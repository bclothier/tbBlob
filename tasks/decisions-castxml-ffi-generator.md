> **Append protocol:** This log is append-only. Never edit or delete a past entry's body. A new entry goes at the end with the next sequential ID and gets a new row in the Index — the Index table is the only part of this file ever rewritten in place. To supersede D-0XX with D-0YY: add `- Status: Superseded by D-0YY` to D-0XX (body and Index row) and `- Supersedes: D-0XX` to D-0YY — D-0XX's original text stays untouched. If D-0YY only invalidates part of D-0XX, use `Superseded (partial) by D-0YY` instead and state in D-0YY's own text which part it replaces. Scope is one of: `Task-only` (approach changed, task branch still valid), `Plan` (the task list itself changed), `Finding` (empirical result from a spike — requires `Verified under`). Keep Title ≤ ~15 words — detail goes in the body, not the Index row. Size a `Task-only` entry to its actual shelf life: a durable constraint gets full detail; a resolved work-journal item needs only 3-4 lines. Copy the skeleton below for each new entry.
>
> **Reading this log:** don't open the whole file. Read only the `## Index` section (line-limited read, or `Grep -B2 -A40 '^## Index'`) to scan Scope/Status/Title; jump to one entry's body with `Grep '### D-0NN' -A 20`. This gets cheaper relative to a full read as the log grows, not more expensive — use it that way.

<!-- Entry skeleton — copy below the last entry, don't edit this comment:
### D-0NN — <title> (Task <n.n | Setup | Spike>)
- Date: YYYY-MM-DD
- Scope: Task-only | Plan | Finding
- Status: Active
- Context: <why this came up>
- Decision: <what was decided / observed>
- Rationale: <why>
- Alternatives considered: <what else, and why not>
- Verified under: <Finding only — exact conditions tested: load, concurrency, version, environment>
-->

## Index
| ID | Task | Scope | Title | Status |
|------|------|-------|-------|--------|
| D-001 | Spike | Finding | tB UDT layout equals C natural alignment for all 85 libgit2 structs, both archs | Active |
| D-002 | Spike | Finding | CDecl delegates work as nested UDT fields and declare parameters | Active |
| D-003 | Spike | Finding | Pointer mapping rule verified; vbNullPtr, CType(Of T), alias interchange work | Active |
| D-004 | Spike | Finding | UTF-8 const char* round-trips via ByVal LongPtr, incl. non-ASCII | Active |
| D-005 | Spike | Finding | Scalar map holds: LongLong fields/returns, 4-byte enums, top-bit hex constants | Active |
| D-006 | Spike | Finding | ByVal ParamArray As Any() calls C variadics correctly; plain variables go by address | Active |
| D-007 | Spike | Finding | Keyword-named fields/params compile unescaped; case collisions need renames; declare Alias works | Active |
| D-008 | Spike | Finding | Generated folder imports and compiles; opaque aliases needed per typedef name; DLL preload binds | Active |
| D-009 | Spike | Finding | tB can run castxml under vcvars via WScript.Shell.Exec and capture output/exit code | Active |
| D-010 | Setup | Task-only | Stack: tB console EXE, built-in --self-test, exported Source/ folder is truth | Active |
| D-011 | Setup | Task-only | Case-collision rule: enum values get renamed; types/functions keep C names | Active |
| D-012 | Setup | Task-only | Add synthetic C library tbfixture as primary test target (PRD §4.6) | Active |
| D-013 | Setup | Task-only | Parse CastXML with MSXML6 (late-bound COM), not a hand-written parser | Active |
| D-014 | 1.1 | Task-only | Port impexp FileSys/TextKit verbatim; run tools via WScript.Shell.Run + file redirect | Active |
| D-015 | 1.2 | Task-only | Errors raised in a tB Delegate Sub or CallByName target lose fidelity; runner uses direct dispatch | Active |
| D-016 | 2.3 | Task-only | x86 __stdcall exports are decorated (_name@N); check tB resolution in 11.0 | Active |
| D-017 | 3.1 | Task-only | Source subfolders Core/Testing/Tests/Generator; CastXML runs from generated .cmd scripts | Active |
| D-018 | 5.1 | Task-only | Unions: raw storage typed by alignment + Property Get/Let accessors per member | Active |
| D-019 | 5.2 | Task-only | Class-method errors may arrive as bare 'Automation error'; FunctionType args unnamed | Active |
| D-020 | 7.1 | Task-only | Library macros = #define names in the header files, valued from the -dM dump | Active |
| D-021 | 7.3 | Task-only | Macro scope: tB-representable constants only; enum references now resolved | Active |
| D-022 | 8.1 | Task-only | Doc comments copied verbatim as tB /* */ blocks; delegate param names from source | Active |
| D-023 | 1.0, 9.0, 10.0, 11.1 | Plan | tbBlob outputs .twin files only: report.md, Source\, Work\; import tool test-only | Active |
| D-024 | 10.4 | Task-only | First libgit2 run: callback typedef chains, MSVC suffixes, error context; speed open | Active |
| D-025 | 10a.0(new) | Plan | New task 10a: typedefs and type-alias macros become Public Alias (PRD req. 15) | Active |
| D-026 | 11.4 | Task-only | x86 stdcall export names read from the DLL (--x86-dll); harness results; enum Alias works | Active |
| D-027 | 11a.0(new) | Plan | New task 11a: generated optional DLL loader helper + "Loading the DLL" report section | Active |
| D-028 | 12.4 | Task-only | INT64_MIN emitted as &H8000000000000000^ (tB cannot parse -9223372036854775808^) | Active |
| D-029 | 12.4 | Task-only | libgit2 harness results; harness bindings synced by content, stale only when generated code changes | Active |
| D-030 | 12a.0(new) | Plan | New task 12a: macros evaluated for x86 and x64; differing constants become #If Win64 pairs | Active |
| D-031 | 12b.0(new) | Plan | New task 12b: docs on same-name opaque aliases; report header functions the DLL does not export | Active |
| D-032 | 12b (experiment) | Finding | libgit2 incl. git2/sys/*.h generates, compiles and passes layout on both architectures | Active |
| D-033 | 12c.0(new) | Plan | New task 12c: repeatable --also <header>; the libgit2 proof includes git2/sys/*.h | Active |
| D-034 | 12d.0(new) | Plan | New task 12d: a struct defined without a doc comment takes its same-name typedef's doc | Active |
| D-035 | 14.0, 15.0 (new) | Plan | Deployment: tbBlob --check, clear missing-dependency messages, bundled CastXML; package.ps1 + README/docs | Active |
| D-036 | 14.4 | Task-only | Exit 4 prints the checklist; SKIPPED vs MISSING; castxml.exe is never run unless it has an executable header | Active |
| D-037 | 16 (measurement) | Finding | libgit2+sys takes 104.5 s: 30% CastXML, 70% tbBlob; linear-scan lookups; parallel CastXML 24.6 -> 21.3 s on 2 cores | Active |
| D-038 | 16.0, 17.0 (new) | Plan | Speed: indexed lookups (16.0), then early-bound MSXML 6 + Scripting.Dictionary (17.0); no parallel CastXML | 17.0 part superseded by D-040 |
| D-039 | 16.4 | Finding | Indexes: byte-identical, no speed-up; late-bound Scripting.Dictionary calls cost ~200 us each (MSXML 2.5 us) and dominate | Active |
| D-040 | 17.0 (revised) | Plan | Maps: tB Collection with explicit KeyCompareMode wherever possible; holder class / array / early-bound Dictionary for in-place updates; measure first | Active |
| D-041 | 17.2 | Finding | tB Collection 0.2 us vs Scripting.Dictionary 100 us early-bound (cross-apartment: Dictionary is Apartment-threaded, tbBlob is MTA); MSXML early-bound 0.4 vs 1.1 us | Active |
| D-042 | 17.4 | Task-only | All maps are keyed Collections; MSXML early-bound and typed IXMLDOMElement throughout; Scripting Runtime reference removed; libgit2+sys 104.5 s -> 36.4 s, output byte-identical | Active |
| D-043 | 17 (evaluation) | Finding | CastXML snapshot 0.6.20260105 (Clang 21.1.8): byte-identical output, not faster, 16 MB larger; keep vcpkg 0.6.5 | Active |
| D-044 | SPIKE-10, 18.0, 19.0 (new) | Plan | Close coverage gaps 1 (callbacks on library threads: spike first) and 3 (caller-freed memory) | Active |
| D-045 | Spike | Finding | tB CDecl callbacks work on library-created threads; unsynchronised state races; no COM until CoInitializeEx; unhandled errors are swallowed (return 0) | Superseded by D-046 |
| D-046 | Spike | Finding | Corrects D-045: an unhandled error in a threaded callback shows a modal "Run-time error" box (caption "shutdown"); C still gets 0, Main sees nothing | Active |
| D-047 | 20.0, 21.0 (new) | Plan | LLVM licence in the package; READMEs for tests/CastXML/libgit2/spikes/tools; import tool moves to tools\impexp\ | Active |
| D-048 | 21.3a | Task-only | Delete git2.xml and reference\libgit2tB\ (superseded by the generated bindings and harness; overrides PRD req. 33's "kept as reference") | Active |
| D-049 | 22.0 (new) | Plan | Dependencies documented by purpose (run / build / test), getting vcpkg, package.ps1 names the CastXML install command; no auto-install | Active |
| D-050 | 23.0 (new) | Task-only | LibGit2Counts generates its own libgit2 XML instead of reading gitignored spike output; docs state what a first run on a clean clone reports | Active |
| D-051 | 24.0 (new) | Task-only | Fixture snapshots store {REPO}; tests resolve it to the real repo root (SelfTest.Fixture); no absolute paths in test data | Active |
| D-052 | cairo (assessment) | Finding | cairo 1.18.4: 419 of 425 exports generated; outside types dangle; one DLL per run duplicates cairo.h | Active |
| D-053 | 26.0 (new) | Plan | Bind each function to the DLL whose export table has it (DLL file or folder) | Active |
| D-054 | SPIKE-11, 27.0, 28.0 (new) | Plan | Import outside types into header-named modules; LongPtr aliases only where C/SDK make it certain; --qualify-outside, --pointer | Superseded (partial) by D-065 |
| D-055 | 29.0, 30.0 (new) | Plan | cairo becomes the second proof library: generation, compile and layout tests, then a runtime harness | Active |
| D-056 | 25.0 (new) | Task-only | Arguments ending in a backslash break the quoted CastXML command line; quote by the C runtime rules | Active |
| D-057 | 26a.0 (new) | Plan | A header CastXML cannot read is skipped (traced via tbblob_entry.h) and reported, not fatal | Active |
| D-058 | 27.0 (new) | Plan | A pointer to a COM interface (MIDL lpVtbl shape) becomes LongPtr /* IName */ | Active |
| D-059 | 29.0, 30.0 | Plan | cairo-dwrite.h: 5 hand-written declares, documented and tested; cairo run proves the header skip | Active |
| D-060 | Issue #1 | Task-only | Callback parameter names come from the compiler's preprocessed headers (castxml -E), not the raw header text | Active |
| D-061 | Issue #1 | Finding | Known issue: CastXML (C mode) cannot read the SDK's webservices.h — two empty enums | Active |
| D-062 | 26.0 | Task-only | D-053 as built: project named after the entry header for a DLL folder; multi-DLL loader raises; libgit2 loses 9 unexported declares; --keep-unexported | Active |
| D-063 | 26a.0 | Task-only | D-057 as built: any untraceable error stays fatal; clang's omitted include stacks; one failed-output file per pass | Active |
| D-064 | Spike | Finding | Module-qualified Types work everywhere; a Public Alias is project-wide and cannot be module-qualified | Active |
| D-065 | 27.0, 28.0 | Plan | Outside types revised: aliases are project-wide names; same-name Types are always qualified | Active |
| D-066 | 27.0 | Task-only | Outside types as built: one walk, alias kinds from typedefs, integration tests instead of snapshots | Superseded (partial) by D-067 |
| D-067 | 28.0 | Task-only | Union accessors copy with tB's native vbaCopyBytes, not a RtlMoveMemory Declare | Active |
| D-068 | 29.0 | Task-only | Gaps cairo showed: outside callback typedefs become delegates; anonymous struct types named after their field | Active |

---
### D-001 — tB UDT layout equals C natural alignment for all 85 libgit2 structs, both archs (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 1 / req. 19, 25, 34. One `LongPtr`-based source only works if tB lays out `Type`s like C on both architectures, including 8-byte members on win32.
- Decision: Observed: 85/85 `LenB` sizes and 433/433 field offsets equal CastXML's values on **both** win32 and win64, with zero mismatches. This includes nested Types (`git_clone_options` → `git_checkout_options` / `git_fetch_options` → `git_remote_callbacks`, 236 bytes x86 / 416 bytes x64), fixed arrays (`git_oid.id(0 To 19) As Byte`), delegate-typed fields, trailing padding, and 8-byte members on win32 (`git_diff_file.size As LongLong` at offset 24 not 20, size 40; `git_time` size 16). No `[PackingAlignment]` needed for libgit2. Field mapping used: pointer-sized → `LongPtr` (or opaque alias / delegate), unsigned → same-size signed, `LongLong` for 64-bit ints, Enum = 4 bytes; bitfield unit emitted as one storage field of the unit's type (`git_commit_create_options.bits_allow_empty_commit As Long`) — offsets matched.
- Rationale: `spikes/castxml-ffi-generator/gen_probe.py` generated all Types plus `Layout.twin`, which compares `LenB(v)` and `VarPtr(v.field) - VarPtr(v)` against per-arch CastXML values. Results: `spikes/castxml-ffi-generator/results/results-win32.txt`, `results-win64.txt` (`1.size.*`, `1.offset.*` lines).
- Verified under: twinBASIC IDE BETA 983; compiled Standard EXE (console) as win32 and win64, run from the built EXEs (`Build\probe_win32.exe`, `probe_win64.exe`), not the IDE debugger; Windows 11 Enterprise 10.0.22621; CastXML 0.6.5 / MSVC 14.44 (`--castxml-cc-msvc-c cl`, vcvars32/vcvars64); libgit2 1.9.1 headers. Layout only checked for libgit2's struct shapes — no `#pragma pack`, unions, or `__declspec(align)` were exercised.
- Alternatives considered: tB padding 8-byte members to 4 on win32 like VB6 `Currency` (ruled out for `LongLong`); per-arch generated sources (unnecessary).

---
### D-002 — CDecl delegates work as nested UDT fields and declare parameters (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 2 / req. 17. Delegates in packages have known bugs (#1890); unknown whether delegate-typed UDT fields and params work for C callbacks.
- Decision: Observed on both archs: `opts.checkout_opts.progress_cb = AddressOf OnCheckoutProgress` and `opts.fetch_opts.callbacks.transfer_progress = AddressOf OnTransferProgress` (delegate fields two and three levels deep in `git_clone_options`) were invoked by libgit2 during `git_clone` (checkout: 3 calls, total_steps=2, path "b.txt"; transfer: 5 calls, received=total=4), and the `void* payload` values (1111, 2222) arrived intact. A delegate as a declare parameter (`git_reference_foreach_name(repo, AddressOf OnRefName, 3333)`) received all 5 ref names and the payload. A callback with a `ByRef stats As git_indexer_progress` parameter read the C struct correctly. Callback procedures were `Private Sub/Function X CDecl(...)` in a standard module.
- Rationale: `handwritten/Tests.twin` `Spike_CloneGroup`; results lines `2.*`.
- Verified under: same as D-001. Bindings were **included sources in the same project** — delegates across a package boundary were not tested. Local `file://` clone only (no network transport).
- Alternatives considered: typing callback fields as `LongPtr` like WinDevLib (not needed inside one project).

---
### D-003 — Pointer mapping rule verified; vbNullPtr, CType(Of T), alias interchange work (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 3 / req. 20 — which declare shapes are correct for C pointers.
- Decision: This rule works on both archs and is the generator's rule:
  - pointer to complete struct → `ByRef x As T` (`git_clone_options_init(opts, 1)` filled `opts.version`);
  - pointer to opaque struct → `ByVal x As <alias>`; `T**` out of opaque → `ByRef x As <alias>` (`git_repository_open`, `git_clone`, `git_revparse_single`);
  - pointer to non-char scalar/enum → `ByRef x As <scalar>` (`git_libgit2_version(major, minor, rev)` → 1.9.1);
  - `T**` of non-opaque → `ByRef x As LongPtr`; `char*`, `void*`, arrays and everything else → `ByVal x As LongPtr`;
  - any returned pointer → `LongPtr` (opaque → its alias); read a returned struct with `With CType(Of T)(p)` (`git_error_last`, `git_commit_author`).
  - `ByVal vbNullPtr` passes NULL to a `ByRef As T` parameter (`git_clone(..., ByVal vbNullPtr)` → rc 0).
  - Two opaque aliases of `LongPtr` are interchangeable: a `git_object` variable passed where `git_commit` is declared compiled and worked.
