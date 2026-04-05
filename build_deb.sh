#!/bin/bash

# Script per generare pacchetto .deb per Ubuntu/Debian

set -e

# Snap Flutter can leave CMAKE_MAKE_PROGRAM pointing at a missing ninja under
# /snap/flutter/... Exporting a real ninja from PATH fixes CMake configuration.
if ! command -v ninja >/dev/null 2>&1; then
  echo "ERROR: ninja not found. Install it, e.g.: sudo apt install ninja-build cmake clang pkg-config libgtk-3-dev" >&2
  exit 1
fi
export CMAKE_MAKE_PROGRAM="$(command -v ninja)"

APP_NAME="sage-file-manager"
DESKTOP_ID="com.sagefile.manager"
VERSION="1.0.0"
ARCH="amd64"
# Upstream metadata (also in README.md and .desktop)
UPSTREAM_NAME="SAGE File Manager"
HOMEPAGE="https://github.com/sviluppoarte1-lang/SAGEFileManager"
BUILD_DIR="build/linux/x64/release/bundle"
DEB_DIR="build/deb"
PACKAGE_DIR="$DEB_DIR/${APP_NAME}_${VERSION}_${ARCH}"
DOC_DIR="usr/share/doc/${APP_NAME}"

echo "Building Flutter app..."
flutter build linux --release

echo "Creating DEB package structure..."
rm -rf "$DEB_DIR"
mkdir -p "$PACKAGE_DIR/DEBIAN"
mkdir -p "$PACKAGE_DIR/usr/bin"
mkdir -p "$PACKAGE_DIR/usr/share/applications"
mkdir -p "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PACKAGE_DIR/usr/share/${APP_NAME}"
mkdir -p "$PACKAGE_DIR/${DOC_DIR}"

echo "Copying files..."
cp -r "$BUILD_DIR"/* "$PACKAGE_DIR/usr/share/${APP_NAME}/"
# Rimuove eventuale .desktop nel bundle (build precedenti / altre toolchain).
rm -rf "$PACKAGE_DIR/usr/share/${APP_NAME}/share/applications"
cp "assets/icons/fileman.png" "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps/${DESKTOP_ID}.png"

# Create launcher script
cat > "$PACKAGE_DIR/usr/bin/${APP_NAME}" << EOF
#!/bin/bash
cd /usr/share/${APP_NAME}
exec ./${APP_NAME} "\$@"
EOF
chmod +x "$PACKAGE_DIR/usr/bin/${APP_NAME}"

# Create desktop file
cat > "$PACKAGE_DIR/usr/share/applications/${DESKTOP_ID}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${UPSTREAM_NAME}
GenericName=File Manager
Comment=Dual-pane file manager with SMB/LAN, trash, previews, and themes
Exec=/usr/bin/${APP_NAME} %F
Icon=${DESKTOP_ID}
StartupNotify=true
StartupWMClass=${APP_NAME}
Terminal=false
Categories=System;FileManager;
MimeType=inode/directory;
EOF

# Optional: short README in package doc dir
if [[ -f README.md ]]; then
  cp README.md "$PACKAGE_DIR/${DOC_DIR}/README.md"
fi

# Machine-readable copyright (Debian copyright-format 1.0)
cat > "$PACKAGE_DIR/${DOC_DIR}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${UPSTREAM_NAME}
Upstream-Contact: https://github.com/sviluppoarte1-lang/SAGEFileManager/issues
Source: ${HOMEPAGE}

Files: *
Copyright: 2026 ${UPSTREAM_NAME} and contributors
License: unknown
 The upstream license is defined in the source repository at ${HOMEPAGE}.
 This binary package is built from that source; refer to the repository
 for full license text.
EOF

# Create control file
cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: libgtk-3-0, libblkid1, liblzma5
Recommends: cifs-utils, avahi-utils, smbclient, samba-common-bin
Maintainer: ${UPSTREAM_NAME} <${HOMEPAGE}/issues>
Homepage: ${HOMEPAGE}
Description: ${UPSTREAM_NAME} — desktop file manager for Linux (Flutter)
 ${UPSTREAM_NAME} is a desktop file manager with list, grid, and details
 views, optional dual-pane (split) layout, SMB/LAN browsing, trash with
 restore, previews (images, PDF, common office formats), archive
 extraction (ZIP, RAR, TAR.GZ, 7Z), smart copy/skip identical files,
 themes, and optional tools for package listing/uninstall and update
 checks across common Linux package stacks (APT, Snap, Flatpak, etc.).
 .
 Official source repository and releases:
   ${HOMEPAGE}
 .
 Install path: /usr/share/${APP_NAME}/ — launcher: /usr/bin/${APP_NAME}
 Documentation: /usr/share/doc/${APP_NAME}/ (README.md, copyright)
EOF

# Create postinst script
cat > "$PACKAGE_DIR/DEBIAN/postinst" << EOF
#!/bin/bash
update-desktop-database
EOF
chmod +x "$PACKAGE_DIR/DEBIAN/postinst"

echo "Building DEB package..."
dpkg-deb --build "$PACKAGE_DIR"

echo "DEB package created: ${PACKAGE_DIR}.deb"
