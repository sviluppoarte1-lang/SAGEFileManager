import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/file_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filemanager/services/folder_icon_service.dart';
import 'package:filemanager/services/network_browser_service.dart';
import 'package:filemanager/services/network_credentials_store.dart';
import 'package:filemanager/services/system_dependencies_service.dart';
import 'package:filemanager/widgets/dependency_install_dialog.dart';
import 'package:filemanager/widgets/network_dependencies_banner.dart';
import 'package:filemanager/widgets/fluid_context_menu.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:async';

/// Dialog SMB condiviso tra sidebar (bookmark) e browser Rete.
Future<Map<String, String>?> showSmbCredentialsDialog(
  BuildContext context,
  String server,
) async {
  final l10n = AppLocalizations.of(context);
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool useGuest = true;
  var remember = true;

  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(l10n.sidebarCredentialsTitle(server)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text(l10n.sidebarGuestAccess),
              value: useGuest,
              onChanged: (value) {
                setDialogState(() {
                  useGuest = value ?? true;
                });
              },
            ),
            if (!useGuest) ...[
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: l10n.labelUsername,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.labelPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.networkRememberPassword),
                value: remember,
                onChanged: (v) => setDialogState(() => remember = v ?? false),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (useGuest) {
                Navigator.pop(dialogContext, <String, String>{
                  'guest': '1',
                  'remember': '0',
                });
              } else if (usernameController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, <String, String>{
                  'username': usernameController.text.trim(),
                  'password': passwordController.text,
                  'remember': remember ? '1' : '0',
                });
              }
            },
            child: Text(l10n.sidebarConnect),
          ),
        ],
      ),
    ),
  );

  return result;
}

typedef NetworkPathPickCallback =
    void Function(String? path, {String? displayTitle, String? serverAddress});

Map<String, String> _parsePrefsPipeMap(String? raw) {
  final m = <String, String>{};
  if (raw == null || raw.isEmpty) return m;
  for (final entry in raw.split('|')) {
    final parts = entry.split('::');
    if (parts.length >= 2) {
      m[parts.first] = parts.sublist(1).join('::');
    }
  }
  return m;
}

String _prefsPipeMapToString(Map<String, String> m) =>
    m.entries.map((e) => '${e.key}::${e.value}').join('|');

