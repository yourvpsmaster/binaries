#!/bin/bash

clear

echo "======================================="
echo " Método Bitel V2RAY"
echo " Desinstalador DNSTT"
echo "======================================="

systemctl stop dnstt >/dev/null 2>&1
systemctl disable dnstt >/dev/null 2>&1

rm -f /etc/systemd/system/dnstt.service

systemctl daemon-reload >/dev/null 2>&1

rm -rf /etc/dnstt

systemctl enable systemd-resolved >/dev/null 2>&1
systemctl restart systemd-resolved >/dev/null 2>&1

clear

echo "======================================="
echo " DNSTT eliminado correctamente"
echo "======================================="
