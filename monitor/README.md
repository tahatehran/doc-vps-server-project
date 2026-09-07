# 📡 FRP Live Dashboard

> ⚠️ **نکته:** این ابزار **اختیاری** است و در حال حاضر روی سرور مستقر **نیست** (به تصمیم مالک حذف شد تا اطلاعات روی وب عمومی لو نرود). پنل‌های ادمین رسمی جایگزین شده‌اند: داشبورد frps روی پورت `7500` و پنل ادمین کلاینت روی `7400` — هر دو با احراز هویت و به‌صورت زنده.

داشبورد وبِ **لحظه‌ای** برای سرور FRP — استریم زنده هر ۲ ثانیه با Server-Sent Events، فارسی RTL، بدون وابستگی خارجی (فقط کتابخانه استاندارد Python).

آدرس زنده: **http://2.144.21.218:8090** *(غیرفعال — در صورت نیاز خودتان مستقر کنید)*

## چه چیزی را زنده نشان می‌دهد؟

| بخش | داده‌ها |
|---|---|
| وضعیت FRP Server | نسخه، پورت اصلی، پورت‌های مجاز، تعداد کلاینت و اتصال‌های فعال |
| ترافیک زنده | نرخ ورودی/خروجی بر ثانیه + نمودار خطی ۳ دقیقه اخیر + ترافیک امروز و کل |
| سیستم | CPU، RAM، دیسک (با نوار درصد)، بار سیستم، Uptime |
| امنیت | بن‌های فعال و مجموع بن‌های fail2ban، پورت‌های شنیده‌شده |
| کلاینت‌های متصل | شناسه، نسخه، سیستم‌عامل/معماری |
| پروکسی‌ها | نام، نوع، وضعیت لحظه‌ای (فعال/خاموش)، اتصال‌ها، ترافیک امروز، آخرین فعالیت |

## استقرار روی سرور

```bash
sudo install -m 700 frp-live-dashboard.py /opt/frp-dashboard/dashboard.py
```

واحد systemd (`/etc/systemd/system/frp-status.service`):

```ini
[Unit]
Description=FRP Live Dashboard (SSE real-time)
After=network-online.target frps.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/frp-dashboard/dashboard.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload && sudo systemctl enable --now frp-status
```

## امنیت

- صفحه **فقط‌خواندنی** است و هیچ توکن یا رمزی نمایش نمی‌دهد
- اعتبارنامه‌ی API داشبورد frps از `/etc/frp/frps.ini` خوانده می‌شود و فقط سمت سرور استفاده می‌شود (فایل باید `600` باشد)
- استریم SSE بدون کش است و در صورت قطع، مرورگر خودکار وصل می‌شود
- اپراتور می‌تواند داشبورد ادمین frps را روی پورت 7500 با ورود جداگانه باز کند (لینک داخل صفحه)
