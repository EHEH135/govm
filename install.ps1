# install.ps1
# Run once to install govm

$govmDir = "C:\GoVM"
$profile = $PROFILE

Write-Host "Installing govm..."

New-Item -ItemType Directory -Force -Path $govmDir | Out-Null
Copy-Item ".\govm.ps1" "$govmDir\govm.ps1" -Force

if (!(Test-Path $profile)) {
    New-Item -ItemType File -Force -Path $profile | Out-Null
}

$loader = @"
# GoVM
. C:\GoVM\govm.ps1
"@

if (-not (Select-String -Path $profile -Pattern "GoVM" -Quiet)) {
    Add-Content -Path $profile -Value $loader
}

Write-Host "✅ govm installed"
Write-Host "👉 Restart PowerShell"
