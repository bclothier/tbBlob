> **Agent resume protocol:** same as other task lists — work top-to-bottom, one unchecked `[ ]` item at a time, mark `[x]` immediately, ask before continuing. Re-read this file and the decision log before resuming after a break or compaction.

## Spikes for castxml-ffi-generator

PRD: `tasks/prd-castxml-ffi-generator.md` §7.5. Decision log: `tasks/decisions-castxml-ffi-generator.md`.

**How these spikes run.** Each tB compile is manual, so SPIKE-1 to SPIKE-9 share **one probe project**: `spikes/castxml-ffi-generator/probe.twinproj`. Its bindings are produced by a throwaway Python prototype (`gen_probe.py`) from CastXML output, and its hand-written `Tests.twin` holds the runtime probes. The user compiles and runs it once as **win32** and once as **win64**. Each run writes `spikes/castxml-ffi-generator/results/results-<arch>.txt` (one `PASS|FAIL|INFO <spike>.<check> ...` line per check, flushed line by line so a crash still shows the last step). Compile errors are also evidence: the user pastes the IDE error list. Each spike below is still logged and committed separately.

**Commit deviation (approved 2026-10-16):** SPIKE-1..9 were committed as **one** combined commit, `SPIKE: CastXML FFI probe for libgit2 on win32/win64 (D-001..D-009)`, because all nine findings came from one probe project, one pair of runs and one decision-log edit.

Setup (shared, done once before the first run):
- [x] SETUP: `git init` (needs user sign-off), `.gitignore` for vcpkg trees, build output, XML and DLL copies.
- [x] SETUP: `run_castxml.ps1` regenerates `xml/git2_x86.xml`, `xml/git2_x64.xml`, `xml/git2_macros.txt`; `setup_fixture.ps1` copies the libgit2 DLL sets to `bin/win32`, `bin/win64` and creates the fixture repo (`fixture/repo`, `fixture/repo.git`) with fixed author/date.
- [x] SETUP: `gen_probe.py` writes `probe/` (Settings + Sources); `tBImportExport_win64.exe import probe.twinproj probe --overwrite` builds the project.
- [x] SETUP: user compiles + runs as win32 and win64 and reports the IDE error list (if any) and that the results files exist.

- [x] SPIKE-1: tB `Type`s generated with C-natural field mapping have exactly CastXML's `LenB` and field offsets for all 85 libgit2 structs, on win32 and win64.
  - [x] Write throwaway probing script: `spikes/castxml-ffi-generator/gen_probe.py` (emits Types + `Layout.twin` expected-value checks).
  - [x] Run it against the real system/service (manual compile + run, both archs).
  - [x] Log the finding in `decisions-castxml-ffi-generator.md` (`Scope: Finding`, `Task: Spike`), including `Verified under`.
  - [x] COMMIT — propose `SPIKE: tB UDT layout matches C natural alignment on win32/win64`, get sign-off. Then, in order: (a) check off this line, (b) stage the probing script + decision log update + this checkbox flip together, (c) `git commit`. Do not commit first and check this box in afterward, and do not record the resulting commit hash anywhere in this file — `git log` is the source of truth for that.
