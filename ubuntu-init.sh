#!/bin/bash

set -e

echo "======================================="
echo " Ubuntu Initialization Script (xcar)   "
echo "======================================="

# --- Update system ---
echo "=== Updating system packages ==="
apt update && apt upgrade -y

# --- Set timezone ---
echo "=== Setting timezone to Asia/Hong_Kong ==="
timedatectl set-timezone Asia/Hong_Kong
timedatectl set-ntp true

# --- NTP Selection ---
echo "=== Configure NTP Server ==="

echo "Select an NTP server to sync time with:"
echo " 1) time.google.com"
echo " 2) ntp.ubuntu.com"
echo " 3) pool.ntp.org (Global)"
echo " 4) asia.pool.ntp.org"
echo " 5) hk.pool.ntp.org"
echo " 6) Hong Kong Observatory (stdtime.gov.hk)"
echo " 7) China NTSC (ntp.ntsc.ac.cn)"
echo " 8) Taiwan Standard Time (time.stdtime.gov.tw)"
echo " 9) Singapore NTP Pool (sg.pool.ntp.org)"
echo "10) Custom NTP server"

read -rp "Enter choice [1-10]: " ntp_choice

case "$ntp_choice" in
  1) ntp_server="time.google.com" ;;
  2) ntp_server="ntp.ubuntu.com" ;;
  3) ntp_server="pool.ntp.org" ;;
  4) ntp_server="asia.pool.ntp.org" ;;
  5) ntp_server="hk.pool.ntp.org" ;;
  6) ntp_server="stdtime.gov.hk" ;;
  7) ntp_server="ntp.ntsc.ac.cn" ;;
  8) ntp_server="time.stdtime.gov.tw" ;;
  9) ntp_server="sg.pool.ntp.org" ;;
  10)
    read -rp "Enter custom NTP server hostname: " ntp_server
    ;;
  *)
    echo "Invalid choice, defaulting to ntp.ubuntu.com"
    ntp_server="ntp.ubuntu.com"
    ;;
esac

echo "Using NTP server: $ntp_server"

# Apply NTP configuration
if grep -q "^NTP=" /etc/systemd/timesyncd.conf; then
  sed -i "s/^NTP=.*/NTP=$ntp_server/" /etc/systemd/timesyncd.conf
else
  echo "NTP=$ntp_server" >> /etc/systemd/timesyncd.conf
fi

systemctl restart systemd-timesyncd
timedatectl set-ntp true

echo "NTP server configured."

# --- Install basic tools ---
echo "=== Installing basic tools ==="
apt install -y curl wget git ufw fail2ban ca-certificates gnupg lsb-release

# --- SSH Hardening ---
echo "=== Hardening SSH ==="
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || true
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || true
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config || true
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config || true
systemctl restart sshd

# --- UFW Firewall ---
echo "=== Configuring UFW Firewall ==="
ufw allow OpenSSH
ufw --force enable

# --- Install Docker ---
echo "=== Installing Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- Cleanup ---
echo "=== Cleaning up ==="
apt autoremove -y
apt autoclean -y

echo "======================================="
echo " Initialization Complete!              "
echo "======================================="
