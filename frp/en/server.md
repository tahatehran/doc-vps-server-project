# FRP Server Documentation

## 🖥️ Server Overview

This document provides complete documentation for setting up and managing an **FRP** secure tunnel server with client management, monitoring, and admin UI.

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Protocol** | TCP + UDP |
| **Authentication** | Token-based |
| **Port Range** | `8000-9000` (configurable) |
| **FRP Version** | v0.68.0 |

---

## 📋 Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Service Setup](#service-setup)
4. [Management Commands](#management-commands)
5. [Client Management](#client-management)
6. [User Management](#user-management)
7. [Monitoring Dashboard](#monitoring-dashboard)
8. [Client Admin UI](#client-admin-ui)
9. [Security](#security)
10. [Troubleshooting](#troubleshooting)

---

## 📦 Installation

### Prerequisites

- Linux system (Debian 10+, Ubuntu 20.04+, RHEL 8+, CentOS 8+)
- Root access
- Internet connection

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
# Download latest release
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"

# Extract
tar -xzf /tmp/frp.tar.gz -C /tmp

# Install
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frps /usr/local/bin/frps
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc

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

### Client Configuration (frpc.ini)

```bash
sudo tee /etc/frp/frpc.ini <<EOF
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_GENERATED_TOKEN
log_file = /var/log/frp/frpc.log
log_level = info
log_max_days = 3

[web_app_tcp]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8080
use_encryption = true
use_compression = true

[web_app_udp]
type = udp
local_ip = 127.0.0.1
local_port = 8081
remote_port = 8081
use_encryption = true
use_compression = true
EOF
```

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
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.ini
Restart=always
RestartSec=10
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

# Enable services
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

### frpctl - Management Script

The `frpctl` script provides a complete management interface:

```bash
# Server control
frpctl start               # Start FRP server
frpctl stop                # Stop FRP server
frpctl restart             # Restart FRP server
frpctl status              # Show server status
frpctl logs [n]            # Show last n log lines

# Client management
frpctl client add <name> [port] [http_user] [http_pass]
frpctl client list         # List all clients
frpctl client remove <name>
frpctl client config <name>
frpctl client install <name>
frpctl client online       # Show online clients

# User management
frpctl user add <user> <pass>
frpctl user list
frpctl user remove <user>

# Monitoring
frpctl monitor             # Real-time dashboard
frpctl monitor logs        # Monitor logs
frpctl monitor traffic     # Traffic statistics

# Other
frpctl info                # Server information
frpctl backup              # Backup configurations
```

### Service Control

| Command | Description |
|---------|-------------|
| `sudo systemctl start frps.service` | Start the FRP server |
| `sudo systemctl stop frps.service` | Stop the FRP server |
| `sudo systemctl restart frps.service` | Restart the FRP server |
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
# Add client with random port
frpctl client add myclient

# Add client with specific port
frpctl client add myclient 8050

# Add client with HTTP authentication
frpctl client add myclient 8050 myuser mypass
```

### Generate Install Script for Client

```bash
# Generate install script
frpctl client install myclient

# Copy to client machine and run
scp /etc/frp/clients/myclient-install.sh user@client-server:/
ssh user@client-server "sudo bash myclient-install.sh"
```

### Client Configuration Example

```ini
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_TOKEN

[myclient-tcp]
type = tcp
local_ip = 127.0.0.1
local_port = 8050
remote_port = 8050

[myclient-http]
type = http
local_ip = 127.0.0.1
local_port = 8080
custom_domains = myclient.local
http_user = myuser
http_pwd = mypass
```

---

## 👤 User Management

### Add Proxy User

```bash
frpctl user add username password
```

### List Users

```bash
frpctl user list
```

### Remove User

```bash
frpctl user remove username
```

---

## 📊 Monitoring Dashboard

### Real-time Monitor

```bash
frpctl monitor
```

This shows:
- Server status and uptime
- Listening ports
- Registered clients
- Recent logs

### Traffic Statistics

```bash
frpctl monitor traffic
```

### FRP Dashboard

Access the FRP dashboard at: `http://2.144.21.218:7500`

Default credentials:
- Username: `admin`
- Password: (set during installation)

---

## 🖥️ Client Admin UI

The Client Admin UI provides a web-based interface to manage and monitor clients.

### Access

URL: `http://2.144.21.218:8080`

### Features

- View all registered clients
- See online/offline status
- Monitor traffic per client
- Add/remove clients
- Generate install scripts

### API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/clients` | List all clients |
| `GET /api/clients/online` | List online clients |
| `POST /api/clients` | Add new client |
| `DELETE /api/clients/<name>` | Remove client |

---

## 🛡️ Security

### Firewall Configuration

```bash
# Allow FRP server port (default: 7000)
sudo ufw allow 7000/tcp

# Allow tunnel ports (8000-9000)
sudo ufw allow 8000:9000/tcp
sudo ufw allow 8000:9000/udp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### Recommended Security Practices

1. **Use a strong token** (32+ characters)
2. **Keep the token private** - never share publicly
3. **Use firewall rules** to restrict access
4. **Monitor logs** regularly
5. **Update FRP** to the latest version
6. **Enable encryption** for all tunnels
7. **Use the dashboard** for monitoring
8. **Enable HTTP authentication** for web proxies

### Change Token

```bash
# Stop services
sudo systemctl stop frps.service
sudo systemctl stop frpc.service

# Update token in both config files
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frps.ini
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frpc.ini

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
sudo netstat -tlnp | grep 7000

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
| `Connection refused` | Server offline or wrong port | Check server status and port |
| `Authentication failed` | Wrong token | Verify token matches server |
| `Address already in use` | Port in use | Choose different local port |
| `Timeout` | Network issues | Check firewall and connectivity |
| `permission denied` | File permissions | Check /etc/frp/ permissions |

---

## 📊 Server Information

### Default Configuration

| Setting | Value |
|---------|-------|
| **Server Port** | 7000 |
| **Dashboard Port** | 7500 |
| **Tunnel Port Range** | 8000-9000 |
| **Protocol** | TCP + UDP |
| **Authentication** | Token-based |
| **Auto-restart** | Yes (on-failure) |
| **Logging** | journald |

### Log Locations

| Log Type | Location |
|----------|----------|
| Server logs | `journalctl -u frps.service` |
| Client logs | `journalctl -u frpc.service` |
| Config files | `/etc/frp/` |
| System logs | `/var/log/syslog` or `/var/log/messages` |

---

## 📞 Support

For issues or questions:
- **GitHub Issues:** https://github.com/tahatehran/doc-vps-server-project/issues
- **FRP Repository:** https://github.com/fatedier/frp

---

*Last updated: September 1, 2026*
