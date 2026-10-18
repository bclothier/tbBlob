# PRD: tbBlob — CastXML-driven C FFI generator for twinBASIC (proof of concept on libgit2)

Status: Draft for review · Date: 2026-10-16

---

## 1. Introduction / Overview

To call a C library (a DLL) from twinBASIC (tB), someone has to hand-write `Declare` statements, `Type`s, `Enum`s, `Delegate`s and constants that exactly match the library's C header files. For a large library this is slow and error-prone. The existing hand-written sample, `libgit2tB.twinproj`, shows the problem. It covers about 9 of libgit2's ~850 functions, and it already contains mistakes that would crash or corrupt memory at runtime, for example:

- `git_error_last` is declared as returning a `git_error` structure, but in C it returns a *pointer* (`const git_error *`).
- Several callbacks declare pointer-to-struct parameters as `ByVal As <SomeType>` (passing the whole struct) instead of a pointer.
- `git_fetch_negotiation.refs` is declared as an inline struct, but in C it is a pointer.
- Some delegates are missing `CDecl` or their return type; `TestIt` declares `Dim remote As git_repository` where it should be `git_remote`.

**CastXML** is a tool that reads C/C++ headers using the real Clang compiler and writes out an XML description of every function, struct, field, enum and typedef — including each struct's exact size and every field's offset in memory, and the location of each doc comment. If we can turn that XML into tB code automatically, we remove both the effort and these classes of mistakes.

**tbBlob** is a tB console application that will:

1. Take **any** folder of C header files, the main header to start from, and the DLL name.
2. Run CastXML on them (once for 32-bit, once for 64-bit), plus a macro dump to get `#define` constants.
3. Read the XML and generate raw tB bindings, with the C doc comments.
4. Write the bindings out as `.twin` files in an output folder, with a report of everything it could not generate (how the files are added to a project is up to the user; D-023).

This PRD defines a **proof of concept**. The question it must answer is: **"Can CastXML be used to automate C FFI for twinBASIC?"** libgit2 is the test subject because it is large and hard: ~850 functions, ~85 structs (some nested and over 400 bytes), ~85 enums, ~70 callback types, variadic functions, a bitfield, and many option structs full of callbacks.

## 2. Goals

1. **Generate** complete raw bindings (`.twin` files) for libgit2 v1.9.1 from its headers with no hand edits to the generated code.
2. **Compile**: the generated project compiles in the twinBASIC IDE with zero errors, as both win32 and win64.
3. **Prove the memory layout is right**: for every generated `Type`, its size and every field offset in tB matches what CastXML reports for the same architecture, on both win32 and win64.
4. **Prove it works at runtime**: a separate tB test project that uses only the generated bindings runs a local git scenario and a clone with callbacks, on both win32 and win64.
5. **Stay generic**: nothing in tbBlob is libgit2-specific, and it works on a header folder from anywhere (not only vcpkg).
6. **Report honestly** what could not be generated (e.g. initializer macros) so the reader knows exactly where the approach stops.
7. End with a clear **verdict**: works / works with listed limits / does not work, backed by the results above.

## 3. User Stories

- As a **tB developer**, I want to point tbBlob at a C library's header folder and get `.twin` files of bindings, so that I can call the library without writing hundreds of `Declare` statements by hand.
- As a **tB developer**, I want the same generated code to work in both 32-bit and 64-bit builds, so that I don't maintain two versions.
- As a **tB developer**, I want each C header to become its own tB module, with the library's own doc comments, so that I can find and understand a function the same way I would in the library's C documentation.
- As a **tB developer**, I want a report of everything tbBlob skipped or renamed, so that I know what I'll need to handle by hand.
- As the **decision maker**, I want measurable pass/fail evidence (compile, layout check, runtime tests on both architectures), so that I can decide whether to invest in tbBlob as a real tool.

## 4. Functional Requirements

### 4.1 Input and invocation

