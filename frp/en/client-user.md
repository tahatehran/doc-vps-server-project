# FRP Client Documentation (User)

## 👤 User Guide

This documentation is for **regular users** who want to connect to an FRP server without programming knowledge.

---

## 📋 Table of Contents

1. [What is FRP?](#what-is-frp)
2. [Quick Start](#quick-start)
3. [Basic Commands](#basic-commands)
4. [Common Use Cases](#common-use-cases)
5. [Troubleshooting](#troubleshooting)

---

## 🤔 What is FRP?

**FRP (Fast Reverse Proxy)** is a tool that helps you share your local computer services with others over the internet. It supports both **TCP and UDP** protocols.

### Simple Example

```
Your Local Computer → FRP Tunnel → Internet → Other People Can Access
```

---

## 🚀 Quick Start

### Step 1: Install FRP

**Linux/macOS:**
```bash
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"
tar -xzf /tmp/frp.tar.gz -C /tmp
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc
```

**Windows (PowerShell):**
```powershell
scoop install frp
```

### Step 2: Connect to Server

```bash
# TCP connection
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080

# UDP connection
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8081 --remote-port 8081
```

That's it! Your local port is now accessible through the server.

---

## ⚡ Basic Commands

### Connect to Server

```bash
# Basic format
frpc <PROTOCOL> --server-addr <SERVER_ADDR> --server-port <PORT> --token <TOKEN> --local-port <PORT> --remote-port <PORT>

# Example: Share your local web app running on port 3000
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 3000 --remote-port 3000
```

### Understanding the Command

| Part | What It Means | Example |
|------|---------------|---------|
| `frpc` | Start FRP client | `frpc` |
| `tcp` (subcommand) | Protocol to tunnel | `tcp`, `udp`, `http`, ... |
| `--server-addr` | Server address | `--server-addr 2.144.21.218` |
| `--server-port` | Server port | `--server-port 7000` |
| `--token` | Authentication token | `--token YOUR_TOKEN` |
| `--local-port` | Your local port | `--local-port 8080` |
| `--remote-port` | Server port | `--remote-port 8080` |

---

## 💼 Common Use Cases

### 1. Share a Local Website (TCP)

```bash
# If you have a website running on localhost:3000
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 3000 --remote-port 3000
```

### 2. Share a Game Server (UDP)

```bash
# Share your local game server
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 19132 --remote-port 19132
```

### 3. Share a Database (TCP)

```bash
# Share your local PostgreSQL database
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 5432 --remote-port 5432
```

### 4. Share Any Service

```bash
# Replace 8080 with any port number
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080
```

---

## 🔧 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| `Connection refused` | Check if the server is online |
| `Authentication failed` | Verify your token is correct |
| `Port already in use` | Choose a different local port |
| `Command not found` | Install FRP properly |

### Getting Help

If you encounter issues:
1. Check the server status
2. Verify your token
3. Try a different port
4. Contact the server administrator

---

## 📞 Need More Help?

- **Server Administrator:** Contact for token and server access
- **FRP GitHub:** https://github.com/fatedier/frp

---

*Last updated: September 1, 2026*
