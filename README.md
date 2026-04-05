# SAGE File Manager — Linux file manager

A full-featured Linux file manager in the spirit of Nemo-style desktop file managers, built with Flutter and Rust.

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

## Installation (from source)

1. Clone the repository:

```bash
git clone https://github.com/sviluppoarte1-lang/SAGEFileManager.git
cd SAGEFileManager
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Build the Rust components (if required by your setup):

```bash
cd rust
cargo build --release
cd ..
```

4. Run the app:

```bash
flutter run -d linux
```

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
