# Using tbBlob

## Synopsis

```
tbBlob <header folder> <entry header> <dll> <output folder> [options]
tbBlob --check [--castxml <path>]
tbBlob --self-test [--integration]
tbBlob --help
```

## Arguments

| Argument | Meaning |
|---|---|
| `<header folder>` | The folder that holds the library's headers. Declarations in headers under this folder belong to the library and are generated; everything else (Windows SDK, C runtime) is only used to understand them. |
| `<entry header>` | The header to start from, relative to the header folder, usually the one an application includes (`git2.h`, `zlib.h`). Headers it includes are followed. |
| `<dll>` | The library's x64 DLL file, or a folder of DLLs (each `*.dll` directly in it). tbBlob reads the export tables and binds each function to the DLL that exports it (`Lib "<file name>"`); a function no DLL exports gets no declare and is listed in the report. Other libraries' DLLs in the folder do no harm: only the library's functions are looked up. A function that two DLLs export stops the run; settle it with `--dll`. A name that is no file or folder here (`mylib.dll` when generating where the DLL isn't) binds every function to that name and checks nothing. |
| `<output folder>` | Where `report.md`, `Source\` and `Work\` are written. It is created if needed. `Source\` is emptied first, so modules of removed headers don't linger. |

## Options

| Option | Meaning |
|---|---|
| `--name <name>` | Project name, used for the `<name>_LayoutCheck` and `<name>_Loader` modules and in the report. Default: the DLL name without its extension; for a folder of DLLs, the entry header's name without its extension (`cairo.h` gives `cairo`). |
| `-I <folder>` | An extra include folder for CastXML (repeatable), for headers the library includes from outside its own folder. |
| `-D <name[=value]>` | A preprocessor define for CastXML (repeatable). Use it to pick configuration macros, or to supply something the headers expect the compiler to define (see the libgit2 example). |
| `--also <header>` | Another header to generate from, relative to the header folder (repeatable). Use it for headers the entry header doesn't include, such as libgit2's `git2/sys/*.h`. tbBlob writes `Work\tbblob_entry.h`, which includes the entry header and each `--also` header. |
| `--x86-dll <path>` | The library's **x86** DLL, or a folder of them. The export table of each function's x86 DLL (same file name) decides, per `__stdcall` function, whether x86 binds the plain name or the decorated `_name@N`, and flags functions the x86 DLL doesn't export. Recommended whenever you have the x86 DLLs. |
| `--dll <f>=<dll>` | Binds function `<f>`, or every function of header `<f>` (a name ending in `.h`), to `<dll>`, one of the DLLs read from `<dll>` (repeatable). Needed for a function more than one DLL exports. It binds `<f>` even if that DLL doesn't export it; the declare then gets a `NOTE` and the report lists it. |
| `--keep-unexported` | Declare the functions no DLL exports anyway, instead of skipping them: each binds to the DLL most of its header's other functions bind to (or the only DLL, when there is one), with a `NOTE` above the declare, and the report lists it. For a DLL that exports more at run time than the one you generate against, or exports by ordinal only. A function this can't place is still skipped, and the report names `--dll` as the fix. |
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
| 3 | The header folder, the entry header, an `--also` header or `--x86-dll` does not exist | Check the paths (`--also` and the entry header are relative to the header folder) |
| 4 | A required tool or file was not found: CastXML, its resource headers, Visual Studio with the C++ tools, the Windows SDK | The run prints the full dependency checklist after the error, the same as `tbBlob --check`, with the fix for each problem |

## Examples

**A library in its own folder.** Headers in `C:\libs\mylib\include`, applications include
`mylib.h`, the DLL is `mylib.dll`:
```
tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib
```

**Give the DLL itself.** Then tbBlob reads its export table: a header function the DLL doesn't
export gets no declare, and the report lists that and any export no header declares:
```
tbBlob C:\libs\mylib\include mylib.h C:\libs\mylib\bin\x64\mylib.dll C:\out\mylib
```

**Pass the x86 DLL as well.** Do this when you have it. It decides how `__stdcall` exports are bound
on x86 and flags any function the x86 DLL doesn't export:
```
tbBlob C:\libs\mylib\include mylib.h C:\libs\mylib\bin\x64\mylib.dll C:\out\mylib --x86-dll C:\libs\mylib\bin\x86\mylib.dll
```

**A library with several DLLs.** Give the folder: each function binds to the DLL that exports it.
cairo's script interpreter is in `cairo-script-interpreter-2.dll`, the rest in `cairo-2.dll`;
vcpkg's `bin` also holds FreeType, zlib and others, which do no harm:
```
set CAIRO=C:\vcpkg\installed\x64-windows
tbBlob %CAIRO%\include\cairo cairo.h %CAIRO%\bin C:\out\cairo -I %CAIRO%\include ^
    --also cairo-script-interpreter.h --also cairo-pdf.h --also cairo-svg.h
```
The project is named `cairo` (after the entry header), and `cairo_Loader.Load(folder)` loads both
DLLs. Were a function exported by two of the DLLs, the run would stop and name them;
`--dll cairo_foo=cairo-2.dll` (or `--dll cairo-ft.h=cairo-2.dll` for a whole header) settles it.

**Configuration macros and an extra include folder:**
```
tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib -D MYLIB_ENABLE_THREADS=1 -I C:\libs\common\include
```

**libgit2, including the advanced `git2/sys` API.** This is what the proof uses. `git2/sys/stream.h`
uses `ssize_t`, which MSVC doesn't define, hence the `-D`:
```
set INC=C:\vcpkg\installed\x64-windows\include
tbBlob %INC% git2.h C:\vcpkg\installed\x64-windows\bin C:\out\git2 ^
    --x86-dll C:\vcpkg\installed\x86-windows\bin ^
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
`tbBlob: done: 89 modules, 951 functions, 108 types, 91 enums, 164 delegates, 248 constants (178 macros skipped)`.
libgit2 with its `sys` headers (951 functions) takes about 35 seconds on a 2-core machine, about 30 s
of it the four CastXML passes and about 5 s tbBlob's own work.

## The output folder

```
<output folder>\
  report.md                  read this first
  Source\
    <module>.twin            one module per header: git2/repository.h -> git2_repository.twin
    <name>_LayoutCheck.twin  LayoutMismatches() and TbLayout(record, member): check the layout at run time
    <name>_Loader.twin       optional: load the DLL (or every DLL) from a folder you choose
  Work\
    castxml_x86.cmd / .xml   CastXML's view of the headers as the x86 compiler sees them
    castxml_x64.cmd / .xml   ... and as the x64 compiler sees them
    castxml_macros_x86.cmd, macros_x86.txt   the x86 compiler's macros
    castxml_macros_x64.cmd, macros_x64.txt   the x64 compiler's macros
    preprocessed_x64.i       the headers after the x64 preprocessor (callback parameter names come from here)
    tbblob_entry.h           only with --also
    castxml_<pass>_failed.txt  only when an --also header was skipped: CastXML's full output of the failed pass
```
The `.cmd` scripts are exactly what ran. Run one by hand to see CastXML's full output when
something fails. Generation is deterministic: the same inputs give byte-identical files.

## The report

`report.md` starts with counts, then the DLLs (each with its function count) and a section on
loading them, then one section per kind of finding. Each entry gives its reason:

| Section | What it lists |
|---|---|
| Headers skipped | `--also` headers CastXML could not read (a C++-only header, an `#error`, a missing dependency), each with the CastXML pass that failed and its error lines. Their functions and types are not generated; everything else is. See [A header CastXML cannot read](#a-header-castxml-cannot-read) |
| Outside types | Types from headers outside the header folder (Windows SDK, C runtime, other libraries) that the library's declarations use, each with its kind and module. See [Types from other headers](#types-from-other-headers) |
| COM interfaces | COM interface pointers, written `LongPtr /* IName */`, and the functions and fields that use each |
| Renamed | Names changed to avoid a collision. twinBASIC is case-insensitive, so `TBF_OPEN` and `tbf_open` collide. Each entry names the other item |
| Type aliases | C typedefs and type-naming macros emitted as `Public Alias` |
| Skipped macros | Macros that can't be twinBASIC constants (function-like, initializers, casts, cycles), each with the reason |
| Parameter names lost | Callback parameters whose names couldn't be recovered |
| Structs passed or returned by value | Functions that do this (supported, listed for awareness) |
| Variadic functions | Functions with `...` (see below) |
| stdcall functions | How each x86 `__stdcall` function is bound |
| Declared but not exported | Header functions no DLL exports: they get no declare, unless `--keep-unexported` or `--dll` binds them (then the declare has a `NOTE`). With a bare DLL name, functions the `--x86-dll` doesn't export: their declare has a `NOTE`, and calling one fails on x86 |
| Exported but not declared | Per DLL, exports no library header declares: a header left out (add it with `--also`), a C++-only header, or an internal export |
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
  loads one full path; `<name>_Loader.IsLoaded()` tells you whether it is loaded. When the functions
  bind to several DLLs, `Load(folder)` loads each of them the same way, in the order the report's DLLs
  section lists them, `LoadFile` is called once per DLL, and `IsLoaded()` is True when all are loaded.

Your program needs only the library's DLL at run time. tbBlob, CastXML and Visual Studio are needed
only to generate.

## Types from other headers

A library's functions often use types it doesn't declare itself: `HDC`, `RECT` and `LOGFONTW` from
the Windows SDK, `FILE` from the C runtime, `FT_Face` from FreeType. tbBlob imports exactly the ones
the library uses, and everything those need, into one module per header, named after the header
(`windef`, `wingdi`, `corecrt_wstdio`, `freetype`). How each is written:

| C | tB | Why |
|---|---|---|
| a struct, used by value, as a field, or through `T*` | the real `Type` (`ByRef As tagLOGFONTW` for `T*`), layout-checked like the library's own | a copy needs the real layout |
| an enum | the `Enum` with its values | |
| a handle: `DECLARE_HANDLE` (`HDC`, `HWND`, `HBRUSH`) or a typedef to a pointer to a struct (`FT_Face`) | `Public Alias HDC As LongPtr`, passed `ByVal` | the value is the pointer; a pointer typedef's struct is still imported for reading fields |
| an incomplete struct, or `FILE` | `Public Alias X As LongPtr`, `X*` passed `ByVal As X` | only ever a pointer (C11 7.21.3 for `FILE`) |
| a COM interface pointer (`IStream*`) | `ByVal As LongPtr /* IStream */` | pass `ObjPtr(obj)` of a tB interface reference; write the `Interface` yourself to call its methods |

Every alias is one name for the whole project, declared once at file scope of its header's module
(twinBASIC aliases can't be module-qualified). Names the library and another header both use are
renamed and reported like any other collision. Give `-I` for another library's include folder, as
for any header the library includes.

## A header CastXML cannot read

tbBlob reads headers as C. A header that needs C++ (`cairo-dwrite.h` stops with
`#error DWrite font backend requires C++`), that `#error`s for another configuration, or whose
dependencies aren't on the include path, makes CastXML fail. When that header was given with
`--also`, tbBlob skips it, runs CastXML again without it, and generates everything else. The console
says `tbBlob: warning: skipped <header>: <first error>`, and the report's "Headers skipped" section
lists the header, the pass that failed (`x86`, `x64`, `macros_x86` or `macros_x64`) and CastXML's
error lines. `Work\castxml_<pass>_failed.txt` holds CastXML's full output of that pass: read the
`In file included from` lines from the top to see how the header was reached.

A header is skipped only when every error traces back, through the include lines of
`Work\tbblob_entry.h`, to `--also` headers. An error in the entry header, or one tbBlob can't trace,
still stops the run (exit 1) as before. Fix such a header with `-I` (a missing dependency) or `-D` (a
configuration macro), or leave it out. The functions of a skipped header still show up under
"Exported but not declared" when you give the DLL itself.

## Known issues

- **The Windows SDK's `webservices.h` cannot be read.** It declares two enums with no values
  (`WS_XML_BUFFER_PROPERTY_ID` and `WS_SECURITY_ALGORITHM_PROPERTY_ID`; SDK 10.0.22621 and
  10.0.26100). MSVC accepts that; Clang, which CastXML is built on, rejects it in C
  (`webservices.h:695:1: error: use of empty enum`), and no option turns the error off. A library
  whose entry header includes `webservices.h` therefore fails in the CastXML pass (exit 1); an
  `--also` header that includes it is skipped and reported (see
  [A header CastXML cannot read](#a-header-castxml-cannot-read)). Not fixed yet (D-061).
