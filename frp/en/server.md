# FRP Server Documentation

## 🖥️ Server Overview

This document provides complete documentation for setting up and managing an **FRP** secure tunnel server.

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Protocol** | TCP + UDP |
| **Authentication** | Token-based |
| **Port Range** | `8000-9000` (configurable) |

---

## 📋 Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Service Setup](#service-setup)
4. [Management Commands](#management-commands)
5. [Security](#security)
6. [Troubleshooting](#troubleshooting)

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
sudo tee /etc/systemd/system/frp-server.service <<EOF
[Unit]
Description=FRP Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.ini
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/frp-client.service <<EOF
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
sudo systemctl enable frp-server
sudo systemctl enable frp-client

# Start services
sudo systemctl start frp-server
sudo systemctl start frp-client

# Check status
sudo systemctl status frp-server
sudo systemctl status frp-client
```

---

## ⚡ Management Commands

### Service Control

| Command | Description |
|---------|-------------|
| `sudo systemctl start frp-server` | Start the FRP server |
| `sudo systemctl stop frp-server` | Stop the FRP server |
| `sudo systemctl restart frp-server` | Restart the FRP server |
| `sudo systemctl status frp-server` | Check server status |
| `sudo systemctl enable frp-server` | Enable auto-start |
| `sudo systemctl disable frp-server` | Disable auto-start |

### View Logs

```bash
# Real-time server logs
sudo journalctl -u frp-server -f

# Real-time client logs
sudo journalctl -u frp-client -f

# Last 50 lines
sudo journalctl -u frp-server -n 50

# Logs since last boot
sudo journalctl -u frp-server -b
```

### Check Server Status

```bash
# Is service active?
sudo systemctl is-active frp-server

# Is service enabled?
sudo systemctl is-enabled frp-server

# Get service PID
sudo systemctl show frp-server --property=MainPID

# View dashboard
curl http://localhost:7500
```

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

### Change Token

```bash
# Stop services
sudo systemctl stop frp-server
sudo systemctl stop frp-client

# Update token in both config files
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frps.ini
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frpc.ini

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl start frp-server
sudo systemctl start frp-client
```

---

## 🔧 Troubleshooting

### Service Won't Start

```bash
# Check error logs
sudo journalctl -u frp-server --no-pager

# Check service configuration
sudo systemctl cat frp-server

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
sudo systemctl status frp-server

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
| **Auto-restart** | Yes (10s delay) |
| **Logging** | journald |

### Log Locations

| Log Type | Location |
|----------|----------|
| Server logs | `journalctl -u frp-server` |
| Client logs | `journalctl -u frp-client` |
| Config files | `/etc/frp/` |
| System logs | `/var/log/syslog` or `/var/log/messages` |

---

## 📞 Support

For issues or questions:
- **GitHub Issues:** https://github.com/tahatehran/doc-vps-server-project/issues
- **FRP Repository:** https://github.com/fatedier/frp

---

*Last updated: September 1, 2026*
