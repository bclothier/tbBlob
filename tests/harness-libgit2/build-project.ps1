# Builds the libgit2 runtime harness project (task 12):
#   1. runs tbBlob on libgit2's git2.h plus every git2/sys/*.h (x64 vcpkg include folder) into
#      tests\harness-libgit2\bindings\,
#      reading the x86 git2.dll's exports (--x86-dll, D-026)
#   2. assembles tests\harness-libgit2\project\ = Settings + Sources\ (harness) + Results.twin and
#      Utf8.twin shared from tests\harness-fixture\Sources + bindings\Source\*.twin
#   3. imports it into tests\harness-libgit2\harness_libgit2.twinproj with tBImportExport
#   4. creates the fixture repositories (setup_fixture.ps1)
# Then compile harness_libgit2.twinproj in the IDE as win32 and win64; run-all.ps1 runs both EXEs.
# Usage: powershell -ExecutionPolicy Bypass -File tests\harness-libgit2\build-project.ps1
# -BindingsOnly <folder>: only generate the bindings into that folder and stop (tests\verdict.ps1
#   regenerates with exactly these arguments to check for hand edits).
param([string]$BindingsOnly = '')
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path
$tbBlob = "$root\Build\tbBlob_win64.exe"
$castxml = "$root\CastXML\vcpkg_installed\x64-windows\tools\castxml\bin\castxml.exe"
$tool = "$root\tools\impexp\Build\tBImportExport_win64.exe"
$include = "$root\libgit2\vcpkg_installed\x64-windows\include"
$x86dll = "$root\libgit2\vcpkg_installed_x86\x86-windows\bin\git2.dll"

# 1. Bindings: generated fresh, then copied over the old ones only where changed (harness-sync.ps1)
. "$root\tests\harness-sync.ps1"
$new = if ($BindingsOnly) { $BindingsOnly } else { "$here\bindings.new" }
if (Test-Path $new) { Remove-Item -Recurse -Force $new }
# git2.h plus every git2/sys/*.h (D-033); sys/stream.h needs ssize_t, which MSVC lacks (D-032)
$also = @(Get-ChildItem "$include\git2\sys\*.h" | Sort-Object Name | ForEach-Object { "--also"; "git2\sys\$($_.Name)" })
& $tbBlob $include git2.h git2.dll $new --castxml $castxml --x86-dll $x86dll -D ssize_t=intptr_t @also
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: tbBlob exit $LASTEXITCODE"; exit 1 }
if ($BindingsOnly) { exit 0 }
$changed = Sync-Bindings $new "$here\bindings"
Set-Content "$here\bindings\tbblob.sha256" (Get-TbBlobHash $tbBlob) -Encoding ascii -NoNewline
Write-Host "generated modules changed: $changed"

# 2. Project folder
$proj = "$here\project"
if (Test-Path $proj) { Remove-Item -Recurse -Force $proj }
New-Item -ItemType Directory -Force "$proj\Sources" | Out-Null
foreach ($d in 'Resources', 'Miscellaneous', 'ImportedTypeLibraries', 'Packages') {
    New-Item -ItemType Directory -Force "$proj\$d" | Out-Null
}
Copy-Item "$here\Settings" "$proj\Settings"
Copy-Item "$here\Sources\*.twin" "$proj\Sources\"
Copy-Item "$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin" "$proj\Sources\"
Copy-Item "$here\bindings\Source\*.twin" "$proj\Sources\"

# 3. Import -- only when something the project is made of changed (keeps an open IDE project as is)
$twinproj = "$here\harness_libgit2.twinproj"
$ownNewest = Get-ChildItem "$here\Settings", "$here\Sources", "$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin" -File -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$skipImport = $changed -eq 0 -and (Test-Path $twinproj) -and $ownNewest.LastWriteTime -lt (Get-Item $twinproj).LastWriteTime
if ($skipImport) { Write-Host "harness_libgit2.twinproj is current (generated code unchanged) -- no recompile needed." }
if (-not $skipImport) {
    $out = & $tool import $twinproj $proj --overwrite
    $code = $LASTEXITCODE
    $out | ForEach-Object { Write-Host $_ }
    if (($code -ne 0 -and $code -ne 6) -or -not ($out -match '\.\.\. DONE')) {
        Write-Host "IMPORT FAILED (exit $code)"
        exit 1
    }
}

# 4. Fixture repositories
& powershell -NoProfile -ExecutionPolicy Bypass -File "$here\setup_fixture.ps1"
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: setup_fixture.ps1"; exit 1 }
if (-not $skipImport) { Write-Host "harness_libgit2.twinproj rebuilt -- open it in the IDE, compile win32 and win64." }