- Rationale: `Tests.twin` `Spike3_Basics`, `Spike_CloneGroup`; results `3.*`.
- Verified under: same as D-001. No struct-by-value parameters exist in libgit2 (generator reports them; untested).
- Alternatives considered: all pointers as `ByVal LongPtr` (works but loses type checking and convenience); `ByRef As Byte` for `char*` (awkward for strings).

---
### D-004 — UTF-8 const char* round-trips via ByVal LongPtr, incl. non-ASCII (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 4 — strings stay `LongPtr` in raw bindings; does UTF-8 in/out work?
- Decision: Observed on both archs: a clone target path containing `é` passed as UTF-8 bytes (`VarPtr(bytes(0))`) made libgit2 create `%TEMP%\tbBlob-spike-é\clone-…` correctly on disk; `git_repository_path` returned `%TEMP%/tbBlob-spike-é/clone-…/.git/` with `é` intact; the author name `Zoë Tëster` read from `git_signature.name` matched exactly; a `const char*` callback argument decoded correctly. The probe's `4.utf8_path_roundtrip` check reported FAIL only because it compared against the 8.3 short form of `%TEMP%` (`BENCLO~1`) while libgit2 returns the long path — a test bug, not a string-marshalling fault (verified by inspecting the folder on disk and the returned string).
- Rationale: `Tests.twin` + `handwritten/Utf8.twin` (`WideCharToMultiByte`/`MultiByteToWideChar` CP_UTF8, `lstrlenA`); results `4.*`. Note: `Print #` writes the results file in ANSI (cp1252), so non-ASCII looks garbled if read as UTF-8; comparisons were done in memory.
- Verified under: same as D-001.
- Alternatives considered: tB `String`/`DeclareWide` string parameters (would pass UTF-16 — wrong for libgit2).

