# مستندات سرور بور

## 🖥️ نمای کلی سرور

این مستند راهنمای کامل برای راه‌اندازی و مدیریت یک تونل سرور امن **Bore** است.

| جزئیات | مقدار |
|--------|-------|
| **آی پی سرور** | `2.144.21.218` |
| **پورت** | `7835` |
| **پروتکل** | TCP |
| **احراز هویت** | مبتنی بر رمز |

---

## 📋 فهرست مطالب

1. [نصب](#نصب)
2. [پیکربندی](#پیکربندی)
3. [تنظیم سرویس](#تنظیم-سرویس)
4. [دستورات مدیریتی](#دستورات-مدیریتی)
5. [امنیت](#امنیت)
6. [عیب‌یابی](#عیب‌یابی)

---

## 📦 نصب

### پیش‌نیازها

- سیستم لینوکس (Debian 10+, Ubuntu 20.04+, RHEL 8+, CentOS 8+)
- دسترسی root
- اتصال اینترنت

### روش 1: نصب خودکار (توصیه می‌شود)

```bash
# دانلود اسکریپت نصب
curl -L -o setup_bore.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/scripts/setup_bore.sh"

# قابل اجرا کردن
chmod +x setup_bore.sh

# اجرای نصب
sudo ./setup_bore.sh
```

### روش 2: نصب دستی

```bash
# دانلود باینری Bore
curl -L -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"

# استخراج
tar -xzf /tmp/bore.tar.gz -C /tmp

# نصب
sudo install -m 755 /tmp/bore /usr/local/bin/bore

# تأیید
bore --version
```

---

## ⚙️ پیکربندی

### تولید رمز امن

```bash
# تولید رمز تصادفی ۳۲ کاراکتری
openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
```

### ایجاد دایرکتوری پیکربندی

```bash
sudo mkdir -p /etc/bore
sudo chmod 700 /etc/bore
```

### ذخیره رمز (اختیاری)

```bash
# ذخیره رمز در فایل (برای سرویس systemd)
echo "رمز_تولید_شده" | sudo tee /etc/bore/secret
sudo chmod 600 /etc/bore/secret
```

---

## 🔧 تنظیم سرویس

### ایجاد سرویس Systemd

```bash
sudo tee /etc/systemd/system/bore-server.service <<EOF
[Unit]
Description=Bore Secure Tunnel Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/bore server --secret "رمز_شما_اینجا"
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# سخت‌سازی امنیتی
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/log/bore/

[Install]
WantedBy=multi-user.target
EOF
```

### فعال‌سازی و شروع سرویس

```bash
# بارگذاری مجدد systemd
sudo systemctl daemon-reload

# فعال‌سازی سرویس (شروع با بوت)
sudo systemctl enable bore-server

# شروع سرویس
sudo systemctl start bore-server

# بررسی وضعیت
sudo systemctl status bore-server
```

---

## ⚡ دستورات مدیریتی

### کنترل سرویس

| دستور | توضیحات |
|---------|-------------|
| `sudo systemctl start bore-server` | شروع سرور |
| `sudo systemctl stop bore-server` | توقف سرور |
| `sudo systemctl restart bore-server` | راه‌اندازی مجدد |
| `sudo systemctl status bore-server` | بررسی وضعیت |
| `sudo systemctl enable bore-server` | فعال‌سازی شروع خودکار |
| `sudo systemctl disable bore-server` | غیرفعال‌سازی شروع خودکار |

### مشاهده لاگ‌ها

```bash
# لاگ‌های زنده
sudo journalctl -u bore-server -f

# ۵۰ خط آخر
sudo journalctl -u bore-server -n 50

# لاگ‌ها از آخرین بوت
sudo journalctl -u bore-server -b
```

### بررسی وضعیت سرور

```bash
# آیا سرویس فعال است?
sudo systemctl is-active bore-server

# آیا سرویس فعال شده?
sudo systemctl is-enabled bore-server

# دریافت PID سرویس
sudo systemctl show bore-server --property=MainPID
```

---

## 🛡️ امنیت

### پیکربندی فایروال

```bash
# اجازه دادن به پورت Bore (پیش‌فرض: 7835)
sudo ufw allow 7835/tcp

# فعال‌سازی فایروال
sudo ufw enable

# بررسی وضعیت
sudo ufw status
```

### بهترین روش‌های امنیتی

1. **از رمز قوی استفاده کنید** (۳۲+ کاراکتر)
2. **رمز را خصوصی نگه دارید** - هرگز به صورت عمومی اشتراک نگذارید
3. **از قوانین فایروال** برای محدود کردن دسترسی استفاده کنید
4. **لاگ‌ها را به طور منظم نظارت کنید**
5. **Bore را به آخرین نسخه به‌روزرسانی کنید**

### تغییر رمز

```bash
# توقف سرویس
sudo systemctl stop bore-server

# به‌روزرسانی رمز در فایل سرویس
sudo sed -i 's/secret ".*"/secret "رمز_جدید"/' /etc/systemd/system/bore-server.service

# بارگذاری مجدد و شروع
sudo systemctl daemon-reload
sudo systemctl start bore-server
```

---

## 🔧 عیب‌یابی

### سرویس شروع نمی‌شود

```bash
# بررسی لاگ‌های خطا
sudo journalctl -u bore-server --no-pager

# بررسی پیکربندی سرویس
sudo systemctl cat bore-server

# آزمایش دستی دستور
/usr/local/bin/bore server --secret "رمز_شما"
```

### مشکلات اتصال

```bash
# بررسی اینکه آیا پورت در حال گوش دادن است
sudo netstat -tlnp | grep 7835

# بررسی فایروال
sudo ufw status

# آزمایش اتصال از راه دور
nc -zv 2.144.21.218 7835
```

### مشکلات عملکرد

```bash
# بررسی استفاده از منابع
sudo systemctl status bore-server

# مشاهده استفاده از حافظه
ps aux | grep bore

# بررسی اتصالات باز
ss -tlnp | grep 7835
```

---

## 📊 اطلاعات سرور

### پیکربندی پیش‌فرض

| تنظیم | مقدار |
|---------|-------|
| **پورت گوش دادن** | 7835 |
| **پروتکل** | TCP |
| **احراز هویت** | مبتنی بر رمز |
| **راه‌اندازی مجدد خودکار** | بله (تأخیر ۱۰ ثانیه) |
| **لاگ‌گیری** | journald |

### مکان لاگ‌ها

| نوع لاگ | مکان |
|----------|----------|
| لاگ‌های سرویس | `journalctl -u bore-server` |
| لاگ‌های سیستم | `/var/log/syslog` یا `/var/log/messages` |

---

## 📞 پشتیبانی

برای مشکلات یا سؤالات:
- **مشکلات گیت‌هاب:** https://github.com/tahatehran/doc-vps-server-project/issues
- **مخزن Bore:** https://github.com/ekzhang/bore

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
