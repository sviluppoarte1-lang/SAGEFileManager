import 'package:flutter/material.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/l10n/app_localizations.dart';

class ContextMenu extends StatelessWidget {
  final FileInfo? file;
  final Offset position;
  final Function(String action)? onAction;

  const ContextMenu({
    super.key,
    this.file,
    required this.position,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      offset: position,
      itemBuilder: (context) => [
        if (file != null) ...[
          PopupMenuItem(
            value: 'copy_to',
            child: Row(
              children: [
                const Icon(Icons.copy, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxCopyTo),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'move_to',
            child: Row(
              children: [
                const Icon(Icons.drive_file_move, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxMoveTo),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                const Icon(Icons.copy, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxCopy),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'paste',
            child: Row(
              children: [
                const Icon(Icons.paste, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxPaste),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'extract',
            child: Row(
              children: [
                const Icon(Icons.unarchive, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxExtract),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'extract_to',
            child: Row(
              children: [
                const Icon(Icons.folder_open, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxExtractTo),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'trash',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, size: 20),
                const SizedBox(width: 8),
                Text(l10n.ctxMoveToTrash),
              ],
            ),
          ),
        ],
      ],
      onSelected: (value) {
        onAction?.call(value);
      },
      child: Container(),
    );
  }
}
