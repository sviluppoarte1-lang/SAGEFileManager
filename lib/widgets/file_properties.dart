import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/utils/format_bytes.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

int? _parseDuFirstColumnBytes(String stdoutText) {
  final out = stdoutText.trim();
  if (out.isEmpty) return null;
  final line = out.split('\n').first.trim();
  // GNU: "12345\t/path"; altri: "12345 /path"
  final tab = line.split('\t');
  if (tab.isNotEmpty) {
    final n = int.tryParse(tab.first.trim());
    if (n != null) return n;
  }
  final sp = line.split(RegExp(r'\s+'));
  if (sp.isNotEmpty) return int.tryParse(sp.first);
  return null;
}

/// Best effort: `du` in byte (GNU `-sb` / `--bytes`) poi `-sk`×1024, infine [FileStat].
Future<int?> _diskUsageBytesOne(String path) async {
  Future<int?> tryDu(String executable, List<String> args) async {
    try {
      final r = await Process.run(executable, args).timeout(
        const Duration(seconds: 120),
        onTimeout: () => ProcessResult(-1, 0, '', ''),
      );
      // GNU `du` può restituire exit 1 se alcune sottodirectory non sono leggibili,
      // ma la prima riga di stdout contiene comunque il totale aggregato.
      final n = _parseDuFirstColumnBytes(r.stdout.toString());
      if (n == null) return null;
      if (args.contains('-sk')) return n * 1024;
      return n;
    } catch (_) {
      return null;
    }
  }

  // Ordine: byte espliciti, poi blocchi 1K (portabile dove manca -sb).
  for (final duExe in <String>['du', '/usr/bin/du']) {
    for (final args in <List<String>>[
      ['-sb', path],
      ['--bytes', '-s', path],
      ['-sk', path],
    ]) {
      final v = await tryDu(duExe, args);
      if (v != null) return v;
    }
  }
  try {
    return (await FileStat.stat(path)).size;
  } catch (_) {
    return null;
  }
}

Future<({int files, int dirs})?> _countFilesAndSubdirs(String dirPath) async {
  try {
    final filesF = Process.run('find', [dirPath, '-type', 'f']).timeout(
      const Duration(seconds: 120),
      onTimeout: () => ProcessResult(-1, 0, '', ''),
    );
    final dirsF = Process.run('find', [dirPath, '-type', 'd']).timeout(
      const Duration(seconds: 120),
      onTimeout: () => ProcessResult(-1, 0, '', ''),
    );
    final results = await Future.wait([filesF, dirsF]);
    final fr = results[0];
    final dr = results[1];
    var files = 0;
    var dirs = 0;
    if (fr.exitCode == 0) {
      files = fr.stdout
          .toString()
          .split('\n')
          .where((l) => l.isNotEmpty)
          .length;
    }
    if (dr.exitCode == 0) {
      final n = dr.stdout
          .toString()
          .split('\n')
          .where((l) => l.isNotEmpty)
          .length;
      dirs = n > 0 ? n - 1 : 0;
    }
    if (fr.exitCode != 0 && dr.exitCode != 0) return null;
    return (files: files, dirs: dirs);
  } catch (_) {
    return null;
  }
}

class FileProperties extends StatelessWidget {
  final FileInfo file;
  /// Se non null e con più elementi, mostra riepilogo (es. dimensione combinata).
  final List<FileInfo>? aggregateSelection;

  const FileProperties({
    super.key,
    required this.file,
    this.aggregateSelection,
  });

