# Full regression run (task list: <full suite cmd>). Refuses to report on a stale tbBlob build.
# Usage: powershell -ExecutionPolicy Bypass -File tests\run-all.ps1
# Later tasks add suites (fixture-c, harness-fixture, harness-libgit2) below.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..").Path
$results = [ordered]@{}

# 1. Keep tbBlob.twinproj in step with Source\ (harmless if nothing changed).
& powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\import.ps1" | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "FAIL import: tests\import.ps1 failed"; exit 1 }

# 2. Stale-build check: the EXE must be newer than every file in Source\.
$exe = "$root\Build\tbBlob_win64.exe"
$newest = Get-ChildItem "$root\Source" -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not (Test-Path $exe)) {
    Write-Host "STALE: $exe does not exist -- compile tbBlob.twinproj as win64 in the IDE."
    exit 2
}
$built = (Get-Item $exe).LastWriteTime
if ($built -lt $newest.LastWriteTime) {
    Write-Host "STALE: $exe ($built) is older than $($newest.FullName) ($($newest.LastWriteTime)) -- recompile win64 in the IDE."
    exit 2
}

# 3. tbBlob unit + integration tests.
$out = & $exe --self-test --integration 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
$results['tbBlob --self-test --integration'] = ($code -eq 0)

# 4. tbfixture C library: build x86/x64, C tests, PE/export checks; then toolchain error handling.
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\fixture-c\build.ps1" 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
$results['fixture-c build + C tests'] = ($code -eq 0)
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\fixture-c\test_build_errors.ps1" 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
$results['fixture-c missing-toolchain handling'] = ($code -eq 0)

# 5-6. Runtime harnesses (tasks 11, 12): both EXEs must be newer than the bindings and the harness
#      sources; bindings made by an older tbBlob are regenerated first; each EXE is run and must log no FAIL and a
#      summary line (a missing summary means the harness crashed).
function Test-Harness($folder, $project, $sharedSources) {
    $h = "$root\tests\$folder"
    $stale = $null
    $stamp = "$h\bindings\tbblob.sha256"
    $current = (Get-FileHash $exe -Algorithm SHA256).Hash
    if (-not (Test-Path $stamp) -or (Get-Content $stamp -Raw) -ne $current) {
        # tbBlob changed since the bindings were made: regenerate. Unchanged modules keep their
        # timestamps (harness-sync.ps1), so the harness EXEs go stale only if generated code changed.
        Write-Host "regenerating $folder bindings (tbBlob was rebuilt)..."
        $bp = & powershell -NoProfile -ExecutionPolicy Bypass -File "$h\build-project.ps1" 2>&1
        if ($LASTEXITCODE -ne 0) { $bp | ForEach-Object { Write-Host "  $_" }; $stale = "tests\$folder\build-project.ps1 failed" }
        else { $bp | Where-Object { $_ -match 'generated modules changed|no recompile|rebuilt --' } | ForEach-Object { Write-Host "  $_" } }
    }
    $inputs = @(Get-ChildItem (@("$h\Sources", "$h\bindings\Source") + $sharedSources) -File -ErrorAction SilentlyContinue)
    foreach ($arch in 'win32', 'win64') {
        $name = "$folder $arch"
        $hexe = "$h\Build\${project}_$arch.exe"
        if ($stale) { Write-Host "STALE: $stale"; $results[$name] = $false; continue }
        if (-not (Test-Path $hexe)) { Write-Host "STALE: $hexe does not exist -- compile $project.twinproj as $arch"; $results[$name] = $false; continue }
        $newestIn = $inputs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ((Get-Item $hexe).LastWriteTime -lt $newestIn.LastWriteTime) {
            Write-Host "STALE: $hexe is older than $($newestIn.FullName) -- recompile $project.twinproj as $arch"
            $results[$name] = $false; continue
        }
        $resFile = "$h\results\results-$arch.txt"
        if (Test-Path $resFile) { Remove-Item $resFile }
        & $hexe | Out-Null
        if (-not (Test-Path $resFile)) { Write-Host "FAIL ${name}: no results file"; $results[$name] = $false; continue }
        $lines = @(Get-Content $resFile -Encoding UTF8)
        $lines | Where-Object { $_ -match '^(FAIL|INFO)' } | ForEach-Object { Write-Host "[$folder $arch] $_" }
        $hasSummary = [bool]($lines -match '^INFO 0\.summary')
        if (-not $hasSummary) { Write-Host "[$folder $arch] no summary line: the harness stopped early (crash?) after: $($lines[-1])" }
        $results[$name] = $hasSummary -and -not ($lines -match '^FAIL')
    }
}

Test-Harness 'harness-fixture' 'harness_fixture' @()
# The libgit2 harness needs its fixture repositories (git.exe); recreate them for a clean run.
& powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\harness-libgit2\setup_fixture.ps1" | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "FAIL harness-libgit2: setup_fixture.ps1 failed" }
Test-Harness 'harness-libgit2' 'harness_libgit2' @("$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin")
# cairo (tasks 29, 30; D-055): two DLLs, outside types, a C++-only header skipped
Test-Harness 'harness-cairo' 'harness_cairo' @("$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin")

# 7. The verdict script's own tests (task 13): its judge on fake inputs.
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\verdict.ps1" -SelfTest 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
$results['verdict.ps1 -SelfTest'] = ($code -eq 0)

# 8. The distributable (task 15): package to a temp folder and verify it (layout, licences, docs,
#    --check with the bundled CastXML, a generation from the package).
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tools\package.ps1" -SelfTest 2>&1
$code = $LASTEXITCODE
$out | ForEach-Object { Write-Host $_ }
$results['tools\package.ps1 -SelfTest'] = ($code -eq 0)

# Summary
Write-Host ""
Write-Host "== run-all summary =="
$failed = 0
foreach ($k in $results.Keys) {
    if ($results[$k]) { Write-Host "PASS $k" } else { Write-Host "FAIL $k"; $failed++ }
}
if ($failed -gt 0) { exit 1 }
exit 0
