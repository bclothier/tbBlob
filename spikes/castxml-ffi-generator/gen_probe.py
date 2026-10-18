"""SPIKE throwaway: prototype generator that turns libgit2 CastXML output into tB probe sources.

Not application code. It exists to produce real tB bindings so the spikes can test how
twinBASIC compiles and lays them out. The real generator (tbBlob) is written in tB later.

Usage (from this folder):  python -I gen_probe.py
Reads:  xml/git2_x86.xml, xml/git2_x64.xml
Writes: probe/Settings, probe/Sources/*.twin (generated + copies of the hand-written ones in handwritten/),
        gen_report.md
"""
import os
import re
import shutil
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
DLL = "git2.dll"
HEADER_MARK = "/include/git2"  # declarations from files under the header folder

PTR_TYPEDEFS = {"size_t", "ssize_t", "intptr_t", "uintptr_t", "ptrdiff_t", "SSIZE_T"}
FUND = {
    "char": "Byte", "signed char": "Byte", "unsigned char": "Byte", "_Bool": "Byte",
    "short int": "Integer", "short unsigned int": "Integer",
    "int": "Long", "unsigned int": "Long", "long int": "Long", "long unsigned int": "Long",
    "long long int": "LongLong", "long long unsigned int": "LongLong",
    "float": "Single", "double": "Double",
}
CHARS = {"char", "signed char", "unsigned char"}


def unsigned_note(cname):
    return " /* unsigned */" if cname and "unsigned" in cname and cname != "unsigned char" else ""


class Model:
    def __init__(self, path):
        self.root = ET.parse(path).getroot()
        self.by = {e.get("id"): e for e in self.root if e.get("id")}
        self.files = {e.get("id"): e.get("name").replace("\\", "/") for e in self.root if e.tag == "File"}
        self.comments = {e.get("id"): e for e in self.root if e.tag == "Comment"}
        self.anon = {}  # anonymous struct/enum id -> typedef name
        for e in self.root:
            if e.tag == "Typedef":
                t = self.strip(e.get("type"))
                if t.tag in ("Struct", "Union", "Enumeration") and not t.get("name") and t.get("id") not in self.anon:
                    self.anon[t.get("id")] = e.get("name")

    def strip(self, tid):
        e = self.by[tid]
        while e.tag in ("CvQualifiedType", "ElaboratedType"):
            e = self.by[e.get("type")]
        return e

    def in_lib(self, e):
        return HEADER_MARK in self.files.get(e.get("file"), "")

    def header_of(self, e):
        f = self.files.get(e.get("file"), "")
        i = f.find(HEADER_MARK)
        return f[i + len("/include/"):] if i >= 0 else f

    def name_of(self, e):
        return e.get("name") or self.anon.get(e.get("id"))

    def doc(self, e):
        c = self.comments.get(e.get("comment") or "")
        if c is None:
            return []
        path = self.files[c.get("file")]
        with open(path, "rb") as fh:
            raw = fh.read()[int(c.get("begin_offset")):int(c.get("end_offset"))].decode("utf-8", "replace")
        lines = []
        for ln in raw.splitlines():
            ln = ln.strip()
            ln = re.sub(r"^/\*\*<?|^/\*|\*/$|^\*", "", ln).strip() if ln not in ("*",) else ""
            ln = ln.replace("*/", "").rstrip()
            if ln.endswith("_"):
                ln += "."  # a trailing " _" would continue the comment onto the next tB line
            lines.append(ln)
        while lines and not lines[0]:
            lines.pop(0)
        while lines and not lines[-1]:
            lines.pop()
        return lines


