# Bore Client Documentation (User)

## 👤 User Guide

This documentation is for **regular users** who want to connect to a Bore server without programming knowledge.

---

## 📋 Table of Contents

1. [What is Bore?](#what-is-bore)
2. [Quick Start](#quick-start)
3. [Basic Commands](#basic-commands)
4. [Common Use Cases](#common-use-cases)
5. [Troubleshooting](#troubleshooting)

---

## 🤔 What is Bore?

**Bore** is a tool that helps you share your local computer services with others over the internet. Think of it as a secure tunnel that connects your local programs to the world.

### Simple Example

```
Your Local Computer → Bore Tunnel → Internet → Other People Can Access
```

---

## 🚀 Quick Start

### Step 1: Install Bore

**Linux/macOS:**
```bash
curl -L -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"
tar -xzf /tmp/bore.tar.gz -C /tmp
sudo install -m 755 /tmp/bore /usr/local/bin/bore
```

**Windows (PowerShell):**
```powershell
scoop install bore-cli
```

### Step 2: Connect to Server

```bash
bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

That's it! Your local port 8080 is now accessible through the server.

---

## ⚡ Basic Commands

### Connect to Server

```bash
# Basic format
bore local <YOUR_PORT> --to <SERVER_IP>:<SERVER_PORT> --secret <SECRET>

# Example: Share your local web app running on port 3000
bore local 3000 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### Understanding the Command

| Part | What It Means | Example |
|------|---------------|---------|
| `bore local` | Start a local tunnel | `bore local` |
| `3000` | Your local port | `3000` |
| `--to` | Connect to server | `--to` |
| `2.144.21.218:7835` | Server address | `2.144.21.218:7835` |
| `--secret` | Authentication | `--secret` |
| `"YOUR_SECRET"` | Your secret key | `"abc123..."` |

---

## 💼 Common Use Cases

### 1. Share a Local Website

```bash
# If you have a website running on localhost:3000
bore local 3000 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### 2. Share a Database

```bash
# Share your local PostgreSQL database
bore local 5432 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### 3. Share Any Service

```bash
# Replace 8080 with any port number
bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

---

## 🔧 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| `Connection refused` | Check if the server is online |
| `Authentication failed` | Verify your secret is correct |
| `Port already in use` | Choose a different local port |
| `Command not found` | Install Bore properly |

### Getting Help

If you encounter issues:
1. Check the server status
2. Verify your secret key
3. Try a different port
4. Contact the server administrator

---

## 📞 Need More Help?

- **Server Administrator:** Contact for secret key and server access
- **Bore GitHub:** https://github.com/ekzhang/bore

---

*Last updated: September 1, 2026*
