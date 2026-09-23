# Changelog

All notable changes to SAGE File Manager. Version `1.4.5+1`.

## [1.4.5] — 2026-09-20

### Fixed — Dialog translations & locale
- `lib/widgets/file_search_dialog.dart`, `lib/main.dart`, `lib/multi_window_app.dart` — hardcoded `'Find Files'`/`'Search'`/`'Open in new window'` → `l10n.searchToolbarLabel`/`searchOpenNewWindow`/`findFilesWindowTitle`
- `lib/widgets/transfer_operation_window.dart`, `transfer_dialog.dart`, `transfer_progress_window.dart` — Italian hardcodes `Sposta file`/`Copia file`/`spostati`/`copiati`/`errori` → `l10n.copyFilesTitle`/`moveFilesTitle`/`copyInProgress`/`moveInProgress`/`itemsCopied`/`itemsMoved`/`transferErrors`/`resumeTooltip`/`pauseTooltip`/`minimizeTooltip`/`pausedLabel`
- `lib/l10n/app_{en,it,fr,es,pt,de}.arb` — added 18 keys with translations; `flutter gen-l10n`
- `lib/multi_window_app.dart` `SubWindowApp` (Stateless→Stateful) + `lib/main.dart::_runSubWindow` — sub-windows now read `SharedPreferences(language)` via `_localeFromSubWindow` instead of `platformDispatcher.locales` (was `it` even when user set `en`)

### Packaging
- Removed `snap/snapcraft.yaml` — classic confinement rejected; distribution is AppImage-only (`build/sage-file-manager-1.4.5-x86_64.AppImage` 24 MB)

### UI — Sidebar, Grid, Dialog
- `lib/widgets/file_icon_service.dart` — removed `Transform.translate` offset from PNG icons
- `lib/widgets/file_list.dart` — removed 3D `rotateX/Y` from `_build3DIconWidget`; `gridIconSize = iconSize*(0.75+zoomT*0.68)` → 64px @ zoom 8; font 14px; `SizedBox` fixed; `desiredCellWidth = gridIconSize*2 clamp 120–240` → ~7 columns; `adaptiveMaxLines=3`, `cellHeight=gridIconSize+64`; `LayoutBuilder` adaptive grid; column view zoom (`colWidth`/`itemExtent`); responsive height fallback
- `lib/widgets/sidebar.dart` — removed `dense:true`+`VisualDensity.compact` from all `ListTile` (`_buildPathItem`, `_buildFilePathItem`, `_buildDiskItem`, `_buildNetworkItem`, Applications/Computer, server shares); `vertical:2→4` (~36→44px). `ReorderableDragStartListener` → `ReorderableDelayedDragStartListener` (tap no longer swallowed by `ImmediateMultiDragGestureRecognizer`)

### Terminal — LED
- `lib/services/terminal_service.dart` — removed 300ms widget + 1200ms service debounce timers. Added `pendingCommands` counter + `_endsWithShellPrompt` (detects `user@host:/path$ `, ignores `>` continuation and `password:`). `sendCommand` +1, prompt −1, idle only when 0. `isBusy`/`busyNotifier` now prompt-driven.
- `lib/widgets/integrated_terminal.dart` — `_isBusy` now mirrors `service.isBusy` via `_syncBusyFromService`; immediate LED on `_onSubmit`, off only on prompt return; added `_processExitSub` `onDone` → LED off on `bash` exit

### File Properties
- `lib/utils/file_utils.dart` — `diskUsageBytesOne(path,{timeout:30s})`; parses `stdout` even on `exitCode!=0` (was `return null` on `Permission denied` → `0 B`), partial total preserved
- `lib/widgets/file_properties.dart` — `_calculateLocalFolderSize` timeout 30s→10m for home (2 TB cold `du -sb` >30s)