---
### D-005 — Scalar map holds: LongLong fields/returns, 4-byte enums, top-bit hex constants (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 5 / req. 19, 21.
- Decision: Observed on both archs: `git_signature.when.time As LongLong` = 1700000000, `.offset` = 90, `.sign As Byte` = 43 ('+'); a `LongLong` **return value** (`git_commit_time` → 1700000000, i.e. EDX:EAX on win32) is correct; `LenB` of an `Enum` variable is 4; `Const X As Long = &H80000000` = -2147483648, `&HFFFFFFFF` = -1, and an `Enum` member `= &H80000000` = -2147483648. Unsigned C fields mapped to same-size signed types laid out correctly (D-001).
- Rationale: `Tests.twin` `Spike_CloneGroup`; results `5.*`.
- Verified under: same as D-001. `float`/`double` struct fields and `_Bool` are not present in libgit2 and were not exercised at runtime (Double only via variadic, D-006).
- Alternatives considered: `Currency` for 64-bit ints (rejected — not 8-byte aligned on win32 per tB #136).

---
### D-006 — ByVal ParamArray As Any() calls C variadics correctly; plain variables go by address (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 6 / req. 22; docs conflict and #671 by-address note.
- Decision: Observed on both archs with `Public DeclareWide PtrSafe Function f CDecl Lib "…" (fixed params, ByVal ParamArray args As Any()) As Long`:
  - `git_libgit2_opts(GIT_OPT_SET_MWINDOW_SIZE, ByVal want)` then `git_libgit2_opts(GIT_OPT_GET_MWINDOW_SIZE, got)` round-tripped 12345678 (`size_t` by value, `size_t*` out via plain variable).
  - msvcrt `_snprintf` printed `CLng(-5)`, `CLngLng(1234567890123)` (`%I64d`), `CDbl(3.25)` (`%.3f`), a `char*` (`VarPtr`), `CLngPtr(987654)` (`%Iu`) correctly, singly and all in one call.
  - #671 still holds in BETA 983: a plain variable `n` in the variadic part printed `VarPtr(n)`; `ByVal n` and `(n)` printed its value 7.
- Rationale: `Tests.twin` `Spike6_Variadic`; results `6.*`.
- Verified under: same as D-001. `va_list` (`ByRef ParamArray`) not exercised (libgit2 public API has none). UDTs and `Single` in the variadic part not tested.
- Alternatives considered: skipping variadics, or fixed-arity overloads with `Alias` (unnecessary).

---
### D-007 — Keyword-named fields/params compile unescaped; case collisions need renames; declare Alias works (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 7 / req. 26.
- Decision: Observed: the full generated libgit2 API — with C names used **unescaped** as `Type` field names and parameter names, including `type`, `local`, `free`, `close`, `len`, `lock`, `name`, `to`, `version`, `option`, `object`, `when`, `out` — compiled with **no naming errors** on both archs (the only compile errors in the first build were missing opaque aliases, D-008). Case-insensitive collisions between a C function/type name and a C enum value are real and were resolved by renaming the non-enum side with a trailing `_`: 7 types (`git_error`→`git_error_`, `git_cert_x509`, `git_credential_userpass_plaintext`, `git_credential_username`, `git_credential_ssh_key`, `git_credential_ssh_interactive`, `git_credential_ssh_custom`) and 1 function. A renamed declare `git_repository_open_bare_ … Alias "git_repository_open_bare"` resolved and ran (rc 0, `is_bare`=1) while the enum value `GIT_REPOSITORY_OPEN_BARE` (=4) kept its name. Leading-underscore identifiers (`_LIBSSH2_SESSION` alias) compiled.
- Rationale: compile results reported by the user for both archs; `gen_report.md` rename list; results `7.*`. Whether a case-only duplicate is actually a compile error was not tested (the generator renamed pre-emptively).
- Verified under: same as D-001. The rename-target rule (enum value keeps its name; function/type gets `_`) is the spike's choice, not a tB requirement — final rule to be recorded during task generation.
- Alternatives considered: escaping with `[ ]` (not needed for any libgit2 name); renaming the enum value instead (would break C-doc parity for `GIT_ERROR` etc.).

---
### D-008 — Generated folder imports and compiles; opaque aliases needed per typedef name; DLL preload binds (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 8 / req. 28–30, 37.
- Decision: Observed:
  - A generated folder (`Settings` + `Sources\*.twin` + empty `Resources`, `Miscellaneous`, `ImportedTypeLibraries`, `Packages`) imported with `tBImportExport_win64.exe import … --overwrite` (exit 0) and opened/compiled in the IDE. The `Settings` used is `spikes/castxml-ffi-generator/handwritten/Settings` (VB compiler package + stdole references, console Standard EXE).
  - One module per header (65 modules, `Module git2_<header>`), `Public Alias` statements at file scope above the `Module`, and cross-module use of Types/Enums/Delegates/aliases compiled regardless of module order.
  - First build failed with 7 × TB5079 "Unrecognized datatype symbol" because opaque aliases were emitted only under the **struct** name; headers also refer to opaque structs through a **different typedef name** (`typedef struct git_iterator git_note_iterator;`, `typedef struct _LIBSSH2_SESSION LIBSSH2_SESSION;`). Emitting an alias for every typedef name of an incomplete struct fixed it.
  - `LoadLibraryExW(<SPIKE_DIR>\bin\<arch>\git2.dll, 0, LOAD_WITH_ALTERED_SEARCH_PATH)` loaded the arch-specific DLL and its dependents (pcre, zlib1) from that folder, after which every `Lib "git2.dll"` declare bound to it (`git_libgit2_init`=1), from an EXE whose own folder holds no DLLs.
- Rationale: user compile reports; `gen_probe.py`; results `8.*`.
- Verified under: same as D-001. Package (`.twinpack`) shape not tested. Settings minimality not explored further (it worked first time).
- Alternatives considered: copying DLLs next to the EXE (needs one folder per arch since both are named `git2.dll`).

---
### D-009 — tB can run castxml under vcvars via WScript.Shell.Exec and capture output/exit code (Task: Spike)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: PRD §7.5 item 9 / req. 5–8.
- Decision: Observed on both archs: `CreateObject("WScript.Shell").Exec("cmd /c ""<vcvars64.bat>"" >nul 2>nul && ""<castxml.exe>"" --version""")`, then `StdOut.ReadAll`, then polling `Status` until non-zero, returned castxml's version text and `ExitCode` 0; `cmd /c exit 3` returned `ExitCode` 3.
- Rationale: `Tests.twin` `Spike9_Process`; results `9.*`.
- Verified under: same as D-001; VS 2022 Enterprise vcvars64. Small stdout only — reading only stdout risks a deadlock if a child fills the stderr pipe; for real runs, redirect castxml output to files (`-o`, `> file 2>&1`) or read both streams.
- Alternatives considered: `CreateProcessW` with pipes (more code; not needed).

---
### D-010 — Stack: tB console EXE, built-in --self-test, exported Source/ folder is truth (Task: Setup)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: generate-tasks step 3. Brand-new tB project with no test runner; tB compiles are manual in the IDE (PRD req. 38; `tb-build` skill does not work).
- Decision (user-chosen):
  - **Language/runtime:** twinBASIC, console Standard EXE `tbBlob.twinproj` (Sub Main), built as win64 for the tool itself. Output: `Build\tbBlob_win64.exe` (Settings `project.buildPath`).
  - **Unit tests:** compiled into tbBlob as a built-in `--self-test` suite (pattern: `impexp.twinproj` `SelfTest.twin`). Integration tests that touch external tools run with `--self-test --integration`. Exit code 0 = all pass; non-zero = failures, one line per failing test on stdout.
  - **Source of truth:** plain `.twin` files under `Source\` (the existing `project.exportPath` `${SourcePath}\Source`, so IDE "Export" writes to the same folder) plus `Source\Settings`. `tbBlob.twinproj` is a build artifact recreated with `Build\tBImportExport_win64.exe import "<repo>\tbBlob.twinproj" "<repo>\Source" --overwrite` before each compile. If the user edits in the IDE, they export back to `Source\` before Claude continues.
  - **Test cycle:** Claude edits `Source\`, runs the import, asks the user to compile win64 in the IDE, then runs the tests itself and reads the output.
  - **Runtime harnesses** (generated bindings + tB test programs for `tbfixture` and libgit2) are separate tB projects compiled by the user as win32 and win64; they write `results-<arch>.txt` files that Claude reads (same pattern as the spike).
- Rationale: one compile serves the tool and its unit tests; reviewable diffs; matches the proven impexp pattern.
- Alternatives considered: separate tB test project (two projects to keep in sync and compile); committing `.twinproj` as truth (binary, unreviewable diffs).

---
### D-011 — Case-collision rule: enum values get renamed; types/functions keep C names (Task: Setup)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: PRD req. 26; D-007 (the spike kept enum values and suffixed types/functions, giving `git_error_`). tB is case-insensitive; enum members are global names.
- Decision (user-chosen): when two generated names are equal ignoring case and one of them is an **enum value**, the enum value is renamed by appending `_` (e.g. `GIT_ERROR` → `GIT_ERROR_`, `GIT_REPOSITORY_OPEN_BARE` → `GIT_REPOSITORY_OPEN_BARE_`); types, functions, delegates keep their C names. For collisions not involving an enum value, a function is renamed and keeps its export name with `Alias "c_name"`; any other kind gets `_`. Repeat `_` until unique. Every rename goes in the generation report.
- Rationale: type and function names are typed far more often than enum values; keeping them matches the C docs. Functions keep exact link names via `Alias` anyway.
- Alternatives considered: keep enum values (spike behaviour — renames the commonly used `git_error`); fixed kind priority (more rules for no extra benefit).

---
### D-012 — Add synthetic C library tbfixture as primary test target (PRD §4.6) (Task: Setup)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: D-001…D-009 showed libgit2 lacks unions, by-value structs, float/double/_Bool fields, va_list, pragma pack, align, stdcall.
- Decision: PRD §4.6 (req. 39–44) adds `tbfixture` (`tests\fixture-c\tbfixture.h/.c`, MSVC build script for x86/x64, self-checking exports, an MSVC `sizeof`/`offsetof` layout table, a C test program). It is the main TDD target for generator features; libgit2 is the final acceptance test.
- Rationale: failures point at one construct; second source of layout truth; fast to rebuild; gives the generator a small stable XML for snapshot tests.
- Alternatives considered: libgit2 only (cannot prove the missing constructs).

---
### D-013 — Parse CastXML with MSXML6 (late-bound COM), not a hand-written parser (Task: Setup)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: PRD §7.7 left the XML parser open. Each CastXML file is ~1 MB with ~3,000 elements, all referenced by `id`.
- Decision: load with `CreateObject("MSXML2.DOMDocument.6.0")` (`async = False`, `validateOnParse = False`, `resolveExternals = False`), walk the root's children once and index them by `id` into tB collections/dictionaries. Late binding avoids a typelib reference in Settings. MSXML6 ships with Windows.
- Rationale: robust, already on every supported machine, avoids writing and testing an XML parser.
- Alternatives considered: hand-written streaming parser (more code and tests; only worth it if MSXML6 proves too slow — to be measured in the loader task's integration test).

---
### D-014 — Port impexp FileSys/TextKit verbatim; run tools via WScript.Shell.Run + file redirect (Task 1.1)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: 1.1 asked for the surface with "no logic yet", but FileSys/TextKit already exist, tested, in impexp.twinproj.
- Decision: copy `FileSys.twin` and `TextKit.twin` verbatim (proven code, not re-derived); only new tbBlob functions (`WriteTextUtf8`, `ReadTextUtf8`, `SplitCommandLine`, `CliOptions.Parse`, `Tools.*`, `SelfTest.*`) start as stubs and go red in 1.2. `Tools.RunCommand` uses `WScript.Shell.Run("cmd /c ""… > log 2>&1""", 0, True)` (waits, returns the exit code, hidden window) rather than `.Exec` — same object as D-009, but no pipe, so no stderr deadlock; 1.3's integration test confirms it.
- Rationale: avoids rewriting tested code; Run+redirect is simpler and safer than Exec+pipes.
- Alternatives considered: `.Exec` with `StdOut.ReadAll` (D-009; deadlock risk with large stderr).
---
### D-015 — Errors raised in a tB Delegate Sub or CallByName target lose fidelity; runner uses direct dispatch (Task 1.2)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: the self-test runner first called tests through `Public Delegate Sub TestProc()` (D-002 had shown delegates work when **C** calls them). Every test reported PASS against stubs that should fail.
- Decision (observed, twinBASIC BETA 983, win64 EXE):
  - Calling a tB procedure **from tB code** through a `Delegate Sub` with `p()`, `Call p()`, or via a `Delegate Function` assigned from the `LongPtr` — all three **do** call the procedure (canary counted 1 hit each).
  - But an error raised inside that procedure (`Err.Raise vbObjectError + &H1200, , "…"`) **never reached the caller's `On Error` handler**: the call returned normally and the failure was silently lost.
  - `CallByName obj, "Method", VbMethod` on a tB class does propagate the error, but as `-2147352567` (`DISP_E_EXCEPTION`) "Exception occurred." — the original number and message are lost.
  - A direct call (`Select Case index: Case 1: Tests_Cli.SomeTest`) propagates number and message intact (impexp's pattern).
  - So the runner now uses direct dispatch: each `Tests_*` module has `MODULE_ID`, numbers its tests in `Register`, runs one in `RunTest(index)`; `SelfTest.Dispatch` has one `Case` per module. A runner self-check (`SelfTestCanary`) runs before every run and refuses to report if a test doesn't run or its error doesn't arrive as exactly `CHECK_FAILED` + "canary".
- Rationale: a test runner that cannot see failures is worse than none; the self-check makes a silently green runner impossible.
- Alternatives considered: assertion flag in module state plus delegate calls (would still lose unexpected runtime errors from test bodies); CallByName (loses messages).
- Note for later tasks: generated bindings are unaffected (C calls the delegates — D-002), but harness code should not rely on errors propagating out of procedures invoked through a delegate from tB.
---
### D-016 — x86 __stdcall exports are decorated (_name@N); check tB resolution in 11.0 (Task 2.3)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: `tests\fixture-c\build.ps1` lists each tbfixture DLL's exports with `dumpbin /exports`.
- Decision (observed, MSVC 14.44, `__declspec(dllexport)`, no `.def` file): on **x86** the `__stdcall` export `tbf_std_add` is named `_tbf_std_add@8`; cdecl exports are undecorated on both architectures, and on x64 everything is undecorated. CastXML cannot see this (it is a property of how the DLL was linked, not of the header). Real libraries usually undecorate stdcall exports with a `.def` file (as the Windows API does), but not all do.
- Consequence for later tasks: in **11.0** check whether a tB `Declare … tbf_std_add Lib "tbfixture.dll"` resolves on win32 (VB6 did not try decorated names). If it does not, the generator needs an option: emit `#If Win64 Then … #Else … Alias "_name@N" … #End If` for stdcall functions, with N = the argument bytes from the x86 XML (each argument rounded up to 4) — and only when the DLL actually exports the decorated name (read its export table, or a `--stdcall-decorated` switch). Record the outcome as a new decision then.
- Rationale: surfaced by the fixture before it can surprise the harness.
- Alternatives considered: give tbfixture a `.def` file (would hide the case real libraries can present).
---
### D-017 — Source subfolders Core/Testing/Tests/Generator; CastXML runs from generated .cmd scripts (Task 3.1)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: user asked for subfolders as the module count grows; 3.0 needs to run CastXML three times under vcvars with paths that contain spaces and parentheses.
- Decision:
  - `Source\Sources\` is split into `Core\` (MainModule, CliOptions, Console, FileSys, TextKit, Tools), `Testing\` (SelfTest, SelfTestCanary), `Tests\` (Tests_*), `Generator\` (pipeline modules from 3.0 on). Verified: `tBImportExport_win64.exe` packs the subfolders and exports them back unchanged; module names are unaffected by folders.
  - tbBlob writes each CastXML invocation as a `.cmd` script in the work folder (`castxml_x86.cmd`, `castxml_x64.cmd`, `castxml_macros.cmd`: `@call "<vcvars>" >nul 2>nul` then the castxml line) and runs it with `Tools.RunCommand`. The macro dump uses castxml's own `-o` with `-E -dM` (verified: writes 2,174 macros for tbfixture.h), so no nested redirection is needed.
- Rationale: one level of quoting instead of three; the scripts stay in the work folder as an exact, re-runnable record of how the XML was made (the user lost the command behind the original git2.xml).
- Alternatives considered: one long `cmd /S /C` line per pass (fragile nested quoting — PowerShell probe already mangled it once).
---
### D-018 — Unions: raw storage typed by alignment + Property Get/Let accessors per member (Task 5.1)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: PRD req. 24 (union → byte array "with alignment preserved"). User (2026-10-16): represent unions as a byte array, and consider a UDT whose members are methods reading at the offset, like the `UTF8` UDT in libgit2tB (tB Types may contain `Property Get/Let`, private `Declare`s and `Me`, without adding storage).
- Decision:
  - A union becomes a `Type` with one storage field `union_data(0 To n-1) As <unit>` plus, for each C member, `Property Get`/`Let` that copy at the member's offset (0 for union members) with a `Private Declare … RtlMoveMemory` inside the Type. Array members get an index parameter; struct members are copied whole.
  - **The storage unit is chosen by the union's alignment, not always `Byte`**: a `Byte` array has alignment 1, so the union would sit at the wrong offset inside a containing struct (fixture: `TBF_TAGGED.value` is at offset 8 in C because the union holds a `double`; Byte storage would put it at 4). Unit = `LongLong` (align 8), `Long` (4), `Integer` (2), `Byte` (1), or `LongPtr` when the alignment is the pointer size on both architectures (4 on x86, 8 on x64) and n is the same in both. If no unit fits both architectures, the union is reported as unsupported.
  - An **anonymous** union inside a struct (fixture `TBF_ANON`) becomes a storage field of the struct (`union_N(0 To n-1) As <unit>`, N = 1, 2, … in member order) and its members become `Property Get`/`Let` on the struct, so tB code reads `x.as_int` as C does.
- Rationale: keeps the byte-buffer representation's intent (opaque storage, explicit access) while keeping C layout; accessors give C-like member names.
- Alternatives considered: plain `Byte` storage (wrong offsets inside structs and arrays of unions); explicit padding fields (arch-dependent; would need `#If Win64` in Types).
- To verify: 11.0 harness — layout check of `TBF_TAGGED`/`TBF_ANON`, and `tbf_check_tagged`/`tbf_check_anon` with values set through the accessors, on win32 and win64.
---
### D-019 — Class-method errors may arrive as bare 'Automation error'; FunctionType args unnamed (Task 5.2)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: two observations while building 5.0.
- Decision:
  - **Errors from class methods.** In the 5.2 build (BETA 983), `Err.Raise vbObjectError + &H1300, , "<message>"` inside `CxModel.Load` reached the caller as Description "Automation error" — the message was lost. The same code and tests passed in the 4.0 build; the only change in `CxModel` was `Public Const LOAD_FAILED` → `Private Const` (the compiler started rejecting the Public constant, TB5250). Cause not established. Consistent with D-015 (errors crossing COM-style boundaries lose fidelity). Rule from now on: **classes report failures through a property (`LoadError`, `ErrorText`, …) set before raising; callers and tests read the property, never `Err.Description` from a class call.** Modules may keep raising (direct calls keep the message — D-015).
  - **FunctionType arguments have no names in CastXML** (schema-confirmed and seen in the snapshot: `<Argument type="_251"/>`). Delegate parameters are therefore `arg1`, `arg2`, … Recovering the C names from the header text (the typedef's source range) is possible later if wanted; cosmetic only.
- Rationale: don't build on behaviour that changed between two builds; names don't affect the binary interface.
- Alternatives considered: investigating the class-error behaviour now (not needed for the proof; can be a later spike if it matters for generated code).
---
### D-020 — Library macros = #define names in the header files, valued from the -dM dump (Task 7.1)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: 7.1 had to decide how to tell the library's macros from compiler/CRT ones; the `-E -dM` dump (D-017) has no source locations.
- Decision:
  - Tried `castxml --castxml-cc-msvc-c cl -E -dD` (keeps `#define` lines in the preprocessed output with `# line "file"` markers): **fails** on MSVC's `sal.h` — 11 × "invalid token at start of a preprocessor expression" at `#if … // [` lines (as if `//` comments were not recognised in that mode). `-dM` works (D-017). Not pursued further.
  - Instead: the library's macros are the `#define` names found by scanning every `.h` file under the header folder (recording file and line, for module placement and order), **intersected** with the names in the `-dM` dump. Each macro's body comes from the dump (its final, active definition), so macros in inactive `#if` branches or in headers the entry header never includes drop out; compiler/CRT macros in the dump are still available for resolving references (e.g. `_MSC_VER`).
  - Evaluation (PRD req. 18, 21, D-005): integers (decimal/hex/octal, u/l/ll suffixes, C typing rules for width and signedness), char and string literals, doubles, references, and expressions with `+ - * / % << >> & | ^ ~ !`, parentheses and simple casts. 32-bit values outside the signed range are written as their bit pattern in hex (`&H80000000`); 64-bit values use the `^` suffix. Skipped with a reason: empty (flag/include-guard) macros, initializers `{…}`, function-like macros, cyclic or unknown references, unrepresentable string escapes.
- Rationale: uses only passes already proven; gives each constant a header (module) and a stable order.
- Alternatives considered: `-dD` (fails, above); diffing against a dump of an empty file (does not exclude CRT macros the library header includes).
---
### D-021 — Macro scope: tB-representable constants only; enum references now resolved (Task 7.3)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: user asked whether macros get full fidelity or a subset (2026-10-16). libgit2 has 378 library macros: 235 constants (230 numeric expressions, 4 strings, 1 char), 71 empty (include guards/flags), 41 initializers `{…}`, 31 function-like.
- Decision:
  - Scope is a **defined subset** (PRD req. 18): every macro that can be a tB `Const` becomes one with the exact C value; everything else is skipped and listed in the generation report with its reason — nothing is dropped silently. Function-like macros are code (and wrappers are a PRD non-goal); libgit2's initializer macros all have `*_init` functions that the bindings already declare; empty macros carry no value.
  - Gap closed at the user's request: macro expressions may reference **enum values**. `MacroTable.AddEnumValues(model)` feeds the library's enum values (C `int`, signed 32-bit; CastXML gives e.g. `init="-2147483648"`) to the evaluator and clears its cache. Fixture: `TBF_COLOR_BLUE_NEXT (TBF_BLUE + 1)` = 6, `TBF_COLOR_RED_ALIAS TBF_RED` = -1, `TBF_FLAGS_ALL (TBF_FLAG_LOW | TBF_FLAG_HIGH)` = -2147483647 (bit pattern 0x80000001; decimal because it is inside the signed range); without the model they remain "unknown identifier".
  - Still out of scope (reported): `sizeof`/`offsetof`, `?:`, `L"…"`/`u8"…"` strings, string escapes other than `\"` and `\\`.
- Rationale: matches the PRD and the user's "no information silently lost" rule.
- Alternatives considered: translating function-like macros to tB functions (PRD non-goal: no helpers).
---
### D-022 — Doc comments copied verbatim as tB /* */ blocks; delegate param names from source (Task 8.1)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: PRD req. 27 (doc comments); D-019 (CastXML drops function-type parameter names); user (2026-10-16): no information may be lost, and "tB supports /* ... */ comments ... no need to convert to ' style".
- Decision:
  - The emitter writes each doc comment **verbatim** from the header (`DocComments.DocRaw`: the bytes at CastXML's `begin_offset`..`end_offset`, UTF-8, CRLF) as a tB block comment. Only CastXML-attached comments exist: `/** … */` blocks and trailing `/**< … */` member comments; plain `/* … */` comments are not attached by CastXML. `DocFor` (marker-stripped lines) serves the report; `SafeCommentLine` guards tbBlob's own one-line `'` comments against a trailing `_`.
  - Enum values (no CastXML comments) get the trailing comment from their source line (`EnumValueComment`).
  - Function-type parameter names come from the declaration's source text (`ParamNamesFor`: from the typedef/field line to the `;`, last top-level parameter list). A parameter the header leaves unnamed becomes `argN` and is **not** reported (nothing lost); only a declaration tbBlob cannot parse (e.g. parameters built by a macro) falls back to `argN` **and** is reported as a loss.
  - The snapshots' byte offsets require `tests\fixture-c\tbfixture.h` to stay byte-exact: `.gitattributes` (`-text`).
- Rationale: verbatim copying is simpler and loses nothing; reporting only real losses keeps the report meaningful.
- Alternatives considered: converting to `'` comments (reformatting, `_` hazard, more code).
---
### D-023 — tbBlob outputs .twin files only: report.md, Source\, Work\; import tool test-only (Task 1.0, 9.0, 10.0, 11.1)
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: the PRD (req. 2, 28–30) and task list had tbBlob write a project folder (Settings + Sources) and call tBImportExport to produce a `.twinproj`. The user (2026-10-16): tbBlob should generate only `.twin` files and not depend on tBImportExport — how they are incorporated is not tbBlob's concern; the tool is for testing the generated `.twin`.
- Decision:
  - The 4th argument is an **output folder** laid out to document itself: `<output>\report.md` (the generation report — read first; early iterations are about reviewing what could not be extracted from the headers and the resulting gaps), `<output>\Source\*.twin` (one module per header + `<Project>_LayoutCheck.twin`), `<output>\Work\` (CastXML x86/x64 XML, macro dump, and the `.cmd` scripts that produced them). `--work` is dropped. `Source\` is emptied before writing.
  - tbBlob writes no `Settings`, no `.twinproj`, and never runs the import tool. tBImportExport is a **test-only** dependency: tbBlob's integration tests and the harness `build-project.ps1` scripts package the `.twin` files into projects (with a checked-in `Settings` template).
  - Affected branches: **1.0** and **9.0** are completed and committed — annotated in the task list, not rewritten; their code changes (`CliOptions` output argument, `ProjectWriter.WriteProject` → `WriteOutput`, moving `SettingsText`/`DeterministicGuid`/`ImportProject` into a test helper `Tests\TestProjects.twin`, updating the tests that used them) happen inside **10.0**. **10.0** (10.1, 10.3) and **11.1** (and 12.1, which follows 11.1) are rewritten — not started yet. PRD §1, §2, §3, req. 2, 9, 28–31, §7.7 and §10 updated.
- Rationale: a generator's job is the source; packaging choices (project vs package, Settings) belong to the consumer. A self-documenting output folder puts the report — the list of gaps — in front of the reviewer.
- Alternatives considered: report in the work folder (less visible); keeping the `.twinproj` output (couples tbBlob to the import tool).
---
### D-024 — First libgit2 run: callback typedef chains, MSVC suffixes, error context; speed open (Task 10.4)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: 10.3's integration test ran the real CLI on libgit2 for the first time; the user asked that errors reach the top with full context, and that the report be reviewed early for extraction gaps.
- Decision / observed:
  - **Crash fixed:** libgit2's `deprecated.h` has typedefs of callback typedefs (`typedef git_credential_acquire_cb git_cred_acquire_cb;`). The emitter looked for the function type behind exactly one typedef and dereferenced Nothing. `PointeeFn` now follows typedef chains; parameter names come from the typedef that declares the parameter list (`DeclaringTypedef`). Fixture: `typedef tbf_visit_cb tbf_visit_alias_cb;`.
  - **Errors carry context:** the emitter keeps a `CurrentItem` breadcrumb (kind, name, header:line), captures the error text inside the class (D-019) and re-raises; `TypeMapper.Disagreements` does the same; the pipeline's top-level error is `<stage> failed: <original message> (while emitting <item>)`. Test hook `Pipeline.TestFailOn` proves it. Pipeline integration tests print tbBlob's own output on failure.
  - **Gap found by the report and fixed:** 49 integer constants in libgit2's own `stdint.h` use MSVC sized suffixes (`9223372036854775807i64`, `0xffffffffui32`, `127i8`); the evaluator now types them as MSVC does. libgit2 constants 179 → 228.
  - **Clearer report:** macros whose body names a type (`#define git_otype git_object_t`, 5 in libgit2) are reported as type aliases, not unknown identifiers. Emitting them as `Alias` is task 10a (D-025).
  - libgit2 result: 67 modules, 848 functions, 85 types, 84 enums, 75 delegates (19 synthesized, no parameter names lost), 228 constants; skipped macros: 71 empty, 41 initializers, 31 function-like, 5 type aliases, 2 pointer expressions; no x86/x64 disagreements; 10 renames.
  - **Open (not blocking the proof):** a libgit2 run takes ~82 s (CastXML 25 s, x86/x64 check 13 s, naming 10 s, generating 29 s). Name lookups scan the XML linearly; indexing them (tB's `Collection` with `Exists`, per the user — mind key case-sensitivity) is the obvious optimization.
- Verified under: twinBASIC BETA 983, win64 build of tbBlob, CastXML 0.6.5, MSVC 14.44, libgit2 1.9.1 headers (vcpkg x64-windows).
---
### D-025 — New task 10a: typedefs and type-alias macros become Public Alias (PRD req. 15) (Task 10a.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: the libgit2 report (D-024) lists 5 macros that name types (`#define git_otype git_object_t`); the user asked whether these are candidates for `Alias`. PRD req. 15 (typedefs of scalar types → `Public Alias`, so signatures keep C type names) was never given a task: the type mapper resolves every typedef to its underlying tB type.
- Decision: add parent task **10a.0** between 10.0 (done) and 11.0 (not started): library typedefs of scalars, records and enums under a new name, and type-alias macros, become file-scope `Public Alias` statements; signatures use the alias names. Unchanged: `typedef struct X X`, opaque aliases (D-008), callback typedefs and their typedef chains (delegates, D-024), pointer-sized CRT typedefs. Whether tB accepts an `Alias` of an enum is undocumented (the docs list intrinsic types, UDTs, Interfaces and Aliases) — proven or disproven by the 11.0 harness compile. No completed branch changes; 11.0+ unaffected except that the harness will compile the aliases.
- Rationale: matches PRD req. 15 and the user's review of the report; keeps C type names in signatures (readability, no information lost).
- Alternatives considered: folding it into 11.0 (mixes a generator feature into a harness task); reopening 10.0 (already committed).

---
### D-026 — x86 stdcall export names read from the DLL (--x86-dll); first harness results (Task 11.4)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: D-016 asked 11.0 to check whether tB binds a plain `Declare … tbf_std_add` to the x86 export `_tbf_std_add@8`. First harness run (BETA 983): win64 145/145 PASS; win32 144/145 — `tbf_std_add(2, 3)` raised &HEAEAEA06 with an empty description: **tB does not try decorated names.** The user pointed out that the fixture only had the decorated form, while Win32-style DLLs undecorate stdcall exports with a `.def` file — so one library can have both, and a global "decorated" switch (first attempt, dropped before it compiled) would mis-bind the undecorated ones.
- Decision:
  - Fixture: new `tbf_std_sub` (`TBF_DEF_API`, no `__declspec(dllexport)`), exported through `tests\fixture-c\tbfixture.def` → undecorated on x86. `build.ps1` links with `/DEF` and checks: x86 exports `_tbf_std_add@8` and `tbf_std_sub` (not `_tbf_std_sub@8`); x64 `tbf_std_add`, `tbf_std_sub`.
  - tbBlob: `--x86-dll <path>` reads the x86 DLL's PE export table (`PeExports`, case-sensitive). Per `__stdcall` function: plain name exported → one plain declare; only `_name@N` exported (N = x86 argument bytes, each rounded up to 4) → `#If Win64 Then` plain `#Else` `Alias "_name@N"` `#End If`; neither → plain declare, reported. Without `--x86-dll` → plain declare, and the report says to pass it. cdecl functions never change.
- Rationale: CastXML cannot know how the DLL was linked; the export table is the truth and is cheap to read. Per-function decisions handle mixed libraries.
- Also observed in the first harness run (both architectures unless noted), all PASS: generated layout = MSVC `tbf_layout_table()` for every row (via generated `TbLayout`); structs of 4/8/16/24 bytes passed **and returned** by value; `ByVal CLngPtr(0)` passes NULL to a generated `ByRef` struct parameter; `va_list` as `ByRef ParamArray`; variable of an enum `Alias` type passed where the enum is expected (D-025 open question: **works**); union accessors on nested and anonymous unions (D-018); `[PackingAlignment(1/2)]`; cdecl and stdcall callbacks incl. a synthesized delegate in a struct.
- Verified under: tB BETA 983, MSVC 14.44, tbfixture DLLs built by `build.ps1`, harness compiled win32 and win64 in the IDE.
- Alternatives considered: global `--stdcall-decorated` switch (wrong for mixed DLLs); always emitting the decorated alias on x86 (wrong for `.def`-built DLLs such as the Windows API).

---
### D-027 — New task 11a: generated optional DLL loader helper + "Loading the DLL" report section (Task 11a.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: after 11.0 the user asked how the DLL gets loaded. Generated code only has `Declare … Lib "<dll>"`, bound by name on first call via the Windows search order (process EXE folder, system folders, current folder, `PATH`; subfolders never searched; for a tB DLL/add-in the EXE folder is the host's). The harness preloads with its own `LoadLibraryExW` by full path (D-008) because both architectures' DLLs share a name in one tree. The user (2026-10-16): providing a load helper makes sense, as its own task.
- Decision: add parent task **11a.0** between 11.0 (done) and 12.0 (not started): tbBlob also writes `Source\<Project>_Loader.twin` with `Load(folder)` (prefers `<folder>\win32|win64\<dll>`, else `<folder>\<dll>`), `LoadFile(path)` and `IsLoaded()`, all with `LOAD_WITH_ALTERED_SEARCH_PATH`, errors naming every path tried; and `report.md` explains loading. Using it is optional — the caller decides. The tbfixture harness switches to it (proving it on both architectures); 12.0's libgit2 harness uses it too. No completed branch changes.
- Rationale: keeps the bindings raw (no load happens unless called) while giving every consumer the right-architecture preload the spike and harness needed.
- Alternatives considered: absolute paths in `Lib` (breaks on deployment); `SetDllDirectoryW` (process-wide side effect); documentation only (every consumer would rewrite the same preload).

---
### D-028 — INT64_MIN emitted as &H8000000000000000^ (Task 12.4)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: first compile of the libgit2 harness (tB BETA 983): 6 × TB5174 "Invalid number" in `git2_stdint.twin`, all `Public Const … As LongLong = -9223372036854775808^` (INT64_MIN and macros defined from it). tB parses the literal as unary minus applied to 9223372036854775808^, which overflows LongLong — the same reason D-005 writes 32-bit top-bit values as hex.
- Decision: `MacroTable.TbConstTail` writes the 64-bit minimum as `&H8000000000000000^`; every other 64-bit value stays decimal with `^`. Unit test: `LIB_I64_MIN (-9223372036854775807i64 - 1)` in `tests\testdata\macros`.
- Also found (not fixed here; user chose a separate task 12a, see D-029 when logged): tbBlob evaluates only the x64 macro dump, so constants whose value depends on the architecture (libgit2: INTPTR_MIN/MAX, UINTPTR_MAX, SIZE_MAX, and PTRDIFF_* through them) carry x64 values on win32.
- Rationale: smallest literal form tB accepts for that value.
- Alternatives considered: `-9223372036854775807^ - 1` (an expression; works but reads oddly in a Const and hides the C value).

---
### D-029 — libgit2 harness results; harness bindings synced by content (Task 12.4)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: task 12 harness (`tests\harness-libgit2\`) on the bindings tbBlob generates from libgit2 1.9.1 (`--x86-dll`: no stdcall functions). Contracts checked against https://libgit2.org/docs/reference/main/ (user-supplied) and the 1.9.1 headers; notably the 1.9.1 header does not promise `git_error_last` is non-NULL (newer docs do), so the harness handles NULL; `git_commit_create` (parents array) is used instead of the variadic `git_commit_create_v`, which the reference calls unsafe for other languages.
- Decision / observed (tB BETA 983, win32 and win64, 93/93 each after the D-028 fix): generated `git2_Loader.LoadFile` loads the vcpkg `git2.dll` and its `zlib1.dll` from the same folder; layout check clean for every generated Type; `CType(Of git_error)`; variadic `git_libgit2_opts`; init → two commits (signature passed `ByVal ptr` to a `ByRef git_signature` parameter, parents as `git_commit` array / `ByVal vbNullPtr`) → revwalk (`GIT_ITEROVER`) → branch (`GIT_EEXISTS` on duplicate) → tree diff (`CType(Of git_diff_delta)`, also with `ByVal vbNullPtr` options) in a non-ASCII temp path (long-name compare, D-004); fixture repo made by git.exe read back (UTF-8 author, +0130 offset, tag list + `git_strarray_dispose`, foreach callback + payload + non-zero stop); `file://` clone with checkout and transfer progress callbacks; `git_libgit2_shutdown` balanced. The generated bindings replace libgit2tB (exported to `reference\libgit2tB\`, PRD req. 33).
- Test infrastructure: `build-project.ps1` now generates into `bindings.new\` and copies over only changed files (`tests\harness-sync.ps1`), records the tbBlob build's SHA-256 in `bindings\tbblob.sha256`, and re-imports the harness project only when something changed. `run-all.ps1` regenerates bindings made by another tbBlob build itself; a harness EXE is stale only if generated code (or the harness's own sources) changed. Replaces the earlier "bindings older than tbBlob" timestamp rule, which forced a harness recompile after every tbBlob rebuild.
- Rationale: fewer manual IDE compiles without weakening the staleness guarantee.
- Alternatives considered: timestamps only (needless recompiles); skipping regeneration (would miss generator changes).

---
### D-030 — New task 12a: macros evaluated for x86 and x64; differing constants become #If Win64 pairs (Task 12a.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: found while fixing D-028: tbBlob runs only an x64 macro dump (`castxml_macros.cmd` uses vcvars64), so constants whose value depends on the architecture carry x64 values on win32. libgit2 1.9.1: `INTPTR_MIN`, `INTPTR_MAX`, `UINTPTR_MAX`, `SIZE_MAX` have different bodies in an x86 dump; `PTRDIFF_MIN`/`MAX` differ only through references, so comparing bodies is not enough — values must be evaluated per architecture. The user chose (2026-10-16) a separate task after 12.0 rather than folding it into 12.0 or only reporting it.
- Decision: add parent task **12a.0** between 12.0 (done) and 13.0: dump and evaluate macros for both architectures; equal results → one `Public Const`; different → `#If Win64` pair; one-architecture-only or differing type aliases → skipped and reported; report section "Architecture-dependent constants"; fixture and harness checks on both architectures; `tests\harness-libgit2\COVERAGE.md` gains the row afterwards (user: keep it out of the 12.0 document). No completed branch changes.
- Rationale: one tB source must be right on both architectures (PRD goal); x86/x64 struct differences already abort generation (§7.8) — constants can be expressed with `#If`, so they need not abort.
- Alternatives considered: report only (leaves wrong values on win32); abort on any difference (libgit2 would not generate).

---
### D-031 — New task 12b: docs on same-name opaque aliases; report header functions the DLL does not export (Task 12b.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: measuring PRD §8 metrics 5 and 6 for the verdict (task 13) on the libgit2 1.9.1 output:
  - Metric 6 (doc comments): 803/803 functions, 82/82 enums, every struct with a body and every tbfixture item carry their header doc; **52 opaque aliases do not** — `typedef struct git_index git_index;` makes the alias from the struct's forward declaration (no comment) and skips the commented typedef as a duplicate name (D-008 ordering). (47 commented anonymous structs are emitted through their typedef with the doc — not a gap.)
  - Metric 5 (coverage): `git2.dll` (x64) exports 953 names; 848 are generated; of the 107 not generated, 105 are declared only in `git2/sys/*.h` (not included by `git2.h`) and 2 in no public header (`git_config_unlock`, `git_odb__backend_loose`). **2 header functions are not exported by the DLL** (`git_blame_file_from_buffer`, `git_diff_patchid_init_options`): their declares compile but a call fails with "entry point not found", and tbBlob does not say so.
  - The user chose (2026-10-16) to fix both before the verdict, as one task.
- Decision: add parent task **12b.0** between 12a.0 (done) and 13.0: (a) same-name opaque aliases take the typedef's doc; (b) with `--x86-dll`, declares the x86 DLL does not export get a NOTE line and a report section "Declared but not exported". Fixture gains a same-name opaque typedef with a handle-returning function and a declared-but-undefined function. No completed branch changes.
- Rationale: both are fidelity bugs the reader cannot see; both are cheap with data tbBlob already has.
- Alternatives considered: record as verdict limits (metric 6 would fail on a technicality); check exports of the x64 DLL too (not needed: same names, D-026 discussion).

---
### D-032 — libgit2 including git2/sys/*.h generates, compiles and passes layout on both architectures (Task: 12b experiment)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: metric 5 analysis (D-031) found 105 of the 107 exported-but-not-generated functions are declared only in `git2/sys/*.h`, which `git2.h` does not include. The user asked whether those are consumer API; the headers say most are for extending libgit2 (custom ODB/refdb/config backends, transports, filters, merge drivers, allocators), but some are ordinary consumer API (`git_error_clear`, `git_error_set_str` for callbacks, `git_index_reuc_*`, `git_commit_create_from_ids`, `git_repository_new`). The user chose a quick experiment before deciding whether tbBlob needs a way to name extra headers.
- Decision (observed): an umbrella header outside the header folder (`#include <git2.h>` + every `git2/sys/*.h`, passed as `git2_all.h`; not in the repo) — tbBlob 12b build, `--x86-dll`:
  - `git2/sys/stream.h` does not compile on MSVC as shipped (`ssize_t` undefined; libgit2 defines it only in its own build) — a Windows consumer must define it; the umbrella does `typedef intptr_t ssize_t;` under `_MSC_VER`.
  - Generation: 89 modules, 960 functions, 108 types, 91 enums, 164 delegates (75 without sys), 248 constants; no x86/x64 disagreements, no parameter names lost; one more bitfield (`git_stream`); `GIT_REBASE_NO_OPERATION` is architecture-dependent (D-030 handles it).
  - Coverage: 951 of the DLL's 953 exports generated; the 2 left are in no public header (`git_config_unlock`, `git_odb__backend_loose`). 9 declared functions are not exported by this vcpkg build (the 2 known plus 7 sys ones for features/platforms it leaves out) — the D-031 report section lists them.
  - Compile (tB BETA 983, IDE) win32 and win64: 0 errors. Layout check of every generated Type: OK on both.
- Verified under: tB BETA 983, MSVC 14.44, libgit2 1.9.1 (vcpkg x64/x86), compile + layout only (no runtime calls into sys APIs).
- Consequence: excluding sys was an input-scope choice, not a limit of the approach. Whether tbBlob should accept extra headers (instead of an umbrella header) is for the user to decide before the verdict.

---
### D-033 — New task 12c: repeatable --also <header>; the libgit2 proof includes git2/sys/*.h (Task 12c.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: D-032 showed libgit2 with `git2/sys/*.h` generates, compiles and passes layout on both architectures, but only through a hand-written umbrella header. The user chose (2026-10-16) to add a tbBlob option and include sys in the proof, over documenting the umbrella approach or keeping sys out of scope.
- Decision: add parent task **12c.0** between 12b.0 (done) and 13.0: `--also <header>` (repeatable, relative to the header folder); with it, tbBlob writes `Work\tbblob_entry.h` including the entry header and each extra header and runs CastXML on that; without it, behaviour is unchanged. The MSVC `ssize_t` gap in `git2/sys/stream.h` is handled with the existing `-D` (`-D ssize_t=intptr_t`) — no new prelude option. The fixture gains `tbfixture_sys.h` (outside `tbfixture.h`), the libgit2 harness generates git2.h + every sys header and calls a few sys functions. No completed branch changes.
- Rationale: the umbrella header is mechanical; tbBlob can write it, keeping the CastXML scripts in `Work\` self-explaining (D-017).
- Alternatives considered: multiple positional entry headers (breaks the 4-argument CLI, D-023); a `--prelude <file>` for typedefs (unnecessary given `-D`).

---
### D-034 — New task 12d: a struct defined without a doc comment takes its same-name typedef's doc (Task 12d.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: the first real run of `tests\verdict.ps1` (task 13.3) measured metric 6 at 1362 of 1363 commented libgit2 items (with git2/sys, D-033). The miss: `typedef struct git_transport git_transport;` is documented in `git2/types.h`, while its body `struct git_transport { … }` in `git2/sys/transport.h` has no comment, and `EmitType` takes the doc from the struct element only. D-031 added the same-name typedef fallback for opaque aliases but not for structs with a body; without sys, `git_transport` was opaque, so the gap was invisible. (The same verdict run also exposed and fixed two bugs in `verdict.ps1` itself, within 13.3: a metric measuring nothing must not PASS; PowerShell's `$el.Name` on an XmlElement returns the `name` attribute.) The user chose (2026-10-16) to fix it before the verdict.
- Decision: add parent task **12d.0** between 12c.0 (done) and 13.0 (in progress, its work uncommitted and staged separately): records fall back to the same-name typedef's doc; fixture `tbf_late` reproduces the pattern. No completed branch changes.
- Rationale: same bug class as D-031 (a); fixing it makes metric 6 complete rather than listing a technicality.
- Alternatives considered: record as a verdict limit.

---
### D-035 — Deployment: tbBlob --check, clear missing-dependency messages, bundled CastXML; package.ps1 + README/docs (Tasks 14.0, 15.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active
- Context: after the verdict (13.0) the user asked for documentation of the command line with examples, of how tbBlob and CastXML are packaged and deployed, and of setting up a different machine that may lack dependencies — with missing dependencies clearly reported. Inventory (2026-10-16): `tbBlob_win64.exe` imports only Windows system DLLs (twinBASIC runtime built in) and uses MSXML 6 and Scripting.Dictionary (in Windows). vcpkg's `castxml.exe` (0.6.5, one 99 MB file) imports the MSVC runtime (`MSVCP140`, `VCRUNTIME140`, `VCRUNTIME140_1`) and needs its clang resource headers at `..\share\castxml\clang\include` (235 files, 12.7 MB). Generation needs Visual Studio or Build Tools with the C++ tools (found with vswhere `-requires …VC.Tools.x86.x64`; on this machine vswhere also lists SQL Server Management Studio 21, which has none) and the Windows SDK. Today a missing CastXML or MSVC is reported clearly (exit 4), but a missing MSVC runtime shows as "castxml failed (exit -1073741515)", missing resource headers or SDK only as CastXML's own error text, and a missing vswhere as vcvars under an empty folder.
- Decision (user, 2026-10-16): two new parent tasks after 13.0: **14.0** `tbBlob --check` (one OK/MISSING line per dependency with its fix; exit 4 if any is missing), the same clear messages on normal runs, and a bundled CastXML found automatically at `<tbBlob folder>\castxml\bin\castxml.exe` (after `--castxml` and `CASTXML`, before `PATH`); **15.0** `tools\package.ps1` producing `dist\tbBlob\` (tbBlob.exe, CastXML bin + share, licences, docs) and verifying it, plus a root `README.md` linking `docs\USAGE.md` and `docs\SETUP.md`. Visual Studio Build Tools cannot be bundled (Microsoft licence) — documented as a prerequisite; CastXML/LLVM (Apache-2.0) are bundled with their licences.
- Rationale: the docs should describe real, tested behaviour, so the checks come first; one copyable folder plus one prerequisite (Build Tools) is the simplest deployment.
- Alternatives considered: not bundling CastXML (more setup steps per machine); a single README (long); one combined task (two coherent pieces).

---
### D-036 — Exit 4 prints the checklist; SKIPPED vs MISSING; castxml.exe is never run unless it has an executable header (Task 14.4)
- Date: 2026-10-16
- Scope: Task-only
- Status: Active
- Context: implementing D-035 (14.0):
  - The user asked (2026-10-16) that a run failing with exit code 4 also run the checks implicitly.
  - The first exit-4 output listed checks that could not run (because castxml.exe was missing) as MISSING — "5 of 9 missing" for one real problem.
  - The user reported intermittent "This app can't run on your PC" dialogs. Cause: `Tests_Doctor` test 3 creates an empty placeholder `castxml.exe`, and `Doctor.CheckEnvironment` ran it (`--version` and both compile probes), up to 3 dialogs per self-test run. The Windows event logs (System "Application Popup", Program-Compatibility-Assistant) record nothing for this dialog; the attribution is from the code path.
- Decision:
  - `MainModule.Run`: when generation returns exit 4, print "Dependency check (the same as tbBlob --check):" and the checklist after the error.
  - `DepCheck.Skipped`: checks that need a missing dependency print SKIPPED, not MISSING; the summary reads "N missing, M not checked because of them -- out of K checks".
  - `CastXmlRunner.LooksLikeProgram`: the first 1 KB must hold `MZ` and a `PE\0\0` signature at `e_lfanew`; otherwise castxml.exe is reported "not a valid program (… empty or damaged?)" and never run (`--check` and normal runs, exit 4). The compile probes run only when "castxml.exe starts" passed. Protects users with a truncated download as well as the tests.
- Rationale: one run should show every missing dependency, accurately counted, without side effects on the desktop.
- Alternatives considered: `SetErrorMode` to suppress the dialog (it is shown by the shell for bad-format images; detecting the format is simpler and also explains the problem).

---
### D-037 — Where a libgit2 run spends its time (Task: 16 measurement)
- Date: 2026-10-16
- Scope: Finding
- Status: Active
- Context: task 16 (speed) was agreed with the user on the condition of measuring first. Candidates: parallel CastXML passes, early-bound MSXML 6, early-bound Scripting.Dictionary (not tB Collection: default case-insensitive keys, no in-place update), indexed lookups (D-024).
- Decision (observed): libgit2 1.9.1 with every `git2/sys/*.h` (`--also`, `-D ssize_t=intptr_t`, `--x86-dll`), tbBlob build of 14.0/15.0, progress lines timestamped from outside: **104.5 s** total —
  - CastXML, four passes: 31.2 s (30%); x86 DLL exports 0.3 s; loading both XMLs 4.3 s; **x86/x64 consistency 14.3 s**; reading macros 1.7 s; **mapping names 12.5 s**; **generating 39.7 s**; writing 0.2 s. tbBlob's own processing after loading: ~68 s (65%).
  - The four CastXML scripts run directly: 6.2 + 5.7 + 6.4 + 6.3 = **24.6 s** one after another, **21.3 s** all four at once on this machine's **2 cores**; peak memory of the four castxml processes together 105 MB. (Inside tbBlob the same four passes took 31.2 s: ~6.6 s of overhead around them, not yet explained.)
  - Linear scans in hot paths: `TypeMapper.FindFunction` (all functions, late-bound name per element; called per function, ~460k attribute reads on libgit2), `TypeMapper.FindRecord` (all records), `CxModel.FindElement` (every node of the document, three late-bound calls each; behind `FindTypedef` and 12 call sites).
- Verified under: tB BETA 983, Windows 11, 2-core machine, MSVC 14.44, CastXML 0.6.5, libgit2 1.9.1 + sys.
- Consequence: indexed lookups target most of the 66 s in consistency + mapping + generation; early-bound MSXML lowers the cost of every remaining XML call; parallel CastXML saves ~3 s here and up to ~18 s on 4+ cores. Byte-identical output is the correctness criterion for any speed change (the determinism tests and `verdict.ps1`'s regeneration check compare it).

---
### D-038 — Speed: indexed lookups (16.0), then early-bound MSXML 6 + Scripting.Dictionary (17.0); no parallel CastXML (Tasks 16.0, 17.0 (new))
- Date: 2026-10-16
- Scope: Plan
- Status: Active for 16.0; superseded by D-040 for 17.0
- Context: D-037 (measurement). The user chose (2026-10-16) indexed lookups, early-bound MSXML 6 and early-bound Scripting.Dictionary; parallel CastXML is left out (≈3 s on this 2-core machine). The user had also rejected tB `Collection` as a Dictionary replacement (no in-place update; ~39 sites update values in place).
- Decision: two parent tasks after 15.0 — **16.0** name indexes built once replace `FindElement` / `FindRecord` / `FindFunction` scans (no project change); **17.0** references to *Microsoft XML, v6.0* and *Microsoft Scripting Runtime* in `Source\Settings`, `New MSXML2.DOMDocument60` with typed nodes, `New Scripting.Dictionary`. Acceptance for both: byte-identical `Source\` and `report.md` for tbfixture and libgit2+sys, and re-measured stage times logged.
- Rationale: indexes remove the dominant algorithmic cost without touching the project's references; early binding is a separate, mechanical change with its own risk (type library references in Settings).
- Alternatives considered: parallel CastXML (small gain here; can be revisited for many-core machines); tB Collection (semantics differ).

---
### D-039 — Indexed lookups gave no speed-up; late-bound Scripting.Dictionary calls (~200 µs each) dominate (Task 16.4)
- Date: 2026-10-17
- Scope: Finding
- Status: Active
- Context: 16.0 replaced the `FindElement` / `FindRecord` / `FindFunction` scans with dictionary indexes (D-038).
- Decision (observed, tB BETA 983, this 2-core machine, libgit2 1.9.1 + sys):
  - The indexes are correct: a fresh generation of both harnesses is byte-identical to the baseline taken before the change (97 files). They are **not faster**: consistency 14.3 s → 14.3 s, mapping names 12.5 → 13.4 s, generating 39.7 → 38.0 s (CastXML 31.2 → 40.4 s is run-to-run noise; its code did not change).
  - `Tests_Perf` (integration, reports only) timed the building blocks: late-bound MSXML `getAttribute` (`CxModel.Attr`) **2.5 µs** per call, `childNodes.length` 1.1 µs; **late-bound `Scripting.Dictionary` lookup (`CxModel.ById`) 220 µs**, `Exists` + `Item` 199 µs. `SignatureText` 6 ms per function, `ParamsOf` 5 ms, `FieldsOf` 13 ms per record, `DocRaw` 0.8 ms; `Disagreements` 14.7 s, `Emitter.Init` 12.8 s, `Emitter.Generate` 39.1 s, loading both XMLs 7.7 s.
  - So the indexes swapped scans of ~2.5 µs reads for ~200 µs dictionary lookups — roughly even. Every dominant stage leans on dictionaries (`ById` at each step of type classification, `FileOf`/`InLibrary`, the anonymous-name map, the naming table, the macro tables).
- Verified under: tB BETA 983, Windows 11, 2-core machine; `CreateObject("Scripting.Dictionary")` held `As Object`.
- Consequence: task 17's priority is the dictionary, not MSXML (at 2.5 µs per call early-bound MSXML can save little). 17 should first measure an early-bound `Scripting.Dictionary` (and, for read-only maps, a tB `Collection` with `KeyCompareMode = vbBinaryCompare`) in `Tests_Perf`, then convert. The indexes stay (correct, and they avoid quadratic scans on larger libraries).

---
### D-040 — Maps: tB Collection with explicit KeyCompareMode wherever possible; early binding for the rest; measure first (Task 17.0 (revised))
- Date: 2026-10-17
- Scope: Plan
- Status: Active
- Supersedes: D-038 (its 17.0 part)
- Context: D-039 found late-bound `Scripting.Dictionary` calls (~200 µs each) dominate tbBlob's own time, not MSXML (2.5 µs). The user (2026-10-17) prefers tB's `Collection` wherever possible — it is better optimised than VBx's and has `KeyCompareMode`, which should be set **explicitly** (self-documenting that keys are case-sensitive) rather than relied on; where a value must be updated in place, use another approach (an array when the size is known, an array of UDT) or an early-bound dictionary. The user added the *Microsoft Scripting Runtime* and *Microsoft XML, v6.0* references in the IDE and exported the project to a temporary folder (code identical to `Source\`; only the two reference entries are taken, not the export's `exportPath`/version fields or package sources).
- Decision: 17.0 becomes: add the two references to `Source\Settings`; measure keyed `Collection`, early-bound and late-bound `Scripting.Dictionary`, and early- vs late-bound MSXML in `Tests_Perf`; convert the 36 dictionary sites — keyed `Collection` with `KeyCompareMode = vbBinaryCompare` where values are written once or are objects mutated in place; a holder-class item, an array / array of UDT, or an early-bound `Scripting.Dictionary` where a value itself is replaced; early-bound MSXML if measured worthwhile. Byte-identical output and re-measured stage times are the acceptance criteria.
- Rationale: fastest structure per use, with case-sensitivity explicit at every keyed collection.
- Alternatives considered: early-bound `Scripting.Dictionary` everywhere (simpler, but not the user's preference); tB `Collection` everywhere (cannot replace a value in place).

---
### D-041 — tB Collection lookups cost 0.2 µs; Scripting.Dictionary ~100 µs even early-bound, because of cross-apartment marshalling (Task 17.2)
- Date: 2026-10-17
- Scope: Finding
- Status: Active
- Context: D-040 asked to measure before converting the 36 dictionary sites.
- Decision (observed, `Tests_Perf`, tB BETA 983, this 2-core machine, 100,000 calls unless noted):
  - `Exists` + `Item`, one key: late-bound `Scripting.Dictionary` **193 µs**, early-bound **104 µs**, tB `Collection` with `KeyCompareMode = vbBinaryCompare` **0.2 µs**. With 20,000 keys: late-bound 187 µs (10,000 calls), early-bound 100 µs, `Collection` **0.3 µs**.
  - MSXML `getAttribute`: late-bound 1.1 µs, early-bound element **0.4 µs**.
  - Cause of the dictionary cost: `Scripting.Dictionary` is registered `ThreadingModel = Apartment`, and tbBlob initialises COM as MTA (`project.comInitialization` in `Settings`), so every dictionary lives in another apartment and every call is marshalled (~100 µs). MSXML 6's `DOMDocument60` is `Both`, so it is called directly.
- Verified under: tB BETA 983, Windows 11, `HKCR\CLSID\{EE09B103-97E0-11CF-978F-00A02463E06F}\InprocServer32 ThreadingModel = Apartment`, `{88D96A05-F192-11D4-A65F-0040963251E5}` = `Both`.
- Consequence: convert every `Scripting.Dictionary` to a keyed tB `Collection` (explicit `KeyCompareMode = vbBinaryCompare`), with a holder-class item where a value is replaced in place (D-040) — no early-bound dictionary is needed, and no change to the COM threading model. Early-bound MSXML is a smaller, separate gain (~0.7 µs per attribute read), to be measured after the conversion.

---
### D-042 — All maps keyed Collections, MSXML early-bound and typed throughout; libgit2+sys 104.5 s → 36.4 s (Task 17.4)
- Date: 2026-10-17
- Scope: Task-only
- Status: Active
- Context: implementing D-040 with the D-041 measurements.
- Decision:
  - Every `Scripting.Dictionary` in tbBlob (31 maps in 9 modules) is a keyed tB `Collection` with `KeyCompareMode = vbBinaryCompare` set explicitly at creation. `Add` arguments swapped (item, key); key loops use `.Keys()`; numeric keys `CStr`; `RemoveAll` → `Clear`. Replace-in-place: report counters use the new `ValueBox` holder class; `MacroTable`'s lookup-only maps use `StoreItem` (remove if present, then add — not named `Put`, a VB statement: TB5092 on the first attempt). The export map (`PeExports`, `Emitter.X86Exports`, `Pipeline`) is a `Collection` end to end. The naming table's case-insensitive collision detection is unchanged (it always used explicitly lower-cased keys).
  - MSXML 6 early-bound: `New MSXML2.DOMDocument60`; at the user's prompt ("why As Object? it's all internal"), all 108 node declarations in the generator are `MSXML2.IXMLDOMElement` (CastXML output has no text/comment nodes), not just `CxModel`'s internals. Left `As Object` on purpose: `Tools`' `WScript.Shell`, `Doctor`'s `CreateObject` probe of MSXML 6.
  - The *Microsoft Scripting Runtime* reference is removed (user's choice), with the early-bound dictionary benchmark lines; `Tests_Perf` keeps the late-bound dictionary lines as the D-041 record.
- Observed (libgit2 1.9.1 + sys, this 2-core machine): stages after CastXML — load 4.3 → 0.2 s, consistency 14.3 → 0.3 s, macros 1.7 → 0.3 s, mapping 12.5 → 2.4 s, generating 39.7 → 1.2 s: tbBlob's own work ~73 s → ~5 s; a whole run 104.5 s → **36.4 s**, of which CastXML 31.3 s. Fresh output of both harnesses byte-identical to the baseline (97 files) after the Collection conversion and again after early binding. `Tests_Perf` (Collection build): `ById` 0.2 µs, `SignatureText` 0.46 ms per function, `Disagreements` 0.7 s, `Emitter.Init` 3.4 s, `Generate` 1.8 s.
- Rationale: D-040 / D-041.
- Alternatives considered: switching tbBlob's COM apartment to STA (would also remove the marshalling, but the Collection is ~500× faster still and changes nothing global).

---
### D-043 — A newer CastXML snapshot gives byte-identical output and no speed-up; keep vcpkg's 0.6.5 (Task: 17 evaluation)
- Date: 2026-10-17
- Scope: Finding
- Status: Active
- Context: the user asked whether a CastXMLSuperbuild release (https://github.com/CastXML/CastXMLSuperbuild/releases) should replace vcpkg's CastXML 0.6.5 (Clang 18.1.3). They downloaded `castxml-windows-win11-amd64`, which reports `castxml version 0.6.20260105-g9864b1e` and `clang version 21.1.8 (git@github.com:thewtex/CastXMLSuperbuild 0b677ec…)`.
- Decision (observed; tbBlob build of 17.0, this 2-core machine), the snapshot passed via `--castxml`:
  - `tbBlob --check`: all 9 OK (same `bin` + `share\castxml` layout; resource headers found; x86 and x64 compile probes pass). Imports the same MSVC runtime (`MSVCP140`, `VCRUNTIME140`, `VCRUNTIME140_1`) plus `ntdll`. Size 124 MB (280 files) vs 108 MB (236 files).
  - Output: the fixture (`--also tbfixture_sys.h`, `--x86-dll`) and libgit2 + sys (`-D ssize_t=intptr_t`, `--x86-dll`, every `--also`) are **byte-identical** to the baseline — 5/5 and 92/92 files.
  - Speed, the same four CastXML scripts run directly, two alternating rounds: 0.6.5 32.7 s / 26.5 s (average 29.6 s), snapshot 39.7 s / 28.4 s (average 34.1 s) — not faster (run-to-run variation on this machine is several seconds).
- Verified under: tB BETA 983, MSVC 14.44, Windows 11, libgit2 1.9.1.
- Consequence (user, 2026-10-17): keep bundling vcpkg's CastXML 0.6.5 — a versioned release reproducible from `CastXML\vcpkg.json`, smaller, no slower; the snapshot is a CI build from a personal fork. A user who needs a newer Clang (newer C standards or MSVC headers) can already pass `--castxml` or set `CASTXML` (docs\SETUP.md); this test shows tbBlob's output does not depend on the CastXML build.

---
### D-044 — Close coverage gaps 1 (callbacks on library-created threads, spike first) and 3 (library-allocated memory the caller frees) (SPIKE-10, Tasks 18.0, 19.0 (new))
- Date: 2026-10-17
- Scope: Plan
- Status: Active
- Context: the verdict and both COVERAGE.md files list untested gaps; the user (2026-10-17) chose gap 1 (callbacks invoked on a thread the library created) and gap 3 (library-allocated buffers/strings the caller must free). The user suggested threads are a matter of ownership the consumer must follow from the library's documentation. That is half of it: what a callback may do on a foreign thread (shared state, no UI, no apartment-bound COM objects, no error escaping into C) is consumer guidance, and only the library's documentation says which callbacks are threaded (a C header cannot, so tbBlob cannot NOTE it). The other half — whether twinBASIC code runs correctly at all on a thread its runtime did not create (VB6 did not) — is undocumented behaviour, so a spike is required before the task is planned.
- Decision: **SPIKE-10** (throwaway `spikes/threads/`: C DLL + hand-written tB probe) observes callbacks on `CreateThread` threads, concurrency, local error handling, and records unhandled errors and `CreateObject` there; **18.0** is a placeholder until SPIKE-10's finding exists (then: tbfixture threaded functions, harness checks, a "Callbacks and threads" section in docs\USAGE.md, COVERAGE.md); **19.0** adds a library-allocated string + free and a `git_buf`-shaped struct + dispose to tbfixture with an outstanding-allocation counter, and a libgit2 `git_buf` round trip.
- Rationale: test what can be tested; document what only the consumer can know.
- Alternatives considered: treating threads as documentation only (would leave "does it work at all" unproven); folding the spike into 18.0 (spike undocumented behaviour first).

---
### D-045 — tB callbacks work on threads the library creates; shared state races, COM needs CoInitializeEx, unhandled errors are swallowed (Task: Spike)
- Date: 2026-10-17
- Scope: Finding
- Status: Superseded by D-046
- Context: SPIKE-10 (D-044). Probe `spikes/threads/`: `threadprobe.dll` (C, `CreateThread`, cdecl callback `int (*)(void *context, int n)`), hand-written tB console probe calling it through `Delegate … CDecl` + `AddressOf`.
- Decision (observed, both architectures unless noted):
  - A tB `CDecl` callback invoked from a C-created thread runs correctly: return value (n*2+1), context pointer, module variable written on that thread, on a different OS thread from `Main` (id = the C worker's), builds a `String` (incl. non-ASCII), creates and uses a `New Collection` (`KeyCompareMode = vbBinaryCompare`, keys `"k"`/`"K"` distinct), raises and handles an error locally (`On Error GoTo`), and the same procedures still work from the main thread afterwards. 11/11 checks PASS on win32 and win64.
  - Concurrency, 4 threads × 10,000 calls at once: an atomic increment (via the DLL's `InterlockedIncrement`; on x64 it is an intrinsic, not a `kernel32` export) counted exactly 40,000 on both; a plain `mPlain += 1` counted 40,000 on win32 (no loss that run) and **39,993 on win64** — unsynchronised module state loses updates.
  - `CreateObject("Scripting.Dictionary")` on the foreign thread fails with **-2147221008 "CoInitialize has not been called"** (CO_E_NOTINITIALIZED): the tB runtime does not initialise COM on threads it did not create.
  - An **unhandled** `Err.Raise` inside the callback is **swallowed**: no crash, the callback's result is 0 (the default), and `Main` sees `Err 0` after the call (consistent with D-015 for delegate-called procedures on the calling thread).
- Verified under: tB BETA 983, Windows 11, 2-core machine, MSVC 14.44; threads created and joined per call (short-lived), up to 4 at once. Not tested: long-lived thread pools, thread exit while tB objects are alive, UI.
- Consequence: task 18 gets tbfixture functions that call back from their own threads (single, concurrent, a callback whose "stop" result matters) with harness checks of the above, plus consumer guidance in docs\USAGE.md: callbacks may run on library threads only when the library says so (tbBlob cannot tell from a header); on such threads synchronise shared state (atomic API or a lock), call `CoInitializeEx`/`CoUninitialize` around any COM use and never touch apartment-bound objects from the main thread, and handle every error inside the callback, returning the library's error value explicitly — an unhandled error silently becomes a 0 return, which many C libraries read as "continue".

---
### D-046 — Corrects D-045: an unhandled error in a callback on a library thread shows a modal run-time error box (Task: Spike)
- Date: 2026-10-17
- Scope: Finding
- Status: Active
- Supersedes: D-045 (its "unhandled errors are swallowed" point; everything else in D-045 stands)
- Context: SPIKE-10's `risky` run. The probe's results showed `tp_call_on_thread returned 0; Err 0` and exit code 0, which D-045 read as "swallowed, no crash". The user then reported what the results could not show: during the test a modal dialog appeared **twice** (once per architecture) — caption `shutdown`, text `Run-time error '5'` / `unhandled, inside a callback on a foreign thread`, button OK — and the runs finished after it was dismissed.
- Decision (observed): an unhandled `Err.Raise` inside a tB `CDecl` callback on a C-created thread (1) does not propagate into C (the callback's result is 0), (2) does not reach `Main` (`Err` is 0 after the call), and (3) **makes the tB runtime show a modal "Run-time error" message box** (caption "shutdown", suggesting it is reported when the thread or process shuts down; when exactly was not measured), which blocks until someone clicks OK — a hang in a console tool, service or unattended run.
- Verified under: as D-045 (tB BETA 983, Windows 11, win32 and win64, short-lived `CreateThread` threads); dialog observed by the user.
- Consequence: the consumer guidance (task 18, docs\USAGE.md) must say that every callback that can run on a library thread handles all errors itself (`On Error` at the top, return the library's error value explicitly). An escaping error is neither reported to C nor to the caller, and blocks on a dialog. Task 18's harness must not exercise the unhandled case (it would block `run-all`); the spike's `risky` run is the record.

---
### D-047 — LLVM licence in the package; README files for key folders; the import tool moves to tools\impexp\ (Tasks 20.0, 21.0 (new))
- Date: 2026-10-17
- Scope: Plan
- Status: Active
- Context: the user (2026-10-17) asked for (1) the LLVM licence in the distributable if required, (2) README files in crucial folders — `tests\` (purpose, scope, use), `CastXML\` and `libgit2\` (in git they hold only a `vcpkg.json`), `spikes\` (overview with back-references), and (3) whether `impexp.twinproj` belongs at the root, since it is a test-only dependency whose output also lands in tbBlob's `Build\`.
- Decision:
  - (1) Required: the package redistributes `castxml.exe`, which statically contains LLVM/Clang 18.1.3, and Clang's resource headers; Apache-2.0 §4(a) requires giving recipients a copy of the licence for redistributed object code (the LLVM exception does not waive that for LLVM itself). Not legal advice. LLVM's `LICENSE.TXT` from tag `llvmorg-18.1.3`, verbatim, goes into `tools\licenses\` and the package; `package.ps1` checks it.
  - (2) README files for `tests\`, `CastXML\`, `libgit2\`, `spikes\` and `tools\` (`docs\` and `reference\libgit2tB\` already have their own). Not inside `Source\`: everything there is imported into the project.
  - (3) `impexp.twinproj` is the source of `tBImportExport_win64.exe`, which `tests\import.ps1` uses to rebuild `tbBlob.twinproj` from `Source\` — a build-from-source dependency as well as a test one — so it moves to `tools\impexp\` (beside `package.ps1`) rather than `tests\`. Its build path is relative to the project file, so its output moves to `tools\impexp\Build\`, apart from tbBlob's `Build\`. The tracked EXE moves with it.
- Rationale: complete licensing for redistribution; a clone should explain itself folder by folder; tbBlob's `Build\` should hold only tbBlob's outputs.
- Alternatives considered: `tests\tools\impexp\` (it is used to build tbBlob itself, not only by tests); a URL instead of the licence text (does not satisfy §4(a)).

---
### D-048 — Delete the superseded leftovers git2.xml and reference\libgit2tB\ (Task 21.3a)
- Date: 2026-10-17
- Scope: Task-only
- Status: Active
- Context: during 21.0 the root `git2.xml` (the original hand-made 32-bit CastXML dump, PRD §7 note 3) and `reference\libgit2tB\` (the hand-written bindings the harness replaces, kept "only as a reference" by PRD req. 33) were still tracked. The user (2026-10-17): remove them; no leftovers, since the generated bindings and the libgit2 harness are the better proof.
- Decision: `git rm` both. Nothing in the code, tests or scripts used them (only the libgit2 README mentioned `reference\`, updated). The PRD and older decision entries keep mentioning them as history; git history keeps the files.
- Rationale: they were reference material for the proof, which is complete (verdict "works", task 13.0); kept, they mislead (git2.xml is 32-bit only).
- Alternatives considered: keep them under `spikes\` (they are not spike output).

---
### D-049 — Dependencies by purpose: run, build, test (Task 22.0 (new))
- Date: 2026-10-17
- Scope: Plan
- Status: Active
- Context: the user (2026-10-17) noted `tools\package.ps1` assumes CastXML is already installed through vcpkg, while `docs\SETUP.md` lists only runtime dependencies (correctly saying vcpkg isn't needed to run) and never says how to get vcpkg, which a fresh clone needs to build the package or run the tests. Also: SETUP.md still lists the Scripting Runtime, removed in 17.0 (D-040/D-042). Python was checked: only `spikes\castxml-ffi-generator\gen_probe.py` uses it.
- Decision: SETUP.md gets three cumulative dependency tables (run / build tbBlob and the package / run the tests), a "Getting vcpkg" section, and fresh-clone build steps; the folder READMEs link there instead of repeating it. `package.ps1` does not run vcpkg itself; when CastXML is missing it prints the exact install command. A package self-test check keeps the SETUP.md structure from regressing.
- Rationale: each reader finds their list without reading the others; the message is enough for a once-per-machine step.
- Alternatives considered: `package.ps1` installing CastXML when vcpkg is on PATH (it would have to locate vcpkg and may download silently; offered to the user, who chose the message only).
---
### D-050 — LibGit2Counts generates its own XML; clean-clone first run documented (Task 23.0 (new))
- Date: 2026-10-17
- Scope: Task-only
- Status: Active
- Context: the user (2026-10-17) cloned fresh and ran `tbBlob --self-test --integration`: `LibGit2Counts` failed because it read `spikes\castxml-ffi-generator\xml\git2_x64.xml`, which is gitignored spike output (`run_castxml.ps1`). It was the only test in `Source\`, `tests\` or `tools\` reading anything under `spikes\`. The same user's first `run-all.ps1` passed 101 of 159 checks until the fixtures were built and both harnesses compiled in the IDE; SETUP.md did not say so.
- Decision: the test generates the libgit2 x64 XML itself with `CastXmlRunner` (same as `FixtureCounts`), so it needs only what the other integration tests already need (CastXML and libgit2 from vcpkg). SETUP.md and tests\README.md say what a first run on a fresh clone reports and that spike output is not a test dependency.
- Rationale: a test must not depend on an artifact a script outside the test suite has to produce first; the runner is the code under test anyway, and it was proven equal to the spike script's invocation (same -I, entry header, vcvars).
- Alternatives considered: documenting `run_castxml.ps1` as a setup step (leaves a hidden ordering dependency); skipping the test when the XML is missing (hides the coverage silently).

---
### D-051 — Fixture snapshots carry a {REPO} placeholder, resolved by the tests (Task 24.0 (new))
- Date: 2026-10-17
- Scope: Task-only
- Status: Active
- Context: the user (2026-10-17) showed a clean clone at `C:\GitHub\tbBlob` passing 100 of 151 self-tests. CastXML writes absolute paths into `<File name=...>`, so the committed `tbfixture_x86.xml`/`_x64.xml` hold `C:\tbBlob\tests\fixture-c\tbfixture.h`. The tests pass `<repo>\tests\fixture-c` as the header folder; `CxModel` keeps only declarations under it (and the doc-comment reader opens headers by the path in the XML), so with any other clone path every model was empty. The user's own find-and-replace of the path had hidden the cause. Production code was right: it takes its header folder from the command line. `SelfTest.RepoRoot` is test-only and stays so.
- Decision: commit the snapshots with `{REPO}` in place of the repository root; `regen-fixture-xml.ps1` writes it; tests load a per-run copy with `{REPO}` replaced by `SelfTest.RepoRoot()` (`SelfTest.Fixture`). A unit test fails if a snapshot holds any other path to `tests\fixture-c`.
- Rationale: the tests' own paths were already relative to the EXE; only the snapshot was not, and CastXML cannot emit relative paths. A placeholder keeps the snapshots real CastXML output apart from one token.
- Alternatives considered: regenerating the XML with CastXML in every unit test (slow, turns unit tests into integration tests, needs MSVC); passing the baked-in path as the header folder (the file must exist at that path for doc comments); matching header folders by path suffix in `CxModel` (changes production behaviour for a test-data problem).

---
### D-052 — cairo 1.18.4: 419 of 425 exports generated; outside types dangle; one DLL per run duplicates cairo.h (Task: cairo assessment)
- Date: 2026-10-22
- Scope: Finding
- Status: Active
- Context: the user (2026-10-21) asked whether tbBlob can generate every cairo function, as a second library after libgit2. cairo's headers are spread out: `cairo.h` includes only `cairo-version.h`, `cairo-features.h` and `cairo-deprecated.h`; each backend has its own header that `cairo.h` does not include; `cairo-ft.h` reaches FreeType and fontconfig outside `include\cairo`, `cairo-win32.h` includes `windows.h`; `cairo-script-interpreter.h` belongs to a second DLL. An earlier attempt (`C:\GitHub\tbCairo\tbBlob`, entry `cairo.h` + `--also cairo-features.h` only) bound 345 functions.
- Decision (observed):
  - Run 1: header folder `include\cairo`, entry `cairo.h`, DLL `cairo-2.dll`, `-I include` (for `ft2build.h`), `--also` `cairo-pdf.h`, `cairo-ps.h`, `cairo-svg.h`, `cairo-script.h`, `cairo-tee.h`, `cairo-win32.h`, `cairo-ft.h`. Exit 0, 409 functions, no mapping notes, no x86/x64 disagreements. Compared with `dumpbin /exports cairo-2.dll` (415): every generated function is exported; the 6 not generated are the 5 `cairo_dwrite_*` (`cairo-dwrite.h` has `#error DWrite font backend requires C++` when read as C) and `cairo_win32_get_system_text_quality` (exported, but in no public header).
  - Run 2: entry `cairo-script-interpreter.h`, DLL `cairo-script-interpreter-2.dll`: its 10 exports all generated, but `cairo.h` sits in the same header folder, so the run also emitted all 345 `cairo.h` functions bound to `cairo-script-interpreter-2.dll`, and a second `cairo` module. Library membership is decided by folder (`CxModel.InLibrary`), the DLL only by the command line.
  - The output does not compile: 16 declares name types that are never emitted, because `TypeMapper.RecordOrOpaque` classifies a struct without asking `Model.InLibrary`, while the emitter only emits library records and opaque aliases. Affected: `cairo_win32` (`ByRef HDC__`, `HFONT__`, `tagLOGFONTW`), `cairo_ft` (`ByRef FT_FaceRec_`, `ByVal FcPattern`), `cairo_script_interpreter` (`ByRef _iobuf` for `FILE*`). Inconsistent with `ReturnOf`, which already returns `LongPtr` for any pointer to a non-opaque struct. CastXML had resolved them all: `HDC__`/`HFONT__` 4 bytes (`shared\windef.h`, `DECLARE_HANDLE`), `tagLOGFONTW` 92 (`um\wingdi.h`), `_iobuf` 8 (`ucrt\corecrt_wstdio.h`: `struct _iobuf { void* _Placeholder; }`), `FT_FaceRec_` 216 (`freetype\freetype.h`), `FcPattern` incomplete. libgit2 never hit this: its API names no outside struct.
- Verified under: cairo 1.18.4 from vcpkg (x64-windows only, `C:\GitHub\tbCairo\cairo`), the packaged `dist\tbBlob\tbBlob.exe` of the first public release, CastXML 0.6.5, Windows SDK 10.0.26100.0, MSVC 2022 Enterprise. Generated code not compiled (the dangling names are certain from the text). No x86 cairo DLL, so `--x86-dll` was not exercised (cairo is all cdecl).
- Consequence: D-053 (function → DLL from export tables), D-054 (outside types), D-055 (cairo as a proof library).

---
### D-053 — Bind each function to the DLL whose export table has it (Task 26.0 (new))
- Date: 2026-10-22
- Scope: Plan
- Status: Active
- Context: D-052 run 2. The user (2026-10-22): rather than mapping headers to DLLs by hand, accept the DLL or a folder of DLLs and read the export tables, since a function the headers declare but no DLL exports cannot be called; the export table is authoritative. `PeExports.ExportNames` already reads PE32 and PE32+ (D-026), so far only for `--x86-dll`.
- Decision:
  - `<dll>` may be a DLL file or a folder. tbBlob reads the x64 export table of each DLL (each `*.dll` directly in the folder) and binds every library function to the DLL that exports it (`Lib "<file name>"`). `--x86-dll` may likewise be a file or folder; it keeps deciding plain vs `_name@N` per `__stdcall` function (D-026), now per DLL.
  - Exported by no DLL: no declare; listed in the report ("Declared but not exported", now skipped rather than emitted with a `NOTE:`).
  - Exported by more than one DLL: generation fails, naming the function and the DLLs; `--dll <function or header>=<dll file name>` settles it. Other libraries' DLLs in the folder (vcpkg `bin` holds freetype, zlib, ...) are harmless: only library functions are looked up.
  - A bare name that is not an existing file or folder keeps today's behaviour: every function binds to that name, nothing is checked (generating where the DLL is absent).
  - The report lists each DLL and its function count. It also lists, per bound DLL, the exports that no library header declares ("Exported but not declared": for cairo, the 5 `cairo_dwrite_*` and `cairo_win32_get_system_text_quality`), so a header left out or a C++-only header is visible. The Loader loads every DLL the project binds to, in the order they first appear, from the same folder rules (D-027).
- Rationale: the export table is the only authority on where a function lives; it handles cairo's two DLLs in one run with one copy of the cairo types, and needs no per-header configuration.
- Alternatives considered: `--dll <header>=<dll>` mapping as the main mechanism (manual, and wrong whenever a header's functions live in two DLLs); a second run treating `cairo.h` as outside (would import cairo's own types again under D-054); only filtering by the one given DLL (cannot bind the interpreter's 10 functions in the same project).

---
### D-054 — Import outside types into header-named modules; LongPtr aliases only where C/SDK make it certain; --qualify-outside, --pointer (SPIKE-11, Tasks 27.0, 28.0 (new))
- Date: 2026-10-22
- Scope: Plan
- Status: Superseded (partial) by D-065
- Context: D-052's dangling types. Discussed with the user (2026-10-21/22): a pointer is passed as one address whatever the struct's size, so `ByVal LongPtr` is exact for any pointer; a struct passed or returned by value, or embedded as a field, is copied (x86: whole struct on the stack; x64: 1/2/4/8 bytes in a register, else a pointer to a caller copy; returns may use a hidden pointer) and needs its real layout. C refuses by-value use of an incomplete struct, so whenever by-value use occurs CastXML has the full layout. The user: import outside structs rather than collapse them, and accept name clashes with packages (a local module takes priority in tB; the module name disambiguates).
- Decision:
  - **Outside type** = a struct, union, enum or typedef declared in a header not under the header folder (Windows SDK, CRT, other libraries) that a library declaration uses. It is emitted into a module named after its header, by the same rule as library modules (`Naming.ModuleName`, relative to its include root): `windef`, `wingdi`, `corecrt_wstdio`, `freetype`, ... Every type it needs is imported too (transitive closure; `FT_FaceRec_` brings `FT_Generic`, `FT_BBox`, ...). Its layout is checked like a library record (LayoutCheck, x86/x64 comparison).
  - **Pointer-only kinds become `Public Alias X As LongPtr`, no struct**, only where it is certain:
    - incomplete (opaque) structs: CastXML marks them incomplete (`FcPattern`; the rule tbBlob already applies to `cairo_t`);
    - Windows handles: the exact `DECLARE_HANDLE` expansion (`struct X__ { int unused; }` with `typedef X__ *X`): `HDC`, `HFONT`, `HWND`, ...;
    - a built-in list of standard types that C defines as used only through pointers: `FILE` (C11 §7.21.3: a copy of a `FILE` need not serve in place of the original; UCRT's `_iobuf` is a placeholder). The list starts with `FILE` and grows only on the same kind of evidence.
  - **Pointer typedef to a complete outside struct** (`typedef struct FT_FaceRec_ *FT_Face`): `Public Alias FT_Face As LongPtr` (the author named the pointer as the handle), and the struct is still emitted for reading fields.
  - **`T*` to a complete outside struct** (`const LOGFONTW*`): `ByRef As <T>`, the same rule as library structs.
  - **By value or as a field**: always the real `Type`; never `LongPtr`.
  - Scope: the alias and spelling rules apply to outside types only; library types keep today's mapping (no change to libgit2 or tbfixture output).
  - `--qualify-outside`: outside type names are written module-qualified (`wingdi.tagLOGFONTW`) wherever they are used; off by default.
  - `--pointer <C type name>` (repeatable): that outside struct type is passed and returned as `LongPtr` when reached through a pointer, for the cases no header or standard can tell (a third-party placeholder struct like UCRT's `FILE`, written `T*`). The report lists every outside struct passed `ByRef`, so a candidate is visible.
  - Report: an "Outside types" section (module, header, kind: imported struct / handle alias / opaque alias / standard pointer type / pointer typedef).
  - **Unknown before 27.0: SPIKE-11** checks in tB that (1) a `Type` in a module is usable module-qualified (`wingdi.tagLOGFONTW`) as a Declare parameter, return, `Type` field and `Alias` target; (2) a local module's `Type` takes priority over a same-named `Type` from a referenced package, and the qualified name selects either; (3) two local modules defining the same name compile and resolve when qualified.
- Rationale: generated code must compile and must never misrepresent a by-value struct; aliases are used only where the C language, the Windows SDK's handle convention or CastXML makes "pointer-only" a fact; the rest follows the header author's spelling, with an override for what nothing can determine.
- Alternatives considered: `ByVal LongPtr` for every pointer to an outside struct (loses `ByRef` struct passing for structs the caller fills, like `LOGFONTW`); not importing outside structs and failing on by-value use (blocks real libraries); module names by DLL, e.g. `User32` (a struct belongs to a header, not a DLL; CastXML cannot tell which DLL); recognising `FILE` by its `_Placeholder` field (a one-header special case; the C standard is the real reason).

---
### D-055 — cairo becomes the second proof library: generation, compile and layout tests, then a runtime harness (Tasks 29.0, 30.0 (new))
- Date: 2026-10-22
- Scope: Plan
- Status: Active
- Context: D-052; cairo exercises what libgit2 does not: several DLLs, outside types (Windows SDK, CRT, FreeType, fontconfig), many backend headers, `double`-heavy signatures and struct returns through pointers.
- Decision: a `cairo\vcpkg.json` beside `libgit2\` (x64 and x86 trees, as libgit2's), an integration test that generates all of cairo in one run (both DLLs as a folder, every C backend header with `--also`) and checks counts against the export tables (all 425 bound except the 5 `cairo_dwrite_*` and `cairo_win32_get_system_text_quality`, each listed in the report), that the output compiles for win32 and win64, and that `LayoutMismatches()` is empty; then `tests\harness-cairo\` draws through the bindings on both architectures (image surface, paths, text, PNG round trip, a Win32 font face from a `LOGFONTW`, the script interpreter). `cairo-dwrite.h` stays out of scope (C++ only); its 5 functions are documented as hand-written declares.
- Rationale: a second, differently shaped library is the real test of D-053 and D-054; the libgit2 proof (D-032) is the model.
- Alternatives considered: keeping cairo outside the repo (`C:\GitHub\tbCairo`) as an ad-hoc check (no regression protection).

---
### D-056 — A path ending in a backslash breaks the quoted CastXML command line (Task 25.0 (new))
- Date: 2026-10-22
- Scope: Task-only
- Status: Active
- Context: found while preparing the cairo runs (D-052): a header folder given as `C:\inc\` is written into the `.cmd` script as `-I "C:\inc\"`. Under the Microsoft C runtime's argument rules a backslash before a quote escapes it, so the quote does not close and the rest of the command line becomes part of that argument; CastXML then reports "no input files". An uncommitted change in `CastXmlRunner.twin` (`NoTrailingSlash`, applied to `-I` folders) was already in the working tree without a task or decision. The user (2026-10-22): make it its own task, before 26.0.
- Decision: task 25.0 fixes it at the quoting layer: an argument-quoting helper that doubles the backslashes immediately before the closing quote (`"C:\inc\\"`, read back as `C:\inc\`), used for every argument tbBlob quotes for a program it runs (CastXML's `-I`, `-D`, `-o`, entry header; the import tool's paths). It replaces `NoTrailingSlash`, which left the drive root (`C:\`) and `-D` values broken. `Tools.Quote` stays as it is for `cmd /C` strings, whose parsing is cmd's, not the C runtime's.
- Rationale: the bug is in quoting, not in paths: the doubling rule is exact for every argument, including `C:\` and a define whose value ends in a backslash; trimming can change meaning (`C:\` → `C:`, the current folder on drive C).
- Alternatives considered: keep `NoTrailingSlash` (misses the root and `-D`); normalise every path with `FileSys.FullPath` (does not remove a trailing backslash and does not cover `-D`).

---
### D-057 — A header CastXML cannot read is skipped and reported, not fatal (Task 26a.0 (new))
- Date: 2026-10-22
- Scope: Plan
- Status: Active
- Context: the user (2026-10-22) asked what skipping `cairo-dwrite.h` (D-055) loses and asked that tbBlob continue and log when it cannot read a header. Observed with the first-release `dist\tbBlob\tbBlob.exe` on cairo 1.18.4: `--also cairo-pdf.h --also cairo-dwrite.h` fails the x86 pass (`cairo-dwrite.h:65:2: error: DWrite font backend requires C++`), exit 1, nothing written, not even `cairo.h`. CastXML's message names the top-level header: `In file included from <Work>\tbblob_entry.h:4`, and each line of `tbblob_entry.h` includes one header (D-033).
- Decision:
  - When a CastXML pass fails and its errors trace back (through the "In file included from" chain, outermost frame) to lines of `tbblob_entry.h` that include `--also` headers, tbBlob drops those headers and runs the passes again, until they succeed or the entry header itself fails. A failure in the entry header, or one that cannot be traced to a header, stays fatal (exit 1, as today).
  - The run then completes with exit 0; the console prints one `tbBlob: warning: skipped <header>: <first error line>` per skipped header; the report gets a "Headers skipped" section (each header, the architecture pass, and CastXML's error lines). `Work\` keeps the failing pass's output (`castxml_<arch>_failed.txt`).
  - A header skipped on one architecture is skipped on both (one source serves both, D-001).
  - Applies to the entry file mechanism only (`--also`); with no `--also` there is one header and nothing to skip.
- Rationale: one unreadable header (C++-only, a missing dependency, a configuration `#error`) should cost that header, not the run; the include chain makes the culprit certain, so nothing is guessed.
- Alternatives considered: checking each header alone before the real passes (one extra CastXML run per header on every run, ~doubles the time for libgit2+sys); parsing only the error's own file name (wrong when the error is in a header that a top-level header includes, e.g. `dwrite.h` itself); C++ mode (a different feature; D-059).

---
### D-058 — A pointer to a COM interface becomes `LongPtr /* IName */` (Task 27.0 (new))
- Date: 2026-10-22
- Scope: Plan
- Status: Active
- Context: the user (2026-10-22): twinBASIC can declare COM interfaces, but writing the `Interface` is a manual step after generation and not tbBlob's job; tbBlob should make those places easy to find, e.g. `As LongPtr /* ISomeComInterface */`. In C, the Windows SDK's MIDL-generated headers declare an interface as `typedef interface IFoo IFoo;` with `interface IFoo { CONST_VTBL struct IFooVtbl *lpVtbl; };` (`interface` is `struct` in C).
- Decision:
  - A struct whose only member is `lpVtbl`, a pointer to a struct named `<name>Vtbl`, is a COM interface. That is the exact MIDL C shape, like `DECLARE_HANDLE`'s (D-054). A pointer to it (parameter, return, field, delegate) is emitted `LongPtr /* <name> */`, e.g. `ByVal stream As LongPtr /* IStream */`; a pointer to a pointer (`IFoo **ppOut`) is `ByRef ... As LongPtr /* IFoo */`. The interface struct and its `Vtbl` struct are not imported.
  - An incomplete (opaque) struct whose name starts with `I` and an upper-case letter is not assumed to be COM: it stays an opaque alias (D-054); the alias name is already searchable.
  - Report: a "COM interfaces" section listing each interface and where it is used, with a note that `LongPtr` takes `ObjPtr(obj)` of a tB interface reference, and that the user may write the `Interface` and change the type by hand.
- Rationale: a COM interface pointer is one pointer whatever the interface, so `LongPtr` is exact; the comment keeps the interface's name, so a search finds every place a hand-written `Interface` could replace it. Generating `Interface` declarations from the Vtbl structs is possible but beyond tbBlob's scope (the user's call).
- Alternatives considered: importing the interface and Vtbl structs as `Type`s (exact layout, useless to call through); generating tB `Interface` blocks from the Vtbl (method order and signatures are there, but IIDs and inheritance need the C++/IDL view).

---
### D-059 — cairo-dwrite.h: 5 hand-written declares, documented and tested; no C++ mode (Tasks 29.0, 30.0)
- Date: 2026-10-22
- Scope: Plan
- Status: Active
- Context: `cairo-dwrite.h` (5 functions) needs C++ only because `dwrite.h` declares DirectWrite's interfaces as C++ classes; the functions are `extern "C"`, exported undecorated, and take COM interface pointers (`IDWriteFontFace*`, `IDWriteRenderingParams*`) and a C enum (`DWRITE_MEASURING_MODE`, `dcommon.h`, values 0..2). They matter only to programs that already hold DirectWrite objects (custom font collections, rendering params, GDI-compatible measuring). The user (2026-10-22) chose hand-written declares over a C shim header or C++ support.
- Decision: 29.0 passes `--also cairo-dwrite.h` on purpose, so the cairo run proves D-057 on a real header (reported as skipped with its `#error`; its 5 functions listed under "Exported but not declared"). `docs\USAGE.md` gives a ready-to-paste `cairo_dwrite.twin` with the 5 declares in D-058's style (`ByVal dwrite_font_face As LongPtr /* IDWriteFontFace */`) and the enum. The cairo harness (30.0) includes that file and checks it: `DWriteCreateFactory` → font file → `IDWriteFontFace`, `cairo_dwrite_font_face_create_for_dwrite_fontface`, set and get the measuring mode, draw text.
- Rationale: 5 functions do not justify C++ support; documenting and testing the declares makes the gap a paste, not a puzzle.
- Alternatives considered: a C shim header (must sit under the header folder to count as cairo's, i.e. inside the vcpkg tree); C++ support in tbBlob (classes, overloads, mangling: a separate feature).

---
### D-060 — Callback parameter names come from the compiler's preprocessed headers (Task: issue #1)
- Date: 2026-10-28
- Scope: Task-only
- Status: Active
- Context: GitHub issue #1: `WS_READ_CALLBACK` (webservices.h:2701) lost all its parameter names because one parameter is `_Out_writes_bytes_to_(maxSize, *actualSize) void* bytes`. D-022 read names from the raw header text, so every macro in a parameter list was a guess: a `(` was taken for a function-pointer declarator, and a parameter built by a macro (`TBF_PARAM(int, first)`) was reported lost. A first fix (skip `_identifier(...)`) only moved the guess to a naming convention; the user asked for something better than blind text parsing.
- Decision:
  - The x64 macro pass also runs `castxml -E -std=c11` (same flags, same vcvars call, `|| exit /b 1` between them) into `Work\preprocessed_x64.i`. `PreprocessedSource` maps CastXML's `file:line` to that text through its `# <line> "<file>"` markers; `DocComments.ParamNamesFor` reads the declaration there. The compiler has expanded every macro, so SAL annotations are gone and macro-built parameters are plain C; nothing is recognised by spelling.
  - A lone identifier after keywords (`const TBF_POINT *`, `struct X *`) is a type, not a name, only when CastXML's model has a typedef/struct/union/enum by that name (it was taken as the name before). MSVC pointer modifiers (`__ptr64`, `__unaligned`, ...) are keywords.
  - With no preprocessed text (`GenerateFrom(..., "", ...)`), or a declaration not found in it, names are argN and reported lost, saying why.
  - `-std=c11`: castxml's text-mode `-E` in its default C mode rejects `//` comments on the SDK's `#if` lines (sal.h, 20 errors on `<windows.h>`). CastXML's MSVC emulation still defines no `__STDC_VERSION__` (checked: an `#ifdef __STDC_VERSION__` branch is not taken in the XML pass nor in `-E -std=c11`), and the `-dM` dump is byte-identical with and without the flag.
- Rationale: the preprocessor already ran with the exact configuration of the XML pass; reading its output removes the whole class of macro guesses instead of adding a rule per macro family. One extra castxml run, no extra vcvars call (~7 s each). `tbf_macro_cb`, formerly the "cannot be parsed" example, is now recovered.
- Alternatives considered: skip identifiers starting with `_` followed by `(` (a naming convention, the first draft); expand macros from the `-dM` table in tbBlob (re-implements the preprocessor: `#`, `##`, rescanning — SAL needs all of them); a separate fifth pass (one more vcvars call); `-E -dD` in place of `-dM` (changes the input of the tested macro table).
- Verified under: CastXML 0.6.5 (clang 18.1.3), MSVC 14.44, Windows SDK 10.0.26100; the issue's typedef with `<windows.h>`'s real sal.h gives callbackState, bytes, maxSize, actualSize, asyncContext, error. `webservices.h` itself cannot be read by CastXML in C mode on either installed SDK (two `typedef enum {} ...;` — clang: "use of empty enum", no flag turns it off; the 0.6.20260105 snapshot fails earlier, in winioctl.h): a separate problem.

---
### D-061 — Known issue: CastXML (C mode) cannot read the SDK's webservices.h (Task: issue #1)
- Date: 2026-10-28
- Scope: Finding
- Status: Active
- Context: reproducing issue #1 (D-060) with `#include <webservices.h>` failed in the x86 XML pass, before any parameter-name code runs. The reporter's output came from a copy of the header (`C:\tbBlob\test\webservices.h`) whose line numbers match SDK 10.0.26100; how they got it through CastXML is not known.
- Decision: recorded as a known issue in `docs\USAGE.md` ("Known issues"); not fixed now (user, 2026-10-28). Observed: `webservices.h` has two unconditional `typedef enum { } ...;` (`WS_XML_BUFFER_PROPERTY_ID` line 695, `WS_SECURITY_ALGORITHM_PROPERTY_ID` line 1603). MSVC accepts an empty enum; clang rejects it in C ("use of empty enum") with no warning group to disable: `-fms-extensions`, `-fms-compatibility` and `-Wno-error=microsoft-empty-enum` (unknown to clang 18) all still fail.
- Rationale: the user chose to note it and return to the cairo work; tbBlob does not edit the SDK's headers.
- Alternatives considered (for a later fix): ask the reporter how they ran it; C++ mode for such headers (empty enums are valid C++; reopens D-059); a patched copy of the header (tbBlob editing Microsoft's header — advised against). D-057's header skip does not help when the entry header itself includes `webservices.h`.
- Verified under: CastXML 0.6.5 (clang 18.1.3) with `--castxml-cc-msvc-c cl` and vcvars32; SDK 10.0.22621 and 10.0.26100 (both have the two empty enums). CastXML 0.6.20260105 (clang 21.1.8) fails earlier, in `winioctl.h` (`use of undeclared label 'Cleanup'`).

---
### D-062 — D-053 as built: details settled while implementing task 26.0 (Task 26.0)
- Date: 2026-10-28
- Scope: Task-only
- Status: Active
- Context: implementing D-053 (`DllSet`, `--dll`, folders for `<dll>` and `--x86-dll`) raised points D-053 and 26.1 left open or got slightly wrong.
- Decision:
  - **Project name.** `--name` defaults to the DLL's name without extension; when `<dll>` is a folder that would be the folder's name (`win64`, `bin`), so the default is then the entry header's name (`cairo.h` → `cairo`, `tbfixture.h` → `tbfixture`). Applied after parsing (`CliOptions.ApplyDiskDefaults`), since `Parse` does not touch the disk.
  - **Loader.** One bound DLL: exactly D-027's text (proven byte-identical). Several: `Load(folder)` loads each in binding order with the same folder rule and **raises** (naming the DLL and the paths tried) when one cannot load, as D-027's does, instead of returning 0 as 26.1 said; `LoadFile` once per DLL; `IsLoaded()` True when all are loaded.
  - **Bare-name mode is unchanged.** The fixture's `.twin` output is byte-identical to a snapshot taken before the change (`tests\testdata\emitter-bare\`), including D-031's x86 `NOTE` for a function the `--x86-dll` does not export. The report gains a "DLLs" section saying the name was not checked.
  - **libgit2 is not byte-identical** (26.3(c) expected it to be): with the `bin` folders, the 9 header functions `git2.dll` does not export (D-031's 2 from `git2.h`, and 7 from `git2/sys`) get no declare instead of a declare with a `NOTE`; every other line is identical (checked against the previous bindings), and "Exported but not declared" lists `git_config_unlock` and `git_odb__backend_loose`. 960 → 951 functions. The fixture harness's D-031 check (calling `tbf_not_exported` raises) became a report check: the function has no declare.
  - **`--keep-unexported`** (the user, 2026-10-28: "can one opt to force to include no-export DLL?"). A function no DLL exports is declared anyway instead of skipped: bound to the DLL most of its header's other functions bind to, else the only DLL read, else still skipped with the report naming `--dll`. The emitter binds every function before emitting, so the choice does not depend on declaration order. The declare gets `' NOTE: not exported by <dll> (declared because of --keep-unexported): a call fails at run time unless the DLL loaded then exports it` and stays under "Declared but not exported". An explicit `--dll <f>=<dll>` to a DLL that does not export `<f>` binds it the same way (it did silently before), with `--dll` named in the note. Bare-name mode is unaffected. Use: a DLL that exports more at run time than the one generated against, or exports by ordinal only.
  - The DLLs are read before CastXML runs (a mistake there fails at once). A `.dll` that is not a PE file, or a folder without DLLs, fails the run (exit 1) naming it; a missing `--x86-dll` exits 3 in `MainModule`.
  - Tests: the `--dll` / `--x86-dll` command-line tests live in `Tests_Dlls` with the rest of the task's tests, not in `Tests_Cli`. Method: not red-first — `DllSet`, the emitter/pipeline signatures and the tests were written together and compiled once; the bare-name snapshot test pins the old behaviour.
- Rationale: an entry header names a library better than a folder does; raising matches the existing loader and the harness's checks; skipping an unexported function is D-053's point, and the libgit2 diff shows it removes exactly the declares that could never be called.
- Alternatives considered: `--name` required with a folder (needless when the entry header names the library); a multi-DLL `Load` returning 0 on failure (silently half-loaded); keeping a `NOTE`ed declare for unexported functions in folder mode (a call that cannot work).

---
### D-063 — D-057 as built: details settled while implementing task 26a.0 (Task 26a.0)
- Date: 2026-10-28
- Scope: Task-only
- Status: Active
- Context: implementing D-057 against CastXML's real output (`tests\fixture-c\tbfixture_cpp.h` `#error`s unless C++, `tbfixture_missing.h` includes a header that does not exist).
- Decision:
  - **All or nothing per failed pass.** Headers are skipped only when every `error:` / `fatal error:` line traces, through the outermost `In file included from <...>\tbblob_entry.h:<n>:` frame, to an `--also` header. One error that traces nowhere (in `tbblob_entry.h` itself, a CastXML error with no file, a diagnostic with no frame) or to the entry header keeps the failure fatal, as before: skipping headers would not explain it. Warnings never count.
  - **Omitted include stacks.** clang prints a diagnostic's include stack only when it differs from the previous diagnostic's; a diagnostic with no frames in the same file as the previous one inherits its stack (a second `error:` in the same skipped header traces there too).
  - **Observed:** a missing include is a `fatal error`, but clang had already reported the earlier `#error` header, so both headers were skipped in one retry. Each retry drops at least one header, so the loop ends.
  - **Observed (the user asked whether errors are local to a file):** clang recovers and keeps parsing after an ordinary error (a header with valid declarations around `typedef enum {} X;` and `int x = ;` reported both errors), but CastXML then writes **no XML at all** (exit 1, no `-o` file): one error anywhere in the translation unit, even inside an SDK header, loses the whole pass. A fatal error (missing include) stops parsing, and clang lists at most 20 errors, so a retry can surface errors the first run did not show. Dropping a whole `--also` header is therefore the finest unit tbBlob can skip without editing headers. With `--also mylib_ws.h` including `<webservices.h>` (D-061), the run succeeds and reports `mylib_ws.h` with both `webservices.h:695:1` / `:1603:1: error: use of empty enum` lines.
  - The failed pass's output goes to `Work\castxml_<pass>_failed.txt` (`<pass>` is `x86`, `x64`, `macros_x86` or `macros_x64`), appended when a later retry fails in the same pass. The report section is first in the report ("Headers skipped"), and is `- none` when nothing was skipped.
  - Method: not red-first. `FailingHeaders`/`ErrorLinesFor` and their tests were written together against captured CastXML output and compiled once.
- Rationale: a run that succeeds must have failed only because of the headers it dropped; anything else is a problem the user has to see.
- Alternatives considered: skipping the traced headers and ignoring the untraced errors (the retry would fail anyway, with a less clear message).

---
### D-064 — Module-qualified Types work everywhere; a Public Alias is project-wide and cannot be module-qualified (Task: Spike)
- Date: 2026-10-28
- Scope: Finding
- Status: Active
- Context: SPIKE-11, before tasks 27.0/28.0 (D-054). Probe: `spikes\qualified-types\` — header-named modules `wingdi` (`Public Type tagLOGFONTW`, 92 bytes) and `windef` (`HDC`); `local_a.SAMENAME` (8 bytes) shadowing `SAMENAME` (4 bytes) of a local package `ShadowPkg` (module `pkgtypes`); `dup1.TWICE` (4) and `dup2.TWICE` (16); `LenB` shows which Type a name resolved to; compile-only variants for forms that might fail (`results\variants.txt`).
- Decision (observed):
  - **(1) Types: yes.** `wingdi.tagLOGFONTW` works as a `Declare` `ByRef` parameter (gdi32 `GetObjectW` filled it: face "MS Shell Dlg"; `RtlMoveMemory` with two), a tB function's return type, a `Type` field, a `Public Alias` target, and in a `Delegate` signature (called through `AddressOf`). 23/23 checks PASS on win32 and win64; the `Type` holding both kinds of field is 108 / 120 bytes, as C lays it out.
  - **(1) Aliases: no, not by module.** `Public Alias` inside a `Module` is a syntax error (TB5182): aliases are file-scope only (tbBlob already writes them there, D-025). `windef.HDC` does not compile (TB5079 unrecognised datatype); the project name qualifies it: `qualprobe.HDC` works. **Two files declaring the same alias name** (`Public Alias HDC As LongPtr` twice, same target) fail at every use, qualified or not (TB5137 "'HDC' is ambiguous ... qualprobe.HDC, qualprobe.HDC").
  - **(2)** A local `Type` shadows a package's: unqualified `SAMENAME` is the local one (8); `local_a.SAMENAME` and `qualprobe.SAMENAME` give the local one; `pkgtypes.SAMENAME`, `ShadowPkg.pkgtypes.SAMENAME` and `ShadowPkg.SAMENAME` give the package's (4); a Type only the package defines works unqualified.
  - **(3)** Two local modules defining the same `Type` name compile; qualified uses resolve correctly (4 vs 16); an **unqualified use is a compile error** (TB5137 "'TWICE' is ambiguous. Could be: qualprobe.dup1.TWICE, qualprobe.dup2.TWICE").
  - **(4)** All of the above holds in `Delegate` signatures.
  - Also: a `Type` named like a module (`VariantUse.windef` next to module `windef`) compiles, with warning TB0033.
  - **Follow-up (the user, 2026-10-28): a handle as a one-field `Type`** (`winhandles.HDC_T` with `Value As LongPtr`) instead of an alias. It works at the ABI level: returned by `GetDC`, passed `ByVal` to `GetDeviceCaps` (96 dpi, the same answer as through the alias), through a `Delegate` by value, a zeroed one passes NULL, `ReleaseDC` = 1; `LenB` = pointer size (29/29 on win32 and win64). What no longer compiles: `If t = 0` (TB5026/TB5028), passing `0` or `vbNullPtr` (TB5001 cannot coerce to `HDC_T`), and assigning a `LongPtr` to it or it to a `LongPtr` (TB5028/TB5001), so every comparison, NULL and hand-over to or from other code goes through `.Value`.
  - **Follow-up: a `Private Alias` cannot back anything.** At file scope it is not visible even in its own file: not from a module there (TB5079 in both files of a pair that each declare `Private Alias PH`), not from a `Public Alias` there, and not as the field type of a public module `Type` (TB5079). Inside a `Module` it is a syntax error (TB5182), like `Public Alias`. A file-scope `Public Type` is a syntax error too (Types live in modules). A file-scope `Private Alias HDC` in one file next to `Public Alias HDC` in another compiles (the public one is used).
- Verified under: twinBASIC BETA 1011 (v0.15.1011), built with tblaunch (no IDE) for win32 and win64, local package referenced with `isLocalPackage` under `Packages\ShadowPkg\`; Windows 11, gdi32/user32/kernel32.

---
### D-065 — Outside types revised by SPIKE-11: aliases are project-wide names; same-name Types are always qualified (Task 27.0, 28.0)
- Date: 2026-10-28
- Scope: Plan
- Status: Active
- Supersedes: D-054 (partial: the `--qualify-outside` spelling of aliases, and name clashes between generated modules)
- Context: D-064. D-054 assumed every outside name could be written module-qualified (`windef.HDC`) and that clashes only matter against packages.
- Decision:
  - **Outside `Type`s** (structs, unions, enums) stay as D-054 says: header-named modules, and `--qualify-outside` writes them `<module>.<Type>`.
  - **Every alias is a project-wide name** (handle aliases like `HDC`, opaque and `FILE` aliases, pointer typedefs, and the library's own type aliases, D-025). tbBlob declares each alias name once in the whole project, at file scope of the module of the header that first declares it; `--qualify-outside` leaves aliases unqualified. An outside alias whose name another generated alias or Type already has is renamed through the name table and reported, like any other collision (D-011).
  - **A `Type` name that more than one generated module defines** (two headers with the same struct name) is written module-qualified at **every** use, with or without `--qualify-outside`: unqualified it does not compile. The report lists such names.
  - Package clashes need nothing: a local `Type` shadows a package's (D-064 (2)), and the package's stays reachable as `<package>.<Type>`.
  - A `Type` named like a module is allowed (warning TB0033 only).
  - 27.0 and 28.0 get their sub-tasks with these rules.
- Rationale: generated code must compile; the spike shows which spellings tB accepts, so tbBlob uses those and never emits the two that fail (a module-qualified alias, an ambiguous unqualified Type).
- Alternatives considered: emitting outside aliases as one-field `Type`s so they can be module-qualified (changes how handles pass: a `Type` goes `ByRef`, a handle must go by value); qualifying aliases with the project name (the project name is the user's `--name`, and unqualified aliases are already unique once each is declared once).

---
### D-066 — Outside types as built: one walk, alias kinds from typedefs, integration tests instead of snapshots (Task 27.0)
- Date: 2026-10-28
- Scope: Task-only
- Status: Superseded (partial) by D-067
- Context: implementing D-054/D-058 under D-065's rules.
- Decision:
  - `TypeMapper.OutsideTypes()` walks the library's functions, record fields and typedefs once (then each imported struct's fields), each element once, each outside name once. The name table, the emitter, `FindRecord` (x86 twins) and `Disagreements` all use it; each architecture's mapper walks its own model.
  - Alias kinds are decided on the outside **typedef**: a typedef to a pointer to a struct/union is a `handle` (`DECLARE_HANDLE` and pointer typedefs alike; the struct is imported when complete and not `struct X__ { int unused; }`); `FILE` (standard list) is `opaque`, like an incomplete struct; `Classify` returns these kinds, so `MapParam`/`ReturnOf`/`FieldType` need only small additions. A COM interface is decided on the struct (`lpVtbl` only, pointing to `<name>Vtbl`).
  - A `Type` name in two generated modules cannot come from one translation unit (C struct tags are unique), so no automatic qualification is written; D-065's rule stays for `--qualify-outside` (28.0).
  - An outside module's header comment uses the header's last two path parts (`shared/windef.h`), so generated files carry no machine path.
  - The unit tests 27.2 asked for are integration tests (`Tests_Outside`, one cached CastXML run): with `<windows.h>` and `<objidl.h>` the XML is ~8 MB per architecture, too big to commit as snapshots.
  - Observed while checking: `tblaunch compile` on a bare source folder reports `RtlMoveMemory` unrecognised inside union accessors' `Type`-level `Private Declare`, for the unchanged pre-26.0 snapshot too; a real project build (the harness) compiles it. Not a tbBlob problem.
- Rationale: one walk keeps emission, names and checks consistent; the typedef is where C says "this is a pointer", so the alias decision lives there.
- Alternatives considered: committing the 16 MB of SDK snapshots; deciding handles by struct name patterns (D-054 rejected guessing).

---
### D-067 — Union accessors copy with tB's native vbaCopyBytes, not a RtlMoveMemory Declare (Task 28.0)
- Date: 2026-10-28
- Scope: Task-only
- Status: Active
- Supersedes: D-066 (partial: its "Observed" bullet blaming a tblaunch bare-folder quirk is wrong)
- Context: proving 28.3 (the `--qualify-outside --pointer` generation compiles), a project built only from generated modules failed, in a bare-folder compile and in a real `.twinproj` build alike: `TB5079 Unrecognized symbol 'RtlMoveMemory'` in every union accessor. Since D-018 the emitter wrote `Private Declare PtrSafe Sub RtlMoveMemory` inside each union's `Type`, and tB does not make it visible to that Type's own property procedures. The fixture harness compiled only because its `Utf8.twin` declares a `Public RtlMoveMemory`, which the accessors bound to; libgit2 has no union accessors. Any user project binding a library with unions failed to compile. The user (2026-10-28) asked whether a native tB API should replace `RtlMoveMemory` (docs.twinbasic.com, tB/Modules/HiddenModule).
- Decision: the accessors call tB's native `vbaCopyBytes length, dest, src` (`vbaCopyBytes LenB(v), VarPtr(v), VarPtr(Me.union_data(0)) + 0`, and the reverse for `Let`); no `Declare` is emitted at all. The bare-name snapshot (`tests\testdata\emitter-bare\`) and `Tests_Emitter` follow. tbBlob's own `Console.twin` still uses `RtlMoveMemory`; making it consistent is a separate commit after 28.0 (the user).
- Rationale: a native intrinsic needs no declaration, so there is nothing to scope wrongly and nothing a test helper can mask.
- Alternatives considered: one module-level `Private Declare RtlMoveMemory` per module with unions (compiles; built and tested first, then dropped for the native call); renaming the harness helper so it cannot mask (unnecessary once generated code declares nothing).
- Verified under: tB BETA 1011, tblaunch builds for win32 and win64: the `--qualify-outside --pointer LOGFONTW` generation of the fixture (with `tbfixture_sys.h`, `tbfixture_ext.h`, `tbfixture_win.h`) builds untouched in a project with no `RtlMoveMemory` anywhere; the fixture harness's union checks (group 10: tagged and anonymous unions, the byte accessor) pass at run time on both, 205/205.

---
### D-068 — Gaps cairo showed: outside callback typedefs become delegates; anonymous struct types are named after their field (Task 29.0)
- Date: 2026-10-29
- Scope: Task-only
- Status: Active
- Context: the first full cairo generation (29.4) compiled with two kinds of errors. (1) FreeType's structs have callback fields (`FT_Alloc_Func`, `FT_Free_Func`, `FT_Stream_IoFunc`, `FT_Generic_Finalizer`, ...): outside function-pointer typedefs were classified as delegates but never emitted (only the library's typedefs were) -- D-052's dangling-name defect in another form. (2) `cairo_path_data_t` is a union whose members `header` and `point` have anonymous struct types: the accessors were written `As ` with no type, since an anonymous record had no name. libgit2 and tbfixture had neither shape.
- Decision:
  - An outside typedef of a pointer to a function is an outside type of kind `delegate`: emitted as a `Delegate` in its header's module, through the same code as library delegates (`EmitDelegateTypedef`), and registered as a project-wide name.
  - An anonymous struct or union that is the type of a named field is a record named `<parent>_<field>` (`_cairo_path_data_t_header`; nested ones chain), from library records and imported outside structs alike (`TypeMapper.RecordName`, `AnonRecords`): emitted as a `Type`, layout-checked, registered, found by `FindRecord` for its x86 twin and compared in the x86/x64 check. Unnamed members keep D-018's handling (anonymous unions as storage; anonymous structs reported).
  - Fixture: `outlib.h` gains `OUT_HOOK_FN` (a callback typedef) in `OUT_HOOKS` and `OUT_PATH_DATA` (a union of two anonymous structs, cairo's shape), used by `tbw_call_hook`, `tbw_make_path_header`, `tbw_path_point_sum`; harness group 21 calls them on win32 and win64 (a tB `CDecl` function as the outside delegate field, called by C; the anonymous struct read and written through the union accessors).
- Rationale: both are generic C shapes, not cairo quirks; a name derived from the field is deterministic and readable, and matches how D-018 already names union storage.
- Alternatives considered: `LongPtr` for outside callback fields (loses the signature tB checks `AddressOf` against); numbering anonymous records (`anon_1`) (not stable across header changes, not readable).
