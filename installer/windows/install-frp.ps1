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

$ErrorActionPreference = 'Continue'

$FRP_VERSION = '0.71.0'
$FRP_ARCH = 'windows_amd64'
$FRP_URL = "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${FRP_ARCH}.zip"
$INSTALL_DIR = "$env:ProgramFiles\frp"
$CONFIG_DIR = "$INSTALL_DIR\config"
$CONFIG_FILE = "$CONFIG_DIR\frpc.toml"
$SERVICE_NAME = 'frp-client'
$NSSM_URL = 'https://nssm.cc/release/nssm-2.24.zip'

# Directory of the running script or compiled EXE; a frpc.exe placed next to
# it is used directly so the release ZIP works fully offline
$ScriptBaseDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$BundledFrpc = Join-Path $ScriptBaseDir 'frpc.exe'

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

    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }
    if (-not (Test-Path $CONFIG_DIR)) {
        New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    }

    if (Test-Path $BundledFrpc) {
        Write-Host "Using frpc.exe bundled next to the installer (offline install)..." -ForegroundColor Cyan
        Copy-Item $BundledFrpc "$INSTALL_DIR\frpc.exe" -Force
    } else {
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

        Copy-Item "$($extractedDir.FullName)\frpc.exe" "$INSTALL_DIR\frpc.exe" -Force
        Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Installed to $INSTALL_DIR\frpc.exe" -ForegroundColor Green

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    if ($currentPath -notlike "*$INSTALL_DIR*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$INSTALL_DIR", "Machine")
        Write-Host "Added $INSTALL_DIR to PATH." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Run option 4 (Connect to Server) to configure and connect"
    Write-Host "  2. Or edit config manually: notepad $CONFIG_FILE"
    Write-Host "  3. Check status: Get-Service $SERVICE_NAME"
    Write-Host ""

    # Pre-create a template config so option 4 and manual editing work right away
    if (-not (Test-Path $CONFIG_FILE)) {
        $template = @"
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_TOKEN_HERE"

transport.protocol = "tcp"
transport.poolCount = 5
transport.tcpMux = true
transport.heartbeatInterval = 30
transport.heartbeatTimeout = 90

log.level = "info"
log.maxDays = 3

[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8001
"@
        Set-Content -Path $CONFIG_FILE -Value $template -Encoding UTF8
        Write-Host "Default config template created at $CONFIG_FILE" -ForegroundColor Green
    }
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

    if (Test-Path $BundledFrpc) {
        Write-Host "Using frpc.exe bundled next to the installer (offline update)..." -ForegroundColor Cyan
        Copy-Item $BundledFrpc "$INSTALL_DIR\frpc.exe" -Force
        Write-Host "Updated to bundled version" -ForegroundColor Green
    } else {
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

        Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') {
        Write-Host "Restarting service..." -ForegroundColor Yellow
        Restart-Service -Name $SERVICE_NAME -Force
        Write-Host "Service restarted." -ForegroundColor Green
    }
}

function Start-FrpcScService {
    # Fallback when NSSM is unavailable: create the service with built-in sc.exe
    $binPath = "`"$INSTALL_DIR\frpc.exe`" -c `"$CONFIG_FILE`""
    sc.exe create $SERVICE_NAME binPath= $binPath start= auto | Out-Null
    if ($LASTEXITCODE -ne 0) { return $false }
    sc.exe description $SERVICE_NAME "FRP Client tunnel service" | Out-Null
    try {
        Start-Service -Name $SERVICE_NAME -ErrorAction Stop
        Write-Host "Service created and started." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to start service: $_" -ForegroundColor Red
        sc.exe delete $SERVICE_NAME | Out-Null
        return $false
    }
}

function Start-FrpcManually {
    Write-Host "Falling back to manual execution mode." -ForegroundColor Yellow
    Start-Process -FilePath "$INSTALL_DIR\frpc.exe" -ArgumentList "-c `"$CONFIG_FILE`"" -WindowStyle Hidden
    Write-Host "frpc started manually. It will run until you log off." -ForegroundColor Yellow
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

    $authToken = Read-Host "Auth Token (the auth.token from the server's frps.toml - ask the server admin)"
    if ([string]::IsNullOrWhiteSpace($authToken)) {
        Write-Host "Token cannot be empty." -ForegroundColor Red
        exit 1
    }
    if ($authToken -in @('YOUR_TOKEN', 'توکن_شما', 'your-token', 'changeme')) {
        Write-Host "That is a placeholder from the docs, not a real token." -ForegroundColor Red
        Write-Host "Ask the server admin for the auth.token value in the server's frps.toml." -ForegroundColor Yellow
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

    # Validate config (verify is a subcommand and must come before -c)
    Write-Host "Validating configuration..." -ForegroundColor Yellow
    $validateOutput = & "$INSTALL_DIR\frpc.exe" verify -c $CONFIG_FILE 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Configuration validation failed:" -ForegroundColor Red
        Write-Host $validateOutput -ForegroundColor Red
        Write-Host "Please check your config file." -ForegroundColor Yellow
        return
    }
    Write-Host "Configuration is valid." -ForegroundColor Green

    # Live 6s foreground test so the user sees the REAL server response
    # (wrong token, duplicate proxy name, unreachable server) before a
    # broken service gets installed
    Write-Host "Testing connection to server (6 seconds)..." -ForegroundColor Yellow
    $testLog = "$env:TEMP\frpc-test.log"
    $testProc = Start-Process -FilePath "$INSTALL_DIR\frpc.exe" -ArgumentList "-c `"$CONFIG_FILE`"" -NoNewWindow -PassThru -RedirectStandardOutput $testLog -RedirectStandardError "$env:TEMP\frpc-test.err"
    Start-Sleep -Seconds 6
    if (-not $testProc.HasExited) {
        Stop-Process -Id $testProc.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Connection test succeeded - login accepted by server." -ForegroundColor Green
    } else {
        $testOutput = (Get-Content $testLog, "$env:TEMP\frpc-test.err" -ErrorAction SilentlyContinue) -join "`n"
        if ($testOutput -match "token .*doesn.t match|authentication failed|token in login") {
            Write-Host "LOGIN FAILED: the auth token is wrong." -ForegroundColor Red
            Write-Host "Get the real token from the server admin (auth.token in the server's frps.toml)." -ForegroundColor Yellow
            return
        }
        if ($testOutput -match "proxy .*already|proxy name") {
            Write-Host "LOGIN FAILED: this proxy name is already used on the server." -ForegroundColor Red
            Write-Host "Re-run option 4 and choose a different Proxy Name." -ForegroundColor Yellow
            return
        }
        if ($testOutput -match "connection refused|i/o timeout|dial tcp") {
            Write-Host "LOGIN FAILED: cannot reach the server." -ForegroundColor Red
            Write-Host "Check Server Address/Port and that the FRP server is running." -ForegroundColor Yellow
            return
        }
        Write-Host "frpc exited during the test:" -ForegroundColor Red
        Write-Host $testOutput -ForegroundColor Red
        return
    }

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "Restarting frp-client service..." -ForegroundColor Yellow
        try {
            Stop-Service -Name $SERVICE_NAME -Force -ErrorAction Stop
            Start-Service -Name $SERVICE_NAME -ErrorAction Stop
            Write-Host "Service restarted." -ForegroundColor Green
        } catch {
            Write-Host "Failed to restart service: $_" -ForegroundColor Red
            Write-Host "Trying to start frpc manually for debugging..." -ForegroundColor Yellow
            Start-Process -FilePath "$INSTALL_DIR\frpc.exe" -ArgumentList "-c `"$CONFIG_FILE`"" -WindowStyle Hidden
        }
    } else {
        Write-Host "Creating service with NSSM..." -ForegroundColor Yellow
        $nssmPath = "$INSTALL_DIR\nssm.exe"
        if (-not (Test-Path $nssmPath)) {
            Write-Host "Downloading NSSM..." -ForegroundColor Yellow
            $nssmZip = "$env:TEMP\nssm.zip"
            $nssmDir = "$env:TEMP\nssm_extract"
            if (Test-Path $nssmDir) {
                Remove-Item $nssmDir -Recurse -Force
            }
            try {
                Invoke-WebRequest -Uri $NSSM_URL -OutFile $nssmZip -UseBasicParsing
                Expand-Archive -Path $nssmZip -DestinationPath $nssmDir -Force
                $nssmExe = Get-ChildItem $nssmDir -Filter "nssm.exe" -Recurse | Select-Object -First 1
                if ($nssmExe) {
                    Copy-Item $nssmExe.FullName $nssmPath -Force
                    Write-Host "NSSM installed." -ForegroundColor Green
                } else {
                    throw "NSSM executable not found in archive"
                }
            } catch {
                Write-Host "Failed to download NSSM: $_" -ForegroundColor Red
                if (Start-FrpcScService) { return }
                Start-FrpcManually
                return
            }
        }

        if (Test-Path $nssmPath) {
            try {
                & $nssmPath install $SERVICE_NAME "$INSTALL_DIR\frpc.exe"
                & $nssmPath set $SERVICE_NAME AppParameters "-c `"$CONFIG_FILE`""
                & $nssmPath set $SERVICE_NAME AppDirectory $INSTALL_DIR
                & $nssmPath set $SERVICE_NAME Start SERVICE_AUTO_START
                & $nssmPath set $SERVICE_NAME DisplayName "FRP Client"
                Start-Service -Name $SERVICE_NAME -ErrorAction Stop
                Write-Host "Service created and started." -ForegroundColor Green
            } catch {
                Write-Host "NSSM service creation failed: $_" -ForegroundColor Red
                if (-not (Start-FrpcScService)) { Start-FrpcManually }
                return
            }
        } else {
            if (-not (Start-FrpcScService)) { Start-FrpcManually }
            return
        }
    }

    Start-Sleep -Seconds 3
    Write-Host ""
    Write-Host "=== Connection Status ===" -ForegroundColor Cyan
    $svc = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "Service is running" -ForegroundColor Green
    } else {
        Write-Host "Service failed to start" -ForegroundColor Red
        Write-Host "Check logs in Event Viewer or run manually." -ForegroundColor Yellow
        Write-Host "You can test manually with: $INSTALL_DIR\frpc.exe -c `"$CONFIG_FILE`"" -ForegroundColor Yellow
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
        Write-Host "Service: Not installed" -ForegroundColor Yellow
    }
    Write-Host ""
}

function Main {
    # #Requires -RunAsAdministrator is not supported inside ps2exe-compiled
    # executables, so elevation is enforced at runtime instead
    if (-not (Test-Administrator)) {
        Write-Host "This installer requires Administrator privileges." -ForegroundColor Red
        Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this again." -ForegroundColor Yellow
        if ($Host.Name -eq 'ConsoleHost') { exit 1 } else { return }
    }

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