/// Aggiorna [SharedPreferences] come la sidebar (Rete) quando si sceglie un percorso dal menu.
Future<void> persistNetworkPathBookmark(
  String path, {
  String? displayTitle,
  String? serverAddress,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final paths = List<String>.from(prefs.getStringList('network_paths') ?? []);
  if (!paths.contains(path)) {
    paths.add(path);
    await prefs.setStringList('network_paths', paths);
  }
  if (displayTitle != null && displayTitle.isNotEmpty) {
    final names = _parsePrefsPipeMap(prefs.getString('network_path_names'));
    names[path] = displayTitle;
    await prefs.setString('network_path_names', _prefsPipeMapToString(names));
  }
  if (serverAddress != null && serverAddress.isNotEmpty) {
    final servers = _parsePrefsPipeMap(prefs.getString('network_path_servers'));
    servers[path] = serverAddress;
    await prefs.setString(
      'network_path_servers',
      _prefsPipeMapToString(servers),
    );
  }
}

class Sidebar extends StatefulWidget {
  final String? selectedPath;
  final List<String> favoritePaths; // Percorsi preferiti
  final Function(String) onPathSelected;
  final Function(String) onAddPath;
  final VoidCallback? onComputer;
  final Function(String)? onRemovePath;
  final void Function(List<String> newFavoritePaths)? onFavoritePathsReordered;

  /// Segnale esterno (es. menu File) per ricaricare i segnalibri rete da prefs.
  final Listenable? networkBookmarksListenable;

  const Sidebar({
    super.key,
    this.selectedPath,
    this.favoritePaths = const [],
    required this.onPathSelected,
    required this.onAddPath,
    this.onComputer,
    this.onRemovePath,
    this.onFavoritePathsReordered,
    this.networkBookmarksListenable,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  static const String _customPathsPrefsKey = 'sidebar_custom_paths';
  List<String> standardDirs = [];
  List<Map<String, dynamic>> mountedDisks = [];
  List<String> customPaths = [];
  List<String> networkPaths = [];
  Map<String, String> networkPathNames =
      {}; // Mappa path -> nome personalizzato
  /// Sottotitolo (es. IP host) per mount CIFS in sidebar.
  Map<String, String> networkPathServers = {};
  bool isLoading = true;
  Timer? _diskMonitorTimer;
  Set<String> _previousDiskPaths =
      {}; // Traccia i dischi precedentemente montati
  /// Ordine utente di directory standard + percorsi personalizzati (persistente).
  /// Ordine unificato: directory standard, percorsi personalizzati e preferiti “solo elenco”.
  List<String> _sidebarPathsOrder = [];

  /// Percorsi tolti volontariamente dalla barra laterale (non si ripresentano finché non si resetta l’elenco).
  final Set<String> _removedFromSidebarList = {};

  @override
  void initState() {
    super.initState();
    widget.networkBookmarksListenable?.addListener(
      _onExternalNetworkBookmarksSignal,
    );
    _loadData();
    // Avvia il monitoraggio automatico dei dischi ogni 2 secondi
    _diskMonitorTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkForNewDisks(),
    );
  }

  void _onExternalNetworkBookmarksSignal() {
    unawaited(_loadNetworkPaths());
  }

  @override
  void dispose() {
    widget.networkBookmarksListenable?.removeListener(
      _onExternalNetworkBookmarksSignal,
    );
    _diskMonitorTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForNewDisks() async {
    try {
      final currentDisks = await FileService.getMountedDisks();
      final currentPaths = currentDisks.map((d) => d['path'] as String).toSet();

      // Se ci sono nuovi dischi montati, ricarica i dati
      if (currentPaths != _previousDiskPaths) {
        _previousDiskPaths = currentPaths;
        if (mounted) {
          setState(() {
            mountedDisks = currentDisks;
          });
        }
      }
    } catch (e) {
      // Ignora errori durante il monitoraggio
    }
  }

  List<String> _mergePlacesOrder(
    List<String> std,
    List<String> custom,
    List<String> saved,
  ) {
    final all = [...std, ...custom];
    final out = <String>[];
    for (final p in saved) {
      if (all.contains(p)) out.add(p);
    }
    for (final p in all) {
      if (!out.contains(p)) out.add(p);
    }
    return out;
  }

  /// Percorsi mostrati nella lista superiore (esclusi Rete/Dischi).
  Set<String> _allSidebarPathKeys() {
    final keys = <String>{...standardDirs, ...customPaths};
    for (final p in widget.favoritePaths) {
      if (!standardDirs.contains(p) && !customPaths.contains(p)) {
        keys.add(p);
      }
    }
    return keys;
  }

  List<String> _computeInitialSidebarOrder(
    List<String>? unifiedSaved,
    List<String> legacyPlaces,
  ) {
    final allowed = _allSidebarPathKeys();
    final out = <String>[];
    final List<String> source;
    if (unifiedSaved != null && unifiedSaved.isNotEmpty) {
      source = unifiedSaved;
    } else {
      final merged = List<String>.from(
        _mergePlacesOrder(standardDirs, customPaths, legacyPlaces),
      );
      for (final p in widget.favoritePaths) {
        if (!standardDirs.contains(p) &&
            !customPaths.contains(p) &&
            !merged.contains(p)) {
          merged.add(p);
        }
      }
      source = merged;
    }
    for (final p in source) {
      if (allowed.contains(p) && !_removedFromSidebarList.contains(p)) {
        out.add(p);
      }
    }
    for (final p in allowed) {
      if (_removedFromSidebarList.contains(p)) continue;
      if (!out.contains(p)) out.add(p);
    }
    return out;
  }

  void _pruneAndAppendSidebarPaths() {
    final allowed = _allSidebarPathKeys();
    _sidebarPathsOrder.removeWhere((p) => !allowed.contains(p));
    for (final p in allowed) {
      if (_removedFromSidebarList.contains(p)) continue;
      if (!_sidebarPathsOrder.contains(p)) {
        _sidebarPathsOrder.add(p);
      }
    }
  }

  Future<void> _saveSidebarPathsOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sidebar_unified_order', _sidebarPathsOrder);
  }

  Future<void> _saveRemovedFromSidebarList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sidebar_paths_removed_from_list',
      _removedFromSidebarList.toList(),
    );
  }

  void _syncFavoritePathsOrderWithParent() {
    if (widget.onFavoritePathsReordered == null) return;
    final favSet = widget.favoritePaths.toSet();
    final orderedInSidebar = _sidebarPathsOrder
        .where((p) => favSet.contains(p))
        .toList();
    final notInSidebar = widget.favoritePaths
        .where((p) => !_sidebarPathsOrder.contains(p))
        .toList();
    widget.onFavoritePathsReordered!(notInSidebar + orderedInSidebar);
  }

  Widget _sidebarDragProxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        return Material(
          color: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black54,
          elevation: 3 * t,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: child,
    );
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final dirs = await FileService.getStandardDirectories();
    final disks = await FileService.getMountedDisks();
    final prefs = await SharedPreferences.getInstance();
    final unifiedSaved = prefs.getStringList('sidebar_unified_order');
    final legacyPlaces = prefs.getStringList('sidebar_places_order') ?? [];
    final removedSaved =
        prefs.getStringList('sidebar_paths_removed_from_list') ?? [];
    final customSaved = prefs.getStringList(_customPathsPrefsKey) ?? [];
    await _loadNetworkPaths();

    setState(() {
      standardDirs = dirs;
      mountedDisks = disks;
      customPaths = customSaved;
      _removedFromSidebarList
        ..clear()
        ..addAll(removedSaved);
      _sidebarPathsOrder = _computeInitialSidebarOrder(
        unifiedSaved,
        legacyPlaces,
      );
      isLoading = false;
    });
  }

  Future<void> _saveCustomPaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customPathsPrefsKey, customPaths);
  }

  @override
  void didUpdateWidget(covariant Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.networkBookmarksListenable !=
        widget.networkBookmarksListenable) {
      oldWidget.networkBookmarksListenable?.removeListener(
        _onExternalNetworkBookmarksSignal,
      );
      widget.networkBookmarksListenable?.addListener(
        _onExternalNetworkBookmarksSignal,
      );
    }
    if (!listEquals(oldWidget.favoritePaths, widget.favoritePaths)) {
      setState(_pruneAndAppendSidebarPaths);
    }
  }

  Future<void> _addCustomPath() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && !customPaths.contains(result)) {
      setState(() {
        customPaths.add(result);
        if (!_sidebarPathsOrder.contains(result)) {
          _sidebarPathsOrder.add(result);
        }
      });
      _saveSidebarPathsOrder();
      _saveCustomPaths();
      widget.onAddPath(result);
    }
  }

  Future<void> _browseNetworkPath() async {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => NetworkBrowserDialog(
        onPathSelected: (path, {displayTitle, serverAddress}) {
          if (path != null) {
            if (!networkPaths.contains(path)) {
              setState(() {
                networkPaths.add(path);
                if (displayTitle != null && displayTitle.isNotEmpty) {
                  networkPathNames[path] = displayTitle;
                }
                if (serverAddress != null && serverAddress.isNotEmpty) {
                  networkPathServers[path] = serverAddress;
                }
              });
              _saveNetworkPaths();
            }
          }
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
          if (path != null) {
            widget.onPathSelected(path);
          }
        },
      ),
    );
  }

  Future<void> _addNetworkPath() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sidebarAddNetworkTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.sidebarNetworkPathLabel,
                      hintText: l10n.sidebarNetworkHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    final path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      controller.text = path;
                    }
                  },
                  tooltip: l10n.sidebarBrowseTooltip,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.sidebarNetworkHelp, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(dialogContext, controller.text);
              }
            },
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && !networkPaths.contains(result)) {
      setState(() {
        networkPaths.add(result);
      });
      await _saveNetworkPaths();
      widget.onAddPath(result);
    }
  }

  Future<void> _loadNetworkPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final networkPathsJson = prefs.getStringList('network_paths') ?? [];
    final networkNamesJson = prefs.getString('network_path_names');
    final networkServersJson = prefs.getString('network_path_servers');

    if (!mounted) return;
    setState(() {
      networkPaths = networkPathsJson;
      if (networkNamesJson != null) {
        try {
          final namesMap = <String, String>{};
          final entries = networkNamesJson.split('|');
          for (final entry in entries) {
            final parts = entry.split('::');
            if (parts.length == 2) {
              namesMap[parts[0]] = parts[1];
            }
          }
          networkPathNames = namesMap;
        } catch (e) {
          networkPathNames = {};
        }
      }
      if (networkServersJson != null && networkServersJson.isNotEmpty) {
        try {
          final serversMap = <String, String>{};
          for (final entry in networkServersJson.split('|')) {
            final parts = entry.split('::');
            if (parts.length == 2) {
              serversMap[parts[0]] = parts[1];
            }
          }
          networkPathServers = serversMap;
        } catch (e) {
          networkPathServers = {};
        }
      }
    });
  }

  Future<void> _saveNetworkPaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('network_paths', networkPaths);

    // Salva i nomi personalizzati
    final namesList = networkPathNames.entries
        .map((e) => '${e.key}::${e.value}')
        .join('|');
    await prefs.setString('network_path_names', namesList);
    final serversList = networkPathServers.entries
        .map((e) => '${e.key}::${e.value}')
        .join('|');
    await prefs.setString('network_path_servers', serversList);
  }

  String _folderTailName(String path) {
    final parts = path.split('/');
    if (parts.isEmpty) return path;
    String name = parts.last;
    if (name.isEmpty && parts.length > 1) name = parts[parts.length - 2];
    return name;
  }

  String _displayDirName(String path, AppLocalizations l10n) {
    if (path.contains('Trash') || path.contains('trash')) {
      return l10n.prefsNavTrash;
    }
    final name = _folderTailName(path);
    if (name.isEmpty) return l10n.sidebarUserFolderHome;

    switch (name) {
      case 'Desktop':
      case 'Scrivania':
        return l10n.sidebarUserFolderDesktop;
      case 'Documents':
      case 'Documenti':
        return l10n.sidebarUserFolderDocuments;
      case 'Pictures':
      case 'Immagini':
        return l10n.sidebarUserFolderPictures;
      case 'Music':
      case 'Musica':
        return l10n.sidebarUserFolderMusic;
      case 'Videos':
      case 'Video':
        return l10n.sidebarUserFolderVideos;
      case 'Downloads':
      case 'Scaricati':
        return l10n.sidebarUserFolderDownloads;
      case 'files':
      case 'Trash':
        return l10n.prefsNavTrash;
      default:
        return name;
    }
  }

  IconData _getDirIcon(String path) {
    final name = _folderTailName(path).toLowerCase();
    if (name == 'home' || path == '/home') return Icons.home;
    if (name == 'desktop') return Icons.desktop_windows;
    if (name == 'documents' || name == 'documenti') return Icons.folder;
    if (name == 'pictures' || name == 'immagini') return Icons.image;
    if (name == 'music' || name == 'musica') return Icons.music_note;
    if (name == 'videos' || name == 'video') return Icons.video_library;
    if (name == 'downloads' || name == 'scaricati') return Icons.download;
    if (path.contains('Trash') || path.contains('trash')) return Icons.delete;
    return Icons.folder;
  }

  void _onReorderSidebarPaths(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _sidebarPathsOrder.removeAt(oldIndex);
      _sidebarPathsOrder.insert(newIndex, item);
    });
    _saveSidebarPathsOrder();
    _syncFavoritePathsOrderWithParent();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme
            .scaffoldBackgroundColor, // Usa lo stesso colore di sfondo del tema
        // Rimossa la linea laterale destra
      ),
      child: Column(
        children: [
          // Header with add button
          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    Icons.add,
                    size: textTheme.bodyMedium?.fontSize != null
                        ? (textTheme.bodyMedium!.fontSize! * 1.4)
                        : 20,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    l10n.sidebarAddPath,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: textTheme.bodyMedium?.fontSize,
                      fontFamily: textTheme.bodyMedium?.fontFamily,
                    ),
                  ),
                  onTap: _addCustomPath,
                ),
                if (widget.onComputer != null)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Icon(
                      Icons.computer,
                      size: textTheme.bodyMedium?.fontSize != null
                          ? (textTheme.bodyMedium!.fontSize! * 1.4)
                          : 20,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      l10n.computerTitle,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: textTheme.bodyMedium?.fontSize,
                        fontFamily: textTheme.bodyMedium?.fontFamily,
                      ),
                    ),
                    onTap: widget.onComputer,
                  ),
              ],
            ),
          ),
          // Standard directories
          Expanded(
            child: GestureDetector(
              onSecondaryTapDown: (details) {
                _showSidebarContextMenu(details);
              },
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      cacheExtent: 500,
                      slivers: [
                        SliverReorderableList(
                          itemCount: _sidebarPathsOrder.length,
                          onReorder: _onReorderSidebarPaths,
                          proxyDecorator: _sidebarDragProxyDecorator,
                          itemBuilder: (context, index) {
                            final path = _sidebarPathsOrder[index];
                            final isCustom = customPaths.contains(path);
                            final isTrash =
                                path.contains('Trash') ||
                                path.contains('trash');
                            return ReorderableDragStartListener(
                              index: index,
                              key: ValueKey('sidebar_path_$path'),
                              child: _buildPathItem(
                                path,
                                _displayDirName(path, l10n),
                                _getDirIcon(path),
                                isTrash: isTrash,
                                isCustom: isCustom,
                                isFavorite: widget.favoritePaths.contains(path),
                              ),
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.sidebarSectionNetwork,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    shadows:
                                        (textTheme.titleSmall?.shadows !=
                                                null &&
                                            textTheme
                                                .titleSmall!
                                                .shadows!
                                                .isNotEmpty)
                                        ? textTheme.titleSmall!.shadows
                                        : null,
                                    fontSize: textTheme.titleSmall?.fontSize,
                                    fontFamily:
                                        textTheme.titleSmall?.fontFamily,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.folder_open,
                                        size: 18,
                                      ),
                                      onPressed: _browseNetworkPath,
                                      tooltip:
                                          l10n.sidebarTooltipBrowseNetworkPaths,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: _addNetworkPath,
                                      tooltip:
                                          l10n.sidebarTooltipAddNetworkPath,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildNetworkItem(networkPaths[index]),
                            childCount: networkPaths.length,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              l10n.sidebarSectionDisks,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                shadows:
                                    (textTheme.titleSmall?.shadows != null &&
                                        textTheme
                                            .titleSmall!
                                            .shadows!
                                            .isNotEmpty)
                                    ? textTheme.titleSmall!.shadows
                                    : null,
                                fontSize: textTheme.titleSmall?.fontSize,
                                fontFamily: textTheme.titleSmall?.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildDiskItem(mountedDisks[index]),
                            childCount: mountedDisks.length,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildOldListView removed (unused).

  Widget _buildPathItem(
    String path,
    String name,
    IconData icon, {
    bool isCustom = false,
    bool isTrash = false,
    bool isFavorite = false,
  }) {
    final isSelected = widget.selectedPath == path;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final enableTextShadow =
        (textTheme.bodyMedium?.shadows != null &&
        textTheme.bodyMedium!.shadows!.isNotEmpty);
    final textShadow = enableTextShadow ? textTheme.bodyMedium!.shadows : null;

    return RepaintBoundary(
      child: FutureBuilder<int?>(
        future: FolderIconService.getFolderColor(path),
        builder: (context, colorSnapshot) {
          final folderColor = colorSnapshot.data != null
              ? Color(colorSnapshot.data!)
              : null;
          return GestureDetector(
            onSecondaryTapDown: (details) {
              _showFolderContextMenu(
                details,
                path,
                name,
                isCustom,
                isTrash,
                folderColor,
              );
            },
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: Icon(
                icon,
                size: textTheme.bodyMedium?.fontSize != null
                    ? (textTheme.bodyMedium!.fontSize! * 1.4)
                    : 20,
                color:
                    folderColor ??
                    (isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary.withOpacity(0.7)),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isSelected
                            ? (theme.brightness == Brightness.dark
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        shadows: textShadow,
                        fontSize: textTheme.bodyMedium?.fontSize,
                        fontFamily: textTheme.bodyMedium?.fontFamily,
                      ),
                    ),
                  ),
                  if (isFavorite)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.star,
                        size: textTheme.bodyMedium?.fontSize != null
                            ? (textTheme.bodyMedium!.fontSize! * 1.1)
                            : 16,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(
                0.7,
              ),
              tileColor: isSelected ? null : Colors.transparent,
              onTap: () => widget.onPathSelected(path),
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkItem(String path) {
    final isSelected = widget.selectedPath == path;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final enableTextShadow =
        (textTheme.bodyMedium?.shadows != null &&
        textTheme.bodyMedium!.shadows!.isNotEmpty);
    final textShadow = enableTextShadow ? textTheme.bodyMedium!.shadows : null;
    final cifsInfo = NetworkBrowserService.tryParseFmCifsMountPath(path);
    final displayName =
        networkPathNames[path] ??
        (cifsInfo != null
            ? cifsInfo.share
            : (path.split('/').last.isEmpty ? path : path.split('/').last));
    final subtitleText =
        networkPathServers[path] ?? (cifsInfo != null ? cifsInfo.server : path);

    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showNetworkContextMenu(path, details.globalPosition);
      },
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          Icons.cloud,
          size: 20,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary.withOpacity(0.7),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            color: isSelected
                ? (theme.brightness == Brightness.dark
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.primary)
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            shadows: textShadow,
            fontSize: textTheme.bodyMedium?.fontSize,
            fontFamily: textTheme.bodyMedium?.fontFamily,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            fontSize: (textTheme.bodySmall?.fontSize ?? 10),
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontFamily: textTheme.bodySmall?.fontFamily,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer,
        onTap: () => unawaited(_openSavedNetworkBookmark(path)),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () async {
            setState(() {
              networkPaths.remove(path);
              networkPathNames.remove(path);
              networkPathServers.remove(path);
            });
            await _saveNetworkPaths();
          },
          tooltip: AppLocalizations.of(context).sidebarTooltipRemoveNetwork,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  /// Dopo reboot il path salvato (`/tmp/fm_cifs_…`) non è montato: rimonta come da Rete.
  Future<void> _openSavedNetworkBookmark(
    String path, {
    bool skipSavedCreds = false,
  }) async {
    if (!Platform.isLinux) {
      widget.onPathSelected(path);
      return;
    }

    final cifsInfo = NetworkBrowserService.tryParseFmCifsMountPath(path);
    if (cifsInfo == null) {
      widget.onPathSelected(path);
      return;
    }

    final server = cifsInfo.server;
    final shareName = cifsInfo.share;

    final activeCifs = await NetworkBrowserService.mountedCifsPathIfActive(
      server,
      shareName,
    );
    if (activeCifs != null) {
      widget.onPathSelected(activeCifs);
      return;
    }

    if (!mounted) return;
    final depsOk = await ensureMountCifsForNetwork(context);
    if (!depsOk || !mounted) return;

    final l10n = AppLocalizations.of(context);

    if (!skipSavedCreds) {
      final saved = await NetworkCredentialsStore.load(server);
      if (saved != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text(l10n.sidebarConnecting(shareName)),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );

        final outcome = await NetworkBrowserService.connectToShareWithOutcome(
          server,
          shareName,
          username: saved.$1,
          password: saved.$2,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (outcome.isSuccess) {
          widget.onPathSelected(outcome.path!);
          return;
        }
      }
    }

    if (!mounted) return;

    final credentials = await showSmbCredentialsDialog(context, server);
    if (!mounted) return;
    if (credentials == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(l10n.sidebarConnecting(shareName)),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    final isGuest = credentials['guest'] == '1';
    final hasUser =
        !isGuest &&
        credentials.isNotEmpty &&
        (credentials['username']?.trim().isNotEmpty ?? false);

    final outcome = await NetworkBrowserService.connectToShareWithOutcome(
      server,
      shareName,
      username: hasUser ? credentials['username']?.trim() : null,
      password: hasUser ? credentials['password'] : null,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (outcome.isSuccess) {
      if (hasUser) {
        await NetworkCredentialsStore.save(
          server,
          credentials['username']!.trim(),
          credentials['password'] ?? '',
        );
      }
      widget.onPathSelected(outcome.path!);
      return;
    }

    final detail = outcome.message;
    final msg = detail == 'missing_mount_cifs'
        ? l10n.computerMountMissingGio
        : detail == 'need_password'
        ? l10n.computerMountNeedPassword
        : (detail != null && detail.isNotEmpty && detail != 'cifs_mount_failed'
              ? '${l10n.sidebarConnectionError(shareName)}\n${detail.length > 200 ? '${detail.substring(0, 200)}…' : detail}'
              : l10n.sidebarConnectionError(shareName));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: l10n.sidebarRetry,
          onPressed: () =>
              unawaited(_openSavedNetworkBookmark(path, skipSavedCreds: true)),
        ),
      ),
    );
  }

  void _showNetworkContextMenu(String path, Offset position) {
    final l10n = AppLocalizations.of(context);

    // Build menu items for FluidContextMenu
    final List<Widget> menuItems = [
      PopupMenuItem<String>(
        value: 'rename',
        child: Row(
          children: [
            const Icon(Icons.edit, size: 16),
            const SizedBox(width: 6),
            Text(l10n.commonRename),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, size: 16),
            const SizedBox(width: 6),
            Text(l10n.commonDelete),
          ],
        ),
      ),
    ];

    // Show fluid context menu
    final overlayEntry = FluidContextMenu.show(
      context,
      position: position,
      menuItems: menuItems,
      onSelected: (value) async {
        // Handle menu selection
        if (value == 'rename') {
          await _renameNetworkPath(path);
        } else if (value == 'delete') {
          await _deleteNetworkPath(path);
        }
      },
      onDismiss: () {
        // Menu dismissed
      },
      dismissOnSelect: true,
    );
  }

  Future<void> _renameNetworkPath(String path) async {
    final l10n = AppLocalizations.of(context);
    final cifs = NetworkBrowserService.tryParseFmCifsMountPath(path);
    final defaultName =
        networkPathNames[path] ??
        (cifs != null
            ? cifs.share
            : (path.split('/').last.isEmpty ? path : path.split('/').last));
    final controller = TextEditingController(text: defaultName);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sidebarRenameShareTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.labelNetworkShareName,
            hintText: l10n.hintNetworkShareName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        networkPathNames[path] = result;
      });
      await _saveNetworkPaths();
    }
  }

  Future<void> _deleteNetworkPath(String path) async {
    final l10n = AppLocalizations.of(context);
    final nm = networkPathNames[path] ?? path;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sidebarRemoveShareTitle),
        content: Text(l10n.sidebarRemoveShareConfirm(nm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        networkPaths.remove(path);
        networkPathNames.remove(path);
        networkPathServers.remove(path);
      });
      await _saveNetworkPaths();
    }
  }

  Widget _buildDiskItem(Map<String, dynamic> disk) {
    final path = disk['path'] as String;
    final displayName = (disk['display_name'] ?? disk['name']) as String;
    final mountPoint = disk['mount_point'] as String? ?? path;
    final isSelected = widget.selectedPath == path;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final enableTextShadow =
        (textTheme.bodyMedium?.shadows != null &&
        textTheme.bodyMedium!.shadows!.isNotEmpty);
    final textShadow = enableTextShadow ? textTheme.bodyMedium!.shadows : null;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(
        Icons.storage_outlined,
        size: 20,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary.withOpacity(0.7),
      ),
      title: Text(
        displayName,
        style: TextStyle(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary)
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          shadows: textShadow,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer,
      onTap: () => widget.onPathSelected(path),
      trailing: IconButton(
        icon: const Icon(Icons.eject, size: 18),
        onPressed: () => _unmountDisk(mountPoint, displayName),
        tooltip: AppLocalizations.of(context).sidebarTooltipUnmount,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Future<void> _unmountDisk(String mountPoint, String diskName) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sidebarUnmountTitle),
        content: Text(l10n.sidebarUnmountConfirm(diskName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.sidebarUnmount),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await FileService.unmountDisk(mountPoint);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.sidebarUnmountSuccess(diskName))),
            );
            _loadData(); // Reload to update disk list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.sidebarUnmountFail(diskName))),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.commonError(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _removePathFromSidebarList(String path) async {
    final wasCustom = customPaths.contains(path);
    final wasFavorite = widget.favoritePaths.contains(path);

    setState(() {
      _sidebarPathsOrder.remove(path);
      _removedFromSidebarList.add(path);
      if (wasCustom) {
        customPaths.remove(path);
      }
    });
    await _saveSidebarPathsOrder();
    await _saveRemovedFromSidebarList();
    if (wasCustom) {
      await _saveCustomPaths();
    }

    if (wasFavorite && widget.onFavoritePathsReordered != null) {
      widget.onFavoritePathsReordered!(
        List<String>.from(widget.favoritePaths)..remove(path),
      );
    }

    if (wasCustom) {
      widget.onRemovePath?.call(path);
    } else if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackPathRemoved(p.basename(path)))),
      );
    }
  }

  void _showFolderContextMenu(
    TapDownDetails details,
    String path,
    String name,
    bool isCustom,
    bool isTrash,
    Color? currentColor,
  ) {
    final l10n = AppLocalizations.of(context);

    // Build menu items for FluidContextMenu
    final List<Widget> menuItems = [];

    if (isTrash) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'empty_trash',
          child: Row(
            children: [
              const Icon(Icons.delete_sweep, size: 16),
              const SizedBox(width: 6),
              Text(l10n.sidebarEmptyTrash),
            ],
          ),
        ),
      );
    }

    if (!isTrash) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              const Icon(Icons.playlist_remove, size: 16),
              const SizedBox(width: 6),
              Text(l10n.sidebarRemoveFromList),
            ],
          ),
        ),
      );
    }

    menuItems.add(
      PopupMenuItem<String>(
        value: 'properties',
        child: Row(
          children: [
            const Icon(Icons.palette, size: 16),
            const SizedBox(width: 6),
            Text(l10n.sidebarMenuChangeColor),
          ],
        ),
      ),
    );

    // Show fluid context menu
    final overlayEntry = FluidContextMenu.show(
      context,
      position: Offset(details.globalPosition.dx, details.globalPosition.dy),
      menuItems: menuItems,
      onSelected: (value) async {
        // Handle menu selection
        if (value == 'empty_trash') {
          _emptyTrash(path);
        } else if (value == 'remove') {
          await _removePathFromSidebarList(path);
        } else if (value == 'properties') {
          _showFolderPropertiesDialog(path, name, currentColor);
        }
      },
      onDismiss: () {
        // Menu dismissed
      },
    );
  }

  void _showFolderPropertiesDialog(
    String folderPath,
    String folderName,
    Color? currentColor,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sidebarChangeColorDialogTitle(folderName)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.sidebarChangeFolderColor),
              const SizedBox(height: 16),
              BlockPicker(
                pickerColor: currentColor ?? Theme.of(ctx).colorScheme.primary,
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
    );
  }

  void _showSidebarContextMenu(TapDownDetails details) {
    final l10n = AppLocalizations.of(context);

    // Build menu items for FluidContextMenu
    final List<Widget> menuItems = [
      PopupMenuItem<String>(
        value: 'change_color',
        child: Row(
          children: [
            const Icon(Icons.palette, size: 16),
            const SizedBox(width: 6),
            Text(l10n.sidebarChangeAllFoldersColor),
          ],
        ),
      ),
    ];

    // Show fluid context menu
    final overlayEntry = FluidContextMenu.show(
      context,
      position: Offset(details.globalPosition.dx, details.globalPosition.dy),
      menuItems: menuItems,
      onSelected: (value) {
        // Handle menu selection
        if (value == 'change_color') {
          _showGlobalFolderColorDialog();
        }
      },
      onDismiss: () {
        // Menu dismissed
      },
    );
  }

  void _showGlobalFolderColorDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sidebarChangeAllFoldersColor),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.sidebarPickDefaultColor),
              const SizedBox(height: 16),
              BlockPicker(
                pickerColor: Theme.of(ctx).colorScheme.primary,
                onColorChanged: (color) async {
                  await FolderIconService.setSelectedColor(color.value);
                  setState(() {}); // Refresh to show new color
                  Navigator.pop(ctx);
                },
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
    );
  }

  Future<void> _emptyTrash(String trashPath) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    );

    if (confirmed == true) {
      try {
        final trashDir = Directory(trashPath);
        if (await trashDir.exists()) {
          await for (final entity in trashDir.list()) {
            try {
              if (entity is File) {
                await entity.delete(recursive: true);
              } else if (entity is Directory) {
                await entity.delete(recursive: true);
              }
            } catch (e) {
              // Continue with other files
            }
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.sidebarTrashEmptied)));
          if (widget.selectedPath == trashPath) {
            widget.onPathSelected(trashPath);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.commonError(e.toString()))),
          );
        }
      }
    }
  }
}

