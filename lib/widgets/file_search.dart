import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/services/file_service.dart';
import 'package:filemanager/services/file_search_service.dart';
import 'package:filemanager/widgets/file_list.dart';
import 'package:filemanager/utils/format_bytes.dart';
import 'package:file_picker/file_picker.dart';

class FileSearch extends StatefulWidget {
  final Function(FileInfo) onFileSelected;
  final String? initialPath;

  const FileSearch({super.key, this.initialPath, required this.onFileSelected});

  @override
  State<FileSearch> createState() => _FileSearchState();
}

class _FileSearchState extends State<FileSearch> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _extensionFilterController =
      TextEditingController();
  final TextEditingController _sizeMinController = TextEditingController();
  final TextEditingController _sizeMaxController = TextEditingController();

  List<FileInfo> searchResults = [];
  bool isSearching = false;
  bool includeSystemFiles = false;
  String searchPath = Platform.environment['HOME'] ?? '/';

  /// Canonical: images, video, audio, documents, archives, executables; null = all
  String? selectedFileTypeKey;

  /// Canonical: today, week, month, year; null = any
  String? selectedDateFilterKey;
  bool shouldStopSearch = false;
  List<Map<String, dynamic>> mountedDisks = [];

  /// Home utente (percorso reale, es. /home/nome); usato nel menu dischi e come default.
  String _homePath = '';

  ViewMode resultViewMode = ViewMode.list; // View mode for results
  int gridZoomLevel = 3; // 1-5, where 1 is most zoomed in, 5 is most zoomed out

  @override
  void initState() {
    super.initState();
    _homePath = Platform.environment['HOME'] ?? '';
    _loadHomePath();
    _loadDisks();
  }

  Future<void> _loadHomePath() async {
    final home = await FileService.getHomeDirectory();
    if (!mounted) return;
    setState(() {
      _homePath = home;
      if (widget.initialPath != null && widget.initialPath!.isNotEmpty) {
        searchPath = widget.initialPath!;
      } else {
        searchPath = home;
      }
    });
  }

  Future<void> _loadDisks() async {
    final disks = await FileService.getMountedDisks();
    setState(() => mountedDisks = disks);
  }

  Future<void> _performSearch() async {
    final l10n = AppLocalizations.of(context);
    if (_searchController.text.isEmpty &&
        _nameFilterController.text.isEmpty &&
        _extensionFilterController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.searchNoCriteriaSnack)));
      return;
    }

    // Use search controller as primary, fallback to name filter
    final searchText = _searchController.text.trim();
    final nameFilter = _nameFilterController.text.trim();
    final extensionFilter = _extensionFilterController.text.trim();

    // Determine effective filters
    String? effectiveNameFilter = nameFilter.isNotEmpty ? nameFilter : null;
    String? effectiveExtensionFilter = extensionFilter.isNotEmpty
        ? extensionFilter
        : null;

    if (searchText.isNotEmpty) {
      if (searchText.startsWith('*.') || searchText.contains('*')) {
        // Pattern search
        effectiveExtensionFilter = searchText;
      } else {
        effectiveNameFilter = searchText;
      }
    }

    setState(() {
      isSearching = true;
      shouldStopSearch = false;
      searchResults.clear();
    });

    try {
      final resultStream = FileSearchService.searchFilesStream(
        searchPath: searchPath,
        nameFilter: effectiveNameFilter,
        extensionFilter: effectiveExtensionFilter,
        minSize: _sizeMinController.text.isEmpty
            ? null
            : int.tryParse(_sizeMinController.text),
        maxSize: _sizeMaxController.text.isEmpty
            ? null
            : int.tryParse(_sizeMaxController.text),
        fileType: selectedFileTypeKey,
        dateFilter: selectedDateFilterKey,
        includeSystemFiles: includeSystemFiles,
        shouldStop: () => shouldStopSearch,
      );

      await for (final fileInfo in resultStream) {
        if (mounted && !shouldStopSearch) {
          setState(() {
            searchResults.add(fileInfo);
          });
        }
      }

      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).searchError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  String _formatListedSize(FileInfo file) =>
      file.isDir ? '\u2014' : formatBytesBinary(file.size);

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _stopSearch() {
    setState(() {
      shouldStopSearch = true;
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.searchDialogTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Selected path display with disk selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        const Icon(Icons.folder, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.searchPathLabel(searchPath),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.storage, size: 18),
                          tooltip: l10n.searchSelectDiskTooltip,
                          onSelected: (path) {
                            setState(() {
                              searchPath = path;
                            });
                          },
                          itemBuilder: (context) {
                            final items = <PopupMenuEntry<String>>[];
                            items.add(
                              PopupMenuItem(
                                value: searchPath,
                                child: Text(l10n.searchPathCurrentMenu),
                              ),
                            );
                            items.add(
                              PopupMenuItem(
                                value: '/',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.searchPathRootMenu),
                                    Text(
                                      '/',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (_homePath.isNotEmpty) {
                              items.add(
                                PopupMenuItem(
                                  value: _homePath,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.sidebarUserFolderHome),
                                      Text(
                                        _homePath,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            for (final disk in mountedDisks) {
                              final raw = disk['path'] ?? disk['mount_point'];
                              final diskPath =
                                  raw == null ? '' : raw.toString();
                              if (diskPath.isEmpty || diskPath == '/') {
                                continue;
                              }
                              if (_homePath.isNotEmpty &&
                                  diskPath == _homePath) {
                                continue;
                              }
                              final diskName =
                                  (disk['display_name'] ?? disk['name'])
                                      as String;
                              items.add(
                                PopupMenuItem(
                                  value: diskPath,
                                  child: Text(diskName),
                                ),
                              );
                            }
                            return items;
                          },
                        ),
                      ],
                    ),
                  ),
                  // Search filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          enableInteractiveSelection: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _performSearch(),
                          decoration: InputDecoration(
                            labelText: l10n.searchLabelQuery,
                            hintText: l10n.searchHintQuery,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            helperText: l10n.searchHelperPatterns,
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameFilterController,
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelNameFilter,
                                  hintText: l10n.searchHintNameFilter,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _extensionFilterController,
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelExtension,
                                  hintText: l10n.searchHintExtension,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _sizeMinController,
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelSizeMin,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _sizeMaxController,
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelSizeMax,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedFileTypeKey,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelFileType,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(l10n.searchTypeAll),
                                  ),
                                  DropdownMenuItem(
                                    value: 'images',
                                    child: Text(l10n.searchTypeImages),
                                  ),
                                  DropdownMenuItem(
                                    value: 'video',
                                    child: Text(l10n.searchTypeVideo),
                                  ),
                                  DropdownMenuItem(
                                    value: 'audio',
                                    child: Text(l10n.searchTypeAudio),
                                  ),
                                  DropdownMenuItem(
                                    value: 'documents',
                                    child: Text(l10n.searchTypeDocuments),
                                  ),
                                  DropdownMenuItem(
                                    value: 'archives',
                                    child: Text(l10n.searchTypeArchives),
                                  ),
                                  DropdownMenuItem(
                                    value: 'executables',
                                    child: Text(l10n.searchTypeExecutables),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => selectedFileTypeKey = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDateFilterKey,
                                decoration: InputDecoration(
                                  labelText: l10n.searchLabelDateFilter,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(l10n.searchDateAll),
                                  ),
                                  DropdownMenuItem(
                                    value: 'today',
                                    child: Text(l10n.searchDateToday),
                                  ),
                                  DropdownMenuItem(
                                    value: 'week',
                                    child: Text(l10n.searchDateWeek),
                                  ),
                                  DropdownMenuItem(
                                    value: 'month',
                                    child: Text(l10n.searchDateMonth),
                                  ),
                                  DropdownMenuItem(
                                    value: 'year',
                                    child: Text(l10n.searchDateYear),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => selectedDateFilterKey = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: includeSystemFiles,
                              onChanged: (value) {
                                setState(
                                  () => includeSystemFiles = value ?? false,
                                );
                              },
                            ),
                            Text(
                              l10n.searchIncludeSystemFiles,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.folder),
                              label: Text(l10n.searchChoosePath),
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .getDirectoryPath();
                                if (result != null) {
                                  setState(() => searchPath = result);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            if (isSearching)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.stop),
                                label: Text(l10n.searchStop),
                                onPressed: _stopSearch,
                              )
                            else
                              ElevatedButton.icon(
                                icon: const Icon(Icons.search),
                                label: Text(l10n.searchSearchButton),
                                onPressed: _performSearch,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Results - show in realtime
                  Expanded(
                    child: isSearching && searchResults.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.searchNoResults,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Results count and view mode selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      searchResults.length == 1
                                          ? l10n.searchResultsOne
                                          : l10n.searchResultsMany(
                                              searchResults.length,
                                            ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    // View mode selector
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.view_list,
                                            color:
                                                resultViewMode == ViewMode.list
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => resultViewMode =
                                                  ViewMode.list,
                                            );
                                          },
                                          tooltip: l10n.searchTooltipViewList,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.view_module,
                                            color:
                                                resultViewMode == ViewMode.grid
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => resultViewMode =
                                                  ViewMode.grid,
                                            );
                                          },
                                          tooltip: l10n.searchTooltipViewGrid,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.view_headline,
                                            color:
                                                resultViewMode ==
                                                    ViewMode.details
                                                ? theme.colorScheme.primary
                                                : null,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => resultViewMode =
                                                  ViewMode.details,
                                            );
                                          },
                                          tooltip:
                                              l10n.searchTooltipViewDetails,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Results list/grid
                              Expanded(
                                child: resultViewMode == ViewMode.grid
                                    ? Stack(
                                        children: [
                                          GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      gridZoomLevel.clamp(
                                                        1,
                                                        10,
                                                      ) +
                                                      1,
                                                  childAspectRatio: 0.85,
                                                  crossAxisSpacing: 2,
                                                  mainAxisSpacing: 2,
                                                ),
                                            padding: const EdgeInsets.all(4),
                                            itemCount: searchResults.length,
                                            itemBuilder: (context, index) {
                                              final file = searchResults[index];
                                              return InkWell(
                                                onTap: () {
                                                  widget.onFileSelected(file);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 2,
                                                        vertical: 4,
                                                      ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        file.isDir
                                                            ? Icons.folder
                                                            : Icons
                                                                  .insert_drive_file,
                                                        size: 48,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Flexible(
                                                        child: Text(
                                                          file.name,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          // Zoom controls in bottom right
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.zoom_out,
                                                    ),
                                                    onPressed: gridZoomLevel > 1
                                                        ? () {
                                                            setState(
                                                              () =>
                                                                  gridZoomLevel--,
                                                            );
                                                          }
                                                        : null,
                                                    tooltip: l10n.searchZoomOut,
                                                    iconSize: 20,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      '${gridZoomLevel}/5',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.zoom_in,
                                                    ),
                                                    onPressed: gridZoomLevel < 5
                                                        ? () {
                                                            setState(
                                                              () =>
                                                                  gridZoomLevel++,
                                                            );
                                                          }
                                                        : null,
                                                    tooltip: l10n.searchZoomIn,
                                                    iconSize: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : resultViewMode == ViewMode.details
                                    ? SingleChildScrollView(
                                        child: DataTable(
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                              ),
                                          columns: [
                                            DataColumn(
                                              label: Text(l10n.tableColumnName),
                                            ),
                                            DataColumn(
                                              label: Text(l10n.tableColumnPath),
                                            ),
                                            DataColumn(
                                              label: Text(l10n.tableColumnSize),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                l10n.tableColumnModified,
                                              ),
                                            ),
                                          ],
                                          rows: searchResults.map((file) {
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        file.isDir
                                                            ? Icons.folder
                                                            : Icons
                                                                  .insert_drive_file,
                                                        size: 20,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          file.name,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    widget.onFileSelected(file);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                DataCell(
                                                  Text(
                                                    file.path,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(_formatListedSize(file)),
                                                ),
                                                DataCell(
                                                  Text(
                                                    _formatDate(file.modified),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: searchResults.length,
                                        itemBuilder: (context, index) {
                                          final file = searchResults[index];
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: ListTile(
                                              leading: Icon(
                                                file.isDir
                                                    ? Icons.folder
                                                    : Icons.insert_drive_file,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              title: Text(
                                                file.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    file.path,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_formatListedSize(file)} • ${_formatDate(file.modified)}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: file.isDir
                                                  ? const Icon(
                                                      Icons.chevron_right,
                                                    )
                                                  : null,
                                              onTap: () {
                                                widget.onFileSelected(file);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
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

  @override
  void dispose() {
    _searchController.dispose();
    _nameFilterController.dispose();
    _extensionFilterController.dispose();
    _sizeMinController.dispose();
    _sizeMaxController.dispose();
    super.dispose();
  }
}
