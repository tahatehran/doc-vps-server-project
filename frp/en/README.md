# FRP Secure Server Documentation

> **🌐 Language:** [English](en/frp/README.md) | [فارسی](fa/frp/README.md)

---

## 📋 Overview

This section contains comprehensive documentation for **FRP (Fast Reverse Proxy)**, a powerful reverse proxy that supports **TCP, UDP, HTTP, HTTPS** protocols.

**🔐 Secure. ⚡ Fast. 🔧 Flexible. 🌐 Multi-Protocol.**

---

## 🖥️ Server Information

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Protocol** | TCP + UDP |
| **Authentication** | Token-based |
| **Port Range** | `8000-9000` (configurable) |
| **Status** | 🔴 Offline (currently disabled) |

---

## 📁 FRP Documentation Structure

```
doc-vps-server-project/
├── 📁 en/frp/                      # English FRP Documentation
│   ├── 📄 README.md                # FRP overview
│   ├── 📄 server.md                # Server setup & commands
│   ├── 📄 client-developer.md      # Client guide for developers
│   └── 📄 client-user.md           # Client guide for regular users
│
├── 📁 fa/frp/                      # Persian FRP Documentation
│   ├── 📄 README.md                # نمای کلی FRP
│   ├── 📄 server.md                # راهنمای سرور
│   ├── 📄 client-developer.md      # راهنمای کلاینت توسعه‌دهنده
│   └── 📄 client-user.md           # راهنمای کلاینت کاربر
```

---

## 📚 Documentation Sections

### 1. 🖥️ Server Documentation
Complete guide for setting up and managing the FRP server.

| Language | Link |
|----------|------|
| English | [en/frp/server.md](en/frp/server.md) |
| فارسی | [fa/frp/server.md](fa/frp/server.md) |

**Topics covered:**
- Server installation
- Service configuration (systemd)
- Security settings
- Management commands
- Troubleshooting

---

### 2. 👨‍💻 Client Documentation (Developer)
For developers who want to integrate FRP client into their applications.

| Language | Link |
|----------|------|
| English | [en/frp/client-developer.md](en/frp/client-developer.md) |
| فارسی | [fa/frp/client-developer.md](fa/frp/client-developer.md) |

**Topics covered:**
- API usage
- Programmatic integration
- Advanced configuration
- Scripting examples
- Best practices

---

### 3. 👤 Client Documentation (User)
For regular users who want to connect to the FRP server.

| Language | Link |
|----------|------|
| English | [en/frp/client-user.md](en/frp/client-user.md) |
| فارسی | [fa/frp/client-user.md](fa/frp/client-user.md) |

**Topics covered:**
- Quick connection guide
- Basic commands
- Common use cases
- Troubleshooting

---

## 🚀 Quick Start

### Connect to Server (Client)

```bash
# Basic TCP connection
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080

# UDP connection
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080
```

> ⚠️ **Note:** The server is currently offline. Contact the administrator for access.

---

## 📜 License

This project is licensed under the **MIT License** - see [LICENSE.md](LICENSE.md) for details.

---

## 🤝 Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📞 Contact

- **Server Administrator:** Taha Tehrani Nasab
- **GitHub:** [@tahatehran](https://github.com/tahatehran)

---

<p align="center">
  <strong>🌐 Choose your language to get started:</strong>
  <br><br>
  <a href="en/frp/README.md">English</a> | 
  <a href="fa/frp/README.md">فارسی</a>
</p>

---

<p align="center">
  <sub>Built with ❤️ for the FRP community</sub>
</p>