/// Dialog per esplorare condivisioni di rete (sidebar Rete e menu File).
class NetworkBrowserDialog extends StatefulWidget {
  final NetworkPathPickCallback onPathSelected;

  const NetworkBrowserDialog({super.key, required this.onPathSelected});

  @override
  State<NetworkBrowserDialog> createState() => _NetworkBrowserDialogState();
}

class _NetworkBrowserDialogState extends State<NetworkBrowserDialog> {
  List<Map<String, String>> servers = [];
  Map<String, List<Map<String, String>>> shares = {};
  bool isLoading = true;
  String? selectedServer;
  bool isLoadingShares = false;
  DependencyCheckResult? _networkDepsBanner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refreshNetworkDepsBanner());
      _discoverServers();
    });
  }

  Future<void> _refreshNetworkDepsBanner() async {
    if (!Platform.isLinux) return;
    final r = await SystemDependenciesService.checkDependenciesByIds(
      SystemDependenciesService.networkDiscoveryDependencyIds,
    );
    if (!mounted) return;
    setState(() {
      _networkDepsBanner = r.missingCommands.isNotEmpty ? r : null;
    });
  }

  Future<void> _afterNetworkDepsInstall() async {
    await _refreshNetworkDepsBanner();
    if (!mounted) return;
    if (_networkDepsBanner == null) {
      await _discoverServers();
    }
  }

  Future<void> _discoverServers() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final discoveredServers =
          await NetworkBrowserService.discoverNetworkServers(
            onPartial: (partial) {
              if (mounted) {
                setState(() {
                  servers = partial;
                  isLoading = true;
                });
              }
            },
          );
      if (mounted) {
        setState(() {
          servers = discoveredServers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// [server] include sempre `address` (IP) per smbclient/mount; `name` è solo etichetta.
  Future<void> _loadShares(Map<String, String> server) async {
    final host = server['address'] ?? server['name']!;
    if (shares.containsKey(host)) {
      setState(() {
        selectedServer = host;
      });
      return;
    }

    setState(() {
      selectedServer = host;
      isLoadingShares = true;
    });

    try {
      var serverShares = await NetworkBrowserService.listShares(host);
      if (serverShares.isEmpty) {
        final saved = await NetworkCredentialsStore.load(host);
        if (saved != null) {
          serverShares = await NetworkBrowserService.listShares(
            host,
            username: saved.$1,
            password: saved.$2,
          );
        }
      }

      Map<String, String>? credsUsedForListing;
      if (serverShares.isEmpty && mounted) {
        final credentials = await showSmbCredentialsDialog(context, host);
        if (credentials == null) {
          if (mounted) {
            setState(() {
              shares[host] = [];
              isLoadingShares = false;
            });
          }
          return;
        }
        if (credentials.isEmpty) {
          serverShares = await NetworkBrowserService.listShares(host);
        } else {
          credsUsedForListing = credentials;
          serverShares = await NetworkBrowserService.listShares(
            host,
            username: credentials['username'],
            password: credentials['password'] ?? '',
          );
        }
      }

      if (serverShares.isNotEmpty && credsUsedForListing != null) {
        final u = credsUsedForListing['username']?.trim() ?? '';
        if (u.isNotEmpty) {
          await NetworkCredentialsStore.save(
            host,
            u,
            credsUsedForListing['password'] ?? '',
          );
        }
      }

      if (mounted) {
        setState(() {
          shares[host] = serverShares;
          isLoadingShares = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingShares = false;
        });
      }
    }
  }

  Future<void> _connectToShare(Map<String, String> share) async {
    final l10n = AppLocalizations.of(context);
    final server = share['server']!;
    final shareName = share['name']!;

    final activeCifs = await NetworkBrowserService.mountedCifsPathIfActive(
      server,
      shareName,
    );
    if (activeCifs != null) {
      widget.onPathSelected(
        activeCifs,
        displayTitle: shareName,
        serverAddress: server,
      );
      return;
    }

    if (Platform.isLinux) {
      final depsOk = await ensureMountCifsForNetwork(context);
      if (!depsOk || !mounted) return;

      final saved = await NetworkCredentialsStore.load(server);
      if (saved != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text(l10n.sidebarConnecting(shareName)),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );
        final savedOutcome =
            await NetworkBrowserService.connectToShareWithOutcome(
              server,
              shareName,
              username: saved.$1,
              password: saved.$2,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (savedOutcome.isSuccess) {
          widget.onPathSelected(
            savedOutcome.path!,
            displayTitle: shareName,
            serverAddress: server,
          );
          return;
        }
      }
    }

    final credentials = await showSmbCredentialsDialog(context, server);

    if (!mounted) return;
    if (credentials == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(l10n.sidebarConnecting(shareName)),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    final isGuest = credentials['guest'] == '1';
    final hasUser =
        !isGuest &&
        credentials.isNotEmpty &&
        (credentials['username']?.trim().isNotEmpty ?? false);

    final outcome = await NetworkBrowserService.connectToShareWithOutcome(
      server,
      shareName,
      username: hasUser ? credentials['username']?.trim() : null,
      password: hasUser ? credentials['password'] : null,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (outcome.isSuccess) {
      if (hasUser) {
        await NetworkCredentialsStore.save(
          server,
          credentials['username']!.trim(),
          credentials['password'] ?? '',
        );
      }
      widget.onPathSelected(
        outcome.path!,
        displayTitle: shareName,
        serverAddress: server,
      );
    } else {
      final detail = outcome.message;
      final msg = detail == 'missing_mount_cifs'
          ? l10n.computerMountMissingGio
          : detail == 'need_password'
          ? l10n.computerMountNeedPassword
          : (detail != null &&
                    detail.isNotEmpty &&
                    detail != 'cifs_mount_failed'
                ? '${l10n.sidebarConnectionError(shareName)}\n${detail.length > 200 ? '${detail.substring(0, 200)}…' : detail}'
                : l10n.sidebarConnectionError(shareName));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(
            label: l10n.sidebarRetry,
            onPressed: () => _connectToShare(share),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.networkBrowserTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: l10n.networkRefreshTooltip,
                      onPressed: _discoverServers,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            if (_networkDepsBanner != null) ...[
              const SizedBox(height: 8),
              NetworkDependenciesBanner(
                result: _networkDepsBanner!,
                onDismiss: () => setState(() => _networkDepsBanner = null),
                onAfterInstallAttempt: _afterNetworkDepsInstall,
              ),
            ],
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            l10n.networkSearchingServers,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : servers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.networkNoServersFound,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _discoverServers,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.sidebarRetry),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Lista server e condivisioni
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.dns,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.networkServersSharesHeader,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: servers.length,
                                    itemBuilder: (context, index) {
                                      final server = servers[index];
                                      final nm = (server['name'] ?? '').trim();
                                      final addr = (server['address'] ?? '')
                                          .trim();
                                      final nameIsIp = RegExp(
                                        r'^\d{1,3}(\.\d{1,3}){3}$',
                                      ).hasMatch(nm);
                                      final hasHostname =
                                          nm.isNotEmpty &&
                                          addr.isNotEmpty &&
                                          nm != addr &&
                                          !nameIsIp;
                                      final serverName = hasHostname
                                          ? nm
                                          : (nm.isNotEmpty
                                                ? nm
                                                : (addr.isNotEmpty
                                                      ? addr
                                                      : l10n.commonUnknown));
                                      final hostKey =
                                          server['address'] ??
                                          server['name'] ??
                                          serverName;
                                      final isSelected =
                                          selectedServer == hostKey;
                                      final serverShares =
                                          shares[hostKey] ?? [];

                                      return ExpansionTile(
                                        leading: Icon(
                                          isSelected
                                              ? Icons.dns
                                              : Icons.dns_outlined,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                    .withOpacity(0.7),
                                        ),
                                        title: Text(
                                          serverName,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        subtitle: Text(
                                          hasHostname
                                              ? '$addr · SMB'
                                              : (addr.isNotEmpty
                                                    ? '$addr · SMB'
                                                    : hostKey),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        initiallyExpanded: isSelected,
                                        onExpansionChanged: (expanded) {
                                          if (expanded) {
                                            _loadShares(server);
                                          }
                                        },
                                        children: [
                                          if (isLoadingShares &&
                                              selectedServer == hostKey)
                                            const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          else if (serverShares.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Text(
                                                l10n.networkNoSharesAvailable,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            )
                                          else
                                            ...serverShares.map(
                                              (share) => ListTile(
                                                dense: true,
                                                leading: Icon(
                                                  Icons.folder_shared,
                                                  size: 20,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                title: Text(
                                                  share['name'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  share['path'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.6),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                trailing: Icon(
                                                  Icons.chevron_right,
                                                  size: 18,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                                ),
                                                onTap: () =>
                                                    _connectToShare(share),
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
                        ),
                        const SizedBox(width: 16),
                        // Info panel
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.networkInfoTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.networkServersFoundCount(servers.length),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.networkConnectShareInstructions,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const Spacer(),
                                if (selectedServer != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.networkSelectedServerLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedServer!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        if (shares[selectedServer!] != null)
                                          Text(
                                            l10n.networkSharesCount(
                                              shares[selectedServer!]!.length,
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
