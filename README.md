# xcar-ubuntu-init

Universal Ubuntu Server initialization script for fresh deployments.

This script performs:
- System updates
- Timezone + NTP configuration
- SSH hardening
- UFW firewall setup
- Fail2Ban installation
- Docker + Docker Compose installation
- Cleanup

## Usage

Run the script directly:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/oxicar/xcar-ubuntu-init/main/ubuntu-init.sh)"
