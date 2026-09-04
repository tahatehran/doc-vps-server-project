# FRP Multi-App Configuration Guide

## 📋 Configure 5 Apps with Different Ports (TCP + UDP)

This guide shows how to configure **5 different applications** with **different ports** on a single FRP server, including both **TCP and UDP** support.

---

## 🖥️ Server Configuration (Single Server)

### Server Configuration File

```bash
sudo tee /etc/frp/frps.ini <<EOF
[common]
bind_port = 7000
token = YOUR_GENERATED_TOKEN
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

### Firewall Rules (All 5 Apps)

```bash
# Allow FRP server port
sudo ufw allow 7000/tcp

# Allow tunnel ports (8000-9000) for TCP and UDP
sudo ufw allow 8000:9000/tcp
sudo ufw allow 8000:9000/udp

# Verify
sudo ufw status
```

---

## 📱 Client Configuration (5 Apps)

### App Configuration Table

| App | Service | Local Port | Remote Port | Protocol | Purpose |
|-----|---------|------------|-------------|----------|---------|
| **App 1** | Web Server | 3000 | 8000 | TCP | React/Vue frontend |
| **App 2** | API Server | 8080 | 8001 | TCP | REST API backend |
| **App 3** | Database | 5432 | 8002 | TCP | PostgreSQL |
| **App 4** | Game Server | 19132 | 8003 | UDP | Minecraft/minecraft-like |
| **App 5** | Admin Panel | 9000 | 8004 | TCP | Admin dashboard |

---

### Method 1: Individual Commands (Quick Start)

```bash
# App 1: Web Server (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 3000 --remote-port 8000

# App 2: API Server (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8001

# App 3: Database (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 5432 --remote-port 8002

# App 4: Game Server (UDP)
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 19132 --remote-port 8003

# App 5: Admin Panel (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 9000 --remote-port 8004
```

---

### Method 2: Config File (Recommended)

```bash
sudo tee /etc/frp/frpc.ini <<EOF
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_GENERATED_TOKEN
log_file = /var/log/frp/frpc.log
log_level = info
log_max_days = 3

# App 1: Web Server (TCP)
[web_app]
type = tcp
local_ip = 127.0.0.1
local_port = 3000
remote_port = 8000
use_encryption = true
use_compression = true

# App 2: API Server (TCP)
[api_app]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8001
use_encryption = true
use_compression = true

# App 3: Database (TCP)
[database]
type = tcp
local_ip = 127.0.0.1
local_port = 5432
remote_port = 8002
use_encryption = true
use_compression = true

# App 4: Game Server (UDP)
[game_server]
type = udp
local_ip = 127.0.0.1
local_port = 19132
remote_port = 8003
use_encryption = true
use_compression = true

# App 5: Admin Panel (TCP)
[admin_panel]
type = tcp
local_ip = 127.0.0.1
local_port = 9000
remote_port = 8004
use_encryption = true
use_compression = true
EOF
```

---

### Method 3: Multi-Tunnel Script

```bash
#!/bin/bash
# frp-multi-app.sh - Start all 5 app tunnels

SERVER="2.144.21.218:7000"
TOKEN="YOUR_TOKEN"

# App configurations: local_port:remote_port:protocol:description
APPS=(
    "3000:8000:tcp:Web Server"
    "8080:8001:tcp:API Server"
    "5432:8002:tcp:PostgreSQL"
    "19132:8003:udp:Game Server"
    "9000:8004:tcp:Admin Panel"
)

start_all() {
    echo "Starting all 5 FRP tunnels..."
    for app in "${APPS[@]}"; do
        IFS=':' read -r local_port remote_port protocol name <<< "$app"
        echo "  → $name (local:$local_port → $SERVER:$remote_port, $protocol)"
        frpc $protocol --server-addr "$SERVER_ADDR" --server-port "$SERVER_PORT" --token "$TOKEN" --local-port $local_port --remote-port $remote_port &
    done
    echo "All 5 tunnels started!"
}

stop_all() {
    echo "Stopping all FRP tunnels..."
    pkill -f "frpc"
    echo "All tunnels stopped."
}

status() {
    echo "Active FRP tunnels:"
    ps aux | grep "frpc" | grep -v grep
}

case "$1" in
    start) start_all ;;
    stop) stop_all ;;
    status) status ;;
    *) echo "Usage: $0 {start|stop|status}" ;;
esac
```

```bash
# Make executable
chmod +x frp-multi-app.sh

# Start all tunnels
./frp-multi-app.sh start

# Check status
./frp-multi-app.sh status

# Stop all
./frp-multi-app.sh stop
```

---

### Method 4: Systemd Service (Production)

```bash
sudo tee /etc/systemd/system/frp-client.service <<EOF
[Unit]
Description=FRP Multi-App Client
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

sudo systemctl daemon-reload
sudo systemctl enable frp-client
sudo systemctl start frp-client
```

---

## 📊 Port Mapping Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    FRP SERVER (2.144.21.218)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Port 7000  ←── Control Port (authentication)               │
│                                                             │
│  Port 8000  ←── App 1: Web Server (TCP)                    │
│  Port 8001  ←── App 2: API Server (TCP)                    │
│  Port 8002  ←── App 3: PostgreSQL (TCP)                    │
│  Port 8003  ←── App 4: Game Server (UDP) ← UDP!            │
│  Port 8004  ←── App 5: Admin Panel (TCP)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Quick Reference

### Start All Tunnels
```bash
# Using config file
frpc -c /etc/frp/frpc.ini

# Or using script
./frp-multi-app.sh start
```

### Check Status
```bash
# Service status
sudo systemctl status frp-client

# Active tunnels
./frp-multi-app.sh status

# Dashboard
curl http://localhost:7500
```

### View Logs
```bash
# Client logs
sudo journalctl -u frp-client -f

# Server logs
sudo journalctl -u frp-server -f
```

### Stop All
```bash
sudo systemctl stop frp-client
# Or
./frp-multi-app.sh stop
```

---

## ⚠️ Important Notes

1. **FRP supports both TCP and UDP** - Use UDP for real-time apps (games, VoIP)
2. **Each app needs a unique remote port** - No duplicates
3. **Token is shared** - All apps use the same token
4. **Enable encryption** - Always set `use_encryption = true`
5. **Enable compression** - Recommended for better throughput
6. **Monitor resources** - 5 tunnels = 5x resource usage

---

## 📈 Comparison: Bore vs FRP for Multi-App

| Feature | Bore | FRP |
|---------|------|-----|
| TCP Support | ✅ | ✅ |
| UDP Support | ❌ | ✅ |
| Config File | ❌ (CLI only) | ✅ (INI/TOML) |
| Dashboard | ❌ | ✅ (Web UI) |
| Compression | ❌ | ✅ |
| Encryption | ✅ (secret) | ✅ (token + encryption) |
| Auto-Reconnect | Manual | Built-in |

---

*Last updated: September 1, 2026*
