# 🖥️ FRP Server Documentation

> **Version:** v0.71.0 | **Protocol:** TCP + UDP + HTTP/HTTPS | **Status:** 🟢 Active

---

## 📋 Table of Contents

1. [Server Overview](#server-overview)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Service Setup](#service-setup)
5. [Management Commands](#management-commands)
6. [Client Management](#client-management)
7. [User Management](#user-management)
8. [Monitoring \& Health Check](#monitoring--health-check)
9. [Client Admin UI](#client-admin-ui)
10. [Security](#security)
11. [Troubleshooting](#troubleshooting)

---

## 🖥️ Server Overview

```
╔══════════════════════════════════════════════════════════════╗
║                    🌐 SERVER DETAILS                         ║
╠══════════════════════════════════════════════════════════════╣
║  🖥️  Hostname    : nima-server                              ║
║  📍 IP Address   : 2.144.21.218                              ║
║  💾 OS           : Debian/Ubuntu Linux                       ║
╠══════════════════════════════════════════════════════════════╣
║  ⚡ FRP Server   : v0.71.0 (Active ✅)                       ║
║  🚪 FRP Port     : 7000 (Main)                               ║
║  📊 Dashboard    : 7500 (Server Panel)                       ║
║  🖥️  Client UI   : 7400 (Client Admin)                       ║
║  📈 Status Page  : 8090 (Public Status)                      ║
║  🔑 Token Auth   : Enabled                                   ║
╠══════════════════════════════════════════════════════════════╣
║  🌐 HTTP Proxy   : 80 (vhost)                                ║
║  🔒 HTTPS Proxy  : 443 (vhost)                               ║
║  📁 Tunnel Range : 8000-9000                                 ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📦 Installation

### Prerequisites

- 🐧 Linux system (Debian 10+, Ubuntu 20.04+, RHEL 8+, CentOS 8+)
- 🔑 Root access
- 🌐 Internet connection

### Method 1: Automated Installation (Recommended)

```bash
# Download installation script
curl -L -o setup_frp.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/scripts/setup_frp.sh"

# Make executable
chmod +x setup_frp.sh

# Run installation
sudo ./setup_frp.sh
```

### Method 2: Manual Installation

```bash
# Download latest release (v0.71.0)
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz"

# Extract
tar -xzf /tmp/frp.tar.gz -C /tmp

# Install binaries
sudo install -m 755 /tmp/frp_0.71.0_linux_amd64/frps /usr/local/bin/frps
sudo install -m 755 /tmp/frp_0.71.0_linux_amd64/frpc /usr/local/bin/frpc

# Verify
frps --version
frpc --version
```

---

## ⚙️ Configuration

### Generate a Secure Token

```bash
# Generate a random 32-character token
openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
```

### Create Configuration Directory

```bash
sudo mkdir -p /etc/frp
sudo chmod 700 /etc/frp
```

### Server Configuration (frps.ini)

```bash
sudo tee /etc/frp/frps.ini <<EOF
[common]
bind_port = 7000
token = YOUR_GENERATED_TOKEN
vhost_http_port = 80
vhost_https_port = 443
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = YOUR_DASHBOARD_PASSWORD
max_pool_count = 50
tcp_mux = true
enable_prometheus = true
log_file = /var/log/frp/frps.log
log_level = info
log_max_days = 3
authentication_timeout = 900
allow_ports = 8000-9000
EOF
```

### Client Configuration (frpc.toml)

```bash
sudo tee /etc/frp/frpc.toml <<EOF
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_GENERATED_TOKEN"

transport.protocol = "tcp"
transport.poolCount = 5
transport.tcpMux = true
transport.heartbeatInterval = 30
transport.heartbeatTimeout = 90

log.level = "info"
log.maxDays = 3

# Client Admin UI (port 7400)
webServer.addr = "0.0.0.0"
webServer.port = 7400
webServer.user = "admin"
webServer.password = "admin"

# TCP Proxy with Health Check
[[proxies]]
name = "my-app-tcp"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080

[proxies.healthCheck]
type = "tcp"
timeoutSeconds = 3
maxFailed = 3
intervalSeconds = 10

# HTTP Proxy with Health Check
[[proxies]]
name = "my-app-http"
type = "http"
localIP = "127.0.0.1"
localPort = 8081
customDomains = ["myapp.local"]

[proxies.healthCheck]
type = "http"
path = "/"
timeoutSeconds = 3
maxFailed = 3
intervalSeconds = 10
EOF
```

### 📊 Configuration Reference

#### Server (`frps.ini`)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `bind_port` | 7000 | Main server port |
| `dashboard_port` | 7500 | Server dashboard port |
| `dashboard_user` | admin | Dashboard username |
| `dashboard_pwd` | - | Dashboard password |
| `vhost_http_port` | 80 | HTTP virtual host |
| `vhost_https_port` | 443 | HTTPS virtual host |
| `max_pool_count` | 50 | Connection pool size |
| `tcp_mux` | true | TCP multiplexing |
| `allow_ports` | - | Allowed port ranges |
| `log_level` | info | Log verbosity |

#### Client (`frpc.toml`)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `serverAddr` | - | Server IP address |
| `serverPort` | 7000 | Server port |
| `auth.method` | token | Authentication method |
| `auth.token` | - | Authentication token |
| `webServer.port` | - | Client Admin UI port |
| `transport.poolCount` | 5 | Connection pool size |
| `transport.tcpMux` | true | TCP multiplexing |

#### Health Check

| Parameter | Default | Description |
|-----------|---------|-------------|
| `type` | - | `tcp` or `http` |
| `path` | / | HTTP check path (HTTP only) |
| `timeoutSeconds` | 3 | Timeout per check |
| `maxFailed` | 3 | Failures before removal |
| `intervalSeconds` | 10 | Check interval |

---

## 🔧 Service Setup

### Create Systemd Service

```bash
sudo tee /etc/systemd/system/frps.service <<EOF
[Unit]
Description=FRP Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.ini
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=FRP Client
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
```

### Enable and Start Service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable services (auto-start on boot)
sudo systemctl enable frps.service
sudo systemctl enable frpc.service

# Start services
sudo systemctl start frps.service
sudo systemctl start frpc.service

# Check status
sudo systemctl status frps.service
sudo systemctl status frpc.service
```

---

## ⚡ Management Commands

### Service Control

| Command | Description |
|---------|-------------|
| `sudo systemctl start frps.service` | Start FRP server |
| `sudo systemctl stop frps.service` | Stop FRP server |
| `sudo systemctl restart frps.service` | Restart FRP server |
| `sudo systemctl status frps.service` | Check server status |
| `sudo systemctl enable frps.service` | Enable auto-start |
| `sudo systemctl disable frps.service` | Disable auto-start |

### View Logs

```bash
# Real-time server logs
sudo journalctl -u frps.service -f

# Real-time client logs
sudo journalctl -u frpc.service -f

# Last 50 lines
sudo journalctl -u frps.service -n 50

# Logs since last boot
sudo journalctl -u frps.service -b
```

---

## 👥 Client Management

### Add a New Client

```bash
# Generate client config
cat > /etc/frp/clients/myclient.ini <<EOF
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_TOKEN

[myclient-tcp]
type = tcp
local_ip = 127.0.0.1
local_port = 8050
remote_port = 8050
use_encryption = true
use_compression = true
EOF
```

### Generate Install Script for Client

```bash
# Create install script
cat > /etc/frp/clients/myclient-install.sh <<'SCRIPT'
#!/bin/bash
set -e

# Download FRPC
curl -L -o /tmp/frpc.tar.gz "https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz"
tar -xzf /tmp/frpc.tar.gz -C /tmp
sudo install -m 755 /tmp/frp_0.71.0_linux_amd64/frpc /usr/local/bin/frpc

# Copy config
sudo mkdir -p /etc/frp
sudo cp /etc/frp/clients/myclient.ini /etc/frp/frpc.ini

# Create service
sudo tee /etc/systemd/system/frpc.service <<EOF
[Unit]
Description=FRP Client
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.ini
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable frpc
sudo systemctl start frpc
echo "✅ FRP Client installed and started!"
SCRIPT

chmod +x /etc/frp/clients/myclient-install.sh
```

### Client Configuration Example

```toml
# Client Config (frpc.toml)
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_TOKEN"

# TCP Proxy
[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080

# HTTP Proxy with Auth
[[proxies]]
name = "my-web"
type = "http"
localIP = "127.0.0.1"
localPort = 8081
customDomains = ["myapp.local"]
```

---

## 👤 User Management

### HTTP Proxy Authentication

```bash
# Install htpasswd utility
sudo apt install apache2-utils

# Add user
sudo htpasswd -cb /etc/frp/htpasswd username password

# Add more users
sudo htpasswd -b /etc/frp/htpasswd user2 password2

# View users
cat /etc/frp/htpasswd

# Remove user
sudo htpasswd -D /etc/frp/htpasswd username
```

### Client Config with HTTP Auth

```toml
[[proxies]]
name = "my-web"
type = "http"
localIP = "127.0.0.1"
localPort = 8080
customDomains = ["myapp.local"]
httpUser = "username"
httpPwd = "password"
```

---

## 📊 Monitoring & Health Check

### 🏥 Service Health Check

Health check ensures high availability by monitoring proxy endpoints.

#### TCP Health Check

```toml
[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080

# Enable TCP health check
[proxies.healthCheck]
type = "tcp"
# TCPing timeout seconds
timeoutSeconds = 3
# If health check failed 3 times in a row, the proxy will be removed from frps
maxFailed = 3
# A health check every 10 seconds
intervalSeconds = 10
```

#### HTTP Health Check

```toml
[[proxies]]
name = "my-web"
type = "http"
localIP = "127.0.0.1"
localPort = 8080
customDomains = ["myapp.local"]

# Enable HTTP health check
[proxies.healthCheck]
type = "http"
# frpc will send a GET request to '/status'
# and expect an HTTP 2xx OK response
path = "/status"
timeoutSeconds = 3
maxFailed = 3
intervalSeconds = 10
```

### 📈 Server Dashboard

Access the FRP server dashboard at: `http://2.144.21.218:7500`

Default credentials:
- Username: `admin`
- Password: (set during installation)

### 🖥️ Client Admin UI

Access the Client Admin UI at: `http://2.144.21.218:7400`

Features:
- 📊 View all registered clients
- 🟢 See online/offline status
- 📈 Monitor traffic per client
- ➕ Add/remove clients
- 📝 Generate install scripts

### 📋 Status Page

Public status page at: `http://2.144.21.218:8090`

Shows:
- Server status and uptime
- Active connections
- Listening ports

---

## 🖥️ Client Admin UI

The Client Admin UI provides a web-based interface to manage and monitor clients.

### Access

URL: `http://2.144.21.218:7400`

### Features

- 📊 View all registered clients
- 🟢 See online/offline status
- 📈 Monitor traffic per client
- ➕ Add/remove clients
- 📝 Generate install scripts

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/clients` | GET | List all clients |
| `/api/clients/online` | GET | List online clients |
| `/api/clients` | POST | Add new client |
| `/api/clients/<name>` | DELETE | Remove client |

---

## 🛡️ Security

### Firewall Configuration

```bash
# Allow FRP server port
sudo ufw allow 7000/tcp

# Allow dashboard and admin
sudo ufw allow 7500/tcp
sudo ufw allow 7400/tcp

# Allow tunnel ports (8000-9000)
sudo ufw allow 8000:9000/tcp
sudo ufw allow 8000:9000/udp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### Recommended Security Practices

1. **🔑 Use a strong token** (32+ characters, random)
2. **🔒 Keep the token private** - never share publicly
3. **🛡️ Use firewall rules** to restrict access
4. **📊 Monitor logs** regularly
5. **🔄 Update FRP** to the latest version
6. **🔐 Enable encryption** for all tunnels
7. **📈 Use the dashboard** for monitoring
8. **👤 Enable HTTP authentication** for web proxies

### Change Token

```bash
# Stop services
sudo systemctl stop frps.service
sudo systemctl stop frpc.service

# Update token in both config files
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frps.ini
sudo sed -i 's/auth.token = .*/auth.token = "NEW_TOKEN"/' /etc/frp/frpc.toml

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl start frps.service
sudo systemctl start frpc.service
```

---

## 🔧 Troubleshooting

### Service Won't Start

```bash
# Check error logs
sudo journalctl -u frps.service --no-pager

# Check service configuration
sudo systemctl cat frps.service

# Test command manually
/usr/local/bin/frps -c /etc/frp/frps.ini
```

### Connection Issues

```bash
# Check if port is listening
sudo ss -tlnp | grep 7000

# Check firewall
sudo ufw status

# Test connectivity from remote
nc -zv 2.144.21.218 7000
```

### Performance Issues

```bash
# Check resource usage
sudo systemctl status frps.service

# View memory usage
ps aux | grep frp

# Check open connections
ss -tlnp | grep frp
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `port already in use` | Another service using port | Kill the process or change port |
| `authentication failed` | Wrong token | Verify token in both configs |
| `connection refused` | Server not running | Start the FRP server |
| `health check failed` | Local service down | Check the local service |
| `max_failed` exceeded | Too many failures | Increase `maxFailed` or fix the service |

### Log Locations

| Service | Log Location |
|---------|--------------|
| FRP Server | `/var/log/frp/frps.log` |
| FRP Client | `/var/log/frp/frpc.log` |
| Systemd | `journalctl -u frps.service` |

---

## 📚 Quick Reference

### Ports Summary

| Port | Service | Access |
|------|---------|--------|
| **7000** | FRP Server | Clients connect here |
| **7400** | Client Admin UI | `http://2.144.21.218:7400` |
| **7500** | Server Dashboard | `http://2.144.21.218:7500` |
| **8090** | Status Page | `http://2.144.21.218:8090` |
| **8000-9000** | Tunnel Range | For client proxies |

### Useful Commands

```bash
# Check all FRP processes
ps aux | grep frp

# View listening ports
ss -tlnp | grep frp

# Restart all services
sudo systemctl restart frps frpc

# View recent logs
journalctl -u frps -u frpc --since "1 hour ago"
```

---

<p align="center">
  <sub>Built with ❤️ for the secure server community</sub>
</p>
