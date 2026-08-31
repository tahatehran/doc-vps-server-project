# Bore Server Documentation

## 🖥️ Server Overview

This document provides complete documentation for setting up and managing a **Bore** secure tunnel server.

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Port** | `7835` |
| **Protocol** | TCP |
| **Authentication** | Secret-based |

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
curl -L -o setup_bore.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/scripts/setup_bore.sh"

# Make executable
chmod +x setup_bore.sh

# Run installation
sudo ./setup_bore.sh
```

### Method 2: Manual Installation

```bash
# Download Bore binary
curl -L -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"

# Extract
tar -xzf /tmp/bore.tar.gz -C /tmp

# Install
sudo install -m 755 /tmp/bore /usr/local/bin/bore

# Verify
bore --version
```

---

## ⚙️ Configuration

### Generate a Secure Secret

```bash
# Generate a random 32-character secret
openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
```

### Create Configuration Directory

```bash
sudo mkdir -p /etc/bore
sudo chmod 700 /etc/bore
```

### Store Secret (Optional)

```bash
# Save secret to file (for systemd service)
echo "YOUR_GENERATED_SECRET" | sudo tee /etc/bore/secret
sudo chmod 600 /etc/bore/secret
```

---

## 🔧 Service Setup

### Create Systemd Service

```bash
sudo tee /etc/systemd/system/bore-server.service <<EOF
[Unit]
Description=Bore Secure Tunnel Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/bore server --secret "YOUR_SECRET_HERE"
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/log/bore/

[Install]
WantedBy=multi-user.target
EOF
```

### Enable and Start Service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable bore-server

# Start service
sudo systemctl start bore-server

# Check status
sudo systemctl status bore-server
```

---

## ⚡ Management Commands

### Service Control

| Command | Description |
|---------|-------------|
| `sudo systemctl start bore-server` | Start the server |
| `sudo systemctl stop bore-server` | Stop the server |
| `sudo systemctl restart bore-server` | Restart the server |
| `sudo systemctl status bore-server` | Check server status |
| `sudo systemctl enable bore-server` | Enable auto-start |
| `sudo systemctl disable bore-server` | Disable auto-start |

### View Logs

```bash
# Real-time logs
sudo journalctl -u bore-server -f

# Last 50 lines
sudo journalctl -u bore-server -n 50

# Logs since last boot
sudo journalctl -u bore-server -b
```

### Check Server Status

```bash
# Is service active?
sudo systemctl is-active bore-server

# Is service enabled?
sudo systemctl is-enabled bore-server

# Get service PID
sudo systemctl show bore-server --property=MainPID
```

---

## 🛡️ Security

### Firewall Configuration

```bash
# Allow Bore port (default: 7835)
sudo ufw allow 7835/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### Recommended Security Practices

1. **Use a strong secret** (32+ characters)
2. **Keep the secret private** - never share publicly
3. **Use firewall rules** to restrict access
4. **Monitor logs** regularly
5. **Update Bore** to the latest version

### Change Secret

```bash
# Stop service
sudo systemctl stop bore-server

# Update secret in service file
sudo sed -i 's/secret ".*"/secret "NEW_SECRET"/' /etc/systemd/system/bore-server.service

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl start bore-server
```

---

## 🔧 Troubleshooting

### Service Won't Start

```bash
# Check error logs
sudo journalctl -u bore-server --no-pager

# Check service configuration
sudo systemctl cat bore-server

# Test command manually
/usr/local/bin/bore server --secret "YOUR_SECRET"
```

### Connection Issues

```bash
# Check if port is listening
sudo netstat -tlnp | grep 7835

# Check firewall
sudo ufw status

# Test connectivity from remote
nc -zv 2.144.21.218 7835
```

### Performance Issues

```bash
# Check resource usage
sudo systemctl status bore-server

# View memory usage
ps aux | grep bore

# Check open connections
ss -tlnp | grep 7835
```

---

## 📊 Server Information

### Default Configuration

| Setting | Value |
|---------|-------|
| **Listen Port** | 7835 |
| **Protocol** | TCP |
| **Authentication** | Secret-based |
| **Auto-restart** | Yes (10s delay) |
| **Logging** | journald |

### Log Locations

| Log Type | Location |
|----------|----------|
| Service logs | `journalctl -u bore-server` |
| System logs | `/var/log/syslog` or `/var/log/messages` |

---

## 📞 Support

For issues or questions:
- **GitHub Issues:** https://github.com/tahatehran/doc-vps-server-project/issues
- **Bore Repository:** https://github.com/ekzhang/bore

---

*Last updated: September 1, 2026*
