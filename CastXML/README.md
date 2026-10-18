# CastXML\

A vcpkg manifest folder. It installs **CastXML 0.6.5**, a prebuilt Kitware binary that contains
Clang 18.1.3. tbBlob runs it to read C headers. Only `vcpkg.json` is in git; the installed tree
(`vcpkg_installed\`) is gitignored, so after cloning you install it once.

## Install

Needs vcpkg (see [Getting vcpkg](../docs/SETUP.md#getting-vcpkg)). From this folder:

```
vcpkg install --triplet x64-windows
```

The manifest pins vcpkg's `builtin-baseline`, so this gets the same version on every machine. It
produces:

```
CastXML\vcpkg_installed\x64-windows\
  tools\castxml\bin\castxml.exe
  tools\castxml\share\castxml\clang\include\...    Clang's resource headers (castxml.exe needs them)
  share\vcpkg-tool-castxml\copyright               CastXML's licence
```

## What uses it

- tbBlob's integration tests (`tbBlob --self-test --integration`) and the scripts in `tests\`: the
  harness build scripts pass it as `--castxml`, and `tests\testdata\regen-fixture-xml.ps1` uses it.
- `tools\package.ps1` copies `castxml.exe` and its resource headers into the distributable, so users
  of a package never need this folder or vcpkg.
- The original spike's scripts in `spikes\castxml-ffi-generator\`.

tbBlob itself never looks here. It uses `--castxml`, the `CASTXML` variable, the bundled copy next
to `tbBlob.exe`, or `PATH` (see [docs\SETUP.md](../docs/SETUP.md)).

## Why this version

CastXML's newer "Superbuild" snapshot (0.6.20260105, Clang 21.1.8) was evaluated. It produced
byte-identical output for libgit2 and tbfixture, was not faster, and was 16 MB larger, so the vcpkg
0.6.5 stays (decision D-043 in `tasks\decisions-castxml-ffi-generator.md`). To change versions,
update `builtin-baseline`, reinstall, run `tests\run-all.ps1`, and replace
`tools\licenses\LLVM-LICENSE.txt` with the matching LLVM version's licence (`castxml --version`
prints the Clang version).
