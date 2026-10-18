# The proof's verdict (task 13): computes PRD section 8's metrics 1-9 from the real artifacts and
# prints a Markdown table plus the verdict: works / works with listed limits / does not work.
#   powershell -ExecutionPolicy Bypass -File tests\verdict.ps1              # the real verdict
#   powershell -ExecutionPolicy Bypass -File tests\verdict.ps1 -Out f.md    # also write the table
#   powershell -ExecutionPolicy Bypass -File tests\verdict.ps1 -SelfTest    # judge on fake inputs
# Two halves: Get-Facts inspects the artifacts (EXEs, results, DLL exports, CastXML XML, a fresh
# regeneration); Invoke-Judge turns facts + results files + reports into verdicts. Only the judge
# reads results/reports, so -SelfTest exercises all of it with tests\testdata\verdict\<case>\.
# Exit codes: 0 verdict computed, 2 the inputs are missing or stale (no verdict), 1 self-test failed.
param([switch]$SelfTest, [string]$Out = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..").Path

# ---- judge -------------------------------------------------------------------------------------

function Resolve-In($baseDir, $path) {
    if ([IO.Path]::IsPathRooted($path)) { return $path }
    return Join-Path $baseDir $path
}

# A harness results file's lines; throws (no verdict) when it is missing, stale or incomplete.
function Read-Results($facts, $baseDir, $harness, $arch) {
    $r = $facts.results.$harness.$arch
    $p = Resolve-In $baseDir $r.path
    if (-not (Test-Path $p)) { throw "results missing: $p -- run tests\run-all.ps1 first" }
    if (-not $r.fresh) { throw "results stale: $p is older than its harness EXE -- run tests\run-all.ps1 first" }
    $lines = @(Get-Content $p -Encoding UTF8)
    if (-not ($lines -match '^INFO 0\.summary')) { throw "results incomplete (no summary line; did the harness crash?): $p" }
    return $lines
}

# PASS/FAIL lines of the checks whose names start with one of the prefixes.
function Select-Checks($lines, $prefixes) {
    @($lines | Where-Object { $l = $_; $prefixes | Where-Object { $l -match ('^(PASS|FAIL) ' + [regex]::Escape($_)) } })
}

function Test-Groups($facts, $baseDir, $harness, $prefixes, $required) {
    $bad = @(); $count = 0
    foreach ($arch in 'win32', 'win64') {
        $checks = Select-Checks (Read-Results $facts $baseDir $harness $arch) $prefixes
        $count += $checks.Count
        if ($checks.Count -eq 0) { $bad += "${arch}: no checks for $($prefixes -join ', ')" }
        $bad += @($checks | Where-Object { $_ -like 'FAIL *' } | ForEach-Object { "${arch}: $_" })
        foreach ($req in $required) {
            if (-not ($checks | Where-Object { $_ -like "PASS $req*" })) { $bad += "${arch}: missing PASS $req" }
        }
    }
    return @{ Pass = ($bad.Count -eq 0); Count = $count; Bad = $bad }
}

# Bullets of one report section ("- none" excluded).
function Get-Section($reportPath, $section) {
    $lines = @(Get-Content $reportPath -Encoding UTF8)
    $i = [array]::IndexOf($lines, "## $section")
    if ($i -lt 0) { return @() }
    $out = @()
    for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j] -notmatch '^## '; $j++) {
        if ($lines[$j] -like '- *' -and $lines[$j] -ne '- none') { $out += $lines[$j] }
    }
    return $out
}

function New-Metric($id, $name, $pass, $evidence) {
    [pscustomobject]@{ Id = $id; Name = $name; Pass = [bool]$pass; Evidence = $evidence }
}

