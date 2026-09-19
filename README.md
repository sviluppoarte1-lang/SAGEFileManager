
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-26" src="https://github.com/user-attachments/assets/b4bfc43e-7f54-403b-b8e7-a29a5ad9ef0c" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-31-11" src="https://github.com/user-attachments/assets/9b411531-efa2-4e6a-a679-278eeb0761de" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-48" src="https://github.com/user-attachments/assets/db0e110e-98ef-4848-ad36-fc3c5a7e5b18" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-30-15" src="https://github.com/user-attachments/assets/134e5602-2ae9-410d-a37e-81115427453f" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-47" src="https://github.com/user-attachments/assets/34563e0e-9f6c-49fc-938c-b2f620db3fd2" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-29-00" src="https://github.com/user-attachments/assets/6c76f0a7-9354-4781-9061-d1482c14a0a0" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-39" src="https://github.com/user-attachments/assets/c3f78ec5-9f69-4449-aa97-a38c28261d3d" />
<img width="953" height="1036" alt="Schermata del 2026-09-19 11-28-23" src="https://github.com/user-attachments/assets/dee3d066-efd0-4752-8402-68f94c283c0e" />
<img width="914" height="624" alt="Schermata del 2026-09-19 11-27-55" src="https://github.com/user-attachments/assets/cf14b8b7-8109-464b-8f20-ed431c76d3bd" />

**SAGE File Manager — v1.4.5**

SAGE File Manager is a modern, full-featured desktop file manager for Linux, built with Flutter + Rust. It combines multi-view browsing, advanced search, previews, split-view, SMB/LAN support, theming and optimized file operations in a single native experience. Version **1.4.5** is a major quality, performance and usability release focused on speed, reliability and terminal integration.

---

### Overview

v1.4.5 delivers what users asked for most: **faster startup, a lag-free sidebar, instant close, and a reliable integrated terminal**. While no single feature defines this release, every core path has been audited — from `main()` initialization to directory watching and window close — resulting in a noticeably smoother experience on both fast SSDs and slow network mounts.

### What's New in 1.4.5

#### 1. Performance & Startup

The entire startup pipeline was parallelized and de-bottlenecked:

- **Parallel initialization:** `LoggingService`, `GlassTheme`, `FolderIconService`, `SettingsService`, `LocalNotifier` and `DesktopSessionService` now start with `Future.wait()` after `windowManager.ensureInitialized()`, instead of 10 sequential `await`s. Estimated saving **80-250 ms** on cold start.
- **SharedPreferences cache:** Introduced `PrefsCache` singleton, eliminating 6-7 redundant `SharedPreferences.getInstance()` round-trips per launch. Folder colors are now cached in-memory (`Map<String,int?>`) instead of N× async reads per sidebar rebuild.
- **Faster standard folders & disks:** `FileService.getStandardDirectories()` now checks `Desktop/Documents/Pictures/Music/Videos/Downloads` in parallel. `FileService.getMountedDisks()` collects `df` candidates and resolves `lsblk/blkid` labels in parallel with 800 ms per-disk timeouts (was serial, 300-800 ms → ~40 ms parallel).
- **Batched initState:** `_FileManagerScreenState` no longer floods the main isolate with 6 independent `setState`s. A new `_batchLoadFastPrefs()` loads favorites, preferences, window geometry and caches from a single `SharedPreferences` instance via `Future.wait()`, and defers the heavy `getMountedDisks()` scan to `addPostFrameCallback` so the first frame paints immediately.
- **Cache init parallelized:** `ThumbnailCacheService` and `AppImageIconService` now initialize concurrently.

Result: faster first paint, no sidebar spinner hang on slow `df`/NFS mounts, and far fewer rebuilds in the first 500 ms.

#### 2. Left Sidebar — No More Lag

- **Parallel data load:** `Sidebar._loadData()` now awaits `Future.wait([getStandardDirectories, getMountedDisks, SharedPreferences])` in one shot (was waterfall).
- **Icon cache:** Folder colors are served from memory; no more `FutureBuilder` thrashing on every theme/reorder tick.
- **Icon decoding optimized:** Thumbnail `Image.file` now uses `cacheWidth/cacheHeight = size * devicePixelRatio` via `RepaintBoundary`, avoiding full-resolution 50MP decode for 64px previews.

#### 3. Integrated Terminal — Always Active

The embedded terminal was rebuilt for real-world use:

- **Autocomplete always on:** `compgen` now completes the **last word** only (e.g. `cd /ho` → `/home/` completes `/ho`, not the whole `cd /ho` string). Works for both files and folders, and is triggered via debounced `onInputChanged`.
- **Tab completion fixed:** Same last-word extraction for Tab.
- **Focus stays alive:** A `Focus.onKeyEvent` wrapper on the terminal redirects any key press back to the input field when the output area has focus. Clicking the output still allows text selection, but typing never loses the cursor.
- **Copy & Select All fixed:** The right-click menu `Copy` was reading *from* the clipboard. It now reads the actual `TextSelection` from `SelectableText.rich` via `onSelectionChanged` and copies `text.substring(start,end)`. `Select all` was missing and is now implemented.
- **Busy-aware close:** See below.

