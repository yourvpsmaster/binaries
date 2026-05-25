#!/bin/bash

clear

echo "======================================="
echo " Método Bitel V2RAY"
echo " Desinstalador"
echo "======================================="

systemctl stop dnstt 2>/dev/null
systemctl disable dnstt 2>/dev/null

rm -f /etc/systemd/system/dnstt.service

systemctl daemon-reload

rm -rf /etc/dnstt

fuser -k 53/udp 2>/dev/null

systemctl enable systemd-resolved 2>/dev/null
systemctl restart systemd-resolved 2>/dev/null

ufw delete allow 53/udp 2>/dev/null

clear

echo "======================================="
echo " Método Bitel V2RAY"
echo " Eliminado correctamente"
echo "======================================="
