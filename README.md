# 🌐 VPS Server Documentation

> **🌐 Language:** [English](#english) | [فارسی](#فارسی)

---

## English

## 📋 Overview

This repository contains comprehensive documentation for managing secure tunnel servers. Currently includes:

| Feature | Bore | FRP |
|---------|------|-----|
| **Protocol** | TCP only | TCP + UDP + HTTP/HTTPS |
| **Language** | Rust | Go |
| **Use Case** | Simple tunneling | Production reverse proxy |
| **Status** | 🔴 Disabled | 🟢 Active |

**🔐 Secure. ⚡ Fast. 🔧 Flexible.**

---

## 🖥️ Server Information

```
╔══════════════════════════════════════════════════════════════╗
║                    🌐 SERVER DETAILS                         ║
╠══════════════════════════════════════════════════════════════╣
║  🖥️  Hostname    : nima-server                              ║
║  📍 IP Address   : 2.144.21.218                              ║
║  💾 OS           : Debian/Ubuntu Linux                       ║
╠══════════════════════════════════════════════════════════════╣
║  ⚡ FRP Server   : v0.71.0 (Active ✅)                       ║
║  🚪 FRP Port     : 7000 (Main)                               ║
║  📊 Dashboard    : 7500 (Server Panel)                       ║
║  🖥️  Client UI   : 7400 (Client Admin)                       ║
║  📈 Status Page  : 8090 (Public Status)                      ║
║  🔑 Token Auth   : Enabled                                   ║
╠══════════════════════════════════════════════════════════════╣
║  🌐 HTTP Proxy   : 80 (vhost)                                ║
║  🔒 HTTPS Proxy  : 443 (vhost)                               ║
║  📁 Tunnel Range : 8000-9000                                 ║
╚══════════════════════════════════════════════════════════════╝
```

### 🟢 Active Services

| Service | Port | Protocol | Status |
|---------|------|----------|--------|
| **FRP Server** | 7000 | TCP | 🟢 Active |
| **Server Dashboard** | 7500 | HTTP | 🟢 Active |
| **Client Admin UI** | 7400 | HTTP | 🟢 Active |
| **Status Page** | 8090 | HTTP | 🟢 Active |
| **SSH Demo** | 8022 | TCP | 🟢 Active |

---

## 📁 Repository Structure

```
doc-vps-server-project/
├── 📄 README.md                    # This file - Main overview
├── 📄 CONTRIBUTING.md              # Contribution guidelines
├── 📄 LICENSE.md                   # MIT License
│
├── 📁 bore/                        # Bore Documentation
│   ├── 📁 en/                      # English
│   │   ├── 📄 README.md
│   │   ├── 📄 server.md
│   │   ├── 📄 client-developer.md
│   │   └── 📄 client-user.md
│   └── 📁 fa/                      # Persian
│       ├── 📄 README.md
│       ├── 📄 server.md
│       ├── 📄 client-developer.md
│       └── 📄 client-user.md
│
├── 📁 frp/                         # FRP Documentation
│   ├── 📁 en/                      # English
│   │   ├── 📄 README.md
│   │   ├── 📄 server.md
│   │   ├── 📄 client-developer.md
│   │   └── 📄 client-user.md
│   └── 📁 fa/                      # Persian
│       ├── 📄 README.md
│       ├── 📄 server.md
│       ├── 📄 client-developer.md
│       └── 📄 client-user.md
│
├── 📁 examples/                    # Code examples
└── 📁 scripts/                     # Utility scripts
```

---

## 📚 Bore Documentation (TCP Only)

### 1. 🖥️ Server Documentation

| Language | Link |
|----------|------|
| English | [bore/en/server.md](bore/en/server.md) |
| فارسی | [bore/fa/server.md](bore/fa/server.md) |

### 2. 👨‍💻 Client (Developer)

| Language | Link |
|----------|------|
| English | [bore/en/client-developer.md](bore/en/client-developer.md) |
| فارسی | [bore/fa/client-developer.md](bore/fa/client-developer.md) |

### 3. 👤 Client (User)

| Language | Link |
|----------|------|
| English | [bore/en/client-user.md](bore/en/client-user.md) |
| فارسی | [bore/fa/client-user.md](bore/fa/client-user.md) |

---

## 📚 FRP Documentation (TCP + UDP)

### 1. 🖥️ Server Documentation

| Language | Link |
|----------|------|
| English | [frp/en/server.md](frp/en/server.md) |
| فارسی | [frp/fa/server.md](frp/fa/server.md) |

### 2. 👨‍💻 Client (Developer)

| Language | Link |
|----------|------|
| English | [frp/en/client-developer.md](frp/en/client-developer.md) |
| فارسی | [frp/fa/client-developer.md](frp/fa/client-developer.md) |

### 3. 👤 Client (User)

| Language | Link |
|----------|------|
| English | [frp/en/client-user.md](frp/en/client-user.md) |
| فارسی | [frp/fa/client-user.md](frp/fa/client-user.md) |

---

## 🚀 Quick Start

### Bore (TCP Only)

```bash
bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### FRP (TCP + UDP)

```bash
# Download FRPC
curl -L -o frpc.tar.gz "https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz"
tar -xzf frpc.tar.gz

# Configure
cat > frpc.toml <<EOF
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "YOUR_TOKEN"

[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080
EOF

# Run
./frpc -c frpc.toml
```

> ✅ **Server is online and ready to use!**

---

## 📥 Quick Install (FRP Client)

### Windows — Offline Installer (Recommended)
1. Go to [Releases](https://github.com/tahatehran/doc-vps-server-project/releases/latest) → Download `frp-client-installer-full.zip`
2. Extract → Open **PowerShell as Administrator** → Run `.\install-frp.exe`
3. Select **1) Install FRP Client** → then **4) Connect to Server** → enter your token & ports

> Bundled `frpc.exe` included — no internet needed on target machine.

### Windows — Online Script
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/windows/install-frp.ps1" -OutFile "install-frp.ps1"
.\install-frp.ps1
```

### Linux
```bash
curl -fsSL -o install-frp.sh https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/linux/install-frp.sh
chmod +x install-frp.sh
sudo ./install-frp.sh
```

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

---

## فارسی

## 📋 نمای کلی

این مخزن مستندات جامع برای مدیریت سرورهای تونل امن را شامل می‌شود. در حال حاضر شامل:

| ویژگی | Bore | FRP |
|--------|------|-----|
| **پروتکل** | فقط TCP | TCP + UDP + HTTP/HTTPS |
| **زبان** | Rust | Go |
| **کاربرد** | تونل ساده | پروکسی معکوس حرفه‌ای |
| **وضعیت** | 🔴 غیرفعال | 🟢 فعال |

**🔐 امن. ⚡ سریع. 🔧 انعطاف‌پذیر.**

---

## 🖥️ اطلاعات سرور

```
╔══════════════════════════════════════════════════════════════╗
║                    🌐 مشخصات سرور                            ║
╠══════════════════════════════════════════════════════════════╣
║  🖥️  Hostname    : nima-server                              ║
║  📍 آی‌پی سرور   : 2.144.21.218                              ║
║  💾 سیستم‌عامل   : Debian/Ubuntu Linux                       ║
╠══════════════════════════════════════════════════════════════╣
║  ⚡ FRP Server   : v0.71.0 (فعال ✅)                         ║
║  🚪 پورت FRP     : 7000 (اصلی)                               ║
║  📊 داشبورد      : 7500 (پنل سرور)                           ║
║  🖥️  Client UI   : 7400 (مدیریت کلاینت)                      ║
║  📈 صفحه وضعیت  : 8090 (وضعیت عمومی)                         ║
║  🔑 احراز هویت   : Token                                     ║
╠══════════════════════════════════════════════════════════════╣
║  🌐 پروکسی HTTP  : 80 (vhost)                                ║
║  🔒 پروکسی HTTPS : 443 (vhost)                               ║
║  📁 محدوده تونل  : 8000-9000                                 ║
╚══════════════════════════════════════════════════════════════╝
```

### 🟢 سرویس‌های فعال

| سرویس | پورت | پروتکل | وضعیت |
|--------|------|--------|--------|
| **سرور FRP** | 7000 | TCP | 🟢 فعال |
| **داشبورد سرور** | 7500 | HTTP | 🟢 فعال |
| **رابط کاربری کلاینت** | 7400 | HTTP | 🟢 فعال |
| **صفحه وضعیت** | 8090 | HTTP | 🟢 فعال |
| **دمو SSH** | 8022 | TCP | 🟢 فعال |

---

## 📁 ساختار مخزن

```
doc-vps-server-project/
├── 📄 README.md                    # این فایل - نمای کلی
├── 📄 CONTRIBUTING.md              # راهنمای مشارکت
├── 📄 LICENSE.md                   # لایسنس MIT
│
├── 📁 bore/                        # مستندات Bore
│   ├── 📁 en/                      # انگلیسی
│   │   ├── 📄 README.md
│   │   ├── 📄 server.md
│   │   ├── 📄 client-developer.md
│   │   └── 📄 client-user.md
│   └── 📁 fa/                      # فارسی
│       ├── 📄 README.md
│       ├── 📄 server.md
│       ├── 📄 client-developer.md
│       └── 📄 client-user.md
│
├── 📁 frp/                         # مستندات FRP
│   ├── 📁 en/                      # انگلیسی
│   │   ├── 📄 README.md
│   │   ├── 📄 server.md
│   │   ├── 📄 client-developer.md
│   │   └── 📄 client-user.md
│   └── 📁 fa/                      # فارسی
│       ├── 📄 README.md
│       ├── 📄 server.md
│       ├── 📄 client-developer.md
│       └── 📄 client-user.md
│
├── 📁 examples/                    # نمونه کدها
└── 📁 scripts/                     # اسکریپت‌های کمکی
```

---

## 📚 مستندات Bore (فقط TCP)

### ۱. 🖥️ مستندات سرور

| زبان | لینک |
|------|------|
| English | [bore/en/server.md](bore/en/server.md) |
| فارسی | [bore/fa/server.md](bore/fa/server.md) |

### ۲. 👨‍💻 کلاینت (توسعه‌دهنده)

| زبان | لینک |
|------|------|
| English | [bore/en/client-developer.md](bore/en/client-developer.md) |
| فارسی | [bore/fa/client-developer.md](bore/fa/client-developer.md) |

### ۳. 👤 کلاینت (کاربر)

| زبان | لینک |
|------|------|
| English | [bore/en/client-user.md](bore/en/client-user.md) |
| فارسی | [bore/fa/client-user.md](bore/fa/client-user.md) |

---

## 📚 مستندات FRP (TCP + UDP)

### ۱. 🖥️ مستندات سرور

| زبان | لینک |
|------|------|
| English | [frp/en/server.md](frp/en/server.md) |
| فارسی | [frp/fa/server.md](frp/fa/server.md) |

### ۲. 👨‍💻 کلاینت (توسعه‌دهنده)

| زبان | لینک |
|------|------|
| English | [frp/en/client-developer.md](frp/en/client-developer.md) |
| فارسی | [frp/fa/client-developer.md](frp/fa/client-developer.md) |

### ۳. 👤 کلاینت (کاربر)

| زبان | لینک |
|------|------|
| English | [frp/en/client-user.md](frp/en/client-user.md) |
| فارسی | [frp/fa/client-user.md](frp/fa/client-user.md) |

---

## 🚀 شروع سریع

### Bore (فقط TCP)

```bash
bore local 8080 --to 2.144.21.218:7835 --secret "رمز_شما"
```

### FRP (TCP + UDP)

```bash
# دانلود FRPC
curl -L -o frpc.tar.gz "https://github.com/fatedier/frp/releases/download/v0.71.0/frp_0.71.0_linux_amd64.tar.gz"
tar -xzf frpc.tar.gz

# تنظیم کانفیگ
cat > frpc.toml <<EOF
serverAddr = "2.144.21.218"
serverPort = 7000
auth.method = "token"
auth.token = "توکن_شما"

[[proxies]]
name = "my-app"
type = "tcp"
localIP = "127.0.0.1"
localPort = 8080
remotePort = 8080
EOF

# اجرا
./frpc -c frpc.toml
```

> ✅ **سرور آنلاین و آماده استفاده است!**

---

## 📥 نصب سریع (FRP Client)

### ویندوز — نصب‌کننده آفلاین (پیشنهاد شده)
1. به [Releases](https://github.com/tahatehran/doc-vps-server-project/releases/latest) بروید → `frp-client-installer-full.zip` را دانلود کنید
2. استخراج کنید → **PowerShell را به عنوان Administrator باز کنید** → `.\install-frp.exe` را اجرا کنید
3. گزینه **1) Install FRP Client** و بعد **4) Connect to Server** → توکن و پورت‌ها را وارد کنید

> `frpc.exe` در کنار نصب‌کننده است — در ماشین مقصد اینترنت لازم نیست.

### ویندوز — اسکریپت آنلاین
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/windows/install-frp.ps1" -OutFile "install-frp.ps1"
.\install-frp.ps1
```

### لینوکس
```bash
curl -fsSL -o install-frp.sh https://raw.githubusercontent.com/tahatehran/doc-vps-server-project/main/installer/linux/install-frp.sh
chmod +x install-frp.sh
sudo ./install-frp.sh
```

---

## 📜 لایسنس

این پروژه تحت **لایسنس MIT** منتشر شده است - برای جزئیات به [LICENSE.md](LICENSE.md) مراجعه کنید.

---

## 🤝 مشارکت

ما از مشارکت‌ها استقبال می‌کنیم! لطفاً [CONTRIBUTING.md](CONTRIBUTING.md) را برای راهنما بخوانید.

---

## 📞 تماس

- **مدیر سرور:** Taha Tehrani Nasab
- **گیت‌هاب:** [@tahatehran](https://github.com/tahatehran)

---

<p align="center">
  <sub>ساخته شده با ❤️ برای جامعه سرورهای امن</sub>
</p>
