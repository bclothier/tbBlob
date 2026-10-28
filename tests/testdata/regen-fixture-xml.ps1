# Regenerates the CastXML snapshots of tests\fixture-c\tbfixture.h used by unit tests
# (tests\testdata\fixture\tbfixture_x86.xml, tbfixture_x64.xml, tbfixture_macros_x86.txt,
# tbfixture_macros_x64.txt -- one macro dump per architecture, D-030; tbfixture_x64.i, the
# preprocessed header that parameter names are read from, D-060).
# Run after changing tbfixture.h, then rerun the self-tests.
# Usage: powershell -ExecutionPolicy Bypass -File tests\testdata\regen-fixture-xml.ps1
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$castxml = "$root\CastXML\vcpkg_installed\x64-windows\tools\castxml\bin\castxml.exe"
$header = "$root\tests\fixture-c\tbfixture.h"
$out = "$root\tests\testdata\fixture"
$vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
New-Item -ItemType Directory -Force $out | Out-Null
$script = "$out\regen.cmd"
@"
@call "$vs\VC\Auxiliary\Build\vcvars32.bat" >nul 2>nul
"$castxml" --castxml-cc-msvc-c cl --castxml-output=1 -I "$root\tests\fixture-c" -o "$out\tbfixture_x86.xml" "$header" || exit /b 1
"$castxml" --castxml-cc-msvc-c cl -E -dM -o "$out\tbfixture_macros_x86.txt" -I "$root\tests\fixture-c" "$header" || exit /b 1
@call "$vs\VC\Auxiliary\Build\vcvars64.bat" >nul 2>nul
"$castxml" --castxml-cc-msvc-c cl --castxml-output=1 -I "$root\tests\fixture-c" -o "$out\tbfixture_x64.xml" "$header" || exit /b 1
"$castxml" --castxml-cc-msvc-c cl -E -dM -o "$out\tbfixture_macros_x64.txt" -I "$root\tests\fixture-c" "$header" || exit /b 1
"$castxml" --castxml-cc-msvc-c cl -E -std=c11 -o "$out\tbfixture_x64.i" -I "$root\tests\fixture-c" "$header" || exit /b 1
"@ | Set-Content -Path $script -Encoding ascii
cmd /c "`"$script`""
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED"; exit 1 }
Remove-Item $script
# CastXML writes absolute paths. Commit {REPO} instead of this clone's root, so the snapshots work in
# any clone; the tests put the real root back (SelfTest.Fixture, D-051).
# The .i file's line markers are C strings, so there the root's backslashes are doubled.
foreach ($name in 'tbfixture_x86.xml', 'tbfixture_x64.xml', 'tbfixture_x64.i') {
    $file = "$out\$name"
    $text = [IO.File]::ReadAllText($file)
    $escaped = $root.Replace('\', '\\')
    if (-not ($text.Contains($root) -or $text.Contains($escaped))) { Write-Host "FAILED: $name does not contain $root"; exit 1 }
    [IO.File]::WriteAllText($file, $text.Replace($escaped, '{REPO}').Replace($root, '{REPO}'), (New-Object Text.UTF8Encoding($false)))
}
Get-ChildItem $out | ForEach-Object { Write-Host "$($_.Name) $($_.Length)" }
