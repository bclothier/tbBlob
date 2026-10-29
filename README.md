# tbBlob

tbBlob generates **twinBASIC bindings for a C library** from its header files: `Declare`s,
`Type`s, `Enum`s, `Delegate`s and constants. One generated source works as both win32 and win64.
It uses [CastXML](https://github.com/CastXML/CastXML) to read the headers exactly as the Microsoft
C compiler does, and writes a report of everything it could not express.

It has been proven on all of libgit2 1.9.1 (951 functions, every one `git2.dll` exports and a
header declares): the bindings compile for both
architectures, every generated struct matches C's memory layout, and a real git workflow plus a
clone with callbacks run through them. A second library, cairo 1.18.4 (419 functions across two
DLLs, with Windows GDI and FreeType types from outside its folder), draws, writes PNG, PDF and SVG,
and renders text through Win32, FreeType and DirectWrite font faces, on both architectures. See
`tasks\verdict-castxml-ffi-generator.md`.

## Quick start

1. Install **Visual Studio 2022 or the Build Tools for Visual Studio 2022** with the
   *Desktop development with C++* workload. This is the one prerequisite that isn't bundled.
2. Copy the `tbBlob` folder (made by `tools\package.ps1`) to the machine and check it:
   ```
   tbBlob --check
   ```
   Every line should say `OK`. Anything `MISSING` comes with the fix.
3. Generate:
   ```
   tbBlob C:\libs\mylib\include mylib.h mylib.dll C:\out\mylib
   ```
   Read `C:\out\mylib\report.md` first, then add the `.twin` files in `C:\out\mylib\Source\` to
   your twinBASIC project.

## Documentation

- [docs/USAGE.md](docs/USAGE.md): the command line, every option, examples, the output folder,
  the report, and using the generated code.
- [docs/SETUP.md](docs/SETUP.md): dependencies, setting up a new machine, deploying, `tbBlob --check`
  and fixes for each failure, building from source, troubleshooting.
