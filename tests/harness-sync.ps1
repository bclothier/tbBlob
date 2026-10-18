# Shared by tests\harness-*\build-project.ps1 (dot-sourced). Generated bindings are written to a
# fresh folder and copied over the old ones file by file, only where the content changed, so an
# unchanged module keeps its timestamp and a harness EXE built from it stays current. The bindings
# record which tbBlob build made them (tbblob.sha256), for run-all.ps1's staleness check.

function Get-TbBlobHash($tbBlob) {
    (Get-FileHash $tbBlob -Algorithm SHA256).Hash
}

# Makes $dest's files equal to $new's (adds, replaces changed, removes extra); returns how many
# files under Source\ changed (0 = the generated code is the same).
function Sync-Bindings($new, $dest) {
    $sourceChanged = 0
    New-Item -ItemType Directory -Force $dest | Out-Null
    $newFiles = @(Get-ChildItem $new -Recurse -File)
    $keep = @{}
    foreach ($f in $newFiles) {
        $rel = $f.FullName.Substring($new.Length + 1)
        $keep[$rel] = $true
        $target = Join-Path $dest $rel
        $same = (Test-Path $target) -and ((Get-FileHash $target).Hash -eq (Get-FileHash $f.FullName).Hash)
        if (-not $same) {
            New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
            Copy-Item $f.FullName $target -Force
            if ($rel -like 'Source\*') { $sourceChanged++ }
        }
    }
    foreach ($f in @(Get-ChildItem $dest -Recurse -File)) {
        $rel = $f.FullName.Substring($dest.Length + 1)
        if ($rel -eq 'tbblob.sha256') { continue }
        if (-not $keep.ContainsKey($rel)) {
            Remove-Item $f.FullName -Force
            if ($rel -like 'Source\*') { $sourceChanged++ }
        }
    }
    Remove-Item -Recurse -Force $new
    return $sourceChanged
}
