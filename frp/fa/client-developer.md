# مستندات کلاینت FRP (توسعه‌دهنده)

## 👨‍💻 راهنمای توسعه‌دهنده

این مستند برای **توسعه‌دهندگان** است که می‌خواهند کلاینت FRP را به صورت برنامه‌نویسی در برنامه‌های خود ادغام کنند.

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

### نصب FRP CLI

```bash
# دانلود آخرین نسخه
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"

# استخراج و نصب
tar -xzf /tmp/frp.tar.gz -C /tmp
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc

# تأیید نصب
frpc --version
```

### نصب در پلتفرم‌های مختلف

#### macOS (Homebrew)
```bash
brew install frp
```

#### Windows (Scoop)
```powershell
scoop install frp
```

---

## 🚀 استفاده پایه

### اتصال به سرور

```bash
# اتصال TCP پایه
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080

# اتصال UDP
frpc udp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8081 --remote-port 8081

# استفاده از فایل پیکربندی
frpc -c /etc/frp/frpc.ini
```

### نحوه استفاده

```bash
frpc <PROTOCOL> --server-addr <SERVER_ADDR> --server-port <PORT> --token <TOKEN> --local-port <PORT> --remote-port <PORT>
```

| پارامتر | توضیحات | الزامی |
|---------|-------------|----------|
| `<PROTOCOL>` | زیرفرمان: `tcp`، `udp`، `http`، `stcp` و... | بله |
| `--server-addr` | آدرس سرور (IP) | بله |
| `--server-port` | پورت سرور | بله |
| `--token` | توکن احراز هویت | بله |
| `--local-port` | پورت محلی برای نمایش | بله |
| `--remote-port` | پورت راه دور در سرور | بله |

---

## ⚙️ پیکربندی پیشرفته

### متغیرهای محیطی

```bash
# ایجاد فایل محیطی
cat > ~/.frp.env <<EOF
export FRP_SERVER_ADDR="2.144.21.218"
export FRP_SERVER_PORT="7000"
export FRP_TOKEN="YOUR_TOKEN"
export FRP_LOCAL_PORT="8080"
export FRP_REMOTE_PORT="8080"
export FRP_PROTOCOL="tcp"
EOF

# بارگذاری محیط
source ~/.frp.env

# استفاده در دستورات
frpc $FRP_PROTOCOL --server-addr "$FRP_SERVER_ADDR" --server-port "$FRP_SERVER_PORT" --token "$FRP_TOKEN" --local-port $FRP_LOCAL_PORT --remote-port $FRP_REMOTE_PORT
```

### اسکریپت اتصال پایدار

```bash
#!/bin/bash
# frp-tunnel.sh - تونل پایدار با اتصال مجدد خودکار

SERVER_ADDR="${FRP_SERVER_ADDR:-2.144.21.218}"
SERVER_PORT="${FRP_SERVER_PORT:-7000}"
TOKEN="${FRP_TOKEN:-YOUR_TOKEN}"
PROTOCOL="${FRP_PROTOCOL:-tcp}"
LOCAL_PORT="${FRP_LOCAL_PORT:-8080}"
REMOTE_PORT="${FRP_REMOTE_PORT:-8080}"

while true; do
    echo "[$(date)] در حال اتصال..."
    frpc $PROTOCOL --server-addr "$SERVER_ADDR" --server-port "$SERVER_PORT" --token "$TOKEN" --local-port $LOCAL_PORT --remote-port $REMOTE_PORT
    echo "[$(date)] اتصال قطع شد. اتصال مجدد در ۵ ثانیه..."
    sleep 5
done
```

```bash
# قابل اجرا کردن و اجرا
chmod +x frp-tunnel.sh
nohup ./frp-tunnel.sh > frp.log 2>&1 &
```

---

## 💻 ادغام برنامه‌نویسی

### یکپارچه‌سازی Python

```python
import subprocess
import os
import signal
import time

class FRPClient:
    def __init__(self, server_addr, server_port, token, protocol, local_port, remote_port):
        self.server_addr = server_addr
        self.server_port = server_port
        self.token = token
        self.protocol = protocol
        self.local_port = local_port
        self.remote_port = remote_port
        self.process = None

    def start(self):
        """شروع تونل FRP"""
        cmd = [
            'frpc', self.protocol,
            '--server-addr', self.server_addr,
            '--server-port', str(self.server_port),
            '--token', self.token,
            '--local-port', str(self.local_port),
            '--remote-port', str(self.remote_port)
        ]
        self.process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        print(f"تونل FRP شروع شد (PID: {self.process.pid})")
        return self.process.pid

    def stop(self):
        """توقف تونل FRP"""
        if self.process:
            self.process.terminate()
            self.process.wait()
            print("تونل FRP متوقف شد")

    def is_running(self):
        """بررسی فعال بودن تونل"""
        return self.process and self.process.poll() is None

# استفاده
if __name__ == "__main__":
    client = FRPClient(
        server_addr="2.144.21.218",
        server_port=7000,
        token="YOUR_TOKEN",
        protocol="tcp",
        local_port=8080,
        remote_port=8080
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

class FRPClient {
    constructor(serverAddr, serverPort, token, protocol, localPort, remotePort) {
        this.serverAddr = serverAddr;
        this.serverPort = serverPort;
        this.token = token;
        this.protocol = protocol;
        this.localPort = localPort;
        this.remotePort = remotePort;
        this.process = null;
    }

    start() {
        return new Promise((resolve, reject) => {
            this.process = spawn('frpc', [
                this.protocol,
                '--server-addr', this.serverAddr,
                '--server-port', this.serverPort.toString(),
                '--token', this.token,
                '--local-port', this.localPort.toString(),
                '--remote-port', this.remotePort.toString()
            ]);

            this.process.stdout.on('data', (data) => {
                console.log(`FRP: ${data}`);
            });

            this.process.stderr.on('data', (data) => {
                console.error(`FRP Error: ${data}`);
            });

            this.process.on('close', (code) => {
                console.log(`FRP exited with code ${code}`);
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
const client = new FRPClient('2.144.21.218', 7000, 'YOUR_TOKEN', 'tcp', 8080, 8080);
client.start();
```

