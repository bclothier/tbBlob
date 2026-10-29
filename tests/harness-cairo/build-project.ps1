# Builds the cairo runtime harness project (tasks 29, 30; D-055):
#   1. runs tbBlob on cairo 1.18.4's cairo.h plus every C backend header (x64 vcpkg include folder)
#      into tests\harness-cairo\bindings\, with the x64 and x86 bin folders: functions bind to
#      cairo-2.dll or cairo-script-interpreter-2.dll by their export tables (D-053). cairo-dwrite.h
#      is passed on purpose: it is C++ only, so it is skipped and reported (D-057, D-059).
#   2. assembles tests\harness-cairo\project\ = Settings + Sources\ (harness) + Results.twin and
#      Utf8.twin shared from tests\harness-fixture\Sources + bindings\Source\*.twin
#   3. imports it into tests\harness-cairo\harness_cairo.twinproj with tBImportExport
# Then build harness_cairo.twinproj as win32 and win64; run-all.ps1 runs both EXEs.
# Usage: powershell -ExecutionPolicy Bypass -File tests\harness-cairo\build-project.ps1
# -BindingsOnly <folder>: only generate the bindings into that folder and stop.
# The same command line is used by tbBlob's integration test (Tests_EndToEnd, cairo counts).
param([string]$BindingsOnly = '')
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path
$tbBlob = "$root\Build\tbBlob_win64.exe"
$castxml = "$root\CastXML\vcpkg_installed\x64-windows\tools\castxml\bin\castxml.exe"
$tool = "$root\tools\impexp\Build\tBImportExport_win64.exe"
$x64 = "$root\cairo\vcpkg_installed\x64-windows"
$bin86 = "$root\cairo\vcpkg_installed_x86\x86-windows\bin"
if (-not (Test-Path "$x64\include\cairo\cairo.h") -or -not (Test-Path "$bin86\cairo-2.dll")) {
    Write-Host "FAILED: cairo is not installed in this clone. From $root\cairo run:"
    Write-Host "    vcpkg install --triplet x64-windows"
    Write-Host "    vcpkg install --triplet x86-windows --x-install-root=vcpkg_installed_x86"
    Write-Host "  (see cairo\README.md)"
    exit 1
}

# 1. Bindings: generated fresh, then copied over the old ones only where changed (harness-sync.ps1)
. "$root\tests\harness-sync.ps1"
$new = if ($BindingsOnly) { $BindingsOnly } else { "$here\bindings.new" }
Remove-Folder $new
$also = @()
foreach ($h in 'cairo-pdf.h', 'cairo-ps.h', 'cairo-svg.h', 'cairo-script.h', 'cairo-tee.h', 'cairo-win32.h', 'cairo-ft.h', 'cairo-script-interpreter.h', 'cairo-dwrite.h') {
    $also += '--also'; $also += $h
}
& $tbBlob "$x64\include\cairo" cairo.h "$x64\bin" $new --castxml $castxml --x86-dll $bin86 -I "$x64\include" --name Cairo @also
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: tbBlob exit $LASTEXITCODE"; exit 1 }
if ($BindingsOnly) { exit 0 }
$changed = Sync-Bindings $new "$here\bindings"
Remove-Folder $new   # nothing left behind to be held open next time
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
$twinproj = "$here\harness_cairo.twinproj"
$ownNewest = Get-ChildItem "$here\Settings", "$here\Sources", "$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin" -File -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($changed -eq 0 -and (Test-Path $twinproj) -and $ownNewest.LastWriteTime -lt (Get-Item $twinproj).LastWriteTime) {
    Write-Host "harness_cairo.twinproj is current (generated code unchanged) -- no recompile needed."
    exit 0
}
$out = & $tool import $twinproj $proj --overwrite
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
if (($code -ne 0 -and $code -ne 6) -or -not ($out -match '\.\.\. DONE')) {
    Write-Host "IMPORT FAILED (exit $code)"
    exit 1
}
Write-Host "harness_cairo.twinproj rebuilt -- build it as win32 and win64."
