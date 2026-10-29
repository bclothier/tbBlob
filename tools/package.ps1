# Builds the tbBlob distributable (task 15.0, D-035): one folder to copy to another machine.
#   powershell -ExecutionPolicy Bypass -File tools\package.ps1                # -> dist\tbBlob\
#   powershell -ExecutionPolicy Bypass -File tools\package.ps1 -Out D:\tbBlob
#   powershell -ExecutionPolicy Bypass -File tools\package.ps1 -SelfTest      # package to a temp folder, verify, delete
# Layout:
#   tbBlob.exe                         (Build\tbBlob_win64.exe)
#   castxml\bin\castxml.exe            CastXML 0.6.5 from vcpkg (found automatically: D-035)
#   castxml\share\castxml\...          its clang resource headers (castxml.exe needs them)
#   licenses\                          CastXML's and LLVM's licences (tools\licenses\, D-047); NOTICE.md
#   README.md, docs\USAGE.md, docs\SETUP.md
# The package is verified: tbBlob --check must find the bundled CastXML and pass, a generation
# from the package must succeed, and every option and exit code of tbBlob --help must be in
# docs\USAGE.md. Visual Studio Build Tools are a prerequisite on the target machine (not bundled).
# Exit codes: 0 packaged and verified, 1 verification failed, 2 stale or missing inputs.
param([string]$Out = '', [switch]$SelfTest)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..").Path
$exe = "$root\Build\tbBlob_win64.exe"
$cx = "$root\CastXML\vcpkg_installed\x64-windows"

# Deletes a folder, retrying while files are briefly locked (antivirus scanning a freshly copied
# castxml.exe, a process still exiting). Cleanup never decides the result: warns if it can't.
function Remove-Folder($path) {
    for ($i = 1; $i -le 5; $i++) {
        try { if (Test-Path $path) { Remove-Item -Recurse -Force $path -ErrorAction Stop }; return }
        catch { Start-Sleep -Seconds 1 }
    }
    Write-Host "WARN could not delete $path (a file is still in use); delete it later"
}

