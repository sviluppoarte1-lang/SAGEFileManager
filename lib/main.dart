import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/widgets/sidebar.dart';
import 'package:filemanager/widgets/file_list.dart';
import 'package:filemanager/widgets/status_bar.dart';
import 'package:filemanager/widgets/package_manager.dart';
import 'package:filemanager/widgets/update_checker.dart';
import 'package:filemanager/services/file_service.dart';
import 'package:filemanager/services/desktop_trash.dart';
import 'package:filemanager/services/network_browser_service.dart';
import 'package:filemanager/services/archive_service.dart';
import 'package:filemanager/services/office_empty_documents.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/models/disk_info.dart';
import 'package:filemanager/models/theme_config.dart';
import 'package:filemanager/services/theme_service.dart';
import 'package:filemanager/widgets/theme_manager.dart';
import 'package:filemanager/widgets/file_search.dart';
import 'package:filemanager/widgets/empty_space_pane_menu.dart';
import 'package:filemanager/widgets/compact_menu_row.dart';
import 'package:filemanager/widgets/dialog_enter_scope.dart';
import 'package:filemanager/widgets/navigation_bar.dart' as custom;
import 'package:filemanager/widgets/preview_panel.dart';
import 'package:filemanager/widgets/file_properties.dart';
import 'package:filemanager/widgets/copy_progress.dart';
import 'package:filemanager/widgets/computer_page.dart';
import 'package:filemanager/widgets/preferences.dart';
import 'package:filemanager/services/thumbnail_cache_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selection_marquee/selection_marquee.dart';
import 'package:filemanager/widgets/glass_wrapper.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';
import 'package:filemanager/services/folder_icon_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:super_clipboard/super_clipboard.dart'
    show
        DataReader,
        DataWriterItem,
        Formats,
        NamedUri,
        PlatformDataProvider,
        PlatformFormat,
        SimplePlatformCodec,
        SimpleValueFormat,
        SystemClipboard;
import 'package:filemanager/services/logging_service.dart';
import 'package:filemanager/services/desktop_session_service.dart';
import 'package:filemanager/services/desktop_input_bridge.dart';
import 'package:filemanager/services/rust_ffi.dart';
import 'package:filemanager/utils/keyboard_modifier_state.dart';
import 'package:filemanager/services/copy_progress_controller.dart';
import 'package:filemanager/services/desktop_apps_service.dart';
import 'package:filemanager/services/system_dependencies_service.dart';
import 'package:filemanager/widgets/dependency_install_dialog.dart';
import 'package:filemanager/services/github_app_update_service.dart';

Future<String?> _clipboardUtf8Text(
  PlatformDataProvider dataProvider,
  PlatformFormat format,
) async {
  final data = await dataProvider.getData(format);
  if (data is String) return data;
  if (data is Uint8List) return utf8.decode(data, allowMalformed: true);
  return null;
}

/// One [text/uri-list] value with **all** paths (newline-separated). Required
/// for many Linux file managers / desktop paste; multiple clipboard items often break this.
final _textUriListFormat = SimpleValueFormat<String>(
  linux: SimplePlatformCodec(
    formats: <PlatformFormat>['text/uri-list'],
    onDecode: _clipboardUtf8Text,
    onEncode: (value, format) => Uint8List.fromList(utf8.encode(value)),
  ),
  fallback: SimplePlatformCodec(
    formats: <PlatformFormat>['text/uri-list'],
    onDecode: _clipboardUtf8Text,
    onEncode: (value, format) => Uint8List.fromList(utf8.encode(value)),
  ),
);

/// GNOME/Nautilus interop clipboard payload for copy/cut of file URIs.
/// Many Linux desktops look specifically for this target, not plain text.
final _gnomeCopiedFilesFormat = SimpleValueFormat<String>(
  linux: SimplePlatformCodec(
    formats: <PlatformFormat>['x-special/gnome-copied-files'],
    onDecode: _clipboardUtf8Text,
    onEncode: (value, format) => Uint8List.fromList(utf8.encode(value)),
  ),
  fallback: SimplePlatformCodec(
    formats: <PlatformFormat>['x-special/gnome-copied-files'],
    onDecode: _clipboardUtf8Text,
    onEncode: (value, format) => Uint8List.fromList(utf8.encode(value)),
  ),
);

List<String> _pathsFromUriListText(String raw) {
  final paths = <String>[];
  for (final line in raw.split(RegExp(r'\r?\n'))) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final uri = Uri.tryParse(t);
    if (uri != null && uri.scheme == 'file') {
      paths.add(uri.toFilePath(windows: false));
    }
  }
  return paths;
}

String messageForDirectoryLoadError(BuildContext context, Object e) {
  final l10n = AppLocalizations.of(context);
  if (e is DirectoryListingPermissionException) {
    return l10n.errorFolderRequiresOpenAsRoot;
  }
  return l10n.commonError(e.toString());
}

bool _globalHardwareKeyHandler(KeyEvent event) {
  return KeyboardModifierState.instance.handleKeyEvent(event);
}

void main(List<String> args) async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  // Ctrl/Maiusc per selezione multipla: aggiornare il state da ogni KeyEvent,
  // prima ancora del primo frame (così la pressione di Ctrl è nota al click).
  HardwareKeyboard.instance.addHandler(_globalHardwareKeyHandler);

  // Initialize keyboard modifier state for instant Ctrl+Click detection
  KeyboardModifierState.instance.ensureSynced();

  // CRITICAL: Initialize logging FIRST before anything else
  await LoggingService.initialize();
  await LoggingService.info('App', 'Application starting', {
    'args': args.toString(),
    'timestamp': DateTime.now().toIso8601String(),
  });
  await LoggingService.info(
    'App',
    'Log file location: ${LoggingService.getLogFilePath()}',
  );

  await DesktopSessionService.detectAndLog();

  // Initialize window_manager
  await windowManager.ensureInitialized();
  await LoggingService.info('App', 'Window manager initialized');

  // Note: super_drag_and_drop initializes automatically when widgets are used
  // No explicit initialization needed - the plugin handles it internally
  await LoggingService.info(
    'App',
    'super_drag_and_drop will initialize automatically',
  );

  // Log command line arguments
  await LoggingService.info('App', 'Command line arguments received', {
    'args': args.toString(),
  });

  // Error handling with logging
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LoggingService.error('Flutter', 'Flutter Error: ${details.exception}', {
      'exception': details.exception.toString(),
      'library': details.library,
      'context': details.context?.toString(),
    }, details.stack);
  };

  // Extract folder path from command line arguments
  String? folderPathToOpen;
  if (args.isNotEmpty) {
    // Look for --folder flag followed by path
    int folderIndex = args.indexOf('--folder');
    if (folderIndex != -1 && folderIndex + 1 < args.length) {
      folderPathToOpen = args[folderIndex + 1];
    } else {
      // If no --folder flag, check if first argument is a valid path
      final firstArg = args.first;
      if (!firstArg.startsWith('-')) {
        // Not a flag, might be a path
        final dir = Directory(firstArg);
        if (await dir.exists()) {
          folderPathToOpen = firstArg;
        }
      }
    }
  }

  runApp(FileManagerApp(initialPath: folderPathToOpen));
}

enum _OverwriteBatchChoice { replace, skip, abortBatch }

class FileManagerApp extends StatefulWidget {
  final String? initialPath;

  const FileManagerApp({super.key, this.initialPath});

  @override
  State<FileManagerApp> createState() => _FileManagerAppState();
}

class _FileManagerAppState extends State<FileManagerApp> {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  ThemeConfig currentTheme = ThemeConfig.lightBlue;
  Locale _locale = const Locale('it');

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadLocale();
    if (Platform.isLinux) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_checkSystemDependenciesAfterFirstFrame());
      });
    }
  }

  Future<void> _checkSystemDependenciesAfterFirstFrame() async {
    if (!mounted) return;
    final result = await SystemDependenciesService.checkAll();
    if (!mounted || !result.needsAttention) return;
    final navContext = _rootNavigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;
    await showDialog<void>(
      context: navContext,
      barrierDismissible: true,
      builder: (context) => DependencyInstallDialog(initialResult: result),
    );
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'italiano';
    if (!mounted) return;
    setState(() => _locale = _localeFromLanguagePreference(lang));
  }

  static Locale _localeFromLanguagePreference(String code) {
    switch (code) {
      case 'inglese':
        return const Locale('en');
      case 'francese':
        return const Locale('fr');
      case 'portoghese':
        return const Locale('pt');
      case 'tedesco':
        return const Locale('de');
      case 'spagnolo':
        return const Locale('es');
      default:
        return const Locale('it');
    }
  }

  Future<void> _loadTheme() async {
    final theme = await ThemeService.getCurrentTheme();
    setState(() => currentTheme = theme);
  }

  void _onThemeChanged(ThemeConfig theme) {
    setState(() => currentTheme = theme);
  }

  @override
  Widget build(BuildContext context) {
    // Log app build and log file location
    final logPath = LoggingService.getLogFilePath();
    LoggingService.info('App', 'FileManagerApp building', {
      'initial_path': widget.initialPath,
      'log_file': logPath,
    });

    // Avoid noisy prints in production; log path is already in LoggingService.

    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: currentTheme.toThemeData(),
      home: FileManagerScreen(
        themeConfig: currentTheme,
        onThemeChanged: _onThemeChanged,
        initialPath: widget.initialPath,
        onLocaleChanged: () async {
          await _loadLocale();
          await _loadTheme();
        },
      ),
    );
  }
}

class FileManagerScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final Function(ThemeConfig) onThemeChanged;
  final String? initialPath;
  final Future<void> Function()? onLocaleChanged;

  const FileManagerScreen({
    super.key,
    required this.themeConfig,
    required this.onThemeChanged,
    this.initialPath,
    this.onLocaleChanged,
  });

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  String? currentPath;
  List<FileInfo> files = [];
  ViewMode viewMode = ViewMode.list;
  int gridZoomLevel = 3; // 1-5, where 1 is most zoomed in, 5 is most zoomed out
  DiskInfo? currentDiskInfo;
  DiskInfo? secondPaneDiskInfo;
  bool isLoading = false;
  // Used to suppress pane-level empty-space context menus when item menu opens.
  bool _isRightClickingFile = false;

  /// Evita menu “spazio vuoto” subito dopo click destro su file/cartella (griglia + listener ritardati).
  int _suppressEmptyPaneContextMenuUntilMs = 0;

  void _onItemContextMenuOpened() {
    final until = DateTime.now().millisecondsSinceEpoch + 48;
    if (until > _suppressEmptyPaneContextMenuUntilMs) {
      _suppressEmptyPaneContextMenuUntilMs = until;
    }
  }

  bool _shouldBlockEmptyPaneContextMenu() {
    if (_isRightClickingFile) return true;
    return DateTime.now().millisecondsSinceEpoch <
        _suppressEmptyPaneContextMenuUntilMs;
  }

  /// Stesso path di [FileInfo.path] può differire leggermente da chiavi in
  /// [SelectionController] (es. normalizzazione); evita falsi negativi al click destro.
  bool _pathInSelectionSets(String filePath, Set<String> ids, Set<String> ui) {
    if (filePath.isEmpty) return false;
    if (ids.contains(filePath) || ui.contains(filePath)) return true;
    try {
      final n = path.normalize(filePath);
      for (final p in ids) {
        if (path.normalize(p) == n) return true;
      }
      for (final p in ui) {
        if (path.normalize(p) == n) return true;
      }
    } catch (_) {}
    return false;
  }

  /// Ogni path in [required] è presente in [actual] (confronto normalizzato).
  bool _selectionCoversPaths(Set<String> actual, Set<String> required) {
    for (final p in required) {
      if (!_pathInSelectionSets(p, actual, actual)) return false;
    }
    return true;
  }

  /// Ordine di lista della cartella corrente (stabile), solo path selezionati.
  List<FileInfo> _orderedSelectedFileInfosInPane({required bool secondPane}) {
    final paths = secondPane ? secondPaneSelectedFiles : selectedFiles;
    final list = secondPane ? secondPaneFiles : files;
    final out = <FileInfo>[];
    for (final f in list) {
      if (paths.contains(f.path)) out.add(f);
    }
    return out;
  }

  bool _pathsEqual(String a, String b) =>
      path.normalize(a) == path.normalize(b);

  void _refreshDirectoryAfterRename(String parentDir, bool secondPane) {
    FileService.clearDirectoryCache(parentDir);
    if (secondPane) {
      if (secondPanePath != null && _pathsEqual(secondPanePath!, parentDir)) {
        _loadDirectoryForPane(secondPanePath!, true);
      }
    } else {
      if (currentPath != null && _pathsEqual(currentPath!, parentDir)) {
        _navigateToPath(currentPath!, addToHistory: false);
      }
    }
  }

  /// Dopo [showMenu], su Linux/GTK a volte resta il layer del popup finché non passa
  /// un frame in più; evita menu “appiccicati” eseguendo l’azione solo a route smontata.
  Future<void> _ensurePopupMenuDismissed() async {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final binding = WidgetsBinding.instance;
    final completer = Completer<void>();
    binding.addPostFrameCallback((_) {
      binding.addPostFrameCallback((_) {
        if (!completer.isCompleted) completer.complete();
      });
    });
    await completer.future;
  }

  /// Incrementato a fine ogni sessione DnD nativa: ricrea [DragItemWidget] nella lista.
  int _nativeDragSessionEpoch = 0;

  Set<String> selectedFiles = {};
  List<String> navigationHistory = [];
  int navigationIndex = -1;
  List<String> secondPaneNavigationHistory = [];
  int secondPaneNavigationIndex = -1;
  FileInfo? previewFile;
  List<String> copiedFiles = [];
  bool isMoveOperation = false;
  bool _systemClipboardHasFiles = false;
  bool showHiddenFiles = false;
  bool showHiddenFilesSecondPane = false;
  bool showSystemFiles = true; // Toggle for system files
  bool showPreview = true; // Toggle for preview panel
  bool previewFastMode = false; // Fast preview: info + icon only
  bool showRightPanel = true; // Toggle for right panel
  final CopyProgressController _copyProgress = CopyProgressController();
  Timer? _memoryMaintenanceTimer;
  Timer? copyRefreshTimer; // Timer per refresh automatico durante la copia
  Timer?
  _copyLiveRefreshTimer; // Aggiorna elenco cartella destinazione durante la copia
  bool _copySilentReloadMainBusy = false;
  bool _copySilentReloadSecondBusy = false;
  StreamSubscription<FileSystemEvent>? _directoryWatchMain;
  Timer? _directoryWatchMainDebounce;
  StreamSubscription<FileSystemEvent>? _directoryWatchSecond;
  Timer? _directoryWatchSecondDebounce;
  bool isSplitView = false;
  String? secondPanePath;
  List<FileInfo> secondPaneFiles = [];
  Set<String> secondPaneSelectedFiles =
      {}; // File selezionati nel secondo pannello
  FileInfo? secondPanePreviewFile; // File di preview per il secondo pannello
  double splitViewRatio = 0.5; // Ratio for split view (0.0 to 1.0)
  String currentSortCriteria = 'name'; // Criterio di ordinamento corrente
  bool reverseSortOrder = false; // Ordine inverso
  double sidebarWidth = 200.0; // Larghezza ridimensionabile della sidebar
  double rightPanelWidth =
      200.0; // Larghezza ridimensionabile del pannello destro
  List<String> favoritePaths = []; // Favorite paths
  /// Notifica la sidebar di ricaricare i segnalibri rete dopo scelta dal menu File.
  final ValueNotifier<int> _networkBookmarksRevision = ValueNotifier<int>(0);
  // Mappa per tracciare i controller dei menu (per evitare intrecci)
  final Map<String, MenuController> _menuControllers = {};
  bool _isSecondPaneFocused = false; // Traccia quale pannello ha il focus
  List<Map<String, String>> tabs =
      []; // Tab management: [{path: '/path', name: 'Tab Name'}]
  int activeTabIndex = 0;

  // Undo/Redo history
  List<Map<String, dynamic>> undoHistory = [];
  List<Map<String, dynamic>> redoHistory = [];
  int maxHistorySize = 50;

  // Selection marquee controller
  final SelectionController _selectionController = SelectionController();
  final SelectionController _secondPaneSelectionController =
      SelectionController();
  final GlobalKey _marqueeKey = GlobalKey();
  final GlobalKey _secondPaneMarqueeKey = GlobalKey();
  final ScrollController _fileListScrollController = ScrollController();
  final ScrollController _secondPaneScrollController = ScrollController();

  // Preferences
  bool singleClickToOpen = false;
  bool doubleClickToRename = false;
  bool openEachFolderInNewWindow = false;
  bool alwaysStartWithDoublePane = false;
  bool ignoreViewPreferences = false;
  bool disableFileOperationQueue = false;
  bool doubleClickEmptyAreaToGoUp = false;
  int executableTextFilesBehavior = 2; // 0=execute, 1=show, 2=ask
  bool useCollapsedMenuBar = false;

  Future<void> _refreshSystemClipboardPasteState() async {
    final payload = await _readFilePayloadFromSystemClipboard();
    if (!mounted) return;
    setState(() {
      _systemClipboardHasFiles = payload.paths.isNotEmpty;
    });
  }

  Future<void> _writeFilePayloadToSystemClipboard(
    List<String> paths, {
    required bool move,
  }) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final uris = paths
        .where((p) => p.isNotEmpty)
        .map((p) => Uri.file(p, windows: false))
        .toList();
    if (uris.isEmpty) return;

    // Single clipboard entry: GNOME/KDE/Nautilus expect **one** item with
    // `text/uri-list` listing every `file://` URL, not one item per file.
    // Clipboard uri-list spec prefers CRLF; some desktop components are picky.
    final uriListBody = '${uris.map((u) => u.toString()).join('\r\n')}\r\n';

    final gnomeText = StringBuffer()..writeln(move ? 'cut' : 'copy');
    for (final uri in uris) {
      gnomeText.writeln(uri.toString());
    }
    final gnomeStr = gnomeText.toString();

    final item = DataWriterItem(
      suggestedName: uris.length == 1 && uris.first.pathSegments.isNotEmpty
          ? uris.first.pathSegments.last
          : null,
    );
    item.add(_textUriListFormat(uriListBody));
    item.add(_gnomeCopiedFilesFormat(gnomeStr));
    item.add(Formats.plainText(gnomeStr));

    await clipboard.write([item]);
    if (Platform.isLinux) {
      unawaited(_mirrorLinuxFileClipboardToNativeTools(uriListBody));
    }
    if (!mounted) return;
    setState(() {
      _systemClipboardHasFiles = true;
    });
  }

  /// Flutter/super_clipboard may not expose file payloads to the compositor
  /// clipboard on Linux. Publish [text/uri-list] once via wl-copy or xclip
  /// (a second MIME type would require a separate clipboard write and would
  /// overwrite the first, so we keep a single native mirror of the URI list).
  Future<void> _mirrorLinuxFileClipboardToNativeTools(
    String uriListBody,
  ) async {
    Future<bool> runWithStdin(
      String executable,
      List<String> args,
      List<int> bytes,
    ) async {
      try {
        final p = await Process.start(executable, args, runInShell: false);
        p.stdin.add(bytes);
        await p.stdin.close();
        return await p.exitCode == 0;
      } catch (_) {
        return false;
      }
    }

    Future<bool> whichOk(String name) async {
      try {
        final r = await Process.run('which', [name], runInShell: false);
        return r.exitCode == 0;
      } catch (_) {
        return false;
      }
    }

    final uriBytes = utf8.encode(uriListBody);

    if (await whichOk('wl-copy')) {
      if (await runWithStdin('wl-copy', [
        '--type',
        'text/uri-list',
      ], uriBytes)) {
        return;
      }
    }
    if (await whichOk('xclip')) {
      await runWithStdin('xclip', [
        '-selection',
        'clipboard',
        '-t',
        'text/uri-list',
      ], uriBytes);
    }
  }

  ({List<String> paths, bool move}) _parseGnomeCopiedFiles(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return (paths: <String>[], move: false);
    final op = lines.first.toLowerCase();
    final move = op == 'cut';
    final paths = <String>[];
    for (final line in lines.skip(1)) {
      try {
        final uri = Uri.parse(line);
        if (uri.scheme == 'file') {
          paths.add(uri.toFilePath(windows: false));
        }
      } catch (_) {}
    }
    return (paths: paths, move: move);
  }

  Future<({List<String> paths, bool move})>
  _readFilePayloadFromSystemClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return (paths: <String>[], move: false);

    try {
      final reader = await clipboard.read();

      // 1) Prefer GNOME-style "x-special/gnome-copied-files" payload when present
      final gnome = await reader.readValue<String>(_gnomeCopiedFilesFormat);
      if (gnome != null) {
        final parsed = _parseGnomeCopiedFiles(gnome);
        if (parsed.paths.isNotEmpty) return parsed;
      }

      // 1b) Fallback: some sources store it as plain text.
      final text = await reader.readValue<String>(Formats.plainText);
      if (text != null) {
        final parsed = _parseGnomeCopiedFiles(text);
        if (parsed.paths.isNotEmpty) return parsed;
      }

      // 1c) Standard multi-file selection: [text/uri-list] body.
      final uriListRaw = await reader.readValue<String>(_textUriListFormat);
      if (uriListRaw != null) {
        final fromList = _pathsFromUriListText(uriListRaw);
        if (fromList.isNotEmpty) {
          return (paths: fromList, move: false);
        }
      }

      // 2) Otherwise, gather file URIs.
      final paths = <String>[];
      for (final item in reader.items) {
        final uri = await item.readValue<Uri>(Formats.fileUri);
        if (uri != null && uri.scheme == 'file') {
          paths.add(uri.toFilePath(windows: false));
        }
      }
      return (paths: paths, move: false);
    } catch (_) {
      return (paths: <String>[], move: false);
    }
  }

  void _applyCopyProgressToUi(
    int bytesCopied,
    String? currentFileName, {
    bool adjustTotalIfUnknown = true,
  }) {
    // Nessun throttle: la barra copia e il pannello devono ricevere ogni tick (rsync/du/unawaited).
    _copyProgress.stats.applyCopyProgress(
      bytesCopied: bytesCopied,
      currentFileName: currentFileName,
      adjustTotalIfUnknown: adjustTotalIfUnknown,
    );
  }

  void _armCopyDestinationLiveRefresh() {
    _copyLiveRefreshTimer?.cancel();
    _copyLiveRefreshTimer = Timer.periodic(const Duration(milliseconds: 1100), (
      _,
    ) {
      if (!mounted || !_copyProgress.active.value) return;
      _refreshVisiblePanesIfCopyDestMatches();
    });
  }

  void _disarmCopyDestinationLiveRefresh() {
    _copyLiveRefreshTimer?.cancel();
    _copyLiveRefreshTimer = null;
  }

  void _refreshVisiblePanesIfCopyDestMatches() {
    final d = _copyProgress.stats.destDirectoryPath;
    if (d == null || d.isEmpty) return;
    final normD = path.normalize(d);
    if (currentPath != null && path.normalize(currentPath!) == normD) {
      if (_copySilentReloadMainBusy) return;
      _copySilentReloadMainBusy = true;
      unawaited(
        _navigateToPath(
          currentPath!,
          addToHistory: false,
          silentRefresh: true,
        ).whenComplete(() {
          if (mounted) _copySilentReloadMainBusy = false;
        }),
      );
    } else if (isSplitView &&
        secondPanePath != null &&
        path.normalize(secondPanePath!) == normD) {
      if (_copySilentReloadSecondBusy) return;
      _copySilentReloadSecondBusy = true;
      unawaited(
        _loadDirectoryForPane(
          secondPanePath!,
          true,
          silentRefresh: true,
        ).whenComplete(() {
          if (mounted) _copySilentReloadSecondBusy = false;
        }),
      );
    }
  }

  void _openComputerPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ComputerLocationsPage(
          onOpenPath: (String openPath) {
            Navigator.of(ctx).pop();
            if (!mounted) return;
            setState(() {
              _isSecondPaneFocused = false;
            });
            _navigateToPath(openPath);
          },
          onFindFilesAndFolders: () {
            Navigator.of(ctx).pop();
            if (!mounted) return;
            _openFileSearch();
          },
          onOpenPackageManager: () {
            Navigator.of(ctx).pop();
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PackageManager()),
            );
          },
          onOpenSystemUpdates: () {
            Navigator.of(ctx).pop();
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UpdateChecker()),
            );
          },
        ),
      ),
    );
  }

  /// Byte totali per file o cartella (`du -sb` per directory, timeout lungo).
  Future<int> _pathTotalBytes(String p) async {
    final t = await FileSystemEntity.type(p);
    if (t == FileSystemEntityType.directory) {
      try {
        final duResult =
            await Process.run('du', [
              '-sb',
              p,
            ], environment: FileService.cLocaleEnvironment()).timeout(
              const Duration(seconds: 120),
              onTimeout: () => ProcessResult(-1, 0, '', 'Timeout'),
            );
        if (duResult.exitCode == 0) {
          final output = duResult.stdout.toString().trim();
          final sizeStr = output.split('\t').first.split('\n').last;
          return int.tryParse(sizeStr) ?? 0;
        }
      } catch (_) {}
      return 0;
    }
    if (t == FileSystemEntityType.file) {
      try {
        return (await File(p).stat()).size;
      } catch (_) {}
    }
    return 0;
  }

  /// Copia albero: [FileService] mescola valori **assoluti** (rsync xfer, `du` dest) con la stessa
  /// etichetta; il delta semplice rompe quando `du` supera rsync e poi rsync resta indietro.
  /// Per file singoli (Rust/Dart) [currentFileName] cambia a ogni file: si “congela” il max della
  /// sessione precedente in [rollingTotal].
  Future<void> Function(int fileBytesCopied, String? currentFileName)
  _makeDirectoryTreeProgressHandler({
    required int progressBaseBytes,
    required bool adjustTotalIfUnknown,
  }) {
    int rollingTotal = 0;
    int sessionMax = 0;
    String? lastFileName;
    return (fileBytesCopied, currentFileName) async {
      final nameChanged = lastFileName != currentFileName;
      if (nameChanged) {
        rollingTotal += sessionMax;
        sessionMax = 0;
        lastFileName = currentFileName;
      }
      if (fileBytesCopied > sessionMax) {
        sessionMax = fileBytesCopied;
      }
      if (!mounted) return;
      _applyCopyProgressToUi(
        progressBaseBytes + rollingTotal + sessionMax,
        currentFileName,
        adjustTotalIfUnknown: adjustTotalIfUnknown,
      );
    };
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initializeCache();
    _loadFavorites();
    _loadTabs();
    _loadPreferences();
    _loadWindowPreferences();
    // Make paste work across app instances (system clipboard).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_refreshSystemClipboardPasteState());
    });

    // Ensure we keep receiving keyboard modifiers (Ctrl-left for multi-select).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await GithubAppUpdateService.checkAndMaybeNotify(
        onNewer: (version, releaseUrl) {
          if (!mounted) return;
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.appUpdateNewVersionAvailable(version)),
              action: SnackBarAction(
                label: loc.appUpdateViewRelease,
                onPressed: () {
                  unawaited(GithubAppUpdateService.openUrl(releaseUrl));
                },
              ),
            ),
          );
        },
      );
    });

    // Modificatori: [DesktopInputBridge] è registrato in main() su [HardwareKeyboard].

    // Setup selection marquee controller
    _updateSelectionController();
    _selectionController.onSelectionChanged.listen((selectedIds) {
      if (mounted) {
        setState(() {
          _isSecondPaneFocused = false;
          selectedFiles = selectedIds.toSet();
          if (selectedFiles.isNotEmpty) {
            final firstSelected = files.firstWhere(
              (f) => selectedFiles.contains(f.path),
              orElse: () => files.isNotEmpty
                  ? files.first
                  : FileInfo(
                      path: '',
                      name: '',
                      size: 0,
                      isDir: false,
                      modified: 0,
                      created: 0,
                    ),
            );
            previewFile = firstSelected;
          } else if (selectedFiles.isEmpty) {
            previewFile = null;
          }
        });
      }
    });
    _secondPaneSelectionController.onSelectionChanged.listen((selectedIds) {
      if (mounted) {
        setState(() {
          secondPaneSelectedFiles = selectedIds.toSet();
          if (secondPaneSelectedFiles.isNotEmpty) {
            final firstSelected = secondPaneFiles.firstWhere(
              (f) => secondPaneSelectedFiles.contains(f.path),
              orElse: () => secondPaneFiles.isNotEmpty
                  ? secondPaneFiles.first
                  : FileInfo(
                      path: '',
                      name: '',
                      size: 0,
                      isDir: false,
                      modified: 0,
                      created: 0,
                    ),
            );
            secondPanePreviewFile = firstSelected;
          } else if (secondPaneSelectedFiles.isEmpty) {
            secondPanePreviewFile = null;
          }
        });
      }
    });
    if (DesktopInputBridge.shouldSyncKeyboardEachFrame) {
      _waylandKeyboardFrameSyncActive = true;
      WidgetsBinding.instance.addPersistentFrameCallback(
        _waylandKeyboardFrameCallback,
      );
    }
    _memoryMaintenanceTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted || _copyProgress.active.value) return;
      PaintingBinding.instance.imageCache.clear();
      ThumbnailCacheService.maintenanceTrim();
    });
  }

  void _updateSelectionController() {
    // Ottimizzazione RAM: usa iteratore invece di creare una nuova lista
    _selectionController.allItemsGetter = () {
      final paths = <String>[];
      for (final f in files) {
        paths.add(f.path);
      }
      return paths;
    };
  }

  // _updateSecondPaneSelectionController removed (unused).

  @override
  void dispose() {
    _waylandKeyboardFrameSyncActive = false;
    _keyboardFocusNode.dispose();
    _memoryMaintenanceTimer?.cancel();
    copyRefreshTimer?.cancel();
    _copyLiveRefreshTimer?.cancel();
    _stopDirectoryWatches();
    _copyProgress.dispose();
    _fileListScrollController.dispose();
    _secondPaneScrollController.dispose();
    _selectionController.dispose();
    _secondPaneSelectionController.dispose();
    _networkBookmarksRevision.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      singleClickToOpen = prefs.getBool('single_click_to_open') ?? false;
      doubleClickToRename = prefs.getBool('double_click_to_rename') ?? false;
      openEachFolderInNewWindow =
          prefs.getBool('open_each_folder_new_window') ?? false;
      alwaysStartWithDoublePane = prefs.getBool('always_double_pane') ?? false;
      ignoreViewPreferences = prefs.getBool('ignore_view_prefs') ?? false;
      disableFileOperationQueue = prefs.getBool('disable_file_queue') ?? false;
      doubleClickEmptyAreaToGoUp =
          prefs.getBool('double_click_empty_go_up') ?? false;
      executableTextFilesBehavior =
          prefs.getInt('executable_text_behavior') ?? 2;
      useCollapsedMenuBar = prefs.getBool('collapsed_menu_bar') ?? false;

      // Load view preferences (default_* dalla schermata Preferenze se view_* assenti)
      final viewModeIndex = prefs.getInt('view_mode') ??
          prefs.getInt('default_view_mode') ??
          0;
      viewMode =
          ViewMode.values[viewModeIndex.clamp(0, ViewMode.values.length - 1)];
      showPreview = prefs.getBool('show_preview') ?? true;
      previewFastMode = prefs.getBool('preview_fast_mode') ?? false;
      showHiddenFiles = prefs.getBool('show_hidden_files') ?? false;
      showHiddenFilesSecondPane =
          prefs.getBool('show_hidden_files_second_pane') ?? showHiddenFiles;
      showSystemFiles = prefs.getBool('show_system_files') ?? true;
      isSplitView = prefs.getBool('is_split_view') ?? false;
      gridZoomLevel = prefs.getInt('grid_zoom_level') ??
          prefs.getInt('default_grid_zoom_level') ??
          3;
      showRightPanel = prefs.getBool('show_right_panel') ?? true;

      // Apply alwaysStartWithDoublePane if set
      if (alwaysStartWithDoublePane) {
        isSplitView = true;
      }

      // Se il doppio schermo è attivo e l'app non è a schermo intero, imposta zoom a 4/10
      if (isSplitView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final screenSize = MediaQuery.of(context).size;
            // Verifica se l'app non è a schermo intero controllando se la larghezza è inferiore a una soglia
            // Assumiamo che se la larghezza è inferiore a 1600px, probabilmente non è a schermo intero
            final isNotFullscreen = screenSize.width < 1600;
            if (isNotFullscreen && gridZoomLevel != 4) {
              setState(() {
                gridZoomLevel = 4;
                _saveViewPreferences();
              });
            }
          }
        });
      }

      // Se il doppio schermo è attivo, inizializza il secondo pannello dalla home
      if (isSplitView && secondPanePath == null) {
        FileService.getHomeDirectory().then((homeDir) {
          if (mounted) {
            setState(() {
              secondPanePath = homeDir;
              secondPaneNavigationHistory = [homeDir];
              secondPaneNavigationIndex = 0;
            });
            _loadDirectoryForPane(homeDir, true);
          }
        });
      }
    });
  }

  Future<void> _saveViewPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('view_mode', viewMode.index);
    await prefs.setBool('show_preview', showPreview);
    await prefs.setBool('preview_fast_mode', previewFastMode);
    await prefs.setBool('show_hidden_files', showHiddenFiles);
    await prefs.setBool(
      'show_hidden_files_second_pane',
      showHiddenFilesSecondPane,
    );
    await prefs.setBool('show_system_files', showSystemFiles);
    await prefs.setBool('is_split_view', isSplitView);
    await prefs.setInt('grid_zoom_level', gridZoomLevel);
    await prefs.setBool('show_right_panel', showRightPanel);
  }

  Future<void> _loadWindowPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final savedWidth = prefs.getDouble('window_width');
      final savedHeight = prefs.getDouble('window_height');
      final savedX = prefs.getDouble('window_offset_x');
      final savedY = prefs.getDouble('window_offset_y');

      if (savedWidth != null && savedHeight != null) {
        await windowManager.setSize(Size(savedWidth, savedHeight));
      }

      if (savedX != null && savedY != null) {
        await windowManager.setPosition(Offset(savedX, savedY));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading window preferences: $e');
      }
    }
  }

  Future<void> _initializeCache() async {
    await ThumbnailCacheService.initialize();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_paths') ?? [];
    setState(() {
      favoritePaths = favorites;
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_paths', favoritePaths);
  }

  Future<void> _loadTabs() async {
    final prefs = await SharedPreferences.getInstance();
    final tabsJson = prefs.getStringList('tabs') ?? [];
    final parsed = tabsJson.map((json) {
      final parts = json.split('|');
      return {
        'path': parts[0],
        'name': parts.length > 1 ? parts[1] : path.basename(parts[0]),
      };
    }).toList();

    final kept = <Map<String, String>>[];
    for (final t in parsed) {
      final p = t['path'] ?? '';
      if (p.isEmpty) continue;
      try {
        final d = Directory(p);
        if (!await d.exists()) continue;
        await d.list(followLinks: false).isEmpty;
        kept.add({'path': p, 'name': t['name'] ?? path.basename(p)});
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      tabs = kept;
      if (tabs.isEmpty && currentPath != null) {
        tabs.add({'path': currentPath!, 'name': path.basename(currentPath!)});
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // If initial path is provided (from command line), use it
      // Otherwise use home directory
      String pathToOpen;
      if (widget.initialPath != null && widget.initialPath!.isNotEmpty) {
        final dir = Directory(widget.initialPath!);
        if (!await dir.exists()) {
          pathToOpen = await FileService.getHomeDirectory();
        } else {
          // Esiste ma può non essere leggibile (es. /root con EUID utente)
          try {
            await dir.list(followLinks: false).isEmpty;
            pathToOpen = widget.initialPath!;
          } catch (_) {
            pathToOpen = await FileService.getHomeDirectory();
          }
        }
      } else {
        pathToOpen = await FileService.getHomeDirectory();
      }

      if (mounted) {
        _navigateToPath(pathToOpen);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is DirectoryListingPermissionException
                  ? AppLocalizations.of(context).errorFolderRequiresOpenAsRoot
                  : AppLocalizations.of(context).snackInitError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _navigateToPath(
    String newPath, {
    bool addToHistory = true,
    bool silentRefresh = false,
  }) async {
    if (silentRefresh) {
      FileService.clearDirectoryCache(newPath);
      try {
        final results = await Future.wait([
          FileService.listDirectory(
            newPath,
            showHidden: showHiddenFiles,
            showSystem: showSystemFiles,
          ),
          FileService.getDiskInfo(newPath),
        ]);
        if (!mounted) return;
        final fileList = results[0] as List<FileInfo>;
        final diskInfoMap = results[1] as Map<String, dynamic>;
        setState(() {
          files = fileList;
          currentDiskInfo = DiskInfo.fromJson(diskInfoMap);
        });
        _syncDirectoryWatches();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageForDirectoryLoadError(context, e))),
        );
      }
      return;
    }

    if (addToHistory && currentPath != null) {
      // Add to undo history
      undoHistory.add({
        'type': 'navigate',
        'oldPath': currentPath,
        'newPath': newPath,
        'oldIndex': navigationIndex,
        'newIndex': navigationIndex + 1,
      });
      if (undoHistory.length > maxHistorySize) {
        undoHistory.removeAt(0);
      }
      // Clear redo history when new action is performed
      redoHistory.clear();
    }
    // Invalidate listing cache: when leaving a folder drop old listing; when
    // reloading the same path (paste, refresh) drop current so listDirectory
    // cannot return a stale cached snapshot.
    if (currentPath != null) {
      if (currentPath != newPath) {
        FileService.clearDirectoryCache(currentPath!);
      } else {
        FileService.clearDirectoryCache(newPath);
      }
    }

    setState(() {
      isLoading = true;
      currentPath = newPath;
      selectedFiles.clear();
      previewFile = null;
      // Keep old files visible while loading for better UX
    });

    try {
      // Load directory and disk info in parallel for better performance
      final results = await Future.wait([
        FileService.listDirectory(
          newPath,
          showHidden: showHiddenFiles,
          showSystem: showSystemFiles,
        ),
        FileService.getDiskInfo(newPath),
      ]);

      final fileList = results[0] as List<FileInfo>;
      final diskInfoMap = results[1] as Map<String, dynamic>;

      if (addToHistory) {
        // Add to navigation history
        if (navigationIndex < navigationHistory.length - 1) {
          navigationHistory = navigationHistory.sublist(0, navigationIndex + 1);
        }
        navigationHistory.add(newPath);
        navigationIndex = navigationHistory.length - 1;
      }

      setState(() {
        files = fileList;
        currentDiskInfo = DiskInfo.fromJson(diskInfoMap);
        isLoading = false;
      });
      _syncDirectoryWatches();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageForDirectoryLoadError(context, e))),
      );
    }
  }

  void _navigateBack() {
    if (navigationIndex > 0) {
      navigationIndex--;
      _navigateToPath(navigationHistory[navigationIndex], addToHistory: false);
    }
  }

  void _goBack() {
    _navigateBack();
  }

  void _navigateSecondPaneBack() {
    if (secondPaneNavigationIndex > 0) {
      secondPaneNavigationIndex--;
      final target = secondPaneNavigationHistory[secondPaneNavigationIndex];
      setState(() {
        _isSecondPaneFocused = true;
        secondPanePath = target;
      });
      unawaited(_loadDirectoryForPane(target, true));
    }
  }

  void _navigateSecondPaneForward() {
    if (secondPaneNavigationIndex >= 0 &&
        secondPaneNavigationIndex < secondPaneNavigationHistory.length - 1) {
      secondPaneNavigationIndex++;
      final target = secondPaneNavigationHistory[secondPaneNavigationIndex];
      setState(() {
        _isSecondPaneFocused = true;
        secondPanePath = target;
      });
      unawaited(_loadDirectoryForPane(target, true));
    }
  }

  void _navigateToSecondPanePath(String newPath, {bool addToHistory = true}) {
    if (newPath.isEmpty) return;
    if (!isSplitView) return;

    final current = secondPanePath;
    if (addToHistory) {
      if (secondPaneNavigationIndex < secondPaneNavigationHistory.length - 1) {
        secondPaneNavigationHistory = secondPaneNavigationHistory.sublist(
          0,
          secondPaneNavigationIndex + 1,
        );
      }
      if (current == null || newPath != current) {
        secondPaneNavigationHistory.add(newPath);
        secondPaneNavigationIndex = secondPaneNavigationHistory.length - 1;
      }
    }

    setState(() {
      _isSecondPaneFocused = true;
      secondPanePath = newPath;
    });
    unawaited(_loadDirectoryForPane(newPath, true));
  }

  void _goBackInActivePane() {
    if (isSplitView && _isSecondPaneFocused) {
      _navigateSecondPaneBack();
      return;
    }
    _goBack();
  }

  void _navigateForward() {
    if (navigationIndex < navigationHistory.length - 1) {
      navigationIndex++;
      _navigateToPath(navigationHistory[navigationIndex], addToHistory: false);
    }
  }

  void _navigateUp() {
    if (currentPath == null) return;
    if (NetworkBrowserService.isSmbShellPath(currentPath!)) {
      final smbParent = NetworkBrowserService.smbShellParent(currentPath!);
      if (smbParent != null) {
        _navigateToPath(smbParent);
      }
      return;
    }
    if (currentPath == '/') return;
    final parent = path.dirname(currentPath!);
    if (parent != currentPath) {
      _navigateToPath(parent);
    }
  }

  void _refreshCurrentDirectory() {
    if (isSplitView && _isSecondPaneFocused && secondPanePath != null) {
      // Refresh del pannello destro
      _loadDirectoryForPane(secondPanePath!, true);
    } else if (currentPath != null) {
      // Refresh del pannello sinistro o unico pannello
      _navigateToPath(currentPath!, addToHistory: false);
    }
  }

  bool _canWatchDirectoryPath(String? p) {
    if (p == null || p.isEmpty) return false;
    if (NetworkBrowserService.isSmbShellPath(p)) return false;
    final low = p.toLowerCase();
    if (low.contains('/.gvfs/') || low.contains('/gvfs/')) return false;
    return true;
  }

  void _stopDirectoryWatches() {
    _directoryWatchMain?.cancel();
    _directoryWatchMain = null;
    _directoryWatchMainDebounce?.cancel();
    _directoryWatchMainDebounce = null;
    _directoryWatchSecond?.cancel();
    _directoryWatchSecond = null;
    _directoryWatchSecondDebounce?.cancel();
    _directoryWatchSecondDebounce = null;
  }

  void _scheduleSilentRefreshFromWatchMain() {
    _directoryWatchMainDebounce?.cancel();
    _directoryWatchMainDebounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted || currentPath == null) return;
      if (!_canWatchDirectoryPath(currentPath)) return;
      _navigateToPath(currentPath!, addToHistory: false, silentRefresh: true);
    });
  }

  void _scheduleSilentRefreshFromWatchSecond() {
    _directoryWatchSecondDebounce?.cancel();
    _directoryWatchSecondDebounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted || secondPanePath == null) return;
      if (!_canWatchDirectoryPath(secondPanePath)) return;
      unawaited(_loadDirectoryForPane(secondPanePath!, true, silentRefresh: true));
    });
  }

  void _bindMainDirectoryWatch() {
    _directoryWatchMain?.cancel();
    _directoryWatchMain = null;
    final p = currentPath;
    if (!_canWatchDirectoryPath(p)) return;
    try {
      final dir = Directory(p!);
      if (!dir.existsSync()) return;
      _directoryWatchMain = dir.watch(events: FileSystemEvent.all).listen(
        (_) => _scheduleSilentRefreshFromWatchMain(),
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _bindSecondDirectoryWatch() {
    _directoryWatchSecond?.cancel();
    _directoryWatchSecond = null;
    if (!isSplitView) return;
    final p = secondPanePath;
    if (!_canWatchDirectoryPath(p)) return;
    try {
      final dir = Directory(p!);
      if (!dir.existsSync()) return;
      _directoryWatchSecond = dir.watch(events: FileSystemEvent.all).listen(
        (_) => _scheduleSilentRefreshFromWatchSecond(),
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _syncDirectoryWatches() {
    _bindMainDirectoryWatch();
    _bindSecondDirectoryWatch();
  }

  void _handleFileSelected(
    FileInfo file, {
    bool isCtrlPressed = false,
    bool isShiftPressed = false,
    bool forceNoModifiers = false,
  }) {
    // [FileList] fonde pointer + DesktopInputBridge in questi flag: non unire
    // altre letture tastiera qui (doppio OR = Ctrl "appiccicato").
    final ctrl = forceNoModifiers ? false : isCtrlPressed;
    final shift = forceNoModifiers ? false : isShiftPressed;
    print(
      'DEBUG _handleFileSelected: file=${file.name}, ctrl=$ctrl, shift=$shift, forceNoModifiers=$forceNoModifiers',
    );
    if (isSplitView && _isSecondPaneFocused) {
      _secondPaneSelectionController.itemClicked(
        file.path,
        isCtrl: ctrl,
        isShift: shift,
      );
      return;
    }
    _selectionController.itemClicked(file.path, isCtrl: ctrl, isShift: shift);
  }

  void _handleFileDoubleClick(FileInfo file) {
    if (file.isDir) {
      _navigateToPath(file.path);
    } else {
      if (NetworkBrowserService.isSmbShellPath(file.path)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).smbShellFileOpenUnavailable,
              ),
            ),
          );
        }
        return;
      }
      // Prima verifica se è un eseguibile ELF (inclusi eseguibili Flutter)
      // Se lo è, eseguilo direttamente, altrimenti usa xdg-open
      FileService.isElfExecutable(file.path)
          .then((isElf) {
            if (isElf) {
              // Esegui direttamente l'eseguibile ELF (inclusi Flutter)
              FileService.executeFile(file.path)
                  .then((executed) {
                    if (!executed) {
                      // Se l'esecuzione diretta fallisce, prova con xdg-open
                      Process.run('xdg-open', [file.path]).catchError((e) {
                        if (mounted) {
                          setState(() {
                            previewFile = file;
                          });
                        }
                        return ProcessResult(0, 0, '', '');
                      });
                    }
                  })
                  .catchError((e) {
                    // Se c'è un errore, fallback a xdg-open
                    Process.run('xdg-open', [file.path]).catchError((e) {
                      if (mounted) {
                        setState(() {
                          previewFile = file;
                        });
                      }
                      return ProcessResult(0, 0, '', '');
                    });
                  });
            } else {
              // Per tutti gli altri file, usa xdg-open
              Process.run('xdg-open', [file.path]).catchError((e) {
                // If xdg-open fails, show preview
                if (mounted) {
                  setState(() {
                    previewFile = file;
                  });
                }
                return ProcessResult(0, 0, '', '');
              });
            }
          })
          .catchError((e) {
            // Se il controllo ELF fallisce, usa xdg-open come fallback
            Process.run('xdg-open', [file.path]).catchError((e) {
              if (mounted) {
                setState(() {
                  previewFile = file;
                });
              }
              return ProcessResult(0, 0, '', '');
            });
          });
    }
  }

  void _selectAll() {
    if (isSplitView && _isSecondPaneFocused) {
      _secondPaneSelectionController.selectAll(
        candidates: secondPaneFiles.map((f) => f.path),
      );
    } else {
      _selectionController.selectAll();
    }
  }

  void _deselectAll() {
    if (isSplitView && _isSecondPaneFocused) {
      _secondPaneSelectionController.clear();
      setState(() {
        secondPaneSelectedFiles.clear();
        secondPanePreviewFile = null;
      });
    } else {
      _selectionController.clear();
      setState(() {
        selectedFiles.clear();
        previewFile = null;
      });
    }
  }

  void _undo() {
    if (undoHistory.isEmpty) return;

    final lastAction = undoHistory.removeLast();
    redoHistory.add(lastAction);

    if (redoHistory.length > maxHistorySize) {
      redoHistory.removeAt(0);
    }

    switch (lastAction['type']) {
      case 'navigate':
        setState(() {
          navigationIndex = lastAction['oldIndex'] as int;
          currentPath = lastAction['oldPath'] as String?;
        });
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
        break;
      case 'delete':
        // Restore deleted file - would need to implement file restoration
        break;
      case 'rename':
        // Restore old name - would need to implement rename undo
        break;
    }
  }

  void _redo() {
    if (redoHistory.isEmpty) return;

    final lastAction = redoHistory.removeLast();
    undoHistory.add(lastAction);

    if (undoHistory.length > maxHistorySize) {
      undoHistory.removeAt(0);
    }

    switch (lastAction['type']) {
      case 'navigate':
        setState(() {
          navigationIndex = lastAction['newIndex'] as int;
          currentPath = lastAction['newPath'] as String?;
        });
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
        break;
    }
  }

  final FocusNode _keyboardFocusNode = FocusNode();
  bool _waylandKeyboardFrameSyncActive = false;

  void _waylandKeyboardFrameCallback(Duration _) {
    if (!_waylandKeyboardFrameSyncActive || !mounted) return;
    unawaited(HardwareKeyboard.instance.syncKeyboardState());
  }

  int? _kbCursorIndex;
  int? _kbCursorIndexSecond;
  int? _kbAnchorIndex;
  int? _kbAnchorIndexSecond;

  int _gridCrossAxisCount() => gridZoomLevel.clamp(1, 10) + 1;

  int _activeKeyboardStepForArrow(LogicalKeyboardKey key) {
    final isGrid = viewMode == ViewMode.grid;
    if (!isGrid) return 1;
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      return _gridCrossAxisCount();
    }
    return 1;
  }

  Future<void> _handleKeyboardRangeMove(LogicalKeyboardKey arrowKey) async {
    if (!(arrowKey == LogicalKeyboardKey.arrowLeft ||
        arrowKey == LogicalKeyboardKey.arrowRight ||
        arrowKey == LogicalKeyboardKey.arrowUp ||
        arrowKey == LogicalKeyboardKey.arrowDown)) {
      return;
    }

    final isSecond = isSplitView && _isSecondPaneFocused;
    final list = isSecond ? secondPaneFiles : files;
    if (list.isEmpty) return;

    final ctrl = DesktopInputBridge.instance.effectiveCtrlOrMeta();
    final shift = DesktopInputBridge.instance.effectiveShift();
    if (!(ctrl && shift)) return;

    final step = _activeKeyboardStepForArrow(arrowKey);
    final delta = (arrowKey == LogicalKeyboardKey.arrowRight)
        ? 1
        : (arrowKey == LogicalKeyboardKey.arrowLeft)
        ? -1
        : (arrowKey == LogicalKeyboardKey.arrowDown)
        ? step
        : -step;

    final controller = isSecond
        ? _secondPaneSelectionController
        : _selectionController;
    final scroll = isSecond
        ? _secondPaneScrollController
        : _fileListScrollController;

    int? cursor = isSecond ? _kbCursorIndexSecond : _kbCursorIndex;
    if (cursor == null) {
      if (controller.selectedIds.isNotEmpty) {
        final firstId = controller.selectedIds.first;
        final idx = list.indexWhere((f) => f.path == firstId);
        cursor = idx >= 0 ? idx : 0;
      } else {
        cursor = 0;
      }
    }

    final next = (cursor + delta).clamp(0, list.length - 1);
    if (isSecond) {
      _kbCursorIndexSecond = next;
    } else {
      _kbCursorIndex = next;
    }

    int? anchor = isSecond ? _kbAnchorIndexSecond : _kbAnchorIndex;
    anchor ??= cursor;
    if (isSecond) {
      _kbAnchorIndexSecond = anchor;
    } else {
      _kbAnchorIndex = anchor;
    }

    final a = anchor;
    final b = next;
    final start = a < b ? a : b;
    final end = a < b ? b : a;
    final ids = <String>{};
    for (var i = start; i <= end; i++) {
      ids.add(list[i].path);
    }
    controller.setSelected(ids);
    await controller.ensureItemVisible(
      list[next].path,
      scrollController: scroll,
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (kDebugMode) {
      print('RawKey Detected: $event');
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      // Keyboard-only multi-selection: Ctrl+Shift + arrows.
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        unawaited(_handleKeyboardRangeMove(event.logicalKey));
        return;
      }

      final isModifierPressed = DesktopInputBridge.instance
          .effectiveCtrlOrMeta();

      if (isModifierPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyC) {
          if (kDebugMode) {
            print('CTRL+C PRESSED');
          }
          // Determina quale pannello è attivo
          final activeSelectedFiles = isSplitView && _isSecondPaneFocused
              ? secondPaneSelectedFiles
              : selectedFiles;

          if (activeSelectedFiles.isNotEmpty) {
            setState(() {
              copiedFiles = List<String>.from(activeSelectedFiles);
              isMoveOperation = false;
            });
            unawaited(
              _writeFilePayloadToSystemClipboard(copiedFiles, move: false),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    copiedFiles.length == 1
                        ? AppLocalizations.of(context).snackOneFileCopied
                        : AppLocalizations.of(
                            context,
                          ).snackManyFilesCopied(copiedFiles.length),
                  ),
                ),
              );
            }
          }
        } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
          if (kDebugMode) {
            print('CTRL+V PRESSED');
          }
          if (isSplitView && _isSecondPaneFocused && secondPanePath != null) {
            unawaited(_pasteFilesToPath(secondPanePath!));
          } else if (currentPath != null) {
            unawaited(_pasteFiles());
          }
        } else if (event.logicalKey == LogicalKeyboardKey.keyX) {
          if (kDebugMode) {
            print('CTRL+X PRESSED');
          }
          final activeSelectedFiles = isSplitView && _isSecondPaneFocused
              ? secondPaneSelectedFiles
              : selectedFiles;

          if (activeSelectedFiles.isNotEmpty) {
            setState(() {
              copiedFiles = List<String>.from(activeSelectedFiles);
              isMoveOperation = true;
            });
            unawaited(
              _writeFilePayloadToSystemClipboard(copiedFiles, move: true),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    copiedFiles.length == 1
                        ? AppLocalizations.of(context).snackOneFileCut
                        : AppLocalizations.of(
                            context,
                          ).snackManyFilesCut(copiedFiles.length),
                  ),
                ),
              );
            }
          }
        } else if (event.logicalKey == LogicalKeyboardKey.f7 &&
            kDebugMode &&
            Platform.isLinux) {
          // Experimental: GTK-based drag from rust/src/lib.rs start_native_drag (single file).
          // Does not replace super_drag_and_drop; use to compare behaviour on Wayland/X11.
          final active = isSplitView && _isSecondPaneFocused
              ? secondPaneSelectedFiles
              : selectedFiles;
          if (active.length == 1 && mounted) {
            final p = active.first;
            final ok = RustFFI.startNativeDrag(p);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? 'GTK Rust drag avviato (F7 debug): $p'
                      : 'GTK Rust drag fallito (vedi log): $p',
                ),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'F7 (debug Linux): seleziona esattamente un file/cartella.',
                ),
              ),
            );
          }
        }
      }

      // F1–F6, Esc, Backspace: senza Ctrl/Meta (allineato alla dialog scorciatoie).
      if (!isModifierPressed) {
        if (event.logicalKey == LogicalKeyboardKey.f1) {
          _openFileSearch();
        } else if (event.logicalKey == LogicalKeyboardKey.f3) {
          if (kDebugMode) {
            print('F3 PRESSED');
          }
          _toggleSplitView();
        } else if (event.logicalKey == LogicalKeyboardKey.f2) {
          if (kDebugMode) {
            print('F2 PRESSED');
          }
          _openNewInstance();
        } else if (event.logicalKey == LogicalKeyboardKey.f5) {
          _refreshCurrentDirectory();
        } else if (event.logicalKey == LogicalKeyboardKey.f6) {
          if (kDebugMode) {
            print('F6 PRESSED');
          }
          setState(() {
            showRightPanel = !showRightPanel;
            if (showRightPanel) {
              showPreview = true;
            }
            _saveViewPreferences();
          });
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (kDebugMode) {
            print('ESC PRESSED');
          }
          _deselectAll();
        } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (kDebugMode) {
            print('BACKSPACE PRESSED');
          }
          _goBackInActivePane();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Focus(
      autofocus: true,
      focusNode: _keyboardFocusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.ignored;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (PointerDownEvent e) {
          // Keep global keyboard focus stable so Ctrl-left stays responsive
          // even after interacting with various focusable widgets.
          _keyboardFocusNode.requestFocus();
        },
        child: DropMonitor(
          formats: Formats.standardFormats,
          hitTestBehavior: HitTestBehavior.translucent,
          onDropEnded: (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              resetPointerGuardsAfterNativeDrag();
              if (mounted) {
                setState(() => _nativeDragSessionEpoch++);
              }
            });
          },
          child: Scaffold(
            appBar: null,
            body: ValueListenableBuilder<bool>(
              valueListenable: _copyProgress.active,
              builder: (context, copyActive, _) {
                return PopScope(
                  canPop: !copyActive,
                  onPopInvokedWithResult: (didPop, result) async {
                    if (copyActive && !didPop) {
                      final shouldClose = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => DialogEnterScope(
                          onEnterPressed: () =>
                              Navigator.pop(dialogContext, true),
                          child: AlertDialog(
                            title: Text(l10n.dialogCloseWhileCopyTitle),
                            content: Text(l10n.dialogCloseWhileCopyBody),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: Text(l10n.dialogCancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: Text(l10n.dialogCloseAnyway),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (shouldClose == true && mounted) {
                        _copyProgress.userCancel();
                        exit(0);
                      }
                    }
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Opacity(
                      opacity:
                          0.98, // Trasparenza al top per uniformità con lo sfondo
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              // Sidebar ridimensionabile
                              SizedBox(
                                width: sidebarWidth,
                                child: Sidebar(
                                  selectedPath:
                                      isSplitView && _isSecondPaneFocused
                                      ? secondPanePath
                                      : currentPath,
                                  networkBookmarksListenable:
                                      _networkBookmarksRevision,
                                  favoritePaths: favoritePaths,
                                  onComputer: _openComputerPage,
                                  onPathSelected: (path) {
                                    // Naviga nel pannello attivo
                                    if (isSplitView && _isSecondPaneFocused) {
                                      _navigateToSecondPanePath(path);
                                    } else {
                                      _navigateToPath(path);
                                    }
                                  },
                                  onAddPath: (path) {
                                    // Custom path added
                                  },
                                  onRemovePath: (pathToRemove) {
                                    // Path removed from list (not from disk)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).snackPathRemoved(
                                            path.basename(pathToRemove),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onFavoritePathsReordered: (paths) {
                                    setState(() {
                                      favoritePaths = paths;
                                    });
                                    _saveFavorites();
                                  },
                                ),
                              ),
                              // Divider ridimensionabile per la sidebar (invisibile ma funzionale)
                              GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    sidebarWidth =
                                        (sidebarWidth + details.delta.dx).clamp(
                                          100.0,
                                          400.0,
                                        );
                                  });
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.resizeColumn,
                                  child: Container(
                                    width: 4,
                                    color: Colors
                                        .transparent, // Rimosso colore per renderlo invisibile
                                  ),
                                ),
                              ),
                              // Main content
                              Expanded(
                                child: Row(
                                  children: [
                                    // Left side: Menu bar and file list
                                    Expanded(
                                      child: Column(
                                        children: [
                                          // Navigation bar with menu bar on the left (menu bar sopra i pulsanti avanti/indietro)
                                          custom.NavigationBar(
                                            currentPath: currentPath ?? '/',
                                            secondPanePath: isSplitView
                                                ? secondPanePath
                                                : null,
                                            isSecondPaneFocused:
                                                _isSecondPaneFocused,
                                            onBack: navigationIndex > 0
                                                ? _navigateBack
                                                : null,
                                            onForward:
                                                navigationIndex <
                                                    navigationHistory.length - 1
                                                ? _navigateForward
                                                : null,
                                            onSecondPaneBack:
                                                isSplitView &&
                                                    secondPaneNavigationIndex >
                                                        0
                                                ? () {
                                                    setState(
                                                      () =>
                                                          _isSecondPaneFocused =
                                                              true,
                                                    );
                                                    _navigateSecondPaneBack();
                                                  }
                                                : null,
                                            onSecondPaneForward:
                                                isSplitView &&
                                                    secondPaneNavigationIndex >=
                                                        0 &&
                                                    secondPaneNavigationIndex <
                                                        secondPaneNavigationHistory
                                                                .length -
                                                            1
                                                ? () {
                                                    setState(
                                                      () =>
                                                          _isSecondPaneFocused =
                                                              true,
                                                    );
                                                    _navigateSecondPaneForward();
                                                  }
                                                : null,
                                            onUp:
                                                currentPath != null &&
                                                    currentPath != '/'
                                                ? _navigateUp
                                                : null,
                                            onPathChanged: (path) {
                                              setState(() {
                                                _isSecondPaneFocused = false;
                                              });
                                              _navigateToPath(path);
                                            },
                                            onSecondPanePathChanged: (path) {
                                              _navigateToSecondPanePath(path);
                                            },
                                            viewMode: viewMode,
                                            onViewModeChanged: (mode) {
                                              setState(() {
                                                viewMode = mode;
                                                _saveViewPreferences();
                                              });
                                            },
                                            arrangeMenu:
                                                _buildArrangeToolbarMenuButton(),
                                            menuBar: GlassWrapper(
                                              opacity: 0.85,
                                              blur: 8.0,
                                              color: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 2,
                                                    ),
                                                child: useCollapsedMenuBar
                                                    ? Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child:
                                                            _buildCompactMenuBar(
                                                              l10n,
                                                            ),
                                                      )
                                                    : SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            _buildMenuButton(
                                                              l10n.menuTopFile,
                                                              _fileMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                            _buildMenuButton(
                                                              l10n.menuTopEdit,
                                                              _modificaMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                            _buildMenuButton(
                                                              l10n.menuTopView,
                                                              _visualizzaMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                            _buildMenuButton(
                                                              l10n.menuTopFavorites,
                                                              _preferitiMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                            _buildDirectThemeMenuButton(
                                                              l10n,
                                                            ),
                                                            _buildMenuButton(
                                                              l10n.menuTopTools,
                                                              _strumentiMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                            _buildMenuButton(
                                                              l10n.menuTopHelp,
                                                              _aiutoMenuItems(
                                                                l10n,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          // File list (split view if enabled)
                                          Expanded(
                                            child: isSplitView
                                                ? Row(
                                                    children: [
                                                      // First pane with flexible width
                                                      Expanded(
                                                        flex:
                                                            (splitViewRatio *
                                                                    100)
                                                                .round(),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _isSecondPaneFocused =
                                                                  false;
                                                            });
                                                            if (selectedFiles
                                                                .isNotEmpty) {
                                                              // Don't deselect when Ctrl is pressed
                                                              if (!KeyboardModifierState
                                                                  .instance
                                                                  .isCtrlPressed) {
                                                                _deselectAll();
                                                              }
                                                            }
                                                          },
                                                          onDoubleTap:
                                                              doubleClickEmptyAreaToGoUp
                                                              ? () {
                                                                  if (currentPath ==
                                                                      null) {
                                                                    return;
                                                                  }
                                                                  String?
                                                                  parent;
                                                                  if (NetworkBrowserService.isSmbShellPath(
                                                                    currentPath!,
                                                                  )) {
                                                                    parent =
                                                                        NetworkBrowserService.smbShellParent(
                                                                          currentPath!,
                                                                        );
                                                                  } else {
                                                                    final d = path
                                                                        .dirname(
                                                                          currentPath!,
                                                                        );
                                                                    parent =
                                                                        d !=
                                                                            currentPath
                                                                        ? d
                                                                        : null;
                                                                  }
                                                                  if (parent !=
                                                                      null) {
                                                                    _navigateToPath(
                                                                      parent,
                                                                    );
                                                                  }
                                                                }
                                                              : null,
                                                          child: isLoading
                                                              ? const Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                )
                                                              : _buildFileListWithContext(),
                                                        ),
                                                      ),
                                                      // Resizable divider
                                                      GestureDetector(
                                                        onHorizontalDragUpdate: (details) {
                                                          setState(() {
                                                            final screenWidth =
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.width;
                                                            final newPosition =
                                                                details
                                                                    .globalPosition
                                                                    .dx;
                                                            final sidebarWidth =
                                                                200.0; // Approximate sidebar width
                                                            final menuWidth =
                                                                200.0; // Menu width
                                                            final availableWidth =
                                                                screenWidth -
                                                                sidebarWidth -
                                                                menuWidth;
                                                            final relativePosition =
                                                                (newPosition -
                                                                    sidebarWidth -
                                                                    menuWidth) /
                                                                availableWidth;
                                                            splitViewRatio =
                                                                relativePosition
                                                                    .clamp(
                                                                      0.1,
                                                                      0.9,
                                                                    );
                                                          });
                                                        },
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .resizeColumn,
                                                          child: Container(
                                                            width: 4,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .outline
                                                                    .withOpacity(
                                                                      0.3,
                                                                    ),
                                                            child: Center(
                                                              child: Container(
                                                                width: 2,
                                                                height: double
                                                                    .infinity,
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.outline,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Second pane with flexible width
                                                      Expanded(
                                                        flex:
                                                            ((1 - splitViewRatio) *
                                                                    100)
                                                                .round(),
                                                        child: LayoutBuilder(
                                                          builder:
                                                              (
                                                                context,
                                                                constraints,
                                                              ) {
                                                                // Keep right pane zoom identical to left pane.
                                                                return _buildSecondPane();
                                                              },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : GestureDetector(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Don't deselect when Ctrl is pressed (for Ctrl+Click multi-select)
                                                        if (KeyboardModifierState
                                                            .instance
                                                            .isCtrlPressed) {
                                                          return;
                                                        }
                                                        if (selectedFiles
                                                            .isNotEmpty) {
                                                          _deselectAll();
                                                        }
                                                      },
                                                      onDoubleTap:
                                                          doubleClickEmptyAreaToGoUp
                                                          ? () {
                                                              if (currentPath ==
                                                                  null) {
                                                                return;
                                                              }
                                                              String? parent;
                                                              if (NetworkBrowserService.isSmbShellPath(
                                                                currentPath!,
                                                              )) {
                                                                parent =
                                                                    NetworkBrowserService.smbShellParent(
                                                                      currentPath!,
                                                                    );
                                                              } else {
                                                                final d = path
                                                                    .dirname(
                                                                      currentPath!,
                                                                    );
                                                                parent =
                                                                    d !=
                                                                        currentPath
                                                                    ? d
                                                                    : null;
                                                              }
                                                              if (parent !=
                                                                  null) {
                                                                _navigateToPath(
                                                                  parent,
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                      child: isLoading
                                                          ? const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : _buildFileListWithContext(),
                                                    ),
                                                  ),
                                          ),
                                          // Solo questa fascia si ricostruisce quando avanza la copia (non tutta la lista file).
                                          ListenableBuilder(
                                            listenable: Listenable.merge([
                                              _copyProgress.active,
                                              _copyProgress.stats,
                                            ]),
                                            builder: (context, _) {
                                              final s = _copyProgress.stats;
                                              final copyOn =
                                                  _copyProgress.active.value;
                                              return StatusBar(
                                                itemCount: files.length,
                                                diskInfo:
                                                    isSplitView &&
                                                        _isSecondPaneFocused
                                                    ? secondPaneDiskInfo
                                                    : currentDiskInfo,
                                                isCopying: copyOn,
                                                copySourceName: s.sourceName,
                                                copyDestName: s.destName,
                                                copyTotalBytes: s.totalBytes,
                                                copyCopiedBytes: s.copiedBytes,
                                                copySpeedBytesPerSecond:
                                                    s.speedBytesPerSecond,
                                                copyCurrentFile: s.currentFile,
                                                copyProgressFraction:
                                                    s.displayProgressFraction,
                                                copyDisplayTotalBytes:
                                                    s.displayTotalBytesForLabel,
                                                copyEstimatedTotal:
                                                    s.displayUsesEstimatedTotal,
                                                copyPanelTitle: s.panelTitle,
                                                copyLeadingIcon: s.leadingIcon,
                                                onCancelCopy: copyOn
                                                    ? () {
                                                        _copyProgress
                                                            .userCancel();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              ).copyCancelled,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    : null,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Divider ridimensionabile per il pannello destro (invisibile ma funzionale)
                                    if (showRightPanel) ...[
                                      GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          setState(() {
                                            rightPanelWidth =
                                                (rightPanelWidth -
                                                        details.delta.dx)
                                                    .clamp(100.0, 400.0);
                                          });
                                        },
                                        child: MouseRegion(
                                          cursor:
                                              SystemMouseCursors.resizeColumn,
                                          child: Container(
                                            width: 4,
                                            color: Colors
                                                .transparent, // Rimosso colore per renderlo invisibile
                                          ),
                                        ),
                                      ),
                                      // Tools panel on the right (ridimensionabile)
                                      SizedBox(
                                        width: rightPanelWidth,
                                        child: Container(
                                          color: Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor, // Usa lo stesso colore di sfondo del tema
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Builder(
                                                  builder: (context) {
                                                    final theme = Theme.of(
                                                      context,
                                                    );
                                                    final textTheme =
                                                        theme.textTheme;
                                                    final enableTextShadow =
                                                        (textTheme
                                                                .titleSmall
                                                                ?.shadows !=
                                                            null &&
                                                        textTheme
                                                            .titleSmall!
                                                            .shadows!
                                                            .isNotEmpty);
                                                    final textShadow =
                                                        enableTextShadow
                                                        ? textTheme
                                                              .titleSmall!
                                                              .shadows
                                                        : null;
                                                    return Text(
                                                      l10n.menuTopTools,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: textShadow,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons.search,
                                                            ),
                                                            title: Text(
                                                              l10n.menuFind,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap:
                                                                _openFileSearch,
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons.apps,
                                                            ),
                                                            title: Text(
                                                              l10n.toolsPackages,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) =>
                                                                          const PackageManager(),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons.update,
                                                            ),
                                                            title: Text(
                                                              l10n.toolsUpdates,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) =>
                                                                          const UpdateChecker(),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons
                                                                  .create_new_folder,
                                                            ),
                                                            title: Text(
                                                              l10n.menuNewFolder,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              _createNewFolder();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons
                                                                  .description_outlined,
                                                            ),
                                                            title: Text(
                                                              l10n
                                                                  .ctxNewTextDocumentShort,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              unawaited(
                                                                _createEmptyDocumentFromKind(
                                                                  kind:
                                                                      'new_txt',
                                                                  secondPane:
                                                                      false,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons
                                                                  .description,
                                                            ),
                                                            title: Text(
                                                              l10n
                                                                  .ctxNewWordDocument,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              unawaited(
                                                                _createEmptyDocumentFromKind(
                                                                  kind:
                                                                      'new_docx',
                                                                  secondPane:
                                                                      false,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons
                                                                  .grid_on_outlined,
                                                            ),
                                                            title: Text(
                                                              l10n
                                                                  .ctxNewExcelSpreadsheet,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              unawaited(
                                                                _createEmptyDocumentFromKind(
                                                                  kind:
                                                                      'new_xlsx',
                                                                  secondPane:
                                                                      false,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final theme =
                                                              Theme.of(context);
                                                          final textTheme =
                                                              theme.textTheme;
                                                          final enableTextShadow =
                                                              (textTheme
                                                                      .bodyMedium
                                                                      ?.shadows !=
                                                                  null &&
                                                              textTheme
                                                                  .bodyMedium!
                                                                  .shadows!
                                                                  .isNotEmpty);
                                                          final textShadow =
                                                              enableTextShadow
                                                              ? textTheme
                                                                    .bodyMedium!
                                                                    .shadows
                                                              : null;
                                                          return ListTile(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            dense: true,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4,
                                                                ),
                                                            leading: const Icon(
                                                              Icons.splitscreen,
                                                            ),
                                                            title: Text(
                                                              l10n.shortcutSplitView,
                                                              style: TextStyle(
                                                                shadows:
                                                                    textShadow,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              _toggleSplitView();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      // Preview panel (only when right panel is visible).
                                                      if (showPreview &&
                                                          showRightPanel) ...[
                                                        PreviewPanel(
                                                          selectedFile:
                                                              previewFile,
                                                          fastMode:
                                                              previewFastMode,
                                                          onClose: () {
                                                            setState(() {
                                                              previewFile =
                                                                  null;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ListenableBuilder(
                                                listenable: Listenable.merge([
                                                  _copyProgress.active,
                                                  _copyProgress.stats,
                                                ]),
                                                builder: (context, _) {
                                                  if (!_copyProgress
                                                      .active
                                                      .value) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  final s = _copyProgress.stats;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: CopyProgress(
                                                      sourceName:
                                                          s.sourceName ?? '',
                                                      destName:
                                                          s.destName ?? '',
                                                      totalBytes: s.totalBytes,
                                                      copiedBytes:
                                                          s.copiedBytes,
                                                      progressFraction: s
                                                          .displayProgressFraction,
                                                      displayTotalBytes: s
                                                          .displayTotalBytesForLabel,
                                                      estimatedTotal: s
                                                          .displayUsesEstimatedTotal,
                                                      speedBytesPerSecond:
                                                          s.speedBytesPerSecond,
                                                      currentFile:
                                                          s.currentFile,
                                                      panelTitle: s.panelTitle,
                                                      leadingIcon:
                                                          s.leadingIcon,
                                                      onCancel: () {
                                                        _copyProgress
                                                            .userCancel();
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              AppLocalizations.of(
                                                                context,
                                                              ).copyCancelled,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // When the right panel is hidden, previews are shown inline
                          // in the file icon tiles (no separate overlay).
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondPane() {
    final l10n = AppLocalizations.of(context);
    if (secondPanePath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.splitscreen,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.paneSelectPathHint,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.labelChoosePath),
              onPressed: () async {
                final result = await FilePicker.platform.getDirectoryPath();
                if (result != null) {
                  _navigateToSecondPanePath(result);
                }
              },
            ),
          ],
        ),
      );
    }

    if (secondPaneFiles.isEmpty && !isLoading) {
      return Center(
        child: Text(
          l10n.emptyFolderLabel,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Rimossa la barra di navigazione separata - ora è unificata nella barra principale
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (secondPaneSelectedFiles.isNotEmpty) {
                setState(() {
                  secondPaneSelectedFiles.clear();
                });
              }
            },
            child: Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyC,
                ): const CopyIntent(),
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyV,
                ): const PasteIntent(),
                LogicalKeySet(
                  LogicalKeyboardKey.control,
                  LogicalKeyboardKey.keyX,
                ): const CutIntent(),
                LogicalKeySet(LogicalKeyboardKey.f1): const FindFilesIntent(),
                LogicalKeySet(LogicalKeyboardKey.f3): const SplitViewIntent(),
                LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
                LogicalKeySet(LogicalKeyboardKey.f2): const NewTabIntent(),
                LogicalKeySet(LogicalKeyboardKey.f6):
                    const ToggleRightPanelIntent(),
                LogicalKeySet(LogicalKeyboardKey.escape):
                    const DeselectAllIntent(),
                LogicalKeySet(LogicalKeyboardKey.backspace):
                    const GoBackIntent(),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  CopyIntent: CallbackAction<CopyIntent>(
                    onInvoke: (intent) {
                      if (secondPaneSelectedFiles.isNotEmpty) {
                        setState(() {
                          // Ottimizzazione RAM: evita copia lista
                          copiedFiles = List<String>.from(
                            secondPaneSelectedFiles,
                          );
                          isMoveOperation = false;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copiedFiles.length == 1
                                    ? AppLocalizations.of(
                                        context,
                                      ).snackOneFileCopied
                                    : AppLocalizations.of(
                                        context,
                                      ).snackManyFilesCopied(
                                        copiedFiles.length,
                                      ),
                              ),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                  ),
                  PasteIntent: CallbackAction<PasteIntent>(
                    onInvoke: (intent) {
                      if (copiedFiles.isNotEmpty && secondPanePath != null) {
                        _pasteFilesToPath(secondPanePath!);
                      }
                      return null;
                    },
                  ),
                  CutIntent: CallbackAction<CutIntent>(
                    onInvoke: (intent) {
                      if (secondPaneSelectedFiles.isNotEmpty) {
                        setState(() {
                          // Ottimizzazione RAM: evita copia lista
                          copiedFiles = List<String>.from(
                            secondPaneSelectedFiles,
                          );
                          isMoveOperation = true;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copiedFiles.length == 1
                                    ? AppLocalizations.of(
                                        context,
                                      ).snackOneFileCut
                                    : AppLocalizations.of(
                                        context,
                                      ).snackManyFilesCut(copiedFiles.length),
                              ),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                  ),
                  SplitViewIntent: CallbackAction<SplitViewIntent>(
                    onInvoke: (intent) {
                      _toggleSplitView();
                      return null;
                    },
                  ),
                  FindFilesIntent: CallbackAction<FindFilesIntent>(
                    onInvoke: (intent) {
                      _openFileSearch();
                      return null;
                    },
                  ),
                  RefreshIntent: CallbackAction<RefreshIntent>(
                    onInvoke: (intent) {
                      _refreshCurrentDirectory();
                      return null;
                    },
                  ),
                  NewTabIntent: CallbackAction<NewTabIntent>(
                    onInvoke: (intent) {
                      _openNewInstance();
                      return null;
                    },
                  ),
                  ToggleRightPanelIntent:
                      CallbackAction<ToggleRightPanelIntent>(
                    onInvoke: (intent) {
                      setState(() {
                        showRightPanel = !showRightPanel;
                        if (showRightPanel) {
                          showPreview = true;
                        }
                        _saveViewPreferences();
                      });
                      return null;
                    },
                  ),
                  DeselectAllIntent: CallbackAction<DeselectAllIntent>(
                    onInvoke: (intent) {
                      _deselectAll();
                      return null;
                    },
                  ),
                  GoBackIntent: CallbackAction<GoBackIntent>(
                    onInvoke: (intent) {
                      _goBackInActivePane();
                      return null;
                    },
                  ),
                },
                child: Focus(
                  autofocus: true,
                  canRequestFocus: true,
                  skipTraversal: false,
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) return;
                    if (mounted) {
                      setState(() {
                        _isSecondPaneFocused = true;
                      });
                    }
                  },
                  onKeyEvent: (node, event) => KeyEventResult.ignored,
                  child: RepaintBoundary(
                    child: SelectionMarquee(
                      controller: _secondPaneSelectionController,
                      marqueeKey: _secondPaneMarqueeKey,
                      scrollController: _secondPaneScrollController,
                      enableShortcuts: true,
                      // SelectionMarquee pan is off while this is enabled; grid marquee
                      // lives in FileList (_GridMarqueeShell + deferred threshold) and the
                      // grid skips mouse drag-scroll via _GridScrollBehavior.
                      dragScrollBehavior: DragScrollBehavior.enabled,
                      config: SelectionConfig(
                        // Higher threshold so dragging files triggers DnD,
                        // not marquee selection, in borderline pointer movements.
                        minDragDistance: 36,
                        selectionDecoration: SelectionDecoration(
                          borderStyle: SelectionBorderStyle.solid,
                          borderWidth: 2.0,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderColor: Theme.of(context).colorScheme.primary,
                        ),
                        edgeAutoScroll: true,
                        autoScrollSpeed: 600.0,
                        edgeZoneFraction: 0.15,
                      ),
                      child: _wrapPaneFileDropTarget(
                        panePath: secondPanePath,
                        isSecondPane: true,
                        child: FileList(
                          files: secondPaneFiles,
                          selectedPath: secondPanePath,
                          selectedFiles: secondPaneSelectedFiles,
                          cutPaths: isMoveOperation
                              ? copiedFiles.toSet()
                              : const <String>{},
                          selectionController: _secondPaneSelectionController,
                          marqueeKey: _secondPaneMarqueeKey,
                          scrollController: _secondPaneScrollController,
                          previewFile: secondPanePreviewFile,
                          showPreview: showPreview,
                          showRightPanel: showRightPanel,
                          nativeDragSessionEpoch: _nativeDragSessionEpoch,
                          onFolderDrop: (folder, event) async {
                            await _handleDropOnFolder(event, folder.path);
                          },
                          onPaneBackgroundPrimaryTap: () {
                            setState(() {
                              _isSecondPaneFocused = true;
                            });
                            _secondPaneSelectionController.clear();
                          },
                          viewMode: viewMode,
                          gridZoomLevel:
                              gridZoomLevel, // Usa gridZoomLevel direttamente come il pannello sinistro
                          onZoomChanged: (level) {
                            setState(() {
                              gridZoomLevel = level.clamp(1, 10);
                              _saveViewPreferences();
                            });
                          },
                          onFileSelected: (file) {
                            setState(() {
                              _isSecondPaneFocused = true;
                            });
                            _handleFileSelected(file);
                            KeyboardModifierState.instance.syncNow();
                            if (singleClickToOpen &&
                                !KeyboardModifierState
                                    .instance.isCtrlOrMetaPressed &&
                                !KeyboardModifierState.instance.isShiftPressed) {
                              if (file.isDir) {
                                _navigateToSecondPanePath(file.path);
                              } else {
                                _handleFileDoubleClick(file);
                              }
                            }
                          },
                          onFileSelectedWithModifiers:
                              (
                                file, {
                                isCtrlPressed = false,
                                isShiftPressed = false,
                                forceNoModifiers = false,
                              }) {
                                setState(() {
                                  _isSecondPaneFocused = true;
                                });
                                _handleFileSelected(
                                  file,
                                  isCtrlPressed: isCtrlPressed,
                                  isShiftPressed: isShiftPressed,
                                  forceNoModifiers: forceNoModifiers,
                                );
                                if (singleClickToOpen &&
                                    !isCtrlPressed &&
                                    !isShiftPressed) {
                                  if (file.isDir) {
                                    _navigateToSecondPanePath(file.path);
                                  } else {
                                    _handleFileDoubleClick(file);
                                  }
                                }
                              },
                          onFileDoubleClick: (file) {
                            setState(() {
                              _isSecondPaneFocused =
                                  true; // Imposta focus sul secondo pannello
                            });
                            if (file.isDir) {
                              _navigateToSecondPanePath(file.path);
                            } else {
                              _handleFileDoubleClick(file);
                            }
                          },
                          onFileRightClick: (file, position) {
                            final selectionSnap = Set<String>.from(
                              _secondPaneSelectionController
                                  .selectedListenable
                                  .value,
                            );
                            setState(() {
                              _isSecondPaneFocused =
                                  true; // Imposta focus sul secondo pannello
                            });
                            _keyboardFocusNode.requestFocus();
                            if (file.path.isEmpty) {
                              if (_shouldBlockEmptyPaneContextMenu()) return;
                              setState(() {
                                _isSecondPaneFocused = true;
                              });
                              _keyboardFocusNode.requestFocus();
                              unawaited(
                                _showEmptySpaceContextMenuForSecondPane(
                                  position,
                                ),
                              );
                            } else {
                              _onItemContextMenuOpened();
                              _isRightClickingFile = true;
                              if (!mounted) return;
                              final clickedInSnap = _pathInSelectionSets(
                                file.path,
                                selectionSnap,
                                selectionSnap,
                              );
                              if (!clickedInSnap) {
                                _secondPaneSelectionController.clear();
                                _secondPaneSelectionController.itemClicked(
                                  file.path,
                                );
                              } else {
                                final ids = _secondPaneSelectionController
                                    .selectedListenable
                                    .value;
                                if (!_selectionCoversPaths(
                                  ids,
                                  selectionSnap,
                                )) {
                                  _secondPaneSelectionController.setSelected(
                                    selectionSnap,
                                  );
                                }
                              }
                              _showContextMenuForSecondPane(position, file);
                              scheduleMicrotask(() {
                                if (mounted) {
                                  _isRightClickingFile = false;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadDirectoryForPane(
    String path,
    bool isSecondPane, {
    bool silentRefresh = false,
  }) async {
    if (silentRefresh) {
      FileService.clearDirectoryCache(path);
    } else {
      if (isSecondPane && secondPanePath != null && secondPanePath != path) {
        FileService.clearDirectoryCache(secondPanePath!);
      } else if (!isSecondPane && currentPath != null && currentPath != path) {
        FileService.clearDirectoryCache(currentPath!);
      }
      final panePath = isSecondPane ? secondPanePath : currentPath;
      if (panePath != null && path == panePath) {
        FileService.clearDirectoryCache(path);
      }
    }

    try {
      // Pre-carica i metadati in background per eliminare lag al click
      // FileService.listDirectory è ottimizzato per eseguire in modo asincrono senza bloccare l'UI
      final results = await Future.wait([
        FileService.listDirectory(
          path,
          showHidden: isSecondPane
              ? showHiddenFilesSecondPane
              : showHiddenFiles,
          showSystem: showSystemFiles,
        ),
        FileService.getDiskInfo(path),
      ]);

      final dirFiles = results[0] as List<FileInfo>;
      final diskInfoMap = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          if (isSecondPane) {
            secondPaneFiles = dirFiles;
            secondPanePath = path;
            secondPaneDiskInfo = DiskInfo.fromJson(diskInfoMap);
          } else {
            files = dirFiles;
            currentPath = path;
            currentDiskInfo = DiskInfo.fromJson(diskInfoMap);
          }
        });
        _syncDirectoryWatches();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(messageForDirectoryLoadError(context, e))),
        );
      }
    }
  }

  bool _pathIsWithinOrEqual(String parent, String child) {
    final p = path.normalize(parent);
    final c = path.normalize(child);
    if (p == c) return true;
    final sep = Platform.pathSeparator;
    final prefix = p.endsWith(sep) ? p : '$p$sep';
    return c.startsWith(prefix);
  }

  Future<String?> _readDroppedPathFromReader(DataReader reader) async {
    final completer = Completer<String?>();
    var finished = false;
    void done(String? v) {
      if (!finished) {
        finished = true;
        completer.complete(v);
      }
    }

    final pr = reader.getValue<Uri>(Formats.fileUri, (uri) async {
      if (uri != null && uri.isScheme('file')) {
        try {
          done(uri.toFilePath(windows: Platform.isWindows));
          return;
        } catch (_) {}
      }
      done(null);
    });
    if (pr != null) {
      return completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
    }

    final completer2 = Completer<String?>();
    var finished2 = false;
    void done2(String? v) {
      if (!finished2) {
        finished2 = true;
        completer2.complete(v);
      }
    }

    final pr2 = reader.getValue<NamedUri>(Formats.uri, (named) async {
      final uri = named?.uri;
      if (uri != null && uri.isScheme('file')) {
        try {
          done2(uri.toFilePath(windows: Platform.isWindows));
          return;
        } catch (_) {}
      }
      done2(null);
    });
    if (pr2 != null) {
      return completer2.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
    }
    return null;
  }

  Future<List<String>> _collectDroppedSourcePaths(
    PerformDropEvent event,
  ) async {
    final out = <String>[];
    for (final item in event.session.items) {
      final reader = item.dataReader;
      if (reader != null) {
        final p = await _readDroppedPathFromReader(reader);
        if (p != null && p.isNotEmpty) out.add(p);
        continue;
      }
      final local = item.localData;
      if (local is List<String>) {
        out.addAll(local.where((s) => s.isNotEmpty));
      } else if (local is List) {
        for (final e in local) {
          if (e is String && e.isNotEmpty) out.add(e);
        }
      }
    }
    return out;
  }

  Future<void> _handleExternalDropOnPane(
    PerformDropEvent event,
    String destPath,
    bool isSecondPane,
  ) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    var sources = await _collectDroppedSourcePaths(event);
    if (sources.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.snackDropUnreadable)));
      }
      return;
    }

    final normDest = path.normalize(destPath);
    sources = sources.where((s) {
      final ns = path.normalize(s);
      if (ns == normDest) return false;
      if (_pathIsWithinOrEqual(ns, normDest)) return false;
      return true;
    }).toList();

    if (sources.isEmpty) return;

    final move = event.acceptedOperation == DropOperation.move;
    await _batchCopyOrMovePathsToDirectory(sources, destPath, move: move);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snackExternalDropDone)));
    if (!isSecondPane && currentPath != null) {
      _navigateToPath(currentPath!, addToHistory: false);
    } else if (isSecondPane && secondPanePath != null) {
      _loadDirectoryForPane(secondPanePath!, true);
    }
  }

  Future<void> _handleDropOnFolder(
    PerformDropEvent event,
    String folderPath,
  ) async {
    if (!mounted) return;
    var sources = await _collectDroppedSourcePaths(event);
    if (sources.isEmpty) return;
    final normDest = path.normalize(folderPath);
    sources = sources.where((s) {
      final ns = path.normalize(s);
      if (ns == normDest) return false;
      if (_pathIsWithinOrEqual(ns, normDest)) return false;
      return true;
    }).toList();
    if (sources.isEmpty) return;

    final move = event.acceptedOperation == DropOperation.move;
    await _batchCopyOrMovePathsToDirectory(sources, folderPath, move: move);
    if (!mounted) return;
    if (isSplitView && secondPanePath != null) {
      _loadDirectoryForPane(secondPanePath!, true);
    }
    if (currentPath != null) {
      _navigateToPath(currentPath!, addToHistory: false);
    }
  }

  Widget _wrapPaneFileDropTarget({
    required Widget child,
    required String? panePath,
    required bool isSecondPane,
  }) {
    if (panePath == null || panePath.isEmpty) {
      return child;
    }
    return DropRegion(
      formats: Formats.standardFormats,
      // translucent: consente al [Listener] della lista (click destro su sfondo)
      // di ricevere l’evento anche con aree senza figli hit-testabili; il drop resta attivo.
      hitTestBehavior: HitTestBehavior.translucent,
      onDropOver: (DropOverEvent event) {
        if (!dropSessionAcceptsFileItemsLenient(event.session)) {
          return DropOperation.none;
        }
        final ops = event.session.allowedOperations;
        if (ops.contains(DropOperation.copy)) return DropOperation.copy;
        if (ops.contains(DropOperation.move)) return DropOperation.move;
        return DropOperation.none;
      },
      onDropEnded: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          resetPointerGuardsAfterNativeDrag();
        });
      },
      onPerformDrop: (PerformDropEvent event) async {
        try {
          await _handleExternalDropOnPane(event, panePath, isSecondPane);
        } finally {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            resetPointerGuardsAfterNativeDrag();
          });
        }
      },
      child: child,
    );
  }

  Widget _buildFileListWithContext({int? adaptiveZoomLevel}) {
    final effectiveZoomLevel = adaptiveZoomLevel ?? gridZoomLevel;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
            const CopyIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            const PasteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX):
            const CutIntent(),
        LogicalKeySet(LogicalKeyboardKey.f1): const FindFilesIntent(),
        LogicalKeySet(LogicalKeyboardKey.f3): const SplitViewIntent(),
        LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.f2): const NewTabIntent(),
        LogicalKeySet(LogicalKeyboardKey.f6): const ToggleRightPanelIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const DeselectAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const GoBackIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CopyIntent: CallbackAction<CopyIntent>(
            onInvoke: (intent) {
              // Determina quale pannello è attivo
              final activeSelectedFiles = isSplitView && _isSecondPaneFocused
                  ? secondPaneSelectedFiles
                  : selectedFiles;

              if (activeSelectedFiles.isNotEmpty) {
                setState(() {
                  // Ottimizzazione RAM: evita copia lista
                  copiedFiles = List<String>.from(activeSelectedFiles);
                  isMoveOperation = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        copiedFiles.length == 1
                            ? AppLocalizations.of(context).snackOneFileCopied
                            : AppLocalizations.of(
                                context,
                              ).snackManyFilesCopied(copiedFiles.length),
                      ),
                    ),
                  );
                }
              }
              return null;
            },
          ),
          PasteIntent: CallbackAction<PasteIntent>(
            onInvoke: (intent) {
              // Determina in quale pannello incollare
              if (copiedFiles.isNotEmpty) {
                if (isSplitView &&
                    _isSecondPaneFocused &&
                    secondPanePath != null) {
                  _pasteFilesToPath(secondPanePath!);
                } else if (currentPath != null) {
                  _pasteFiles();
                }
              }
              return null;
            },
          ),
          SplitViewIntent: CallbackAction<SplitViewIntent>(
            onInvoke: (intent) {
              _toggleSplitView();
              return null;
            },
          ),
          FindFilesIntent: CallbackAction<FindFilesIntent>(
            onInvoke: (intent) {
              _openFileSearch();
              return null;
            },
          ),
          CutIntent: CallbackAction<CutIntent>(
            onInvoke: (intent) {
              // Determina quale pannello è attivo
              final activeSelectedFiles = isSplitView && _isSecondPaneFocused
                  ? secondPaneSelectedFiles
                  : selectedFiles;

              if (activeSelectedFiles.isNotEmpty) {
                setState(() {
                  // Ottimizzazione RAM: evita copia lista
                  copiedFiles = List<String>.from(activeSelectedFiles);
                  isMoveOperation = true;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        copiedFiles.length == 1
                            ? AppLocalizations.of(context).snackOneFileCut
                            : AppLocalizations.of(
                                context,
                              ).snackManyFilesCut(copiedFiles.length),
                      ),
                    ),
                  );
                }
              }
              return null;
            },
          ),
          RefreshIntent: CallbackAction<RefreshIntent>(
            onInvoke: (intent) {
              _refreshCurrentDirectory();
              return null;
            },
          ),
          NewTabIntent: CallbackAction<NewTabIntent>(
            onInvoke: (intent) {
              _openNewInstance();
              return null;
            },
          ),
          ToggleRightPanelIntent: CallbackAction<ToggleRightPanelIntent>(
            onInvoke: (intent) {
              setState(() {
                showRightPanel = !showRightPanel;
                if (showRightPanel) {
                  showPreview = true;
                }
                _saveViewPreferences();
              });
              return null;
            },
          ),
          DeselectAllIntent: CallbackAction<DeselectAllIntent>(
            onInvoke: (intent) {
              _deselectAll();
              return null;
            },
          ),
          GoBackIntent: CallbackAction<GoBackIntent>(
            onInvoke: (intent) {
              _goBackInActivePane();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          canRequestFocus: true,
          skipTraversal: false,
          onFocusChange: (hasFocus) {
            if (!hasFocus) return;
            if (mounted) {
              setState(() {
                _isSecondPaneFocused = false;
              });
            }
          },
          onKeyEvent: (node, event) => KeyEventResult.ignored,
          child: RepaintBoundary(
            child: SelectionMarquee(
              controller: _selectionController,
              marqueeKey: _marqueeKey,
              scrollController: _fileListScrollController,
              enableShortcuts: true,
              // SelectionMarquee pan is off while this is enabled; grid marquee
              // lives in FileList (_GridMarqueeShell + deferred threshold) and the
              // grid skips mouse drag-scroll via _GridScrollBehavior.
              dragScrollBehavior: DragScrollBehavior.enabled,
              config: SelectionConfig(
                // Higher threshold so dragging files triggers DnD,
                // not marquee selection, in borderline pointer movements.
                minDragDistance: 36,
                selectionDecoration: SelectionDecoration(
                  borderStyle: SelectionBorderStyle.solid,
                  borderWidth: 2.0,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  borderColor: Theme.of(context).colorScheme.primary,
                ),
                edgeAutoScroll: true,
                autoScrollSpeed: 600.0,
                edgeZoneFraction: 0.15,
              ),
              child: _wrapPaneFileDropTarget(
                panePath: currentPath,
                isSecondPane: false,
                child: FileList(
                  files: files,
                  selectedPath: currentPath,
                  selectedFiles: selectedFiles,
                  cutPaths: isMoveOperation
                      ? copiedFiles.toSet()
                      : const <String>{},
                  selectionController: _selectionController,
                  marqueeKey: _marqueeKey,
                  scrollController: _fileListScrollController,
                  previewFile: previewFile,
                  showPreview: showPreview,
                  showRightPanel: showRightPanel,
                  nativeDragSessionEpoch: _nativeDragSessionEpoch,
                  onFolderDrop: (folder, event) async {
                    await _handleDropOnFolder(event, folder.path);
                  },
                  onPaneBackgroundPrimaryTap: () {
                    // Don't deselect when Ctrl is pressed (for Ctrl+Click multi-select)
                    if (KeyboardModifierState.instance.isCtrlPressed) {
                      return;
                    }
                    setState(() {
                      _isSecondPaneFocused = false;
                    });
                    _deselectAll();
                  },
                  onFileSelected: (file) {
                    setState(() {
                      _isSecondPaneFocused =
                          false; // Imposta focus sul primo pannello
                    });
                    _handleFileSelected(file);
                    KeyboardModifierState.instance.syncNow();
                    if (singleClickToOpen &&
                        !KeyboardModifierState.instance.isCtrlOrMetaPressed &&
                        !KeyboardModifierState.instance.isShiftPressed) {
                      if (file.isDir) {
                        _navigateToPath(file.path);
                      } else {
                        _handleFileDoubleClick(file);
                      }
                    }
                  },
                  onFileSelectedWithModifiers:
                      (
                        file, {
                        isCtrlPressed = false,
                        isShiftPressed = false,
                        forceNoModifiers = false,
                      }) {
                        setState(() {
                          _isSecondPaneFocused = false;
                        });
                        _handleFileSelected(
                          file,
                          isCtrlPressed: isCtrlPressed,
                          isShiftPressed: isShiftPressed,
                          forceNoModifiers: forceNoModifiers,
                        );
                        if (singleClickToOpen &&
                            !isCtrlPressed &&
                            !isShiftPressed) {
                          if (file.isDir) {
                            _navigateToPath(file.path);
                          } else {
                            _handleFileDoubleClick(file);
                          }
                        }
                      },
                  onFileDoubleClick: _handleFileDoubleClick,
                  onFileRightClick: (file, position) {
                    final selectionSnap = Set<String>.from(
                      _selectionController.selectedListenable.value,
                    );
                    setState(() {
                      _isSecondPaneFocused =
                          false; // Imposta focus sul primo pannello
                    });
                    _keyboardFocusNode.requestFocus();
                    if (file.path.isEmpty) {
                      if (_shouldBlockEmptyPaneContextMenu()) return;
                      setState(() {
                        _isSecondPaneFocused = false;
                      });
                      _keyboardFocusNode.requestFocus();
                      unawaited(_showEmptySpaceContextMenu(position));
                    } else {
                      _onItemContextMenuOpened();
                      _isRightClickingFile = true;
                      // Subito dopo il down: niente ritardo di frame (evita race col controller).
                      if (!mounted) return;
                      final clickedInSnap = _pathInSelectionSets(
                        file.path,
                        selectionSnap,
                        selectionSnap,
                      );
                      if (!clickedInSnap) {
                        _selectionController.clear();
                        _selectionController.itemClicked(file.path);
                      } else {
                        final ids =
                            _selectionController.selectedListenable.value;
                        if (!_selectionCoversPaths(ids, selectionSnap)) {
                          _selectionController.setSelected(selectionSnap);
                        }
                      }
                      _showContextMenu(position, file: file);
                      scheduleMicrotask(() {
                        if (mounted) _isRightClickingFile = false;
                      });
                    }
                  },
                  viewMode: viewMode,
                  onViewModeChanged: (mode) {
                    setState(() {
                      viewMode = mode;
                      _saveViewPreferences();
                    });
                  },
                  gridZoomLevel: effectiveZoomLevel,
                  onZoomChanged: (level) {
                    setState(() {
                      gridZoomLevel = level.clamp(1, 10);
                      _saveViewPreferences();
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Removed: _handleDragSelection - now handled by selection_marquee package

  bool _isInTrash() {
    if (currentPath == null) return false;
    return currentPath!.contains('.local/share/Trash') ||
        currentPath!.contains('Trash') ||
        currentPath ==
            path.join(
              Platform.environment['HOME'] ?? '',
              '.local/share/Trash/files',
            );
  }

  bool _isTrashFilesFolder(String? dirPath) {
    if (dirPath == null || dirPath.isEmpty) return false;
    final n = path.normalize(dirPath);
    return n.contains('.local/share/Trash/files') || n.endsWith('Trash/files');
  }

  Future<void> _restoreTrashItems(
    List<String> trashEntryPaths, {
    required bool secondPane,
  }) async {
    final l10n = AppLocalizations.of(context);
    final home = await FileService.getHomeDirectory();
    var ok = 0;
    var fail = 0;
    for (final tp in trashEntryPaths) {
      final base = path.basename(tp);
      try {
        var original = await DesktopTrash.readOriginalPath(home, base);
        if (original == null || original.isEmpty) {
          if (!mounted) return;
          final pick = await FilePicker.platform.getDirectoryPath(
            dialogTitle: l10n.trashRestorePickFolderTitle,
          );
          if (pick == null) {
            fail++;
            continue;
          }
          original = path.join(pick, base);
        } else {
          await Directory(path.dirname(original)).create(recursive: true);
        }
        if (await File(original).exists() || await Directory(original).exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.trashRestoreTargetExists(path.basename(original)),
                ),
              ),
            );
          }
          fail++;
          continue;
        }
        final srcFile = File(tp);
        final srcDir = Directory(tp);
        if (await srcFile.exists()) {
          await srcFile.rename(original);
        } else if (await srcDir.exists()) {
          await srcDir.rename(original);
        } else {
          fail++;
          continue;
        }
        await DesktopTrash.deleteTrashInfo(home, base);
        ok++;
      } catch (_) {
        fail++;
      }
    }
    if (mounted) {
      setState(() {
        if (secondPane) {
          secondPaneSelectedFiles.clear();
          secondPanePreviewFile = null;
        } else {
          selectedFiles.clear();
          previewFile = null;
        }
      });
      if (secondPane) {
        _secondPaneSelectionController.clear();
      } else {
        _selectionController.clear();
      }
      if (secondPane && secondPanePath != null) {
        _loadDirectoryForPane(secondPanePath!, true);
      } else if (currentPath != null) {
        FileService.clearDirectoryCache(currentPath!);
        _navigateToPath(currentPath!, addToHistory: false);
      }
      if (ok > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.trashRestoredCount(ok))),
        );
      }
      if (fail > 0 && ok == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.trashRestoreFailed)),
        );
      }
    }
  }

  Future<void> _emptyTrash() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx, true),
        child: AlertDialog(
          title: Text(l10n.sidebarEmptyTrashTitle),
          content: Text(l10n.sidebarEmptyTrashBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.sidebarEmptyTrashConfirm),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final home = Platform.environment['HOME'] ?? '';
        final trashPath = path.join(home, '.local/share/Trash/files');
        final trashDir = Directory(trashPath);

        if (await trashDir.exists()) {
          await for (final entity in trashDir.list()) {
            try {
              if (entity is File) {
                await entity.delete(recursive: false);
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (e) {
              // Skip files that can't be deleted
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).sidebarTrashEmptied),
              ),
            );
            // Force refresh if currently in trash
            if (_isInTrash()) {
              _navigateToPath(currentPath ?? home, addToHistory: false);
            } else {
              // Clear cache and refresh
              FileService.clearDirectoryCache(trashPath);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).trashEmptyError(e.toString()),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _createEmptyDocumentFromKind({
    required String kind,
    required bool secondPane,
  }) async {
    final baseDir = secondPane ? secondPanePath : currentPath;
    if (baseDir == null || baseDir.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ext = switch (kind) {
      'new_txt' => '.txt',
      'new_docx' => '.docx',
      'new_xlsx' => '.xlsx',
      _ => '.txt',
    };
    final defaultStem = switch (kind) {
      'new_txt' => 'Document',
      'new_docx' => 'Document',
      'new_xlsx' => 'Workbook',
      _ => 'Document',
    };
    final controller = TextEditingController(text: defaultStem);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.ctxCreateNew),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.labelFileName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(ctx, true);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l10n.buttonCreate),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    var stem = controller.text.trim();
    if (stem.isEmpty) return;
    if (path.extension(stem).toLowerCase() != ext) {
      stem = '$stem$ext';
    }
    final filePath = path.join(baseDir, stem);
    try {
      final f = File(filePath);
      if (await f.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackRenameTargetExists)),
          );
        }
        return;
      }
      switch (kind) {
        case 'new_txt':
          await OfficeEmptyDocuments.writeUtf8TextFile(f);
          break;
        case 'new_docx':
          await OfficeEmptyDocuments.writeMinimalDocx(f);
          break;
        case 'new_xlsx':
          await OfficeEmptyDocuments.writeMinimalXlsx(f);
          break;
        default:
          await OfficeEmptyDocuments.writeUtf8TextFile(f);
      }
      if (secondPane && secondPanePath != null) {
        _loadDirectoryForPane(secondPanePath!, true);
      } else if (currentPath != null) {
        _navigateToPath(currentPath!, addToHistory: false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackDocumentCreated(path.basename(filePath)))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError(e.toString()))),
        );
      }
    }
  }

  Future<void> _showEmptySpaceContextMenu(Offset position) async {
    if (_shouldBlockEmptyPaneContextMenu()) return;
    // Difesa extra: alcuni widget (pane + lista) possono ricevere lo stesso
    // click destro “spazio vuoto” e chiamare showMenu più volte (soprattutto
    // alla prima apertura). Sopprimiamo le repliche ravvicinate.
    _suppressEmptyPaneContextMenuUntilMs =
        DateTime.now().millisecondsSinceEpoch + 12;
    _isRightClickingFile = false;
    final l10n = AppLocalizations.of(context);
    // Non bloccare l'apertura del menu: aggiorna lo stato paste in background.
    unawaited(_refreshSystemClipboardPasteState());
    if (!mounted) return;
    final value = await EmptySpacePaneMenu.show(
      context,
      globalPosition: position,
      l10n: l10n,
      showHiddenFiles: showHiddenFiles,
      pasteEnabled: copiedFiles.isNotEmpty || _systemClipboardHasFiles,
    );
    _isRightClickingFile = false;
    if (!mounted || value == null) return;
    await _ensurePopupMenuDismissed();
    if (!mounted) return;
    unawaited(_handleEmptySpaceAction(value));
  }

  /// Voci del menu «Disponi icone» (barra indirizzi e altri popup).
  List<PopupMenuEntry<String>> _arrangeIconMenuEntries() {
    final l10n = AppLocalizations.of(context);
    return [
      PopupMenuItem<String>(
        value: 'arrange_manual',
        child: RadioListTile<String>(
          title: Text(l10n.sortManual),
          value: 'manual',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'manual';
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<String>(
        value: 'arrange_name',
        child: RadioListTile<String>(
          title: Text(l10n.sortByName),
          value: 'name',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'name';
              _arrangeFiles('name');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<String>(
        value: 'arrange_size',
        child: RadioListTile<String>(
          title: Text(l10n.sortBySize),
          value: 'size',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'size';
              _arrangeFiles('size');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<String>(
        value: 'arrange_type',
        child: RadioListTile<String>(
          title: Text(l10n.sortByType),
          value: 'type',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'type';
              _arrangeFiles('type');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<String>(
        value: 'arrange_detailed_type',
        child: RadioListTile<String>(
          title: Text(l10n.sortByDetailedType),
          value: 'detailed_type',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'detailed_type';
              _arrangeFiles('type');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem<String>(
        value: 'arrange_date',
        child: RadioListTile<String>(
          title: Text(l10n.sortByDate),
          value: 'date',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              currentSortCriteria = value ?? 'date';
              _arrangeFiles('date');
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'reverse_order',
        child: CheckboxListTile(
          title: Text(l10n.sortReverse),
          value: reverseSortOrder,
          onChanged: (value) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              reverseSortOrder = value ?? false;
              _arrangeFiles(currentSortCriteria);
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }

  Widget _buildArrangeToolbarMenuButton() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.sortArrangeIcons,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 36),
        itemBuilder: (BuildContext context) => _arrangeIconMenuEntries(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.view_module,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 22,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(Offset position, {FileInfo? file}) {
    final selectedFile = file ?? previewFile;
    if (selectedFile == null) {
      unawaited(_showEmptySpaceContextMenu(position));
      return;
    }

    final l10n = AppLocalizations.of(context);

    unawaited(() async {
      final value = await showMenu<String>(
        context: context,
        useRootNavigator: true,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          MediaQuery.of(context).size.width - position.dx,
          MediaQuery.of(context).size.height - position.dy,
        ),
        items: [
          if (!selectedFile.isDir)
            PopupMenuItem(
              value: 'open_with',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.open_in_new,
                label: l10n.ctxOpenWith,
              ),
            ),
          if (_isTrashFilesFolder(currentPath))
            PopupMenuItem(
              value: 'restore_trash',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.restore_from_trash,
                label: l10n.ctxRestoreFromTrash,
              ),
            ),
          PopupMenuItem(
            value: 'copy_to',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.copy,
              label: l10n.ctxCopyTo,
            ),
          ),
          PopupMenuItem(
            value: 'move_to',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.drive_file_move,
              label: l10n.ctxMoveTo,
            ),
          ),
          PopupMenuItem(
            value: 'copy',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.copy,
              label: l10n.ctxCopy,
            ),
          ),
          PopupMenuItem(
            value: 'cut',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.content_cut,
              label: l10n.ctxCut,
            ),
          ),
          PopupMenuItem(
            value: 'paste',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.paste,
              label: l10n.ctxPaste,
            ),
          ),
          if (!_isTrashFilesFolder(currentPath))
            PopupMenuItem(
              value: 'compress_zip',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.archive_outlined,
                label: l10n.ctxCompressToZip,
              ),
            ),
          if (ArchiveService.isArchive(selectedFile.path))
            PopupMenuItem(
              value: 'extract',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.unarchive,
                label: l10n.ctxExtract,
              ),
            ),
          if (ArchiveService.isArchive(selectedFile.path))
            PopupMenuItem(
              value: 'extract_to',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.folder_open,
                label: l10n.ctxExtractTo,
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'rename',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.edit,
              label: l10n.commonRename,
            ),
          ),
          if (selectedFile.isDir)
            PopupMenuItem(
              value: 'change_color',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.palette,
                label: l10n.ctxChangeColor,
              ),
            ),
          PopupMenuItem(
            value: 'properties',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.info,
              label: l10n.sidebarProperties,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.delete,
              label: l10n.commonDelete,
              iconColor: Colors.red,
              textStyle: const TextStyle(color: Colors.red),
            ),
          ),
          if (!_isTrashFilesFolder(currentPath))
            PopupMenuItem(
              value: 'trash',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.delete_outline,
                label: l10n.ctxMoveToTrash,
              ),
            ),
        ],
      );
      _isRightClickingFile = false;
      if (!mounted || value == null) return;
      await _ensurePopupMenuDismissed();
      if (!mounted) return;
      await _handleContextAction(value, selectedFile);
    }());
  }

  Future<void> _compressSelectionToZip({
    required bool secondPane,
    required FileInfo primary,
  }) async {
    final l10n = AppLocalizations.of(context);
    final paths = secondPane
        ? (secondPaneSelectedFiles.isNotEmpty
            ? secondPaneSelectedFiles.toList()
            : <String>[primary.path])
        : (selectedFiles.isNotEmpty
            ? selectedFiles.toList()
            : <String>[primary.path]);
    if (paths.isEmpty) return;
    final parentDir = path.dirname(paths.first);
    final baseName = paths.length == 1
        ? path.basename(paths.first)
        : 'Archive';
    String? outPath;
    try {
      outPath = await ArchiveService.uniqueZipPath(parentDir, baseName);
      final estimated = await ArchiveService.estimateZipSourcesBytes(paths);
      if (!mounted) return;
      _copyProgress.start(
        sourceName: l10n.zipProgressSubtitle,
        destName: path.basename(outPath),
        destDirectoryPath: parentDir,
        totalBytes: estimated > 0 ? estimated : 0,
        panelTitle: l10n.zipProgressPanelTitle,
        leadingIcon: Icons.archive_outlined,
      );
      await ArchiveService.createZipFromPaths(
        sourceAbsolutePaths: paths,
        zipFileAbsolutePath: outPath,
        onProgress: (c, name) {
          final label = name == ArchiveService.zipEncodingProgressToken
              ? l10n.zipProgressEncoding
              : name;
          _copyProgress.stats.applyCopyProgress(
            bytesCopied: c,
            currentFileName: label,
            adjustTotalIfUnknown: estimated <= 0,
          );
        },
        isCancelled: () => _copyProgress.shouldCancelCopy,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackZipCreated(path.basename(outPath)))),
      );
      if (secondPane) {
        if (secondPanePath != null) {
          _loadDirectoryForPane(secondPanePath!, true);
        }
      } else if (currentPath != null) {
        _navigateToPath(currentPath!, addToHistory: false);
      }
    } on ZipCompressionCancelled {
      if (outPath != null) {
        try {
          final f = File(outPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.copyCancelled)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackZipFailed(e.toString()))),
        );
      }
    } finally {
      _copyProgress.finish();
    }
  }

  Future<void> _handleContextAction(String action, FileInfo file) async {
    switch (action) {
      case 'compress_zip':
        await _compressSelectionToZip(secondPane: false, primary: file);
        break;
      case 'copy':
        if (selectedFiles.isNotEmpty) {
          setState(() {
            copiedFiles = selectedFiles.toList();
            isMoveOperation = false;
          });
        } else {
          setState(() {
            copiedFiles = [file.path];
            isMoveOperation = false;
          });
        }
        unawaited(_writeFilePayloadToSystemClipboard(copiedFiles, move: false));
        break;
      case 'cut':
        if (selectedFiles.isNotEmpty) {
          setState(() {
            copiedFiles = selectedFiles.toList();
            isMoveOperation = true;
          });
        } else {
          setState(() {
            copiedFiles = [file.path];
            isMoveOperation = true;
          });
        }
        unawaited(_writeFilePayloadToSystemClipboard(copiedFiles, move: true));
        break;
      case 'copy_to':
        final destCopy = await FilePicker.platform.getDirectoryPath();
        if (destCopy != null && mounted) {
          final sourcesCopy = selectedFiles.isNotEmpty
              ? selectedFiles.toList()
              : <String>[file.path];
          await _batchCopyOrMovePathsToDirectory(
            sourcesCopy,
            destCopy,
            move: false,
          );
          if (currentPath != null) {
            _navigateToPath(currentPath!, addToHistory: false);
          }
          if (isSplitView && secondPanePath != null) {
            _loadDirectoryForPane(secondPanePath!, true);
          }
        }
        break;
      case 'move_to':
        final destMove = await FilePicker.platform.getDirectoryPath();
        if (destMove != null && mounted) {
          final sourcesMove = selectedFiles.isNotEmpty
              ? selectedFiles.toList()
              : <String>[file.path];
          await _batchCopyOrMovePathsToDirectory(
            sourcesMove,
            destMove,
            move: true,
          );
          if (currentPath != null) {
            _navigateToPath(currentPath!, addToHistory: false);
          }
          if (isSplitView && secondPanePath != null) {
            _loadDirectoryForPane(secondPanePath!, true);
          }
        }
        break;
      case 'paste':
        if (copiedFiles.isNotEmpty && currentPath != null) {
          await _pasteFiles();
        }
        break;
      case 'extract':
        await ArchiveService.extractArchive(file.path, currentPath ?? '/tmp');
        _navigateToPath(currentPath!, addToHistory: false);
        break;
      case 'extract_to':
        final dest = await FilePicker.platform.getDirectoryPath();
        if (dest != null) {
          await ArchiveService.extractArchive(file.path, dest);
        }
        break;
      case 'change_color':
        if (file.isDir) {
          _showFolderColorDialog(file.path, file.name);
        }
        break;
      case 'properties':
        {
          final ordered = _orderedSelectedFileInfosInPane(secondPane: false);
          final selection = ordered.length >= 2 ? ordered : <FileInfo>[file];
          showDialog(
            context: context,
            builder: (context) => FileProperties(
              file: selection.first,
              aggregateSelection: selection.length >= 2 ? selection : null,
            ),
          );
        }
        break;
      case 'delete':
        if (selectedFiles.isNotEmpty) {
          await _deleteMultipleFiles(selectedFiles.toList(), permanent: true);
        } else {
          await _deleteFile(file.path, permanent: true);
        }
        break;
      case 'trash':
        if (selectedFiles.isNotEmpty) {
          await _deleteMultipleFiles(selectedFiles.toList(), permanent: false);
        } else {
          await _deleteFile(file.path, permanent: false);
        }
        break;
      case 'restore_trash':
        {
          final paths = selectedFiles.isNotEmpty
              ? selectedFiles.toList()
              : <String>[file.path];
          await _restoreTrashItems(paths, secondPane: false);
        }
        break;
      case 'open_with':
        _showOpenWithDialog(file);
        break;
      case 'rename':
        _showRenameDialog(file, secondPane: false);
        break;
    }
  }

  Future<void> _showOpenWithDialog(FileInfo file) async {
    final l10n = AppLocalizations.of(context);
    final mimeType = await DesktopAppsService.queryMimeTypeForPath(file.path);
    final applications = await DesktopAppsService.discoverApplications();

    String? defaultSubtitle;
    final defId = await DesktopAppsService.defaultDesktopIdForMime(mimeType);
    if (defId != null) {
      final friendly = await DesktopAppsService.friendlyNameForDesktopId(defId);
      defaultSubtitle = '$friendly • $defId';
    }

    final searchController = TextEditingController();
    final filteredApps = ValueNotifier<List<DesktopAppEntry>>(applications);

    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      filteredApps.value = applications.where((app) {
        return app.name.toLowerCase().contains(query) ||
            app.subtitle.toLowerCase().contains(query) ||
            app.desktopPath.toLowerCase().contains(query) ||
            app.desktopId.toLowerCase().contains(query);
      }).toList();
    });

    final choice = await showDialog<OpenWithChoice>(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
        title: Text(l10n.dialogOpenWithTitle(file.name)),
        content: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: l10n.hintSearchApp,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                autofocus: false,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  l10n.openWithFooterHint,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<DesktopAppEntry>>(
                  valueListenable: filteredApps,
                  builder: (context, filtered, _) {
                    return ListView.builder(
                      itemCount: filtered.length + 3,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.apps),
                            title: Text(l10n.openWithDefaultApp),
                            subtitle: defaultSubtitle != null
                                ? Text(
                                    defaultSubtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(
                                ctx,
                                const OpenWithChoice.xdgDefault(),
                              );
                            },
                          );
                        }
                        if (index == 1) {
                          return const Divider();
                        }
                        if (index == filtered.length + 2) {
                          return Column(
                            children: [
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.folder_open),
                                title: Text(l10n.browseEllipsis),
                                onTap: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(
                                        type: FileType.any,
                                        allowedExtensions: null,
                                      );
                                  if (result != null &&
                                      result.files.single.path != null) {
                                    final exePath = result.files.single.path!;
                                    if (!ctx.mounted) return;
                                    Navigator.pop(
                                      ctx,
                                      OpenWithChoice.customExecutable(exePath),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        }
                        final app = filtered[index - 2];
                        return ListTile(
                          leading: const Icon(Icons.apps),
                          title: Text(app.name),
                          subtitle: Text(
                            app.subtitle,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.star, size: 20),
                                tooltip: l10n.tooltipSetAsDefaultApp,
                                onPressed: () async {
                                  final ok =
                                      await DesktopAppsService.setDefaultForMime(
                                        app.desktopId,
                                        mimeType,
                                      );
                                  if (!mounted) return;
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.snackDefaultAppSet(
                                            app.name,
                                            mimeType,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.snackSetDefaultAppError(
                                            'xdg-mime',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                tooltip: l10n.openWithOpenAndSetDefault,
                                onSelected: (value) {
                                  if (value == 'openAndSet') {
                                    Navigator.pop(
                                      ctx,
                                      OpenWithChoice.desktop(
                                        app.desktopPath,
                                        setDefaultAfterOpen: true,
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (menuCtx) => [
                                  PopupMenuItem<String>(
                                    value: 'openAndSet',
                                    child: Text(l10n.openWithOpenAndSetDefault),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(
                              ctx,
                              OpenWithChoice.desktop(app.desktopPath),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
        ],
      ),
      ),
    );

    if (choice == null || !mounted) return;

    try {
      if (choice.useXdgDefault) {
        await Process.run('xdg-open', [file.path]);
      } else if (choice.desktopPath != null) {
        if (choice.setDefaultAfterOpen) {
          final ok = await DesktopAppsService.setDefaultForMime(
            path.basename(choice.desktopPath!),
            mimeType,
          );
          if (mounted && ok) {
            final appLabel = await DesktopAppsService.friendlyNameForDesktopId(
              path.basename(choice.desktopPath!),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.snackDefaultAppSet(appLabel, mimeType)),
              ),
            );
          } else if (mounted && !ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.snackSetDefaultAppError('xdg-mime'))),
            );
          }
        }
        final r = await DesktopAppsService.launchWithDesktopFile(
          choice.desktopPath!,
          file.path,
        );
        if (r.exitCode != 0 && mounted) {
          final err = r.stderr.toString().trim().isNotEmpty
              ? r.stderr.toString()
              : r.stdout.toString().trim();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).snackOpenFileError(err.isEmpty ? 'exit ${r.exitCode}' : err),
              ),
            ),
          );
        }
      } else if (choice.customExecutablePath != null) {
        await Process.run(choice.customExecutablePath!, [file.path]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).snackOpenFileError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  // Funzioni per il secondo pannello (split view)
  void _showContextMenuForSecondPane(Offset position, FileInfo file) {
    final l10n = AppLocalizations.of(context);

    unawaited(() async {
      final value = await showMenu<String>(
        context: context,
        useRootNavigator: true,
        position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          MediaQuery.of(context).size.width - position.dx,
          MediaQuery.of(context).size.height - position.dy,
        ),
        items: [
          if (!file.isDir)
            PopupMenuItem(
              value: 'open_with',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.open_in_new,
                label: l10n.ctxOpenWith,
              ),
            ),
          if (_isTrashFilesFolder(secondPanePath))
            PopupMenuItem(
              value: 'restore_trash',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.restore_from_trash,
                label: l10n.ctxRestoreFromTrash,
              ),
            ),
          PopupMenuItem(
            value: 'copy_to',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.copy,
              label: l10n.ctxCopyTo,
            ),
          ),
          PopupMenuItem(
            value: 'move_to',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.drive_file_move,
              label: l10n.ctxMoveTo,
            ),
          ),
          PopupMenuItem(
            value: 'copy',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.copy,
              label: l10n.ctxCopy,
            ),
          ),
          PopupMenuItem(
            value: 'cut',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.content_cut,
              label: l10n.ctxCut,
            ),
          ),
          PopupMenuItem(
            value: 'paste',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.paste,
              label: l10n.ctxPaste,
            ),
          ),
          if (!_isTrashFilesFolder(secondPanePath))
            PopupMenuItem(
              value: 'compress_zip',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.archive_outlined,
                label: l10n.ctxCompressToZip,
              ),
            ),
          if (ArchiveService.isArchive(file.path))
            PopupMenuItem(
              value: 'extract',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.unarchive,
                label: l10n.ctxExtract,
              ),
            ),
          if (ArchiveService.isArchive(file.path))
            PopupMenuItem(
              value: 'extract_to',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.folder_open,
                label: l10n.ctxExtractTo,
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'rename',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.edit,
              label: l10n.commonRename,
            ),
          ),
          if (file.isDir)
            PopupMenuItem(
              value: 'change_color',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.palette,
                label: l10n.ctxChangeColor,
              ),
            ),
          PopupMenuItem(
            value: 'properties',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.info,
              label: l10n.sidebarProperties,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            height: CompactMenuRow.rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CompactMenuRow(
              icon: Icons.delete,
              label: l10n.commonDelete,
              iconColor: Colors.red,
              textStyle: const TextStyle(color: Colors.red),
            ),
          ),
          if (!_isTrashFilesFolder(secondPanePath))
            PopupMenuItem(
              value: 'trash',
              height: CompactMenuRow.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CompactMenuRow(
                icon: Icons.delete_outline,
                label: l10n.ctxMoveToTrash,
              ),
            ),
        ],
      );
      _isRightClickingFile = false;
      if (!mounted || value == null) return;
      await _ensurePopupMenuDismissed();
      if (!mounted) return;
      await _handleContextActionForSecondPane(value, file);
    }());
  }

  Future<void> _handleContextActionForSecondPane(
    String action,
    FileInfo file,
  ) async {
    switch (action) {
      case 'compress_zip':
        await _compressSelectionToZip(secondPane: true, primary: file);
        break;
      case 'copy':
        if (secondPaneSelectedFiles.isNotEmpty) {
          setState(() {
            copiedFiles = secondPaneSelectedFiles.toList();
            isMoveOperation = false;
          });
        } else {
          setState(() {
            copiedFiles = [file.path];
            isMoveOperation = false;
          });
        }
        unawaited(_writeFilePayloadToSystemClipboard(copiedFiles, move: false));
        break;
      case 'cut':
        if (secondPaneSelectedFiles.isNotEmpty) {
          setState(() {
            copiedFiles = secondPaneSelectedFiles.toList();
            isMoveOperation = true;
          });
        } else {
          setState(() {
            copiedFiles = [file.path];
            isMoveOperation = true;
          });
        }
        unawaited(_writeFilePayloadToSystemClipboard(copiedFiles, move: true));
        break;
      case 'copy_to':
        final destCopy2 = await FilePicker.platform.getDirectoryPath();
        if (destCopy2 != null && mounted) {
          final sourcesCopy2 = secondPaneSelectedFiles.isNotEmpty
              ? secondPaneSelectedFiles.toList()
              : <String>[file.path];
          await _batchCopyOrMovePathsToDirectory(
            sourcesCopy2,
            destCopy2,
            move: false,
          );
          _loadDirectoryForPane(secondPanePath ?? '', true);
          if (currentPath != null) {
            _navigateToPath(currentPath!, addToHistory: false);
          }
        }
        break;
      case 'move_to':
        final destMove2 = await FilePicker.platform.getDirectoryPath();
        if (destMove2 != null && mounted) {
          final sourcesMove2 = secondPaneSelectedFiles.isNotEmpty
              ? secondPaneSelectedFiles.toList()
              : <String>[file.path];
          await _batchCopyOrMovePathsToDirectory(
            sourcesMove2,
            destMove2,
            move: true,
          );
          _loadDirectoryForPane(secondPanePath ?? '', true);
          if (currentPath != null) {
            _navigateToPath(currentPath!, addToHistory: false);
          }
        }
        break;
      case 'paste':
        if (copiedFiles.isNotEmpty && secondPanePath != null) {
          await _pasteFilesToPath(secondPanePath!);
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'extract':
        await ArchiveService.extractArchive(
          file.path,
          secondPanePath ?? '/tmp',
        );
        _loadDirectoryForPane(secondPanePath ?? '/tmp', true);
        break;
      case 'extract_to':
        final dest = await FilePicker.platform.getDirectoryPath();
        if (dest != null) {
          await ArchiveService.extractArchive(file.path, dest);
        }
        break;
      case 'change_color':
        if (file.isDir) {
          _showFolderColorDialog(file.path, file.name);
        }
        break;
      case 'properties':
        {
          final ordered = _orderedSelectedFileInfosInPane(secondPane: true);
          final selection = ordered.length >= 2 ? ordered : <FileInfo>[file];
          showDialog(
            context: context,
            builder: (context) => FileProperties(
              file: selection.first,
              aggregateSelection: selection.length >= 2 ? selection : null,
            ),
          );
        }
        break;
      case 'delete':
        if (secondPaneSelectedFiles.isNotEmpty) {
          await _deleteMultipleFiles(
            secondPaneSelectedFiles.toList(),
            permanent: true,
          );
          _loadDirectoryForPane(secondPanePath ?? '', true);
        } else {
          await _deleteFile(file.path, permanent: true);
          _loadDirectoryForPane(secondPanePath ?? '', true);
        }
        break;
      case 'trash':
        if (secondPaneSelectedFiles.isNotEmpty) {
          await _deleteMultipleFiles(
            secondPaneSelectedFiles.toList(),
            permanent: false,
          );
          _loadDirectoryForPane(secondPanePath ?? '', true);
        } else {
          await _deleteFile(file.path, permanent: false);
          _loadDirectoryForPane(secondPanePath ?? '', true);
        }
        break;
      case 'restore_trash':
        {
          final paths = secondPaneSelectedFiles.isNotEmpty
              ? secondPaneSelectedFiles.toList()
              : <String>[file.path];
          await _restoreTrashItems(paths, secondPane: true);
        }
        break;
      case 'rename':
        _showRenameDialog(file, secondPane: true);
        break;
      case 'open_with':
        _showOpenWithDialog(file);
        break;
    }
  }

  Future<void> _showEmptySpaceContextMenuForSecondPane(Offset position) async {
    if (_shouldBlockEmptyPaneContextMenu()) return;
    _suppressEmptyPaneContextMenuUntilMs =
        DateTime.now().millisecondsSinceEpoch + 12;
    _isRightClickingFile = false;
    final l10n = AppLocalizations.of(context);
    unawaited(_refreshSystemClipboardPasteState());
    if (!mounted) return;

    final value = await EmptySpacePaneMenu.show(
      context,
      globalPosition: position,
      l10n: l10n,
      showHiddenFiles: showHiddenFilesSecondPane,
      pasteEnabled: copiedFiles.isNotEmpty || _systemClipboardHasFiles,
    );
    _isRightClickingFile = false;
    if (!mounted || value == null) return;
    await _ensurePopupMenuDismissed();
    if (!mounted) return;
    unawaited(_handleEmptySpaceActionForSecondPane(value));
  }

  Future<void> _handleEmptySpaceActionForSecondPane(String action) async {
    switch (action) {
      case 'open_terminal':
        if (secondPanePath != null) {
          _openTerminalInPath(secondPanePath!);
        } else {
          _openTerminal();
        }
        break;
      case 'new_folder':
        final name = await _showCreateFolderDialog();
        if (name != null && secondPanePath != null) {
          final newPath = path.join(secondPanePath!, name);
          await Directory(newPath).create(recursive: true);
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'open_as_root':
        if (secondPanePath != null) {
          _openAsRootInPath(secondPanePath!);
        }
        break;
      case 'toggle_hidden':
        setState(() {
          showHiddenFilesSecondPane = !showHiddenFilesSecondPane;
          _saveViewPreferences();
        });
        if (secondPanePath != null) {
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'paste':
        if (copiedFiles.isNotEmpty && secondPanePath != null) {
          await _pasteFilesToPath(secondPanePath!);
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'properties':
        if (secondPanePath != null) {
          final dirInfo = FileInfo(
            path: secondPanePath!,
            name: path.basename(secondPanePath!),
            size: 0,
            isDir: true,
            modified: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
          showDialog(
            context: context,
            builder: (context) => FileProperties(file: dirInfo),
          );
        }
        break;
      case 'create_folder':
        final name = await _showCreateFolderDialog();
        if (name != null && secondPanePath != null) {
          final newPath = path.join(secondPanePath!, name);
          await Directory(newPath).create(recursive: true);
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'create_file':
        final name = await _showCreateFileDialog();
        if (name != null && secondPanePath != null) {
          final newPath = path.join(secondPanePath!, name);
          await File(newPath).create();
          _loadDirectoryForPane(secondPanePath!, true);
        }
        break;
      case 'new_txt':
        await _createEmptyDocumentFromKind(kind: 'new_txt', secondPane: true);
        break;
      case 'new_docx':
        await _createEmptyDocumentFromKind(kind: 'new_docx', secondPane: true);
        break;
      case 'new_xlsx':
        await _createEmptyDocumentFromKind(kind: 'new_xlsx', secondPane: true);
        break;
    }
  }

  Future<String?> _showCreateFolderDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogTitleCreateFolder),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.labelFolderName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              Navigator.pop(ctx, controller.text);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: Text(l10n.buttonCreate),
          ),
        ],
      ),
    );
    return result;
  }

  Future<String?> _showCreateFileDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.menuNewTextFile),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.labelFileName,
            hintText: l10n.hintTextDocument,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              Navigator.pop(ctx, controller.text);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: Text(l10n.buttonCreate),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _copyDirectory(
    String source,
    String dest, {
    int progressBaseBytes = 0,
    bool adjustTotalIfUnknown = true,
  }) async {
    final onProgress = _makeDirectoryTreeProgressHandler(
      progressBaseBytes: progressBaseBytes,
      adjustTotalIfUnknown: adjustTotalIfUnknown,
    );
    await FileService.copyDirectorySmartWithProgress(
      source,
      dest,
      shouldCancel: () => _copyProgress.shouldCancelCopy,
      onProgress: onProgress,
    );
  }

  Future<void> _moveDirectory(
    String source,
    String dest, {
    int progressBaseBytes = 0,
    bool batchMode = false,
    int itemTotalBytes = 0,
  }) async {
    try {
      // Verifica se la destinazione esiste già
      final destDir = Directory(dest);
      if (await destDir.exists()) {
        // Se esiste, elimina prima di spostare
        await destDir.delete(recursive: true);
      }

      // Prova prima con rename (veloce se stesso filesystem)
      await Directory(source).rename(dest);
      if (mounted && batchMode && itemTotalBytes > 0) {
        _applyCopyProgressToUi(
          progressBaseBytes + itemTotalBytes,
          path.basename(source),
          adjustTotalIfUnknown: false,
        );
      }
    } catch (e) {
      // Se rename fallisce (cross-device o altro errore), copia e elimina
      try {
        final onProgress = _makeDirectoryTreeProgressHandler(
          progressBaseBytes: progressBaseBytes,
          adjustTotalIfUnknown: !batchMode,
        );
        await FileService.copyDirectorySmartWithProgress(
          source,
          dest,
          shouldCancel: () => _copyProgress.shouldCancelCopy,
          onProgress: onProgress,
        );
        await Directory(source).delete(recursive: true);
      } catch (copyError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).snackMoveError(copyError.toString()),
              ),
            ),
          );
        }
        rethrow;
      }
    }
  }

  Future<_OverwriteBatchChoice?> _promptOverwriteNameConflict(
    String destPath,
  ) async {
    final t = await FileSystemEntity.type(destPath);
    if (t == FileSystemEntityType.notFound) {
      return _OverwriteBatchChoice.replace;
    }
    if (!mounted) return _OverwriteBatchChoice.abortBatch;
    final l10n = AppLocalizations.of(context);
    final name = path.basename(destPath);
    return showDialog<_OverwriteBatchChoice>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () =>
            Navigator.pop(ctx, _OverwriteBatchChoice.replace),
        child: AlertDialog(
          title: Text(l10n.dialogOverwriteTitle),
          content: Text(l10n.dialogOverwriteBody(name)),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, _OverwriteBatchChoice.abortBatch),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _OverwriteBatchChoice.skip),
              child: Text(l10n.dialogOverwriteSkip),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, _OverwriteBatchChoice.replace),
              child: Text(l10n.dialogOverwriteReplace),
            ),
          ],
        ),
      ),
    );
  }

  /// Copia o sposta più percorsi in una cartella con una sessione progress e totale stimato (`du`/stat).
  Future<void> _batchCopyOrMovePathsToDirectory(
    List<String> sources,
    String destDir, {
    required bool move,
  }) async {
    if (sources.isEmpty) return;

    final l10nPaste = AppLocalizations.of(context);
    final sizes = await Future.wait(sources.map(_pathTotalBytes));
    final totalBatch = sizes.fold<int>(0, (a, b) => a + b);

    _copyProgress.start(
      sourceName: sources.length == 1
          ? path.basename(sources.first)
          : l10nPaste.labelNItems(sources.length),
      destName: path.basename(destDir),
      destDirectoryPath: destDir,
      totalBytes: totalBatch,
    );
    _armCopyDestinationLiveRefresh();

    var base = 0;
    try {
      for (var i = 0; i < sources.length; i++) {
        if (_copyProgress.shouldCancelCopy) break;

        final sourcePath = sources[i];
        final itemBytes = sizes[i];
        var itemOk = false;
        try {
          final sourceFile = File(sourcePath);
          final sourceDir = Directory(sourcePath);
          final fileName = path.basename(sourcePath);
          final dest = path.join(destDir, fileName);

          var resolvedDest = dest;
          if (await File(dest).exists() || await Directory(dest).exists()) {
            final choice = await _promptOverwriteNameConflict(dest);
            if (choice == null || choice == _OverwriteBatchChoice.abortBatch) {
              break;
            }
            if (choice == _OverwriteBatchChoice.skip) {
              continue;
            }
            resolvedDest = dest;
            try {
              final dt = await FileSystemEntity.type(resolvedDest);
              if (dt == FileSystemEntityType.directory) {
                await Directory(resolvedDest).delete(recursive: true);
              } else if (dt == FileSystemEntityType.file) {
                await File(resolvedDest).delete();
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      ).commonError('${path.basename(resolvedDest)}: $e'),
                    ),
                  ),
                );
              }
              continue;
            }
          }

          if (await sourceFile.exists()) {
            if (move) {
              await _moveFile(
                sourcePath,
                resolvedDest,
                batchProgress: true,
                progressBaseBytes: base,
                itemTotalBytes: itemBytes,
              );
            } else {
              await _copyFile(
                sourcePath,
                resolvedDest,
                ownsUiSession: false,
                progressBaseBytes: base,
              );
            }
            itemOk = true;
          } else if (await sourceDir.exists()) {
            if (move) {
              await _moveDirectory(
                sourcePath,
                resolvedDest,
                batchMode: true,
                progressBaseBytes: base,
                itemTotalBytes: itemBytes,
              );
            } else {
              await _copyDirectory(
                sourcePath,
                resolvedDest,
                progressBaseBytes: base,
                adjustTotalIfUnknown: false,
              );
            }
            itemOk = true;
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).snackPasteItemError(
                    path.basename(sourcePath),
                    e.toString(),
                  ),
                ),
              ),
            );
          }
        }
        if (itemOk) {
          base += itemBytes;
          if (mounted) {
            _applyCopyProgressToUi(
              base,
              path.basename(sourcePath),
              adjustTotalIfUnknown: false,
            );
          }
        }
      }
    } finally {
      // Snap to 100% when callbacks sotto-stimano i byte (es. alberi grandi), poi chiudi.
      if (mounted && !_copyProgress.shouldCancelCopy && totalBatch > 0) {
        _applyCopyProgressToUi(totalBatch, null, adjustTotalIfUnknown: false);
      }
      // Always tear down copy UI: do not gate on [mounted] — async work can end
      // when the Element reports unmounted briefly or navigations overlap, leaving
      // ValueNotifier(active) stuck true while files already finished copying.
      _disarmCopyDestinationLiveRefresh();
      _copyProgress.finish();
    }
  }

  /// Barra menu / azioni rapide: selezione pannello sinistro → cartella scelta con file picker.
  Future<void> _pickDirectoryAndBatchCopyOrMove({required bool move}) async {
    if (selectedFiles.isEmpty) return;
    final dest = await FilePicker.platform.getDirectoryPath();
    if (dest == null || !mounted) return;
    await _batchCopyOrMovePathsToDirectory(
      selectedFiles.toList(),
      dest,
      move: move,
    );
    if (!mounted) return;
    if (currentPath != null) {
      _navigateToPath(currentPath!, addToHistory: false);
    }
    if (isSplitView && secondPanePath != null) {
      _loadDirectoryForPane(secondPanePath!, true);
    }
  }

  Future<void> _pasteFilesToPath(String destPath) async {
    if (copiedFiles.isEmpty) {
      final payload = await _readFilePayloadFromSystemClipboard();
      if (payload.paths.isEmpty) {
        await _refreshSystemClipboardPasteState();
        return;
      }
      if (!mounted) return;
      setState(() {
        copiedFiles = List<String>.from(payload.paths);
        isMoveOperation = payload.move;
      });
    }

    await _batchCopyOrMovePathsToDirectory(
      copiedFiles,
      destPath,
      move: isMoveOperation,
    );

    if (mounted) {
      setState(() {
        copiedFiles.clear();
        isMoveOperation = false;
      });

      if (isSplitView) {
        if (secondPanePath != null) {
          _loadDirectoryForPane(secondPanePath!, true);
        }
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
      } else {
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
      }
    }
  }

  Future<void> _handleEmptySpaceAction(String action) async {
    switch (action) {
      case 'toggle_hidden':
        setState(() {
          showHiddenFiles = !showHiddenFiles;
          _saveViewPreferences();
        });
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
        break;
      case 'new_folder':
        await _createNewFolder();
        break;
      case 'open_terminal':
        _openTerminal();
        break;
      case 'open_as_root':
        _openAsRoot();
        break;
      case 'arrange_by_name':
        _arrangeFiles('name');
        break;
      case 'arrange_by_size':
        _arrangeFiles('size');
        break;
      case 'arrange_by_type':
        _arrangeFiles('type');
        break;
      case 'arrange_by_date':
        _arrangeFiles('date');
        break;
      case 'paste':
        if (copiedFiles.isNotEmpty && currentPath != null) {
          await _pasteFiles();
        }
        break;
      case 'properties':
        if (currentPath != null) {
          final dirInfo = FileInfo(
            path: currentPath!,
            name: path.basename(currentPath!),
            size: 0,
            isDir: true,
            modified: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          );
          showDialog(
            context: context,
            builder: (context) => FileProperties(file: dirInfo),
          );
        }
        break;
      case 'new_txt':
        await _createEmptyDocumentFromKind(kind: 'new_txt', secondPane: false);
        break;
      case 'new_docx':
        await _createEmptyDocumentFromKind(kind: 'new_docx', secondPane: false);
        break;
      case 'new_xlsx':
        await _createEmptyDocumentFromKind(kind: 'new_xlsx', secondPane: false);
        break;
    }
  }

  void _showFolderColorDialog(String folderPath, String folderName) async {
    final l10n = AppLocalizations.of(context);
    final currentColorValue = await FolderIconService.getFolderColor(
      folderPath,
    );
    final currentColor = currentColorValue != null
        ? Color(currentColorValue)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
          title: Text(l10n.dialogChangeColorFor(folderName)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.dialogPickFolderColor),
                const SizedBox(height: 16),
                BlockPicker(
                  pickerColor:
                      currentColor ?? Theme.of(ctx).colorScheme.primary,
                  onColorChanged: (color) async {
                    await FolderIconService.setFolderColor(
                      folderPath,
                      color.value,
                    );
                    setState(() {}); // Refresh to show new color
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 16),
                if (currentColor != null)
                  TextButton(
                    onPressed: () async {
                      await FolderIconService.removeFolderColor(folderPath);
                      setState(() {}); // Refresh to show default color
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.sidebarRemoveCustomColor),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  void _openFileSearch() {
    final initial = (isSplitView &&
            _isSecondPaneFocused &&
            secondPanePath != null &&
            secondPanePath!.isNotEmpty)
        ? secondPanePath
        : currentPath;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => FileSearch(
          initialPath:
              (initial != null && initial.isNotEmpty) ? initial : null,
          onFileSelected: (file) {
            if (file.isDir) {
              _navigateToPath(file.path);
            } else {
              final parent = NetworkBrowserService.isSmbShellPath(file.path)
                  ? NetworkBrowserService.smbShellParent(file.path)
                  : path.dirname(file.path);
              _navigateToPath(parent ?? file.path);
              setState(() {
                selectedFiles = {file.path};
                previewFile = file;
              });
            }
          },
        ),
      ),
    );
  }

  void _showUserGuideDialog() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mq = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
          title: Text(l10n.helpUserGuideTitle),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: mq.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                '${l10n.helpUserGuideBlock1}\n\n'
                '${l10n.helpUserGuideBlock2}\n\n'
                '${l10n.helpUserGuideBlock3}\n\n'
                '${l10n.helpUserGuideBlock4}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeyboardShortcutsDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
          title: Text(l10n.shortcutTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShortcutRow('CTRL+C', l10n.shortcutCopy),
                _buildShortcutRow('CTRL+V', l10n.shortcutPaste),
                _buildShortcutRow('CTRL+X', l10n.shortcutCut),
                _buildShortcutRow('F1', l10n.shortcutFindFiles),
                _buildShortcutRow('F2', l10n.shortcutNewTab),
                _buildShortcutRow('F3', l10n.shortcutSplitView),
                _buildShortcutRow('F5', l10n.shortcutRefresh),
                _buildShortcutRow('F6', l10n.shortcutRightPanel),
                _buildShortcutRow('ESC', l10n.shortcutDeselect),
                _buildShortcutRow('Backspace', l10n.shortcutBackNav),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              shortcut,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
          title: Text(l10n.aboutTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutAppName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutTagline,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutVersionLabel('1.2.0'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(l10n.aboutAuthor, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(l10n.aboutYear, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutDescriptionHeading,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutDescription,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutFeaturesHeading,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutFeaturesList,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSplitView() async {
    setState(() {
      isSplitView = !isSplitView;
      if (isSplitView && secondPanePath == null) {
        // Inizializza dalla home invece che dalla cartella corrente
        FileService.getHomeDirectory().then((homeDir) {
          setState(() {
            secondPanePath = homeDir;
            secondPaneNavigationHistory = [homeDir];
            secondPaneNavigationIndex = 0;
          });
          _loadDirectoryForPane(homeDir, true);
        });
      } else if (!isSplitView) {
        secondPanePath = null;
        secondPaneFiles = [];
        secondPaneSelectedFiles.clear();
        secondPanePreviewFile = null;
        secondPaneNavigationHistory = [];
        secondPaneNavigationIndex = -1;
      }
      _saveViewPreferences();
    });
    _syncDirectoryWatches();
  }

  Future<void> _createNewFolder() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogTitleNewFolder),
        content: TextField(
          controller: controller,
          enableInteractiveSelection: true,
          keyboardType: TextInputType.text,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.labelFolderName,
            hintText: l10n.hintFolderName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) =>
              Navigator.pop(ctx, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.buttonCreate),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && currentPath != null) {
      try {
        final newFolderPath = path.join(currentPath!, result);
        await Directory(newFolderPath).create();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).snackFolderCreated),
            ),
          );
          _navigateToPath(currentPath!, addToHistory: false);
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString().toLowerCase();
          final isPermissionError =
              errorMsg.contains('permission') ||
              errorMsg.contains('access') ||
              errorMsg.contains('denied');

          if (isPermissionError) {
            final shouldOpenAsRoot = await showDialog<bool>(
              context: context,
              builder: (ctx2) => DialogEnterScope(
                onEnterPressed: () => Navigator.pop(ctx2, true),
                child: AlertDialog(
                  title: Text(
                    AppLocalizations.of(context).dialogInsufficientPermissions,
                  ),
                  content: Text(
                    AppLocalizations.of(context).dialogOpenAsRootBody,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2, false),
                      child: Text(AppLocalizations.of(context).dialogCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2, true),
                      child: Text(AppLocalizations.of(context).ctxOpenAsRoot),
                    ),
                  ],
                ),
              ),
            );

            if (shouldOpenAsRoot == true) {
              unawaited(_openFileManagerAsRoot(currentPath));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).commonError(e.toString()),
                ),
              ),
            );
          }
        }
      }
    }
  }

  void _openTerminal() {
    if (currentPath == null) return;
    _openTerminalInPath(currentPath!);
  }

  void _openTerminalInPath(String path) {
    Process.start('gnome-terminal', [
      '--working-directory=$path',
    ], mode: ProcessStartMode.detached).catchError((e) {
      // Try other terminals
      Process.start('xterm', [
        '-e',
        'cd "$path" && bash',
      ], mode: ProcessStartMode.detached).catchError((e2) {
        Process.start('konsole', [
          '--workdir',
          path,
        ], mode: ProcessStartMode.detached).catchError((e3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).snackTerminalUnavailable,
                ),
              ),
            );
          }
          return Process.start('true', [], mode: ProcessStartMode.detached);
        });
        return Process.start('true', [], mode: ProcessStartMode.detached);
      });
      return Process.start('true', [], mode: ProcessStartMode.detached);
    });
  }

  /// Apre un terminale come root nella cartella (fallback non-Linux o se non si vuole una seconda finestra del file manager).
  void _openTerminalAsRootInPath(String dirPath) {
    Process.start('pkexec', [
      'gnome-terminal',
      '--working-directory=$dirPath',
    ], mode: ProcessStartMode.detached).catchError((e) {
      Process.start('sudo', [
        '-E',
        'gnome-terminal',
        '--working-directory=$dirPath',
      ], mode: ProcessStartMode.detached).catchError((e2) {
        Process.start('pkexec', [
          'xterm',
          '-e',
          'cd "$dirPath" && bash',
        ], mode: ProcessStartMode.detached).catchError((e3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).snackTerminalRootError,
                ),
              ),
            );
          }
          return Process.start('true', [], mode: ProcessStartMode.detached);
        });
        return Process.start('true', [], mode: ProcessStartMode.detached);
      });
      return Process.start('true', [], mode: ProcessStartMode.detached);
    });
  }

  void _openAsRootInPath(String dirPath) {
    unawaited(_openFileManagerAsRoot(dirPath));
  }

  /// Linux: `sudo -S -E -- <exe> --folder <dir>` con password inserita nel dialogo (come `sudo ./sage-file-manager` da terminale).
  Future<void> _openFileManagerAsRoot(String? dirRaw) async {
    final l10n = AppLocalizations.of(context);
    if (dirRaw == null || dirRaw.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.snackOpenAsRootNoFolder)));
      return;
    }
    final dir = path.normalize(dirRaw);
    try {
      if (!await Directory(dir).exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.snackOpenAsRootBadFolder)));
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonError(e.toString()))));
      return;
    }

    if (!Platform.isLinux) {
      _openTerminalAsRootInPath(dir);
      return;
    }

    final exe = Platform.resolvedExecutable;
    final env = Map<String, String>.from(Platform.environment);
    const sessionKeys = <String>[
      'DISPLAY',
      'WAYLAND_DISPLAY',
      'XDG_RUNTIME_DIR',
      'XAUTHORITY',
      'DBUS_SESSION_BUS_ADDRESS',
      'XDG_CURRENT_DESKTOP',
      'PATH',
      'HOME',
      'USER',
      'LANG',
      'LC_ALL',
    ];
    for (final k in sessionKeys) {
      final v = Platform.environment[k];
      if (v != null && v.isNotEmpty) env[k] = v;
    }
    env.removeWhere((_, v) => v.isEmpty);

    if (!mounted) return;
    final sudoPass = await _promptSudoPasswordForRoot(l10n);
    if (sudoPass == null) return;

    try {
      await LoggingService.info('App', 'open_as_root sudo -S', {
        'exe': exe,
        'folder': dir,
      });
      final proc = await Process.start('sudo', [
        '-S',
        '-E',
        '--',
        exe,
        '--folder',
        dir,
      ], environment: env);
      proc.stdin.write(sudoPass);
      proc.stdin.writeln();
      await proc.stdin.close();
      unawaited(
        proc.exitCode.then((code) async {
          if (code != 0) {
            await LoggingService.warning('App', 'open_as_root sudo failed', {
              'exit': code,
            });
          }
        }),
      );
      return;
    } catch (e) {
      await LoggingService.warning('App', 'open_as_root exception', {
        'error': e.toString(),
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.snackRootHelperMissing)));
  }

  /// Password per `sudo -S` (come da terminale: sudo ./sage-file-manager).
  Future<String?> _promptSudoPasswordForRoot(AppLocalizations l10n) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogRootPasswordTitle),
        content: TextField(
          controller: c,
          obscureText: true,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l10n.dialogRootPasswordLabel),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.ctxOpenAsRoot),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return null;
    return c.text;
  }

  void _openAsRoot() {
    unawaited(_openFileManagerAsRoot(currentPath));
  }

  Widget _buildSortSubmenu(AppLocalizations l10n) {
    return SubmenuButton(
      menuChildren: [
        RadioListTile<String>(
          title: Text(l10n.sortManual),
          value: 'manual',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'manual';
            });
          },
          dense: true,
        ),
        RadioListTile<String>(
          title: Text(l10n.sortByName),
          value: 'name',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'name';
              _arrangeFiles('name');
            });
          },
          dense: true,
        ),
        RadioListTile<String>(
          title: Text(l10n.sortBySize),
          value: 'size',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'size';
              _arrangeFiles('size');
            });
          },
          dense: true,
        ),
        RadioListTile<String>(
          title: Text(l10n.sortByType),
          value: 'type',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'type';
              _arrangeFiles('type');
            });
          },
          dense: true,
        ),
        RadioListTile<String>(
          title: Text(l10n.sortByDetailedType),
          value: 'detailed_type',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'detailed_type';
              _arrangeFiles('type');
            });
          },
          dense: true,
        ),
        RadioListTile<String>(
          title: Text(l10n.sortByDate),
          value: 'date',
          groupValue: currentSortCriteria,
          onChanged: (value) {
            setState(() {
              currentSortCriteria = value ?? 'date';
              _arrangeFiles('date');
            });
          },
          dense: true,
        ),
        const Divider(),
        CheckboxListTile(
          title: Text(l10n.sortReverse),
          value: reverseSortOrder,
          onChanged: (value) {
            setState(() {
              reverseSortOrder = value ?? false;
              _arrangeFiles(currentSortCriteria);
            });
          },
          dense: true,
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort, size: 20),
          const SizedBox(width: 8),
          Text(l10n.sortArrangeIcons),
        ],
      ),
    );
  }

  void _openPreferencesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Preferences()),
    ).then((_) async {
      if (!mounted) return;
      await _loadPreferences();
      final reloadLocale = widget.onLocaleChanged;
      if (reloadLocale != null) await reloadLocale();
    });
  }

  List<Widget> _mapMenuItemsToWidgets(List<dynamic> items) {
    return items.map<Widget>((item) {
      if (item is PopupMenuDivider) {
        return const Divider();
      }
      if (item is _MenuItem) {
        return MenuItemButton(
          onPressed: item.onPressed,
          child: Row(
            children: [
              Icon(item.icon, size: 20),
              const SizedBox(width: 8),
              Text(item.label),
            ],
          ),
        );
      }
      return item as Widget;
    }).toList();
  }

  Widget _buildCompactSubmenu(
    String label,
    IconData icon,
    List<dynamic> items,
  ) {
    return SubmenuButton(
      menuChildren: _mapMenuItemsToWidgets(items),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCompactMenuBar(AppLocalizations l10n) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      builder: (context, menuController, child) {
        return Material(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
          child: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.menuTooltip,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
            onPressed: () {
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
              }
            },
          ),
        );
      },
      menuChildren: [
        _buildCompactSubmenu(
          l10n.menuTopFile,
          Icons.description_outlined,
          _fileMenuItems(l10n),
        ),
        _buildCompactSubmenu(
          l10n.menuTopEdit,
          Icons.edit_outlined,
          _modificaMenuItems(l10n),
        ),
        _buildCompactSubmenu(
          l10n.menuTopView,
          Icons.visibility_outlined,
          _visualizzaMenuItems(l10n),
        ),
        _buildCompactSubmenu(
          l10n.menuTopFavorites,
          Icons.star_outline,
          _preferitiMenuItems(l10n),
        ),
        MenuItemButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ThemeManager(onThemeChanged: widget.onThemeChanged),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.palette_outlined, size: 20),
              const SizedBox(width: 8),
              Text(l10n.themesManage, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        _buildCompactSubmenu(
          l10n.menuTopTools,
          Icons.build_outlined,
          _strumentiMenuItems(l10n),
        ),
        _buildCompactSubmenu(
          l10n.menuTopHelp,
          Icons.help_outline,
          _aiutoMenuItems(l10n),
        ),
      ],
    );
  }

  List<dynamic> _fileMenuItems(AppLocalizations l10n) => [
    _MenuItem(l10n.menuNewTab, Icons.tab, () {
      _openNewInstance();
    }),
    _MenuItem(l10n.menuNewFolder, Icons.create_new_folder, () {
      _createNewFolder();
    }),
    SubmenuButton(
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            unawaited(
              _createEmptyDocumentFromKind(kind: 'new_txt', secondPane: false),
            );
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.ctxNewTextDocumentShort),
          ),
        ),
        MenuItemButton(
          onPressed: () {
            unawaited(
              _createEmptyDocumentFromKind(kind: 'new_docx', secondPane: false),
            );
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.ctxNewWordDocument),
          ),
        ),
        MenuItemButton(
          onPressed: () {
            unawaited(
              _createEmptyDocumentFromKind(kind: 'new_xlsx', secondPane: false),
            );
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.ctxNewExcelSpreadsheet),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.post_add_outlined, size: 20),
          const SizedBox(width: 8),
          Text(l10n.ctxCreateNew),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    ),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.menuNetworkDrive, Icons.storage, () {
      unawaited(_connectNetworkDrive());
    }),
    _MenuItem(l10n.menuBulkRename, Icons.drive_file_rename_outline, () {
      unawaited(_renameFromActivePaneMenu());
    }),
    if (_isInTrash())
      _MenuItem(l10n.menuEmptyTrash, Icons.delete_forever, () {
        _emptyTrash();
      }),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.menuExit, Icons.exit_to_app, () {
      exit(0);
    }),
  ];

  List<dynamic> _modificaMenuItems(AppLocalizations l10n) => [
    _MenuItem(l10n.menuCut, Icons.content_cut, () {
      if (selectedFiles.isNotEmpty) {
        setState(() {
          copiedFiles = selectedFiles.toList();
          isMoveOperation = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copiedFiles.length == 1
                  ? l10n.snackOneFileCut
                  : l10n.snackManyFilesCut(copiedFiles.length),
            ),
          ),
        );
      }
    }),
    _MenuItem(l10n.menuCopy, Icons.copy, () {
      if (selectedFiles.isNotEmpty) {
        setState(() {
          copiedFiles = selectedFiles.toList();
          isMoveOperation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copiedFiles.length == 1
                  ? l10n.snackOneFileCopied
                  : l10n.snackManyFilesCopied(copiedFiles.length),
            ),
          ),
        );
      }
    }),
    _MenuItem(l10n.menuPaste, Icons.paste, () {
      if (copiedFiles.isNotEmpty && currentPath != null) {
        _pasteFiles();
      }
    }),
    if (_isTrashFilesFolder(
          isSplitView && _isSecondPaneFocused ? secondPanePath : currentPath,
        ))
      _MenuItem(l10n.menuRestoreFromTrash, Icons.restore_from_trash, () {
        final second = isSplitView && _isSecondPaneFocused;
        final paths = second
            ? secondPaneSelectedFiles.toList()
            : selectedFiles.toList();
        if (paths.isEmpty) return;
        unawaited(_restoreTrashItems(paths, secondPane: second));
      }),
    _MenuItem(l10n.ctxCopyTo, Icons.folder_copy_outlined, () {
      _pickDirectoryAndBatchCopyOrMove(move: false);
    }),
    _MenuItem(l10n.ctxMoveTo, Icons.drive_file_move, () {
      _pickDirectoryAndBatchCopyOrMove(move: true);
    }),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.menuRefresh, Icons.refresh, () {
      _refreshCurrentDirectory();
    }),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.menuSelectAll, Icons.select_all, () {
      _selectAll();
    }),
    _MenuItem(l10n.menuDeselectAll, Icons.deselect, () {
      _deselectAll();
    }),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.menuPreferences, Icons.settings, _openPreferencesScreen),
  ];

  List<dynamic> _visualizzaMenuItems(AppLocalizations l10n) => [
    _buildSortSubmenu(l10n),
    PopupMenuDivider() as dynamic,
    _MenuItem(
      showHiddenFiles ? l10n.viewHideHidden : l10n.viewShowHidden,
      showHiddenFiles ? Icons.check_box : Icons.check_box_outline_blank,
      () {
        setState(() {
          showHiddenFiles = !showHiddenFiles;
          _saveViewPreferences();
        });
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
        if (isSplitView && secondPanePath != null) {
          _loadDirectoryForPane(secondPanePath!, true);
        }
      },
    ),
    _MenuItem(l10n.viewSplitScreen, Icons.splitscreen, () {
      _toggleSplitView();
    }),
    _MenuItem(
      showRightPanel ? l10n.viewHideRightPanel : l10n.viewShowRightPanel,
      showRightPanel ? Icons.chevron_right : Icons.chevron_left,
      () {
        setState(() {
          showRightPanel = !showRightPanel;
          if (showRightPanel) {
            showPreview = true;
          }
          _saveViewPreferences();
        });
      },
    ),
  ];

  List<dynamic> _preferitiMenuItems(AppLocalizations l10n) => [
    _MenuItem(l10n.favAdd, Icons.star_border, () {
      _addToFavorites();
    }),
    _MenuItem(l10n.favManage, Icons.manage_accounts, () {
      _showManageFavoritesDialog();
    }),
    if (favoritePaths.isNotEmpty) PopupMenuDivider() as dynamic,
    ...favoritePaths.map(
      (favPath) => _MenuItem(path.basename(favPath), Icons.star, () {
        _navigateToPath(favPath);
      }),
    ),
  ];

  List<dynamic> _strumentiMenuItems(AppLocalizations l10n) => [
    _MenuItem(l10n.menuFind, Icons.search, _openFileSearch),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.toolsPackages, Icons.apps, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PackageManager()),
      );
    }),
    _MenuItem(l10n.toolsUpdates, Icons.update, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UpdateChecker()),
      );
    }),
  ];

  List<dynamic> _aiutoMenuItems(AppLocalizations l10n) => [
    _MenuItem(l10n.helpGitHubProject, Icons.code, () {
      unawaited(GithubAppUpdateService.openUrl(kSageFileManagerGithubUrl));
    }),
    _MenuItem(l10n.helpDonateNow, Icons.favorite_outline, () {
      unawaited(GithubAppUpdateService.openUrl(kSageFileManagerDonateUrl));
    }),
    PopupMenuDivider() as dynamic,
    _MenuItem(l10n.helpUserGuide, Icons.menu_book, () {
      _showUserGuideDialog();
    }),
    _MenuItem(l10n.helpShortcuts, Icons.keyboard, () {
      _showKeyboardShortcutsDialog();
    }),
    _MenuItem(l10n.helpAbout, Icons.info, () {
      _showAboutDialog();
    }),
  ];

  void _arrangeFiles(String criteria) {
    setState(() {
      List<FileInfo> sortedFiles = List.from(files);

      switch (criteria) {
        case 'name':
          sortedFiles.sort((a, b) {
            if (a.isDir && !b.isDir) return -1;
            if (!a.isDir && b.isDir) return 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case 'size':
          sortedFiles.sort((a, b) {
            if (a.isDir && !b.isDir) return -1;
            if (!a.isDir && b.isDir) return 1;
            return b.size.compareTo(a.size);
          });
          break;
        case 'type':
          sortedFiles.sort((a, b) {
            if (a.isDir && !b.isDir) return -1;
            if (!a.isDir && b.isDir) return 1;
            final aExt = path.extension(a.name).toLowerCase();
            final bExt = path.extension(b.name).toLowerCase();
            return aExt.compareTo(bExt);
          });
          break;
        case 'date':
          sortedFiles.sort((a, b) {
            if (a.isDir && !b.isDir) return -1;
            if (!a.isDir && b.isDir) return 1;
            return b.modified.compareTo(a.modified);
          });
          break;
        case 'manual':
          // Mantieni l'ordine manuale (non ordinare)
          break;
      }

      // Applica ordine inverso se richiesto
      if (reverseSortOrder && criteria != 'manual') {
        sortedFiles = sortedFiles.reversed.toList();
      }

      files = sortedFiles;
    });
  }

  Future<void> _pasteFiles() async {
    if (currentPath == null) return;
    if (copiedFiles.isEmpty) {
      final payload = await _readFilePayloadFromSystemClipboard();
      if (payload.paths.isEmpty) {
        await _refreshSystemClipboardPasteState();
        return;
      }
      if (!mounted) return;
      setState(() {
        copiedFiles = List<String>.from(payload.paths);
        isMoveOperation = payload.move;
      });
    }

    await _batchCopyOrMovePathsToDirectory(
      copiedFiles,
      currentPath!,
      move: isMoveOperation,
    );

    if (mounted) {
      setState(() {
        copiedFiles.clear();
        isMoveOperation = false;
      });
      _navigateToPath(currentPath!, addToHistory: false);
    }
  }

  Future<void> _copyFile(
    String source,
    String dest, {
    bool ownsUiSession = true,
    int progressBaseBytes = 0,
  }) async {
    try {
      final sourceEntity = await FileSystemEntity.type(source);
      final sourceFile = File(source);

      int totalSize = 0;
      if (sourceEntity == FileSystemEntityType.directory) {
        try {
          final duResult = await Process.run('du', ['-sb', source]).timeout(
            const Duration(seconds: 120),
            onTimeout: () => ProcessResult(-1, 0, '', 'Timeout'),
          );
          if (duResult.exitCode == 0) {
            final output = duResult.stdout.toString().trim();
            final sizeStr = output.split('\t').first.split('\n').last;
            totalSize = int.tryParse(sizeStr) ?? 0;
          }
        } catch (_) {
          totalSize = 0;
        }
      } else {
        totalSize = (await sourceFile.stat()).size;
      }

      final adjustTotal = ownsUiSession ? totalSize <= 0 : false;

      if (ownsUiSession) {
        _copyProgress.start(
          sourceName: path.basename(source),
          destName: path.basename(dest),
          destDirectoryPath: path.dirname(dest),
          totalBytes: totalSize,
        );
        _armCopyDestinationLiveRefresh();
      }

      copyRefreshTimer?.cancel();

      if (sourceEntity == FileSystemEntityType.directory) {
        final onProgress = _makeDirectoryTreeProgressHandler(
          progressBaseBytes: progressBaseBytes,
          adjustTotalIfUnknown: adjustTotal,
        );
        await FileService.copyDirectorySmartWithProgress(
          source,
          dest,
          shouldCancel: () => _copyProgress.shouldCancelCopy,
          onProgress: onProgress,
        );
      } else {
        await FileService.copyFileSmart(
          source,
          dest,
          onProgress: (copied, skipped, errors) {},
          onCopyProgress: (bytesCopied, fileName) async {
            if (!mounted) return;
            _applyCopyProgressToUi(
              progressBaseBytes + bytesCopied,
              fileName ?? path.basename(source),
              adjustTotalIfUnknown: adjustTotal,
            );
          },
        );
      }

      if (mounted && ownsUiSession) {
        if (currentPath != null) {
          _navigateToPath(currentPath!, addToHistory: false);
        }
        if (isSplitView && secondPanePath != null) {
          _loadDirectoryForPane(secondPanePath!, true);
        }

        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sourceEntity == FileSystemEntityType.directory
                  ? loc.folderCopiedSuccess
                  : loc.fileCopiedSuccess,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonError(e.toString()),
            ),
          ),
        );
      }
      if (!ownsUiSession) rethrow;
    } finally {
      if (ownsUiSession) {
        copyRefreshTimer?.cancel();
        copyRefreshTimer = null;
        _disarmCopyDestinationLiveRefresh();
        _copyProgress.finish();
      }
    }
  }

  Future<void> _moveFile(
    String source,
    String dest, {
    bool batchProgress = false,
    int progressBaseBytes = 0,
    int itemTotalBytes = 0,
  }) async {
    try {
      final sourceFile = File(source);
      final destFile = File(dest);

      if (await destFile.exists()) {
        await destFile.delete();
      }

      if (await sourceFile.exists()) {
        await sourceFile.rename(dest);
        if (mounted && batchProgress && itemTotalBytes > 0) {
          _applyCopyProgressToUi(
            progressBaseBytes + itemTotalBytes,
            path.basename(source),
            adjustTotalIfUnknown: false,
          );
        }
      } else {
        final sourceDir = Directory(source);
        if (await sourceDir.exists()) {
          await _moveDirectory(
            source,
            dest,
            batchMode: batchProgress,
            progressBaseBytes: progressBaseBytes,
            itemTotalBytes: itemTotalBytes,
          );
          return;
        }
        throw Exception('File o directory non trovato: $source');
      }

      if (mounted && !batchProgress) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).snackFileMoved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonError(e.toString()),
            ),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteMultipleFiles(
    List<String> filePaths, {
    required bool permanent,
  }) async {
    final l10n = AppLocalizations.of(context);
    final count = filePaths.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx, true),
        child: AlertDialog(
          title: Text(
            permanent
                ? l10n.dialogTitleDeletePermanent
                : l10n.dialogTitleMoveToTrashConfirm,
          ),
          content: Text(
            permanent
                ? (count == 1
                      ? l10n.dialogBodyPermanentDeleteOne
                      : l10n.dialogBodyPermanentDeleteMany(count))
                : (count == 1
                      ? l10n.dialogBodyTrashOne
                      : l10n.dialogBodyTrashMany(count)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(permanent ? l10n.commonDelete : l10n.ctxMoveToTrash),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      int deleted = 0;
      int errors = 0;

      for (final filePath in filePaths) {
        try {
          if (permanent) {
            final file = File(filePath);
            final dir = Directory(filePath);
            if (await file.exists()) {
              await file.delete(recursive: true);
            } else if (await dir.exists()) {
              await dir.delete(recursive: true);
            }
          } else {
            final home = await FileService.getHomeDirectory();
            await DesktopTrash.moveToTrash(home, filePath);
          }
          deleted++;
        } catch (e) {
          errors++;
        }
      }

      if (mounted) {
        // Clear cache for deleted files
        for (final filePath in filePaths) {
          FileService.clearDirectoryCache(path.dirname(filePath));
        }

        var msg = permanent
            ? (deleted == 1
                  ? l10n.snackDeletedPermanentOne
                  : l10n.snackDeletedPermanentMany(deleted))
            : (deleted == 1
                  ? l10n.snackMovedToTrashOne
                  : l10n.snackMovedToTrashMany(deleted));
        if (errors > 0) {
          msg += l10n.snackDeleteErrorsSuffix(errors);
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        setState(() {
          selectedFiles.clear();
          previewFile = null;
        });

        // Force refresh by clearing cache and reloading
        FileService.clearDirectoryCache(currentPath!);
        _navigateToPath(currentPath!, addToHistory: false);
      }
    }
  }

  Future<void> _deleteFile(String filePath, {required bool permanent}) async {
    await _deleteMultipleFiles([filePath], permanent: permanent);
  }

  Future<void> _showRenameDialog(FileInfo file, {required bool secondPane}) async {
    final ordered = _orderedSelectedFileInfosInPane(secondPane: secondPane);
    final targets = ordered.isNotEmpty ? ordered : <FileInfo>[file];
    if (targets.isEmpty) return;
    if (targets.length == 1) {
      await _renameOne(targets.first, secondPane: secondPane);
    } else {
      await _renameManyDialog(targets, secondPane: secondPane);
    }
  }

  Future<void> _renameOne(FileInfo file, {required bool secondPane}) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: file.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogRenameFileTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.labelNewName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(ctx, true);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l10n.commonRename),
          ),
        ],
      ),
    );

    if (confirmed != true || controller.text.trim().isEmpty) return;

    try {
      final newName = controller.text.trim();
      final parentDir = path.dirname(file.path);
      final newPath = path.join(parentDir, newName);

      final oldEntity = File(file.path);
      final dirEntity = Directory(file.path);

      if (await oldEntity.exists()) {
        await oldEntity.rename(newPath);
      } else if (await dirEntity.exists()) {
        await dirEntity.rename(newPath);
      }

      _refreshDirectoryAfterRename(parentDir, secondPane);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackFileRenamed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackRenameError(e.toString()))),
        );
      }
    }
  }

  Future<void> _renameManyDialog(
    List<FileInfo> items, {
    required bool secondPane,
  }) async {
    final l10n = AppLocalizations.of(context);
    final parentDir = path.dirname(items.first.path);
    if (items.any((f) => path.dirname(f.path) != parentDir)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackRenameSameFolder)),
        );
      }
      return;
    }

    final controllers =
        items.map((f) => TextEditingController(text: f.name)).toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.sizeOf(ctx);
        return AlertDialog(
          title: Text(l10n.dialogRenameFileTitle),
          content: SizedBox(
            width: math.min(920, mq.width * 0.92),
            height: math.min(520, mq.height * 0.72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.dialogRenameManySubtitle(items.length)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                items[i].name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: controllers[i],
                              decoration: InputDecoration(
                                labelText: l10n.labelNewName,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonRename),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      for (final c in controllers) {
        c.dispose();
      }
      return;
    }

    final newNames = controllers.map((c) => c.text.trim()).toList();
    for (final c in controllers) {
      c.dispose();
    }

    for (var i = 0; i < newNames.length; i++) {
      if (newNames[i].isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackRenameEmptyName)),
          );
        }
        return;
      }
    }

    final seen = <String>{};
    for (final n in newNames) {
      if (seen.contains(n)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackRenameDuplicateNames)),
          );
        }
        return;
      }
      seen.add(n);
    }

    var success = 0;
    String? firstError;
    for (var i = 0; i < items.length; i++) {
      final f = items[i];
      final nn = newNames[i];
      if (nn == f.name) {
        success++;
        continue;
      }
      final newPath = path.join(parentDir, nn);
      try {
        if (File(newPath).existsSync() || Directory(newPath).existsSync()) {
          firstError ??= l10n.snackRenameTargetExists;
          continue;
        }
        final fe = File(f.path);
        final de = Directory(f.path);
        if (await fe.exists()) {
          await fe.rename(newPath);
        } else if (await de.exists()) {
          await de.rename(newPath);
        }
        success++;
      } catch (e) {
        firstError ??= e.toString();
      }
    }

    _refreshDirectoryAfterRename(parentDir, secondPane);

    if (!mounted) return;
    if (success == items.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackBulkRenameManyDone(success))),
      );
    } else {
      final tail = firstError != null ? ' — $firstError' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.snackBulkRenameManyDone(success)}$tail'),
        ),
      );
    }
  }

  Future<void> _addToFavorites() async {
    if (currentPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).snackSelectPathFirst),
        ),
      );
      return;
    }

    if (favoritePaths.contains(currentPath)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).snackAlreadyFavorite),
        ),
      );
      return;
    }

    setState(() {
      favoritePaths.add(currentPath!);
    });
    await _saveFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          ).snackAddedFavorite(path.basename(currentPath!)),
        ),
      ),
    );
  }

  Future<void> _showManageFavoritesDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (ctx) => DialogEnterScope(
        onEnterPressed: () => Navigator.pop(ctx),
        child: AlertDialog(
          title: Text(l10n.favManage),
          content: SizedBox(
            width: double.maxFinite,
            child: favoritePaths.isEmpty
                ? Text(l10n.favoritesEmptyList)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: favoritePaths.length,
                    itemBuilder: (context, index) {
                      final favPath = favoritePaths[index];
                      return ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(path.basename(favPath)),
                        subtitle: Text(
                          favPath,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              favoritePaths.removeAt(index);
                              _saveFavorites();
                            });
                            Navigator.pop(ctx);
                            _showManageFavoritesDialog(); // Riapri il dialog aggiornato
                          },
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _navigateToPath(favPath);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persistNetworkBookmarkAndNotifySidebar(
    String picked, {
    String? displayTitle,
    String? serverAddress,
  }) async {
    await persistNetworkPathBookmark(
      picked,
      displayTitle: displayTitle,
      serverAddress: serverAddress,
    );
    if (!mounted) return;
    _networkBookmarksRevision.value++;
  }

  Future<void> _connectNetworkDrive() async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => NetworkBrowserDialog(
        onPathSelected: (picked, {displayTitle, serverAddress}) {
          if (picked != null) {
            unawaited(
              _persistNetworkBookmarkAndNotifySidebar(
                picked,
                displayTitle: displayTitle,
                serverAddress: serverAddress,
              ),
            );
          }
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
          if (picked != null) {
            if (isSplitView && _isSecondPaneFocused) {
              _navigateToSecondPanePath(picked);
            } else {
              _navigateToPath(picked);
            }
          }
        },
      ),
    );
  }

  Future<void> _openNewInstance() async {
    try {
      // Get the executable path
      final executable = Platform.resolvedExecutable;

      // Launch a new instance of the app
      await Process.start(executable, [], runInShell: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).snackNewInstanceStarted),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).snackNewInstanceError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _renameFromActivePaneMenu() async {
    final second = isSplitView && _isSecondPaneFocused;
    final ordered = _orderedSelectedFileInfosInPane(secondPane: second);
    final anchor = ordered.isNotEmpty
        ? ordered.first
        : (second ? secondPanePreviewFile : previewFile);
    final l10n = AppLocalizations.of(context);
    if (anchor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackSelectFilesRename)),
      );
      return;
    }
    await _showRenameDialog(anchor, secondPane: second);
  }

  bool _isHoveringAnyMenu() {
    return _menuControllers.values.any((controller) => controller.isOpen);
  }

  /// Voce diretta «Gestione temi» senza sottomenu.
  Widget _buildDirectThemeMenuButton(AppLocalizations l10n) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ThemeManager(onThemeChanged: widget.onThemeChanged),
          ),
        );
      },
      child: Text(l10n.themesManage, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildMenuButton(String label, List<dynamic> items) {
    final controller = MenuController();
    _menuControllers[label] = controller;

    return MenuAnchor(
      controller: controller,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(
            context,
          ).scaffoldBackgroundColor, // Usa lo stesso colore di sfondo del tema
        ),
      ),
      builder: (context, menuController, child) {
        return MouseRegion(
          onEnter: (_) {
            // Chiudi tutti gli altri menu prima di aprire questo
            // Questo evita che i menu si intreccino
            for (final otherController in _menuControllers.values) {
              if (otherController != menuController && otherController.isOpen) {
                otherController.close();
              }
            }
            // Apri il menu quando il mouse passa sopra
            if (!menuController.isOpen) {
              menuController.open();
            }
          },
          onExit: (_) {
            // Chiudi il menu quando il mouse esce (con un piccolo delay per evitare chiusure accidentali)
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted && !_isHoveringAnyMenu()) {
                menuController.close();
              }
            });
          },
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
              }
            },
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
        );
      },
      menuChildren: items.map<Widget>((item) {
        if (item is PopupMenuDivider) {
          return const Divider();
        }
        if (item is _MenuItem) {
          return MenuItemButton(
            onPressed: item.onPressed,
            child: Row(
              children: [
                Icon(item.icon, size: 20),
                const SizedBox(width: 8),
                Text(item.label),
              ],
            ),
          );
        }
        return item as Widget;
      }).toList(),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  _MenuItem(this.label, this.icon, this.onPressed);
}

