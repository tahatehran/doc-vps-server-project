# مستندات سرور FRP

## 🖥️ نمای کلی سرور

این مستند راهنمای کامل برای راه‌اندازی و مدیریت یک تونل سرور امن **FRP** است.

| جزئیات | مقدار |
|--------|-------|
| **آی پی سرور** | `2.144.21.218` |
| **پروتکل** | TCP + UDP |
| **احراز هویت** | مبتنی بر توکن |
| **محدوده پورت** | `8000-9000` (قابل پیکربندی) |

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
curl -L -o setup_frp.sh "https://github.com/tahatehran/doc-vps-server-project/raw/main/scripts/setup_frp.sh"

# قابل اجرا کردن
chmod +x setup_frp.sh

# اجرای نصب
sudo ./setup_frp.sh
```

### روش 2: نصب دستی

```bash
# دانلود آخرین نسخه
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"

# استخراج
tar -xzf /tmp/frp.tar.gz -C /tmp

# نصب
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frps /usr/local/bin/frps
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc

# تأیید
frps --version
frpc --version
```

---

## ⚙️ پیکربندی

### تولید توکن امن

```bash
# تولید توکن تصادفی ۳۲ کاراکتری
openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
```

### ایجاد دایرکتوری پیکربندی

```bash
sudo mkdir -p /etc/frp
sudo chmod 700 /etc/frp
```

### پیکربندی سرور (frps.ini)

```bash
sudo tee /etc/frp/frps.ini <<EOF
[common]
bind_port = 7000
token = YOUR_GENERATED_TOKEN
vhost_http_port = 80
vhost_https_port = 443
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = YOUR_DASHBOARD_PASSWORD
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

### پیکربندی کلاینت (frpc.ini)

```bash
sudo tee /etc/frp/frpc.ini <<EOF
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_GENERATED_TOKEN
log_file = /var/log/frp/frpc.log
log_level = info
log_max_days = 3

[web_app_tcp]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8080
use_encryption = true
use_compression = true

[web_app_udp]
type = udp
local_ip = 127.0.0.1
local_port = 8081
remote_port = 8081
use_encryption = true
use_compression = true
EOF
```

---

## 🔧 تنظیم سرویس

### ایجاد سرویس Systemd

```bash
sudo tee /etc/systemd/system/frp-server.service <<EOF
[Unit]
Description=FRP Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.ini
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/frp-client.service <<EOF
[Unit]
Description=FRP Client
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
```

### فعال‌سازی و شروع سرویس

```bash
# بارگذاری مجدد systemd
sudo systemctl daemon-reload

# فعال‌سازی سرویس‌ها
sudo systemctl enable frp-server
sudo systemctl enable frp-client

# شروع سرویس‌ها
sudo systemctl start frp-server
sudo systemctl start frp-client

# بررسی وضعیت
sudo systemctl status frp-server
sudo systemctl status frp-client
```

---

## ⚡ دستورات مدیریتی

### کنترل سرویس

| دستور | توضیحات |
|---------|-------------|
| `sudo systemctl start frp-server` | شروع سرور FRP |
| `sudo systemctl stop frp-server` | توقف سرور FRP |
| `sudo systemctl restart frp-server` | راه‌اندازی مجدد |
| `sudo systemctl status frp-server` | بررسی وضعیت |
| `sudo systemctl enable frp-server` | فعال‌سازی شروع خودکار |
| `sudo systemctl disable frp-server` | غیرفعال‌سازی شروع خودکار |

### مشاهده لاگ‌ها

```bash
# لاگ‌های زنده سرور
sudo journalctl -u frp-server -f

# لاگ‌های زنده کلاینت
sudo journalctl -u frp-client -f

# ۵۰ خط آخر
sudo journalctl -u frp-server -n 50

# لاگ‌ها از آخرین بوت
sudo journalctl -u frp-server -b
```

### بررسی وضعیت سرور

```bash
# آیا سرویس فعال است?
sudo systemctl is-active frp-server

# آیا سرویس فعال شده?
sudo systemctl is-enabled frp-server

# دریافت PID سرویس
sudo systemctl show frp-server --property=MainPID

# مشاهده داشبورد
curl http://localhost:7500
```

