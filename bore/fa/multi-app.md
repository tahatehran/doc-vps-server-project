# راهنمای پیکربندی چنداپلیکیشن Bore

## 📋 پیکربندی ۵ اپ با ۵ پورت مختلف

این راهنما نحوه پیکربندی **۵ اپلیکیشن مختلف** با **۵ پورت مختلف** روی یک سرور Bore را نشان می‌دهد.

---

## 🖥️ پیکربندی سرور (یک سرور)

سرور Bore به عنوان یک نمونه واحد اجرا می‌شود. هر ۵ اپ از همان سرور استفاده می‌کنند.

### شروع سرور Bore

```bash
# یک سرور برای همه اپ‌ها
sudo systemctl start bore-server
```

### قوانین فایروال (هر ۵ اپ)

```bash
# اجازه پورت کنترل Bore
sudo ufw allow 7835/tcp

# اجازه ۵ پورت اپ
sudo ufw allow 8000/tcp
sudo ufw allow 8001/tcp
sudo ufw allow 8002/tcp
sudo ufw allow 8003/tcp
sudo ufw allow 8004/tcp

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
| **اپ ۴** | ردیس | 6379 | 8003 | TCP | سرور کش |
| **اپ ۵** | پنل مدیریت | 9000 | 8004 | TCP | داشبورد مدیریت |

---

### روش ۱: دستورات جداگانه (شروع سریع)

```bash
# اپ ۱: وب سرور
bore local 3000 --to 2.144.21.218:8000 --secret "YOUR_SECRET"

# اپ ۲: API سرور
bore local 8080 --to 2.144.21.218:8001 --secret "YOUR_SECRET"

# اپ ۳: دیتابیس
bore local 5432 --to 2.144.21.218:8002 --secret "YOUR_SECRET"

# اپ ۴: ردیس
bore local 6379 --to 2.144.21.218:8003 --secret "YOUR_SECRET"

# اپ ۵: پنل مدیریت
bore local 9000 --to 2.144.21.218:8004 --secret "YOUR_SECRET"
```

---

### روش ۲: اسکریپت چندتونلی (توصیه می‌شود)

```bash
#!/bin/bash
# bore-multi-app.sh - شروع تمام ۵ تونل اپ

SECRET="YOUR_SECRET"
SERVER="2.144.21.218"

# پیکربندی اپ‌ها: پورت_محلی:پورت_راه_دور:توضیحات
APPS=(
    "3000:8000:وب سرور"
    "8080:8001:API سرور"
    "5432:8002:PostgreSQL"
    "6379:8003:ردیس"
    "9000:8004:پنل مدیریت"
)

start_all() {
    echo "شروع تمام ۵ تونل Bore..."
    for app in "${APPS[@]}"; do
        IFS=':' read -r local_port remote_port name <<< "$app"
        echo "  → $name (محلی:$local_port → $SERVER:$remote_port)"
        bore local $local_port --to $SERVER:$remote_port --secret "$SECRET" &
    done
    echo "تمام ۵ تونل شروع شدند!"
}

stop_all() {
    echo "توقف تمام تونل‌های Bore..."
    pkill -f "bore local"
    echo "تمام تونل‌ها متوقف شدند."
}

status() {
    echo "تونل‌های فعال Bore:"
    ps aux | grep "bore local" | grep -v grep
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
chmod +x bore-multi-app.sh

# شروع تمام تونل‌ها
./bore-multi-app.sh start

# بررسی وضعیت
./bore-multi-app.sh status

# توقف همه
./bore-multi-app.sh stop
```

---

### روش ۳: سرویس Systemd (تولید)

```bash
sudo tee /etc/systemd/system/bore-multi-app.service <<EOF
[Unit]
Description=سرویس تونل چنداپلیکیشن Bore
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/bore-multi-app.sh start
ExecStop=/usr/local/bin/bore-multi-app.sh stop
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bore-multi-app
sudo systemctl start bore-multi-app
```

---

## 📊 خلاصه نقشه پورت‌ها

```
┌─────────────────────────────────────────────────────────────┐
│                    BORE SERVER (2.144.21.218)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Port 7835  ←── پورت کنترل (احراز هویت)                     │
│                                                             │
│  Port 8000  ←── اپ ۱: وب سرور (TCP)                        │
│  Port 8001  ←── اپ ۲: API سرور (TCP)                       │
│  Port 8002  ←── اپ ۳: PostgreSQL (TCP)                     │
│  Port 8003  ←── اپ ۴: ردیس (TCP)                           │
│  Port 8004  ←── اپ ۵: پنل مدیریت (TCP)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 مرجع سریع

### شروع تمام تونل‌ها
```bash
./bore-multi-app.sh start
```

### بررسی وضعیت
```bash
./bore-multi-app.sh status
```

### مشاهده لاگ‌ها
```bash
# تمام تونل‌ها
sudo journalctl -u bore-multi-app -f

# اپ خاص (بررسی فرآیند)
ps aux | grep "bore local"
```

### توقف همه
```bash
./bore-multi-app.sh stop
```

---

## ⚠️ نکات مهم

1. **Bore فقط TCP است** - برای UDP، به جای آن از FRP استفاده کنید
2. **هر اپ به یک پورت راه دور منحصربه‌فرد نیاز دارد** - بدون تکرار
3. **رمز مشترک است** - همه اپ‌ها از همان رمز استفاده می‌کنند
4. **اتصال مجدد خودکار** - برای محیط تولید منطق راه‌اندازی مجدد پیاده‌سازی کنید
5. **نظارت بر منابع** - ۵ تونل = ۵ برابر استفاده از منابع

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
