# Rebuilds tbBlob.twinproj from Source\ (the source of truth, D-010). Run before every compile.
# Usage: powershell -ExecutionPolicy Bypass -File tests\import.ps1
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..").Path
$tool = "$root\tools\impexp\Build\tBImportExport_win64.exe"
$out = & $tool import "$root\tbBlob.twinproj" "$root\Source" --overwrite
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
if (($code -ne 0 -and $code -ne 6) -or -not ($out -match '\.\.\. DONE')) {
    Write-Host "IMPORT FAILED (exit $code)"
    exit 1
}
Write-Host "tbBlob.twinproj rebuilt from Source\ -- reopen it in the IDE (close/reopen if open), compile win64."
