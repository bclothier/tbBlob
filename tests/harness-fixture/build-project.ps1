# Builds the tbfixture runtime harness project (task 11):
#   1. runs tbBlob on tests\fixture-c\tbfixture.h (+ --also tbfixture_sys.h, D-033, and tbfixture_ext.h,
#      D-053) with the bin\win64 and bin\win32 DLL folders into tests\harness-fixture\bindings\
#   2. assembles tests\harness-fixture\project\ = Settings + Sources\ (harness) + bindings\Source\*.twin
#   3. imports it into tests\harness-fixture\harness_fixture.twinproj with tBImportExport (D-023:
#      packaging is the harness's job, not tbBlob's)
# Then compile harness_fixture.twinproj in the IDE as win32 and win64; run-all.ps1 runs both EXEs.
# Usage: powershell -ExecutionPolicy Bypass -File tests\harness-fixture\build-project.ps1
# -BindingsOnly <folder>: only generate the bindings into that folder and stop (tests\verdict.ps1
#   regenerates with exactly these arguments to check for hand edits).
param([string]$BindingsOnly = '')
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path
$tbBlob = "$root\Build\tbBlob_win64.exe"
$castxml = "$root\CastXML\vcpkg_installed\x64-windows\tools\castxml\bin\castxml.exe"
$tool = "$root\tools\impexp\Build\tBImportExport_win64.exe"

# 1. Bindings: generated fresh, then copied over the old ones only where changed (harness-sync.ps1)
. "$root\tests\harness-sync.ps1"
$new = if ($BindingsOnly) { $BindingsOnly } else { "$here\bindings.new" }
if (Test-Path $new) { Remove-Item -Recurse -Force $new }
# The DLL folders (D-053): each function binds to tbfixture.dll or tbfixture_ext.dll by their export tables.
& $tbBlob "$root\tests\fixture-c" tbfixture.h "$root\tests\fixture-c\bin\win64" $new --castxml $castxml --x86-dll "$root\tests\fixture-c\bin\win32" --also tbfixture_sys.h --also tbfixture_ext.h --also tbfixture_win.h -I "$root\tests\fixture-outside"
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
Copy-Item "$here\bindings\Source\*.twin" "$proj\Sources\"

# 3. Import -- only when something the project is made of changed (keeps an open IDE project as is)
$twinproj = "$here\harness_fixture.twinproj"
$ownNewest = Get-ChildItem "$here\Settings", "$here\Sources" -File -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($changed -eq 0 -and (Test-Path $twinproj) -and $ownNewest.LastWriteTime -lt (Get-Item $twinproj).LastWriteTime) {
    Write-Host "harness_fixture.twinproj is current (generated code unchanged) -- no recompile needed."
    exit 0
}
$out = & $tool import "$here\harness_fixture.twinproj" $proj --overwrite
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
if (($code -ne 0 -and $code -ne 6) -or -not ($out -match '\.\.\. DONE')) {
    Write-Host "IMPORT FAILED (exit $code)"
    exit 1
}
Write-Host "harness_fixture.twinproj rebuilt -- open it in the IDE, compile win32 and win64."
