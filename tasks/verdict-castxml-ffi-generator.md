# Verdict: CastXML-driven FFI generation for twinBASIC (tbBlob)

**The approach works.** tbBlob runs CastXML on a folder of C headers and generates twinBASIC
bindings. It did this for all of libgit2 1.9.1, including its advanced `git2/sys` API, with no hand
edits. The bindings compile as win32 and win64, every generated struct has the same memory layout as
in C on both architectures, and a separate tB program using only those bindings runs a real git
workflow and a clone with callbacks. All nine success metrics in the PRD (§8) pass.

The approach does have limits. They are C constructs that twinBASIC can't express, or that
generation can only report and not fix. Each one is listed below with its workaround, and tbBlob
reports every instance in `report.md`, so nothing is lost silently.

Environment: twinBASIC BETA 983, MSVC 14.44 (VS 2022), CastXML 0.6.5, libgit2 1.9.1 (vcpkg x86 and
x64), Windows 11. First reached 2026-10-16 (task 13.0); updated 2026-10-17 after tasks 14.0–22.0,
with the metrics recomputed by `tests\verdict.ps1` (same verdict; only metric 9's count grew, from the
thread and memory checks of tasks 18.0 and 19.0).

## The metrics (PRD §8)

Computed by `tests\verdict.ps1` from the artifacts themselves: harness EXEs and results, the DLL's
export table, CastXML's XML, and a fresh regeneration.

| # | Metric | Result | Evidence |
|---|---|---|---|
| 1 | Generated libgit2 bindings compile (win32, win64) | PASS | the harness EXEs were built from the current bindings, on both architectures |
| 2 | Layout self-check: 0 mismatches (win32, win64) | PASS | all 108 generated Types match CastXML's sizes and offsets on both architectures |
| 3 | Local git scenario incl. a variadic call (win32, win64) | PASS | 116 checks passed: errors, variadic options, init / stage / commit / revwalk / branch / diff, shutdown |
| 4 | Clone with checkout and transfer callbacks (win32, win64) | PASS | 26 checks passed (`file://` clone, both callbacks with their payloads) |
| 5 | Coverage: every export generated, or listed with a reason | PASS | 960 functions generated; 951 of `git2.dll`'s 953 exports covered; the other 2 are in no public header; 9 header functions the DLL doesn't export are listed in the report |
| 6 | Doc comments for every item that has one | PASS | 1363 of 1363 commented header items carry their doc |
| 7 | No hand edits to generated code | PASS | a fresh regeneration is byte-identical to the bindings and to the copies the harnesses compiled |
| 8 | Report: every skip, rename and loss listed with a reason | PASS | 212 entries, each with a reason |
| 9 | Synthetic library: every construct passes or is reported unsupported | PASS | 368 checks passed (win32 + win64); one construct reported unsupported: `__declspec(align(n))` |

**Verdict: works.**

## What was generated

libgit2 1.9.1, from `git2.h` plus every `git2/sys/*.h`:

