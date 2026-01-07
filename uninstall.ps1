# uninstall.ps1

Remove-Item -Recurse -Force C:\GoVM -ErrorAction SilentlyContinue

$profile = $PROFILE
if (Test-Path $profile) {
    (Get-Content $profile) |
        Where-Object { $_ -notmatch "GoVM" } |
        Set-Content $profile
}

Write-Host "❌ govm removed"