function Invoke-Judge($facts, $baseDir) {
    $m = @()
    # 1. compile
    $c = $facts.compile
    $m += New-Metric 1 'Generated libgit2 bindings compile (win32, win64)' ($c.win32.exists -and $c.win32.fresh -and $c.win64.exists -and $c.win64.fresh) `
        ("harness EXE built from the current bindings: win32 " + $(if ($c.win32.exists -and $c.win32.fresh) { 'yes' } else { 'NO' }) + ", win64 " + $(if ($c.win64.exists -and $c.win64.fresh) { 'yes' } else { 'NO' }))
    # 2. layout
    $g = Test-Groups $facts $baseDir 'libgit2' @('1.') @('1.layout')
    $m += New-Metric 2 'Layout self-check: 0 mismatches (win32, win64)' $g.Pass $(if ($g.Pass) { 'every generated Type matches CastXML on both architectures' } else { $g.Bad -join '; ' })
    # 3. local scenario (PRD req. 35), incl. the variadic call and shutdown
    $g = Test-Groups $facts $baseDir 'libgit2' @('2.', '3.', '4.', '0.libgit2_shutdown') @('3.opts', '0.libgit2_shutdown')
    $m += New-Metric 3 'Local git scenario incl. a variadic call (win32, win64)' $g.Pass $(if ($g.Pass) { "$($g.Count) checks passed (errors, variadic opts, init/commit/revwalk/branch/diff, shutdown)" } else { $g.Bad -join '; ' })
    # 4. callbacks + clone (PRD req. 36)
    $g = Test-Groups $facts $baseDir 'libgit2' @('6.') @('6.clone', '6.checkout progress callback called', '6.transfer progress callback called')
    $m += New-Metric 4 'Clone with checkout and transfer callbacks (win32, win64)' $g.Pass $(if ($g.Pass) { "$($g.Count) checks passed" } else { $g.Bad -join '; ' })
    # 5. coverage
    $cov = $facts.coverage
    $unexplained = @($cov.exceptions | Where-Object { -not $_.reason })
    $m += New-Metric 5 'Coverage: every export generated, or listed with a reason' ($unexplained.Count -eq 0) `
        ("$($cov.generated) functions generated for $($cov.exports) DLL exports; $(@($cov.exceptions).Count) exports not generated" + $(if ($unexplained.Count) { ", UNEXPLAINED: " + (($unexplained | ForEach-Object { $_.name }) -join ', ') } else { ', each with a reason' }) + "; $(@($cov.notExported).Count) declared but not exported (in the report)")
    # 6. doc comments
    $d = $facts.docs
    $m += New-Metric 6 'Doc comments for every item that has one' (@($d.missing).Count -eq 0 -and $d.commented -gt 0) `
        ("$($d.documented) of $($d.commented) commented header items carry their doc" + $(if (@($d.missing).Count) { "; missing: " + (@($d.missing) -join ', ') } else { '' }))
    # 7. hand edits
    $r = $facts.regenerated
    $m += New-Metric 7 'No hand edits to generated code' $r.identical $(if ($r.identical) { 'a fresh regeneration is byte-identical to the bindings and to the copies the harnesses compiled' } else { 'differs: ' + (@($r.differing) -join ', ') })
    # 8. report: every skipped item, rename and escape listed with a reason
    $bad = @(); $n = 0
    foreach ($h in 'libgit2', 'fixture') {
        $rp = Resolve-In $baseDir $facts.reports.$h
        foreach ($s in 'Renamed', 'Skipped macros', 'Parameter names lost', 'Declared but not exported') {
            foreach ($b in (Get-Section $rp $s)) {
                $n++
                $ok = if ($s -eq 'Renamed') { $b -match '-> \S+ \(.+\)$' } else { $b -match '^- \S+: \S' }
                if (-not $ok) { $bad += "${h}: $b" }
            }
        }
    }
    $m += New-Metric 8 'Report: every skip, rename and loss listed with a reason' ($bad.Count -eq 0) $(if ($bad.Count) { 'without a reason: ' + ($bad -join '; ') } else { "$n entries, each with a reason" })
    # 9. synthetic library
    $bad = @(); $n = 0
    foreach ($arch in 'win32', 'win64') {
        $lines = Read-Results $facts $baseDir 'fixture' $arch
        $n += @($lines | Where-Object { $_ -like 'PASS *' }).Count
        $bad += @($lines | Where-Object { $_ -like 'FAIL *' } | ForEach-Object { "${arch}: $_" })
    }
    $unsupported = @(Get-Section (Resolve-In $baseDir $facts.reports.fixture) 'Packing' | Where-Object { $_ -like '*cannot be expressed*' })
    $m += New-Metric 9 'Synthetic library: every construct passes or is reported unsupported' ($bad.Count -eq 0) `
        $(if ($bad.Count) { $bad -join '; ' } else { "$n checks passed on win32 + win64; reported unsupported: " + $(if ($unsupported.Count) { ($unsupported | ForEach-Object { $_.Substring(2) }) -join '; ' } else { 'none' }) })

    $core = @($m | Where-Object { $_.Id -le 4 -and -not $_.Pass }).Count -eq 0
    $all = @($m | Where-Object { -not $_.Pass }).Count -eq 0
    $verdict = if ($all) { 'works' } elseif ($core) { 'works with listed limits' } else { 'does not work' }
    return [pscustomobject]@{ Verdict = $verdict; Metrics = $m }
}

