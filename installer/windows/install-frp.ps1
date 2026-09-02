#Requires -RunAsAdministrator
<#
.SYNOPSIS
    FRP Client Installer for Windows
.DESCRIPTION
    Interactive installer for FRP Client with menu:
    1. Install
    2. Uninstall
    3. Update
    4. Connect to Server
.NOTES
    Run PowerShell as Administrator
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$FRP_VERSION = '0.71.0'
$FRP_ARCH = 'windows_amd64'
$FRP_URL = "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${FRP_ARCH}.zip"
$INSTALL_DIR = "$env:ProgramFiles\frp"
$CONFIG_DIR = "$INSTALL_DIR\config"
$CONFIG_FILE = "$CONFIG_DIR\frpc.toml"
$SERVICE_NAME = 'frp-client'

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "          FRP Client Installer for Windows              " -ForegroundColor Cyan
    Write-Host "                   Version: $FRP_VERSION                      " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Menu {
    Write-Host "Please select an option:" -ForegroundColor Green
    Write-Host "  1) Install FRP Client"
    Write-Host "  2) Uninstall FRP Client"
    Write-Host "  3) Update FRP Client"
    Write-Host "  4) Connect to Server"
    Write-Host "  5) Exit"
    Write-Host ""
}

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Dependencies {
    Write-Host "Checking dependencies..." -ForegroundColor Cyan
    if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
        Write-Host "curl not found. Please install curl for Windows." -ForegroundColor Yellow
    }
    if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
        Write-Host "Expand-Archive not available. Please use PowerShell 5.1+." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Dependencies OK." -ForegroundColor Green
}

function Install-FrpClient {
    if (-not (Test-Administrator)) {
        Write-Host "This operation requires Administrator privileges." -ForegroundColor Yellow
        Write-Host "Please run PowerShell as Administrator." -ForegroundColor Yellow
        exit 1
    }

    Install-Dependencies

    Write-Host "Installing FRP Client..." -ForegroundColor Cyan

    $tmpZip = "$env:TEMP\frp.zip"
    $tmpDir = "$env:TEMP\frp_extract"

    if (Test-Path $tmpDir) {
        Remove-Item $tmpDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    Write-Host "Downloading FRP Client v$FRP_VERSION..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $FRP_URL -OutFile $tmpZip -UseBasicParsing

    Write-Host "Extracting..." -ForegroundColor Cyan
    Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force

    $extractedDir = Get-ChildItem $tmpDir -Directory | Select-Object -First 1
    if (-not $extractedDir) {
        Write-Host "Download failed or wrong archive format." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }
    if (-not (Test-Path $CONFIG_DIR)) {
        New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    }

    Copy-Item "$($extractedDir.FullName)\frpc.exe" "$INSTALL_DIR\frpc.exe" -Force
    Write-Host "Installed to $INSTALL_DIR\frpc.exe" -ForegroundColor Green

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    if ($currentPath -notlike "*$INSTALL_DIR*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$INSTALL_DIR", "Machine")
        Write-Host "Added $INSTALL_DIR to PATH." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Edit config: notepad $CONFIG_FILE"
    Write-Host "  2. Start service: .\install-frp.ps1 (option 4)"
    Write-Host "  3. Check status: Get-Service $SERVICE_NAME"
    Write-Host ""

    Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

function Uninstall-FrpClient {
    if (-not (Test-Administrator)) {
        Write-Host "This operation requires Administrator privileges." -ForegroundColor Yellow
        exit 1
    }

    Write-Host "Uninstalling FRP Client..." -ForegroundColor Yellow

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq 'Running') {
            Stop-Service -Name $SERVICE_NAME -Force
        }
        sc.exe delete $SERVICE_NAME | Out-Null
    }

    if (Test-Path $INSTALL_DIR) {
        Remove-Item $INSTALL_DIR -Recurse -Force
    }

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $newPath = ($currentPath -split ';' | Where-Object { $_ -notlike "*$INSTALL_DIR*" }) -join ';'
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

    Write-Host "FRP Client uninstalled successfully." -ForegroundColor Green
}

