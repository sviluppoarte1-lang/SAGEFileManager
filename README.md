<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-26" src="https://github.com/user-attachments/assets/b4bfc43e-7f54-403b-b8e7-a29a5ad9ef0c" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-11" src="https://github.com/user-attachments/assets/9b411531-efa2-4e6a-a679-278eeb0761de" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-48" src="https://github.com/user-attachments/assets/db0e110e-98ef-4848-ad36-fc3c5a7e5b18" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-15" src="https://github.com/user-attachments/assets/134e5602-2ae9-410d-a37e-81115427453f" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-47" src="https://github.com/user-attachments/assets/34563e0e-9f6c-49fc-938c-b2f620db3fd2" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-00" src="https://github.com/user-attachments/assets/6c76f0a7-9354-4781-9061-d1482c14a0a0" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-39" src="https://github.com/user-attachments/assets/c3f78ec5-9f69-4449-aa97-a38c28261d3d" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-23" src="https://github.com/user-attachments/assets/dee3d066-efd0-4752-8402-68f94c283c0e" />
<img width="914" height="624" alt="Schermata del 2026-09-19 11-27-55" src="https://github.com/user-attachments/assets/cf14b8b7-8109-464b-8f20-ed431c76d3bd" />
<img width="1914" height="1034" alt="Schermata del 2026-09-19 11-27-33" src="https://github.com/user-attachments/assets/f0c952d4-cb55-43a1-ad5b-984a5151be9f" />
<img width="1397" height="1034" alt="Schermata del 2026-09-19 11-27-06" src="https://github.com/user-attachments/assets/c60e0f89-f96f-4275-b0b2-1da38a30ea6c" />

# SAGE File Manager

Full-featured desktop file manager for Linux — Flutter + Rust. Dual-pane, SMB/CIFS, FTP, NFS, trash, previews, archives, and themes.

