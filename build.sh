#!/bin/bash

set -e

echo "🔧 VPN Unlimited Linux Fix - Build Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
ORIGINAL_URL="https://www.vpnunlimited.com/api/keepsolid/vpn-download?platform=linux-mint"
ORIGINAL_FILE="vpn-unlimited-original.deb"
EXTRACT_DIR="vpn-unlimited-extracted"
OUTPUT_FILE="vpn-unlimited-9.0.1-fixed.deb"

echo -e "${YELLOW}Step 1:${NC} Downloading original package..."
if [ -f "$ORIGINAL_FILE" ]; then
    echo "  ✓ Original package already exists, skipping download"
else
    wget -O "$ORIGINAL_FILE" "$ORIGINAL_URL"
    echo -e "  ${GREEN}✓${NC} Downloaded"
fi
echo ""

echo -e "${YELLOW}Step 2:${NC} Extracting package..."
if [ -d "$EXTRACT_DIR" ]; then
    echo "  ! Removing existing extraction directory"
    rm -rf "$EXTRACT_DIR"
fi
mkdir -p "$EXTRACT_DIR"
dpkg-deb -R "$ORIGINAL_FILE" "$EXTRACT_DIR"
echo -e "  ${GREEN}✓${NC} Extracted"
echo ""

echo -e "${YELLOW}Step 3:${NC} Modifying dependencies..."
CONTROL_FILE="$EXTRACT_DIR/DEBIAN/control"

# Backup original control file
cp "$CONTROL_FILE" "$CONTROL_FILE.backup"

# Remove problematic dependencies using sed
sed -i 's/libqt5webkit5 ([^)]*), //g' "$CONTROL_FILE"
sed -i 's/, libllvm13 | libllvm14 | libllvm15//g' "$CONTROL_FILE"
sed -i 's/Recommends: libstrongswan-extra-plugins, libllvm13/Recommends: libstrongswan-extra-plugins/g' "$CONTROL_FILE"

echo "  Changes made:"
echo "    - Removed libqt5webkit5 dependency"
echo "    - Removed libllvm13/14/15 dependency"
echo -e "  ${GREEN}✓${NC} Modified"
echo ""

echo -e "${YELLOW}Step 4:${NC} Rebuilding package..."
dpkg-deb -b "$EXTRACT_DIR" "$OUTPUT_FILE" 2>&1 | grep -v "warning:" || true
echo -e "  ${GREEN}✓${NC} Package rebuilt: $OUTPUT_FILE"
echo ""

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "To install the fixed package, run:"
echo "  sudo dpkg -i $OUTPUT_FILE"
echo ""
echo "If you encounter dependency issues, run:"
echo "  sudo apt install -f"
echo ""
