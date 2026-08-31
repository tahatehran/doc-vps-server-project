# Bore Multi-App Configuration Guide

## 📋 Configure 5 Apps with 5 Different Ports

This guide shows how to configure **5 different applications** with **5 different ports** on a single Bore server.

---

## 🖥️ Server Configuration (Single Server)

The Bore server runs as a single instance. All 5 apps share the same server.

### Start Bore Server

```bash
# Single server handles all apps
sudo systemctl start bore-server
```

### Firewall Rules (All 5 Apps)

```bash
# Allow Bore control port
sudo ufw allow 7835/tcp

# Allow all 5 app ports
sudo ufw allow 8000/tcp
sudo ufw allow 8001/tcp
sudo ufw allow 8002/tcp
sudo ufw allow 8003/tcp
sudo ufw allow 8004/tcp

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
| **App 4** | Redis | 6379 | 8003 | TCP | Cache server |
| **App 5** | Admin Panel | 9000 | 8004 | TCP | Admin dashboard |

---

### Method 1: Individual Commands (Quick Start)

```bash
# App 1: Web Server
bore local 3000 --to 2.144.21.218:8000 --secret "YOUR_SECRET"

# App 2: API Server
bore local 8080 --to 2.144.21.218:8001 --secret "YOUR_SECRET"

# App 3: Database
bore local 5432 --to 2.144.21.218:8002 --secret "YOUR_SECRET"

# App 4: Redis
bore local 6379 --to 2.144.21.218:8003 --secret "YOUR_SECRET"

# App 5: Admin Panel
bore local 9000 --to 2.144.21.218:8004 --secret "YOUR_SECRET"
```

---

### Method 2: Multi-Tunnel Script (Recommended)

```bash
#!/bin/bash
# bore-multi-app.sh - Start all 5 app tunnels

SECRET="YOUR_SECRET"
SERVER="2.144.21.218"

# App configurations: local_port:remote_port:description
APPS=(
    "3000:8000:Web Server"
    "8080:8001:API Server"
    "5432:8002:PostgreSQL"
    "6379:8003:Redis"
    "9000:8004:Admin Panel"
)

start_all() {
    echo "Starting all 5 Bore tunnels..."
    for app in "${APPS[@]}"; do
        IFS=':' read -r local_port remote_port name <<< "$app"
        echo "  → $name (local:$local_port → $SERVER:$remote_port)"
        bore local $local_port --to $SERVER:$remote_port --secret "$SECRET" &
    done
    echo "All 5 tunnels started!"
}

stop_all() {
    echo "Stopping all Bore tunnels..."
    pkill -f "bore local"
    echo "All tunnels stopped."
}

status() {
    echo "Active Bore tunnels:"
    ps aux | grep "bore local" | grep -v grep
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
chmod +x bore-multi-app.sh

# Start all tunnels
./bore-multi-app.sh start

# Check status
./bore-multi-app.sh status

# Stop all
./bore-multi-app.sh stop
```

---

### Method 3: Systemd Service (Production)

```bash
sudo tee /etc/systemd/system/bore-multi-app.service <<EOF
[Unit]
Description=Bore Multi-App Tunnel Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/bore-multi-app.sh start
ExecStop=/usr/local/bin/bore-multi-app.sh stop
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bore-multi-app
sudo systemctl start bore-multi-app
```

---

## 📊 Port Mapping Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    BORE SERVER (2.144.21.218)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Port 7835  ←── Control Port (authentication)               │
│                                                             │
│  Port 8000  ←── App 1: Web Server (TCP)                    │
│  Port 8001  ←── App 2: API Server (TCP)                    │
│  Port 8002  ←── App 3: PostgreSQL (TCP)                    │
│  Port 8003  ←── App 4: Redis (TCP)                         │
│  Port 8004  ←── App 5: Admin Panel (TCP)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Quick Reference

### Start All Tunnels
```bash
./bore-multi-app.sh start
```

### Check Status
```bash
./bore-multi-app.sh status
```

### View Logs
```bash
# All tunnels
sudo journalctl -u bore-multi-app -f

# Specific app (check process)
ps aux | grep "bore local"
```

### Stop All
```bash
./bore-multi-app.sh stop
```

---

## ⚠️ Important Notes

1. **Bore is TCP only** - For UDP, use FRP instead
2. **Each app needs a unique remote port** - No duplicates
3. **Secret is shared** - All apps use the same secret
4. **Auto-reconnect** - Implement restart logic for production
5. **Monitor resources** - 5 tunnels = 5x resource usage

---

*Last updated: September 1, 2026*