function Format-Verdict($res) {
    $s = @('| # | Metric | Result | Evidence |', '|---|---|---|---|')
    foreach ($x in $res.Metrics) { $s += "| $($x.Id) | $($x.Name) | $(if ($x.Pass) { 'PASS' } else { '**FAIL**' }) | $($x.Evidence -replace '\|', '\|') |" }
    $s += ''
    $s += "**Verdict: $($res.Verdict).**"
    return ($s -join "`r`n")
}

# ---- facts from the real artifacts --------------------------------------------------------------

function Get-PeExports($path) {
    $d = [IO.File]::ReadAllBytes($path)
    $pe = [BitConverter]::ToInt32($d, 0x3C)
    $nsec = [BitConverter]::ToUInt16($d, $pe + 6); $optsz = [BitConverter]::ToUInt16($d, $pe + 20)
    $opt = $pe + 24; $magic = [BitConverter]::ToUInt16($d, $opt)
    $dd = $opt + $(if ($magic -eq 0x10B) { 96 } else { 112 })
    $rva = [BitConverter]::ToInt32($d, $dd); $sec = $opt + $optsz
    $off = { param($r) for ($k = 0; $k -lt $nsec; $k++) { $h = $sec + 40 * $k
            $vs = [BitConverter]::ToInt32($d, $h + 8); $va = [BitConverter]::ToInt32($d, $h + 12); $rs = [BitConverter]::ToInt32($d, $h + 16); $rp = [BitConverter]::ToInt32($d, $h + 20)
            if ($r -ge $va -and $r -lt $va + [Math]::Max($vs, $rs)) { return $r - $va + $rp } } }
    $ed = & $off $rva; $n = [BitConverter]::ToInt32($d, $ed + 24); $names = & $off ([BitConverter]::ToInt32($d, $ed + 32))
    $set = @{}
    for ($i = 0; $i -lt $n; $i++) {
        $s = & $off ([BitConverter]::ToInt32($d, $names + 4 * $i)); $e = $s
        while ($d[$e] -ne 0) { $e++ }
        $set[[Text.Encoding]::ASCII.GetString($d, $s, $e - $s)] = $true
    }
    return $set
}

# C names of the generated declares (Alias names where the tB name differs).
function Get-GeneratedFunctions($sourceDir) {
    $set = @{}
    foreach ($f in Get-ChildItem "$sourceDir\*.twin") {
        foreach ($l in [IO.File]::ReadAllLines($f.FullName)) {
            if ($l -match 'Public DeclareWide PtrSafe (?:Function|Sub) (\w+)') {
                $n = $Matches[1]
                if ($l -match 'Alias "(\w+)"') { $n = $Matches[1] }
                $set[$n] = $true
            }
        }
    }
    return $set
}