### یکپارچه‌سازی Bash

```bash
#!/bin/bash
# frp-manager.sh - مدیریت چندین تونل

TUNNELS=(
    "8080:8080:tcp:سرور وب"
    "8081:8081:udp:سرور بازی"
    "5432:5432:tcp:دیتابیس"
)

start_tunnel() {
    local local_port=$1
    local remote_port=$2
    local protocol=$3
    local name=$4
    
    echo "شروع $name (محلی:$local_port -> راه دور:$remote_port, $protocol)"
    frpc $protocol --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port $local_port --remote-port $remote_port &
}

start_all() {
    for tunnel in "${TUNNELS[@]}"; do
        IFS=':' read -r local_port remote_port protocol name <<< "$tunnel"
        start_tunnel $local_port $remote_port $protocol "$name"
    done
}

stop_all() {
    pkill -f "frpc"
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
# frp-healthcheck.sh - تونل با نظارت بر سلامت

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
            frpc ${PROTOCOL:-tcp} --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port ${LOCAL_PORT:-8080} --remote-port ${REMOTE_PORT:-8080} &
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
# frp-multiport.sh - فوروارد کردن چندین پورت

declare -A PORTS=(
    [3000]="tcp:برنامه وب"
    [8080]="udp:سرور بازی"
    [5432]="tcp:PostgreSQL"
)

for port in "${!PORTS[@]}"; do
    IFS=':' read -r protocol name <<< "${PORTS[$port]}"
    echo "فوروارد $name (پورت $port, $protocol)"
    frpc $protocol --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port $port --remote-port $port &
done

echo "تمام تونل‌ها شروع شدند. برای توقف Ctrl+C را فشار دهید."
wait
```

---

## 🏆 بهترین روش‌ها

### امنیت

1. **هرگز توکن‌ها را در کد منبع هاردکد نکنید**
2. **از متغیرهای محیطی** برای داده‌های حساس استفاده کنید
3. **توکن‌ها را به طور منظم بچرخانید**
4. **مجوزهای فایل** را محدود کنید
5. **رمزنگاری را برای تمام تونل‌ها فعال کنید**

```bash
# خوب: استفاده از متغیرهای محیطی
frpc tcp --server-addr "$FRP_SERVER_ADDR" --server-port "$FRP_SERVER_PORT" --token "$FRP_TOKEN" --local-port 8080 --remote-port 8080

# بد: توکن هاردکد شده
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token "my-secret-token" --local-port 8080 --remote-port 8080
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
4. **از فشرده‌سازی** برای توان عملیاتی بهتر استفاده کنید

---

## 🔧 عیب‌یابی

### خطاهای رایج

| خطا | علت | راه‌حل |
|-----|-------|----------|
| `Connection refused` | سرور آفلاین یا پورت اشتباه | وضعیت سرور و پورت را بررسی کنید |
| `Authentication failed` | توکن اشتباه | توکن را با سرور مطابقت دهید |
| `Address already in use` | پورت در حال استفاده | پورت محلی متفاوت انتخاب کنید |
| `Timeout` | مشکلات شبکه | فایروال و اتصال را بررسی کنید |

### حالت دیباگ

```bash
# فعال‌سازی لاگ‌گیری مفصل
frpc tcp --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080
```

### تشخیص شبکه

```bash
# آزمایش اتصال سرور
nc -zv 2.144.21.218 7000

# بررسی وضوح DNS
nslookup 2.144.21.218

# ردیابی مسیر شبکه
traceroute 2.144.21.218
```

---

## 📚 مرجع API

### گزینه‌های خط فرمان

```
frpc [OPTIONS]

گزینه‌ها:
  -s, --server-addr <SERVER_ADDR>    آدرس سرور [پیش‌فرض: 0.0.0.0:7000]
  -t, --token <TOKEN>                توکن احراز هویت
  -P, --protocol <PROTOCOL>          نوع پروتکل (tcp/udp) [پیش‌فرض: tcp]
      --local-port <LOCAL_PORT>      پورت محلی برای نمایش
      --remote-port <REMOTE_PORT>    پورت راه دور در سرور
  -c, --config <CONFIG>              مسیر فایل پیکربندی
      --log-file <LOG_FILE>          مسیر فایل لاگ
  -h, --help                         چاپ اطلاعات راهنما
  -V, --version                      چاپ اطلاعات نسخه
```

### متغیرهای محیطی

| متغیر | توضیحات | پیش‌فرض |
|----------|-------------|---------|
| `FRP_SERVER_ADDR` | آدرس سرور | هیچ |
| `FRP_SERVER_PORT` | پورت سرور | هیچ |
| `FRP_TOKEN` | توکن احراز هویت | هیچ |
| `FRP_PROTOCOL` | نوع پروتکل | tcp |
| `FRP_LOCAL_PORT` | پورت محلی | هیچ |
| `FRP_REMOTE_PORT` | پورت راه دور | هیچ |

---

*آخرین به‌روزرسانی: ۱ سپتامبر ۲۰۲۶*
