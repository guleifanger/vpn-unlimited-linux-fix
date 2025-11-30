#!/bin/bash
#
# VPN Unlimited Zombie Process Cleanup
#
# Kills zombie vpn-unlimited-daemon processes that accumulate
# when WireGuard connections fail.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧹 VPN Unlimited Zombie Cleanup"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please run: sudo ./cleanup-zombies.sh"
    exit 1
fi

# Count zombies
ZOMBIE_COUNT=$(ps aux | grep 'vpn-unlimited-d' | grep defunct | wc -l)

if [ "$ZOMBIE_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No zombie processes found!"
    echo ""
    exit 0
fi

echo -e "${YELLOW}Found $ZOMBIE_COUNT zombie processes${NC}"
echo ""

# Kill all vpn-unlimited processes (this will clean up zombies)
echo "Killing all VPN Unlimited processes..."
pkill -9 vpn-unlimited 2>/dev/null || true
sleep 1

# Restart the daemon
echo "Restarting VPN daemon..."
systemctl restart vpn-unlimited-daemon
sleep 2

# Check if successful
NEW_ZOMBIE_COUNT=$(ps aux | grep 'vpn-unlimited-d' | grep defunct | wc -l)

if [ "$NEW_ZOMBIE_COUNT" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Cleanup complete! All zombies eliminated.${NC}"
    echo ""
    echo "You can now open VPN Unlimited and connect."
    echo ""
    echo -e "${YELLOW}TIP:${NC} Use IPsec/IKEv2 or OpenVPN protocol."
    echo "WireGuard is not supported due to directory name restrictions."
else
    echo ""
    echo -e "${YELLOW}⚠ Warning: $NEW_ZOMBIE_COUNT zombies still present${NC}"
    echo "This is normal if VPN Unlimited is currently running."
fi
echo ""
