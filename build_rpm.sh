#!/bin/bash

# Script per generare pacchetto .rpm per Fedora/RHEL

set -e

APP_NAME="sage-file-manager"
DESKTOP_ID="com.sagefile.manager"
VERSION="1.0.0"
RELEASE="1"
ARCH="x86_64"
BUILD_DIR="build/linux/x64/release/bundle"
RPM_DIR="build/rpm"
SPEC_DIR="$RPM_DIR/SPECS"
SOURCES_DIR="$RPM_DIR/SOURCES"
BUILDROOT_DIR="$RPM_DIR/BUILDROOT"

echo "Building Flutter app..."
flutter build linux --release

echo "Creating RPM package structure..."
rm -rf "$RPM_DIR"
mkdir -p "$SPEC_DIR"
mkdir -p "$SOURCES_DIR"
mkdir -p "$BUILDROOT_DIR"

echo "Creating tarball..."
tar -czf "$SOURCES_DIR/${APP_NAME}-${VERSION}.tar.gz" -C "$BUILD_DIR" .

# Create spec file
cat > "$SPEC_DIR/${APP_NAME}.spec" << EOF
Name:           ${APP_NAME}
Version:        ${VERSION}
Release:        ${RELEASE}%{?dist}
Summary:        SAGE File Manager — file manager for Linux
License:        MIT
Source0:        %{name}-%{version}.tar.gz
BuildArch:      ${ARCH}
Requires:       gtk3 libblkid liblzma

%description
Dual-pane file manager with SMB/LAN, trash restore, previews, and themes
(SAGE File Manager, application id ${DESKTOP_ID}).

%prep
%setup -q

%build
# No build needed, files are pre-built

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/${APP_NAME}
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps

cp -r * %{buildroot}/usr/share/${APP_NAME}/
rm -rf %{buildroot}/usr/share/${APP_NAME}/share/applications
cp ../../assets/icons/fileman.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/${DESKTOP_ID}.png

cat > %{buildroot}/usr/bin/${APP_NAME} << 'SCRIPT'
#!/bin/bash
cd /usr/share/${APP_NAME}
exec ./${APP_NAME} "$@"
SCRIPT
chmod +x %{buildroot}/usr/bin/${APP_NAME}

cat > %{buildroot}/usr/share/applications/${DESKTOP_ID}.desktop << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=SAGE File Manager
GenericName=File Manager
Comment=Browse files, SMB/LAN, split view, trash, and previews
Exec=/usr/bin/${APP_NAME} %F
Icon=${DESKTOP_ID}
StartupNotify=true
StartupWMClass=${APP_NAME}
Terminal=false
Categories=System;FileManager;
MimeType=inode/directory;
DESKTOP

%files
/usr/bin/${APP_NAME}
/usr/share/${APP_NAME}/*
/usr/share/applications/${DESKTOP_ID}.desktop
/usr/share/icons/hicolor/256x256/apps/${DESKTOP_ID}.png

%post
update-desktop-database

%changelog
* $(date +"%a %b %d %Y") SAGE File Manager <https://github.com> - ${VERSION}-${RELEASE}
- Package aligned with sage-file-manager binary and com.sagefile.manager desktop id
EOF

echo "Building RPM package..."
cd "$RPM_DIR"
rpmbuild --define "_topdir $(pwd)" --define "_builddir %{_topdir}/BUILD" \
         --define "_rpmdir %{_topdir}/RPMS" --define "_sourcedir %{_topdir}/SOURCES" \
         --define "_specdir %{_topdir}/SPECS" --define "_srcrpmdir %{_topdir}/SRPMS" \
         -ba SPECS/${APP_NAME}.spec

echo "RPM package created in: $RPM_DIR/RPMS/${ARCH}/"