#### 4. Window Close Safety

Closing the manager while the internal terminal is busy now warns the user:

- `TerminalService` tracks busy state per instance with a 1200 ms debounce timer and a `ValueNotifier<bool> busyNotifier`, plus async child-process detection (`ps --ppid` / `pgrep -P` with 400 ms timeouts for silent commands like `sleep`).
- `main.dart` hooks `busyNotifier` and `onInstancesChanged` to `windowManager.setPreventClose()`. `_handleWindowClose()` awaits `hasBusyTerminalAsync()` (800 ms timeout fallback) and shows a dedicated localized dialog:
  - *“Terminal operation in progress — A command is still running in the internal terminal. Closing may interrupt it. Continue?”* (EN/IT/FR/DE/ES/PT).
  - Mixed copy+terminal state shows combined message. Idle terminal closes instantly with no warning.

#### 5. Tools Menu — Terminal Icon Restored

- **Bug:** `Strumenti → Apri terminale interno (F4)` used `assets/icons/terminal.png` which existed on disk (64×64) but was not declared in `flutter.assets` in `pubspec.yaml`. The top menu via `Image(AssetImage)` without `errorBuilder` showed a blank/broken image; the empty-space menu via `CompactMenuRow` fell back to a generic `Icons.terminal`.
- **Fix:** Declared `assets/icons/terminal.png` in `pubspec.yaml` and made `_mapMenuItemsToWidgets()` use `Image.asset(..., errorBuilder: Icon(Icons.image_not_supported))` for resilience.

#### 6. File Operations & Reliability

- **Copy/Move bug fixed:** Removed silent fallback that copied the *parent* directory when the source file was missing (`main.dart` `_copyFile` / `_moveFile`).
- **Delete deduplication:** `_deleteMultipleFiles` now deduplicates parent/child selections (deleting a folder and its child no longer shows the parent twice) and shows the parent path in `delete_operation_window.dart`.
- **.desktop support:** `FileService.isDesktopFile()` / `isDesktopFileSync()` detect `[Desktop Entry]` headers. `FileInfo.isDesktopFile` added, populated in `_getFileInfoAsync()`, icon rendered via `file_icon_service`, `Type` column shows “Program” in `file_list.dart`, `file_properties.dart`, `file_properties_tabs.dart`, `quick_look.dart`, and double-click launches via `xdg-open` before ELF check. Localized in 6 languages.

#### 7. Generic Reliability & Resource Management

- **Window IPC** (`/tmp/sage-fm-ipc`) polling changed from `listSync/readAsStringSync` every 2s on the main isolate to `await dir.list()` + `await file.readAsString()` async.
- **Transfer progress timers** coalesced from 300 ms/500 ms to 500 ms/1000 ms to reduce I/O storm during copy.
- **Leaks fixed:** `AudioPlayerWidget` now stores and cancels `onPlayerState/onPosition/onDuration` subscriptions; `main.dart` stores `_selectionSub` / `_secondPaneSelectionSub` and cancels on `dispose`.
- **Glass/transparency:** `GlassTheme.isEnabled` now guards `BackdropFilter` in `navigation_bar.dart` (extracted `_buildBarContent()`) and `main.dart` scaffold, avoiding an always-on blur even when disabled.

#### 8. Code Health

- Removed duplicate import in `file_list.dart`, unused `Seek` import, 4 unused Rust dependencies in `Cargo.toml`, 13 dead Rust symbols in `lib.rs`, cleaned `rust_ffi.dart` typedefs. Both `cargo check` and `flutter analyze` pass clean (0 new errors).

---

### Technical Details

- **Stack:** Flutter (Impeller/OpenGL ES, GTK3 embedder), Rust FFI, `window_manager`, `shared_preferences`, `yaru`, `pdfrx`, `flutter_svg`.
- **I/O model:** All heavy work (disk enumeration, thumbnail generation, archive, duplicate finder) is isolated where possible; v1.4.5 moves more to `Future.wait` / async and reduces synchronous `*Sync` calls on the UI thread.
- **Localization:** EN, IT, FR, DE, ES, PT fully updated for new strings (`fileListTypeProgram`, `dialogCloseWhileTerminalTitle/Body`).
- **Platform:** Linux-first, X11 + Wayland, tested on Mesa/Gallium (NVIDIA/AMD/Intel).

**Upgrade is recommended for all users.** v1.4.5 makes SAGE feel instant on open, stable on close, and finally makes the integrated terminal a true daily driver — not a secondary widget.
