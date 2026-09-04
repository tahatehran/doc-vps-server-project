# راهنمای پیکربندی چنداپلیکیشن FRP

## 📋 پیکربندی ۵ اپ با پورت‌های مختلف (TCP + UDP)

این راهنما نحوه پیکربندی **۵ اپلیکیشن مختلف** با **پورت‌های مختلف** روی یک سرور FRP را نشان می‌دهد، از جمله پشتیبانی **TCP و UDP**.

---

## 🖥️ پیکربندی سرور (یک سرور)

### فایل پیکربندی سرور

```bash
sudo tee /etc/frp/frps.ini <<EOF
[common]
bind_port = 7000
token = YOUR_GENERATED_TOKEN
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

### قوانین فایروال (هر ۵ اپ)

```bash
# اجازه پورت سرور FRP
sudo ufw allow 7000/tcp

# اجازه پورت‌های تونل (8000-9000) برای TCP و UDP
sudo ufw allow 8000:9000/tcp
sudo ufw allow 8000:9000/udp

# تأیید
sudo ufw status
```

---

## 📱 پیکربندی کلاینت (۵ اپ)

### جدول پیکربندی اپ‌ها

| اپ | سرویس | پورت محلی | پورت راه دور | پروتکل | هدف |
|-----|---------|------------|-------------|----------|---------|
| **اپ ۱** | وب سرور | 3000 | 8000 | TCP | React/Vue frontend |
| **اپ ۲** | API سرور | 8080 | 8001 | TCP | REST API backend |
| **اپ ۳** | دیتابیس | 5432 | 8002 | TCP | PostgreSQL |
| **اپ ۴** | سرور بازی | 19132 | 8003 | UDP | Minecraft/minecraft-like |
| **اپ ۵** | پنل مدیریت | 9000 | 8004 | TCP | داشبورد مدیریت |

---

### روش ۱: دستورات جداگانه (شروع سریع)

```bash
# اپ ۱: وب سرور (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 3000 --remote-port 8000

# اپ ۲: API سرور (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8001

# اپ ۳: دیتابیس (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 5432 --remote-port 8002

# اپ ۴: سرور بازی (UDP)
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 19132 --remote-port 8003

# اپ ۵: پنل مدیریت (TCP)
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 9000 --remote-port 8004
```

---

### روش ۲: فایل پیکربندی (توصیه می‌شود)

```bash
sudo tee /etc/frp/frpc.ini <<EOF
[common]
server_addr = 2.144.21.218
server_port = 7000
token = YOUR_GENERATED_TOKEN
log_file = /var/log/frp/frpc.log
log_level = info
log_max_days = 3

# اپ ۱: وب سرور (TCP)
[web_app]
type = tcp
local_ip = 127.0.0.1
local_port = 3000
remote_port = 8000
use_encryption = true
use_compression = true

# اپ ۲: API سرور (TCP)
[api_app]
type = tcp
local_ip = 127.0.0.1
local_port = 8080
remote_port = 8001
use_encryption = true
use_compression = true

# اپ ۳: دیتابیس (TCP)
[database]
type = tcp
local_ip = 127.0.0.1
local_port = 5432
remote_port = 8002
use_encryption = true
use_compression = true

# اپ ۴: سرور بازی (UDP)
[game_server]
type = udp
local_ip = 127.0.0.1
local_port = 19132
remote_port = 8003
use_encryption = true
use_compression = true

# اپ ۵: پنل مدیریت (TCP)
[admin_panel]
type = tcp
local_ip = 127.0.0.1
local_port = 9000
remote_port = 8004
use_encryption = true
use_compression = true
EOF
```

---

### روش ۳: اسکریپت چندتونلی

```bash
#!/bin/bash
# frp-multi-app.sh - شروع تمام ۵ تونل اپ

SERVER="2.144.21.218:7000"
TOKEN="YOUR_TOKEN"

# پیکربندی اپ‌ها: پورت_محلی:پورت_راه_دور:پروتکل:توضیحات
APPS=(
    "3000:8000:tcp:وب سرور"
    "8080:8001:tcp:API سرور"
    "5432:8002:tcp:PostgreSQL"
    "19132:8003:udp:سرور بازی"
    "9000:8004:tcp:پنل مدیریت"
)

