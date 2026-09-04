# FRP Client Documentation (Developer)

## 👨‍💻 Developer Guide

This documentation is for **developers** who want to integrate FRP client into their applications programmatically.

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

### Install FRP CLI

```bash
# Download latest release
curl -L -o /tmp/frp.tar.gz "https://github.com/fatedier/frp/releases/download/v0.68.0/frp_0.68.0_linux_amd64.tar.gz"

# Extract and install
tar -xzf /tmp/frp.tar.gz -C /tmp
sudo install -m 755 /tmp/frp_0.68.0_linux_amd64/frpc /usr/local/bin/frpc

# Verify installation
frpc --version
```

### Platform-Specific Installation

#### macOS (Homebrew)
```bash
brew install frp
```

#### Windows (Scoop)
```powershell
scoop install frp
```

---

## 🚀 Basic Usage

### Connect to Server

```bash
# Basic TCP connection
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080

# UDP connection
frpc udp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8081 --remote-port 8081

# Using config file
frpc -c /etc/frp/frpc.ini
```

### Command Syntax

```bash
frpc <PROTOCOL> --proxy-name <NAME> --server-addr <SERVER_ADDR> --server-port <PORT> --token <TOKEN> --local-port <PORT> --remote-port <PORT>
```

| Parameter | Description | Required |
|-----------|-------------|----------|
| `<PROTOCOL>` | Subcommand: `tcp`, `udp`, `http`, `stcp`, ... | Yes |
| `--proxy-name` | Unique proxy name | Yes |
| `--server-addr` | Server address (IP) | Yes |
| `--server-port` | Server port | Yes |
| `--token` | Authentication token | Yes |
| `--local-port` | Local port to expose | Yes |
| `--remote-port` | Remote port on server | Yes |

---

## ⚙️ Advanced Configuration

### Environment Variables

```bash
# Create environment file
cat > ~/.frp.env <<EOF
export FRP_SERVER_ADDR="2.144.21.218"
export FRP_SERVER_PORT="7000"
export FRP_TOKEN="YOUR_TOKEN"
export FRP_LOCAL_PORT="8080"
export FRP_REMOTE_PORT="8080"
export FRP_PROTOCOL="tcp"
EOF

# Load environment
source ~/.frp.env

# Use in commands
frpc $FRP_PROTOCOL --proxy-name my-app --server-addr "$FRP_SERVER_ADDR" --server-port "$FRP_SERVER_PORT" --token "$FRP_TOKEN" --local-port $FRP_LOCAL_PORT --remote-port $FRP_REMOTE_PORT
```

### Persistent Connection Script

```bash
#!/bin/bash
# frp-tunnel.sh - Persistent tunnel with auto-reconnect

SERVER_ADDR="${FRP_SERVER_ADDR:-2.144.21.218}"
SERVER_PORT="${FRP_SERVER_PORT:-7000}"
TOKEN="${FRP_TOKEN:-YOUR_TOKEN}"
PROTOCOL="${FRP_PROTOCOL:-tcp}"
LOCAL_PORT="${FRP_LOCAL_PORT:-8080}"
REMOTE_PORT="${FRP_REMOTE_PORT:-8080}"

while true; do
    echo "[$(date)] Connecting..."
    frpc $PROTOCOL --proxy-name my-app --server-addr "$SERVER_ADDR" --server-port "$SERVER_PORT" --token "$TOKEN" --local-port $LOCAL_PORT --remote-port $REMOTE_PORT    echo "[$(date)] Disconnected. Reconnecting in 5s..."
    sleep 5
done
```

```bash
# Make executable and run
chmod +x frp-tunnel.sh
nohup ./frp-tunnel.sh > frp.log 2>&1 &
```

---

## 💻 Programmatic Integration

