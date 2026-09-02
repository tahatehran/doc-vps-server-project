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

## 🐧 Linux Installation

```bash
# Download
curl -fsSL -o install-frp.sh https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/linux/install-frp.sh

# Make executable
chmod +x install-frp.sh

# Run with sudo
sudo ./install-frp.sh
```

## 🪟 Windows Installation

1. Open **PowerShell as Administrator**
2. Run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/windows/install-frp.ps1" -OutFile "install-frp.ps1"
.\install-frp.ps1
```

## 📋 Menu Options

```
1) Install FRP Client
   - Downloads FRP v0.71.0
   - Installs to /usr/local/bin (Linux) or C:\Program Files\frp (Windows)
   - Creates systemd service (Linux) or Windows service (Windows)

2) Uninstall FRP Client
   - Stops and removes service
   - Removes binaries and configs
   - Cleans up PATH

3) Update FRP Client
   - Downloads latest version
   - Replaces binary
   - Restarts service if running

4) Connect to Server
   - Interactive configuration
   - Sets server address, port, token
   - Configures local/remote ports
   - Supports TCP and HTTP proxies
   - Starts/restarts service

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

## 📝 Notes

- Requires **root/Administrator** for install/uninstall/update
- Connect option also requires root/Administrator to manage service
- Config file is created with restricted permissions (600 on Linux)
- Service auto-starts on boot after installation

## 🔗 Links

- **GitHub:** https://github.com/tahatehran/doc-vps-server-project
- **FRP Releases:** https://github.com/fatedier/frp/releases