// Intent classes for keyboard shortcuts
class CopyIntent extends Intent {
  const CopyIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}

class SplitViewIntent extends Intent {
  const SplitViewIntent();
}

class CutIntent extends Intent {
  const CutIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class NewTabIntent extends Intent {
  const NewTabIntent();
}

class FindFilesIntent extends Intent {
  const FindFilesIntent();
}

class DeselectAllIntent extends Intent {
  const DeselectAllIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class ToggleRightPanelIntent extends Intent {
  const ToggleRightPanelIntent();
}

// Widget for "Disponi Icone" submenu
class _ArrangeIconsSubmenu<T> extends PopupMenuEntry<T> {
  final Function(String) onArrange;

  const _ArrangeIconsSubmenu({required this.onArrange});

  @override
  _ArrangeIconsSubmenuState<T> createState() => _ArrangeIconsSubmenuState<T>();

  @override
  double get height => 48.0;

  @override
  bool represents(T? value) => false;
}

class _ArrangeIconsSubmenuState<T> extends State<_ArrangeIconsSubmenu<T>> {
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  void _showSubmenu(BuildContext menuContext) {
    if (_overlayEntry != null) return;
    _hideTimer?.cancel();

    final RenderBox? renderBox = menuContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final l10n = AppLocalizations.of(menuContext);
    final theme = Theme.of(menuContext);
    final popupMenuTheme = PopupMenuTheme.of(menuContext);
    final Color menuBackground =
        popupMenuTheme.color ?? theme.colorScheme.surface;

    _overlayEntry = OverlayEntry(
      opaque: false,
      maintainState: true,
      builder: (ctx) => Theme(
        data: theme,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: offset.dx + size.width - 8,
              top: offset.dy,
              child: MouseRegion(
                onEnter: (_) => _hideTimer?.cancel(),
                onExit: (_) => _scheduleHide(),
                child: Material(
                  color: menuBackground,
                  elevation: 8,
                  shadowColor: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 220,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSubmenuItem(
                          ctx,
                          'arrange_by_name',
                          Icons.sort_by_alpha,
                          l10n.sortByName,
                        ),
                        _buildSubmenuItem(
                          ctx,
                          'arrange_by_size',
                          Icons.sort,
                          l10n.sortBySize,
                        ),
                        _buildSubmenuItem(
                          ctx,
                          'arrange_by_type',
                          Icons.category,
                          l10n.sortByType,
                        ),
                        _buildSubmenuItem(
                          ctx,
                          'arrange_by_date',
                          Icons.calendar_today,
                          l10n.sortByDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(menuContext, rootOverlay: true).insert(_overlayEntry!);
  }

  Widget _buildSubmenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;
    final style = theme.textTheme.bodyLarge ?? theme.textTheme.bodyMedium;
    return InkWell(
      onTap: () {
        _hideSubmenu();
        widget.onArrange(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: style?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _hideSubmenu();
      }
    });
  }

  void _hideSubmenu() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hideSubmenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuItem<String>(
      enabled: true,
      child: MouseRegion(
        onEnter: (event) {
          _showSubmenu(context);
        },
        onExit: (event) {
          _scheduleHide();
        },
        child: Row(
          children: [
            const Icon(Icons.view_module, size: 20),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).sortArrangeIcons),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
