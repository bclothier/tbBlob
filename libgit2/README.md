# libgit2\

A vcpkg manifest folder. It installs **libgit2**, the real-world library tbBlob is proven against.
Only `vcpkg.json` is in git; the installed trees are gitignored, so after cloning you install them
once. This is needed only for tbBlob's tests, not to build or use tbBlob.

## Install

Needs vcpkg (see [Getting vcpkg](../docs/SETUP.md#getting-vcpkg)). From this folder, run both
commands. The tests need the x64 **and** the x86 build:

```
vcpkg install --triplet x64-windows
vcpkg install --triplet x86-windows --x-install-root=vcpkg_installed_x86
```

The second command installs to a separate root so the two don't replace each other. The manifest
pins vcpkg's `builtin-baseline`, so every machine gets the same libgit2. Result:

```
libgit2\vcpkg_installed\x64-windows\
  include\git2.h, include\git2\...       the headers tbBlob generates from
  bin\git2.dll (+ its dependencies)      used by the win64 harness
libgit2\vcpkg_installed_x86\x86-windows\
  bin\git2.dll (+ its dependencies)      used by the win32 harness, and as tbBlob's --x86-dll
```

(The x86 root also gets an `x64-windows` folder of host tools. vcpkg needs those to build; nothing
here uses them.)

## What uses it

- `tests\harness-libgit2\build-project.ps1` runs tbBlob on `include\git2.h`, plus every
  `git2\sys\*.h` through `--also`, with the x86 `git2.dll` as `--x86-dll`. The harness
  (`tests\harness-libgit2\Sources\Harness.twin`) loads the matching `git2.dll` from these trees for
  win32 and win64.
- tbBlob's integration tests (`Tests_EndToEnd`, `Tests_Model`, `Tests_Perf`) and `tests\verdict.ps1`
  read the x64 headers and DLL.
- The original spike, `spikes\castxml-ffi-generator\`.

The libgit2 API reference is at https://libgit2.org/docs/reference/main/. What the harness covers is
in [tests\harness-libgit2\COVERAGE.md](../tests/harness-libgit2/COVERAGE.md).
