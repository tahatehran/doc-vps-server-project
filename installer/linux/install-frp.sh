#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# FRP Client Installer for Linux
# Features: Install / Uninstall / Update / Connect
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FRP_VERSION="0.71.0"
FRP_ARCH="linux_amd64"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${FRP_ARCH}.tar.gz"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/frp"
SERVICE_FILE="/etc/systemd/system/frp-client.service"
SERVICE_NAME="frp-client"

print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║            FRP Client Installer for Linux                 ║"
    echo "║                  Version: ${FRP_VERSION}                     ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_menu() {
    echo -e "${GREEN}Please select an option:${NC}"
    echo "  1) Install FRP Client"
    echo "  2) Uninstall FRP Client"
    echo "  3) Update FRP Client"
    echo "  4) Connect to Server"
    echo "  5) Exit"
    echo ""
    read -rp "Enter your choice [1-5]: " choice
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}This operation requires root privileges.${NC}"
        echo -e "${YELLOW}Please run with sudo.${NC}"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}Unsupported OS. This script supports Debian/Ubuntu/RHEL/CentOS.${NC}"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y -qq curl tar systemd >/dev/null 2>&1 || true
    elif command -v yum >/dev/null 2>&1; then
        yum install -y -q curl tar systemd >/dev/null 2>&1 || true
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y -q curl tar systemd >/dev/null 2>&1 || true
    fi
    echo -e "${GREEN}Dependencies installed.${NC}"
}

download_frpc() {
    echo -e "${BLUE}Downloading FRP Client v${FRP_VERSION}...${NC}"
    local tmpdir
    tmpdir=$(mktemp -d)
    cd "$tmpdir"
    curl -fsSL -o frp.tar.gz "$FRP_URL"
    tar -xzf frp.tar.gz
    local extracted_dir="frp_${FRP_VERSION}_${FRP_ARCH}"
    if [[ ! -d "$extracted_dir" ]]; then
        echo -e "${RED}Download failed or wrong archive format.${NC}"
        rm -rf "$tmpdir"
        exit 1
    fi
    echo -e "${GREEN}Downloaded successfully.${NC}"
    echo "$tmpdir/$extracted_dir"
}

install_frpc() {
    check_root
    check_os
    install_dependencies

    echo -e "${BLUE}Installing FRP Client...${NC}"
    local extracted_dir
    extracted_dir=$(download_frpc)
    cp "${extracted_dir}/frpc" "$INSTALL_DIR/frpc"
    chmod 755 "$INSTALL_DIR/frpc"

    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR"

    echo -e "${GREEN}FRP Client installed to ${INSTALL_DIR}/frpc${NC}"
    echo -e "${GREEN}Config directory: ${CONFIG_DIR}${NC}"
    echo ""
    echo -e "${YELLOW}Next step:${NC}"
    echo "  1. Edit config: sudo nano ${CONFIG_DIR}/frpc.toml"
    echo "  2. Start service: sudo systemctl enable --now frp-client"
    echo "  3. Check status: sudo systemctl status frp-client"
    echo ""
}

uninstall_frpc() {
    check_root
    echo -e "${YELLOW}Uninstalling FRP Client...${NC}"

    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        systemctl stop "$SERVICE_NAME" || true
    fi
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        systemctl disable "$SERVICE_NAME" || true
    fi
    rm -f "$SERVICE_FILE"
    rm -f "$INSTALL_DIR/frpc"
    rm -rf "$CONFIG_DIR"

    systemctl daemon-reload || true

    echo -e "${GREEN}FRP Client uninstalled successfully.${NC}"
}

update_frpc() {
    check_root
    echo -e "${BLUE}Updating FRP Client to v${FRP_VERSION}...${NC}"

    if [[ ! -f "$INSTALL_DIR/frpc" ]]; then
        echo -e "${RED}FRP Client is not installed. Please install first.${NC}"
        exit 1
    fi

    local current_version
    current_version=$("$INSTALL_DIR/frpc" --version 2>/dev/null || echo "unknown")
    echo -e "${YELLOW}Current version: ${current_version}${NC}"

    local extracted_dir
    extracted_dir=$(download_frpc)
    cp "${extracted_dir}/frpc" "$INSTALL_DIR/frpc"
    chmod 755 "$INSTALL_DIR/frpc"

    local new_version
    new_version=$("$INSTALL_DIR/frpc" --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}Updated to version: ${new_version}${NC}"

    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${YELLOW}Restarting service...${NC}"
        systemctl restart "$SERVICE_NAME"
        echo -e "${GREEN}Service restarted.${NC}"
    fi
}

connect_to_server() {
    check_root

    if [[ ! -f "$INSTALL_DIR/frpc" ]]; then
        echo -e "${RED}FRP Client is not installed. Please install first (option 1).${NC}"
        exit 1
    fi

    echo -e "${BLUE}Connect to FRP Server${NC}"
    echo ""

    read -rp "Server Address [2.144.21.218]: " server_addr
    server_addr=${server_addr:-2.144.21.218}

    read -rp "Server Port [7000]: " server_port
    server_port=${server_port:-7000}

    read -rp "Auth Token (the auth.token from the server's frps.toml - ask the server admin): " auth_token
    if [[ -z "$auth_token" ]]; then
        echo -e "${RED}Token cannot be empty.${NC}"
        exit 1
    fi
    case "$auth_token" in
        YOUR_TOKEN|توکن_شما|your-token|changeme)
            echo -e "${RED}That is a placeholder from the docs, not a real token.${NC}"
            echo -e "${YELLOW}Ask the server admin for the auth.token value in the server's frps.toml.${NC}"
            exit 1
            ;;
    esac

    read -rp "Local Port (your app port): " local_port
    if [[ -z "$local_port" ]]; then
        echo -e "${RED}Local port cannot be empty.${NC}"
        exit 1
    fi

    read -rp "Remote Port (exposed port on server): " remote_port
    if [[ -z "$remote_port" ]]; then
        echo -e "${RED}Remote port cannot be empty.${NC}"
        exit 1
    fi

    read -rp "Proxy Name [my-app]: " proxy_name
    proxy_name=${proxy_name:-my-app}

    read -rp "Proxy Type [tcp/http]: " proxy_type
    proxy_type=${proxy_type:-tcp}

    echo ""
    echo -e "${YELLOW}Creating configuration...${NC}"

    mkdir -p "$CONFIG_DIR"

    local config_file="$CONFIG_DIR/frpc.toml"
    cat > "$config_file" <<EOF
