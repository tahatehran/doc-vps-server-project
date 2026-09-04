# مستندات کلاینت FRP (کاربر)

## 👤 راهنمای کاربر

این مستند برای **کاربران عادی** است که می‌خواهند بدون دانش برنامه‌نویسی به سرور FRP متصل شوند.

---

## 📋 فهرست مطالب

1. [FRP چیست؟](#frp-چیست)
2. [شروع سریع](#شروع-سریع)
3. [دستورات پایه](#دستورات-پایه)
4. [کاربردهای رایج](#کاربردهای-رایج)
5. [عیب‌یابی](#عیب‌یابی)

---

## 🤔 FRP چیست؟

**FRP (Fast Reverse Proxy)** ابزاری است که به شما کمک می‌کند خدمات کامپیوتر محلی خود را با دیگران در اینترنت به اشتراک بگذارید. این ابزار از پروتکل‌های **TCP و UDP** پشتیبانی می‌کند.

### مثال ساده

```
کامپیوتر محلی شما → تونل FRP → اینترنت → دیگران می‌توانند دسترسی داشته باشند
```

---

## 🚀 شروع سریع

### مرحله ۱: نصب FRP

**لینوکس/macOS:**
```bash
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"
tar -xzf /tmp/frp.tar.gz -C /tmp
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc
```

**ویندوز (PowerShell):**
```powershell
scoop install frp
```

### مرحله ۲: اتصال به سرور

```bash
# اتصال TCP
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 8080 --remote-port 8080

# اتصال UDP
frpc udp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 8081 --remote-port 8081
```

همین! پورت محلی شما اکنون از طریق سرور قابل دسترسی است.

---

## ⚡ دستورات پایه

### اتصال به سرور

```bash
# فرمت پایه
frpc <پروتکل> --proxy-name <نام> --server-addr <آدرس_سرور> --server-port <پورت_سرور> --token <توکن> --local-port <پورت_محلی> --remote-port <پورت_راه_دور>

# مثال: به اشتراک‌گذاری برنامه وب محلی روی پورت 3000
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 3000 --remote-port 3000
```

### درک دستور

| بخش | معنی | مثال |
|------|------|---------|
| `frpc` | شروع کلاینت FRP | `frpc` |
| `tcp` (زیرفرمان) | پروتکل تونل | `tcp`، `udp`، `http` و... |
| `--proxy-name` | نام یکتای پروکسی | `--proxy-name my-app` |
| `--server-addr` | آدرس سرور | `--server-addr 2.144.21.218` |
| `--server-port` | پورت سرور | `--server-port 7000` |
| `--token` | توکن احراز هویت | `--token توکن_شما` |
| `--local-port` | پورت محلی شما | `--local-port 8080` |
| `--remote-port` | پورت سرور | `--remote-port 8080` |

---

## 💼 کاربردهای رایج

### ۱. به اشتراک‌گذاری وب‌سایت محلی (TCP)

```bash
# اگر وب‌سایتی روی localhost:3000 اجرا می‌شود
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 3000 --remote-port 3000
```

### ۲. به اشتراک‌گذاری سرور بازی (UDP)

```bash
# به اشتراک‌گذاری سرور بازی محلی
frpc udp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 19132 --remote-port 19132
```

### ۳. به اشتراک‌گذاری دیتابیس (TCP)

```bash
# به اشتراک‌گذاری دیتابیس PostgreSQL محلی
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 5432 --remote-port 5432
```

### ۴. به اشتراک‌گذاری هر سرویسی

```bash
# 8080 را با هر شماره پورتی جایگزین کنید
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token توکن_شما --local-port 8080 --remote-port 8080
```

---

## 🔧 عیب‌یابی

### مشکلات رایج

| مشکل | راه‌حل |
|---------|----------|
| `Connection refused` | بررسی کنید که سرور آنلاین باشد |
| `Authentication failed` | تأیید کنید که توکن شما درست است |
| `Port already in use` | پورت محلی متفاوتی انتخاب کنید |
| `Command not found` | FRP را به درستی نصب کنید |

### دریافت کمک

اگر با مشکلاتی مواجه شدید:
1. وضعیت سرور را بررسی کنید
2. توکن خود را تأیید کنید
3. پورت دیگری امتحان کنید
4. با مدیر سرور تماس بگیرید

---

## 📞 نیاز به کمک بیشتر؟

- **مدیر سرور:** برای توکن و دسترسی به سرور تماس بگیرید
- **FRP گیت‌هاب:** https://github.com/fatedier/frp

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
