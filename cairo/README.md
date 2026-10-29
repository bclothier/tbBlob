# cairo\

A vcpkg manifest folder. It installs **cairo 1.18.4**, tbBlob's second proof library (D-055): unlike
libgit2 it has two DLLs, its declarations use types from the Windows SDK, the C runtime, FreeType and
fontconfig, and one of its headers is C++ only. Only `vcpkg.json` is in git; the installed trees are
gitignored, so after cloning you install them once. This is needed only for tbBlob's tests, not to
build or use tbBlob.

## Install

Needs vcpkg (see [Getting vcpkg](../docs/SETUP.md#getting-vcpkg)). From this folder, run both
commands. The tests need the x64 **and** the x86 build:

```
vcpkg install --triplet x64-windows
vcpkg install --triplet x86-windows --x-install-root=vcpkg_installed_x86
```

The second command installs to a separate root so the two don't replace each other. The manifest
pins vcpkg's `builtin-baseline` (the same as `libgit2\`), so every machine gets the same cairo. The
first build from source takes a while (cairo, pixman, FreeType, fontconfig, libpng, zlib, ...).

**If FreeType fails to download:** its source comes from download.savannah.gnu.org, which can
answer an automated download with a human check, so vcpkg fails on it. Download the archive the
error names (for this baseline `freetype-freetype-VER-2-13-3.tar.gz`) in a browser and put it in
vcpkg's download cache, then run `vcpkg install` again: vcpkg uses the cached file instead of
downloading. With Visual Studio's vcpkg that cache is `%LOCALAPPDATA%\vcpkg\downloads`; with a
cloned vcpkg it is `downloads\` in its folder, or wherever `VCPKG_DOWNLOADS` points.

Result:

```
cairo\vcpkg_installed\x64-windows\
  include\cairo\cairo.h, cairo-*.h        the headers tbBlob generates from
  include\ft2build.h, include\freetype\   FreeType's headers (cairo-ft.h needs them, -I include)
  bin\cairo-2.dll, cairo-script-interpreter-2.dll (+ their dependencies)   used by the win64 harness
cairo\vcpkg_installed_x86\x86-windows\
  bin\cairo-2.dll, ... (+ their dependencies)   used by the win32 harness, and as tbBlob's --x86-dll
```

## What uses it

- `tests\harness-cairo\build-project.ps1` runs tbBlob on `include\cairo\cairo.h` with every C backend
  header through `--also`, the x64 `bin` folder as `<dll>` (both DLLs, bound by their export tables,
  D-053) and the x86 one as `--x86-dll`. `cairo-dwrite.h` is passed on purpose: it is C++ only, so it
  is skipped and reported (D-057, D-059). The harness loads the matching DLLs from these trees for
  win32 and win64.
- tbBlob's integration test `Tests_EndToEnd` (cairo counts) runs the same generation.
