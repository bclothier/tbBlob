# Using tbBlob

## Synopsis

```
tbBlob <header folder> <entry header> <dll name> <output folder> [options]
tbBlob --check [--castxml <path>]
tbBlob --self-test [--integration]
tbBlob --help
```

## Arguments

| Argument | Meaning |
|---|---|
| `<header folder>` | The folder that holds the library's headers. Declarations in headers under this folder belong to the library and are generated; everything else (Windows SDK, C runtime) is only used to understand them. |
| `<entry header>` | The header to start from, relative to the header folder, usually the one an application includes (`git2.h`, `zlib.h`). Headers it includes are followed. |
| `<dll name>` | The DLL every `Declare` binds to (`Lib "git2.dll"`). Use the file name, not a path. |
| `<output folder>` | Where `report.md`, `Source\` and `Work\` are written. It is created if needed. `Source\` is emptied first, so modules of removed headers don't linger. |

## Options

| Option | Meaning |
|---|---|
| `--name <name>` | Project name, used for the `<name>_LayoutCheck` and `<name>_Loader` modules and in the report. Default: the DLL name without its extension. |
| `-I <folder>` | An extra include folder for CastXML (repeatable), for headers the library includes from outside its own folder. |
| `-D <name[=value]>` | A preprocessor define for CastXML (repeatable). Use it to pick configuration macros, or to supply something the headers expect the compiler to define (see the libgit2 example). |
| `--also <header>` | Another header to generate from, relative to the header folder (repeatable). Use it for headers the entry header doesn't include, such as libgit2's `git2/sys/*.h`. tbBlob writes `Work\tbblob_entry.h`, which includes the entry header and each `--also` header. |
| `--x86-dll <path>` | The library's **x86** DLL. Its export table decides, per `__stdcall` function, whether x86 binds the plain name or the decorated `_name@N`, and it flags header functions the DLL doesn't export. Recommended whenever you have the x86 DLL. |
| `--castxml <path>` | The `castxml.exe` to use. Default: the `CASTXML` environment variable, then `castxml\bin\castxml.exe` next to `tbBlob.exe`, then `PATH`. |
| `--check` | Check every dependency (CastXML, its resource headers, Visual Studio with the C++ tools, the Windows SDK through a real compile probe for x86 and x64, MSXML 6). Prints `OK`, `MISSING` (with the fix) or `SKIPPED` for each, then exits: 0 if all are OK, 4 otherwise. See [SETUP.md](SETUP.md#checking-a-machine-tbblob---check). |
| `--self-test` | Run tbBlob's built-in tests. `--integration` adds the tests that need CastXML, MSVC and the repository's test files. For development, not normal use. |
| `--help` | Print the usage summary. |

## Exit codes

| Code | Meaning | What to do |
|---|---|---|
| 0 | Done | Read `report.md` |
| 1 | Generation failed. The message names the item and header it was working on, or the x86/x64 disagreement | Usually a header problem: see [Troubleshooting](SETUP.md#troubleshooting) |
| 2 | A mistake on the command line | The message says which; the usage follows |
| 3 | The header folder, the entry header or an `--also` header does not exist | Check the paths (`--also` and the entry header are relative to the header folder) |
| 4 | A required tool or file was not found: CastXML, its resource headers, Visual Studio with the C++ tools, the Windows SDK | The run prints the full dependency checklist after the error, the same as `tbBlob --check`, with the fix for each problem |

## Examples

**A library in its own folder.** Headers in `C:\libs\mylib\include`, applications include
`mylib.h`, the DLL is `mylib.dll`:
```
tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib
```

**Pass the x86 DLL as well.** Do this when you have it. It decides how `__stdcall` exports are bound
on x86 and lists any header function the DLL doesn't export:
```
tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib --x86-dll C:\libs\mylib\bin\x86\mylib.dll
```

**Configuration macros and an extra include folder:**
```
tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib -D MYLIB_ENABLE_THREADS=1 -I C:\libs\common\include
```

**libgit2, including the advanced `git2/sys` API.** This is what the proof uses. `git2/sys/stream.h`
uses `ssize_t`, which MSVC doesn't define, hence the `-D`:
```
set INC=C:\vcpkg\installed\x64-windows\include
tbBlob %INC% git2.h git2.dll C:\out\git2 ^
    --x86-dll C:\vcpkg\installed\x86-windows\bin\git2.dll ^
    -D ssize_t=intptr_t ^
    --also git2\sys\alloc.h --also git2\sys\commit.h --also git2\sys\errors.h
```
(List each `git2\sys\*.h` you want. The test harness passes all 24.)

**Name the project differently from the DLL:**
```
tbBlob C:\libs\zlib\include zlib.h zlib1.dll C:\out\zlib --name ZLib
```
This gives `ZLib_LayoutCheck.twin` and `ZLib_Loader.twin`.

**Check a machine:**
```
tbBlob --check
tbBlob --check --castxml D:\tools\castxml\bin\castxml.exe
```

A run prints one progress line per stage, then a summary such as
`tbBlob: done: 89 modules, 960 functions, 108 types, 91 enums, 164 delegates, 248 constants (178 macros skipped)`.
libgit2 with its `sys` headers (960 functions) takes about 35 seconds on a 2-core machine, about 30 s
of it the four CastXML passes and about 5 s tbBlob's own work.

## The output folder

```
<output folder>\
  report.md                  read this first
  Source\
    <module>.twin            one module per header: git2/repository.h -> git2_repository.twin
    <name>_LayoutCheck.twin  LayoutMismatches() and TbLayout(record, member): check the layout at run time
    <name>_Loader.twin       optional: load the DLL from a folder you choose
  Work\
    castxml_x86.cmd / .xml   CastXML's view of the headers as the x86 compiler sees them
    castxml_x64.cmd / .xml   ... and as the x64 compiler sees them
    castxml_macros_x86.cmd, macros_x86.txt   the x86 compiler's macros
    castxml_macros_x64.cmd, macros_x64.txt   the x64 compiler's macros
    tbblob_entry.h           only with --also
```
The `.cmd` scripts are exactly what ran. Run one by hand to see CastXML's full output when
something fails. Generation is deterministic: the same inputs give byte-identical files.

## The report

`report.md` starts with counts, then a section on loading the DLL, then one section per kind of
finding. Each entry gives its reason:

| Section | What it lists |
|---|---|
| Renamed | Names changed to avoid a collision. twinBASIC is case-insensitive, so `TBF_OPEN` and `tbf_open` collide. Each entry names the other item |
| Type aliases | C typedefs and type-naming macros emitted as `Public Alias` |
| Skipped macros | Macros that can't be twinBASIC constants (function-like, initializers, casts, cycles), each with the reason |
| Parameter names lost | Callback parameters whose names couldn't be recovered |
| Structs passed or returned by value | Functions that do this (supported, listed for awareness) |
| Variadic functions | Functions with `...` (see below) |
| stdcall functions | How each x86 `__stdcall` function is bound |
| Declared but not exported | Header functions the DLL doesn't export: calling one fails at run time |
| Architecture-dependent constants | Constants emitted as `#If Win64` pairs, with both values |
| Packing | `#pragma pack` structs (`[PackingAlignment(n)]`), and over-aligned structs tB can't express |
| Unions | Unions and their storage |
| Bitfields | Bitfield groups and their storage field |
| Mapping notes | C types the type mapper had to approximate, each with what it chose (`none` for libgit2 and tbfixture) |
| x86/x64 disagreements | Structs whose layout differs beyond pointer size. Generation stops if there are any |

## Using the generated code

- **Add the files.** Import every `.twin` file from `Source\` into your twinBASIC project. Modules
  refer to each other's types, and the order doesn't matter. Don't edit them: regenerate instead.
- **Both architectures from one source.** Pointer-sized values are `LongPtr`, and the few things that
  differ use `#If Win64`. Compile your project as win32 or win64 against the matching DLL.
- **Strings.** `const char*` is `ByVal LongPtr`. Pass `VarPtr(bytes(0))` of a NUL-terminated UTF-8
  byte array, and read returned strings from the pointer. `const wchar_t*` takes `StrPtr(s)`.
- **NULL** for a pointer, or for a `ByRef` struct parameter: `ByVal vbNullPtr`.
- **Unsigned integers** are the signed type of the same width. Values with the top bit set read as
  negative numbers or bit patterns (`&H80000000`).
- **Unions** are a storage field plus `Property Get`/`Let` per member: write `v.as_float`, not a field.
- **Bitfields** are one storage field per group. Mask and shift to reach the bits; the comment says
  which bits are which.
- **Variadic functions** (`...`) use `ByVal ParamArray args As Any()`. Pass variables as `ByVal x`,
  because a plain variable is passed by address.
- **Callbacks** are `Delegate`s. Pass `AddressOf YourProcedure`, declared with the same calling
  convention (`CDecl` where the delegate says so).
- **Callbacks on the library's own threads.** Some C libraries call back from worker threads they
  create. Only the library's documentation says which callbacks can do that; a header can't, so tbBlob
  can't flag them. twinBASIC callbacks do run correctly there, which is tested on win32 and win64
  (D-045, D-046). On such a thread, though:
  - **Handle every error inside the callback.** Put `On Error` at the top and return the library's
    error value explicitly. An error that escapes is not reported to the C code (it sees a result of
    0, which many libraries read as "continue"), it does not reach your calling code, and the
    twinBASIC runtime shows a modal "Run-time error" box. In a console tool or service, that box hangs
    the program until someone clicks it.
  - **Synchronise shared state.** Module variables changed by callbacks running at the same time lose
    updates. Use an atomic operation (the C library may offer one; `InterlockedIncrement` is a
    `kernel32` export on x86 only) or a lock.
  - **COM is not initialised on that thread.** `CreateObject` fails with "CoInitialize has not been
    called". Call `CoInitializeEx` (from `ole32`) at the start of the callback and `CoUninitialize`
    at the end if you need COM objects there, and never use objects that were created on your main
    thread.
  - **No UI** from a library thread.
- **Memory the library allocates.** A returned `char*` you must free arrives as a `LongPtr`. Read it
  (for example `FromUtf8`-style code over the pointer), then pass it back to the library's own free
  function, never to anything else. A struct the library fills, like libgit2's `git_buf`, is a normal
  `Type`: read its fields, then call the library's dispose function. Don't assume dispose sets the
  pointer to NULL: libgit2's `git_buf_dispose` leaves it at an internal empty string. Just don't use
  the old contents afterwards.
- **`NOTE:` comments** above a declare flag what to know: variadic, struct by value, not exported.
- **Checking the layout** in your own program: `If Len(<name>_LayoutCheck.LayoutMismatches()) > 0 Then …`
- **Loading the DLL.** By default Windows looks in the EXE's folder, the system folders, the current
  folder, then `PATH`, and never in subfolders. For a twinBASIC DLL or add-in, "the EXE's folder" is
  the host application's folder. To load the library from elsewhere, call
  `<name>_Loader.Load(folder)` before the first call. It loads `folder\win32\<dll>` or
  `folder\win64\<dll>` (matching the running code) if that file exists, otherwise
  `folder\<dll>`, and the DLL's own dependencies load from its folder. `<name>_Loader.LoadFile(path)`
  loads one full path; `<name>_Loader.IsLoaded()` tells you whether it is loaded.

Your program needs only the library's DLL at run time. tbBlob, CastXML and Visual Studio are needed
only to generate.
