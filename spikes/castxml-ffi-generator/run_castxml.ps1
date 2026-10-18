# SPIKE throwaway: regenerate the libgit2 CastXML output for x86 and x64, plus the macro dump.
# Usage: powershell -ExecutionPolicy Bypass -File run_castxml.ps1
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path
$castxml = "$root\CastXML\vcpkg_installed\x64-windows\tools\castxml\bin\castxml.exe"
$include = "$root\libgit2\vcpkg_installed\x64-windows\include"
$vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
$out = "$here\xml"
New-Item -ItemType Directory -Force $out | Out-Null

function Invoke-InVcvars($arch, $castxmlArgs) {
    $vcvars = "$vsPath\VC\Auxiliary\Build\vcvars$arch.bat"
    cmd /c "`"$vcvars`" >nul 2>nul && `"$castxml`" $castxmlArgs"
    if ($LASTEXITCODE -ne 0) { throw "castxml failed for vcvars$arch (exit $LASTEXITCODE)" }
}

foreach ($a in @(@{vc = '32'; name = 'x86' }, @{vc = '64'; name = 'x64' })) {
    Invoke-InVcvars $a.vc "--castxml-cc-msvc-c cl --castxml-output=1 -I `"$include`" -o `"$out\git2_$($a.name).xml`" `"$include\git2.h`""
    Write-Host "wrote $out\git2_$($a.name).xml"
}
Invoke-InVcvars '64' "--castxml-cc-msvc-c cl -E -dM -I `"$include`" `"$include\git2.h`" > `"$out\git2_macros.txt`""
Write-Host "wrote $out\git2_macros.txt"
