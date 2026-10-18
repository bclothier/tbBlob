# SPIKE-10 throwaway: builds threadprobe.dll for x86 (bin\win32) and x64 (bin\win64), and imports
# the probe project (threadprobe.twinproj) with tBImportExport.
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path
$vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
foreach ($a in @(@{ name = 'win32'; vc = 'vcvars32.bat' }, @{ name = 'win64'; vc = 'vcvars64.bat' })) {
    $bin = "$here\bin\$($a.name)"
    New-Item -ItemType Directory -Force "$bin\obj" | Out-Null
    cmd /c "`"$vs\VC\Auxiliary\Build\$($a.vc)`" >nul 2>nul && cl /nologo /W4 /LD `"$here\threadprobe.c`" /Fo`"$bin\obj\\`" /Fe`"$bin\threadprobe.dll`" > `"$bin\build.log`" 2>&1"
    if ($LASTEXITCODE -ne 0) { Get-Content "$bin\build.log"; throw "build failed: $($a.name)" }
    Write-Host "built $bin\threadprobe.dll"
}
$proj = "$here\project"
if (Test-Path $proj) { Remove-Item -Recurse -Force $proj }
New-Item -ItemType Directory -Force "$proj\Sources" | Out-Null
foreach ($d in 'Resources', 'Miscellaneous', 'ImportedTypeLibraries', 'Packages') { New-Item -ItemType Directory -Force "$proj\$d" | Out-Null }
Copy-Item "$here\Settings" "$proj\Settings"
Copy-Item "$here\Sources\*.twin" "$proj\Sources\"
& "$root\tools\impexp\Build\tBImportExport_win64.exe" import "$here\threadprobe.twinproj" $proj --overwrite | Select-Object -Last 1
Write-Host "threadprobe.twinproj ready -- compile win32 and win64, then run Build\threadprobe_<arch>.exe (and with argument risky)"
