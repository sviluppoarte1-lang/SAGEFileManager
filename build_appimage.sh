#!/bin/bash

# Script per generare AppImage

set -e

APP_NAME="sage-file-manager"
DESKTOP_ID="com.sagefile.manager"
VERSION="1.0.0"
BUILD_DIR="build/linux/x64/release/bundle"
APPIMAGE_DIR="build/appimage"
APPIMAGE_NAME="${APP_NAME}-${VERSION}-x86_64.AppImage"

echo "Building Flutter app..."
flutter build linux --release

echo "Creating AppImage structure..."
rm -rf "$APPIMAGE_DIR"
mkdir -p "$APPIMAGE_DIR/AppDir/usr/bin"
mkdir -p "$APPIMAGE_DIR/AppDir/usr/share/applications"
mkdir -p "$APPIMAGE_DIR/AppDir/usr/share/icons/hicolor/256x256/apps"

echo "Copying files..."
cp -r "$BUILD_DIR"/* "$APPIMAGE_DIR/AppDir/usr/bin/"
rm -rf "$APPIMAGE_DIR/AppDir/usr/bin/share/applications"
cp "assets/icons/fileman.png" "$APPIMAGE_DIR/AppDir/usr/share/icons/hicolor/256x256/apps/${DESKTOP_ID}.png"

# Create desktop file
cat > "$APPIMAGE_DIR/AppDir/usr/share/applications/${DESKTOP_ID}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=SAGE File Manager
GenericName=File Manager
Comment=Browse files, SMB/LAN, split view, trash, and previews
Exec=${APP_NAME} %F
Icon=${DESKTOP_ID}
StartupNotify=true
StartupWMClass=${APP_NAME}
Terminal=false
Categories=System;FileManager;
MimeType=inode/directory;
EOF

# Create AppRun
cat > "$APPIMAGE_DIR/AppDir/AppRun" << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
exec "\${HERE}/usr/bin/${APP_NAME}" "\$@"
EOF
chmod +x "$APPIMAGE_DIR/AppDir/AppRun"

# Download appimagetool if not present
APPIMAGETOOL="$APPIMAGE_DIR/appimagetool-x86_64.AppImage"
if [ ! -f "$APPIMAGETOOL" ]; then
    echo "Downloading appimagetool..."
    wget -O "$APPIMAGETOOL" https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$APPIMAGETOOL"
fi

echo "Creating AppImage..."
cd "$APPIMAGE_DIR"
APPIMAGETOOL="appimagetool-x86_64.AppImage"
if "./$APPIMAGETOOL" AppDir "$APPIMAGE_NAME" 2>&1; then
    echo "AppImage created: $APPIMAGE_DIR/$APPIMAGE_NAME"
    echo "Making AppImage executable..."
    chmod +x "$APPIMAGE_NAME"
    cd ../..
    mv "$APPIMAGE_DIR/$APPIMAGE_NAME" "build/"
    echo "AppImage ready: build/$APPIMAGE_NAME"
else
    echo "AVVISO: appimagetool fallito - l'AppImage non e' stato creato automaticamente"
    echo "La struttura e' pronta in build/appimage/AppDir/"
    echo "Per creare l'AppImage manualmente:"
    echo "  cd build/appimage"
    echo "  ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir ${APP_NAME}-${VERSION}-x86_64.AppImage"
    echo ""
    echo "Nota: il file .desktop potrebbe richiedere modifiche per essere accettato da appimagetool"
    echo "Assicurarsi che il file desktop abbia i campi richiesti e l'icona corretta"
fi