- [x] SPIKE-2: `CDecl` delegates work as nested `Type` fields (`git_clone_options.checkout_opts.progress_cb`, `.fetch_opts.callbacks.transfer_progress`) and as a declare parameter (`git_reference_foreach_name`): libgit2 calls them with sensible values, on both archs.
  - [x] Write throwaway probing script: `spikes/castxml-ffi-generator/probe/Sources/Tests.twin` (`Spike2_*`).
  - [x] Run it against the real system/service.
  - [x] Log the finding (`Scope: Finding`, `Task: Spike`), including `Verified under`.
  - [x] COMMIT — propose `SPIKE: CDecl delegates as UDT fields and declare params`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-3: The pointer rule works: struct* → `ByRef As T`; opaque `T*` → `ByVal As alias`; `T**` → `ByRef As alias`; scalar* → `ByRef As scalar`; `char*`/`void*`/other → `ByVal As LongPtr`; NULL via `ByVal vbNullPtr`; returned struct pointer read with `CType(Of T)`; two different opaque aliases of `LongPtr` are interchangeable (`git_object` → `git_commit`).
  - [x] Write throwaway probing script: `Tests.twin` (`Spike3_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: pointer parameter/return mapping rules`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-4: UTF-8 strings pass correctly as `ByVal LongPtr`: a non-ASCII clone path round-trips through `git_clone` / `git_repository_path`, and a non-ASCII author name reads back from `git_signature.name`.
  - [x] Write throwaway probing script: `Tests.twin` (`Spike4_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: UTF-8 const char* round-trip via LongPtr`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-5: The scalar map holds at runtime: `git_time.time` (`LongLong`, 8-byte aligned on win32), `offset`, `sign` read correctly from a known commit; `Enum`-typed fields are 4 bytes; a top-bit constant written as `&H80000000&` compiles and equals `-2147483648`.
  - [x] Write throwaway probing script: `Tests.twin` (`Spike5_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: scalar type mapping and top-bit constants`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-6: `ByVal ParamArray args As Any()` on a `CDecl` declare calls C variadics correctly on both archs: `git_libgit2_opts` set/get round-trip (`size_t` by value, `size_t*` out), and msvcrt `_snprintf` with `Long`, `LongLong`, `Double`, string pointer, `LongPtr`; a plain variable in the variadic part is passed by address (#671).
  - [x] Write throwaway probing script: `Tests.twin` (`Spike6_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: variadic CDecl declares via ByVal ParamArray`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-7: Naming: unescaped C field/parameter names that are tB keywords (`type`, `local`, `free`, `close`, `len`, `lock`, `name`, `to`, `version`, `option`, `object`, ...) compile; which ones (if any) need `[ ]`; a renamed declare with `Alias "git_repository_open_bare"` resolves and runs.
  - [x] Write throwaway probing script: `gen_probe.py` naming pass + `Tests.twin` (`Spike7_*`).
  - [x] Run it (compile error list is the main evidence).
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: identifier naming, keyword escaping and declare Alias`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-8: Project shape: a minimal generated `Settings` + `Sources` folder imports with `tBImportExport_win64.exe` and opens/compiles in the IDE; bindings as included sources (one module per header, aliases at file scope) compile; pre-loading the arch-specific `git2.dll` with `LoadLibraryExW(..., LOAD_WITH_ALTERED_SEARCH_PATH)` makes `Lib "git2.dll"` bind, on both archs. (Package/`.twinpack` shape is not tested here — see note.)
  - [x] Write throwaway probing script: `gen_probe.py` (Settings, module layout) + `Tests.twin` (`Spike8_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: generated project shape and DLL loading`, get sign-off. Then (a) check off, (b) stage together, (c) commit.
- [x] SPIKE-9: tB code can run `cmd /c "<vcvars64.bat>" >nul && "<castxml.exe>" --version` through `WScript.Shell.Exec`, and capture its stdout and exit code.
  - [x] Write throwaway probing script: `Tests.twin` (`Spike9_*`).
  - [x] Run it.
  - [x] Log the finding, including `Verified under`.
  - [x] COMMIT — propose `SPIKE: running castxml from tB via WScript.Shell`, get sign-off. Then (a) check off, (b) stage together, (c) commit.

Note on packages: if SPIKE-8 passes with included sources, the package shape is only needed if the user wants generated bindings distributed as a `.twinpack`. That would be a separate SPIKE-10 (requires extra manual IDE steps: build package, add reference) — ask before adding it.

## Once every spike above is checked off

Hand off to `generate-tasks`. Each affected parent task's "Define the surface" step should cite the relevant finding's decision ID directly, rather than re-deriving the assumption.

## SPIKE-10 (added 2026-10-17, D-044): callbacks on threads the library creates

Separate throwaway probe in `spikes/threads/`: a tiny C DLL (`threadprobe.c`, built x86 + x64 by `build.ps1`) and a hand-written tB console probe (`threadprobe.twinproj`, compiled by the user as win32 and win64). Results go to `spikes/threads/results/results-<arch>.txt`, flushed per line; the risky steps run last, in a separate invocation, so a crash cannot hide the earlier results.

- [x] SPIKE-10: A tB `CDecl` callback invoked by C from a thread the C code created (`CreateThread`) runs correctly on win32 and win64: it reads its arguments and returns a value, runs on a different OS thread from `Main`, updates a module variable, builds a `String`, creates and uses a `New Collection`, and handles an error locally with `On Error`. Under 4 concurrent threads × 10,000 calls, `InterlockedIncrement` on a module `Long` counts exactly, while a plain `+= 1` may lose counts. Separately recorded (not assumed): what an *unhandled* `Err.Raise` inside such a callback does, and whether `CreateObject` works there without `CoInitializeEx`.
  - [x] Write throwaway probing code: `spikes/threads/threadprobe.c`, `build.ps1`, `Settings`, `Sources/*.twin`, `build-project.ps1`
  - [x] Run it against the real system: user compiles win32 + win64; run both, normal and risky steps.
  - [x] Log the finding in `decisions-castxml-ffi-generator.md` (`Scope: Finding`, `Task: Spike`), including `Verified under`.
  - [x] COMMIT — propose `SPIKE: tB callbacks on library-created threads (D-0xx)`, get sign-off. Then, in order: (a) check off this line, (b) stage the probing code + decision log update + this checkbox flip together, (c) `git commit`.
## SPIKE-11 (added 2026-10-22, D-054): module-qualified type names and same-name types

Separate throwaway probe in `spikes/qualified-types/`: a hand-written tB console project (`Settings`, `Sources/*.twin`, `build-project.ps1`) plus a tiny tB package (or the smallest referenced package that defines a `Type`) to shadow. The user compiles it as win32 and win64 and pastes the IDE error list if any; results go to `spikes/qualified-types/results/results-<arch>.txt`, one `PASS|FAIL|INFO` line per check.

- [ ] SPIKE-11: In tB, (1) a `Public Type` declared in module `wingdi` can be written `wingdi.tagLOGFONTW` as a `Declare` parameter (`ByRef`), a function return, a `Type` field and a `Public Alias` target, and a `Public Alias HDC As LongPtr` in module `windef` can be written `windef.HDC` the same ways; (2) when a referenced package and a local module both define a `Type` of the same name, the unqualified name resolves to the local one, and the module-qualified name selects either; (3) two local modules defining the same `Type` name compile, and qualified uses resolve to the right one (`LenB` differs to prove it); (4) the same holds inside `Delegate` signatures. Compile errors are evidence: record which form fails.
  - [ ] Write throwaway probing code: `spikes/qualified-types/` (project source, package, `build-project.ps1`).
  - [ ] Run it against the real system: user compiles win32 + win64; run both.
  - [ ] Log the finding in `decisions-castxml-ffi-generator.md` (`Scope: Finding`, `Task: Spike`), including `Verified under`; if a form does not work, a `Plan` entry revises D-054 before 27.0's sub-tasks are generated.
  - [ ] COMMIT — propose `SPIKE: module-qualified and same-name types in tB (D-0xx)`, get sign-off. Then, in order: (a) check off this line, (b) stage the probing code + decision log update + this checkbox flip together, (c) `git commit`.
