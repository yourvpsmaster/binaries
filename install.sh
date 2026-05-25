#!/bin/bash

clear

echo "======================================="
echo " Método Bitel V2RAY"
echo " Creado por @yourvpsmaster en telegram"
echo "======================================="

read -p "Tunnel Domain: " TUNNELDOMAIN
read -p "NS Domain: " NSDOMAIN
read -p "V2Ray Port: " V2PORT

apt update -y
apt install wget curl net-tools dnsutils lsof -y

mkdir -p /etc/dnstt

cd /etc/dnstt

echo ""
echo "Downloading DNSTT binary..."

wget -O dnstt-server https://raw.githubusercontent.com/yourvpsmaster/dnstt-binaries/main/dnstt-server.bin

chmod +x dnstt-server

echo ""
echo "Generating Public Key..."

./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub

sleep 2

PUBKEY=$(cat /etc/dnstt/server.pub)

echo ""
echo "Stopping conflicts on port 53..."

systemctl stop systemd-resolved 2>/dev/null
systemctl disable systemd-resolved 2>/dev/null

fuser -k 53/udp 2>/dev/null

echo ""
echo "Creating DNSTT service..."

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

systemctl daemon-reload
systemctl enable dnstt
systemctl restart dnstt

ufw allow 53/udp
ufw allow $V2PORT/tcp

clear

echo "======================================="
echo " Método Bitel V2RAY"
echo " Instalado correctamente"
echo " Creado por @yourvpsmaster en telegram"
echo "======================================="
echo ""
echo "NS DOMAIN:"
echo "$NSDOMAIN"
echo ""
echo "TUNNEL DOMAIN:"
echo "$TUNNELDOMAIN"
echo ""
echo "PUBLIC KEY:"
echo "$PUBKEY"
echo ""
echo "FORWARDING:"
echo "127.0.0.1:$V2PORT"
echo ""
echo "======================================="
echo " HTTP CUSTOM CONFIG"
echo "======================================="
echo ""
echo "DNS:"
echo "8.8.8.8"
echo ""
echo "NS:"
echo "$NSDOMAIN"
echo ""
echo "Public Key:"
echo "$PUBKEY"
echo ""
echo "Port:"
echo "$V2PORT"
echo ""
echo "Network:"
echo "ws"
echo ""
echo "MTU:"
echo "1420"
echo ""
