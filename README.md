# VPN Unlimited Linux Fix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)

Fixed VPN Unlimited package for modern Ubuntu/Debian distributions.

## 🔍 Problem

VPN Unlimited version 9.0.1 fails to install on modern Ubuntu/Debian systems due to deprecated dependencies:

- **libqt5webkit5** - Deprecated and removed from modern repositories
- **libllvm13/14/15** - Specific LLVM versions no longer available

## ✅ Solution

This repository provides a modified package that works on modern Linux distributions by removing the problematic dependencies while maintaining full functionality.

## 🚀 Quick Install

### Option 1: One-Line Install (Easiest)

```bash
wget -qO- https://raw.githubusercontent.com/guleifanger/vpn-unlimited-linux-fix/main/quick-install.sh | sudo bash
```

Or with curl:
```bash
curl -fsSL https://raw.githubusercontent.com/guleifanger/vpn-unlimited-linux-fix/main/quick-install.sh | sudo bash
```

This automatically:
- Downloads and installs the fixed package
- Applies DNS resolution fix
- Configures daemon auto-start
- Sets up all permissions

### Option 2: Clone and Install

```bash
git clone https://github.com/guleifanger/vpn-unlimited-linux-fix.git
cd vpn-unlimited-linux-fix
sudo ./install-fixes.sh
```

### Option 3: Manual Installation

```bash
# Download the fixed package
wget https://github.com/guleifanger/vpn-unlimited-linux-fix/releases/latest/download/vpn-unlimited-9.0.1-fixed.deb

# Install
sudo dpkg -i vpn-unlimited-9.0.1-fixed.deb

# Install any missing dependencies
sudo apt install -f

# Apply post-installation fixes (see below)
```

## 📦 What Was Changed?

### 1. Package Dependencies (DEBIAN/control)
- Removed `libqt5webkit5` dependency (deprecated)
- Removed `libllvm13 | libllvm14 | libllvm15` dependency (unavailable)

### 2. DNS Resolution Script
- Fixed `/usr/sbin/vpnu_update-resolv-conf` to use `systemd-resolved` instead of iptables
- Removed problematic DNS port redirection that blocked internet access
- Now uses `resolvectl` for proper DNS configuration

### 3. Daemon Service
- Created proper systemd service unit for `vpn-unlimited-daemon`
- Ensures daemon starts automatically on boot
- Improves stability and reliability

**No application code was modified.** All binaries remain unchanged and original.

## ✔️ Tested On

- ✅ Ubuntu 25.04 (Questing) - Linux 6.17.0
- ✅ Ubuntu 24.04 LTS
- ✅ Ubuntu 22.04 LTS
- ✅ Debian 12 (Bookworm)

## 🛠️ Build It Yourself

If you prefer to build the fixed package yourself:

```bash
# Clone this repository
git clone https://github.com/guleifanger/vpn-unlimited-linux-fix.git
cd vpn-unlimited-linux-fix

# Run the build script
chmod +x build.sh
./build.sh
```

The script will:
1. Download the original package
2. Extract it
3. Modify the dependencies
4. Rebuild the package

## 📋 Technical Details

### Original Error
```
dpkg: dependency problems prevent configuration of vpn-unlimited:
 vpn-unlimited depends on libqt5webkit5 (>= 5.15.3); however:
  Package libqt5webkit5 is not installed.
 vpn-unlimited depends on libllvm13 | libllvm14 | libllvm15; however:
  Package libllvm13 is not installed.
  Package libllvm14 is not installed.
  Package libllvm15 is not installed.
```

### Why This Works

The VPN Unlimited application uses QtWebEngine (not QtWebKit) for rendering, which is already included in the dependencies:
- `libqt5webenginewidgets5`
- `libqt5webenginecore5`

The LLVM dependency appears to be unnecessary for the core VPN functionality.

## ⚠️ Disclaimer

This is an **unofficial modification** created to address compatibility issues.

- The original software belongs to KeepSolid Inc.
- This repository only modifies package metadata, not the application itself
- Use at your own discretion
- For official support, contact KeepSolid: support@keepsolid.com

## 🤝 Contributing

If you've tested this on other distributions or found issues:

1. Open an issue describing your experience
2. Include your distribution version
3. Include any error messages

## 📜 License

The build script and documentation in this repository are provided under the MIT License.

The VPN Unlimited application itself is proprietary software owned by KeepSolid Inc.

## 🔗 Links

- [Official VPN Unlimited Website](https://www.vpnunlimited.com/)
- [Official Linux Downloads](https://www.vpnunlimited.com/downloads/linux)
- [KeepSolid Support](https://www.vpnunlimitedapp.com/en/support)

## 📧 Contact KeepSolid

We encourage everyone experiencing this issue to contact KeepSolid and request an updated package:
- Email: support@keepsolid.com
- Include: "Dependency issues on modern Ubuntu/Debian"

---

**Made with ❤️ by the Linux community**
