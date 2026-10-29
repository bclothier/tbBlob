# Rebuilds tbBlob.twinproj from Source\ (the source of truth, D-010). Run before every compile.
# The version (Major.Minor.Build, bumped by hand in Source\Settings) gets the last commit's short hash
# in its Comments field ("commit 1a2b3c4", "-modified" when the working tree has uncommitted
# changes), so a built tbBlob.exe says which source it came from. The hash goes into a copy of
# Source\ that is packed, never into Source\Settings: committing it would change the hash.
# Usage: powershell -ExecutionPolicy Bypass -File tests\import.ps1
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot\..").Path
$tool = "$root\tools\impexp\Build\tBImportExport_win64.exe"

$hash = (& git -C $root rev-parse --short HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $hash) { $hash = 'unknown' }
elseif (& git -C $root status --porcelain 2>$null) { $hash += '-modified' }
$comment = "commit $hash"

$copy = Join-Path ([IO.Path]::GetTempPath()) ("tbBlob-import-" + [Guid]::NewGuid().ToString('N'))
Copy-Item "$root\Source" $copy -Recurse
try {
    $settings = "$copy\Settings"
    $text = [IO.File]::ReadAllText($settings)
    $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $text = $text -replace "\t`"project\.versionComments`": `"[^`"]*`",\r?\n", ''
    $text = $text -replace "(\t`"project\.versionBuild`": \d+,)\r?\n", "`$1$nl`t`"project.versionComments`": `"$comment`",$nl"
    if (-not $text.Contains("`"project.versionComments`": `"$comment`"")) {
        Write-Host "IMPORT FAILED: Source\Settings has no project.versionBuild line to put the commit after"
        exit 1
    }
    [IO.File]::WriteAllText($settings, $text, (New-Object Text.UTF8Encoding $false))

    $out = & $tool import "$root\tbBlob.twinproj" $copy --overwrite
    $code = $LASTEXITCODE
} finally {
    Remove-Item -Recurse -Force $copy -ErrorAction SilentlyContinue
}
$out | ForEach-Object { Write-Host $_ }
if (($code -ne 0 -and $code -ne 6) -or -not ($out -match '\.\.\. DONE')) {
    Write-Host "IMPORT FAILED (exit $code)"
    exit 1
}
Write-Host "tbBlob.twinproj rebuilt from Source\ ($comment) -- reopen it in the IDE (close/reopen if open), compile win64."