# Header items (functions, structs, unions, enums, typedefs) that have a doc comment in the
# headers versus those whose generated declaration is preceded by it.
function Get-DocFacts($xmlPath, $sourceDir, $libDir) {
    $xml = New-Object Xml.XmlDocument; $xml.Load($xmlPath)
    $files = @{}; foreach ($f in $xml.SelectNodes('/CastXML/File')) { $files[$f.GetAttribute('id')] = $f.GetAttribute('name') }
    $lines = @(); foreach ($f in Get-ChildItem "$sourceDir\*.twin" | Where-Object { $_.Name -notmatch '_(LayoutCheck|Loader)\.twin$' }) { $lines += [IO.File]::ReadAllLines($f.FullName) }
    $idx = @{}
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*Public (?:DeclareWide PtrSafe (?:Function|Sub)|Type|Enum|Delegate (?:Function|Sub)|Alias) (\w+)') {
            if (-not $idx.ContainsKey($Matches[1])) { $idx[$Matches[1]] = $i }
            if ($lines[$i] -match 'Alias "(\w+)"' -and -not $idx.ContainsKey($Matches[1])) { $idx[$Matches[1]] = $i }
        }
    }
    $lib = ($libDir -replace '/', '\').ToLower()
    $commented = 0; $documented = 0; $missing = @()
    foreach ($el in $xml.DocumentElement.ChildNodes) {
        # psbase: on an XmlElement, PowerShell's $el.Name would return its "name" attribute
        if ($el.NodeType -ne 'Element' -or 'Function', 'Struct', 'Union', 'Enumeration', 'Typedef' -notcontains $el.psbase.Name) { continue }
        $name = $el.GetAttribute('name')
        if (-not $el.GetAttribute('comment') -or -not $name) { continue }     # anonymous structs are documented through their typedef
        if (-not (($files[$el.GetAttribute('file')] -replace '/', '\').ToLower().StartsWith($lib))) { continue }
        $commented++
        if (-not $idx.ContainsKey($name)) { $missing += "$name (not generated by name)"; continue }
        $j = $idx[$name] - 1
        while ($j -ge 0 -and ($lines[$j].Trim() -match "^(' C:|' NOTE:|\[|#If|#Else)")) { $j-- }
        if ($j -ge 0 -and $lines[$j].TrimEnd().EndsWith('*/')) { $documented++ } else { $missing += $name }
    }
    return @{ commented = $commented; documented = $documented; missing = $missing }
}

function Get-HarnessFacts($folder, $project, $shared, $tbHash) {
    $h = "$root\tests\$folder"
    $inputs = @(Get-ChildItem (@("$h\Sources", "$h\bindings\Source") + $shared) -File -ErrorAction SilentlyContinue)
    $newest = ($inputs | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    $stampOk = (Test-Path "$h\bindings\tbblob.sha256") -and ((Get-Content "$h\bindings\tbblob.sha256" -Raw) -eq $tbHash)
    $exe = @{}; $res = @{}
    foreach ($arch in 'win32', 'win64') {
        $e = "$h\Build\${project}_$arch.exe"
        $exists = Test-Path $e
        $exe[$arch] = @{ exists = $exists; fresh = ($exists -and $stampOk -and (Get-Item $e).LastWriteTime -ge $newest) }
        $rf = "$h\results\results-$arch.txt"
        $res[$arch] = @{ path = $rf; fresh = ($exists -and (Test-Path $rf) -and (Get-Item $rf).LastWriteTime -ge (Get-Item $e).LastWriteTime) }
    }
    return @{ exe = $exe; results = $res }
}

function Get-Facts {
    $tb = "$root\Build\tbBlob_win64.exe"
    $tbHash = (Get-FileHash $tb -Algorithm SHA256).Hash
    $shared = @("$root\tests\harness-fixture\Sources\Results.twin", "$root\tests\harness-fixture\Sources\Utf8.twin")
    $gl = Get-HarnessFacts 'harness-libgit2' 'harness_libgit2' $shared $tbHash
    $fx = Get-HarnessFacts 'harness-fixture' 'harness_fixture' @() $tbHash
    $hl = "$root\tests\harness-libgit2"
    $include = "$root\libgit2\vcpkg_installed\x64-windows\include"

    Write-Host "verdict: coverage (git2.dll exports vs generated declares)..."
    $exports = Get-PeExports "$root\libgit2\vcpkg_installed\x64-windows\bin\git2.dll"
    $generated = Get-GeneratedFunctions "$hl\bindings\Source"
    $declaredIn = @{}
    foreach ($f in Get-ChildItem $include -Recurse -Filter *.h) {
        foreach ($mm in [regex]::Matches([IO.File]::ReadAllText($f.FullName), 'GIT_EXTERN\([^)]*\)\s*(\w+)\s*\(')) { $declaredIn[$mm.Groups[1].Value] = $f.FullName.Substring($include.Length + 1) }
    }
    $exceptions = @(foreach ($n in ($exports.Keys | Where-Object { -not $generated.ContainsKey($_) } | Sort-Object)) {
        # declared but not generated would be a tbBlob bug: no reason
        @{ name = $n; reason = $(if ($declaredIn.ContainsKey($n)) { '' } else { 'not declared in any public header (internal)' }) }
    })
    $notExported = @($generated.Keys | Where-Object { -not $exports.ContainsKey($_) } | Sort-Object)

    Write-Host "verdict: doc comments..."
    $docs = Get-DocFacts "$hl\bindings\Work\castxml_x64.xml" "$hl\bindings\Source" $include

    Write-Host "verdict: regenerating both sets of bindings to check for hand edits (about a minute)..."
    $differing = @()
    foreach ($h in 'harness-fixture', 'harness-libgit2') {
        $tmp = Join-Path $env:TEMP ("tbblob-verdict-" + [guid]::NewGuid().ToString('N'))
        & powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tests\$h\build-project.ps1" -BindingsOnly $tmp | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "regeneration failed for $h (exit $LASTEXITCODE)" }
        foreach ($f in Get-ChildItem "$tmp\Source\*.twin") {
            $fresh = (Get-FileHash $f.FullName).Hash
            foreach ($copy in "$root\tests\$h\bindings\Source\$($f.Name)", "$root\tests\$h\project\Sources\$($f.Name)") {
                if (-not (Test-Path $copy) -or (Get-FileHash $copy).Hash -ne $fresh) { $differing += $copy.Substring($root.Length + 1) }
            }
        }
        Remove-Item -Recurse -Force $tmp
    }

    return [pscustomobject]@{
        compile = $gl.exe
        results = @{ libgit2 = $gl.results; fixture = $fx.results }
        reports = @{ libgit2 = "$hl\bindings\report.md"; fixture = "$root\tests\harness-fixture\bindings\report.md" }
        coverage = @{ exports = $exports.Count; generated = $generated.Count; exceptions = $exceptions; notExported = $notExported }
        docs = $docs
        regenerated = @{ identical = ($differing.Count -eq 0); differing = $differing }
    } | ConvertTo-Json -Depth 6 | ConvertFrom-Json     # same shape as the self-test facts.json
}

# ---- self-test ---------------------------------------------------------------------------------

function Invoke-SelfTest {
    $cases = @(
        @{ name = 'allpass';           verdict = 'works';                       fail = @() },
        @{ name = 'harness-fail';      verdict = 'does not work';               fail = @(4) },
        @{ name = 'coverage-noreason'; verdict = 'works with listed limits';    fail = @(5) },
        @{ name = 'docs-none';         verdict = 'works with listed limits';    fail = @(6) },     # measured nothing: not a PASS
        @{ name = 'stale-results';     error = 'stale' },
        @{ name = 'missing-results';   error = 'missing' }
    )
    $failed = 0
    foreach ($c in $cases) {
        $dir = "$root\tests\testdata\verdict\$($c.name)"
        $facts = Get-Content "$dir\facts.json" -Raw | ConvertFrom-Json
        $got = $null; $err = ''
        try { $got = Invoke-Judge $facts $dir } catch { $err = $_.Exception.Message }
        if ($c.error) {
            $ok = $err -like "*$($c.error)*"
            $why = "expected an error mentioning '$($c.error)', got " + $(if ($err) { "error: $err" } else { "verdict: $($got.Verdict)" })
        } else {
            $failedIds = @(if ($got) { $got.Metrics | Where-Object { -not $_.Pass } | ForEach-Object { $_.Id } })
            $ok = -not $err -and $got.Verdict -eq $c.verdict -and (($failedIds -join ',') -eq ($c.fail -join ','))
            $why = if ($err) { "error: $err" } else { "verdict '$($got.Verdict)' failing [$($failedIds -join ',')], expected '$($c.verdict)' failing [$($c.fail -join ',')]" }
        }
        if ($ok) { Write-Host "PASS $($c.name)" } else { Write-Host "FAIL $($c.name): $why"; $failed++ }
    }
    Write-Host "verdict self-test: $($cases.Count - $failed)/$($cases.Count) passed"
    return $failed
}

if ($SelfTest) { exit $(if ((Invoke-SelfTest) -gt 0) { 1 } else { 0 }) }

try {
    $facts = Get-Facts
    $res = Invoke-Judge $facts $root
} catch {
    Write-Host "NO VERDICT: $($_.Exception.Message)"
    exit 2
}
$md = Format-Verdict $res
Write-Host ""
Write-Host $md
if ($Out) { [IO.File]::WriteAllText($Out, $md + "`r`n", (New-Object Text.UTF8Encoding($false))) }
exit 0