start_all() {
    echo "شروع تمام ۵ تونل FRP..."
    for app in "${APPS[@]}"; do
        IFS=':' read -r local_port remote_port protocol name <<< "$app"
        echo "  → $name (محلی:$local_port → $SERVER:$remote_port, $protocol)"
        frpc $protocol --server-addr "$SERVER_ADDR" --server-port "$SERVER_PORT" --token "$TOKEN" --local-port $local_port --remote-port $remote_port &
    done
    echo "تمام ۵ تونل شروع شدند!"
}

stop_all() {
    echo "توقف تمام تونل‌های FRP..."
    pkill -f "frpc"
    echo "تمام تونل‌ها متوقف شدند."
}

status() {
    echo "تونل‌های فعال FRP:"
    ps aux | grep "frpc" | grep -v grep
}

case "$1" in
    start) start_all ;;
    stop) stop_all ;;
    status) status ;;
    *) echo "استفاده: $0 {start|stop|status}" ;;
esac
```

```bash
# قابل اجرا کردن
chmod +x frp-multi-app.sh

# شروع تمام تونل‌ها
./frp-multi-app.sh start

# بررسی وضعیت
./frp-multi-app.sh status

# توقف همه
./frp-multi-app.sh stop
```

---

### روش ۴: سرویس Systemd (تولید)

```bash
sudo tee /etc/systemd/system/frp-client.service <<EOF
[Unit]
Description=کلاینت چنداپلیکیشن FRP
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

sudo systemctl daemon-reload
sudo systemctl enable frp-client
sudo systemctl start frp-client
```

---

## 📊 خلاصه نقشه پورت‌ها

```
┌─────────────────────────────────────────────────────────────┐
│                    FRP SERVER (2.144.21.218)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Port 7000  ←── پورت کنترل (احراز هویت)                     │
│                                                             │
│  Port 8000  ←── اپ ۱: وب سرور (TCP)                        │
│  Port 8001  ←── اپ ۲: API سرور (TCP)                       │
│  Port 8002  ←── اپ ۳: PostgreSQL (TCP)                     │
│  Port 8003  ←── اپ ۴: سرور بازی (UDP) ← UDP!               │
│  Port 8004  ←── اپ ۵: پنل مدیریت (TCP)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 مرجع سریع

### شروع تمام تونل‌ها
```bash
# استفاده از فایل پیکربندی
frpc -c /etc/frp/frpc.ini

# یا استفاده از اسکریپت
./frp-multi-app.sh start
```

### بررسی وضعیت
```bash
# وضعیت سرویس
sudo systemctl status frp-client

# تونل‌های فعال
./frp-multi-app.sh status

# داشبورد
curl http://localhost:7500
```

### مشاهده لاگ‌ها
```bash
# لاگ‌های کلاینت
sudo journalctl -u frp-client -f

# لاگ‌های سرور
sudo journalctl -u frp-server -f
```

### توقف همه
```bash
sudo systemctl stop frp-client
# یا
./frp-multi-app.sh stop
```

---

## ⚠️ نکات مهم

1. **FRP از TCP و UDP پشتیبانی می‌کند** - UDP را برای اپ‌های بلادرنگ (بازی‌ها، VoIP) استفاده کنید
2. **هر اپ به یک پورت راه دور منحصربه‌فرد نیاز دارد** - بدون تکرار
3. **توکن مشترک است** - همه اپ‌ها از همان توکن استفاده می‌کنند
4. **رمزنگاری را فعال کنید** - همیشه `use_encryption = true` را تنظیم کنید
5. **فشرده‌سازی را فعال کنید** - برای توان عملیاتی بهتر توصیه می‌شود
6. **نظارت بر منابع** - ۵ تونل = ۵ برابر استفاده از منابع

---

## 📈 مقایسه: Bore vs FRP برای چنداپلیکیشن

| ویژگی | Bore | FRP |
|---------|------|-----|
| پشتیبانی TCP | ✅ | ✅ |
| پشتیبانی UDP | ❌ | ✅ |
| فایل پیکربندی | ❌ (فقط CLI) | ✅ (INI/TOML) |
| داشبورد | ❌ | ✅ (Web UI) |
| فشرده‌سازی | ❌ | ✅ |
| رمزنگاری | ✅ (رمز) | ✅ (توکن + رمزنگاری) |
| اتصال مجدد خودکار | دستی | داخلی |

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
