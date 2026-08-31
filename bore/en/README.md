# Bore Secure Server Documentation

> **🌐 Language:** [English](en/README.md) | [فارسی](fa/README.md)

---

## 📋 Overview

This repository contains comprehensive documentation for **Bore**, a modern, simple TCP tunnel written in Rust that exposes local ports to a remote server, bypassing standard NAT connection firewalls.

**🔐 Secure. ⚡ Fast. 🔧 Flexible.**

---

## 🖥️ Server Information

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Port** | `7835` |
| **Protocol** | TCP |
| **Authentication** | Secret-based |
| **Status** | 🔴 Offline (currently disabled) |

---

## 📁 Repository Structure

```
doc-vps-server-project/
├── 📄 README.md                    # This file - Main overview
├── 📄 CONTRIBUTING.md              # Contribution guidelines
├── 📄 LICENSE.md                   # MIT License
│
├── 📁 en/                          # English Documentation
│   ├── 📄 README.md                # English overview
│   ├── 📄 server.md                # Server setup & commands
│   ├── 📄 client-developer.md      # Client guide for developers
│   └── 📄 client-user.md           # Client guide for regular users
│
├── 📁 fa/                          # Persian Documentation (فارسی)
│   ├── 📄 README.md                # نمای کلی فارسی
│   ├── 📄 server.md                # راهنمای سرور
│   ├── 📄 client-developer.md      # راهنمای کلاینت برای توسعه‌دهندگان
│   └── 📄 client-user.md           # راهنمای کلاینت برای کاربران عادی
│
├── 📁 examples/                    # Code examples
└── 📁 scripts/                     # Utility scripts
```

---

## 📚 Documentation Sections

### 1. 🖥️ Server Documentation
Complete guide for setting up and managing the Bore server.

| Language | Link |
|----------|------|
| English | [en/server.md](en/server.md) |
| فارسی | [fa/server.md](fa/server.md) |

**Topics covered:**
- Server installation
- Service configuration (systemd)
- Security settings
- Management commands
- Troubleshooting

---

### 2. 👨‍💻 Client Documentation (Developer)
For developers who want to integrate Bore client into their applications.

| Language | Link |
|----------|------|
| English | [en/client-developer.md](en/client-developer.md) |
| فارسی | [fa/client-developer.md](fa/client-developer.md) |

**Topics covered:**
- API usage
- Programmatic integration
- Advanced configuration
- Scripting examples
- Best practices

---

### 3. 👤 Client Documentation (User)
For regular users who want to connect to the Bore server.

| Language | Link |
|----------|------|
| English | [en/client-user.md](en/client-user.md) |
| فارسی | [fa/client-user.md](fa/client-user.md) |

**Topics covered:**
- Quick connection guide
- Basic commands
- Common use cases
- Troubleshooting

---

## 🚀 Quick Start

### Connect to Server (Client)

```bash
# Basic connection
bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"

# Example: Forward local port 3000 to remote
bore local 3000 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
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
  <a href="en/README.md">English</a> | 
  <a href="fa/README.md">فارسی</a>
</p>

---

<p align="center">
  <sub>Built with ❤️ for the Bore community</sub>
</p>