class Gen:
    def __init__(self, m64, m86):
        self.m = m64
        self.m86 = m86
        self.report = []
        self.renames = []
        self.modules = {}   # module name -> list of lines (inside Module)
        self.file_scope = {}  # module name -> list of file-scope lines (Alias)
        self.delegates = {}  # delegate name -> (module, lines)
        self.records = {}    # tb name -> struct element
        self.opaques = {}    # tb name -> header
        self.tbnames = {}    # lower name -> (kind, name)
        self.synth = {}      # FunctionType id + ctx -> delegate name
        self.func_names = {}  # c function name -> tb name
        self.delegate_renames = {}

    # ---- naming -------------------------------------------------------
    def claim(self, name, kind):
        key = name.lower()
        if key in self.tbnames and self.tbnames[key] != (kind, name):
            return False
        self.tbnames[key] = (kind, name)
        return True

    def module_for(self, e):
        h = self.m.header_of(e)
        base = re.sub(r"[^A-Za-z0-9]", "_", os.path.splitext(h)[0])  # git2/repository -> git2_repository
        return base

    # ---- type classification -----------------------------------------
    def classify(self, tid):
        m = self.m
        e = m.by[tid]
        if e.tag in ("CvQualifiedType", "ElaboratedType"):
            return self.classify(e.get("type"))
        if e.tag == "Typedef":
            n = e.get("name")
            if n in PTR_TYPEDEFS:
                return ("scalar", "LongPtr", n)
            t = m.strip(e.get("type"))
            if t.tag in ("Struct", "Union"):
                return self.record_or_opaque(t, n)
            if t.tag == "Enumeration":
                return ("enum", m.name_of(t))
            if t.tag == "PointerType" and m.strip(t.get("type")).tag == "FunctionType":
                return ("delegate", self.delegate_renames.get(n, n))
            if t.tag == "FunctionType":
                return ("fntype", n, t.get("id"))
            return self.classify(e.get("type"))
        if e.tag == "FundamentalType":
            n = e.get("name")
            if n == "void":
                return ("void",)
            return ("scalar", FUND[n], n)
        if e.tag in ("Struct", "Union"):
            return self.record_or_opaque(e, None)
        if e.tag == "Enumeration":
            return ("enum", m.name_of(e))
        if e.tag == "PointerType":
            return ("ptr", e.get("type"))
        if e.tag == "ArrayType":
            return ("array", e.get("type"), e.get("max"))
        if e.tag == "FunctionType":
            return ("fntype", None, e.get("id"))
        raise ValueError(f"unhandled type {e.tag} {tid}")

    def record_or_opaque(self, s, typedef_name):
        name = self.m.name_of(s) or typedef_name
        if s.get("incomplete"):
            return ("opaque", self.rename_type(typedef_name or name))
        return ("record", self.rename_type(name))

    def rename_type(self, name):
        return self.type_renames.get(name, name)

    def delegate_for_fntype(self, fn_id, hint):
        key = fn_id + "|" + hint
        if key not in self.synth:
            self.synth[key] = self.emit_delegate(hint, self.m.by[fn_id], None, self.current_module)
        return self.synth[key]

    def field_type(self, tid, hint):
        c = self.classify(tid)
        k = c[0]
        if k == "scalar":
            return c[1] + unsigned_note(c[2])
        if k in ("enum", "record", "delegate"):
            return c[1]
        if k == "opaque":
            return "LongPtr /* opaque by value?! */"
        if k == "ptr":
            p = self.classify(c[1])
            if p[0] == "fntype":
                return p[1] if p[1] else self.delegate_for_fntype(p[2], hint)
            if p[0] == "opaque":
                return p[1]
            return "LongPtr"
        raise ValueError(f"field kind {k}")

    def param(self, tid, hint):
        """-> (passing, tb type)"""
        c = self.classify(tid)
        k = c[0]
        if k == "scalar":
            return "ByVal", c[1] + unsigned_note(c[2])
        if k in ("enum", "delegate"):
            return "ByVal", c[1]
        if k == "record":
            self.report.append(f"struct passed by value: {hint} ({c[1]})")
            return "ByVal", c[1]
        if k == "array":
            return "ByVal", "LongPtr"
        if k == "fntype":
            return "ByVal", c[1] if c[1] else self.delegate_for_fntype(c[2], hint)
        if k == "ptr":
            p = self.classify(c[1])
            pk = p[0]
            if pk == "record":
                return "ByRef", p[1]
            if pk == "opaque":
                return "ByVal", p[1]
            if pk == "fntype":
                return "ByVal", p[1] if p[1] else self.delegate_for_fntype(p[2], hint)
            if pk == "scalar":
                if p[2] in CHARS:
                    return "ByVal", "LongPtr"
                return "ByRef", p[1] + unsigned_note(p[2])
            if pk == "enum":
                return "ByRef", p[1]
            if pk == "ptr":
                q = self.classify(p[1])
                if q[0] == "opaque":
                    return "ByRef", q[1]
                return "ByRef", "LongPtr"
            return "ByVal", "LongPtr"
        raise ValueError(f"param kind {k} for {hint}")

    def ret(self, tid):
        c = self.classify(tid)
        k = c[0]
        if k == "void":
            return None
        if k == "scalar":
            return c[1] + unsigned_note(c[2])
        if k in ("enum", "delegate", "record"):
            return c[1]
        if k == "ptr":
            p = self.classify(c[1])
            return p[1] if p[0] == "opaque" else "LongPtr"
        raise ValueError(f"return kind {k}")

    # ---- C declaration text for comments --------------------------------
    def ctype(self, tid):
        e = self.m.by[tid]
        if e.tag == "CvQualifiedType":
            return ("const " if e.get("const") else "") + self.ctype(e.get("type"))
        if e.tag == "ElaboratedType":
            return self.ctype(e.get("type"))
        if e.tag == "PointerType":
            inner = self.m.strip(e.get("type"))
            if inner.tag == "FunctionType":
                return f"{self.ctype(inner.get('returns'))} (*)({', '.join(self.ctype(a.get('type')) for a in inner if a.tag == 'Argument')})"
            return self.ctype(e.get("type")) + " *"
        if e.tag == "ArrayType":
            return f"{self.ctype(e.get('type'))}[{int(e.get('max')) + 1}]"
        return e.get("name") or self.m.name_of(e) or e.tag

    # ---- emitters -----------------------------------------------------
    def comment_block(self, e, cdecl):
        out = [f"' {ln}" if ln else "'" for ln in self.m.doc(e)]
        out.append(f"' C: {cdecl}")
        return out

    def params_text(self, args, ctx, variadic):
        ps = []
        used = set()
        for i, a in enumerate(args):
            n = a.get("name") or f"arg{i + 1}"
            if n.lower() in used:
                n = f"{n}{i + 1}"
            used.add(n.lower())
            byx, t = self.param(a.get("type"), f"{ctx}_{n}_cb")
            ps.append(f"{byx} {n} As {t}")
        if variadic:
            ps.append("ByVal ParamArray args As Any()")
        if not ps:
            return "()"
        return "( _\n" + ", _\n".join(f"        {p}" for p in ps) + " _\n    )"

    def emit_delegate(self, name, fn, src, module):
        args = [a for a in fn if a.tag == "Argument"]
        r = self.ret(fn.get("returns"))
        if not self.claim(name, "delegate"):
            self.renames.append(f"delegate {name}: case-insensitive collision with {self.tbnames[name.lower()]} -> {name}_")
            self.delegate_renames[name] = name + "_"
            name = name + "_"
            self.claim(name, "delegate")
        lines = self.comment_block(src, self.ctype(fn.get("returns")) + f" (*{name})(...)") if src is not None else [f"' C: unnamed function pointer"]
        kind = "Function" if r else "Sub"
        lines.append(f"Public Delegate {kind} {name} CDecl {self.params_text(args, name, False)}" + (f" As {r}" if r else ""))
        self.modules.setdefault(module, []).extend(["    " + l if not l.startswith("        ") else l for l in "\n".join(lines).split("\n")] + [""])
        return name

    def run(self):
        m = self.m
        self.type_renames = {}
        lib = [e for e in m.root if m.in_lib(e)]

        # 1. enum values and functions first registered for collision detection
        enum_values = set()
        for e in lib:
            if e.tag == "Enumeration":
                for v in e:
                    enum_values.add(v.get("name").lower())
                self.claim(m.name_of(e), "enum")
        for e in lib:
            if e.tag == "Enumeration":
                for v in e:
                    self.claim(v.get("name"), "enumvalue")
        # struct/opaque type names
        for e in lib:
            if e.tag in ("Struct", "Union"):
                n = m.name_of(e)
                if not n:
                    continue
                if not self.claim(n, "type"):
                    new = n + "_"
                    self.renames.append(f"type {n}: collides with {self.tbnames[n.lower()]} -> {new}")
                    self.type_renames[n] = new
                    self.claim(new, "type")

        # 2. opaque aliases (file scope)
        for e in lib:
            if e.tag in ("Struct", "Union") and e.get("incomplete"):
                n = self.rename_type(m.name_of(e))
                if n in self.opaques:
                    continue
                self.opaques[n] = True
                mod = self.module_for(e)
                self.file_scope.setdefault(mod, []).append(f"' C: typedef struct {m.name_of(e)} {m.name_of(e)}; (opaque)")
                self.file_scope[mod].append(f"Public Alias {n} As LongPtr")
        # typedef names of opaque structs can differ from the struct name
        # (typedef struct git_iterator git_note_iterator; typedef struct _LIBSSH2_SESSION LIBSSH2_SESSION;)
        for e in lib:
            if e.tag == "Typedef":
                t = m.strip(e.get("type"))
                if t.tag in ("Struct", "Union") and t.get("incomplete"):
                    n = self.rename_type(e.get("name"))
                    if n in self.opaques:
                        continue
                    self.opaques[n] = True
                    mod = self.module_for(e)
                    self.file_scope.setdefault(mod, []).append(f"' C: typedef struct {m.name_of(t)} {e.get('name')}; (opaque, typedef name differs)")
                    self.file_scope[mod].append(f"Public Alias {n} As LongPtr")
                    self.report.append(f"opaque typedef {e.get('name')} -> struct {m.name_of(t)}: alias emitted under the typedef name")

        # 3. delegates from typedefs
        for e in lib:
            if e.tag == "Typedef":
                t = m.strip(e.get("type"))
                if t.tag == "PointerType" and m.strip(t.get("type")).tag == "FunctionType":
                    self.current_module = self.module_for(e)
                    self.emit_delegate(e.get("name"), m.strip(t.get("type")), e, self.current_module)

        # 4. enums
        for e in lib:
            if e.tag == "Enumeration":
                mod = self.module_for(e)
                lines = self.comment_block(e, f"enum {m.name_of(e)}")
                lines.append(f"Public Enum {m.name_of(e)}")
                for v in e:
                    val = int(v.get("init"))
                    lines.append(f"    {v.get('name')} = {val}")
                lines.append("End Enum")
                self.modules.setdefault(mod, []).extend(["    " + l for l in lines] + [""])

        # 5. records
        for e in lib:
            if e.tag in ("Struct", "Union") and not e.get("incomplete") and m.name_of(e):
                self.emit_record(e)

        # 6. functions
        for e in lib:
            if e.tag != "Function":
                continue
            cname = e.get("name")
            self.current_module = mod = self.module_for(e)
            tbname = cname
            alias = ""
            if not self.claim(cname, "function"):
                tbname = cname + "_"
                self.renames.append(f"function {cname}: collides with {self.tbnames[cname.lower()]} -> {tbname} Alias \"{cname}\"")
                self.claim(tbname, "function")
                alias = f' Alias "{cname}"'
            self.func_names[cname] = tbname
            args = [a for a in e if a.tag == "Argument"]
            variadic = any(a.tag == "Ellipsis" for a in e)
            cdecl = f"{self.ctype(e.get('returns'))} {cname}({', '.join(self.ctype(a.get('type')) + ' ' + (a.get('name') or '') for a in args)}{', ...' if variadic else ''})"
            lines = self.comment_block(e, cdecl)
            if variadic:
                lines.append("' NOTE: variadic. A plain variable in the variadic part is passed by address; use ByVal x or (x) for its value.")
            r = self.ret(e.get("returns"))
            kind = "Function" if r else "Sub"
            lines.append(f"Public DeclareWide PtrSafe {kind} {tbname} CDecl Lib \"{DLL}\"{alias} {self.params_text(args, cname, variadic)}" + (f" As {r}" if r else ""))
            self.modules.setdefault(mod, []).extend(["    " + l if not l.startswith("        ") else l for l in "\n".join(lines).split("\n")] + [""])

    def emit_record(self, e):
        m = self.m
        name = self.rename_type(m.name_of(e))
        self.current_module = mod = self.module_for(e)
        self.records[name] = e
        lines = self.comment_block(e, f"struct {m.name_of(e)} (size {int(e.get('size')) // 8} bytes on x64)")
        if e.tag == "Union":
            lines.append(f"Public Type {name}")
            lines.append(f"    bytes(0 To {int(e.get('size')) // 8 - 1}) As Byte  ' union")
            lines.append("End Type")
            self.report.append(f"union {name}: emitted as byte array")
        else:
            lines.append(f"Public Type {name}")
            unit_seen = set()
            for fid in (e.get("members") or "").split():
                f = m.by[fid]
                if f.tag != "Field":
                    continue
                fname = f.get("name") or f"field_{fid}"
                for ln in m.doc(f):
                    lines.append(f"    ' {ln}" if ln else "    '")
                if f.get("bits"):
                    c = self.classify(f.get("type"))
                    unit_bits = {"Byte": 8, "Integer": 16, "Long": 32, "LongLong": 64}[c[1]]
                    start = int(f.get("offset")) // unit_bits * unit_bits
                    if start in unit_seen:
                        lines.append(f"    ' (bitfield {fname}:{f.get('bits')} is packed into the storage field above)")
                        continue
                    unit_seen.add(start)
                    lines.append(f"    ' bitfield storage: {fname}:{f.get('bits')} (and any following bitfields in this unit)")
                    lines.append(f"    bits_{fname} As {c[1]}")
                    self.report.append(f"bitfield {name}.{fname}: emitted as storage field bits_{fname}")
                    continue
                c = self.classify(f.get("type"))
                if c[0] == "array":
                    et = self.field_type(c[1], f"{name}_{fname}_cb")
                    lines.append(f"    {fname}(0 To {c[2]}) As {et}")
                else:
                    lines.append(f"    {fname} As {self.field_type(f.get('type'), f'{name}_{fname}_cb')}")
            lines.append("End Type")
        self.modules.setdefault(mod, []).extend(["    " + l for l in lines] + [""])

    # ---- layout expectations ----------------------------------------
    def layout_module(self):
        def fields(model, s):
            out = []
            for fid in (s.get("members") or "").split():
                f = model.by[fid]
                if f.tag == "Field":
                    out.append(f)
            return out

        recs86 = {}
        for e in self.m86.root:
            if e.tag in ("Struct", "Union") and self.m86.in_lib(e) and not e.get("incomplete") and self.m86.name_of(e):
                recs86[self.m86.name_of(e)] = e
        lines = ["' GENERATED by gen_probe.py: expected sizes/offsets from CastXML (x86, x64).", "Module Layout",
                 "    Private Function E(ByVal x86 As Long, ByVal x64 As Long) As Long",
                 "        #If Win64 Then", "            Return x64", "        #Else", "            Return x86", "        #End If",
                 "    End Function", ""]
        calls = []
        for name, s64 in sorted(self.records.items()):
            s86 = recs86[self.m.name_of(s64)]
            sub = f"L_{name}"
            calls.append(sub)
            lines.append(f"    Private Sub {sub}()")
            lines.append(f"        Dim v As {name}")
            lines.append(f"        Results.CheckEq \"1.size.{name}\", LenB(v), E({int(s86.get('size')) // 8}, {int(s64.get('size')) // 8})")
            f86 = {f.get("name"): f for f in fields(self.m86, s86)}
            seen_units = set()
            for f in fields(self.m, s64):
                fn = f.get("name")
                o64 = int(f.get("offset"))
                o86 = int(f86[fn].get("offset"))
                if f.get("bits"):
                    ub = {"Byte": 8, "Integer": 16, "Long": 32, "LongLong": 64}[self.classify(f.get("type"))[1]]
                    if o64 // ub in seen_units:
                        continue
                    seen_units.add(o64 // ub)
                    target = f"v.bits_{fn}"
                    o64, o86 = o64 // ub * ub, o86 // ub * ub
                elif self.classify(f.get("type"))[0] == "array":
                    target = f"v.{fn}(0)"
                else:
                    target = f"v.{fn}"
                lines.append(f"        Results.CheckEq \"1.offset.{name}.{fn}\", CLng(VarPtr({target}) - VarPtr(v)), E({o86 // 8}, {o64 // 8})")
            lines.append("    End Sub")
            lines.append("")
        lines.append("    Public Sub RunAll()")
        for c in calls:
            lines.append(f"        {c}")
        lines.append(f"        Results.Info \"1.count\", \"{len(calls)} structs checked\"")
        lines.append("    End Sub")
        lines.append("End Module")
        return lines


def write_crlf(path, lines):
    with open(path, "w", encoding="utf-8", newline="\r\n") as fh:
        fh.write("\n".join(lines) + "\n")


def main():
    m64 = Model(os.path.join(HERE, "xml", "git2_x64.xml"))
    m86 = Model(os.path.join(HERE, "xml", "git2_x86.xml"))
    g = Gen(m64, m86)
    g.run()

    probe = os.path.join(HERE, "probe")
    src = os.path.join(probe, "Sources")
    if os.path.isdir(probe):
        shutil.rmtree(probe)
    for d in ("Sources", "Resources", "Miscellaneous", "ImportedTypeLibraries", "Packages"):
        os.makedirs(os.path.join(probe, d))
    shutil.copy(os.path.join(HERE, "handwritten", "Settings"), os.path.join(probe, "Settings"))
    for f in os.listdir(os.path.join(HERE, "handwritten")):
        if f.endswith(".twin"):
            shutil.copy(os.path.join(HERE, "handwritten", f), os.path.join(src, f))

    for mod in sorted(set(g.modules) | set(g.file_scope)):
        out = [f"' GENERATED by gen_probe.py from {mod.replace('_', '/', 1)}.h (CastXML). Do not edit."]
        out += g.file_scope.get(mod, [])
        out += ["", f"Module {mod}"] + g.modules.get(mod, []) + ["End Module"]
        write_crlf(os.path.join(src, f"{mod}.twin"), out)
    write_crlf(os.path.join(src, "Layout.twin"), g.layout_module())

    rep = ["# gen_probe report", "", f"- modules: {len(set(g.modules) | set(g.file_scope))}",
           f"- records: {len(g.records)}", f"- opaque aliases: {len(g.opaques)}",
           f"- delegates (incl. synthesized): {sum(1 for v in g.tbnames.values() if v[0] == 'delegate')}",
           f"- functions: {len(g.func_names)}", "", "## Renames"] + [f"- {r}" for r in g.renames] + ["", "## Notes"] + [f"- {r}" for r in g.report]
    write_crlf(os.path.join(HERE, "gen_report.md"), rep)
    print("\n".join(rep[:8]))
    print(f"renames: {len(g.renames)}; notes: {len(g.report)}")


if __name__ == "__main__":
    main()
