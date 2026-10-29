# spikes\

Throwaway probes. A spike tests one falsifiable claim against the real system (twinBASIC, CastXML,
a DLL) **before** any production code relies on it. The code here is disposable and not maintained;
what matters is the recorded finding.

- The claims and their status: [tasks\spikes-castxml-ffi-generator.md](../tasks/spikes-castxml-ffi-generator.md)
- The findings, with the exact conditions each was verified under:
  [tasks\decisions-castxml-ffi-generator.md](../tasks/decisions-castxml-ffi-generator.md) (`Scope: Finding` entries)

Later code and docs cite the decision ID (for example "D-003"), not the spike code.

## castxml-ffi-generator\ — SPIKE-1 to SPIKE-9

Run before any of tbBlob was written: could CastXML output be turned into twinBASIC that compiles and
runs against libgit2 on both architectures? A Python prototype generator (`gen_probe.py`, report in
`gen_report.md`) produced bindings for all of libgit2. A hand-written tB project (`handwritten\`)
then called them and recorded results (`results\results-win32.txt`, `results-win64.txt`).
`run_castxml.ps1` regenerates the CastXML input; `setup_fixture.ps1` creates the test repositories.

| Spike | Claim (short) | Finding |
|---|---|---|
| SPIKE-1 | tB `Type` layout equals C natural alignment for all 85 libgit2 structs | D-001 |
| SPIKE-2 | `CDecl` delegates work as nested struct fields and as parameters | D-002 |
| SPIKE-3 | The pointer mapping rule; `vbNullPtr`; `CType(Of T)`; opaque aliases interchange | D-003 |
| SPIKE-4 | UTF-8 `const char*` round-trips through `ByVal LongPtr`, non-ASCII included | D-004 |
| SPIKE-5 | Scalar map: `LongLong` fields, 4-byte enums, top-bit hex constants | D-005 |
| SPIKE-6 | `ByVal ParamArray args As Any()` calls C variadics | D-006 |
| SPIKE-7 | Keyword-named fields compile; case collisions need renames; declare `Alias` works | D-007 |
| SPIKE-8 | A generated folder imports and compiles; preloading the DLL makes `Lib` bind | D-008 |
| SPIKE-9 | tB can run CastXML under `vcvars` and capture its output and exit code | D-009 |

All nine held, and tbBlob was built on them (task list tasks 1.0–10.0). Python was used only for the
prototype; tbBlob is pure twinBASIC.

## threads\ — SPIKE-10

Before tasks 18.0 and 19.0 (D-044): do tB callbacks work when a C library calls them from a thread
it created itself? `threadprobe.c` is a small DLL that calls back from `CreateThread` threads, one
at a time and four at once. The tB probe (`Sources\Probe.twin`) checks arguments, return values,
strings, objects, local error handling, shared counters, COM, and an unhandled error. `build.ps1`
builds the DLL for both architectures and imports the probe project.

Finding: **D-045**, corrected by **D-046**. Callbacks work on both architectures. Unsynchronised
shared state loses updates. COM needs `CoInitializeEx` on that thread. An unhandled error returns 0
to C and shows a modal "Run-time error" box. This became the "Callbacks on the library's own
threads" guidance in [docs\USAGE.md](../docs/USAGE.md) and the thread checks in the fixture harness.

## qualified-types\ — SPIKE-11

Before tasks 27.0 and 28.0 (D-054): can generated code name an outside type through a header-named
module (`wingdi.tagLOGFONTW`), and how do same-named types resolve between local modules and a
referenced package? A tB console probe (`Sources\`) with a tiny local package (`package\ShadowPkg\`)
checks each form with `LenB` and real Win32 calls (`GetDC`, `GetObjectW`) on both architectures
(`results\results-<arch>.txt`). Forms that might not compile are in `variants\`: `build-project.ps1`
compiles each one added to the probe and writes what the compiler said to `results\variants.txt`.
The probe is built and run with tblaunch, without the IDE.

Finding: **D-064**, which led to **D-065** (a partial revision of D-054). Module-qualified `Type`
names work everywhere, and a local `Type` shadows a package's. But a `Public Alias` is file-scope and
project-wide: it can't be module-qualified, and two declarations of one alias name don't compile. A
`Type` name defined in two modules must be qualified at every use.

## Running one again

Each folder's scripts regenerate their own outputs; those outputs are gitignored. A spike needs the
same tools as the tests (see [tests\README.md](../tests/README.md#what-it-needs)). The Python
prototype also needs Python 3. Spikes are not part of `run-all.ps1`.