serverAddr = "${server_addr}"
serverPort = ${server_port}
auth.method = "token"
auth.token = "${auth_token}"

transport.protocol = "tcp"
transport.poolCount = 5
transport.tcpMux = true
transport.heartbeatInterval = 30
transport.heartbeatTimeout = 90

log.level = "info"
log.maxDays = 3

[[proxies]]
name = "${proxy_name}"
type = "${proxy_type}"
localIP = "127.0.0.1"
localPort = ${local_port}
remotePort = ${remote_port}
EOF

    if [[ "$proxy_type" == "http" ]]; then
        read -rp "Custom Domain (optional): " custom_domain
        if [[ -n "$custom_domain" ]]; then
            sed -i "s|remotePort = ${remote_port}|customDomains = [\"${custom_domain}\"]|" "$config_file"
        fi
    fi

    chmod 600 "$config_file"

    echo -e "${GREEN}Configuration saved to ${config_file}${NC}"

    # Live 6s foreground test so the user sees the REAL server response
    # (wrong token, duplicate proxy name, unreachable server) before a
    # broken service gets installed
    echo -e "${YELLOW}Testing connection to server (6 seconds)...${NC}"
    local test_log
    test_log=$(mktemp)
    timeout 6 "$INSTALL_DIR/frpc" -c "$config_file" > "$test_log" 2>&1 || true
    if grep -Eq "token .*doesn.t match|authentication failed|token in login" "$test_log"; then
        echo -e "${RED}LOGIN FAILED: the auth token is wrong.${NC}"
        echo -e "${YELLOW}Get the real token from the server admin (auth.token in the server's frps.toml).${NC}"
        grep -E "ERROR|WARN" "$test_log" | head -3 || true
        rm -f "$test_log"
        return
    elif grep -Eq "proxy .*already|proxy name" "$test_log"; then
        echo -e "${RED}LOGIN FAILED: this proxy name is already used on the server.${NC}"
        echo -e "${YELLOW}Re-run option 4 and choose a different Proxy Name.${NC}"
        grep -E "ERROR|WARN" "$test_log" | head -3 || true
        rm -f "$test_log"
        return
    elif grep -Eq "connection refused|i/o timeout|dial tcp" "$test_log"; then
        echo -e "${RED}LOGIN FAILED: cannot reach the server.${NC}"
        echo -e "${YELLOW}Check Server Address/Port and that the FRP server is running.${NC}"
        grep -E "ERROR|WARN" "$test_log" | head -3 || true
        rm -f "$test_log"
        return
    elif grep -qE "try to connect|login to server success|start login success" "$test_log"; then
        echo -e "${GREEN}Connection test succeeded - login accepted by server.${NC}"
    fi
    rm -f "$test_log"

    if [[ -f "$SERVICE_FILE" ]]; then
        echo -e "${YELLOW}Restarting frp-client service...${NC}"
        systemctl daemon-reload
        systemctl restart "$SERVICE_NAME"
        echo -e "${GREEN}Service restarted.${NC}"
    else
        echo -e "${YELLOW}Creating systemd service...${NC}"
        cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=FRP Client
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/frpc -c ${config_file}
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable "$SERVICE_NAME"
        systemctl start "$SERVICE_NAME"
        echo -e "${GREEN}Service created and started.${NC}"
    fi

    sleep 2
    echo ""
    echo -e "${BLUE}=== Connection Status ===${NC}"
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}● Service is running${NC}"
    else
        echo -e "${RED}● Service failed to start${NC}"
        echo -e "${YELLOW}Check logs: journalctl -u ${SERVICE_NAME} -f${NC}"
    fi
    echo ""
}

show_status() {
    echo -e "${BLUE}=== FRP Client Status ===${NC}"
    if command -v frpc >/dev/null 2>&1; then
        echo -e "${GREEN}FRP Client:${NC} $(frpc --version 2>/dev/null || echo 'unknown')"
    else
        echo -e "${RED}FRP Client:${NC} Not installed"
    fi
    if [[ -f "$CONFIG_DIR/frpc.toml" ]]; then
        echo -e "${GREEN}Config:${NC} $CONFIG_DIR/frpc.toml"
    else
        echo -e "${RED}Config:${NC} Not found"
    fi
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}Service:${NC} Running"
    else
        echo -e "${YELLOW}Service:${NC} Stopped"
    fi
    echo ""
}

main() {
    print_banner
    show_status

    while true; do
        print_menu
        case $choice in
            1) install_frpc ;;
            2) uninstall_frpc ;;
            3) update_frpc ;;
            4) connect_to_server ;;
            5) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice. Please select 1-5.${NC}" ;;
        esac
        echo ""
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

main "$@"
