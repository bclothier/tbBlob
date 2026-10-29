# Builds tbfixture.dll and test_tbfixture.exe for x86 (bin\win32) and x64 (bin\win64) with MSVC,
# runs the C tests for both, and checks each DLL (PE machine type, exports).
# Usage: powershell -ExecutionPolicy Bypass -File tests\fixture-c\build.ps1 [-VsPath <VS install>]
#   -VsPath overrides vswhere (used by the integration test of a missing toolchain).
param([string]$VsPath = '')
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$failed = 0

function Fail($msg) { Write-Host "FAIL $msg"; $script:failed++ }

if (-not $VsPath) {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vswhere)) { Write-Host "ERROR: vswhere.exe not found ($vswhere) -- install Visual Studio or Build Tools"; exit 4 }
    $VsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
}
$vcvarsDir = "$VsPath\VC\Auxiliary\Build"
if (-not (Test-Path "$vcvarsDir\vcvars64.bat")) { Write-Host "ERROR: MSVC vcvars not found under '$vcvarsDir' -- install the C++ build tools"; exit 4 }

$archs = @(
    @{ name = 'win32'; vcvars = 'vcvars32.bat'; machine = '14C' },
    @{ name = 'win64'; vcvars = 'vcvars64.bat'; machine = '8664' }
)
foreach ($a in $archs) {
    $bin = "$here\bin\$($a.name)"
    $obj = "$bin\obj"
    New-Item -ItemType Directory -Force $obj | Out-Null
    $vc = "$vcvarsDir\$($a.vcvars)"
    # /wd4121 /wd4324: TBF_PACKED2 and TBF_ALIGNED are deliberately packing- and alignment-sensitive.
    $cl = "cl /nologo /W4 /WX /wd4121 /wd4324 /std:c11 /utf-8"
    # tbfixture_win.c: functions using outside types (D-054): the Windows SDK and ..\fixture-outside\outlib.h
    $buildDll = "$cl /I`"$here\..\fixture-outside`" /LD `"$here\tbfixture.c`" `"$here\tbfixture_win.c`" /Fo`"$obj\\`" /Fe`"$bin\tbfixture.dll`" /link /DEF:`"$here\tbfixture.def`" user32.lib gdi32.lib"
    $buildTest = "$cl `"$here\test_tbfixture.c`" `"$bin\tbfixture.lib`" /Fo`"$obj\\`" /Fe`"$bin\test_tbfixture.exe`""
    # A second DLL of the same library, using tbfixture.h's types (D-053).
    $buildExt = "$cl /LD `"$here\tbfixture_ext.c`" /Fo`"$obj\\`" /Fe`"$bin\tbfixture_ext.dll`""
    $log = "$bin\build.log"
    # All redirection inside cmd: vcvars writes noise to stderr, which PowerShell would treat as an error.
    cmd /c "`"$vc`" >nul 2>nul && ($buildDll && $buildTest && $buildExt) > `"$log`" 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Get-Content $log | ForEach-Object { Write-Host "  $_" }
        Fail "$($a.name): build"
        continue
    }
    Write-Host "built $($a.name): $bin\tbfixture.dll, tbfixture_ext.dll, test_tbfixture.exe"

    # Integration check: PE machine type of the DLL.
    $bytes = [IO.File]::ReadAllBytes("$bin\tbfixture.dll")
    $pe = [BitConverter]::ToInt32($bytes, 0x3C)
    $machine = '{0:X}' -f [BitConverter]::ToUInt16($bytes, $pe + 4)
    if ($machine -ne $a.machine) { Fail "$($a.name): PE machine $machine, expected $($a.machine)" } else { Write-Host "PASS $($a.name): PE machine $machine" }

    # Integration check: every function declared in the header is exported. On x86, __stdcall
    # exports are decorated (_name@N) unless tbfixture.def exports them (D-026).
    cmd /c "`"$vc`" >nul 2>nul && dumpbin /nologo /exports `"$bin\tbfixture.dll`" > `"$bin\exports.txt`" 2>&1"
    $exported = @{}
    Get-Content "$bin\exports.txt" | ForEach-Object {
        if ($_ -match '^\s+\d+\s+[0-9A-F]+\s+[0-9A-F]{8}\s+(\S+)') { $exported[$Matches[1]] = $true }
    }
    $header = (Get-Content "$here\tbfixture.h" -Raw) + (Get-Content "$here\tbfixture_sys.h" -Raw) + (Get-Content "$here\tbfixture_win.h" -Raw)
    $declared = [regex]::Matches($header, '(?m)^TBF_(?:DEF_)?API\s+[^;{]*?\b(\w+)\s*\(') | ForEach-Object { $_.Groups[1].Value }
    $missing = @()
    # tbf_not_exported is declared but deliberately not defined: it must NOT be exported (D-031).
    $notExported = @('tbf_not_exported')
    foreach ($fn in $notExported) {
        if ($exported.ContainsKey($fn)) { Fail "$($a.name): $fn must not be exported" } else { Write-Host "PASS $($a.name): $fn is not exported (as designed)" }
    }
    $declared = @($declared | Where-Object { $notExported -notcontains $_ })
    foreach ($fn in $declared) {
        if ($exported.ContainsKey($fn)) { continue }
        $decorated = $exported.Keys | Where-Object { $_ -match "^_$fn@\d+$" }
        if ($decorated) { Write-Host "INFO $($a.name): $fn is exported decorated as $decorated" } else { $missing += $fn }
    }
    # Both stdcall forms must be present as designed: decorated tbf_std_add, undecorated tbf_std_sub.
    $wantAdd = if ($a.name -eq 'win32') { '_tbf_std_add@8' } else { 'tbf_std_add' }
    if ($exported.ContainsKey($wantAdd) -and $exported.ContainsKey('tbf_std_sub') -and -not $exported.ContainsKey('_tbf_std_sub@8')) {
        Write-Host "PASS $($a.name): stdcall exports $wantAdd and tbf_std_sub"
    } else { Fail "$($a.name): expected stdcall exports $wantAdd and tbf_std_sub (only)" }
    if ($missing.Count -gt 0) { Fail "$($a.name): not exported: $($missing -join ', ')" } else { Write-Host "PASS $($a.name): all $($declared.Count) header functions exported" }

    # tbfixture_ext.dll: its two defined functions and tbx_hidden (declared in no header) are
    # exported; tbx_not_built (declared, not defined) is not (D-053).
    cmd /c "`"$vc`" >nul 2>nul && dumpbin /nologo /exports `"$bin\tbfixture_ext.dll`" > `"$bin\exports_ext.txt`" 2>&1"
    $extExported = @{}
    Get-Content "$bin\exports_ext.txt" | ForEach-Object {
        if ($_ -match '^\s+\d+\s+[0-9A-F]+\s+[0-9A-F]{8}\s+(\S+)') { $extExported[$Matches[1]] = $true }
    }
    $wantExt = 'tbx_hidden,tbx_scale_point,tbx_version'
    $gotExt = (@($extExported.Keys) | Sort-Object) -join ','
    if ($gotExt -eq $wantExt) { Write-Host "PASS $($a.name): tbfixture_ext.dll exports $wantExt (not tbx_not_built)" }
    else { Fail "$($a.name): tbfixture_ext.dll exports $gotExt, expected $wantExt" }

    # Run the C tests.
    $testOut = & "$bin\test_tbfixture.exe" 2>&1
    $testCode = $LASTEXITCODE
    $testOut | ForEach-Object { Write-Host "  [$($a.name)] $_" }
    if ($testCode -ne 0) { Fail "$($a.name): C tests ($testCode failing)" } else { Write-Host "PASS $($a.name): C tests" }
}

if ($failed -gt 0) { Write-Host "build.ps1: $failed failure(s)"; exit 1 }
Write-Host "build.ps1: all passed"
exit 0