### FTP 11 GB anomaly (`/usr/share/sage-file-manager/ftp:`)
- Root cause: `/usr/bin/sage-file-manager` did `cd /usr/share/sage-file-manager`; any `File("ftp://…")` relative (e.g. thumbnail `File("ftp://host/path.jpg").exists()`) resolved to `ftp:` under `/usr/share` → `lftp mirror` created `ftp:/ftpshare:ipnosis@100.73.133.87/dati/Marco` (11G)
- Fix `lib/main.dart:341` — `Directory.current = HOME` at startup (before `WidgetsFlutterBinding`)
- Fix `lib/services/thumbnail_cache_service.dart` — `generateThumbnailForFile/Pdf` and `generateThumbnailsForBatch` early-return for `ftp://`/`fm-ftp://`/`fm-smb://`/`smb://`/`nfs://`/`smb-share://` (no `File("ftp://…")`); `isNetworkShell` guard
- Fix `lib/services/ftp_service.dart:212,186` — `downloadDirectory`/`downloadFileWithProgress` reject non-absolute or `/usr/share` `localDir`/`localPath` with warning
- Fix `build_deb.sh:159` + `/usr/bin/sage-file-manager` — `cd "$HOME" 2>/dev/null || cd /tmp; exec /usr/share/.../sage-file-manager "$@"` (was `cd /usr/share` + `exec ./`)
- Cleanup: `rm -rf "/usr/share/sage-file-manager/ftp:"` (was `workstation:workstation`, no sudo needed)

### Thumbnails / Preview regression
- Symptom: icons no longer previewed — `~/.cache/com.sagefile.manager/thumbnails` was `root:root 755` after prior `sudo` run → `workstation` could not write
- Fix `lib/services/thumbnail_cache_service.dart:28` — `initialize()` probes writability (`.wtest_*`); on failure falls back to `Directory.systemTemp/sage-thumbnails` (`/tmp/sage-thumbnails`) so previews never break; `flutter build linux` OK

### Integrated .deb Installer (replaces gnome-software)
- New `lib/services/deb_installer_service.dart` — `dpkg-deb -f` parsing (`Package`/`Version`/`Architecture`/`Maintainer`/`Description`/`Depends`/`Size`...), `dpkg-query -W` installed check, `pkexec dpkg -i` + `pkexec apt-get install -f -y` fallback, live `onOutput` streaming, `DebInstallOutcome` (`success`/`authFailed`/`alreadyInstalled`/`dependencyError`)
- New `lib/widgets/deb_installer_dialog.dart` — `showGeneralDialog` (barrier `black54`, `FadeTransition`), `Stack`+`Positioned` draggable (`onPanUpdate` clamp, `drag_indicator` in header, `ModernDialogStyles`-like), info rows, dependencies monospace, orange already-installed banner, log `ListView` 120px, `FilledButton Installa`
- Integrate `lib/main.dart:2760,5998,6950` — double-click `.deb` → `DebInstallerDialog.show`; right-click `PopupMenuItem value:'install_deb'` (both panes) → same dialog; `l10n` + `desktop_launcher_service`

### Copy — Permissions & USB progress
- Permission: no `chmod`/`PermissionsExt` after `File.copy`/`create_dir_all`/`fs::copy` → umask only. Fix `rust/src/lib.rs` (`PermissionsExt`, `preserve_permissions`/`preserve_dir_permissions` after `fs::copy`/`create_dir_all`, root dir too) + `lib/services/parallel_copy_engine.dart` (`_preserveMode` via `chmod --reference` + `setLastModified` after each dir/file, `run` and `runWithRamBridge`) + `lib/services/file_service.dart` (`copyFileSmart` both branches + `copyDirectorySmartWithProgress` fallback: `chmod --reference` per file/dir + `touch --reference`/`setLastModified`)
- USB progress stuck at 0%: `_isSlowNetworkWriteDest` treated `/media/`/`/mnt/` as network; `_isNetworkWriteDestAsync` `lower.contains('fuse')` caught `fuseblk` (NTFS `ntfs-3g`) as network → `file_service.dart` took `if(isNetwork) _runCp one-shot` / skip `Timer 2500ms statSync` → `onCopyProgress` only at exit. Fix: `/media`/`/mnt` not network by themselves; `fuse` → only `fuse.sshfs`/`gvfsd-fuse`; `fuseblk`/`vfat`/`exfat` now local with `du`/`stat` polling → bar animates 0→100%

### Build
- `rust/Cargo.toml` → `cargo build --release` 8.5s; `cp libfilemanager_rust.so` then `flutter build linux` OK (105 packages newer, ignored)

## [1.3.0] — prior (README)
- Navigation bar 3D depth, PNG toolbar assets, `AppProcess` 2-min timeout, SMB progress baseline, `PackageService` fixes, system theme auto-detect, etc. (see previous README)
