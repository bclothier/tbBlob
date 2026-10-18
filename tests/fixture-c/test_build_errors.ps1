# Integration test of build.ps1's toolchain handling: a missing MSVC install must fail clearly
# (exit 4, message naming what is missing) instead of producing a confusing compiler error.
# Usage: powershell -ExecutionPolicy Bypass -File tests\fixture-c\test_build_errors.ps1
$ErrorActionPreference = 'Stop'
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot\build.ps1" -VsPath 'C:\no-such-visual-studio' 2>&1
$code = $LASTEXITCODE
$text = ($out | Out-String)
$failed = 0
if ($code -ne 4) { Write-Host "FAIL missing toolchain: exit $code, expected 4"; $failed++ } else { Write-Host "PASS missing toolchain: exit 4" }
if ($text -notmatch 'vcvars not found') { Write-Host "FAIL missing toolchain: message was: $text"; $failed++ } else { Write-Host "PASS missing toolchain: message names vcvars" }
exit $failed
