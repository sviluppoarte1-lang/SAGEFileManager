import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/services/file_service.dart';
import 'package:filemanager/widgets/file_properties.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

/// Dialog “Proprietà volume” (stile Dischi / file manager desktop).
Future<void> showDiskPropertiesDialog(
  BuildContext context,
  Map<String, dynamic> disk,
) async {
  final mount =
      disk['mount_point'] as String? ?? disk['path'] as String? ?? '/';
  final displayName =
      disk['display_name'] as String? ??
      disk['name'] as String? ??
      path.basename(mount);
  final total = disk['total'] as int? ?? 0;
  final used = disk['used'] as int? ?? 0;
  final free = disk['free'] as int? ?? 0;
  final block = disk['block_device'] as String?;

  final fstype = await FileService.getFilesystemType(mount);
  DateTime? modified;
  DateTime? created;
  try {
    final st = await FileStat.stat(mount);
    modified = st.modified;
    created = st.changed;
  } catch (_) {}

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      final theme = Theme.of(ctx);
      final locale = Localizations.localeOf(ctx).toString();
      final dateFmt = DateFormat.yMMMd(locale).add_Hms();

      String fmtBytes(int b) {
        if (b < 1024) return '$b B';
        if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
        if (b < 1024 * 1024 * 1024) {
          return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      }

      final frac = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

      Future<void> openGnomeDisks() async {
        try {
          if (block != null && block.startsWith('/dev/')) {
            await Process.start('gnome-disks', [
              '--block-device',
              block,
            ], mode: ProcessStartMode.detached);
            return;
          }
        } catch (_) {}
        try {
          await Process.start(
            'gnome-disks',
            [],
            mode: ProcessStartMode.detached,
          );
        } catch (_) {}
      }

      Future<void> openFileAccess() async {
        Navigator.pop(ctx);
        if (!context.mounted) return;
        try {
          final st = await FileStat.stat(mount);
          if (!context.mounted) return;
          final fi = FileInfo(
            path: mount,
            name: displayName,
            size: 0,
            isDir: true,
            modified: st.modified.millisecondsSinceEpoch ~/ 1000,
            created: st.changed.millisecondsSinceEpoch ~/ 1000,
          );
          await showDialog<void>(
            context: context,
            builder: (c2) => FileProperties(file: fi),
          );
        } catch (_) {}
      }

      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.storage,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fstype.isEmpty
                                ? l10n.diskPropsFsUnknown
                                : l10n.diskPropsFsLine(fstype),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (total > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: frac,
                          minHeight: 10,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.diskPropsTotalLine(fmtBytes(total)),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.diskPropsUsedLine(fmtBytes(used)),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        l10n.diskPropsFreeLine(fmtBytes(free)),
                        style: theme.textTheme.bodySmall,
                      ),
                    ] else
                      Text(
                        mount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: openGnomeDisks,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(l10n.diskPropsOpenInDisks),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (modified != null || created != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      if (modified != null)
                        ListTile(
                          title: Text(l10n.propsFieldModified),
                          subtitle: Text(dateFmt.format(modified)),
                          dense: true,
                        ),
                      if (created != null)
                        ListTile(
                          title: Text(l10n.propsFieldCreated),
                          subtitle: Text(dateFmt.format(created)),
                          dense: true,
                        ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              ListTile(
                title: Text(l10n.propsFieldPermissions),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.diskPropsFileAccessRow,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                  ],
                ),
                onTap: openFileAccess,
              ),
            ],
          ),
        ),
      );
    },
  );
}
