# Setting up tbBlob

## What it needs

tbBlob runs on 64-bit Windows 10 or 11 and generates bindings for both win32 and win64. What you need
depends on what you're doing; each list adds to the one before:

- [To run tbBlob](#to-run-tbblob): you have a tbBlob folder (a package) and want to generate bindings.
- [To build tbBlob and the package](#to-build-tbblob-and-the-package): you have a clone of this
  repository and want `tbBlob.exe` and a package to give to others.
- [To run the tests](#to-run-the-tests): you are changing tbBlob.

### To run tbBlob

| Dependency | Bundled in the tbBlob folder? | Why tbBlob needs it | How to get it |
|---|---|---|---|
| `tbBlob.exe` | yes | The generator itself. It needs only Windows system DLLs; the twinBASIC runtime is built in | `tools\package.ps1` |
| CastXML 0.6.5: `castxml\bin\castxml.exe` **and** `castxml\share\castxml\` | yes | Reads the headers exactly as the Microsoft C compiler does. `castxml.exe` needs its `share\castxml` folder (Clang's resource headers) next to its `bin` folder | Bundled. To use another copy, see [Where tbBlob looks for CastXML](#where-tbblob-looks-for-castxml) |
| **Visual Studio 2022 or Build Tools for Visual Studio 2022** with the *Desktop development with C++* workload: MSVC x64/x86 build tools **and a Windows 10/11 SDK** | **no, install it** (Microsoft's licence) | CastXML runs MSVC's environment (`vcvars32.bat` / `vcvars64.bat`) so the headers see the same compiler, macros and Windows SDK as a real build, once for x86 and once for x64 | See [step 1](#setting-up-a-new-machine) |
| Microsoft Visual C++ Redistributable 2015–2022 (x64) | no | `castxml.exe` needs `MSVCP140.dll`, `VCRUNTIME140.dll` and `VCRUNTIME140_1.dll` | Installed with Visual Studio / Build Tools; otherwise https://aka.ms/vs/17/release/vc_redist.x64.exe |
| MSXML 6, Windows Script Host | part of Windows | Reading CastXML's XML; running CastXML (`WScript.Shell`) | Nothing to do |

**Not needed** to generate bindings: the twinBASIC IDE (you need it to *use* the generated code),
vcpkg, Git, Python.

**Visual Studio Code is not enough on its own.** VS Code and its C/C++ extension are an editor and a
language service. They ship no compiler, C runtime headers or Windows SDK, and use whatever toolchain
is installed. tbBlob needs the **MSVC** toolchain specifically, because the DLLs you bind to were
built with it: CastXML must see MSVC's predefined macros, runtime headers and Windows SDK. Installing
the **Build Tools for Visual Studio 2022** (no IDE) provides it, and if you set up VS Code for MSVC
C++ you have probably installed them already, so `tbBlob --check` will pass. A MinGW or Clang-only
toolchain is not a substitute: its headers and Windows SDK differ from MSVC's.

### To build tbBlob and the package

Everything in [To run tbBlob](#to-run-tbblob) except the package itself, plus:

| Dependency | Why | How to get it |
|---|---|---|
| Git | To clone this repository | https://git-scm.com |
| The twinBASIC IDE, BETA 983 or later | tbBlob is a twinBASIC project, compiled in the IDE (no command-line compiler) | https://twinbasic.com |
| vcpkg | Installs CastXML into the clone. A clone holds only `CastXML\vcpkg.json`, not the 100 MB install | [Getting vcpkg](#getting-vcpkg) |
| CastXML 0.6.5 in `CastXML\vcpkg_installed\` | `tools\package.ps1` copies it into the package; the build-from-source tests use it | `vcpkg install --triplet x64-windows` in `CastXML\` ([CastXML\README.md](../CastXML/README.md)) |

The twinBASIC import/export tool (`tools\impexp\`), which turns `Source\` into `tbBlob.twinproj`, is
in the repository; nothing to install.

### To run the tests

Everything in [To build tbBlob and the package](#to-build-tbblob-and-the-package), plus:

| Dependency | Why | How to get it |
|---|---|---|
| libgit2, x64 **and** x86, in `libgit2\` | The real-world library the tests generate bindings for and call | Two `vcpkg install` commands in `libgit2\` ([libgit2\README.md](../libgit2/README.md)) |
| `git.exe` on `PATH` | Creates the libgit2 harness's test repositories | Git, as above |
| Both test harnesses compiled, win32 and win64 | They call the generated bindings at run time | In the twinBASIC IDE; `tests\run-all.ps1` says which one is stale ([tests\README.md](../tests/README.md#manual-steps)) |

Python is **not** needed. Only the original spike's prototype (`spikes\castxml-ffi-generator\gen_probe.py`)
uses it, and spikes are not part of the tests.

## Getting vcpkg

vcpkg is Microsoft's C/C++ package manager. This repository uses it in *manifest mode*: each of
`CastXML\` and `libgit2\` has a `vcpkg.json` that pins the exact versions (`builtin-baseline`), and
`vcpkg install` in that folder installs into it. Either:

- **With Visual Studio 2022 17.6 or later:** add the *vcpkg package manager* component in the
  Visual Studio Installer (Individual components). It is available as `vcpkg` in the *Developer
  Command Prompt* and *Developer PowerShell*.
- **On its own:**
  ```
  git clone https://github.com/microsoft/vcpkg C:\vcpkg
  C:\vcpkg\bootstrap-vcpkg.bat
  ```
  then run `C:\vcpkg\vcpkg.exe`, or add `C:\vcpkg` to `PATH`.

vcpkg is needed once per clone, to install; tbBlob, the tests and the package never run it.

## Setting up a new machine

1. **Install the C++ build tools.** Either:
   - add the *Desktop development with C++* workload to Visual Studio 2022 in the Visual Studio
     Installer, or
   - install the Build Tools for Visual Studio 2022 (https://aka.ms/vs/17/release/vs_BuildTools.exe).
     From a command prompt that is:
     ```
     vs_BuildTools.exe --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive
     ```
     `--includeRecommended` brings the MSVC x64/x86 tools and a Windows SDK.
2. **Copy the tbBlob folder** (see [Deploying](#deploying)) anywhere, for example `C:\Tools\tbBlob`.
   Keep its layout: `tbBlob.exe` next to the `castxml` folder. Add the folder to `PATH` if you want
   to type `tbBlob` from anywhere.
3. **Check the machine:**
   ```
   C:\Tools\tbBlob\tbBlob --check
   ```
   All lines should say `OK`. Fix anything `MISSING` as its `fix:` line says, then run it again.
4. **Generate something.** See [USAGE.md](USAGE.md#examples).

## Checking a machine: `tbBlob --check`

On a machine set up correctly:

```
OK       castxml.exe                    C:\Tools\tbBlob\castxml\bin\castxml.exe (bundled with tbBlob)
OK       castxml.exe starts             castxml version 0.6.5
OK       CastXML resource headers       C:\Tools\tbBlob\castxml\share\castxml\clang\include
OK       vswhere.exe                    C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe
OK       Visual Studio with C++ tools   C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools
OK       vcvars32.bat / vcvars64.bat    C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build
OK       compile probe x86              <windows.h> preprocessed by CastXML with vcvars32.bat
OK       compile probe x64              <windows.h> preprocessed by CastXML with vcvars64.bat
OK       MSXML 6                        MSXML2.DOMDocument.6.0
all 9 dependencies OK
```

Each line is `OK`, `MISSING` (followed by a `fix:` line) or `SKIPPED` (it couldn't be checked
because something it needs is missing; fix the `MISSING` ones first). The exit code is 0 when
everything is OK, 4 otherwise. **A normal run that fails for a missing dependency (exit 4) prints the
same checklist**, so you don't have to run `--check` separately.

| Check | What it proves | If it is MISSING |
|---|---|---|
| castxml.exe | A `castxml.exe` was found, and where (`--castxml`, `CASTXML` variable, bundled, or `PATH`) | Keep the `castxml` folder next to `tbBlob.exe`, or point tbBlob at another CastXML |
| castxml.exe starts | It runs and prints its version | *"not a valid program"*: the file is empty or damaged, so reinstall it (tbBlob never runs such a file). *Exit 0xC0000135*: install the Visual C++ Redistributable (x64) |
| CastXML resource headers | `..\share\castxml\clang\include` exists next to CastXML's `bin` folder | Copy CastXML's whole folder (`bin` **and** `share`) |
| vswhere.exe | The Visual Studio Installer is present | Install Visual Studio 2022 or the Build Tools |
| Visual Studio with C++ tools | An installation with the MSVC x86/x64 tools | Add the *Desktop development with C++* workload |
| vcvars32.bat / vcvars64.bat | MSVC's environment scripts for both architectures | As above |
| compile probe x86 / x64 | CastXML really preprocesses `<windows.h>` with that architecture's compiler and Windows SDK | Install a Windows 10/11 SDK and that architecture's MSVC tools (part of the workload). The line shows the first error |
| MSXML 6 | The XML parser tbBlob uses | It is part of Windows; repair Windows |

## Where tbBlob looks for CastXML

In this order:

1. `--castxml <path>` on the command line. If it doesn't exist, tbBlob stops rather than falling back.
2. The `CASTXML` environment variable.
3. `castxml\bin\castxml.exe` next to `tbBlob.exe` (the bundled copy).
4. The first folder on `PATH` that holds `castxml.exe`.

Any CastXML must keep its release layout, `bin\castxml.exe` with `share\castxml\` beside `bin`:
the official release zip, a vcpkg install (`tools\castxml\`), or the bundled copy.

## Deploying

`tools\package.ps1` (run from a clone of this repository, after building tbBlob) builds one folder
to copy, about 110 MB:

```
powershell -ExecutionPolicy Bypass -File tools\package.ps1                 # -> dist\tbBlob\
powershell -ExecutionPolicy Bypass -File tools\package.ps1 -Out D:\tbBlob
```

```
tbBlob\
  tbBlob.exe
  castxml\bin\castxml.exe
  castxml\share\castxml\...     (Clang resource headers)
  licenses\CastXML-LICENSE.txt, LLVM-LICENSE.txt, NOTICE.md
  README.md
  docs\USAGE.md, SETUP.md
```

The script checks the package before reporting success. `tbBlob --check` must find the bundled
CastXML and pass, a generation from the package must work, and every option and exit code of
`tbBlob --help` must be documented in `USAGE.md`. Zip the folder or copy it as it is. The target
machine still needs the C++ build tools (step 1 above).

Licences: CastXML is Apache-2.0 (Kitware). The LLVM/Clang code inside `castxml.exe` and its resource
headers are Apache-2.0 with LLVM Exceptions. Both licence texts are in `licenses\`, and
`licenses\NOTICE.md` lists what each covers. The LLVM text comes from `tools\licenses\LLVM-LICENSE.txt`
(LLVM 18.1.3, the Clang version `castxml --version` reports). If a newer CastXML is bundled, replace
it with the matching LLVM version's `LICENSE.TXT`.

## Building from source

From a fresh clone, with the dependencies in
[To build tbBlob and the package](#to-build-tbblob-and-the-package) installed:

1. Install CastXML into the clone:
   ```
   cd CastXML
   vcpkg install --triplet x64-windows
   ```
2. `powershell -ExecutionPolicy Bypass -File tests\import.ps1` rebuilds `tbBlob.twinproj` from
   `Source\`, using the import/export tool checked in at `tools\impexp\Build\`.
3. Open `tbBlob.twinproj` in the twinBASIC IDE and compile it as **win64**. The EXE goes to
   `Build\tbBlob_win64.exe`.
4. `powershell -ExecutionPolicy Bypass -File tools\package.ps1` builds the distributable in
   `dist\tbBlob\` and verifies it.

To run the tests as well ([To run the tests](#to-run-the-tests)):

5. Install libgit2 for both architectures:
   ```
   cd libgit2
   vcpkg install --triplet x64-windows
   vcpkg install --triplet x86-windows --x-install-root=vcpkg_installed_x86
   ```
6. `powershell -ExecutionPolicy Bypass -File tests\run-all.ps1`. The first run generates the
   harness projects and reports them as missing (a first run on a clean clone passes only part of
   its self-test checks); compile each as win32 and win64 in the IDE, then run it again. No test needs the
   spike output in `spikes\`. See [tests\README.md](../tests/README.md#first-run-on-a-fresh-clone).

## Troubleshooting

**Exit 4 and a checklist.** A dependency is missing. Fix the `MISSING` lines; each says how.

**Exit 1, "castxml failed (x86 pass …)" followed by compiler errors.** The headers didn't compile as
given. Usually:
- the library needs a configuration macro: add `-D NAME=value`;
- it includes headers from another folder: add `-I <folder>`;
- the headers expect something MSVC doesn't define. libgit2's `git2/sys/stream.h` needs
  `-D ssize_t=intptr_t`.

The failing `Work\castxml_*.cmd` is named in the message. Run it by hand to see the full output.

**Exit 1, "x86 and x64 disagree".** A struct's layout differs between the architectures in a way
one source can't express. The message names it. That struct (or the header) has to be left out.

**Exit 1 naming an item and a header.** Generation stopped on that item. The message includes the
original error; please report it with the header.

**"Declared but not exported" in the report.** The headers declare functions the DLL doesn't have,
often because the library was built without that feature. Don't call them; they fail at run time.

**A function fails at run time with "entry point not found" on win32 only.** It is probably a
`__stdcall` export with a decorated name. Generate again with `--x86-dll <the x86 DLL>`.

**How long it takes.** libgit2 with its `sys` headers takes about 35 seconds on a 2-core machine.
About 30 s of that is the four CastXML passes (x86, x64, and a macro dump for each); tbBlob's own
work is about 5 s.
