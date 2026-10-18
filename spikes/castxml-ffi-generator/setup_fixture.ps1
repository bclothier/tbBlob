# SPIKE throwaway: copy the per-architecture libgit2 DLL sets and create the fixture repositories.
# Usage: powershell -ExecutionPolicy Bypass -File setup_fixture.ps1
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = (Resolve-Path "$here\..\..").Path

# DLL sets: bin\win32 (x86) and bin\win64 (x64)
$sets = @{ 'win32' = "$root\libgit2\vcpkg_installed_x86\x86-windows\bin"; 'win64' = "$root\libgit2\vcpkg_installed\x64-windows\bin" }
foreach ($arch in $sets.Keys) {
    $dest = "$here\bin\$arch"
    New-Item -ItemType Directory -Force $dest | Out-Null
    Copy-Item "$($sets[$arch])\*.dll" $dest -Force
    Write-Host "copied $($sets[$arch]) -> $dest"
}

# Fixture repo with a fixed author/date and a non-ASCII author name (UTF-8), plus a bare clone.
$fixture = "$here\fixture"
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
git -C "$fixture\repo" log -1 --format='%an <%ae> %at %ai'
Write-Host "fixture ready: $fixture"
