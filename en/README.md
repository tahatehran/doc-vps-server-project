# Bore Secure Server Documentation

## 🎯 Project Overview

Bore is a modern, simple TCP tunnel in Rust that exposes local ports to a remote server, bypassing standard NAT connection firewalls. This project provides comprehensive documentation for deploying, configuring, and using Bore in various scenarios.

### Key Features
- 🔒 **Security**: End-to-end encryption with strong authentication
- ⚡ **Performance**: Fast, lightweight Rust implementation
- 🔧 **Flexibility**: Supports various tunneling scenarios
- 🌐 **Cross-platform**: Windows, macOS, Linux support
- 🛡️ **Privacy**: Minimal data exposure, no logging

## 🚀 Quick Start

### Prerequisites
- Linux system (Debian 10+, Ubuntu 20.04+, RHEL 8+, CentOS 8+)
- Root privileges (or sudo access)
- Internet connection
- Secure password (30+ characters)

### Installation

#### Step 1: Download Installation Script
```bash
# Download installation script
curl -L -o setup_bore.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/setup_bore.sh"

# Make executable
chmod +x setup_bore.sh

# Run installation (requires root/sudo)
sudo ./setup_bore.sh
```

#### Step 2: Verify Installation
```bash
# Check Bore version
bore --version

# Check service status
sudo systemctl status bore-server
```

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Installation Instructions](#installation-instructions)
  - [Linux (Debian/Ubuntu)](#linux-debuntu)
  - [Linux (RHEL/CentOS)](#linux-rhelcentos)
  - [Installation Script](#installation-script)
- [Configuration](#configuration)
  - [Service Setup](#service-setup)
  - [Security Settings](#security-settings)
- [Usage Examples](#usage-examples)
  - [Basic Tunnel](#basic-tunnel)
  - [Advanced Configuration](#advanced-configuration)
- [Management Commands](#management-commands)
  - [Service Control](#service-control)
  - [Log Monitoring](#log-monitoring)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debug Commands](#debug-commands)
- [Use Cases](#use-cases)
  - [Local Service Exposure](#local-service-exposure)
  - [Remote Access](#remote-access)
  - [Reverse Tunneling](#reverse-tunneling)
  - [Development and Testing](#development-and-testing)
- [Security Best Practices](#security-best-practices)
- [FAQ](#faq)
- [Resources and Links](#resources-and-links)

## 💻 System Requirements

### Minimum Requirements
| Component | Requirement |
|-----------|-------------|
| OS | Debian 10+, Ubuntu 20.04+, RHEL 8+, CentOS 8+ |
| Kernel | 4.15+ |
| RAM | 256 MB |
| Disk Space | 50 MB |
| Network | Broadband Internet connection |
| Privileges | Root (for installation) |

### Recommended Configuration
| Component | Recommended |
|-----------|-------------|
| RAM | 1 GB+ |
| SWAP | 512 MB |
| Kernel | 5.10+ |
| Users | Dedicated `bore` user |

## 📦 Installation

### Linux (Debian/Ubuntu)

#### Method 1: Package Manager
```bash
# Update package list
sudo apt update

# Install Bore from package
sudo apt install -y bore-cli
```

#### Method 2: Manual Installation
```bash
# Download release binary
wget -O /tmp/bore https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl

# Make executable
chmod +x /tmp/bore

# Install to /usr/local/bin
sudo mv /tmp/bore /usr/local/bin/
```

### Linux (RHEL/CentOS)

#### Method 1: Package Manager
```bash
# Install Bore
sudo yum install -y bore-cli
```

#### Method 2: Manual Installation
```bash
# Download release binary
sudo curl -L -o /usr/local/bin/bore https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz
sudo tar -xzf /usr/local/bin/bore.tar.gz -C /usr/local/bin bore
sudo chmod +x /usr/local/bin/bore
```

### Installation Script (Recommended)

Our comprehensive installation script automates the entire process:

```bash
# Download installation script
curl -L -o setup_bore.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/setup_bore.sh"

# Make executable
chmod +x setup_bore.sh

# Run installation
sudo ./setup_bore.sh
```

---

## ⚙️ Configuration

### Service Setup

#### Creating a Systemd Service
```bash
# Create service file
sudo tee /etc/systemd/system/bore-server.service <<EOF
[Unit]
Description=Bore Secure Tunnel Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=bore
Group=bore
ExecStart=/usr/local/bin/bore server --secret "YOUR_SECURE_PASSWORD"
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/log/bore/

[Install]
WantedBy=multi-user.target
EOF
```

#### Enable and Start Service
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable bore-server

# Start service
sudo systemctl start bore-server

# Check status
sudo systemctl status bore-server
```

### Security Settings

#### Password Configuration
```bash
# Generate a secure password
SECURE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-30)
echo "$SECURE_PASSWORD"

# Or use a memorable but secure password
SECURE_PASSWORD="MyS3cureB0re!2024@Password123#"
```

#### File Permissions
```bash
# Create secure directories
sudo mkdir -p /var/log/bore
sudo mkdir -p /etc/bore

# Set appropriate permissions
sudo chown bore:bore /var/log/bore
sudo chmod 750 /var/log/bore

sudo chown -R bore:bore /etc/bore
sudo chmod 700 /etc/bore
```

---

## 🔗 Client Connection

### Basic Tunnel

#### Expose Local Service
```bash
# Forward local port 8080 to remote server
bore local 8080 --to your-server.com:80 --secret "YOUR_SECURE_PASSWORD"
```

#### Forward Remote Service to Local
```bash
# Access local service from remote
bore local 3306 --to bore.server.com:3306 --secret "YOUR_SECURE_PASSWORD"
```

### Advanced Configuration

#### Persistent Tunnel with Auto-reconnect
```bash
# Create a script for persistent connection
cat > ~/bore-tunnel.sh <<EOF
#!/bin/bash
while true; do
    bore local 8080 --to your-server.com:80 --secret "YOUR_SECURE_PASSWORD"
    sleep 5
done
EOF

chmod +x ~/bore-tunnel.sh

# Start in background
nohup ~/bore-tunnel.sh > ~/bore.log 2>&1 &
```

#### Environment Variables
```bash
# Create environment file
cat > ~/.bore.env <<EOF
BORE_SECRET="YOUR_SECURE_PASSWORD"
BORE_REMOTE_HOST="your-server.com"
BORE_REMOTE_PORT="80"
BORE_LOCAL_PORT="8080"
EOF

# Source environment
source ~/.bore.env

# Use in bore command
bore local $BORE_LOCAL_PORT --to $BORE_REMOTE_HOST:$BORE_REMOTE_PORT --secret $BORE_SECRET
```

---

## ⚡ Management Commands

### Service Control

#### Start/Stop/Restart
```bash
# Start service
sudo systemctl start bore-server

# Stop service
sudo systemctl stop bore-server

# Restart service
sudo systemctl restart bore-server

# Reload configuration
sudo systemctl reload bore-server
```

#### Status Check
```bash
# Check service status
sudo systemctl is-active bore-server
sudo systemctl is-enabled bore-server

# View detailed status
sudo systemctl status bore-server

# View logs (real-time)
sudo journalctl -u bore-server -f

# View recent logs
sudo journalctl -u bore-server --since "1 hour ago"
```

### Log Management

#### Log Rotation
```bash
# Create logrotate configuration
sudo tee /etc/logrotate.d/bore-server <<EOF
/var/log/bore/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 640 bore bore
    postrotate
        systemctl reload bore-server || true
    endscript
}
EOF
```

---

## 🔧 Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check error logs
sudo journalctl -u bore-server --no-pager

# Check system logs
sudo journalctl -u bore-server -f
```

#### Connection Refused
```bash
# Check if service is running
sudo systemctl status bore-server

# Check firewall rules
sudo ufw status
sudo iptables -L -n | grep 7835

# Check if port is open
netstat -tlnp | grep 7835
```

#### Authentication Failed
```bash
# Verify password
sudo grep "secret" /etc/systemd/system/bore-server.service

# Restart service with correct password
sudo systemctl restart bore-server
```

### Debug Commands

#### Service Information
```bash
# Get service PID
sudo systemctl show bore-server --property=MainPID

# Check service configuration
systemctl cat bore-server

# View environment variables
systemctl show bore-server --property=Environment --property=ExecStart
```

#### Network Diagnostics
```bash
# Test connectivity
curl -v http://localhost:8080

# Check open ports
sudo apt install -y net-tools
netstat -tlnp | grep 7835

# Check firewall
sudo ufw status
sudo iptables -L -n | grep 7835
```

---

## 💼 Use Cases

### Local Service Exposure

#### Web Application
```bash
# Forward local web server
bore local 80 --to remote-server.com:80 --secret "your-password"
```

#### Database Access
```bash
# Access local database from remote
bore local 3306 --to db.server.com:3306 --secret "your-password"
```

#### Development Environment
```bash
# Connect to local development environment
bore local 3000 --to dev-server.com:3000 --secret "your-password"
```

### Remote Access

#### Home Server Access
```bash
# Access home server from anywhere
bore local 22 --to home-server.local:22 --secret "your-password"
```

#### Cloud Service Access
```bash
# Access cloud database
bore local 5432 --to aws-db.instance.us-east-1.rds.amazonaws.com:5432 --secret "your-password"
```

### Reverse Tunneling

#### Server to Server Communication
```bash
# Forward traffic from server A to server B
bore local 80 --to server-b.com:80 --secret "your-password"
```

#### Network Testing
```bash
# Test internal network connectivity
bore local 9999 --to internal-server:9999 --secret "your-password"
```

### Development and Testing

#### CI/CD Pipeline
```bash
# Use in CI/CD for testing
bore local 3000 --to test-environment:3000 --secret "$CI_BORE_SECRET"
```

#### Local Development
```bash
# Forward local service to staging
bore local 8080 --to staging-server:8080 --secret "your-password"
```

---

## 🛡️ Security Best Practices

### Password Management

#### Password Requirements
- Use at least 30 characters
- Mix of uppercase, lowercase, numbers, and special characters
- No dictionary words or personal information
- Rotate passwords regularly

#### Password Storage
```bash
# Store in environment file
echo "export BORE_SECRET='your-secure-password'" > ~/.bore.env
chmod 600 ~/.bore.env

# Add to shell profile
echo 'source ~/.bore.env' >> ~/.bashrc
source ~/.bashrc
```

### File System Security

#### Directory Permissions
```bash
# Create secure directories
sudo mkdir -p /etc/bore
sudo mkdir -p /var/log/bore

# Set permissions
sudo chmod 700 /etc/bore
sudo chmod 750 /var/log/bore
sudo chown -R bore:bore /etc/bore
sudo chown -R bore:bore /var/log/bore
```

### Network Security

#### Firewall Configuration
```bash
# Allow only specific IPs
sudo ufw allow from 192.168.1.100 to any port 7835
sudo ufw allow from 10.0.0.0/8 to any port 7835

# Deny all other connections
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

#### SSH Key Authentication
```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/bore-server

# Copy public key to authorized keys
cat ~/.ssh/bore-server.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## ❓ FAQ

### Installation Issues

#### "sudo: command not found"
```bash
# Install sudo (for Debian/Ubuntu)
sudo apt install -y sudo

# Or use root directly
su -c "your-command"
```

#### "Permission denied"
```bash
# Check current permissions
ls -la /usr/local/bin/bore

# Fix permissions
sudo chmod 755 /usr/local/bin/bore
```

#### "Command not found: bore"
```bash
# Check if bore is in PATH
echo $PATH | tr ':' '\n' | grep bore

# Add to PATH
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
bore --version
```

### Service Issues

#### "Service failed to start"
```bash
# Check logs
sudo journalctl -u bore-server -f

# Check configuration
sudo systemctl cat bore-server

# Restart service
sudo systemctl restart bore-server
```

#### "Connection refused"
```bash
# Check if service is running
sudo systemctl is-active bore-server

# Check firewall
sudo ufw status
sudo iptables -L -n | grep 7835
```

### Configuration Issues

#### "Secret not set"
```bash
# Check service configuration
grep "secret" /etc/systemd/system/bore-server.service

# Update secret
sudo sed -i 's/secret=".*"/secret="new-secret"/' /etc/systemd/system/bore-server.service

# Restart service
sudo systemctl restart bore-server
```

---

## 📚 Resources and Links

### Official Resources
- **GitHub Repository**: https://github.com/ekzhang/bore
- **Releases Page**: https://github.com/ekzhang/bore/releases
- **Documentation**: https://github.com/ekzhang/bore/blob/main/README.md

### Community Resources
- **Discord Server**: https://discord.gg/ekzhang
- **Reddit**: https://www.reddit.com/r/bore/
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/bore-cli

### Tutorials and Guides
- **Bore Quick Start**: https://github.com/ekzhang/bore/blob/main/docs/quickstart.md
- **Advanced Configuration**: https://github.com/ekzhang/bore/blob/main/docs/advanced.md
- **Security Best Practices**: https://github.com/ekzhang/bore/blob/main/docs/security.md

---

## 🎯 Conclusion

Bore provides a powerful, secure way to create encrypted tunnels for remote access and service exposure. This comprehensive guide covers installation, configuration, management, and troubleshooting for both beginners and advanced users.

**Remember:**
1. Use strong, unique passwords
2. Regularly update and monitor your tunnels
3. Follow security best practices
4. Keep documentation updated
5. Test your setup thoroughly

For more information, visit the official Bore documentation and community resources listed above. Happy tunneling! 🚀

---

*Last updated: August 30, 2026*
*Version: 1.0*