---

## 🛡️ امنیت

### پیکربندی فایروال

```bash
# اجازه دادن به پورت سرور FRP (پیش‌فرض: 7000)
sudo ufw allow 7000/tcp

# اجازه دادن به پورت‌های تونل (8000-9000)
sudo ufw allow 8000:9000/tcp
sudo ufw allow 8000:9000/udp

# فعال‌سازی فایروال
sudo ufw enable

# بررسی وضعیت
sudo ufw status
```

### بهترین روش‌های امنیتی

1. **از توکن قوی استفاده کنید** (۳۲+ کاراکتر)
2. **توکن را خصوصی نگه دارید** - هرگز به صورت عمومی اشتراک نگذارید
3. **از قوانین فایروال** برای محدود کردن دسترسی استفاده کنید
4. **لاگ‌ها را به طور منظم نظارت کنید**
5. **FRP را به آخرین نسخه به‌روزرسانی کنید**
6. **رمزنگاری را برای تمام تونل‌ها فعال کنید**
7. **از داشبورد** برای نظارت استفاده کنید

### تغییر توکن

```bash
# توقف سرویس‌ها
sudo systemctl stop frp-server
sudo systemctl stop frp-client

# به‌روزرسانی توکن در هر دو فایل پیکربندی
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frps.ini
sudo sed -i 's/token = .*/token = NEW_TOKEN/' /etc/frp/frpc.ini

# بارگذاری مجدد و شروع
sudo systemctl daemon-reload
sudo systemctl start frp-server
sudo systemctl start frp-client
```

---

## 🔧 عیب‌یابی

### سرویس شروع نمی‌شود

```bash
# بررسی لاگ‌های خطا
sudo journalctl -u frp-server --no-pager

# بررسی پیکربندی سرویس
sudo systemctl cat frp-server

# آزمایش دستی دستور
/usr/local/bin/frps -c /etc/frp/frps.ini
```

### مشکلات اتصال

```bash
# بررسی اینکه آیا پورت در حال گوش دادن است
sudo netstat -tlnp | grep 7000

# بررسی فایروال
sudo ufw status

# آزمایش اتصال از راه دور
nc -zv 2.144.21.218 7000
```

### مشکلات عملکرد

```bash
# بررسی استفاده از منابع
sudo systemctl status frp-server

# مشاهده استفاده از حافظه
ps aux | grep frp

# بررسی اتصالات باز
ss -tlnp | grep frp
```

### خطاهای رایج

| خطا | علت | راه‌حل |
|-----|-------|----------|
| `Connection refused` | سرور آفلاین یا پورت اشتباه | وضعیت سرور و پورت را بررسی کنید |
| `Authentication failed` | توکن اشتباه | توکن را با سرور مطابقت دهید |
| `Address already in use` | پورت در حال استفاده | پورت محلی متفاوت انتخاب کنید |
| `Timeout` | مشکلات شبکه | فایروال و اتصال را بررسی کنید |

---

## 📊 اطلاعات سرور

### پیکربندی پیش‌فرض

| تنظیم | مقدار |
|---------|-------|
| **پورت سرور** | 7000 |
| **پورت داشبورد** | 7500 |
| **محدوده پورت تونل** | 8000-9000 |
| **پروتکل** | TCP + UDP |
| **احراز هویت** | مبتنی بر توکن |
| **راه‌اندازی مجدد خودکار** | بله (تأخیر ۱۰ ثانیه) |
| **لاگ‌گیری** | journald |

### مکان لاگ‌ها

| نوع لاگ | مکان |
|----------|----------|
| لاگ‌های سرور | `journalctl -u frp-server` |
| لاگ‌های کلاینت | `journalctl -u frp-client` |
| فایل‌های پیکربندی | `/etc/frp/` |
| لاگ‌های سیستم | `/var/log/syslog` یا `/var/log/messages` |

---

## 📞 پشتیبانی

برای مشکلات یا سؤالات:
- **مشکلات گیت‌هاب:** https://github.com/tahatehran/doc-vps-server-project/issues
- **مخزن FRP:** https://github.com/fatedier/frp

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