1. tbBlob must be a twinBASIC **console** application (Standard EXE, `Sub Main` — the existing `tbBlob.twinproj`).
2. tbBlob must accept, on the command line:
   - the header folder (used as the include path and as the filter for what gets generated),
   - the entry header file (e.g. `git2.h`),
   - the DLL name to bind to (e.g. `git2.dll`),
   - the output folder (D-023: tbBlob writes `report.md`, `Source\` with the `.twin` files, and `Work\` there),
   - an optional project name (default: derived from the DLL name),
   - optional extra include folders (`-I`) and defines (`-D`), for libraries whose headers include other libraries' headers,
   - an optional path to `castxml.exe` (default: search `PATH`, then a path given in a config/env variable).
3. tbBlob must print a usage message and exit with a non-zero exit code when required arguments are missing or a path does not exist.
4. tbBlob must **not** depend on vcpkg. vcpkg is only how CastXML and libgit2 happened to be obtained for this proof. The only external requirements are `castxml.exe` (with its `share` folder next to its `bin` folder) and an MSVC toolchain (see §7.2 item 2).

### 4.2 Running CastXML

5. tbBlob must locate the MSVC build environment (Visual Studio 2022 or Build Tools via `vswhere.exe`, then `vcvars32.bat` / `vcvars64.bat`).
6. tbBlob must run CastXML **twice** — once in the x86 environment and once in the x64 environment — producing two XML files. The verified command shape is:

   ```
   cmd /c ""<vcvarsNN.bat>" >nul && "<castxml.exe>" --castxml-cc-msvc-c cl --castxml-output=1 -I "<include>" -o "<out.xml>" "<include>\<entry.h>""
   ```

7. tbBlob must run CastXML a third time with `-E -dM` (same compiler emulation and include paths) to dump all `#define` macros to a text file.
8. tbBlob must stop with a clear error message (including CastXML's own output) if any CastXML run fails.
9. tbBlob must keep the two XML files, the macro file and the `.cmd` scripts that produced them in the output folder's `Work\` subfolder, so they can be inspected and re-run.

### 4.3 What to generate (raw bindings only)

10. **Filtering:** only declarations whose source file is inside the given header folder must be generated. System/CRT declarations (from MSVC and Windows SDK headers) must be ignored.
11. **Functions** → `Public DeclareWide PtrSafe Function|Sub <name> CDecl Lib "<dll>" (...)`, one per exported C function. The calling-convention keyword comes from CastXML's `attributes` (`__stdcall__` → none, `__fastcall__` → `FastCall`, `__thiscall__` → `ThisCall`, no attribute → `CDecl`). `PtrSafe` is always emitted.
12. **Structs** → tB `Type`s with fields in the same order as C. Fixed-size arrays (e.g. `unsigned char id[20]`) must become fixed-size arrays in tB (`id(0 To 19) As Byte`).
13. **Anonymous structs** declared as `typedef struct { ... } name;` (most libgit2 option structs) must be generated as a `Type` named after the typedef.
14. **Opaque structs** (declared but never defined, e.g. `git_repository`) → a pointer-sized alias at file scope, as the sample does: `Public Alias git_repository As LongPtr`. Handle variables then carry the type name but are stored as `LongPtr`.
15. **Other typedefs** of scalar types → `Public Alias <name> As <tB type>` where useful (e.g. `git_object_size_t`), so generated signatures keep the C type names.
16. **Enums** → tB `Enum`s with the exact numeric values from CastXML (not re-computed expressions).
17. **Function-pointer typedefs** (callbacks) → tB `Public Delegate Function|Sub <name> CDecl (...)`, with correct return type (`Sub` for `void`). Struct fields and parameters whose C type is that typedef must use the delegate type. Unnamed function-pointer fields (e.g. `int (*connect)(...)` inside `git_transport`) must get a generated delegate named after the struct and field.
18. **Constants** from the macro dump → `Public Const` for macros whose value is a plain integer, a string literal, a character literal, or a simple expression made of those and other already-generated constants. Initializer macros (e.g. `GIT_CLONE_OPTIONS_INIT { ... }`) and function-like macros must be skipped and listed in the report.
19. **Type mapping:**
    - Pointer-sized C types (any pointer, `size_t`, `ssize_t`, `intptr_t`, `uintptr_t`, `ptrdiff_t`) → `LongPtr` (or the opaque alias / `Type` / delegate per requirements 14, 17 and 20). This is what lets one source serve both architectures.
    - **Unsigned types → the signed tB type of the same size**, marked `/* unsigned */`, as in the sample: `unsigned char`/`uint8_t` → `Byte` (already unsigned), `unsigned short`/`uint16_t` → `Integer`, `unsigned int`/`uint32_t`/`unsigned long` → `Long`, `unsigned long long`/`uint64_t` → `LongLong`. tB has no unsigned types other than `Byte` (see §7.4). This is acceptable because these values are passed through, not used in arithmetic.
    - Signed: `char`/`signed char` → `Byte` (flagged in comment), `short` → `Integer`, `int`/`long` → `Long`, `long long`/`int64_t` → `LongLong`, `float` → `Single`, `double` → `Double`, `_Bool` → `Byte`.
    - C enum types → the generated tB `Enum` (4 bytes).
    - The final table is confirmed by spike §7.5 and recorded in the decision log.
20. **Pointer parameters:** one consistent, documented rule, to be confirmed by spike and recorded in the decision log. Starting proposal, based on the tB docs and WinDevLib:
    - pointer to struct (`git_x *`, `const git_x *`) → `ByRef <name> As git_x` (callers pass `ByVal vbNullPtr` for `NULL`);
    - pointer to opaque handle (`git_repository *`) → `ByVal <name> As git_repository` (the alias is already a pointer);
    - out-parameter `T **` → `ByRef <name> As T` when `T` is opaque, otherwise `ByRef <name> As LongPtr`;
    - `const char *`, `char *`, `void *` and anything else → `ByVal <name> As LongPtr`.
    - Functions returning any pointer must return `LongPtr` (or the opaque alias), never a struct by value. Callers read a returned struct pointer with `CType(Of git_x)(ptr)`.
21. **Constants and enum values with the top bit set** (e.g. `1u << 31`, `0xFFFFFFFF`) must be written as the signed bit pattern of the target size (e.g. `&H80000000`, `&HFFFFFFFF`, with the right `&` / `^` type suffix) so tB neither rejects them as overflow nor reads them as a different number.
22. **Variadic functions** (libgit2 has two: `git_libgit2_opts`, `git_commit_create_v`) → a declare whose last parameter is `ByVal ParamArray args As Any()`, which the tB docs document for C `...` (§7.4). A C `va_list` parameter → `ByRef ParamArray args As Any()`. The generated comment must warn that a plain variable passed in the variadic part goes **by address**; pass `ByVal x` or `(x)` to pass the value. Behaviour is confirmed by spike §7.5.
23. **Bitfields** (libgit2 has one: `git_commit_create_options.allow_empty_commit`) → the underlying storage field(s) at the correct size and offset, with a comment naming the packed bits. The item must be listed in the report.
24. **Unions** (none in libgit2, but other libraries have them; tB has no union support) → a `Type` containing a byte array of the union's size, with alignment preserved, and a comment listing the union's members. Listed in the report.
25. **Packing:** tbBlob must compute the natural-alignment layout of every generated `Type` and compare it with CastXML's offsets. If they differ (e.g. a header uses `#pragma pack`), it must emit `[PackingAlignment(n)]` on the `Type` when that reproduces CastXML's layout, and otherwise report the struct as unsupported. libgit2 needs none (§7.2 item 5).
26. **Naming:** generated names must keep the C name wherever possible.
    - C is case-sensitive and tB is not, so tbBlob must detect names that collide when case is ignored. libgit2 has 41 such pairs. Most are a function vs an initializer macro that won't be generated anyway (e.g. `git_diff_options_init` vs `GIT_DIFF_OPTIONS_INIT`), but some are real (enum value `GIT_REPOSITORY_OPEN_BARE` vs function `git_repository_open_bare`; enum value `GIT_CERT_X509` vs type `git_cert_x509`).
    - **Functions:** when a function's tB name has to change, the generator must keep the real export name with `Alias` in the declare, e.g. `Public DeclareWide PtrSafe Function git_repository_open_bare_ CDecl Lib "git2.dll" Alias "git_repository_open_bare" (...)`. The DLL entry point must always be the exact C name. Functions are therefore the preferred thing to rename.
    - **Fields and parameters:** tB allows keywords as `Type` field names (WinDevLib uses `Type`, `Get`, `Put`, `Error`, `Line`) and as parameter names (`Class`, `Error`). tbBlob must escape a name with square brackets (`[ReadOnly]`) only where tB requires it; the exact list is confirmed by spike. Renaming fields and parameters doesn't affect the binary interface.
    - **Enum values, types, delegates, constants:** `Alias` doesn't apply, so the tB name itself changes using a deterministic rule recorded in the decision log, kept to a minimum.
    - Every rename and escape must be listed in the report.
27. **Doc comments:** each generated function, `Type`, field, `Enum`, delegate and alias must carry:
    - the library's own doc comment, copied from the header using the byte range CastXML gives in its `Comment` element (`file`, `begin_offset`, `end_offset`), converted to tB `'` comment lines;
    - a one-line comment with the original C declaration, so a reader can check the mapping.
    - CastXML gives no comment for individual enum values. tbBlob should extract a trailing `/**< ... */` or `/* ... */` comment from the enum value's source line when one exists, and otherwise omit it.

### 4.4 Output folder (D-023)

28. Each C header file must become **one tB module** (e.g. `git2/repository.h` → `git2_repository.twin`), written to `<output folder>\Source\` together with the layout-check module (req. 34). Shared `Type`s, `Alias`es (which must be at file scope) and delegates must be placed so a project that includes the files compiles regardless of module order.
29. tbBlob produces **only `.twin` files** (plus the report and the `Work\` files): it writes no `Settings` and no `.twinproj`, and does not call the import tool. How the files are incorporated into a project is the user's concern. The output folder documents itself: `report.md` (read first), `Source\` (the `.twin` files), `Work\` (CastXML output and the scripts that produced it).
30. The generated files contain only bindings: no wrapper classes, no helpers. tbBlob's tests and the harnesses package them into projects themselves (with the import tool), as included sources (§7.5 item 8).
31. tbBlob must write a **generation report**, `<output folder>\report.md`, listing: counts of each generated item kind, every skipped item with its reason, every rename/escape with its reason, every bitfield/union/packed struct, and any x86-vs-x64 disagreement.
32. Generation must be **deterministic**: same input → byte-identical output.

### 4.5 Proof harness (separate test project)

33. The harness is a **separate tB test project** that consumes the generated bindings. It **replaces `libgit2tB.twinproj`**. The old project's exported source is kept only as a reference (e.g. `reference\libgit2tB\`).
34. **Layout self-check:** tbBlob must also emit, for each architecture, the expected size of every generated `Type` and the offset of every field, taken from that architecture's CastXML file. The harness compares these against the actual tB layout (`LenB(...)` and `VarPtr(field) - VarPtr(var)`) and prints every mismatch. It must pass with zero mismatches when built as win32 and as win64.
35. **Local git scenario:** using only the generated bindings, the harness must: initialise libgit2, create a new repository in a temp folder, write and stage a file, create a commit with a signature, read it back through a revwalk, create a branch, produce a diff between two commits, read `git_error_last` (through `CType(Of git_error)`) after a deliberately failing call, call one variadic function (`git_libgit2_opts`, e.g. get/set a cache limit), and shut libgit2 down. Each step must check the return code and print pass/fail.
36. **Callbacks + clone:** clone a local repository (a local path or `file://` URL — no network) with `git_clone_options` filled in, including a checkout progress callback and a fetch transfer-progress callback, and show that both callbacks were actually called with sensible values.
37. Requirements 35 and 36 must pass when built as win32 (against libgit2 x86) and as win64 (against libgit2 x64). The harness must load the correct `git2.dll` for its architecture (e.g. by copying the matching DLL set into its build folder, or pre-loading with `LoadLibraryExW` as the old sample does).
38. Compiling is done **manually in the twinBASIC IDE** by the user. Each step that needs a compile must stop and ask the user to compile and report the IDE's error list and the test output.

### 4.6 Synthetic C test library (primary test target)

libgit2 does not contain every C construct tbBlob must handle (it has no unions, no structs passed or returned by value, no `float`/`double`/`_Bool` fields, no `va_list`, no `#pragma pack`, no `__declspec(align)`, no `__stdcall`). A small purpose-built C library fills those gaps and gives failures that point at exactly one construct. libgit2 stays the final real-world acceptance test.

39. The repository must contain a synthetic C library, `tbfixture`: one header (`tbfixture.h`), one source file (`tbfixture.c`), and a build script that compiles it with MSVC into `tbfixture.dll` for **x86 and x64** (one output folder per architecture). It must not depend on anything except the C runtime.
40. The header must cover, as exported functions, struct fields, parameters and return values:
    - **Scalars:** every C integer type signed and unsigned (`char` … `long long`), `float`, `double`, `_Bool`, `size_t`, `intptr_t`, `wchar_t`.
    - **Pointers:** `T*`, `const T*`, `T**`, `void*`, `char*`, `wchar_t*`, array parameters, NULL.
    - **Structs:** by value as a parameter and as a return value at 4, 8, 16 and more than 16 bytes; nested structs; fixed arrays; structs containing function pointers.
    - **Layout:** unions (standalone, inside a struct, anonymous), bitfields, `#pragma pack(1)` and `(2)`, `__declspec(align(16))`.
    - **Calling:** cdecl and `__stdcall` functions and callbacks; callbacks with struct-pointer parameters; variadic `...`; `va_list`.
    - **Constants:** enums with negative values and top-bit values (`0x80000000u`); macros of each kind (integer, expression, char, string, reference to another macro, initializer, function-like).
    - **Naming:** case-insensitive collisions, C names that are tB keywords, an opaque struct whose typedef name differs from its struct name, doc comments, trailing enum-value comments.
41. Each export must be **self-checking** where possible: functions that receive data return a code saying which field or argument was wrong (0 = all correct), and functions that return data return known values the test can compare, so a failure names the construct and the direction (tB→C or C→tB).
42. The library must export a **layout table** with `sizeof` and `offsetof` for every struct and field, computed by MSVC. The runtime harness compares tB's layout against it, so layout is checked against the real compiler as well as against CastXML.
43. A tiny C test program, built by the same script, must call every export with correct values and confirm it reports success, so the fixture itself is known-good before tB uses it.
44. The tB runtime harness (requirement 33) must also run against `tbfixture` on win32 and win64. For constructs tB cannot express (e.g. `__declspec(align(16))`, possibly structs returned by value), the expected result is a correct entry in tbBlob's generation report rather than a working binding.

## 5. Non-Goals (Out of Scope)

- **C++ APIs**: classes, methods, templates, overloads, namespaces, name-mangled functions. C++ headers that only expose `extern "C"` functions are in scope; everything else is reported and skipped.
- **Friendly wrappers**: no generated helper functions, string-conversion helpers or object-style classes (no `Repository` class). These may be hand-written later on top of the raw bindings. The test harness may contain its own small helpers (e.g. UTF-8 conversion), but they are not generated.
- **Headless/automatic compilation** of tB projects. The `tb-build` skill does not work and the IDE's `--buildAndExit` flags are documented as unreliable; compiling stays manual.
- **Network operations** in tests (HTTPS/SSH clone, real credentials).
- **Non-Windows platforms** and non-MSVC compilers (MinGW/GCC emulation is possible with CastXML but not part of this proof).
- Libraries other than libgit2 as test subjects (though tbBlob must not be libgit2-specific).
- Using the `tb-import` / `tb-export` skills. Use `tBImportExport_win64.exe` instead.
- A GUI.

## 6. Design Considerations

- Console output: one short progress line per stage (locate tools, CastXML x86, CastXML x64, macros, parse, generate, import), then summary counts and the path to the report.
- Generated code style follows the existing sample and WinDevLib: doc comment, then C declaration comment, then the tB declaration; `CDecl` on every declare and delegate; one parameter per line with line continuations; `/* unsigned */` markers.
- tbBlob's own structure can follow `impexp.twinproj` (§7.6), which is a working tB console tool of the same kind.

## 7. Technical Considerations

### 7.1 Verified environment (checked 2026-10-16)

| Component | Location / version | Verified how |
|---|---|---|
| CastXML 0.6.5 (Clang 18.1.3) | `CastXML\vcpkg_installed\x64-windows\tools\castxml\` (`bin\castxml.exe` + `share\`) | `--version`; also ran from a copy in an unrelated folder |
| libgit2 v1.9.1 **x64** | `libgit2\vcpkg_installed\x64-windows\` — `bin\git2.dll` (+ `pcre*.dll`, `zlib1.dll`), `include\git2.h` | files present |
| libgit2 v1.9.1 **x86** | `libgit2\vcpkg_installed_x86\x86-windows\` — same file set as x64 (separate install root so the x64 install is untouched) | built with VS-bundled vcpkg on 2026-10-16 (`vcpkg install --triplet x86-windows --x-install-root=...`); `git2.dll` PE machine type `0x14C` (i386); `LIBGIT2_VERSION "1.9.1"` |
| MSVC 14.44 (VS 2022 Enterprise) | `vcvars32.bat`, `vcvars64.bat`; VS-bundled `vcpkg.exe` | used to run CastXML for both architectures |
| twinBASIC IDE/compiler | `C:\TwinBasic\` (`bin\twinBASIC_win32.exe`, `twinBASIC_win64.exe`) | present |
| tB import/export tool | `Build\tBImportExport_win64.exe` (source: `impexp.twinproj`) | exported all three projects in this folder successfully |
| Python 3.13 | `C:\Program Files\Python313` | used only for this research, not part of tbBlob |

### 7.2 Findings about CastXML and the libgit2 headers

1. **The original CastXML command was reconstructed.** The command in requirement 6, run under `vcvars64` on the vcpkg headers, produces XML in the same format (`CastXML format="1.4.0"`) with the same 844 `git_*` functions and the same struct/enum/callback counts as the hand-built `git2.xml`.
2. **No vcpkg dependency; MSVC is needed.** CastXML ran from a copy of its folder in an unrelated location, on a copy of the headers in another unrelated location, with identical results. It needs the MSVC environment (`vcvars`) because `--castxml-cc-msvc-c cl` asks `cl` for the system include paths. Without `vcvars` it fails with `fatal error: 'time.h' file not found`. In theory the system include folders could be passed with `-I` instead, but the MSVC headers (`vcruntime.h`) still have to exist, so MSVC (Build Tools is enough) is a requirement. CastXML itself can also be obtained without vcpkg (e.g. CastXMLSuperbuild release binaries or the `castxml` PyPI package).
3. **The existing `git2.xml` is a 32-bit layout** (4-byte pointers; `git_clone_options` = 236 bytes), made from a previous prototype's headers. The x64 layout of the same struct is 416 bytes. Don't use that file as a 64-bit reference.
4. **The headers are architecture-neutral.** The `include` folders of the x86 and x64 vcpkg installs are byte-identical. Only `git2/stdint.h` branches on `_WIN64`, and only to define pointer-sized integer types.
5. **One `LongPtr`-based source can describe both architectures — on paper.** Comparing x86 and x64 CastXML output from the same headers: all 85 structs, 848 functions and 84 enums are identical once pointer-sized types are treated as "pointer". Laying out each struct with standard C natural alignment (pointer = 4 or 8 bytes) reproduces CastXML's exact sizes and offsets for all 84 non-bitfield structs on both architectures. The tB docs say tB also "aligns objects naturally within UDTs" (§7.4). What is not yet proven is that tB does so on win32 for 8-byte members — spike §7.5 item 1.
6. **Calling convention:** every libgit2 function is plain `cdecl` (CastXML shows only `attributes="dllexport"`, no `__stdcall__`) on both architectures.
7. **CastXML units:** `size`, `align` and `offset` in the XML are in **bits**, not bytes.
8. **Anonymous typedef structs:** `typedef struct { ... } git_fetch_options;` appears in the XML as a `Struct` with an empty name, reached from a `Typedef` through an `ElaboratedType`. A generator that only looks at named `Struct`s sees 37 structs instead of 85.
9. **Macros are not in the XML.** `castxml --castxml-cc-msvc-c cl -E -dM ...` dumps them: 1,916 macros, 200 starting with `GIT_`. Kinds seen: plain numbers (`GIT_OID_SHA1_SIZE 20`), references to other macros (`GIT_OID_RAWSZ GIT_OID_SHA1_SIZE`), expressions (`(GIT_OID_SHA1_SIZE * 2)`), char literals (`GIT_PATH_LIST_SEPARATOR ';'`) and struct initializers (`{ ... }`, to be skipped). The macro dump has no source location, so macros get no doc comment.
10. **Doc comments are recoverable.** The XML has 1,577 `Comment` elements with `file`, `begin_offset` and `end_offset` (byte offsets) but no text. Reading those bytes from the header gives the exact comment, e.g. the full `/** Open a git repository. ... */` block for `git_repository_open`. Coverage: 799 of 844 functions and 335 of 433 struct fields have a comment. Enum values have none in the XML.
11. **Hard cases in libgit2:** variadic functions `git_libgit2_opts` and `git_commit_create_v` (XML `<Ellipsis/>`); one bitfield struct (`git_commit_create_options`); 5 structs with 8-byte scalars that are alignment-sensitive on x86 (`git_diff_file`, `git_diff_line`, `git_diff_options`, `git_odb_stream`, `git_time`); 41 case-insensitive name collisions; keyword-like field/parameter names (`type`, `local`, `free`, `close`, `len`, `lock`, `name`, `to`, `version`); no unions.

### 7.3 Findings about the existing samples

- **`libgit2tB.twinproj`** (Standard DLL, `Sources\Git.twin` + `UTF8.twin`): ~20 delegates, ~15 enums, ~20 types, 9 declares. Its idioms are correct and worth keeping: `Public Alias git_repository As LongPtr` for opaque handles, `DeclareWide ... CDecl`, `ByVal vbNullPtr` for `NULL` struct pointers, a `UTF8` helper class for `const char *`, `LoadLibraryExW` to pre-load the DLL. Its errors are listed in §1. It references WinDevLib as a local package, but the exported `Packages` folder is empty, so it may not compile as-is.
- **`tbBlob.twinproj`**: empty Standard EXE, console app, `Sub Main`, references VB + stdole only. `project.exportPath` is `${SourcePath}\Source`.

### 7.4 Findings about twinBASIC (docs.twinbasic.com and github.com/twinbasic)

Sources: `twinbasic/documentation` (commit d534c50, the source of docs.twinbasic.com), issues in `twinbasic/twinbasic` and `twinbasic/lang-design`, and `fafalone/WinDevLib` (commit 424436e). **WinDevLib is hand-written, not generated**, but it is widely used and battle-tested, so it is the best reference for how experienced developers write these declarations. Each pattern below still needs confirming on both architectures in the spike.

**Declare / DeclareWide** (`Reference/Core/Declare.md`, `Features/Advanced/API-Declarations.md`)
- Syntax: `[Public|Private] Declare [PtrSafe] Function name [callconv] Lib "libname" [Alias "aliasname"] ([arglist]) [As type]`. `Alias "x"` names the DLL entry point.
- `callconv` is `CDecl`, `ThisCall` or `FastCall`, placed after the name; default is stdcall. "A 64-bit build has only one calling convention. There, all four keywords are accepted and have no effect." Naming two is error TB5258.
- `DeclareWide` "disables ANSI<->Unicode conversion" for `String` arguments. Generated declares pass strings as `LongPtr`, so it makes no difference to them; it is used for consistency with the sample.
- `ByRef`/`ByVal` should be explicit. To pass `NULL` to a `ByRef` UDT parameter, use `ByVal vbNullPtr`. A known 64-bit LLVM bug: `ByVal 0&` as NULL to an 8th+ `ByRef` 32-bit parameter can cause an access violation. Use `vbNullPtr` / `LongPtr` instead.

**Alias (type alias)** (`Reference/Core/Alias.md`)
- `[Public|Private] Alias aliasname As type`, "comparable to `typedef` in C/C++". Valid only in `.twin` files, **at file scope, outside `Module` and `Class` blocks**. Aliases of aliases are allowed. A `Private` alias is replaced by the underlying type when compiled. WinDevLib example: `Public Alias DWORD As Long`, `Public Alias SIZE_T As LongPtr`.

**Delegate** (`Reference/Core/Delegate.md`)
- `{Public|Private} Delegate Function name [callconv] ([arglist]) As type` (or `Delegate Sub`). Public or Private is required.
- "A delegate value is bit-compatible with LongPtr". A delegate can be the type of a `Type` member and of a `Declare` parameter. `AddressOf` returns a delegate. A signature mismatch is only warning TB0026 (can be made an error with `[EnforceErrors(TB0026)]`).
- CDecl callbacks work: `Private Function Comparator CDecl(...)` passed to msvcrt `qsort` is a documented example. CDecl procedures are supported since BETA 287.
- Known defects: on win32, calling *through* a `ThisCall`/`FastCall` delegate from tB passes stdcall (issue #2443, open; **CDecl not affected**). Delegates in **packages** had bugs: #1999 (closed 2025-01-12) and #1890 "project compiler constants not applied to packages" (open). WinDevLib still keeps its delegate-typed declares disabled and uses `LongPtr` instead.

**Variadic functions** (`Features/Advanced/API-Declarations.md` "Variadic" section; issue twinbasic#671; lang-design#25)
- C `...` → `ByVal ParamArray args As Any()`; C `va_list` → `ByRef ParamArray args As Any()`. `ByRef`/`ByVal` must be explicit. Supported since v0.13.79. Documented example:
  ```
  Private DeclareWide PtrSafe Function wsprintfW CDecl Lib "user32" ( _
      ByVal buf As String, ByVal format As String, ByVal ParamArray args As Any()) As Long
  ```
- Important: per Wayne Phillips (#671, v0.13.81), even with `ByVal ParamArray`, "referenceable variables are already passed as pointers unless the inline `ByVal` attribute is used". So at the call site a plain variable goes by address; use `ByVal x` or `(x)` to pass its value. WinDevLib: "These are all ByVal so pass ByRefs as ByVal VarPtr() etc."
- WinDevLib uses this for `wsprintfA/W`, `swprintf`, `DbgPrint`, `ShellMessageBox`, and `ByRef ParamArray` for `wvsprintf` / `FormatMessage`.
- The `ParamArray.md` and `Declare.md` pages say ParamArray "can't be used with ByVal, ByRef" — this is VBA-inherited text about ordinary procedures and contradicts the API-Declarations page. The API-Declarations page is the authority for declares.
- Not documented: how `Double`, `LongLong` and UDT arguments are passed in the variadic part. Spike needed.

**Type (UDT) layout** (`Reference/Core/Type.md`, `Features/Language/UDTs.md`, `Reference/Attributes.md`)
- "twinBASIC normally aligns objects naturally within UDTs, e.g. an 8-byte object is aligned at the 8-byte boundary relative to the beginning of the UDT."
- `[PackingAlignment(1|2|4|8|16|32|64)]` on a `Type` is equivalent to MSVC `#pragma pack(n)`. There is no equivalent of `__declspec(align(n))` yet (issue #1308, open).
- `Len` counts only member sizes; `LenB` includes padding — use `LenB` for C sizes.
- Fixed-size arrays in a `Type` need literal or constant bounds. "Element names ... keywords can be used."
- Win32 caveat: a `Currency` member was fixed to match VB6 (not 8-byte aligned, issue #136); WinDevLib notes that `LongLong` triggers 8-byte alignment where `Currency` didn't. So always map 8-byte C integers to `LongLong`, never `Currency`, and confirm the win32 alignment of `LongLong` and `Double` in the spike.
- **No union support** (lang-design#56, post-1.0).

**Data types** (`Reference/Data-Types.md`)
- `Byte` 1 (unsigned), `Integer` 2, `Long` 4, `LongLong` 8 (available on win32 too), `LongPtr` 4/8, `Single` 4, `Double` 8, `Boolean` 2 (not C's 1-byte `_Bool`).
- "Byte is the only unsigned integer type." Unsigned types are a proposal (lang-design#9, open). Hence requirement 19's signed stand-ins.
- `Enum` values are `Long`; no documented way to give an enum a different size.

**Pointers** (`Features/Language/Pointers.md`)
- `CType(Of T)(ptr)` views the memory at `ptr` as a `T` without copying (`With CType(Of foo)(ptr) : .a = 1 : End With`). The harness uses this to read returned struct pointers such as `git_error_last()`.
- `LenB(Of T)` gives a type's size without a variable, e.g. `LenB(Of LongPtr)`.

**Names**
- Square brackets escape names: `[ReadOnly]`, `[_Max]`. `ReadOnly` is a tB-specific reserved word that needs escaping in some declaration contexts. There is no published full list of reserved words — spike needed.

**Prior art**
- No official header import tool exists. lang-design#39 "Allow imports of .h files" is open; Wayne noted that headers need "a full C compiler" to interpret and don't say which DLL a symbol is in. CastXML addresses the first point; tbBlob's DLL-name argument addresses the second.

### 7.5 Undocumented / experimental unknowns — need a spike before task planning

> **Resolved 2026-10-16** by the spikes in `tasks/spikes-castxml-ffi-generator.md`; findings are D-001 … D-009 in `tasks/decisions-castxml-ffi-generator.md`, which take precedence over the text below where they differ.

Small throwaway tB probes, compiled manually in the IDE, as win32 and win64:

1. **`Type` layout vs C**: padding between fields and at the end, nested `Type`s, fixed arrays, and 8-byte members (`LongLong`, `Double`) on win32. Check against the CastXML values for a few libgit2 structs (e.g. `git_time`, `git_diff_file`, `git_clone_options`). Confirm `LenB` / `VarPtr` differences measure it reliably.
2. **Delegates**: as `Type` fields (including nested option structs), as `Declare` parameters, assigning `AddressOf` to a delegate field, and a `CDecl` callback being called from C on both architectures.
3. **Pointer parameter rules** (requirement 20): `ByRef As Type`, opaque alias `ByVal`/`ByRef` for `T*`/`T**`, `ByVal vbNullPtr` for NULL, reading a returned struct pointer with `CType(Of T)`.
4. **Strings**: passing UTF-8 `const char *` as `LongPtr` and reading returned `char *` in the harness (the sample's `UTF8.twin` approach).
5. **Scalar mapping**: confirm requirement 19's table, including `Enum`-typed fields and parameters being 4 bytes, and top-bit-set constants (requirement 21).
6. **Variadic declares**: `ByVal ParamArray args As Any()` with `CDecl` on both architectures, with `Long`, `LongPtr`, `LongLong` and string-pointer arguments. Confirm the by-address behaviour of plain variables (#671) still holds.
7. **Naming**: which identifiers tB actually rejects as field/parameter/enum/constant names and need `[ ]`; how case-insensitive duplicates behave across modules; that `Alias "name"` in a declare works when the tB name differs.
8. **Generated project shape**: minimum `Settings` the import tool and IDE accept; **package vs included sources** for the bindings, given the package/delegate bugs (#1890); how `Lib "git2.dll"` finds the DLL and its dependent DLLs at runtime on each architecture.
9. **Running external processes from tB** (castxml through `cmd /c` with `vcvars`) and capturing the exit code and output. Lower risk.

### 7.6 Reusable code: `impexp.twinproj`

`impexp.twinproj` is the source of `tBImportExport_win64.exe`, a working tB console tool. tbBlob can reuse its patterns or code:

- `MainModule.twin`: `Sub Main`, command-line parsing with `CommandLineToArgvW`, console output with `WriteConsoleW`, exit codes with `ExitProcess`.
- `FileSys.twin`: file and folder I/O (read/write all bytes, list, make dirs, temp folder, full path).
- `TextKit.twin`: UTF-8 encode/decode (`MultiByteToWideChar`/`WideCharToMultiByte`), ordinal sorting (useful for deterministic output), JSON quoting.
- `Json.twin`, `ProjectFormat.twin`: reading and writing `Settings` and the `.twinproj` format.
- `SelfTest.twin`: a `--self-test` pattern with ~50 built-in tests. This is a model for tbBlob's own unit tests of the generator, which can run without the IDE once tbBlob itself is compiled.

### 7.7 Third-party dependencies (need integration tests)

- **CastXML** 0.6.5 — external process; XML format `1.4.x`.
- **MSVC toolchain** (VS 2022 or Build Tools) — needed by CastXML's `cl` emulation; located with `vswhere.exe`.
- **libgit2 v1.9.1** x86 and x64, and their runtime DLLs (`pcre*`, `zlib1`).
- **tBImportExport** (`Build\tBImportExport_win64.exe`) — **test-only** (D-023): used by tbBlob's integration tests and the harness build scripts to package generated `.twin` files into projects; tbBlob itself never calls it. Exit codes 0–6.
- **twinBASIC IDE/compiler** (`C:\TwinBasic`) — manual compile only.
- **XML parsing inside tbBlob** — parser choice (e.g. MSXML6 via COM, or hand-written) is decided in the task list; each XML is about 1 MB.

### 7.8 Constraints

- tbBlob must not contain anything libgit2-specific.
- One set of tB sources for both architectures. If the x86 and x64 XML disagree in a way `LongPtr` can't express, tbBlob must report an error rather than silently pick one.
- Generated output is deterministic.

## 8. Success Metrics

The proof is a **success** if all of the following are true:

| # | Metric | Target |
|---|---|---|
| 1 | Generated libgit2 bindings compile in the IDE | 0 errors, as win32 and win64 |
| 2 | Layout self-check | 0 mismatches across all generated `Type`s, win32 and win64 |
| 3 | Local git scenario (req. 35), including one variadic call | all steps pass, win32 and win64 |
| 4 | Callbacks + clone (req. 36) | clone succeeds and both callbacks fire with sensible values, win32 and win64 |
| 5 | Coverage | 100% of exported libgit2 functions generated, or each exception listed with a reason |
| 6 | Doc comments | present for every item that has one in the header |
| 7 | Hand edits to generated code | none |
| 8 | Report | every skipped item, rename and escape listed with a reason |
| 9 | Synthetic library (req. 39–44) | every `tbfixture` construct either passes its self-check on win32 and win64, or is listed in the report as unsupported with a reason |

A **partial success** meets 1–4 with a listed set of manual workarounds. The final write-up must state which.

## 9. Open Questions

1. Spike results may change requirements 19, 20, 22, 26 and 30. Those decisions go into the decision log, which supersedes this PRD where they differ.
2. If CastXML itself should be found without a path argument, where should tbBlob look for it (`PATH` only, an environment variable such as `CASTXML`, or a config file next to `tbBlob.exe`)? Default proposal: argument, then `CASTXML` env var, then `PATH`.

## 10. Resolved Decisions (from review, 2026-10-16)

| Topic | Decision |
|---|---|
| Architectures | Both win32 and win64, compiled and run. One `LongPtr`-based source. |
| Output | Raw bindings only. |
| Proof gates | Compiles cleanly; layout self-check; local git scenario; callbacks + clone. |
| Compiling | Always manual in the IDE. |
| Language scope | C APIs only (`extern "C"` in C++ headers included). |
| Pipeline | tbBlob runs CastXML itself (x86, x64, macro dump). |
| Module layout | One tB module per C header. |
| Naming | Function renames use `Alias "c_name"` in the declare. |
| Unsigned | Same-size signed stand-ins, marked `/* unsigned */`. |
| vcpkg | Not a dependency of tbBlob. |
| libgit2 x86 | Built into `libgit2\vcpkg_installed_x86\`. |
| Doc comments | Included. |
| Harness | Separate test project; replaces `libgit2tB.twinproj`, whose source is kept only as a reference. |
| WinDevLib | Reference for idioms (hand-written, battle-tested), not proof. |
| Packages | Not tested separately: if the bindings compile as a DLL/project they will compile as a package (user, 2026-10-16). |
| Synthetic C library | Added (§4.6, req. 39–44) as the primary test target; libgit2 remains the final acceptance test (2026-10-16). |
| Output (D-023) | tbBlob writes only `.twin` files and a report: `<output>\report.md`, `<output>\Source\*.twin`, `<output>\Work\` (CastXML files, scripts). No `Settings`/`.twinproj`, no import tool at runtime; tBImportExport is test-only (2026-10-16). |
