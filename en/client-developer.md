# Bore Client Documentation (Developer)

## 👨‍💻 Developer Guide

This documentation is for **developers** who want to integrate Bore client into their applications programmatically.

---

## 📋 Table of Contents

1. [Installation](#installation)
2. [Basic Usage](#basic-usage)
3. [Advanced Configuration](#advanced-configuration)
4. [Programmatic Integration](#programmatic-integration)
5. [Scripting Examples](#scripting-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## 📦 Installation

### Install Bore CLI

```bash
# Download latest release
curl -L -o /tmp/bore.tar.gz "https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz"

# Extract and install
tar -xzf /tmp/bore.tar.gz -C /tmp
sudo install -m 755 /tmp/bore /usr/local/bin/bore

# Verify installation
bore --version
```

### Platform-Specific Installation

#### macOS (Homebrew)
```bash
brew install bore-cli
```

#### Windows (Scoop)
```powershell
scoop install bore-cli
```

---

## 🚀 Basic Usage

### Connect to Server

```bash
# Basic connection
bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"

# Forward local web server
bore local 3000 --to 2.144.21.218:7835 --secret "YOUR_SECRET"

# Forward database port
bore local 5432 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### Command Syntax

```
bore local <LOCAL_PORT> --to <REMOTE_HOST>:<REMOTE_PORT> --secret <SECRET>
```

| Parameter | Description | Required |
|-----------|-------------|----------|
| `LOCAL_PORT` | Local port to expose | Yes |
| `REMOTE_HOST` | Remote server IP/hostname | Yes |
| `REMOTE_PORT` | Remote server port | Yes |
| `SECRET` | Authentication secret | Yes |

---

## ⚙️ Advanced Configuration

### Environment Variables

```bash
# Create environment file
cat > ~/.bore.env <<EOF
export BORE_SECRET="YOUR_SECRET"
export BORE_REMOTE_HOST="2.144.21.218"
export BORE_REMOTE_PORT="7835"
export BORE_LOCAL_PORT="8080"
EOF

# Load environment
source ~/.bore.env

# Use in commands
bore local $BORE_LOCAL_PORT --to $BORE_REMOTE_HOST:$BORE_REMOTE_PORT --secret $BORE_SECRET
```

### Persistent Connection Script

```bash
#!/bin/bash
# bore-tunnel.sh - Persistent tunnel with auto-reconnect

SECRET="${BORE_SECRET:-YOUR_SECRET}"
REMOTE_HOST="${BORE_REMOTE_HOST:-2.144.21.218}"
REMOTE_PORT="${BORE_REMOTE_PORT:-7835}"
LOCAL_PORT="${BORE_LOCAL_PORT:-8080}"

while true; do
    echo "[$(date)] Connecting..."
    bore local $LOCAL_PORT --to $REMOTE_HOST:$REMOTE_PORT --secret "$SECRET"
    echo "[$(date)] Disconnected. Reconnecting in 5s..."
    sleep 5
done
```

```bash
# Make executable and run
chmod +x bore-tunnel.sh
nohup ./bore-tunnel.sh > bore.log 2>&1 &
```

---

## 💻 Programmatic Integration

### Python Integration

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
        """Start the Bore tunnel"""
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
        print(f"Bore tunnel started (PID: {self.process.pid})")
        return self.process.pid

    def stop(self):
        """Stop the Bore tunnel"""
        if self.process:
            self.process.terminate()
            self.process.wait()
            print("Bore tunnel stopped")

    def is_running(self):
        """Check if tunnel is active"""
        return self.process and self.process.poll() is None

# Usage
if __name__ == "__main__":
    client = BoreClient(
        local_port=8080,
        remote_host="2.144.21.218",
        remote_port=7835,
        secret="YOUR_SECRET"
    )
    client.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        client.stop()
```

### Node.js Integration

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

// Usage
const client = new BoreClient(8080, '2.144.21.218', 7835, 'YOUR_SECRET');
client.start();
```

### Bash Integration

```bash
#!/bin/bash
# bore-manager.sh - Manage multiple tunnels

TUNNELS=(
    "8080:3000:Web Server"
    "5432:5432:Database"
    "6379:6379:Redis"
)

start_tunnel() {
    local local_port=$1
    local remote_port=$2
    local name=$3
    
    echo "Starting $name (local:$local_port -> remote:$remote_port)"
    bore local $local_port --to 2.144.21.218:$remote_port --secret "YOUR_SECRET" &
}

start_all() {
    for tunnel in "${TUNNELS[@]}"; do
        IFS=':' read -r local_port remote_port name <<< "$tunnel"
        start_tunnel $local_port $remote_port "$name"
    done
}

stop_all() {
    pkill -f "bore local"
    echo "All tunnels stopped"
}

case "$1" in
    start) start_all ;;
    stop) stop_all ;;
    *) echo "Usage: $0 {start|stop}" ;;
esac
```

---

## 📝 Scripting Examples

### Auto-Reconnect with Health Check

```bash
#!/bin/bash
# bore-healthcheck.sh - Tunnel with health monitoring

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
            echo "[$(date)] Tunnel down, restarting..."
            bore local ${LOCAL_PORT:-8080} --to 2.144.21.218:7835 --secret "$BORE_SECRET" &
            sleep 2
        fi
        sleep 10
    done
}

main
```

### Multi-Port Forwarding

```bash
#!/bin/bash
# bore-multiport.sh - Forward multiple ports

declare -A PORTS=(
    [3000]="Web App"
    [8080]="API"
    [5432]="PostgreSQL"
)

for port in "${!PORTS[@]}"; do
    echo "Forwarding ${PORTS[$port]} (port $port)"
    bore local $port --to 2.144.21.218:7835 --secret "$BORE_SECRET" &
done

echo "All tunnels started. Press Ctrl+C to stop."
wait
```

---

## 🏆 Best Practices

### Security

1. **Never hardcode secrets** in source code
2. **Use environment variables** for sensitive data
3. **Rotate secrets** regularly
4. **Restrict file permissions** on config files

```bash
# Good: Use environment variables
bore local 8080 --to 2.144.21.218:7835 --secret "$BORE_SECRET"

# Bad: Hardcoded secret
bore local 8080 --to 2.144.21.218:7835 --secret "my-secret-123"
```

### Reliability

1. **Implement auto-reconnect** for long-running tunnels
2. **Monitor tunnel health** with periodic checks
3. **Log tunnel activity** for debugging
4. **Use process managers** like systemd or supervisor

### Performance

1. **Limit concurrent tunnels** to avoid resource exhaustion
2. **Use connection pooling** when possible
3. **Monitor resource usage** (CPU, memory, network)

---

## 🔧 Troubleshooting

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | Server offline or wrong port | Check server status and port |
| `Authentication failed` | Wrong secret | Verify secret matches server |
| `Address already in use` | Port in use | Choose different local port |
| `Timeout` | Network issues | Check firewall and connectivity |

### Debug Mode

```bash
# Enable verbose logging
RUST_LOG=debug bore local 8080 --to 2.144.21.218:7835 --secret "YOUR_SECRET"
```

### Network Diagnostics

```bash
# Test server connectivity
nc -zv 2.144.21.218 7835

# Check DNS resolution
nslookup 2.144.21.218

# Trace network path
traceroute 2.144.21.218
```

---

## 📚 API Reference

### Command-Line Options

```
bore local [OPTIONS] <LOCAL_PORT> --to <REMOTE> --secret <SECRET>

Options:
  -h, --help       Print help information
  -V, --version    Print version information
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BORE_SECRET` | Authentication secret | None |
| `BORE_REMOTE_HOST` | Remote server address | None |
| `BORE_REMOTE_PORT` | Remote server port | 7835 |
| `BORE_LOCAL_PORT` | Local port to expose | None |

---

*Last updated: September 1, 2026*
