#!/bin/bash

clear

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}"
echo "=============================================="
echo "         Método Bitel V2RAY"
echo "  Creado por @yourvpsmaster en telegram"
echo "=============================================="
echo -e "${NC}"

sleep 1

echo -e "${GREEN}Checking system compatibility...${NC}"
sleep 1

ARCH=$(uname -m)

if [[ "$ARCH" != "x86_64" ]]; then
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo -e "${GREEN}Detected x86_64 (amd64) architecture.${NC}"

sleep 1

echo ""
echo -e "${YELLOW}Please configure your DNSTT installation:${NC}"
echo ""

read -p "Enter full NS domain: " NSDOMAIN
read -p "Enter full tunnel domain: " TUNNELDOMAIN

V2PORT=8787

echo ""
echo -e "${GREEN}DNSTT will forward traffic to V2Ray on 127.0.0.1:${V2PORT}${NC}"

sleep 2

echo ""
echo -e "${GREEN}Installing required packages...${NC}"

apt update -y >/dev/null 2>&1
apt install wget curl lsof dnsutils net-tools -y >/dev/null 2>&1

mkdir -p /etc/dnstt

cd /etc/dnstt || exit

echo ""
echo -e "${GREEN}Checking if port 53 (UDP) is available...${NC}"

systemctl stop systemd-resolved >/dev/null 2>&1
systemctl disable systemd-resolved >/dev/null 2>&1

fuser -k 53/udp >/dev/null 2>&1

sleep 1

echo -e "${GREEN}Port 53 (UDP) is free to use.${NC}"

sleep 1

echo ""
echo -e "${GREEN}Downloading pre-compiled DNSTT server binary...${NC}"

wget -O dnstt-server https://raw.githubusercontent.com/yourvpsmaster/dnstt-binaries/main/dnstt-server.bin >/dev/null 2>&1

chmod +x dnstt-server

sleep 2

echo ""
echo -e "${GREEN}Generating cryptographic keys...${NC}"

./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub >/dev/null 2>&1

if [ ! -f server.pub ]; then
    echo ""
    echo "ERROR: Failed to generate public key."
    exit 1
fi

PUBKEY=$(cat server.pub)

echo ""
echo -e "${GREEN}Creating systemd service...${NC}"

cat > /etc/systemd/system/dnstt.service << EOF
[Unit]
Description=DNSTT Service
After=network.target

[Service]
Type=simple
ExecStart=/etc/dnstt/dnstt-server -udp :53 -privkey-file /etc/dnstt/server.key $TUNNELDOMAIN 127.0.0.1:$V2PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sleep 1

echo ""
echo -e "${GREEN}Saving configuration and starting service...${NC}"

systemctl daemon-reload >/dev/null 2>&1
systemctl enable dnstt >/dev/null 2>&1
systemctl restart dnstt >/dev/null 2>&1

sleep 2

STATUS=$(systemctl is-active dnstt)

clear

echo -e "${CYAN}"
echo "=================================================="
echo "         DNSTT Connection Details"
echo "=================================================="
echo -e "${NC}"

echo ""
echo -e " Tunnel Domain: ${GREEN}$TUNNELDOMAIN${NC}"
echo ""
echo -e " Public Key: ${GREEN}$PUBKEY${NC}"
echo ""
echo -e " Forwarding To: ${GREEN}V2Ray (port 8787)${NC}"
echo ""
echo -e " NS Record: ${GREEN}$NSDOMAIN${NC}"

echo ""

if [[ "$STATUS" == "active" ]]; then
    echo -e "${GREEN}SUCCESS: DNSTT has been installed and started!${NC}"
else
    echo "DNSTT service failed to start."
fi

echo ""
echo -e "${CYAN}============== HTTP CUSTOM SETTINGS ==============${NC}"

echo ""
echo "Enable DNS : ON"
echo "SlowDNS    : ON"
echo "V2Ray      : ON"
echo "SSL        : OFF"

echo ""
echo "DNS        : 8.8.8.8"
echo "NS         : $NSDOMAIN"
echo "Tunnel     : $TUNNELDOMAIN"
echo "PublicKey  : $PUBKEY"

echo ""
echo "V2Ray Port : 8787"
echo "Network    : ws"

echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "Your V2Ray/Xray must listen on port 8787"
echo "using VMESS/VLESS/TROJAN with WebSocket."
echo ""
