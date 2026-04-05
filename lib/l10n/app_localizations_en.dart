// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get menuTopFile => 'File';

  @override
  String get menuTopEdit => 'Edit';

  @override
  String get menuTopView => 'View';

  @override
  String get menuTopFavorites => 'Favorites';

  @override
  String get menuTopThemes => 'Themes';

  @override
  String get menuTopTools => 'Tools';

  @override
  String get menuTopHelp => 'Help';

  @override
  String get menuNewTab => 'Open new tab (F2)';

  @override
  String get menuNewFolder => 'New folder';

  @override
  String get menuNewTextFile => 'New text document';

  @override
  String get menuNetworkDrive => 'Connect network drive';

  @override
  String get menuBulkRename => 'Rename';

  @override
  String get menuEmptyTrash => 'Empty trash';

  @override
  String get menuExit => 'Exit';

  @override
  String get menuCut => 'Cut (Ctrl+X)';

  @override
  String get menuCopy => 'Copy (Ctrl+C)';

  @override
  String get menuPaste => 'Paste (Ctrl+V)';

  @override
  String get menuUndo => 'Undo (Ctrl+Z)';

  @override
  String get menuRedo => 'Redo (Ctrl+Y)';

  @override
  String get menuRefresh => 'Refresh (F5)';

  @override
  String get menuSelectAll => 'Select all';

  @override
  String get menuDeselectAll => 'Deselect all';

  @override
  String get menuFind => 'Find (F1)';

  @override
  String get menuPreferences => 'Preferences';

  @override
  String get snackOneFileCut => '1 item cut to clipboard';

  @override
  String snackManyFilesCut(int count) {
    return '$count items cut to clipboard';
  }

  @override
  String get snackOneFileCopied => '1 item copied to clipboard';

  @override
  String snackManyFilesCopied(int count) {
    return '$count items copied to clipboard';
  }

  @override
  String get sortArrangeIcons => 'Arrange icons';

  @override
  String get sortManual => 'Manually';

  @override
  String get sortByName => 'By name';

  @override
  String get sortBySize => 'By size';

  @override
  String get sortByType => 'By type';

  @override
  String get sortByDetailedType => 'By detailed type';

  @override
  String get sortByDate => 'By modification date';

  @override
  String get sortReverse => 'Reverse order';

  @override
  String get viewShowHidden => 'Show hidden files';

  @override
  String get viewHideHidden => 'Hide hidden files';

  @override
  String get viewSplitScreen => 'Split view (F3)';

  @override
  String get viewShowPreview => 'Show preview';

  @override
  String get viewHidePreview => 'Hide preview';

  @override
  String get viewShowRightPanel => 'Show right sidebar';

  @override
  String get viewHideRightPanel => 'Hide right sidebar';

  @override
  String get favAdd => 'Add to favorites';

  @override
  String get favManage => 'Manage favorites';

  @override
  String get themesManage => 'Theme manager';

  @override
  String get toolsPackages => 'Uninstall / install apps';

  @override
  String get toolsUpdates => 'Check for updates';

  @override
  String get toolsBulkRenamePattern => 'Bulk rename (pattern)';

  @override
  String get toolsExtractArchive => 'Extract archive';

  @override
  String get helpShortcuts => 'Keyboard shortcuts';

  @override
  String get helpUserGuide => 'User guide';

  @override
  String get helpUserGuideTitle => 'User guide';

  @override
  String get helpUserGuideBlock1 =>
      'NAVIGATION\n• Sidebar: open Home, standard folders (Desktop, Documents, …), custom paths, favorites, network locations and mounted disks. Drag rows to reorder places and favorites.\n• Toolbar and path bar: parent folder, refresh, and global search.\n• Backspace goes back in history. If enabled in Preferences, double-click empty space in the file list to go to the parent folder.\n• Double-click a folder to open it; double-click a file to open it with the default application.';

  @override
  String get helpUserGuideBlock2 =>
      'FILES AND CLIPBOARD\n• Click to select; drag a rectangle to select multiple items. Use Ctrl for multi-select and Shift for ranges. Esc deselects all.\n• Ctrl+C, Ctrl+X, Ctrl+V copy, cut and paste files. Drag selected items out of the window to copy to the desktop or other apps.\n• Right-click for the context menu (rename, delete, properties, etc.). The File and Edit menus offer the same actions.';

  @override
  String get helpUserGuideBlock3 =>
      'VIEWS AND SEARCH\n• View menu: list, grid or details; hidden files; split view (F3); preview and right panel (F6).\n• F5 refreshes the current folder. F2 opens a new window instance.\n• Tools → Find (F1) opens file search: filter by name, extension, size, type and date; search under one path or, when enabled, across mounted volumes.';

  @override
  String get helpUserGuideBlock4 =>
      'SETTINGS AND MORE\n• Favorites and Theme management in the top menu (opens the full theme editor). Preferences adjust clicks, language, compact menu, split view defaults and file-operation options.\n• Computer lists disks. Add network paths from the sidebar; the app may prompt to install tools for SMB or similar.\n• Tools: find files (F1), package manager and update checker when available.\n• Help → Keyboard shortcuts lists every shortcut; this guide summarizes the main features.';

  @override
  String get helpAbout => 'About';

  @override
  String get helpGitHubProject => 'GitHub project';

  @override
  String get helpDonateNow => 'Donate now';

  @override
  String get helpCheckAppUpdate => 'Check for app update';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'New version $version is available.';
  }

  @override
  String get appUpdateViewRelease => 'View release';

  @override
  String get appUpdateCheckFailed =>
      'Could not check for updates (network or GitHub).';

  @override
  String get appUpdateAlreadyLatest => 'You are using the latest version.';

  @override
  String get navBack => 'Back';

  @override
  String get navForward => 'Forward';

  @override
  String get navUp => 'Up';

  @override
  String get prefsGeneral => 'General';

  @override
  String get prefsSingleClickOpen => 'Single click to open';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Open files and folders with a single click';

  @override
  String get prefsDoubleClickRename => 'Double click to rename';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Rename files and folders by double-clicking the name';

  @override
  String get prefsDoubleClickEmptyUp => 'Double click empty area to go up';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Go to parent folder by double-clicking empty space';

  @override
  String get prefsLanguage => 'Language';

  @override
  String get prefsLanguageLabel => 'Interface language';

  @override
  String get prefsMenuCompactTitle => 'Compact menu';

  @override
  String get prefsMenuCompactSubtitle =>
      'Group menu items behind the three-line icon instead of the classic bar';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'CIFS mount failed: showing folders via smbclient only. Install cifs-utils and ensure you can run mount.cifs, then try again to open, copy or edit files on this share.';

  @override
  String get smbShellFileOpenUnavailable =>
      'This path is smbclient-only (no CIFS mount). Mount the share with mount.cifs or turn off the smbclient option if CIFS mounting works on your system.';

  @override
  String get prefsExecTextTitle => 'Executable text files';

  @override
  String get prefsExecAuto => 'Run automatically';

  @override
  String get prefsExecAlwaysShow => 'Always show';

  @override
  String get prefsExecAlwaysAsk => 'Always ask';

  @override
  String get prefsDefaultFmTitle => 'Default file manager';

  @override
  String get prefsDefaultFmBody =>
      'Set this file manager as the default app to open folders.';

  @override
  String get prefsDefaultFmButton => 'Set as default file manager';

  @override
  String get langItalian => 'Italian';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'French';

  @override
  String get langSpanish => 'Spanish';

  @override
  String get langPortuguese => 'Portuguese';

  @override
  String get langGerman => 'German';

  @override
  String get fileListTypeFolder => 'Folder';

  @override
  String get fileListTypeFile => 'File';

  @override
  String get fileListEmpty => 'No files';

  @override
  String get copyProgressTitle => 'Copying';

  @override
  String get copyProgressCancelTooltip => 'Cancel';

  @override
  String copySpeed(String speed) {
    return 'Speed: $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Time left: $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Items: $count';
  }

  @override
  String statusFree(String size) {
    return 'Free: $size';
  }

  @override
  String statusUsed(String size) {
    return 'Used: $size';
  }

  @override
  String statusTotal(String size) {
    return 'Total: $size';
  }

  @override
  String statusCopyLine(String source, String dest) {
    return 'Copy: $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'File: $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Operation in progress';

  @override
  String get dialogCloseWhileCopyBody =>
      'A copy or move is in progress. Closing may interrupt it. Continue?';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogOverwriteTitle => 'Replace existing item?';

  @override
  String dialogOverwriteBody(String name) {
    return '\"$name\" already exists in this folder. Replace it?';
  }

  @override
  String get dialogOverwriteReplace => 'Replace';

  @override
  String get dialogOverwriteSkip => 'Skip';

  @override
  String get dialogCloseAnyway => 'Close anyway';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRename => 'Rename';

  @override
  String get commonAdd => 'Add';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'To open this folder, use “Open as root”.';

  @override
  String get sidebarAddNetworkTitle => 'Add network location';

  @override
  String get sidebarNetworkPathLabel => 'Network path';

  @override
  String get sidebarNetworkHint => 'smb://server/share or //server/share';

  @override
  String get sidebarNetworkHelp =>
      'Examples:\n• smb://192.168.1.100/shared\n• //server/share\n• /mnt/network';

  @override
  String get sidebarBrowseTooltip => 'Browse';

  @override
  String get sidebarRenameShareTitle => 'Rename network share';

  @override
  String get sidebarRemoveShareTitle => 'Remove network share';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return 'Remove \"$name\" from the list?';
  }

  @override
  String get sidebarUnmountTitle => 'Unmount disk';

  @override
  String sidebarUnmountConfirm(String name) {
    return 'Unmount \"$name\"?';
  }

  @override
  String get sidebarUnmount => 'Unmount';

  @override
  String sidebarUnmountOk(String name) {
    return '\"$name\" unmounted';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Failed to unmount \"$name\"';
  }

  @override
  String get sidebarEmptyTrash => 'Empty trash';

  @override
  String get sidebarRemoveFromList => 'Remove from list';

  @override
  String get sidebarMenuChangeColor => 'Change color';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Change color: $name';
  }

  @override
  String get sidebarProperties => 'Properties';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Properties: $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Change folder color:';

  @override
  String get sidebarRemoveCustomColor => 'Remove custom color';

  @override
  String get sidebarChangeAllFoldersColor => 'Change all folder colors';

  @override
  String get sidebarPickDefaultColor => 'Pick a default color for all folders:';

  @override
  String get sidebarEmptyTrashTitle => 'Empty trash';

  @override
  String get sidebarEmptyTrashBody =>
      'Permanently empty the trash? This cannot be undone.';

  @override
  String get sidebarEmptyTrashConfirm => 'Empty';

  @override
  String get sidebarTrashEmptied => 'Trash emptied';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Credentials for $server';
  }

  @override
  String get sidebarGuestAccess => 'Guest (anonymous) access';

  @override
  String get sidebarConnect => 'Connect';

  @override
  String sidebarConnecting(String name) {
    return 'Connecting to $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Error connecting to $name';
  }

  @override
  String get sidebarRetry => 'Retry';

  @override
  String get copyCancelled => 'Copy cancelled';

  @override
  String get fileCopiedSuccess => 'File copied';

  @override
  String get folderCopiedSuccess => 'Folder copied';

  @override
  String get extractionComplete => 'Extraction complete';

  @override
  String snackInitError(String error) {
    return 'Initialization error: $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Removed from list: $name';
  }

  @override
  String get labelChoosePath => 'Choose path';

  @override
  String get ctxOpenTerminal => 'Open terminal';

  @override
  String get ctxNewFolder => 'New folder';

  @override
  String get ctxOpenAsRoot => 'Open as root';

  @override
  String get ctxOpenWith => 'Open with…';

  @override
  String get ctxCopyTo => 'Copy to…';

  @override
  String get ctxMoveTo => 'Move to…';

  @override
  String get ctxCopy => 'Copy';

  @override
  String get ctxCut => 'Cut';

  @override
  String get ctxPaste => 'Paste';

  @override
  String get ctxCreateNew => 'New';

  @override
  String get ctxNewTextDocumentShort => 'Text document (.txt)';

  @override
  String get ctxNewWordDocument => 'Word document (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Excel workbook (.xlsx)';

  @override
  String get ctxExtract => 'Extract';

  @override
  String get ctxExtractTo => 'Extract archive to…';

  @override
  String get ctxCompressToZip => 'Compress to .zip file';

  @override
  String snackZipCreated(Object name) {
    return 'Created archive \"$name\".';
  }

  @override
  String snackZipFailed(Object message) {
    return 'Could not create ZIP: $message';
  }

  @override
  String get ctxChangeColor => 'Change color';

  @override
  String get ctxMoveToTrash => 'Move to trash';

  @override
  String get ctxRestoreFromTrash => 'Restore to original folder';

  @override
  String get menuRestoreFromTrash => 'Restore from trash';

  @override
  String get trashRestorePickFolderTitle => 'Choose folder to restore into';

  @override
  String trashRestoreTargetExists(String name) {
    return 'Cannot restore: \"$name\" already exists at the destination.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count items restored';
  }

  @override
  String get trashRestoreFailed => 'Could not restore the selected items.';

  @override
  String dialogOpenWithTitle(String name) {
    return 'Open \"$name\" with…';
  }

  @override
  String get hintSearchApp => 'Search application…';

  @override
  String get openWithDefaultApp => 'Default application';

  @override
  String get browseEllipsis => 'Browse…';

  @override
  String get tooltipSetAsDefaultApp => 'Set as default application';

  @override
  String get openWithOpenAndSetDefault => 'Open and set as default';

  @override
  String get openWithFooterHint =>
      'Use the star or the ⋮ menu to change the default application for this file type anytime.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName set as default for $mimeType';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'Could not set default: $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'Could not open: $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Create new folder';

  @override
  String get dialogTitleNewFolder => 'New folder';

  @override
  String get labelFolderName => 'Folder name';

  @override
  String get hintFolderName => 'Enter folder name';

  @override
  String get labelFileName => 'File name';

  @override
  String get hintTextDocument => 'document.txt';

  @override
  String get buttonCreate => 'Create';

  @override
  String snackMoveError(String error) {
    return 'Error while moving: $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Change color: $name';
  }

  @override
  String get dialogPickFolderColor => 'Pick a color for the folder:';

  @override
  String get shortcutTitle => 'Keyboard shortcuts';

  @override
  String get shortcutCopy => 'Copy selected files/folders';

  @override
  String get shortcutPaste => 'Paste files/folders';

  @override
  String get shortcutCut => 'Cut selected files/folders';

  @override
  String get shortcutUndo => 'Undo last operation';

  @override
  String get shortcutRedo => 'Redo last operation';

  @override
  String get shortcutNewTab => 'Open new tab';

  @override
  String get shortcutSplitView => 'Split screen in two';

  @override
  String get shortcutRefresh => 'Refresh current folder';

  @override
  String get shortcutRightPanel => 'Show/hide right sidebar';

  @override
  String get shortcutDeselect => 'Deselect all files';

  @override
  String get shortcutBackNav => 'Go back in navigation';

  @override
  String get shortcutFindFiles => 'Find files and folders';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'File Manager';

  @override
  String get aboutTagline => 'Advanced file manager';

  @override
  String aboutVersionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get aboutAuthor => 'Author: Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Description:';

  @override
  String get aboutDescription =>
      'SAGE File Manager is a modern, full-featured file manager for Linux with multi-view, previews, themes, search, optimized copy/paste, split view, SMB/LAN support, and more.';

  @override
  String get aboutFeaturesHeading => 'Main features:';

  @override
  String get aboutFeaturesList =>
      '• Full file and folder management\n• Multiple views (list, grid, details)\n• File preview (images, PDF, documents, text)\n• Theme management (presets and customization)\n• Advanced search\n• Optimized copy/paste\n• Split view\n• Favorites and custom paths\n• Executable and script support\n• Modern UI';

  @override
  String snackDocumentCreated(String name) {
    return 'Document \"$name\" created';
  }

  @override
  String get dialogInsufficientPermissions => 'Insufficient permissions';

  @override
  String get snackFolderCreated => 'Folder created';

  @override
  String get snackTerminalUnavailable => 'Terminal not available';

  @override
  String get snackTerminalRootError => 'Could not open terminal as root';

  @override
  String get snackRootHelperMissing =>
      'Could not open as root. Install pkexec or sudo.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Open a folder first, then choose Open as root.';

  @override
  String get snackOpenAsRootBadFolder => 'That folder cannot be opened.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Error pasting $name: $error';
  }

  @override
  String get snackFileMoved => 'File moved';

  @override
  String get dialogRenameFileTitle => 'Rename';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count items selected. Enter a new name for each row.';
  }

  @override
  String get labelNewName => 'New name';

  @override
  String get snackFileRenamed => 'File renamed';

  @override
  String snackRenameError(String error) {
    return 'Rename error: $error';
  }

  @override
  String get snackRenameSameFolder =>
      'All selected items must be in the same folder.';

  @override
  String get snackRenameEmptyName => 'Each item needs a non-empty new name.';

  @override
  String get snackRenameDuplicateNames =>
      'New names must be different from each other.';

  @override
  String get snackRenameTargetExists =>
      'A file or folder with this name already exists.';

  @override
  String get snackSelectPathFirst => 'Select a path first';

  @override
  String get snackAlreadyFavorite => 'Already in favorites';

  @override
  String snackAddedFavorite(String name) {
    return 'Added to favorites: $name';
  }

  @override
  String get favoritesEmptyList => 'No favorites yet';

  @override
  String snackNewTabOpened(String name) {
    return 'New tab opened: $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Select a file or folder to create a shortcut';

  @override
  String get dialogCreateSymlinkTitle => 'Create shortcut';

  @override
  String get labelSymlinkName => 'Shortcut name';

  @override
  String get snackSymlinkCreated => 'Shortcut created';

  @override
  String get snackConnectingNetwork => 'Connecting to network…';

  @override
  String get snackNewInstanceStarted => 'New app instance started';

  @override
  String snackNewInstanceError(String error) {
    return 'Could not start new instance: $error';
  }

  @override
  String get snackSelectFilesRename => 'Select at least one file to rename';

  @override
  String get bulkRenameTitle => 'Bulk rename';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count files selected';
  }

  @override
  String get bulkRenamePatternLabel => 'Rename pattern';

  @override
  String get bulkRenamePatternHelper =>
      'Use the tokens name and num each wrapped in curly braces (see example below).';

  @override
  String get bulkRenameAutoNumber => 'Use automatic numbering';

  @override
  String get bulkRenameStartNumber => 'Starting number';

  @override
  String get bulkRenameKeepExt => 'Keep original extension';

  @override
  String trashEmptyError(String error) {
    return 'Error emptying trash: $error';
  }

  @override
  String labelNItems(int count) {
    return '$count items';
  }

  @override
  String get dialogTitleDeletePermanent => 'Delete permanently?';

  @override
  String get dialogTitleMoveToTrashConfirm => 'Move to trash?';

  @override
  String get dialogBodyPermanentDeleteOne => 'Permanently delete one item?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return 'Permanently delete $count items?';
  }

  @override
  String get dialogBodyTrashOne => 'Move one item to trash?';

  @override
  String dialogBodyTrashMany(int count) {
    return 'Move $count items to trash?';
  }

  @override
  String get snackDeletedPermanentOne => 'One item permanently deleted';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count items permanently deleted';
  }

  @override
  String get snackMovedToTrashOne => 'One item moved to trash';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count items moved to trash';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors errors';
  }

  @override
  String get dialogOpenAsRootBody =>
      'You do not have permission to create files or folders in this directory. Open the file manager as root?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Open as administrator';

  @override
  String get dialogOpenAsRootAuthBody =>
      'When you tap Continue, the system will ask for the administrator password. Only after you authenticate successfully will a new file manager window open in this folder.';

  @override
  String get dialogOpenAsRootContinue => 'Continue';

  @override
  String get paneSelectPathHint => 'Select a path';

  @override
  String get emptyFolderLabel => 'Empty folder';

  @override
  String get sidebarMountPointOptional => 'Mount point (optional)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count files renamed';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Preferences';

  @override
  String get snackPrefsSaved => 'Preferences saved';

  @override
  String get prefsNavView => 'Display';

  @override
  String get prefsNavPreview => 'Preview';

  @override
  String get prefsNavFileOps => 'File operations';

  @override
  String get prefsNavTrash => 'Trash';

  @override
  String get prefsNavMedia => 'Removable media';

  @override
  String get prefsNavCache => 'Cache';

  @override
  String get prefsDefaultFmSuccess =>
      'File manager set as default successfully.';

  @override
  String get prefsShowHiddenTitle => 'Show hidden files';

  @override
  String get prefsShowHiddenSubtitle =>
      'Show files and folders whose names start with a dot';

  @override
  String get prefsShowPreviewPanelTitle => 'Show preview panel';

  @override
  String get prefsShowPreviewPanelSubtitle =>
      'Show the preview panel on the right';

  @override
  String get prefsAlwaysDoublePaneTitle => 'Always start with split view';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Always open split view on startup';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ignore per-folder view preferences';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'Do not save view preferences for each folder';

  @override
  String get prefsDefaultViewModeTitle => 'Default view mode';

  @override
  String get prefsViewModeList => 'List';

  @override
  String get prefsViewModeGrid => 'Grid';

  @override
  String get prefsViewModeDetails => 'Details';

  @override
  String get prefsGridZoomTitle => 'Default grid zoom level';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Level: $current/10';
  }

  @override
  String get prefsFontSection => 'Font';

  @override
  String get prefsFontFamilyLabel => 'Font family';

  @override
  String get labelSelectFont => 'Select font';

  @override
  String get fontFamilyDefaultSystem => 'Default (system)';

  @override
  String get prefsFontSizeTitle => 'Font size';

  @override
  String prefsFontSizeValue(String size) {
    return 'Size: $size';
  }

  @override
  String get prefsFontWeightTitle => 'Font weight';

  @override
  String get prefsFontWeightNormal => 'Normal';

  @override
  String get prefsFontWeightBold => 'Bold';

  @override
  String get prefsFontWeightSemiBold => 'Semi-bold';

  @override
  String get prefsFontWeightMedium => 'Medium';

  @override
  String get prefsTextShadowSection => 'Text shadow';

  @override
  String get prefsTextShadowEnableTitle => 'Enable text shadow';

  @override
  String get prefsTextShadowEnableSubtitle =>
      'Add a shadow to text for readability';

  @override
  String get prefsShadowIntensityTitle => 'Shadow blur';

  @override
  String get prefsShadowOffsetXTitle => 'Shadow offset X';

  @override
  String get prefsShadowOffsetYTitle => 'Shadow offset Y';

  @override
  String get prefsShadowColorTitle => 'Shadow color';

  @override
  String prefsShadowColorValue(String value) {
    return 'Color: $value';
  }

  @override
  String get prefsShadowColorBlack => 'Black';

  @override
  String get dialogPickShadowColor => 'Pick shadow color';

  @override
  String get prefsPickColor => 'Choose color';

  @override
  String get prefsTextPreviewLabel => 'Text preview';

  @override
  String get prefsDisableFileQueueTitle => 'Disable file operation queue';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Run file operations sequentially without a queue';

  @override
  String get prefsAskTrashTitle => 'Ask before moving to trash';

  @override
  String get prefsAskTrashSubtitle =>
      'Require confirmation before moving files to trash';

  @override
  String get prefsAskEmptyTrashTitle => 'Ask before emptying trash';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Require confirmation before permanently deleting trash';

  @override
  String get prefsIncludeDeleteTitle => 'Include Delete command';

  @override
  String get prefsIncludeDeleteSubtitle =>
      'Show option to delete files without trash';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Skip trash with Delete key';

  @override
  String get prefsSkipTrashDelKeySubtitle =>
      'Delete files directly when pressing Delete';

  @override
  String get prefsAutoMountTitle => 'Auto-mount removable devices';

  @override
  String get prefsAutoMountSubtitle =>
      'Mount USB and other devices when connected';

  @override
  String get prefsOpenWindowMountedTitle => 'Open window for mounted devices';

  @override
  String get prefsOpenWindowMountedSubtitle =>
      'Automatically open a window for mounted devices';

  @override
  String get prefsWarnRemovableTitle => 'Warn when device is connected';

  @override
  String get prefsWarnRemovableSubtitle =>
      'Show notification when a removable device is connected';

  @override
  String get prefsPreviewExtensionsIntro =>
      'Choose file extensions to enable preview for:';

  @override
  String get prefsPreviewRightPanelNote =>
      'Full previews for PDF, Office, text and other types appear in the right sidebar when it is visible. If the sidebar is hidden, only image thumbnails are shown in the file list.';

  @override
  String get prefsAdminPasswordSection => 'Administrator password';

  @override
  String get prefsSaveAdminPasswordTitle => 'Save administrator password';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Save password for updates (not recommended)';

  @override
  String get labelAdminPassword => 'Administrator password';

  @override
  String get hintAdminPassword => 'Enter password';

  @override
  String get prefsCacheSectionTitle => 'Cache and previews';

  @override
  String get prefsCacheSizeTitle => 'Cache size';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Current size: $size';
  }

  @override
  String get labelNetworkShareName => 'Custom name';

  @override
  String get hintNetworkShareName => 'Enter a name for this share';

  @override
  String get sidebarTooltipRemoveNetwork => 'Remove network path';

  @override
  String get sidebarTooltipUnmount => 'Unmount disk';

  @override
  String sidebarUnmountSuccess(String name) {
    return '\"$name\" unmounted successfully';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Error unmounting \"$name\"';
  }

  @override
  String get previewSelectFile => 'Select a file for preview';

  @override
  String get previewPanelTitle => 'Preview';

  @override
  String previewPanelSizeLine(String value) {
    return 'Size: $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Modified: $value';
  }

  @override
  String get dialogErrorTitle => 'Error';

  @override
  String get propsLoadError => 'Could not load file properties';

  @override
  String get snackPermissionsUpdated => 'Permissions updated';

  @override
  String dialogEditFieldTitle(String label) {
    return 'Edit $label';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label updated successfully';
  }

  @override
  String get propsEditPermissionsTitle => 'Edit permissions';

  @override
  String get permOwner => 'Owner:';

  @override
  String get permGroup => 'Group:';

  @override
  String get permOthers => 'Others:';

  @override
  String get permRead => 'Read';

  @override
  String get permWrite => 'Write';

  @override
  String get permExecute => 'Execute';

  @override
  String get previewNotAvailable => 'Preview not available';

  @override
  String get previewImageError => 'Error loading image';

  @override
  String get previewDocLoadError => 'Error loading document';

  @override
  String get previewOpenExternally => 'Open with external viewer';

  @override
  String get previewDocumentTitle => 'Document preview';

  @override
  String get previewDocLegacyFormat =>
      '.doc is not supported. Use .docx or open with an external viewer.';

  @override
  String get previewSheetLoadError => 'Error loading spreadsheet';

  @override
  String get previewSheetTitle => 'Spreadsheet preview';

  @override
  String get previewXlsLegacyFormat =>
      '.xls is not supported. Use .xlsx or open with an external viewer.';

  @override
  String get previewPresentationLoadError => 'Error loading presentation';

  @override
  String get previewOpenOfficeTitle => 'OpenOffice preview';

  @override
  String get previewOpenOfficeBody =>
      'OpenOffice files require an external viewer.';

  @override
  String themeApplied(String name) {
    return 'Theme \"$name\" applied';
  }

  @override
  String get themeDark => 'Dark theme';

  @override
  String themeFontSizeTitle(String size) {
    return 'Font size: $size';
  }

  @override
  String get themeFontWeightSection => 'Font weight';

  @override
  String get themeBoldLabel => 'Bold';

  @override
  String get themeTextShadowSection => 'Text shadow';

  @override
  String themeShadowIntensity(String percent) {
    return 'Shadow intensity: $percent%';
  }

  @override
  String get themeColorPicked => 'Color selected';

  @override
  String get themeSelectToCustomize => 'Select a theme to customize';

  @override
  String get themeFontFamilySection => 'Font family';

  @override
  String get searchNeedCriterion => 'Enter at least one search criterion';

  @override
  String get searchCurrentPath => 'Current path';

  @override
  String get searchButton => 'Search';

  @override
  String get pkgConfirmUninstallTitle => 'Confirm uninstall';

  @override
  String pkgConfirmUninstallBody(String name) {
    return 'Uninstall $name?';
  }

  @override
  String get pkgDependenciesTitle => 'Dependencies found';

  @override
  String get pkgUninstallError => 'Error during uninstall';

  @override
  String get pkgManagerTitle => 'Application manager';

  @override
  String get pkgInstallTitle => 'Install package';

  @override
  String pkgInstallBody(String name) {
    return 'Install \"$name\"?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name made executable';
  }

  @override
  String get pkgUnsupportedFormat => 'Unsupported package format';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Install error: $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name updated successfully';
  }

  @override
  String updateItemError(String name) {
    return 'Error updating $name';
  }

  @override
  String get updateAllError => 'Error installing updates';

  @override
  String get updateInstallAllButton => 'Install all';

  @override
  String get previewCatImages => 'Images';

  @override
  String get previewCatDocuments => 'Documents';

  @override
  String get previewCatText => 'Text';

  @override
  String get previewCatWeb => 'Web';

  @override
  String get previewCatOffice => 'Office';

  @override
  String previewExtTitle(String ext, String name) {
    return '.$ext — $name';
  }

  @override
  String bulkRenamePatternExample(String a, String b) {
    return '$a, ${a}_$b, Document_$b';
  }

  @override
  String get tableColumnName => 'Name';

  @override
  String get tableColumnPath => 'Path';

  @override
  String get tableColumnSize => 'Size';

  @override
  String get tableColumnModified => 'Modified';

  @override
  String get tableColumnType => 'Type';

  @override
  String get networkBrowserTitle => 'Browse network';

  @override
  String get networkSearchingServers => 'Searching for network servers…';

  @override
  String get networkNoServersFound => 'No network servers found';

  @override
  String get networkServersSharesHeader => 'Servers and shares';

  @override
  String get labelUsername => 'Username';

  @override
  String get labelPassword => 'Password';

  @override
  String get networkRefreshTooltip => 'Refresh';

  @override
  String get networkNoSharesAvailable => 'No shares available';

  @override
  String get networkInfoTitle => 'Information';

  @override
  String networkServersFoundCount(int count) {
    return 'Servers found: $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'To connect to a share, expand a server and tap the share you want.';

  @override
  String get networkSelectedServerLabel => 'Selected server:';

  @override
  String networkSharesCount(int count) {
    return 'Shares: $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Browse network paths';

  @override
  String get sidebarTooltipAddNetworkPath => 'Add network path';

  @override
  String get sidebarSectionNetwork => 'Network';

  @override
  String get sidebarSectionDisks => 'Disks';

  @override
  String get sidebarAddPath => 'Add path';

  @override
  String get sidebarUserFolderHome => 'Home';

  @override
  String get sidebarUserFolderDesktop => 'Desktop';

  @override
  String get sidebarUserFolderDocuments => 'Documents';

  @override
  String get sidebarUserFolderPictures => 'Pictures';

  @override
  String get sidebarUserFolderMusic => 'Music';

  @override
  String get sidebarUserFolderVideos => 'Videos';

  @override
  String get sidebarUserFolderDownloads => 'Downloads';

  @override
  String get sidebarSectionFavorites => 'Favorites';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get prefsClearCacheButton => 'Clear cache';

  @override
  String get prefsClearCacheTitle => 'Clear cache';

  @override
  String get prefsClearCacheBody => 'Clear all thumbnail preview cache?';

  @override
  String get prefsClearCacheConfirm => 'Clear';

  @override
  String get snackPrefsCacheCleared => 'Cache cleared';

  @override
  String get previewFmtJpeg => 'JPEG image';

  @override
  String get previewFmtPng => 'PNG image';

  @override
  String get previewFmtGif => 'GIF image';

  @override
  String get previewFmtBmp => 'BMP image';

  @override
  String get previewFmtWebp => 'WebP image';

  @override
  String get previewFmtPdf => 'PDF document';

  @override
  String get previewFmtPlainText => 'Text file';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'Info file';

  @override
  String get previewFmtShell => 'Shell script';

  @override
  String get previewFmtHtml => 'HTML document';

  @override
  String get previewFmtDocx => 'Word document';

  @override
  String get previewFmtXlsx => 'Excel spreadsheet';

  @override
  String get previewFmtPptx => 'PowerPoint presentation';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Theme \"$name\" applied';
  }

  @override
  String get themeEditTitle => 'Edit theme';

  @override
  String get themeNewTitle => 'New theme';

  @override
  String get themeFieldName => 'Theme name';

  @override
  String get themeDarkThemeSwitch => 'Dark theme';

  @override
  String get themeColorPrimary => 'Primary color';

  @override
  String get themeColorSecondary => 'Secondary color';

  @override
  String get themeColorFile => 'File color';

  @override
  String get themeColorLocation => 'Location bar color';

  @override
  String get themeColorBackground => 'Background color';

  @override
  String get themeColorFolder => 'Folder color';

  @override
  String get themeFolderIconsHint =>
      'Icons are applied automatically based on folder type.';

  @override
  String get themeFolderIconPickColor => 'Pick a color for folder icons';

  @override
  String get themeColorPickedSnack => 'Color selected';

  @override
  String get themeManagerTitle => 'Theme management';

  @override
  String get themeBuiltinHeader => 'Built-in themes';

  @override
  String get themeCustomHeader => 'Custom themes';

  @override
  String get themeCustomizationHeader => 'Customization';

  @override
  String get themeSelectPrompt => 'Select a theme to customize';

  @override
  String get themeVariantLight => 'Light';

  @override
  String get themeVariantDark => 'Dark';

  @override
  String get themeColorsHeader => 'Colors';

  @override
  String get themeFontHeader => 'Font';

  @override
  String get themeFontFamilyRow => 'Font family';

  @override
  String themeFontSizeRow(String size) {
    return 'Font size: $size';
  }

  @override
  String get themeFontWeightHeader => 'Font weight';

  @override
  String get themeTextShadow => 'Text shadow';

  @override
  String get themeIconShadowTitle => 'Icon shadow (grid)';

  @override
  String get themeIconShadowSubtitle =>
      'Drop shadow under file and folder icons in grid view';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Icon shadow intensity: $percent%';
  }

  @override
  String themeShadowIntensityRow(String percent) {
    return 'Shadow intensity: $percent%';
  }

  @override
  String get themeFolderIconFolder => 'Folder';

  @override
  String get themeFolderIconFolderOpen => 'Folder open';

  @override
  String get themeFolderIconFolderSpecial => 'Folder special';

  @override
  String get themeFolderIconFolderShared => 'Folder shared';

  @override
  String get themeFolderIconFolderCopy => 'Folder copy';

  @override
  String get themeFolderIconFolderDelete => 'Folder delete';

  @override
  String get themeFolderIconFolderZip => 'Folder zip';

  @override
  String get themeFolderIconFolderOff => 'Folder off';

  @override
  String get themeFolderIconFolderPlus => 'New folder';

  @override
  String get themeFolderIconFolderHome => 'Home';

  @override
  String get themeFolderIconFolderDrive => 'Drive';

  @override
  String get themeFolderIconFolderCloud => 'Cloud';

  @override
  String get propsTitle => 'Properties';

  @override
  String get propsTimeoutLoading => 'Timed out loading properties';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Error loading properties: $detail';
  }

  @override
  String get propsFieldName => 'Name';

  @override
  String get propsFieldPath => 'Path';

  @override
  String get propsFieldType => 'Type';

  @override
  String get propsFieldSize => 'Size';

  @override
  String get propsFieldSizeOnDisk => 'Size on disk';

  @override
  String get propsFieldModified => 'Modified';

  @override
  String get propsFieldAccessed => 'Accessed';

  @override
  String get propsFieldCreated => 'Created';

  @override
  String get propsFieldOwner => 'Owner';

  @override
  String get propsFieldGroup => 'Group';

  @override
  String get propsFieldPermissions => 'Permissions';

  @override
  String get propsFieldInode => 'Inode';

  @override
  String get propsFieldLinks => 'Links';

  @override
  String get propsFieldFilesInside => 'Files inside';

  @override
  String get propsFieldDirsInside => 'Folders inside';

  @override
  String get propsTypeFolder => 'Folder';

  @override
  String get propsTypeFile => 'File';

  @override
  String propsMultiSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items selected',
      one: '1 item selected',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Mixed (files and folders)';

  @override
  String get propsMultiCombinedSize => 'Total size on disk';

  @override
  String get propsMultiLoadingSizes => 'Calculating sizes…';

  @override
  String get propsMultiPerItemTitle => 'Each item';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount folders, $fileCount files';
  }

  @override
  String get propsEditTooltip => 'Edit';

  @override
  String get propsHintNewValue => 'Enter new value';

  @override
  String get propsPermissionsDialogTitle => 'Edit permissions';

  @override
  String get propsPermOwnerSection => 'Owner:';

  @override
  String get propsPermGroupSection => 'Group:';

  @override
  String get propsPermOtherSection => 'Others:';

  @override
  String get propsInvalidPermissionsFormat => 'Invalid permissions format';

  @override
  String propsChmodFailed(String detail) {
    return 'Could not change permissions: $detail';
  }

  @override
  String get pkgPageTitle => 'Applications';

  @override
  String get pkgInstallFromFileTooltip => 'Install package from file';

  @override
  String get pkgFilterAll => 'All';

  @override
  String get pkgSearchHint => 'Search applications…';

  @override
  String get pkgUninstallTitle => 'Confirm uninstall';

  @override
  String pkgUninstallConfirm(String name) {
    return 'Uninstall $name?';
  }

  @override
  String get pkgUninstallButton => 'Uninstall';

  @override
  String get pkgDepsTitle => 'Dependencies found';

  @override
  String pkgDepsUsedByBody(String list) {
    return 'This package is used by:\n$list';
  }

  @override
  String get pkgProceedAnyway => 'Proceed anyway';

  @override
  String pkgUninstalled(Object name) {
    return '$name uninstalled';
  }

  @override
  String get pkgUninstallFailed => 'Error during uninstall';

  @override
  String get pkgInstallDialogTitle => 'Install package';

  @override
  String pkgInstallConfirm(String name) {
    return 'Install \"$name\"?';
  }

  @override
  String get pkgInstallButton => 'Install';

  @override
  String get pkgInstallProgressTitle => 'Installing package';

  @override
  String get pkgInstallRunningStatus => 'Starting installer…';

  @override
  String get zipProgressPanelTitle => 'Compressing to ZIP';

  @override
  String get zipProgressSubtitle => 'Adding files to archive';

  @override
  String get zipProgressEncoding => 'Writing archive…';

  @override
  String pkgExecutableMade(String name) {
    return '$name is now executable';
  }

  @override
  String get pkgUnsupportedPackage => 'Unsupported package format';

  @override
  String pkgInstalledSuccess(String name) {
    return '$name installed successfully';
  }

  @override
  String pkgInstallFailedWithError(String detail) {
    return 'Install error: $detail';
  }

  @override
  String get updateTitle => 'Updates';

  @override
  String updateTitleWithCount(int count) {
    return 'Updates ($count)';
  }

  @override
  String get updateInstallAll => 'Install all';

  @override
  String get updateNoneAvailable => 'No updates available';

  @override
  String updateTypeLine(String type) {
    return 'Type: $type';
  }

  @override
  String updateCurrentVersionLine(String v) {
    return 'Current version: $v';
  }

  @override
  String updateAvailableVersionLine(String v) {
    return 'Available version: $v';
  }

  @override
  String get updateInstallTooltip => 'Install update';

  @override
  String updateUpdatedSuccess(String name) {
    return '$name updated successfully';
  }

  @override
  String updateOneFailed(String name) {
    return 'Error updating $name';
  }

  @override
  String get updateInstallAllTitle => 'Install all updates';

  @override
  String updateInstallAllBody(int count) {
    return 'Install $count updates?';
  }

  @override
  String get updateAllSuccess => 'All updates installed successfully';

  @override
  String get updateAllFailed => 'Error installing updates';

  @override
  String get searchDialogTitle => 'Find files';

  @override
  String searchPathLabel(String path) {
    return 'Path: $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Select drive';

  @override
  String get searchAllMountsLabel => 'Search all mounted volumes';

  @override
  String get searchAllMountsHint =>
      'USB drives, extra partitions, GVFS/network (where accessible). Slower than a single folder.';

  @override
  String searchAllMountsActive(int count) {
    return 'Searching $count locations (all mounts)';
  }

  @override
  String get searchPathCurrentMenu => 'Current path';

  @override
  String get searchPathRootMenu => 'Filesystem root';

  @override
  String get searchLabelQuery => 'Search';

  @override
  String get searchHintQuery => 'File name, *.mp4, *.txt…';

  @override
  String get searchHelperPatterns => 'Patterns: *.mp4, *.txt, document*.pdf';

  @override
  String get searchLabelNameFilter => 'Name filter';

  @override
  String get searchHintNameFilter => 'e.g. document';

  @override
  String get searchLabelExtension => 'Extension';

  @override
  String get searchHintExtension => 'e.g. pdf';

  @override
  String get searchLabelSizeMin => 'Min size (bytes)';

  @override
  String get searchLabelSizeMax => 'Max size (bytes)';

  @override
  String get searchLabelFileType => 'File type';

  @override
  String get searchLabelDateFilter => 'Date filter';

  @override
  String get searchIncludeSystemFiles => 'Include system files';

  @override
  String get searchChoosePath => 'Choose path';

  @override
  String get searchStop => 'Stop';

  @override
  String get searchSearchButton => 'Search';

  @override
  String get searchNoCriteriaSnack => 'Enter at least one search criterion';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchResultsOne => '1 result found';

  @override
  String searchResultsMany(int count) {
    return '$count results found';
  }

  @override
  String get searchTooltipViewList => 'List';

  @override
  String get searchTooltipViewGrid => 'Grid';

  @override
  String get searchTooltipViewDetails => 'Details';

  @override
  String get searchZoomOut => 'Zoom out';

  @override
  String get searchZoomIn => 'Zoom in';

  @override
  String get searchTypeAll => 'All';

  @override
  String get searchTypeImages => 'Images';

  @override
  String get searchTypeVideo => 'Video';

  @override
  String get searchTypeAudio => 'Audio';

  @override
  String get searchTypeDocuments => 'Documents';

  @override
  String get searchTypeArchives => 'Archives';

  @override
  String get searchTypeExecutables => 'Executables';

  @override
  String get searchDateAll => 'Any time';

  @override
  String get searchDateToday => 'Today';

  @override
  String get searchDateWeek => 'Last week';

  @override
  String get searchDateMonth => 'Last month';

  @override
  String get searchDateYear => 'Last year';

  @override
  String statusDiskPercent(String value) {
    return '$value%';
  }

  @override
  String get depsDialogTitle => 'System components';

  @override
  String get depsDialogIntro =>
      'The following components are missing. The app works best when they are installed. You can install them now using your administrator password (PolicyKit).';

  @override
  String get depsInstallButton => 'Install now (admin password)';

  @override
  String get depsContinueButton => 'Continue without installing';

  @override
  String get depsInstalling => 'Installing packages…';

  @override
  String get depsInstallSuccess => 'Installation completed successfully.';

  @override
  String depsInstallFailed(String message) {
    return 'Installation failed: $message';
  }

  @override
  String get depsUnknownDistro =>
      'Automatic installation is not available for this Linux distribution. Install the packages manually in a terminal.';

  @override
  String get depsManualCommandLabel => 'Suggested command';

  @override
  String get depsPkexecNotFound =>
      'pkexec was not found. Run this in a terminal:';

  @override
  String get depsRustUnavailable =>
      'The native library (Rust) was not loaded. Copying large files may be slower. Reinstall the application if this continues.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — open files with default applications';

  @override
  String get depLabelMountCifs => 'mount.cifs — mount SMB shares (cifs-utils)';

  @override
  String get depsCifsInstallTitle => 'Install cifs-utils?';

  @override
  String get depsCifsInstallBody =>
      'Mounting SMB shares needs mount.cifs from the cifs-utils package. Install it now with the system package manager (administrator password required)?';

  @override
  String get depLabelSmbclient => 'smbclient — browse SMB/CIFS shares';

  @override
  String get depLabelNmblookup =>
      'nmblookup — find computers on the LAN (NetBIOS)';

  @override
  String get depLabelAvahiBrowse =>
      'avahi-browse — find computers via network discovery (mDNS)';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — resolve host names on the LAN (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Some optional tools for finding PCs on the network and mounting shares are missing. You can install them automatically (administrator password required).';

  @override
  String get depsNetworkBannerLater => 'Not now';

  @override
  String get depsSomeStillMissing =>
      'Some tools are still missing. Try the suggested terminal command below.';

  @override
  String get depsPolkitAuthFailed =>
      'Administrator authentication was cancelled, denied, or pkexec could not run the installer.';

  @override
  String get depsInstallOutputIntro => 'Package manager output:';

  @override
  String get depsInstallUnexpected => 'unexpected error';

  @override
  String get depsDialogIntroRustOnly =>
      'Native acceleration for some file operations is not available (Rust library).';

  @override
  String get depsDialogIntroToolsOk =>
      'Required command-line tools are installed.';

  @override
  String get depsCloseButton => 'Close';

  @override
  String get computerTitle => 'Computer';

  @override
  String get computerOnDevice => 'On this device';

  @override
  String get computerNetworks => 'Network';

  @override
  String get computerNoVolumes => 'No volumes found';

  @override
  String get computerNoServers => 'No servers found';

  @override
  String get computerTools => 'Tools';

  @override
  String get computerToolFindFiles => 'Find files and folders';

  @override
  String get computerToolPackages => 'Uninstall/Install apps';

  @override
  String get computerToolSystemUpdates => 'Check system updates';

  @override
  String get computerRefresh => 'Refresh';

  @override
  String computerFreeShort(String size) {
    return '$size free';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Use the sidebar → Network to connect to $name';
  }

  @override
  String get computerVolumeOpen => 'Open';

  @override
  String get computerFormatVolume => 'Format…';

  @override
  String get computerFormatTitle => 'Format volume';

  @override
  String get computerFormatWarning =>
      'All data on this volume will be erased. This cannot be undone.';

  @override
  String get computerFormatFilesystem => 'Filesystem';

  @override
  String get computerFormatConfirm => 'Format';

  @override
  String get computerFormatNotSupported =>
      'Formatting from this screen is only supported on Linux with udisks2.';

  @override
  String get computerFormatNoDevice =>
      'Could not determine the block device for this volume.';

  @override
  String get computerFormatSystemBlockedTitle => 'Cannot format';

  @override
  String get computerFormatSystemBlockedBody =>
      'This is a system volume (root, boot, or same device as the system disk). Formatting it here is not allowed.';

  @override
  String get computerFormatRunning => 'Formatting…';

  @override
  String get computerFormatDone => 'Format completed.';

  @override
  String computerFormatFailed(String error) {
    return 'Format failed: $error';
  }

  @override
  String get computerMounting => 'Connecting…';

  @override
  String get computerMountNoShares =>
      'No shares found. Check credentials, firewall, or SMB on the server.';

  @override
  String get computerMountFailed =>
      'Could not mount the share. Try different credentials, install cifs-utils, or check mount permissions.';

  @override
  String get computerMountMissingGio =>
      'mount.cifs was not found. Install the cifs-utils package. You may need root privileges or /etc/fstab entries to allow mounting.';

  @override
  String get computerMountNeedPassword =>
      'This share requires a username and password. Connect again and enter your credentials.';

  @override
  String get networkRememberPassword =>
      'Remember credentials for this computer (secure storage)';

  @override
  String get dialogRootPasswordTitle => 'Administrator password';

  @override
  String get dialogRootPasswordLabel => 'Password for sudo';

  @override
  String get computerSelectShare => 'Select share';

  @override
  String get computerConnect => 'Connect';

  @override
  String get computerCredentialsTitle => 'Network login';

  @override
  String get computerUsername => 'Username';

  @override
  String get computerPassword => 'Password';

  @override
  String get computerDiskProperties => 'Properties';

  @override
  String get diskPropsOpenInDisks => 'Open in Disks';

  @override
  String get diskPropsFsUnknown => 'File system unknown';

  @override
  String diskPropsFsLine(String type) {
    return 'File system $type';
  }

  @override
  String diskPropsTotalLine(String size) {
    return 'Total: $size';
  }

  @override
  String diskPropsUsedLine(String size) {
    return 'Used: $size';
  }

  @override
  String diskPropsFreeLine(String size) {
    return 'Free: $size';
  }

  @override
  String get diskPropsFileAccessRow => 'File access';

  @override
  String get snackExternalDropDone => 'Finished with dropped items.';

  @override
  String get snackDropUnreadable => 'Could not read the dropped files.';

  @override
  String get snackOpenAsRootLaunched =>
      'Administrator window started (separate from this window).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP: $ip';
  }
}
