#!/bin/bash
set -e

echo "=== Updating system ==="
apt update && apt upgrade -y

echo "=== Setting timezone to Asia/Hong_Kong ==="
timedatectl set-timezone Asia/Hong_Kong

echo "=== Enabling NTP ==="
timedatectl set-ntp true

echo "=== Installing essentials ==="
apt install -y \
    curl wget git htop ufw net-tools unzip jq \
    ca-certificates gnupg lsb-release

echo "=== Hardening SSH ==="
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "=== Setting up UFW firewall ==="
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo "=== Installing Fail2Ban ==="
apt install -y fail2ban
systemctl enable --now fail2ban

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

echo "=== Adding user to docker group ==="
usermod -aG docker $SUDO_USER

echo "=== Cleaning up ==="
apt autoremove -y
apt autoclean -y

echo "=== Done! Reboot recommended ==="
