# VPS Server Documentation

> **🌐 Language:** [English](#english) | [فارسی](#فارسی)

---

## English

## 📋 Overview

This repository contains comprehensive documentation for secure tunnel servers. Currently includes:

1. **Bore** - Simple TCP tunnel (Rust)
2. **FRP** - Fast Reverse Proxy with TCP + UDP support (Go)

**🔐 Secure. ⚡ Fast. 🔧 Flexible.**

---

## 🖥️ Server Information

| Detail | Value |
|--------|-------|
| **Server IP** | `2.144.21.218` |
| **Bore Port** | `7835` (TCP only) |
| **FRP Port** | `7000` (TCP + UDP) |
| **Tunnel Port Range** | `8000-9000` |
| **Status** | 🔴 Offline (currently disabled) |

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
# TCP
frpc -s 2.144.21.218:7000 -t YOUR_TOKEN -P tcp --local-port 8080 --remote-port 8080

# UDP
frpc -s 2.144.21.218:7000 -t YOUR_TOKEN -P udp --local-port 8081 --remote-port 8081
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

---

## فارسی

## 📋 نمای کلی

این مخزن مستندات جامع برای سرورهای تونل امن را شامل می‌شود. در حال حاضر شامل:

1. **Bore** - تونل TCP ساده (Rust)
2. **FRP** - پروکسی معکوس سریع با پشتیبانی TCP + UDP (Go)

**🔐 امن. ⚡ سریع. 🔧 انعطاف‌پذیر.**

---

## 🖥️ اطلاعات سرور

| جزئیات | مقدار |
|--------|-------|
| **آی پی سرور** | `2.144.21.218` |
| **پورت Bore** | `7835` (فقط TCP) |
| **پورت FRP** | `7000` (TCP + UDP) |
| **محدوده پورت تونل** | `8000-9000` |
| **وضعیت** | 🔴 آفلاین (در حال حاضر غیرفعال) |

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
|----------|------|
| English | [bore/en/server.md](bore/en/server.md) |
| فارسی | [bore/fa/server.md](bore/fa/server.md) |

### ۲. 👨‍💻 کلاینت (توسعه‌دهنده)
| زبان | لینک |
|----------|------|
| English | [bore/en/client-developer.md](bore/en/client-developer.md) |
| فارسی | [bore/fa/client-developer.md](bore/fa/client-developer.md) |

### ۳. 👤 کلاینت (کاربر)
| زبان | لینک |
|----------|------|
| English | [bore/en/client-user.md](bore/en/client-user.md) |
| فارسی | [bore/fa/client-user.md](bore/fa/client-user.md) |

---

## 📚 مستندات FRP (TCP + UDP)

### ۱. 🖥️ مستندات سرور
| زبان | لینک |
|----------|------|
| English | [frp/en/server.md](frp/en/server.md) |
| فارسی | [frp/fa/server.md](frp/fa/server.md) |

### ۲. 👨‍💻 کلاینت (توسعه‌دهنده)
| زبان | لینک |
|----------|------|
| English | [frp/en/client-developer.md](frp/en/client-developer.md) |
| فارسی | [frp/fa/client-developer.md](frp/fa/client-developer.md) |

### ۳. 👤 کلاینت (کاربر)
| زبان | لینک |
|----------|------|
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
# TCP
frpc -s 2.144.21.218:7000 -t توکن_شما -P tcp --local-port 8080 --remote-port 8080

# UDP
frpc -s 2.144.21.218:7000 -t توکن_شما -P udp --local-port 8081 --remote-port 8081
```

> ⚠️ **توجه:** سرور در حال حاضر آفلاین است. برای دسترسی با مدیر سرور تماس بگیرید.

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