  @override
  Widget build(BuildContext context) {
    final aggregate = aggregateSelection;
    if (aggregate != null && aggregate.length >= 2) {
      return _MultiSelectionPropertiesBody(items: aggregate);
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _getFileProperties().timeout(
        // Home / cartelle grandi: du+find possono richiedere più di 30s.
        const Duration(seconds: 150),
        onTimeout: () {
          return <String, dynamic>{
            'error': '__props_timeout__',
          };
        },
      ),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Dialog(
            child: SizedBox(
              width: 500,
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || (snapshot.hasData && snapshot.data!.containsKey('error'))) {
          final errVal = snapshot.hasData ? snapshot.data!['error'] as String? : null;
          return AlertDialog(
            title: Text(l10n.dialogErrorTitle),
            content: Text(
              snapshot.hasError
                  ? l10n.propsLoadErrorDetail(snapshot.error.toString())
                  : (errVal == '__props_timeout__'
                      ? l10n.propsTimeoutLoading
                      : (errVal ?? '')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonClose),
              ),
            ],
          );
        }

        final properties = snapshot.data ?? {};
        
        // If properties is empty, show error
        if (properties.isEmpty) {
          return AlertDialog(
            title: Text(l10n.dialogErrorTitle),
            content: Text(l10n.propsLoadError),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonClose),
              ),
            ],
          );
        }

        return Dialog(
          child: SizedBox(
            width: 500,
            height: 600,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        file.isDir ? Icons.folder : Icons.insert_drive_file,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.propsTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              file.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPropertyRow(l10n.propsFieldName, file.name),
                        _buildPropertyRow(l10n.propsFieldPath, file.path),
                        _buildPropertyRow(l10n.propsFieldType, file.isDir ? l10n.propsTypeFolder : l10n.propsTypeFile),
                        if (!file.isDir) _buildPropertyRow(l10n.propsFieldSize, _formatSize(file.size)),
                        if (properties['size_on_disk'] != null)
                          _buildPropertyRow(l10n.propsFieldSizeOnDisk, _formatSize(properties['size_on_disk'] as int)),
                        _buildPropertyRow(l10n.propsFieldModified, _formatDate(file.modified)),
                        if (properties['accessed'] != null)
                          _buildPropertyRow(l10n.propsFieldAccessed, _formatDate(properties['accessed'] as int)),
                        if (properties['created'] != null)
                          _buildPropertyRow(l10n.propsFieldCreated, _formatDate(properties['created'] as int)),
                        if (properties['owner'] != null)
                          _buildEditablePropertyRow(
                            context,
                            l10n,
                            'owner',
                            l10n.propsFieldOwner,
                            properties['owner'] as String,
                            null,
                            (newOwner) => _changeOwner(newOwner),
                          ),
                        if (properties['group'] != null)
                          _buildEditablePropertyRow(
                            context,
                            l10n,
                            'group',
                            l10n.propsFieldGroup,
                            properties['group'] as String,
                            null,
                            (newGroup) => _changeGroup(newGroup),
                          ),
                        if (properties['permissions'] != null)
                          _buildEditablePropertyRow(
                            context,
                            l10n,
                            'permissions',
                            l10n.propsFieldPermissions,
                            properties['permissions'] as String,
                            properties['permissions_numeric'] as String?,
                            (newPerm) => _changePermissions(l10n, newPerm),
                          ),
                        if (properties['inode'] != null)
                          _buildPropertyRow(l10n.propsFieldInode, properties['inode'].toString()),
                        if (properties['links'] != null)
                          _buildPropertyRow(l10n.propsFieldLinks, properties['links'].toString()),
                        if (file.isDir && properties['files_count'] != null)
                          _buildPropertyRow(l10n.propsFieldFilesInside, properties['files_count'].toString()),
                        if (file.isDir && properties['dirs_count'] != null)
                          _buildPropertyRow(l10n.propsFieldDirsInside, properties['dirs_count'].toString()),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.commonClose),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePropertyRow(
    BuildContext context,
    AppLocalizations l10n,
    String fieldKey,
    String label,
    String value,
    String? numericValue,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditDialog(context, l10n, fieldKey, label, numericValue ?? value, onChanged),
                  tooltip: l10n.propsEditTooltip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    AppLocalizations l10n,
    String fieldKey,
    String label,
    String currentValue,
    Function(String) onChanged,
  ) async {
    if (fieldKey == 'permissions') {
      final result = await _showPermissionsDialog(context, l10n, currentValue);
      if (result != null) {
        await onChanged(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackFieldUpdated(label))),
          );
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => FileProperties(file: file),
          );
        }
      }
      return;
    }

    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogEditFieldTitle(label)),
        content: TextField(
          controller: controller,
          enableInteractiveSelection: true,
          keyboardType: TextInputType.text,
          autofocus: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: l10n.propsHintNewValue,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await onChanged(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackFieldUpdated(label))),
          );
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => FileProperties(file: file),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.commonError(e.toString()))),
          );
        }
      }
    }
  }

  Future<String?> _showPermissionsDialog(BuildContext context, AppLocalizations l10n, String currentPerm) async {
    // Parse current permissions
    final currentPermNumeric = currentPerm.split(' ').last.replaceAll('(', '').replaceAll(')', '');
    int ownerPerm = 0, groupPerm = 0, otherPerm = 0;
    if (currentPermNumeric.length == 3) {
      ownerPerm = int.tryParse(currentPermNumeric[0]) ?? 0;
      groupPerm = int.tryParse(currentPermNumeric[1]) ?? 0;
      otherPerm = int.tryParse(currentPermNumeric[2]) ?? 0;
    }

    bool ownerRead = (ownerPerm & 4) != 0;
    bool ownerWrite = (ownerPerm & 2) != 0;
    bool ownerExecute = (ownerPerm & 1) != 0;
    bool groupRead = (groupPerm & 4) != 0;
    bool groupWrite = (groupPerm & 2) != 0;
    bool groupExecute = (groupPerm & 1) != 0;
    bool otherRead = (otherPerm & 4) != 0;
    bool otherWrite = (otherPerm & 2) != 0;
    bool otherExecute = (otherPerm & 1) != 0;

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(l10n.propsPermissionsDialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.propsPermOwnerSection, style: const TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: Text(l10n.permRead),
                      value: ownerRead,
                      onChanged: (v) => setState(() => ownerRead = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permWrite),
                      value: ownerWrite,
                      onChanged: (v) => setState(() => ownerWrite = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permExecute),
                      value: ownerExecute,
                      onChanged: (v) => setState(() => ownerExecute = v ?? false),
                      dense: true,
                    ),
                    const Divider(),
                    Text(l10n.propsPermGroupSection, style: const TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: Text(l10n.permRead),
                      value: groupRead,
                      onChanged: (v) => setState(() => groupRead = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permWrite),
                      value: groupWrite,
                      onChanged: (v) => setState(() => groupWrite = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permExecute),
                      value: groupExecute,
                      onChanged: (v) => setState(() => groupExecute = v ?? false),
                      dense: true,
                    ),
                    const Divider(),
                    Text(l10n.propsPermOtherSection, style: const TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: Text(l10n.permRead),
                      value: otherRead,
                      onChanged: (v) => setState(() => otherRead = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permWrite),
                      value: otherWrite,
                      onChanged: (v) => setState(() => otherWrite = v ?? false),
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(l10n.permExecute),
                      value: otherExecute,
                      onChanged: (v) => setState(() => otherExecute = v ?? false),
                      dense: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.dialogCancel),
                ),
                TextButton(
                  onPressed: () {
                    final newOwnerPerm = (ownerRead ? 4 : 0) + (ownerWrite ? 2 : 0) + (ownerExecute ? 1 : 0);
                    final newGroupPerm = (groupRead ? 4 : 0) + (groupWrite ? 2 : 0) + (groupExecute ? 1 : 0);
                    final newOtherPerm = (otherRead ? 4 : 0) + (otherWrite ? 2 : 0) + (otherExecute ? 1 : 0);
                    Navigator.pop(ctx, '$newOwnerPerm$newGroupPerm$newOtherPerm');
                  },
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changePermissions(AppLocalizations l10n, String newPerm) async {
    if (!RegExp(r'^[0-7]{3}$').hasMatch(newPerm)) {
      throw Exception(l10n.propsInvalidPermissionsFormat);
    }
    
    final result = await Process.run('chmod', [newPerm, file.path]);
    if (result.exitCode != 0) {
      throw Exception(l10n.propsChmodFailed(result.stderr.toString().trim()));
    }
  }

  Future<void> _changeOwner(String newOwner) async {
    final result = await Process.run('chown', [newOwner, file.path]);
    if (result.exitCode != 0) {
      // Try with sudo
      final sudoResult = await Process.run('sudo', ['chown', newOwner, file.path]);
      if (sudoResult.exitCode != 0) {
        throw Exception('Impossibile modificare il proprietario: ${sudoResult.stderr}');
      }
    }
  }

  Future<void> _changeGroup(String newGroup) async {
    final result = await Process.run('chgrp', [newGroup, file.path]);
    if (result.exitCode != 0) {
      // Try with sudo
      final sudoResult = await Process.run('sudo', ['chgrp', newGroup, file.path]);
      if (sudoResult.exitCode != 0) {
        throw Exception('Impossibile modificare il gruppo: ${sudoResult.stderr}');
      }
    }
  }

  Future<Map<String, dynamic>> _getFileProperties() async {
    final Map<String, dynamic> properties = {};

    try {
      final entity = file.isDir ? Directory(file.path) : File(file.path);
      final stat = await entity.stat();

      properties['size_on_disk'] = stat.size;
      properties['accessed'] = stat.accessed.millisecondsSinceEpoch ~/ 1000;
      properties['created'] = stat.changed.millisecondsSinceEpoch ~/ 1000;
      
      // Get Unix-specific properties using stat command
      try {
        final inodeResult = await Process.run('stat', ['-c', '%i', file.path]);
        if (inodeResult.exitCode == 0) {
          properties['inode'] = inodeResult.stdout.toString().trim();
        }

        final linksResult = await Process.run('stat', ['-c', '%h', file.path]);
        if (linksResult.exitCode == 0) {
          properties['links'] = linksResult.stdout.toString().trim();
        }
      } catch (e) {
        // stat command might not be available
      }

      // Get owner and group (Unix only)
      try {
        final ownerResult = await Process.run('stat', ['-c', '%U', file.path]);
        if (ownerResult.exitCode == 0) {
          properties['owner'] = ownerResult.stdout.toString().trim();
        }

        final groupResult = await Process.run('stat', ['-c', '%G', file.path]);
        if (groupResult.exitCode == 0) {
          properties['group'] = groupResult.stdout.toString().trim();
        }

        final permResult = await Process.run('stat', ['-c', '%a', file.path]);
        if (permResult.exitCode == 0) {
          final perm = permResult.stdout.toString().trim();
          properties['permissions'] = _formatPermissions(perm);
          properties['permissions_numeric'] = perm;
        }
      } catch (e) {
        // stat command might not be available or fail
      }

      if (file.isDir) {
        final parallel = await Future.wait<Object?>([
          _diskUsageBytesOne(file.path),
          _countFilesAndSubdirs(file.path),
        ]);
        final usage = parallel[0] as int?;
        final counts = parallel[1] as ({int files, int dirs})?;
        if (usage != null) {
          properties['size_on_disk'] = usage;
        } else {
          properties['size_on_disk'] = stat.size;
        }
        if (counts != null) {
          properties['files_count'] = counts.files;
          properties['dirs_count'] = counts.dirs;
        } else {
          properties['files_count'] = 0;
          properties['dirs_count'] = 0;
        }
      } else {
        // For files, use stat.size but also get block size
        try {
          final blockSizeResult = await Process.run('stat', ['-c', '%B', file.path]);
          if (blockSizeResult.exitCode == 0) {
            final blockSize = int.tryParse(blockSizeResult.stdout.toString().trim()) ?? 4096;
            final blocksResult = await Process.run('stat', ['-c', '%b', file.path]);
            if (blocksResult.exitCode == 0) {
              final blocks = int.tryParse(blocksResult.stdout.toString().trim()) ?? 0;
              properties['size_on_disk'] = blocks * blockSize;
            } else {
              properties['size_on_disk'] = stat.size;
            }
          } else {
            properties['size_on_disk'] = stat.size;
          }
        } catch (e) {
          properties['size_on_disk'] = stat.size;
        }
      }
    } catch (e) {
      // Error getting properties
    }

    return properties;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String _formatPermissions(String perm) {
    // Convert numeric permissions to rwx format
    if (perm.length == 3) {
      final owner = _numToPerm(int.parse(perm[0]));
      final group = _numToPerm(int.parse(perm[1]));
      final other = _numToPerm(int.parse(perm[2]));
      return '$owner$group$other ($perm)';
    }
    return perm;
  }

  String _numToPerm(int num) {
    switch (num) {
      case 0:
        return '---';
      case 1:
        return '--x';
      case 2:
        return '-w-';
      case 3:
        return '-wx';
      case 4:
        return 'r--';
      case 5:
        return 'r-x';
      case 6:
        return 'rw-';
      case 7:
        return 'rwx';
      default:
        return '---';
    }
  }

  // _calculateDirectorySize removed (unused).
}

class _MultiSelectionPropertiesBody extends StatelessWidget {
  const _MultiSelectionPropertiesBody({required this.items});

  final List<FileInfo> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nDir = items.where((f) => f.isDir).length;
    final nFile = items.length - nDir;

    return FutureBuilder<List<int?>>(
      future: Future.wait(items.map((f) => _diskUsageBytesOne(f.path))),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 240),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.layers),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.propsTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      l10n.propsMultiLoadingSizes,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: Text(l10n.dialogErrorTitle),
            content: Text('${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonClose),
              ),
            ],
          );
        }

        final sizes = snapshot.data ?? List<int?>.filled(items.length, null);
        var total = 0;
        var any = false;
        for (final s in sizes) {
          if (s != null) {
            total += s;
            any = true;
          }
        }

        return Dialog(
          child: SizedBox(
            width: 520,
            height: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.layers, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.propsTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.propsMultiSelectionTitle(items.length),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.propsMultiCountSummary(nDir, nFile),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _propRow(
                          context,
                          l10n.propsFieldType,
                          l10n.propsMultiTypeMixed,
                        ),
                        _propRow(
                          context,
                          l10n.propsMultiCombinedSize,
                          any ? formatBytesBinary(total) : '—',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.propsMultiPerItemTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0; i < items.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  items[i].isDir
                                      ? Icons.folder
                                      : Icons.insert_drive_file,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    items[i].name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SelectableText(
                                  i < sizes.length && sizes[i] != null
                                      ? formatBytesBinary(sizes[i]!)
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.commonClose),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _propRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
