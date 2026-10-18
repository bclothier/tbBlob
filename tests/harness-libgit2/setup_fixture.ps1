# Creates the libgit2 harness's fixture repositories in tests\harness-libgit2\fixture\ (gitignored),
# with git.exe: repo\ (a.txt, b.txt; one commit by a non-ASCII author at a fixed date; branch
# feature; tag v1) and a bare clone repo.git\. Ported from the spike's setup_fixture.ps1.
# Usage: powershell -ExecutionPolicy Bypass -File tests\harness-libgit2\setup_fixture.ps1
$ErrorActionPreference = 'Stop'
$fixture = "$PSScriptRoot\fixture"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "ERROR: git.exe not found on PATH"; exit 4 }
if (Test-Path $fixture) { Remove-Item -Recurse -Force $fixture }
New-Item -ItemType Directory -Force "$fixture\repo" | Out-Null
Push-Location "$fixture\repo"
try {
    git init -q -b main .
    git config user.name "Zo$([char]0xEB) T$([char]0xEB)ster"
    git config user.email "zoe@example.com"
    git config i18n.commitEncoding utf-8
    Set-Content -Path a.txt -Value "alpha" -Encoding ascii
    Set-Content -Path b.txt -Value "bravo" -Encoding ascii
    git add a.txt b.txt
    $env:GIT_AUTHOR_DATE = '1700000000 +0130'
    $env:GIT_COMMITTER_DATE = '1700000000 +0130'
    git commit -q -m "fixture commit"
    git branch feature
    git tag v1
} finally {
    Remove-Item Env:GIT_AUTHOR_DATE, Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    Pop-Location
}
git clone -q --bare "$fixture\repo" "$fixture\repo.git"
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: git clone --bare failed"; exit 1 }
Write-Host "fixture ready: $fixture ($(git -C "$fixture\repo" log -1 --format='%an <%ae> %at %ai'))"
