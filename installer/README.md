# 🚀 FRP Client Installer

Cross-platform installer for FRP Client with interactive menu.

## 📦 Supported Platforms

| Platform | Script | Requirements |
|----------|--------|--------------|
| **Linux** | `linux/install-frp.sh` | bash, curl, systemd |
| **Windows** | `windows/install-frp.ps1` | PowerShell 5.1+, Administrator |

## ✨ Features

- ✅ **Install** - Download and install FRP Client
- ✅ **Uninstall** - Remove FRP Client completely
- ✅ **Update** - Update to latest version
- ✅ **Connect** - Configure and connect to server

## 🪟 Windows Installation

### Quick Start (Recommended: Offline Installer)

Download the **pre-built installer** from the [latest release](https://github.com/tahatehran/doc-vps-server-project/releases/latest):

1. Go to **Releases** → Download `frp-client-installer-full.zip`
2. Extract the ZIP
3. Open **PowerShell as Administrator**
4. Run: `.\install-frp.exe`

> The offline installer includes `frpc.exe` bundled — **no internet required** for install/update on the target machine.

### Alternative: Online Script

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/windows/install-frp.ps1" -OutFile "install-frp.ps1"
.\install-frp.ps1
```

> The script auto-detects if `frpc.exe` is bundled next to it (offline mode) or downloads from GitHub (online mode).

## 🐧 Linux Installation

```bash
# Download
curl -fsSL -o install-frp.sh https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/linux/install-frp.sh

# Make executable
chmod +x install-frp.sh

# Run with sudo
sudo ./install-frp.sh
```

## 📋 Menu Options

```
1) Install FRP Client
   - Downloads FRP v0.71.0 (or uses bundled frpc.exe)
   - Installs to C:\Program Files\frp (Windows) or /usr/local/bin (Linux)
   - Creates Windows service (sc.exe) or systemd service (Linux)
   - Creates default config template

2) Uninstall FRP Client
   - Stops and removes service
   - Removes binaries and configs
   - Cleans up PATH

3) Update FRP Client
   - Replaces binary with bundled version (offline) or downloads latest
   - Restarts service if running

4) Connect to Server
   - Interactive configuration (server address, port, token)
   - Configures local/remote ports for TCP or HTTP proxies
   - Validates config with `frpc verify -c config`
   - Creates/starts Windows service (sc.exe fallback) or systemd service
   - Shows connection status

5) Exit
```

## 🔧 Configuration

After installation, config file locations:
- **Linux:** `/etc/frp/frpc.toml`
- **Windows:** `C:\Program Files\frp\config\frpc.toml`

### Example Config (TOML)

```toml
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_TOKEN"

transport.protocol = "tcp"
transport.poolCount = 5
transport.tcpMux = true

log.level = "info"
log.maxDays = 3

[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3000
remotePort = 8001

[proxies.healthCheck]
type = "tcp"
timeoutSeconds = 3
maxFailed = 3
intervalSeconds = 10
```

### HTTP Proxy Example

```toml
[[proxies]]
name = "web-app"
type = "http"
localIP = "127.0.0.1"
localPort = 8080
customDomains = ["app.example.com"]
```

## 📝 Notes

- Requires **root/Administrator** for install/uninstall/update/connect
- Connect option also requires Administrator to manage service
- Config file is created with restricted permissions (600 on Linux)
- Service auto-starts on boot after installation
- **Offline mode:** Place `frpc.exe` next to `install-frp.ps1` / `install-frp.exe` to skip download

## 🔗 Links

- **GitHub:** https://github.com/tahatehran/doc-vps-server-project
- **FRP Releases:** https://github.com/fatedier/frp/releases
- **Server Info:** 2.144.21.218:7000 (FRP), 7500 (Dashboard), 7400 (Client UI), 8090 (Status)