### Python Integration

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
        """Start the FRP tunnel"""
        cmd = [
            'frpc', self.protocol,
            '--proxy-name', 'my-app',
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
        print(f"FRP tunnel started (PID: {self.process.pid})")
        return self.process.pid

    def stop(self):
        """Stop the FRP tunnel"""
        if self.process:
            self.process.terminate()
            self.process.wait()
            print("FRP tunnel stopped")

    def is_running(self):
        """Check if tunnel is active"""
        return self.process and self.process.poll() is None

# Usage
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

### Node.js Integration

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
                '--proxy-name', 'my-app',
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

// Usage
const client = new FRPClient('2.144.21.218', 7000, 'YOUR_TOKEN', 'tcp', 8080, 8080);
client.start();
```

### Bash Integration

```bash
#!/bin/bash
# frp-manager.sh - Manage multiple tunnels

TUNNELS=(
    "8080:8080:tcp:Web Server"
    "8081:8081:udp:Game Server"
    "5432:5432:tcp:Database"
)

start_tunnel() {
    local local_port=$1
    local remote_port=$2
    local protocol=$3
    local name=$4
    
    echo "Starting $name (local:$local_port -> remote:$remote_port, $protocol)"
    frpc $protocol --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port $local_port --remote-port $remote_port &
}

start_all() {
    for tunnel in "${TUNNELS[@]}"; do
        IFS=':' read -r local_port remote_port protocol name <<< "$tunnel"
        start_tunnel $local_port $remote_port $protocol "$name"
    done
}

stop_all() {
    pkill -f "frpc"
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
# frp-healthcheck.sh - Tunnel with health monitoring

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
            frpc ${PROTOCOL:-tcp} --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port ${LOCAL_PORT:-8080} --remote-port ${REMOTE_PORT:-8080} &
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
# frp-multiport.sh - Forward multiple ports

declare -A PORTS=(
    [3000]="tcp:Web App"
    [8080]="udp:Game Server"
    [5432]="tcp:PostgreSQL"
)

for port in "${!PORTS[@]}"; do
    IFS=':' read -r protocol name <<< "${PORTS[$port]}"
    echo "Forwarding $name (port $port, $protocol)"
    frpc $protocol --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token "$FRP_TOKEN" --local-port $port --remote-port $port &
done

echo "All tunnels started. Press Ctrl+C to stop."
wait
```

---

## 🏆 Best Practices

### Security

1. **Never hardcode tokens** in source code
2. **Use environment variables** for sensitive data
3. **Rotate tokens** regularly
4. **Restrict file permissions** on config files
5. **Enable encryption** for all tunnels

```bash
# Good: Use environment variables
frpc tcp --proxy-name my-app --server-addr "$FRP_SERVER_ADDR" --server-port "$FRP_SERVER_PORT" --token "$FRP_TOKEN" --local-port 8080 --remote-port 8080

# Bad: Hardcoded token
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token "my-secret-token" --local-port 8080 --remote-port 8080
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
4. **Use compression** for better throughput

---

## 🔧 Troubleshooting

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | Server offline or wrong port | Check server status and port |
| `Authentication failed` | Wrong token | Verify token matches server |
| `Address already in use` | Port in use | Choose different local port |
| `Timeout` | Network issues | Check firewall and connectivity |

### Debug Mode

```bash
# Enable verbose logging
frpc tcp --proxy-name my-app --server-addr 2.144.21.218 --server-port 7000 --token YOUR_TOKEN --local-port 8080 --remote-port 8080
```

### Network Diagnostics

```bash
# Test server connectivity
nc -zv 2.144.21.218 7000

# Check DNS resolution
nslookup 2.144.21.218

# Trace network path
traceroute 2.144.21.218
```

---

## 📚 API Reference

### Command-Line Options

```
frpc [OPTIONS]

Options:
  -s, --server-addr <SERVER_ADDR>    Server address [default: 0.0.0.0:7000]
  -t, --token <TOTION>               Authentication token
  -P, --protocol <PROTOCOL>          Protocol type (tcp/udp) [default: tcp]
      --local-port <LOCAL_PORT>      Local port to expose
      --remote-port <REMOTE_PORT>    Remote port on server
  -c, --config <CONFIG>              Config file path
      --log-file <LOG_FILE>          Log file path
  -h, --help                         Print help information
  -V, --version                      Print version information
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FRP_SERVER_ADDR` | Server address | None |
| `FRP_SERVER_PORT` | Server port | None |
| `FRP_TOKEN` | Authentication token | None |
| `FRP_PROTOCOL` | Protocol type | tcp |
| `FRP_LOCAL_PORT` | Local port | None |
| `FRP_REMOTE_PORT` | Remote port | None |

---

*Last updated: September 1, 2026*