function Update-FrpClient {
    if (-not (Test-Administrator)) {
        Write-Host "This operation requires Administrator privileges." -ForegroundColor Yellow
        exit 1
    }

    if (-not (Test-Path "$INSTALL_DIR\frpc.exe")) {
        Write-Host "FRP Client is not installed. Please install first." -ForegroundColor Red
        exit 1
    }

    Write-Host "Updating FRP Client to v$FRP_VERSION..." -ForegroundColor Cyan

    $tmpZip = "$env:TEMP\frp.zip"
    $tmpDir = "$env:TEMP\frp_extract"

    if (Test-Path $tmpDir) {
        Remove-Item $tmpDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    Invoke-WebRequest -Uri $FRP_URL -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force

    $extractedDir = Get-ChildItem $tmpDir -Directory | Select-Object -First 1
    if (-not $extractedDir) {
        Write-Host "Download failed." -ForegroundColor Red
        exit 1
    }

    Copy-Item "$($extractedDir.FullName)\frpc.exe" "$INSTALL_DIR\frpc.exe" -Force
    Write-Host "Updated to v$FRP_VERSION" -ForegroundColor Green

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Write-Host "Restarting service..." -ForegroundColor Yellow
        Restart-Service -Name $SERVICE_NAME -Force
        Write-Host "Service restarted." -ForegroundColor Green
    }

    Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

function Connect-ToServer {
    if (-not (Test-Administrator)) {
        Write-Host "This operation requires Administrator privileges." -ForegroundColor Yellow
        exit 1
    }

    if (-not (Test-Path "$INSTALL_DIR\frpc.exe")) {
        Write-Host "FRP Client is not installed. Please install first (option 1)." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Connect to FRP Server" -ForegroundColor Cyan
    Write-Host ""

    $serverAddr = Read-Host "Server Address [2.144.21.218]"
    if ([string]::IsNullOrWhiteSpace($serverAddr)) { $serverAddr = '2.144.21.218' }

    $serverPort = Read-Host "Server Port [7000]"
    if ([string]::IsNullOrWhiteSpace($serverPort)) { $serverPort = '7000' }

    $authToken = Read-Host "Auth Token"
    if ([string]::IsNullOrWhiteSpace($authToken)) {
        Write-Host "Token cannot be empty." -ForegroundColor Red
        exit 1
    }

    $localPort = Read-Host "Local Port (your app port)"
    if ([string]::IsNullOrWhiteSpace($localPort)) {
        Write-Host "Local port cannot be empty." -ForegroundColor Red
        exit 1
    }

    $remotePort = Read-Host "Remote Port (exposed port on server)"
    if ([string]::IsNullOrWhiteSpace($remotePort)) {
        Write-Host "Remote port cannot be empty." -ForegroundColor Red
        exit 1
    }

    $proxyName = Read-Host "Proxy Name [my-app]"
    if ([string]::IsNullOrWhiteSpace($proxyName)) { $proxyName = 'my-app' }

    $proxyType = Read-Host "Proxy Type [tcp/http]"
    if ([string]::IsNullOrWhiteSpace($proxyType)) { $proxyType = 'tcp' }

    Write-Host ""
    Write-Host "Creating configuration..." -ForegroundColor Yellow

    if (-not (Test-Path $CONFIG_DIR)) {
        New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    }

    $configContent = @"
serverAddr = "$serverAddr"
serverPort = $serverPort
auth.method = "token"
auth.token = "$authToken"

transport.protocol = "tcp"
transport.poolCount = 5
transport.tcpMux = true
transport.heartbeatInterval = 30
transport.heartbeatTimeout = 90

log.level = "info"
log.maxDays = 3

[[proxies]]
name = "$proxyName"
type = "$proxyType"
localIP = "127.0.0.1"
localPort = $localPort
remotePort = $remotePort
"@

    if ($proxyType -eq 'http') {
        $customDomain = Read-Host "Custom Domain (optional)"
        if (-not [string]::IsNullOrWhiteSpace($customDomain)) {
            $configContent = $configContent -replace [regex]::Escape("remotePort = $remotePort"), "customDomains = [`"$customDomain`"]"
        }
    }

    Set-Content -Path $CONFIG_FILE -Value $configContent -Encoding UTF8
    Write-Host "Configuration saved to $CONFIG_FILE" -ForegroundColor Green

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "Restarting frp-client service..." -ForegroundColor Yellow
        Restart-Service -Name $SERVICE_NAME -Force
        Write-Host "Service restarted." -ForegroundColor Green
    } else {
        Write-Host "Creating service..." -ForegroundColor Yellow
        $nssmPath = "$INSTALL_DIR\nssm.exe"
        if (-not (Test-Path $nssmPath)) {
            Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile "$env:TEMP\nssm.zip" -UseBasicParsing
            Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath "$env:TEMP\nssm" -Force
            $nssmExe = Get-ChildItem "$env:TEMP\nssm" -Filter "nssm.exe" -Recurse | Select-Object -First 1
            if ($nssmExe) {
                Copy-Item $nssmExe.FullName $nssmPath -Force
            }
        }
        if (Test-Path $nssmPath) {
            & $nssmPath install $SERVICE_NAME "$INSTALL_DIR\frpc.exe" "-c `"$CONFIG_FILE`""
            & $nssmPath set $SERVICE_NAME AppDirectory $INSTALL_DIR
            & $nssmPath set $SERVICE_NAME Start SERVICE_AUTO_START
            Start-Service -Name $SERVICE_NAME
            Write-Host "Service created and started." -ForegroundColor Green
        } else {
            Write-Host "Could not install service automatically." -ForegroundColor Yellow
            Write-Host "Please run frpc.exe manually: $INSTALL_DIR\frpc.exe -c `"$CONFIG_FILE`"" -ForegroundColor Yellow
        }
    }

    Start-Sleep -Seconds 2
    Write-Host ""
    Write-Host "=== Connection Status ===" -ForegroundColor Cyan
    $svc = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "Service is running" -ForegroundColor Green
    } else {
        Write-Host "Service failed to start" -ForegroundColor Red
        Write-Host "Check logs in Event Viewer or run manually." -ForegroundColor Yellow
    }
    Write-Host ""
}

function Show-Status {
    Write-Host "=== FRP Client Status ===" -ForegroundColor Cyan
    if (Test-Path "$INSTALL_DIR\frpc.exe") {
        Write-Host "FRP Client: Installed" -ForegroundColor Green
        & "$INSTALL_DIR\frpc.exe" --version 2>&1 | ForEach-Object { Write-Host "  Version: $_" -ForegroundColor Green }
    } else {
        Write-Host "FRP Client: Not installed" -ForegroundColor Red
    }
    if (Test-Path $CONFIG_FILE) {
        Write-Host "Config: $CONFIG_FILE" -ForegroundColor Green
    } else {
        Write-Host "Config: Not found" -ForegroundColor Red
    }
    $svc = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "Service: $($svc.Status)" -ForegroundColor Green
    } else {
        Write-Host "Service: Not installed" -ForegroundColor Red
    }
    Write-Host ""
}

function Main {
    Write-Banner
    Show-Status

    while ($true) {
        Write-Menu
        $choice = Read-Host "Enter your choice [1-5]"
        Write-Host ""

        switch ($choice) {
            '1' { Install-FrpClient }
            '2' { Uninstall-FrpClient }
            '3' { Update-FrpClient }
            '4' { Connect-ToServer }
            '5' { Write-Host "Goodbye!" -ForegroundColor Green; exit 0 }
            default { Write-Host "Invalid choice. Please select 1-5." -ForegroundColor Red }
        }

        Write-Host ""
        $null = Read-Host "Press Enter to continue"
    }
}

Main