![Version](https://img.shields.io/badge/version-1.4.5-blue) ![Flutter](https://img.shields.io/badge/Flutter-3.12-02569B) ![License](https://img.shields.io/badge/license-GPL--3.0-green) ![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)

## Features

### File Management
- **Views:** Grid, List, Details, Columns — adaptive `LayoutBuilder` grid, zoom 1–20 (slider), column-width/icon-size follow zoom
- **Dual-pane:** Split view with close button, per-pane navigation, drag & drop between panes
- **Operations:** Copy/Move/Delete with parallel engine (`parallel_copy_engine.dart` + Rust `rayon`/`copy_file_range`), hardlink dedup, skip-identical, `chmod --reference` permission preservation (ext4; best-effort on vfat/ntfs)
- **Permissions:** Preserved on HDD→HDD/USB copy (mode + timestamps via `chmod --reference`/`setLastModified`/`PermissionsExt::from_mode`)
- **Progress:** Per-file + total bytes, pause/resume, cancel. USB (`/media`/`/mnt`, `fuseblk` NTFS) now correctly treated as local — `du`/`stat` polling enabled (was misclassified as network → bar stuck at 0%)
- **Trash:** Move to trash, restore, permanent delete with parent deduplication
- **Clipboard:** System clipboard `text/uri-list` with `copy`/`cut`/`paste`

### Network
- **SMB/CIFS:** `smbclient` + `cifs-utils` (`mount.cifs`), credential store (`flutter_secure_storage` 600), polling with `smbclient` `du` fallback
- **FTP:** `curl`/`lftp` mirror (`FtpService`), virtual `ftp://`/`fm-ftp://` paths
- **NFS:** `flutter_nfs` user-space mount, `nfs://` virtual paths
- **Guard:** Network shell paths (`ftp://`, `fm-ftp://`, `fm-smb://`, `nfs://`) never touch local `File("ftp://…")` — prevents `ftp:` relative dir under `/usr/share` (was 11G; now blocked + `Directory.current = HOME`)

### Previews & Thumbnails
- **Images:** `jpg/jpeg/png/gif/bmp/webp/tiff` — 160px `instantiateImageCodec` thumbnails, `sha256` cache in `getApplicationCacheDirectory()/thumbnails` (`~/.cache/com.sagefile.manager`), 256 MB LRU, 500-entry memory cache
- **PDF:** `pdfrx` first-page render 220px
- **Office:** `microsoft_viewer` for doc/xls/ppt, fallback placeholder 1×1 PNG
- **Resilience:** Cache init probes writability; if `~/.cache` is `root:root` (prior `sudo` run), falls back to `/tmp/sage-thumbnails` so previews never break
- **UI:** Grid icons shadow-normalized (no `Transform.translate`/3D rotation), fixed `SizedBox` 64px @ zoom 8, 3-line labels

### Search & Tools
- **Find Files:** Pattern `*.mp4`, extension/name/size/date/type/system-files filters, streaming `FileSearchService`, all strings localized via `AppLocalizations`
- **Duplicate Finder / Compare Folders:** `DuplicateFinderScreen` with exact/perceptual/audio modes, `sub_window` isolate
- **Folder Organizer:** Category-based (`deb/rpm/appimage` etc.)
- **.deb Installer:** Integrated GUI (replaces `gnome-software`) — `dpkg-deb -f` info, `dpkg-query` installed check, `pkexec dpkg -i` + `apt-get install -f -y` fallback, live log. Trigger: double-click `.deb` or right-click → *Installa pacchetto*. Dialog is `showGeneralDialog` draggable (`Stack`+`Positioned`+`onPanUpdate`, clamp, `drag_indicator`)

### Terminal
- **Integrated terminal** (`integrated_terminal.dart` + `terminal_service.dart`): `script -qfec 'bash --login -i'` via `Process.start`, 45ms debounced `outputController`, `MaxOutputLines 500`
- **LED:** Prompt-driven (`pendingCommands` counter + `_endsWithShellPrompt` detecting `user@host:/path$ `), not timer — green LED on at `sendCommand`, off only when prompt returns (no 300ms/1200ms debounce)
- **Password:** `passwordProbe` detects `password:`/`passphrase:` prompts

### UI & Localization
- **Languages:** `en`/`it`/`fr`/`es`/`pt`/`de` via `lib/l10n/*.arb` + `flutter gen-l10n`; default `en`; wizard Next/Back localized
- **Themes:** `Yaru` + `Catppuccin Mocha` dark, glass `BackdropFilter` / `GlassWrapper`, system theme auto-detect (GNOME/KDE/XFCE)
- **Sidebar:** `SliverReorderableList` with `ReorderableDelayedDragStartListener` (tap not swallowed by `ImmediateMultiDrag`), `contentPadding vertical:4` (was 2 + `compact` → 36px → 44px), `HitTestBehavior` fixed
- **Window:** `window_manager` transparent/hidden title bar when glass enabled; sub-windows (`transfer_operation_window`, `duplicate_finder`, `file_search`) read `SharedPreferences(language)` — no longer platform locale mismatch

### Packaging
- **Deb:** `build_deb.sh` → `/usr/bin/sage-file-manager` now `cd "$HOME" || cd /tmp` + `exec /usr/share/...` (was `cd /usr/share` → relative `ftp:` bug), `LD_LIBRARY_PATH` for `libfilemanager_rust.so`
- **AppImage:** `build_appimage.sh` via `appimagetool`
- **Install docs:** `LICENSE` GPL-3.0, `README.md`, `com.sagefile.manager.desktop`

## Installation

### From .deb
```bash
./build_deb.sh
sudo dpkg -i build/deb/sage-file-manager_1.4.5_amd64.deb
```

### AppImage
```bash
./build_appimage.sh
./build/sage-file-manager-1.4.5-x86_64.AppImage
```

### From source
```bash
flutter pub get
cargo build --release --manifest-path rust/Cargo.toml
cp rust/target/release/libfilemanager_rust.so build/linux/x64/release/bundle/lib/
flutter build linux
./build/linux/x64/release/bundle/sage-file-manager
```

Dependencies: `libgtk-3-0 libsecret-1-0 libnotify4 libgdk-pixbuf2.0-0 libblkid1 liblzma5` · Recommends: `cifs-utils avahi-utils smbclient samba-common-bin` · Build: `ninja clang pkg-config libgtk-3-dev libsecret-1-dev libnotify-dev libgstreamer1.0-dev`

## Usage

Double-click folder to navigate, file to open via `xdg-open`/`DesktopLauncherService`; right-click for *Copy/Move/Compress/Extract/Installa pacchetto/Properties*; `F1` Find Files; split view via toolbar; terminal at bottom (`Type a command...`); `.deb` double-click → draggable installer dialog (move via header).

## Development

```
flutter analyze lib/services/file_service.dart lib/services/thumbnail_cache_service.dart
cargo test  # rust
flutter test
```

Key services: `parallel_copy_engine.dart`, `file_service.dart`, `thumbnail_cache_service.dart`, `ftp_service.dart`, `network_browser_service.dart`, `terminal_service.dart`, `deb_installer_service.dart`.

## License

GPL-3.0 — see [LICENSE](LICENSE) / [LICENSE.md](LICENSE.md).
