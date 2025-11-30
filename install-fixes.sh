#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 VPN Unlimited Linux Fix - Installation Script"
echo "=================================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please run: sudo ./install-fixes.sh"
    exit 1
fi

echo -e "${YELLOW}Step 1:${NC} Installing VPN Unlimited package..."
if ! dpkg -l | grep -q vpn-unlimited; then
    if [ -f "vpn-unlimited-9.0.1-fixed.deb" ]; then
        dpkg -i vpn-unlimited-9.0.1-fixed.deb || true
        apt install -f -y
        echo -e "  ${GREEN}✓${NC} Package installed"
    else
        echo -e "  ${YELLOW}!${NC} Package not found, skipping installation"
    fi
else
    echo -e "  ${GREEN}✓${NC} Package already installed"
fi
echo ""

echo -e "${YELLOW}Step 2:${NC} Fixing DNS resolution script..."
if [ -f "/usr/sbin/vpnu_update-resolv-conf" ]; then
    # Backup original
    cp /usr/sbin/vpnu_update-resolv-conf /usr/sbin/vpnu_update-resolv-conf.backup 2>/dev/null || true

    # Install fixed version
    cp vpnu_update-resolv-conf-fixed /usr/sbin/vpnu_update-resolv-conf
    chmod +x /usr/sbin/vpnu_update-resolv-conf
    echo -e "  ${GREEN}✓${NC} DNS script updated (backup saved as .backup)"
else
    echo -e "  ${RED}✗${NC} DNS script not found"
    exit 1
fi
echo ""

echo -e "${YELLOW}Step 3:${NC} Installing systemd service..."
cp vpn-unlimited-daemon.service /etc/systemd/system/vpn-unlimited-daemon.service
systemctl daemon-reload
systemctl enable vpn-unlimited-daemon.service
echo -e "  ${GREEN}✓${NC} Systemd service installed and enabled"
echo ""

echo -e "${YELLOW}Step 4:${NC} Starting VPN daemon..."
systemctl restart vpn-unlimited-daemon.service
sleep 2
if systemctl is-active --quiet vpn-unlimited-daemon.service; then
    echo -e "  ${GREEN}✓${NC} Daemon is running"
else
    echo -e "  ${YELLOW}!${NC} Daemon may not be running properly"
    echo "  Check status with: systemctl status vpn-unlimited-daemon"
fi
echo ""

echo -e "${YELLOW}Step 5:${NC} Creating IPsec directories..."
mkdir -p /etc/ipsec.d/cacerts /etc/ipsec.d/certs /etc/ipsec.d/private
chmod 755 /etc/ipsec.d /etc/ipsec.d/cacerts /etc/ipsec.d/certs
chmod 700 /etc/ipsec.d/private
echo -e "  ${GREEN}✓${NC} IPsec directories created"
echo ""

echo -e "${YELLOW}Step 6:${NC} Creating temp directory with correct permissions..."
mkdir -p "/tmp/VPN Unlimited"
chmod 700 "/tmp/VPN Unlimited"
# Set ownership to the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER:$SUDO_USER" "/tmp/VPN Unlimited"
fi
echo -e "  ${GREEN}✓${NC} Temp directory created"
echo ""

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "You can now:"
echo "  1. Open VPN Unlimited from your applications menu"
echo "  2. Connect to a VPN server"
echo "  3. Internet and DNS should work correctly"
echo ""
echo "If you encounter issues:"
echo "  - Check daemon status: systemctl status vpn-unlimited-daemon"
echo "  - View logs: journalctl -u vpn-unlimited-daemon -f"
echo "  - OpenVPN logs: tail -f '/tmp/VPN Unlimited/openvpn'*.log"
echo ""
