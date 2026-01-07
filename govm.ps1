# govm.ps1
# Simple Go Version Manager for Windows (PATH-based, no symlink)

$Global:GoVMRoot = "C:\GoVM"

function govm {
    param(
        [Parameter(Mandatory=$true)]
        [string]$command,
        [string]$version
    )

    switch ($command) {
        "install" { govm-install $version }
        "use"     { govm-use $version }
        "list"    { govm-list }
        default   { govm-help }
    }
}

function govm-install {
    param([string]$version)

    if (-not $version) {
        Write-Host "Usage: govm install <version>"
        return
    }

    $dest = "$GoVMRoot\versions\$version"
    if (Test-Path $dest) {
        Write-Host "Go $version already installed"
        return
    }

    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    $url = "https://go.dev/dl/go$version.windows-amd64.zip"
    $zip = "$env:TEMP\go$version.zip"

    Write-Host "Downloading Go $version..."
    Invoke-WebRequest $url -OutFile $zip

    Expand-Archive $zip $env:TEMP -Force
    Move-Item "$env:TEMP\go\*" $dest
    Remove-Item $zip -Force
    Remove-Item "$env:TEMP\go" -Recurse -Force

    Write-Host "Installed Go $version"
}

function govm-use {
    param([string]$version)

    if (-not $version) {
        Write-Host "Usage: govm use <version>"
        return
    }

    $goBin = "$GoVMRoot\versions\$version\bin"
    if (!(Test-Path $goBin)) {
        Write-Host "Go $version is not installed"
        return
    }

    # Remove existing Go paths
    $env:PATH = ($env:PATH -split ";" |
        Where-Object { $_ -notmatch "GoVM|\\Go\\bin" }) -join ";"

    # Add selected Go
    $env:PATH = "$goBin;$env:PATH"

    Write-Host "Switched to Go $version"
    go version
}

function govm-list {
    if (!(Test-Path "$GoVMRoot\versions")) {
        Write-Host "No Go versions installed"
        return
    }

    Get-ChildItem "$GoVMRoot\versions" -Directory |
        Select-Object -ExpandProperty Name
}

function govm-help {
@"
govm - Go Version Manager for Windows

Commands:
  govm install <version>   Install Go version
  govm use <version>       Use Go version
  govm list                List installed versions
"@
}
