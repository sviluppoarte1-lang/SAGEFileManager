
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-26" src="https://github.com/user-attachments/assets/b4bfc43e-7f54-403b-b8e7-a29a5ad9ef0c" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-11" src="https://github.com/user-attachments/assets/9b411531-efa2-4e6a-a679-278eeb0761de" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-48" src="https://github.com/user-attachments/assets/db0e110e-98ef-4848-ad36-fc3c5a7e5b18" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-15" src="https://github.com/user-attachments/assets/134e5602-2ae9-410d-a37e-81115427453f" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-47" src="https://github.com/user-attachments/assets/34563e0e-9f6c-49fc-938c-b2f620db3fd2" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-00" src="https://github.com/user-attachments/assets/6c76f0a7-9354-4781-9061-d1482c14a0a0" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-39" src="https://github.com/user-attachments/assets/c3f78ec5-9f69-4449-aa97-a38c28261d3d" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-23" src="https://github.com/user-attachments/assets/dee3d066-efd0-4752-8402-68f94c283c0e" />
<img width="914" height="624" alt="Schermata del 2026-09-19 11-27-55" src="https://github.com/user-attachments/assets/cf14b8b7-8109-464b-8f20-ed431c76d3bd" />

# SAGE File Manager — Linux file manager

Version 1.3.0 
Navigation & Toolbar Redesign 

Complete 3D depth redesign of the navigation bar: multi-layer shadows (ambient 48px + directional 28px + contact 8px + primary glow
20px), vertical gradient (95%→72% opacity), 2px primary accent bottom border, 18px border radius
Replaced icon fonts with custom 32×32 PNG assets for all toolbar buttons (back, forward, up, list, grid, details, columns, search)
preserving original colors and transparency
New _GlowNavButton, _GlowViewModeButton, _GlowSearchButton widgets with animated hover glow effects, scale transitions
(easeOutCubic), and gradient ring backgrounds
Path bar redesigned with focus-aware styling: active pane gets a primary-tinted background with matching glow shadow, inactive pane
uses subtle surfaceContainerHighest
Status bar enhanced with subtle surface gradient and soft top shadow 
Crash Fixes & Stability 
Added mounted guards in _loadFavorites and showDeleteResults to prevent state updates after disposal
Fixed StreamSubscription leak in package_manager.dart — subscriptions now cancelled in dispose()
Created AppProcess wrapper (lib/services/process_helper.dart) with default 2-minute timeout; applied to all 195 Process.run
calls across 17 files
Added .timeout() to SMB exitCode awaits (5–10 min) to prevent hanging on unresponsive shares 

SMB / Network Transfers 

Fixed pre-existing content inflating progress: upload and download operations now measure baseline destination size before starting and
subtract it from each poll result
Fixed parallel SMB upload race condition: source sizes are pre-calculated sequentially before Future.wait() so each parallel upload
receives its correct cumulative progressBaseBytes 

Progress & Localization 
Fixed multi-transfer progress cross-talk: global _copyProgress.stats is no longer the source of per-operation progress values
Replaced hardcoded 'Copying…' English string in transfer_dialog.dart with localized l10n.copyProgressTitle /
l10n.deleteProgressTitle 

Theme & UI 

Added system theme auto-detection on first launch (lib/services/system_theme_detector.dart) supporting GNOME, KDE, XFCE,
and GTK-based desktops
Consolidated duplicate parseDuFirstColumnBytes and diskUsageBytesOne functions into lib/utils/file_utils.dart
Removed redundant “>” chevron from View menu button and custom submenu items
Enhanced GlassWrapper with optional gradient, border, and boxShadow parameters
Removed duplicate imports in file_list.dart 
Under the Hood 

All Process.run calls now pass through AppProcess.run with configurable timeout
Shared utility functions return int? (null = not found), matching existing caller conventions
Theme auto-detection is only performed on first launch; the result is persisted in settings
Pre-existing file sizes are measured sequentially before parallel uploads to avoid data races

**Official repository:** [https://github.com/sviluppoarte1-lang/SAGEFileManager](https://github.com/sviluppoarte1-lang/SAGEFileManager)

## Features

### Core functionality

- **Smart copy**: Automatically detects whether files already exist at the destination by comparing size and creation time. Identical files are skipped.
- **Status bar**: Shows the number of items in the current directory and disk free/used information.
- **Left sidebar**: Home, Desktop, Documents, Pictures, Music, Videos, and Downloads; custom paths; mounted volumes (local, network, USB).
- **Full menus**: File, Edit, View, Favorites, Tools, and Help.

### Advanced tools

- **Application management**: Built-in utility to view and uninstall apps from:

  - APT (Debian/Ubuntu/Linux Mint)
  - Snap
  - Flatpak
  - GNOME (system apps)
  - Automatic dependency checks before uninstall

- **Update checker**: Checks for updates across:

  - APT
  - Snap
  - Flatpak
  - DNF (Fedora)
  - Pacman (Arch)
  - Flathub
  - GNOME
  - KDE

- **Distribution detection**: Detects the running Linux distribution and configures the appropriate backends.

### Views

- **Multiple modes**: List, grid, and details
- **Customization**: Switch view modes on the fly

### Archives

Extraction support for:

- ZIP
- RAR
- TAR.GZ
- 7Z

### Previews

Built-in preview for:

- Images: JPG, PNG, GIF, BMP, WEBP
- PDF
- Documents: DOC, DOCX, ODT
- Spreadsheets: XLS, XLSX, ODS

## Requirements

- Flutter SDK 3.10.4 or newer
- Rust (for system integration)
- Linux (tested on Debian/Ubuntu/Linux Mint)
- Appropriate permissions for file and system operations


### Debian/Ubuntu package

From the project root, after a release Linux build:

```bash
./build_deb.sh
```

The generated `.deb` includes package metadata and documentation under `/usr/share/doc/sage-file-manager/`.

## Project layout

```
lib/
├── main.dart                 # Main UI shell
├── models/                   # Data models
│   ├── file_info.dart
│   └── disk_info.dart
├── services/                 # File, packages, archives, previews, etc.
│   ├── file_service.dart
│   ├── package_service.dart
│   ├── archive_service.dart
│   └── preview_service.dart
└── widgets/                  # UI components
    ├── sidebar.dart
    ├── file_list.dart
    ├── status_bar.dart
    ├── package_manager.dart
    └── update_checker.dart

rust/
└── src/
    └── lib.rs                # Rust helpers for system operations
```

## Usage

### Navigation

- Click a folder in the sidebar to navigate
- Double-click a file to open or view it
- Use the “+” control in the sidebar to add custom paths

### Copying files

1. Select the files to copy
2. Use **File → Copy**
3. Go to the destination folder
4. Use **File → Paste**
5. Identical files are skipped automatically

### Application management

- **Tools → Uninstall/Install Apps**, or use the tools panel
- Browse installed applications
- Review dependencies before uninstalling

### Checking for updates

- **Tools → Check for updates**, or use the tools panel
- The app queries the configured package sources

### Extracting archives

- Double-click an archive
- Choose a destination folder
- Extraction runs automatically

## Notes

- Some operations require administrator privileges (`sudo`)
- For RAR and 7Z extraction, install `unrar` and `7z` on the system
- Distribution detection relies on `/etc/os-release`

## License

See the [upstream repository](https://github.com/sviluppoarte1-lang/SAGEFileManager) for license information.

## Contributing

Contributions are welcome. Please open an issue or a pull request on GitHub.
