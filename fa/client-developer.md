# مستندات کلاینت بور (توسعه‌دهنده)

## 👨‍💻 راهنمای توسعه‌دهنده

این مستند برای **توسعه‌دهندگان** است که می‌خواهند کلاینت Bore را به صورت برنامه‌نویسی در برنامه‌های خود ادغام کنند.

---

## 📋 فهرست مطالب

1. [نصب](#نصب)
2. [استفاده پایه](#استفاده-پایه)
3. [پیکربندی پیشرفته](#پیکربندی-پیشرفته)
4. [ادغام برنامه‌نویسی](#ادغام-برنامه‌نویسی)
5. [مثال‌های اسکریپت](#مثال‌های-اسکریپت)
6. [بهترین روش‌ها](#بهترین-روش‌ها)
7. [عیب‌یابی](#عیب‌یابی)

---

## 📦 نصب

### نصب Bore CLI

```bash
# دانلود آخرین نسخه
curl -L -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"

# استخراج و نصب
tar -xzf /tmp/bore.tar.gz -C /tmp
sudo install -m 755 /tmp/bore /usr/local/bin/bore

# تأیید نصب
bore --version
```

### نصب در پلتفرم‌های مختلف

#### macOS (Homebrew)
```bash
brew install bore-cli
```

#### Windows (Scoop)
```powershell
scoop install bore-cli
```

---

## 🚀 استفاده پایه

### اتصال به سرور

```bash
# اتصال پایه
bore local 8080 --to 2.144.21.218:7835 --secret "رمز_شما"

# فوروارد کردن سرور وب محلی
bore local 3000 --to 2.144.21.218:7835 --secret "رمز_شما"

# فوروارد کردن پورت دیتابیس
bore local 5432 --to 2.144.21.218:7835 --secret "رمز_شما"
```

### نحوه استفاده

```
bore local <پورت_محلی> --to <هاست_راه_دور>:<پورت_راه_دور> --secret <رمز>
```

| پارامتر | توضیحات | الزامی |
|---------|-------------|----------|
| `پورت_محلی` | پورت محلی برای نمایش | بله |
| `هاست_راه_دور` | آی پی/نام هاست سرور راه دور | بله |
| `پورت_راه_دور` | پورت سرور راه دور | بله |
| `رمز` | رمز احراز هویت | بله |

---

## ⚙️ پیکربندی پیشرفته

### متغیرهای محیطی

```bash
# ایجاد فایل محیطی
cat > ~/.bore.env <<EOF
export BORE_SECRET="رمز_شما"
export BORE_REMOTE_HOST="2.144.21.218"
export BORE_REMOTE_PORT="7835"
export BORE_LOCAL_PORT="8080"
EOF

# بارگذاری محیط
source ~/.bore.env

# استفاده در دستورات
bore local $BORE_LOCAL_PORT --to $BORE_REMOTE_HOST:$BORE_REMOTE_PORT --secret $BORE_SECRET
```

### اسکریپت اتصال پایدار

```bash
#!/bin/bash
# bore-tunnel.sh - تونل پایدار با اتصال مجدد خودکار

SECRET="${BORE_SECRET:-رمز_شما}"
REMOTE_HOST="${BORE_REMOTE_HOST:-2.144.21.218}"
REMOTE_PORT="${BORE_REMOTE_PORT:-7835}"
LOCAL_PORT="${BORE_LOCAL_PORT:-8080}"

while true; do
    echo "[$(date)] در حال اتصال..."
    bore local $LOCAL_PORT --to $REMOTE_HOST:$REMOTE_PORT --secret "$SECRET"
    echo "[$(date)] اتصال قطع شد. اتصال مجدد در ۵ ثانیه..."
    sleep 5
done
```

```bash
# قابل اجرا کردن و اجرا
chmod +x bore-tunnel.sh
nohup ./bore-tunnel.sh > bore.log 2>&1 &
```

---

## 💻 ادغام برنامه‌نویسی

### یکپارچه‌سازی Python

```python
import subprocess
import os
import signal
import time

class BoreClient:
    def __init__(self, local_port, remote_host, remote_port, secret):
        self.local_port = local_port
        self.remote_host = remote_host
        self.remote_port = remote_port
        self.secret = secret
        self.process = None

    def start(self):
        """شروع تونل Bore"""
        cmd = [
            'bore', 'local', str(self.local_port),
            '--to', f"{self.remote_host}:{self.remote_port}",
            '--secret', self.secret
        ]
        self.process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        print(f"تونل Bore شروع شد (PID: {self.process.pid})")
        return self.process.pid

    def stop(self):
        """توقف تونل Bore"""
        if self.process:
            self.process.terminate()
            self.process.wait()
            print("تونل Bore متوقف شد")

    def is_running(self):
        """بررسی فعال بودن تونل"""
        return self.process and self.process.poll() is None

# استفاده
if __name__ == "__main__":
    client = BoreClient(
        local_port=8080,
        remote_host="2.144.21.218",
        remote_port=7835,
        secret="رمز_شما"
    )
    client.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        client.stop()
```

### یکپارچه‌سازی Node.js

```javascript
const { spawn } = require('child_process');

class BoreClient {
    constructor(localPort, remoteHost, remotePort, secret) {
        this.localPort = localPort;
        this.remoteHost = remoteHost;
        this.remotePort = remotePort;
        this.secret = secret;
        this.process = null;
    }

    start() {
        return new Promise((resolve, reject) => {
            this.process = spawn('bore', [
                'local', this.localPort.toString(),
                '--to', `${this.remoteHost}:${this.remotePort}`,
                '--secret', this.secret
            ]);

            this.process.stdout.on('data', (data) => {
                console.log(`Bore: ${data}`);
            });

            this.process.stderr.on('data', (data) => {
                console.error(`Bore Error: ${data}`);
            });

            this.process.on('close', (code) => {
                console.log(`Bore exited with code ${code}`);
            });

            resolve(this.process.pid);
        });
    }

    stop() {
        if (this.process) {
            this.process.kill();
        }
    }
}

// استفاده
const client = new BoreClient(8080, '2.144.21.218', 7835, 'رمز_شما');
client.start();
```

### یکپارچه‌سازی Bash

```bash
#!/bin/bash
# bore-manager.sh - مدیریت چندین تونل

TUNNELS=(
    "8080:3000:سرور وب"
    "5432:5432:دیتابیس"
    "6379:6379:ردیس"
)

start_tunnel() {
    local local_port=$1
    local remote_port=$2
    local name=$3
    
    echo "شروع $name (محلی:$local_port -> راه دور:$remote_port)"
    bore local $local_port --to 2.144.21.218:$remote_port --secret "رمز_شما" &
}

start_all() {
    for tunnel in "${TUNNELS[@]}"; do
        IFS=':' read -r local_port remote_port name <<< "$tunnel"
        start_tunnel $local_port $remote_port "$name"
    done
}

stop_all() {
    pkill -f "bore local"
    echo "تمام تونل‌ها متوقف شدند"
}

case "$1" in
    start) start_all ;;
    stop) stop_all ;;
    *) echo "استفاده: $0 {start|stop}" ;;
esac
```

---

## 📝 مثال‌های اسکریپت

### اتصال مجدد خودکار با بررسی سلامت

```bash
#!/bin/bash
# bore-healthcheck.sh - تونل با نظارت بر سلامت

check_tunnel() {
    local port=$1
    if nc -zv localhost $port 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

main() {
    while true; do
        if ! check_tunnel ${LOCAL_PORT:-8080}; then
            echo "[$(date)] تونل قطع است، راه‌اندازی مجدد..."
            bore local ${LOCAL_PORT:-8080} --to 2.144.21.218:7835 --secret "$BORE_SECRET" &
            sleep 2
        fi
        sleep 10
    done
}

main
```

### فوروارد کردن چندین پورت

```bash
#!/bin/bash
# bore-multiport.sh - فوروارد کردن چندین پورت

declare -A PORTS=(
    [3000]="برنامه وب"
    [8080]="API"
    [5432]="PostgreSQL"
)

for port in "${!PORTS[@]}"; do
    echo "فوروارد ${PORTS[$port]} (پورت $port)"
    bore local $port --to 2.144.21.218:7835 --secret "$BORE_SECRET" &
done

echo "تمام تونل‌ها شروع شدند. برای توقف Ctrl+C را فشار دهید."
wait
```

---

## 🏆 بهترین روش‌ها

### امنیت

1. **هرگز رمزها را در کد منبع هاردکد نکنید**
2. **از متغیرهای محیطی** برای داده‌های حساس استفاده کنید
3. **رمزها را به طور منظم بچرخانید**
4. **مجوزهای فایل** را محدود کنید

```bash
# خوب: استفاده از متغیرهای محیطی
bore local 8080 --to 2.144.21.218:7835 --secret "$BORE_SECRET"

# بد: رمز هاردکد شده
bore local 8080 --to 2.144.21.218:7835 --secret "my-secret-123"
```

### قابلیت اطمینان

1. **اتصال مجدد خودکار** برای تونل‌های طولانی‌مدت پیاده‌سازی کنید
2. **سلامت تونل** را با بررسی‌های دوره‌ای نظارت کنید
3. **فعالیت تونل** را برای عیب‌یابی لاگ کنید
4. **از مدیران فرآیند** مثل systemd یا supervisor استفاده کنید

### عملکرد

1. **تونل‌های همزمان** را برای جلوگیری از تمام شدن منابع محدود کنید
2. **از استخر اتصال** در صورت امکان استفاده کنید
3. **استفاده از منابع** (CPU، حافظه، شبکه) را نظارت کنید

---

## 🔧 عیب‌یابی

### خطاهای رایج

| خطا | علت | راه‌حل |
|-----|-------|----------|
| `Connection refused` | سرور آفلاین یا پورت اشتباه | وضعیت سرور و پورت را بررسی کنید |
| `Authentication failed` | رمز اشتباه | رمز را با سرور مطابقت دهید |
| `Address already in use` | پورت در حال استفاده | پورت محلی متفاوت انتخاب کنید |
| `Timeout` | مشکلات شبکه | فایروال و اتصال را بررسی کنید |

### حالت دیباگ

```bash
# فعال‌سازی لاگ‌گیری مفصل
RUST_LOG=debug bore local 8080 --to 2.144.21.218:7835 --secret "رمز_شما"
```

### تشخیص شبکه

```bash
# آزمایش اتصال سرور
nc -zv 2.144.21.218 7835

# بررسی وضوح DNS
nslookup 2.144.21.218

# ردیابی مسیر شبکه
traceroute 2.144.21.218
```

---

## 📚 مرجع API

### گزینه‌های خط فرمان

```
bore local [OPTIONS] <LOCAL_PORT> --to <REMOTE> --secret <SECRET>

گزینه‌ها:
  -h, --help       چاپ اطلاعات راهنما
  -V, --version    چاپ اطلاعات نسخه
```

### متغیرهای محیطی

| متغیر | توضیحات | پیش‌فرض |
|----------|-------------|---------|
| `BORE_SECRET` | رمز احراز هویت | هیچ |
| `BORE_REMOTE_HOST` | آدرس سرور راه دور | هیچ |
| `BORE_REMOTE_PORT` | پورت سرور راه دور | 7835 |
| `BORE_LOCAL_PORT` | پورت محلی برای نمایش | هیچ |

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