| | |
|---|---|
| Modules (one per header) | 89 |
| Functions | 960 |
| Types / enums / enum values | 108 / 91 / 602 |
| Callback delegates | 164 (96 synthesized for unnamed function-pointer fields) |
| Opaque handle aliases / typedef aliases | 56 / 21 |
| Constants from macros | 248 (178 macros that can't be constants are skipped, each with a reason) |
| Generation time | about 36 seconds on a 2-core machine: about 30 s for the four CastXML passes, about 5 s tbBlob's own work (was about 2 minutes before tasks 16.0–17.0; D-042) |

Generality (PRD goal 5): the generator contains no libgit2-specific code. The same build generates
the synthetic `tbfixture` library, which holds every construct tbBlob is expected to handle, and
takes any header folder (`tbBlob <header folder> <entry header> <dll> <output folder>`).

## A second real library: cairo

cairo 1.18.4 (vcpkg, tasks 29.0–30.0, D-055) was generated in one run from `cairo.h` plus its
backend headers (pdf, ps, svg, script, tee, win32, ft, script-interpreter): 409 functions bound to
`cairo-2.dll` and 10 to `cairo-script-interpreter-2.dll` by their export tables, types imported from
Windows GDI and FreeType headers outside cairo's folder, and every generated Type matching CastXML on
both architectures. `cairo-dwrite.h` is C++ only, so it is skipped and reported; a hand-written file
covers its 5 functions (D-059). The generator needed no cairo-specific code; cairo showed two generic
gaps (outside callback typedefs, anonymous structs inside unions), fixed with fixture cases first
(D-068). The cairo harness (`tests\harness-cairo\`, 58 checks on win32 and win64) draws to image,
PDF, SVG and Win32 surfaces, reads paths through the union accessors, writes PNG through a callback,
uses Win32, FreeType and DirectWrite font faces, and runs the script interpreter with a callback in a
hooks struct. `tests\harness-cairo\COVERAGE.md` has the breakdown.

## Limits and their workarounds

| Construct | What tbBlob does | What the consumer does | Ref. |
|---|---|---|---|
| `__declspec(align(n))` over-aligned structs | Emits the Type with a NOTE, skips its layout check, reports it | Allocate aligned memory by hand if the library depends on the alignment | PRD §8 m.9 |
| Unions | Storage typed by alignment, plus `Property Get/Let` accessors per member | Use the accessors (`v.as_float`), not overlapping fields | D-018 |
| A Type's methods (union accessors) on an array element | Nothing: not safe; tested on tB BETA 1011 and shown to crash, cause not established | Copy the element into a variable, then use its accessors | D-069 |
| Bitfields | One storage field per group of bits, with the bits named in a comment | Mask and shift the storage value | D-018 |
| Unsigned integers | The signed tB type of the same width (same bits) | Read top-bit values as bit patterns (`&H80000000`) | D-005 |
| Macros that aren't constants (function-like, initializers, casts to types, cycles) | Skipped, each with a reason in the report | Write the equivalent tB by hand where needed | D-021 |
| Constants that differ between x86 and x64 | `#If Win64` pairs | Nothing | D-030 |
| Variadic functions | `ByVal ParamArray As Any()`; NOTE on each declare | Pass variables as `ByVal x` (a plain variable is passed by address) | D-006 |
| x86 `__stdcall` exports decorated as `_name@N` | With `--x86-dll`, binds each one to the name the DLL actually exports | Pass `--x86-dll <x86 DLL>` | D-026 |
| Header functions the DLL doesn't export | NOTE on the declare, listed in the report (9 in this libgit2 build) | Don't call them | D-031 |
| Headers that need a consumer define on MSVC (`git2/sys/stream.h` uses `ssize_t`) | Nothing automatic | `-D ssize_t=intptr_t` | D-032 |
| APIs in headers the entry header doesn't include | Generated only when named | `--also <header>` (repeatable) | D-033 |
| Struct layouts that differ between x86 and x64 beyond pointer size | Generation stops and names the struct (none in libgit2) | Not expressible in one tB source | PRD §7.8 |
| Callback parameter names hidden behind a macro | Placeholder names, reported (none lost in libgit2) | Nothing; no information exists to recover | D-024 |
| Where the DLL is loaded from | Normal Windows search; optional generated `<Project>_Loader` | Ship the DLL next to the EXE, or call `Load(folder)` / `LoadFile(path)` first | D-027 |
| Callbacks the library calls from its own threads | Nothing: a header doesn't say which callbacks those are | Handle every error inside the callback, synchronise shared state, call `CoInitializeEx` before using COM, no UI (`docs\USAGE.md`) | D-046 |
| Memory the library allocates for the caller to free | Nothing: ownership is in the library's documentation, not the header | Read it, then free it with the library's own function; don't rely on dispose setting the pointer to NULL | 19.0 |

## What the proof does not cover

Function coverage at run time is about 5% (52 of 960 libgit2 functions). That is enough because the
generator is mechanical: each *kind* of binding has been exercised on both architectures by the
tbfixture harness, the libgit2 harness, the cairo harness, or several. `tests\harness-fixture\COVERAGE.md`,
`tests\harness-libgit2\COVERAGE.md` and `tests\harness-cairo\COVERAGE.md` give the per-kind breakdown.

Closed since the first verdict:
- **Callbacks invoked on a thread the library created** (SPIKE-10, task 18.0): tbfixture calls back
  from threads it creates, singly and four at once, on win32 and win64 (D-045, D-046).
- **Library-allocated memory the caller frees** (task 19.0): a returned `char*` and a `git_buf`-style
  struct in tbfixture, with an allocation counter that returns to zero; libgit2's own `git_buf`
  through `git_repository_discover` and `git_buf_dispose`.

Things nothing exercises yet, roughly in order of risk:

1. **libgit2 callbacks on libgit2's own worker threads.** The libgit2 operations tested call back on
   the calling thread; threads are covered through tbfixture only.
2. **Long-lived library thread pools**, and a library thread exiting while tB objects created on it
   are still alive. tbfixture's threads are created and joined per call.
3. **Callbacks taking or returning structs by value**; floats in a variadic call.
4. **Network transports and credential callbacks** (https, ssh).
5. **Memory leaks in libgit2**: free functions are called, but only tbfixture measures whether
   memory comes back.
6. **Packaging**: generated modules were compiled as part of a project, not as a `.twinpack`.
   The user expects that a DLL that compiles will package too.

## Recommended next steps

1. **A libgit2 operation that calls back on its own threads** (for example pack indexing with
   threads enabled), to confirm the tbfixture thread result on a real library.
2. **A `.twinpack` of generated bindings**, to close the packaging gap.

Done since the first verdict: the threaded-callback test (18.0), `git_buf`-style ownership (19.0),
speed (16.0, 17.0: about 2 minutes down to about 36 seconds), plus `tbBlob --check` and dependency
messages (14.0), a distributable with the bundled CastXML (15.0, 20.0) and setup documentation by
purpose (22.0), and a second real library, cairo (29.0, 30.0).

## How to reproduce

```
powershell -ExecutionPolicy Bypass -File tests\run-all.ps1     # tests, fixture DLLs, the three harnesses (win32 + win64)
powershell -ExecutionPolicy Bypass -File tests\verdict.ps1     # the table above, from the current artifacts
```
`run-all.ps1` regenerates harness bindings after a tbBlob rebuild. It asks for an IDE recompile of a
harness only when the generated code changed. What a fresh clone needs first is in `docs\SETUP.md`
("To run the tests").