function Assert-Inputs {
    if (-not (Test-Path $exe)) { Write-Host "ERROR: $exe does not exist -- compile tbBlob.twinproj as win64"; exit 2 }
    $newest = Get-ChildItem "$root\Source" -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ((Get-Item $exe).LastWriteTime -lt $newest.LastWriteTime) { Write-Host "ERROR: $exe is older than $($newest.FullName) -- recompile tbBlob.twinproj as win64"; exit 2 }
    foreach ($p in "$cx\tools\castxml\bin\castxml.exe", "$cx\tools\castxml\share\castxml\clang\include\stddef.h", "$cx\share\vcpkg-tool-castxml\copyright", "$PSScriptRoot\licenses\LLVM-LICENSE.txt") {
        if (-not (Test-Path $p)) {
            if ($p -like "$PSScriptRoot\*") { Write-Host "ERROR: $p does not exist -- restore it from git"; exit 2 }
            Write-Host "ERROR: $p does not exist -- CastXML is not installed in this clone. Install it with vcpkg:"
            Write-Host "    cd `"$root\CastXML`""
            Write-Host "    vcpkg install --triplet x64-windows"
            Write-Host "  See CastXML\README.md; to get vcpkg, docs\SETUP.md 'Getting vcpkg'."
            exit 2
        }
    }
}

function New-Package($dest) {
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    New-Item -ItemType Directory -Force "$dest\castxml\bin", "$dest\castxml\share", "$dest\licenses", "$dest\docs" | Out-Null
    Copy-Item $exe "$dest\tbBlob.exe"
    Copy-Item "$cx\tools\castxml\bin\castxml.exe" "$dest\castxml\bin\"
    Copy-Item "$cx\tools\castxml\share\castxml" "$dest\castxml\share\" -Recurse
    Copy-Item "$cx\share\vcpkg-tool-castxml\copyright" "$dest\licenses\CastXML-LICENSE.txt"
    Copy-Item "$PSScriptRoot\licenses\LLVM-LICENSE.txt" "$dest\licenses\LLVM-LICENSE.txt"
    [IO.File]::WriteAllText("$dest\licenses\NOTICE.md", @'
# Third-party software in this package

- **CastXML 0.6.5** (`castxml\`) -- Copyright 2013-2022 Kitware, Inc., Apache License 2.0
  (`CastXML-LICENSE.txt`). Prebuilt by Kitware, installed through vcpkg (`vcpkg-tool-castxml`).
- **LLVM / Clang 18.1.3**, built into `castxml.exe`, and the Clang resource headers in
  `castxml\share\castxml\clang\include` -- Apache License 2.0 with LLVM Exceptions
  (`LLVM-LICENSE.txt`, LLVM's `LICENSE.TXT` at tag `llvmorg-18.1.3`; each header also carries
  the notice).

Visual Studio / Build Tools and the Windows SDK are NOT included: they are installed separately
under Microsoft's licence (see docs\SETUP.md).
'@, (New-Object Text.UTF8Encoding($false)))
    foreach ($d in "README.md") { if (Test-Path "$root\$d") { Copy-Item "$root\$d" "$dest\$d" } }
    if (Test-Path "$root\docs") { Copy-Item "$root\docs\*.md" "$dest\docs\" }
}

# One line per failed check; empty when the package is good.
function Test-Package($dest) {
    $bad = @()
    foreach ($f in 'tbBlob.exe', 'castxml\bin\castxml.exe', 'castxml\share\castxml\clang\include\stddef.h',
                   'licenses\CastXML-LICENSE.txt', 'licenses\NOTICE.md', 'README.md', 'docs\USAGE.md', 'docs\SETUP.md') {
        if (-not (Test-Path "$dest\$f")) { $bad += "missing $f" }
    }
    # LLVM's licence text, not a link (Apache-2.0 4(a): castxml.exe contains LLVM/Clang; D-047)
    $llvm = "$dest\licenses\LLVM-LICENSE.txt"
    if (-not (Test-Path $llvm)) { $bad += "missing licenses\LLVM-LICENSE.txt" }
    else {
        $t = Get-Content $llvm -Raw
        foreach ($s in 'Apache License', 'Version 2.0, January 2004', 'LLVM Exceptions to the Apache 2.0 License') {
            if (-not $t.Contains($s)) { $bad += "licenses\LLVM-LICENSE.txt lacks '$s'" }
        }
    }
    if ((Test-Path "$dest\licenses\NOTICE.md") -and -not (Get-Content "$dest\licenses\NOTICE.md" -Raw).Contains('LLVM-LICENSE.txt')) { $bad += "licenses\NOTICE.md does not point at LLVM-LICENSE.txt" }
    if (Test-Path "$dest\tbBlob.exe") {
        # --check with no --castxml and no CASTXML: the bundled CastXML must be found and everything OK
        $saved = $env:CASTXML; $env:CASTXML = ''
        try {
            $check = & "$dest\tbBlob.exe" --check 2>&1 | ForEach-Object { "$_" }
            $code = $LASTEXITCODE
        } finally { $env:CASTXML = $saved }
        if ($code -ne 0) { $bad += "tbBlob --check exit $code`n" + ($check -join "`n") }
        if (-not ($check -match 'castxml\.exe .*\(bundled with tbBlob\)')) { $bad += "tbBlob --check did not use the bundled CastXML: " + (($check | Select-Object -First 1) -join '') }
        # a generation from the package
        $tmp = Join-Path $env:TEMP ("tbblob-package-" + [guid]::NewGuid().ToString('N'))
        $env:CASTXML = ''
        try {
            $gen = & "$dest\tbBlob.exe" "$root\tests\fixture-c" tbfixture.h tbfixture.dll "$tmp\out" 2>&1 | ForEach-Object { "$_" }
            $code = $LASTEXITCODE
        } finally { $env:CASTXML = $saved }
        if ($code -ne 0 -or -not (Test-Path "$tmp\out\Source\tbfixture.twin")) { $bad += "generating the fixture from the package failed (exit $code)`n" + ($gen -join "`n") }
        Remove-Folder $tmp
        # docs: every option and exit code of --help is in docs\USAGE.md
        if (Test-Path "$dest\docs\USAGE.md") {
            $help = & "$dest\tbBlob.exe" --help | ForEach-Object { "$_" }
            $usage = Get-Content "$dest\docs\USAGE.md" -Raw
            $options = @($help | ForEach-Object { if ($_ -match '^\s{2}(--?[a-zA-Z][\w-]*)') { $Matches[1] } } | Sort-Object -Unique)
            foreach ($o in $options) { if ($usage -notmatch ('`' + [regex]::Escape($o) + '[ `]')) { $bad += "docs\USAGE.md does not document $o" } }
            $inExits = $false
            foreach ($l in $help) {
                if ($l -match '^Exit codes') { $inExits = $true; continue }
                if ($inExits -and $l -match '^\s{2}(\d)\s') { if ($usage -notmatch ('\| ' + $Matches[1] + ' \|')) { $bad += "docs\USAGE.md has no row for exit code $($Matches[1])" } }
            }
            if ($options.Count -lt 8) { $bad += "only $($options.Count) options read from --help (parsing problem?)" }
        }
    }
    # docs: SETUP.md lists dependencies by purpose and says how to get vcpkg (D-049)
    if (Test-Path "$dest\docs\SETUP.md") {
        $setup = Get-Content "$dest\docs\SETUP.md" -Raw
        foreach ($h in '### To run tbBlob', '### To build tbBlob and the package', '### To run the tests', '## Getting vcpkg') {
            if (-not ($setup -match ('(?m)^' + [regex]::Escape($h) + '\s*$'))) { $bad += "docs\SETUP.md has no '$h' section" }
        }
        if ($setup -match 'Scripting Runtime') { $bad += "docs\SETUP.md still lists the Scripting Runtime (removed in task 17)" }
    }
    return $bad
}

Assert-Inputs
if ($SelfTest) {
    $dest = Join-Path $env:TEMP ("tbblob-dist-" + [guid]::NewGuid().ToString('N'))
} elseif ($Out) { $dest = $Out } else { $dest = "$root\dist\tbBlob" }
Write-Host "packaging into $dest ..."
New-Package $dest
$bad = @(Test-Package $dest)
if ($SelfTest) { Remove-Folder $dest }
if ($bad.Count -gt 0) {
    $bad | ForEach-Object { Write-Host "FAIL $_" }
    Write-Host "package: $($bad.Count) problem(s)"
    exit 1
}
Write-Host "PASS package: layout, licences, docs, tbBlob --check with the bundled CastXML, a generation from the package"
if (-not $SelfTest) {
    $mb = (Get-ChildItem $dest -Recurse -File | Measure-Object Length -Sum).Sum / 1MB
    $v = (Get-Item $exe).VersionInfo
    Write-Host ("package ready: {0} ({1:N0} MB) -- copy this folder to the target machine" -f $dest, $mb)
    Write-Host ("version {0}.{1}.{2}, {3}" -f $v.FileMajorPart, $v.FileMinorPart, $v.FileBuildPart, $v.Comments)
}
exit 0
