# Technical Documentation

## Problem Analysis

### Dependencies Issue

The VPN Unlimited 9.0.1 package declares dependencies on libraries that have been deprecated or removed from modern Linux distributions:

```
libqt5webkit5 (>= 5.15.3)
libllvm13 | libllvm14 | libllvm15
```

### Why These Dependencies Are Problematic

#### 1. libqt5webkit5

**Status:** Deprecated and removed

QtWebKit was deprecated in Qt 5.6 and completely removed from Qt 5.15+. Modern Qt applications use **QtWebEngine** instead, which is based on Chromium.

VPN Unlimited already includes QtWebEngine dependencies:
- `libqt5webenginewidgets5 (>= 5.15.3)`
- `libqt5webenginecore5`

**Evidence:** After removing the libqt5webkit5 dependency, the application GUI works perfectly, confirming it uses QtWebEngine, not QtWebKit.

#### 2. libllvm13/14/15

**Status:** Obsolete versions

Modern Ubuntu/Debian repositories only include LLVM 17+ versions:
- Ubuntu 24.04: libllvm17, libllvm18
- Ubuntu 25.04: libllvm18, libllvm19, libllvm20, libllvm21
- Debian 12: libllvm14t64, libllvm17t64

The t64 suffix indicates time64_t transition packages, which are not compatible with the original package names.

**Analysis:** The application works without these specific LLVM versions, suggesting they were likely:
- Build-time dependencies incorrectly listed as runtime dependencies
- Legacy requirements from an older build system
- Transitive dependencies that are no longer needed

## Solution Implementation

### Approach

We modify only the package metadata (DEBIAN/control file) without touching any application binaries or code.

### Changes Made

```diff
- Depends: ... libqt5webkit5 (>= 5.15.3), ... libllvm13 | libllvm14 | libllvm15, ...
+ Depends: ... (libqt5webkit5 removed), ... (libllvm removed), ...
```

### Build Process

1. **Extract**: `dpkg-deb -R original.deb extracted/`
2. **Modify**: Edit `extracted/DEBIAN/control`
3. **Rebuild**: `dpkg-deb -b extracted/ fixed.deb`

## Testing Results

### Test Environment
- **OS:** Ubuntu 25.04 (Questing)
- **Kernel:** Linux 6.17.0-7-generic
- **Architecture:** x86_64

### Functionality Testing

| Component | Status | Notes |
|-----------|--------|-------|
| Installation | ✅ Success | No dependency errors |
| GUI Launch | ✅ Success | Interface renders correctly |
| OpenVPN | ✅ Working | Connections established successfully |
| WireGuard | ✅ Working | Protocol functions normally |
| strongSwan | ✅ Working | IPSec connections work |
| Settings | ✅ Working | All configuration options accessible |
| WebEngine UI | ✅ Working | Embedded web views render properly |

### Dependencies Installed

All other declared dependencies were successfully installed:

**Qt5 Libraries (5.15.17):**
- libqt5core5t64
- libqt5gui5t64
- libqt5widgets5t64
- libqt5network5t64
- libqt5script5
- libqt5concurrent5t64
- libqt5webenginecore5
- libqt5webenginewidgets5
- libqt5quickshapes5

**VPN Components:**
- strongswan (6.0.1)
- openvpn (2.6.14)
- wireguard-tools (1.0.20210914)
- libstrongswan-extra-plugins
- libcharon-extra-plugins

**QML Modules:**
- qml-module-qtquick2
- qml-module-qtquick-controls
- qml-module-qtquick-controls2
- qml-module-qtquick-layouts
- qml-module-qtwebengine
- qml-module-qtwebchannel

**KDE/Qt Dev Libraries:**
- qtquickcontrols2-5-dev
- libkf5qqc2desktopstyle-dev
- qml-module-org-kde-qqc2desktopstyle

## Package Integrity

### What Remains Unchanged

- All binary executables (MD5/SHA256 hashes identical)
- All libraries
- All configuration files
- All resources and assets
- Application version (9.0.1)

### What Changed

Only the `DEBIAN/control` file:
- Dependency list shortened
- No changes to package description, version, or other metadata

## Verification

To verify the modified package:

```bash
# Compare file listings
dpkg-deb -c vpn-unlimited-original.deb > original-files.txt
dpkg-deb -c vpn-unlimited-fixed.deb > fixed-files.txt
diff original-files.txt fixed-files.txt  # Only timestamps differ

# Compare binaries
dpkg-deb -x vpn-unlimited-original.deb original/
dpkg-deb -x vpn-unlimited-fixed.deb fixed/
diff -r original/ fixed/  # No differences in application files
```

## Security Considerations

### Is This Safe?

**Yes**, for the following reasons:

1. **No code modification**: Only package metadata changed
2. **Dependencies met**: All actual runtime dependencies are satisfied
3. **Open source process**: Build script is public and reproducible
4. **Community tested**: Multiple users have verified functionality

### Supply Chain Security

Users can:
1. Build the package themselves using the provided script
2. Verify checksums of the original package
3. Compare binaries between original and modified packages
4. Audit the simple sed commands that modify dependencies

## Recommendations to KeepSolid

We recommend KeepSolid Inc. to:

1. **Update the package** to remove obsolete dependencies
2. **Use QtWebEngine exclusively** and remove QtWebKit references
3. **Remove LLVM version constraints** or update to accept modern versions
4. **Consider AppImage/Flatpak** for better cross-distribution compatibility
5. **Update documentation** to reflect current supported distributions

## Alternative Solutions Considered

### 1. Install Old Libraries

**Status:** Not feasible
- libqt5webkit5 requires rebuilding from deprecated source
- LLVM 13/14/15 would conflict with system LLVM
- Security risk from unmaintained libraries

### 2. Use Compatibility Layers

**Status:** Overcomplicated
- Unnecessary given the application doesn't actually need these libraries
- Would add maintenance burden

### 3. Docker/Container

**Status:** Possible but excessive
- Works but requires container overhead
- Network configuration complexity
- The dependency removal solution is simpler

## Conclusion

The modified package works perfectly because:

1. **QtWebKit is not actually used** - The app uses QtWebEngine
2. **LLVM is not needed at runtime** - Likely a packaging error
3. **All real dependencies are satisfied** - Qt5, VPN tools, QML modules all present

This fix is safe, tested, and recommended for users on modern Linux distributions.
