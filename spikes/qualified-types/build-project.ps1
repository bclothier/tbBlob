# SPIKE-11 throwaway: assembles the probe (project\ = Settings + Sources\ + Packages\ShadowPkg\)
# and imports it into qualprobe.twinproj; then compiles each variants\*.twin added to the same
# project, compile-only, and writes what the compiler said to results\variants.txt.
# Usage: powershell -ExecutionPolicy Bypass -File spikes\qualified-types\build-project.ps1
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$tblaunch = 'C:\Projects\TwinBasic\tbLauncher\Build\tblaunch_win64.exe'
$ide = 'C:\TwinBasic\twinBASIC.exe'

function New-ProjectFolder($dest, $extra) {
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    New-Item -ItemType Directory -Force "$dest\Sources" | Out-Null
    foreach ($d in 'Resources', 'Miscellaneous', 'ImportedTypeLibraries', 'Packages') { New-Item -ItemType Directory -Force "$dest\$d" | Out-Null }
    Copy-Item "$here\Settings" "$dest\Settings"
    Copy-Item "$here\Sources\*.twin" "$dest\Sources\"
    # a variant is one .twin file (copied as VariantUse.twin) or a folder of them (copied as they are)
    if ($extra) {
        if (Test-Path $extra -PathType Container) { Copy-Item "$extra\*.twin" "$dest\Sources\" }
        else { Copy-Item $extra "$dest\Sources\VariantUse.twin" }
    }
    $pkg = "$dest\Packages\ShadowPkg"
    New-Item -ItemType Directory -Force "$pkg\Sources" | Out-Null
    foreach ($d in 'Resources', 'Miscellaneous', 'ImportedTypeLibraries', 'Packages') { New-Item -ItemType Directory -Force "$pkg\$d" | Out-Null }
    Copy-Item "$here\package\ShadowPkg\Settings" "$pkg\Settings"
    Copy-Item "$here\package\ShadowPkg\Sources\*.twin" "$pkg\Sources\"
}

New-ProjectFolder "$here\project" $null
& $tblaunch import "$here\qualprobe.twinproj" "$here\project" --overwrite | Select-Object -Last 1

New-Item -ItemType Directory -Force "$here\results" | Out-Null
# tblaunch prints a version note on stderr; under 'Stop' PowerShell would treat it as a failure
$ErrorActionPreference = 'Continue'
$report = @()
foreach ($v in Get-ChildItem "$here\variants" | Sort-Object Name) {
    $dir = "$here\variant.work\$($v.BaseName)"
    New-ProjectFolder $dir $v.FullName
    $out = & $tblaunch compile $dir --arch win64 --ide $ide --compile-timeout 120 2>&1 | Where-Object { $_ -notmatch '^tblaunch: note' }
    $report += "== $($v.Name): exit $LASTEXITCODE"
    $report += $out | ForEach-Object { "   $_" }
}
$report | Set-Content "$here\results\variants.txt" -Encoding utf8
$report | ForEach-Object { Write-Host $_ }
Write-Host "qualprobe.twinproj ready -- build win32 and win64, then run Build\qualprobe_<arch>.exe"
