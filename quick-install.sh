#!/bin/bash
#
# VPN Unlimited Linux Fix - Quick Installer
# https://github.com/guleifanger/vpn-unlimited-linux-fix
#
# Usage:
#   wget -qO- https://raw.githubusercontent.com/guleifanger/vpn-unlimited-linux-fix/main/quick-install.sh | sudo bash
#   OR
#   curl -fsSL https://raw.githubusercontent.com/guleifanger/vpn-unlimited-linux-fix/main/quick-install.sh | sudo bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  VPN Unlimited Linux Fix - Quick Installer            ║${NC}"
echo -e "${BLUE}║  https://github.com/guleifanger/vpn-unlimited-linux-fix${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ Error: This script must be run as root${NC}"
    echo "Please run with sudo:"
    echo "  wget -qO- https://raw.githubusercontent.com/guleifanger/vpn-unlimited-linux-fix/main/quick-install.sh | sudo bash"
    exit 1
fi

RELEASE_URL="https://github.com/guleifanger/vpn-unlimited-linux-fix/releases/download/v9.0.1-fix.2"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

cd "$TEMP_DIR"

echo -e "${YELLOW}[1/5]${NC} Downloading VPN Unlimited fixed package..."
wget -q --show-progress "$RELEASE_URL/vpn-unlimited-9.0.1-fixed.deb" || {
    echo -e "${RED}✗ Failed to download package${NC}"
    exit 1
}
echo -e "${GREEN}✓${NC} Package downloaded"
echo ""

echo -e "${YELLOW}[2/5]${NC} Installing VPN Unlimited..."
if dpkg -l | grep -q vpn-unlimited 2>/dev/null; then
    echo -e "${BLUE}ℹ${NC} VPN Unlimited already installed, upgrading..."
fi
dpkg -i vpn-unlimited-9.0.1-fixed.deb 2>/dev/null || true
apt-get install -f -y -qq 2>&1 | grep -v "^Reading" | grep -v "^Building" || true
echo -e "${GREEN}✓${NC} VPN Unlimited installed"
echo ""

echo -e "${YELLOW}[3/5]${NC} Downloading and installing DNS fix..."
wget -q "$RELEASE_URL/vpnu_update-resolv-conf-fixed" -O /usr/sbin/vpnu_update-resolv-conf.new || {
    echo -e "${RED}✗ Failed to download DNS fix${NC}"
    exit 1
}

# Backup original
if [ -f "/usr/sbin/vpnu_update-resolv-conf" ]; then
    cp /usr/sbin/vpnu_update-resolv-conf /usr/sbin/vpnu_update-resolv-conf.backup 2>/dev/null || true
fi

mv /usr/sbin/vpnu_update-resolv-conf.new /usr/sbin/vpnu_update-resolv-conf
chmod +x /usr/sbin/vpnu_update-resolv-conf
echo -e "${GREEN}✓${NC} DNS fix installed"
echo ""

echo -e "${YELLOW}[4/5]${NC} Setting up daemon service..."
wget -q "$RELEASE_URL/vpn-unlimited-daemon.service" -O /etc/systemd/system/vpn-unlimited-daemon.service || {
    echo -e "${RED}✗ Failed to download service file${NC}"
    exit 1
}
systemctl daemon-reload
systemctl enable vpn-unlimited-daemon.service --quiet
echo -e "${GREEN}✓${NC} Service configured"
echo ""

echo -e "${YELLOW}[5/5]${NC} Starting VPN daemon..."
mkdir -p "/tmp/VPN Unlimited"
chmod 700 "/tmp/VPN Unlimited"
systemctl restart vpn-unlimited-daemon.service
sleep 2

if systemctl is-active --quiet vpn-unlimited-daemon.service; then
    echo -e "${GREEN}✓${NC} Daemon is running"
else
    echo -e "${YELLOW}!${NC} Daemon may need manual start (run: sudo systemctl restart vpn-unlimited-daemon)"
fi
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               ✅ Installation Complete!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "You can now:"
echo "  1. Open 'VPN Unlimited' from your applications menu"
echo "  2. Connect to a VPN server"
echo "  3. Enjoy secure internet with working DNS!"
echo ""
echo "Troubleshooting:"
echo "  • Check daemon: sudo systemctl status vpn-unlimited-daemon"
echo "  • View logs: journalctl -u vpn-unlimited-daemon -f"
echo ""
echo "Documentation: https://github.com/guleifanger/vpn-unlimited-linux-fix"
echo ""
