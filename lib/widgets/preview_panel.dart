import 'package:flutter/material.dart';
import 'package:filemanager/utils/format_bytes.dart';
import 'package:flutter/foundation.dart';
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/services/preview_service.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'dart:async';

class PreviewPanel extends StatefulWidget {
  final FileInfo? selectedFile;
  final VoidCallback? onClose;
  final bool fastMode;

  const PreviewPanel({
    super.key,
    this.selectedFile,
    this.onClose,
    this.fastMode = false,
  });

  @override
  State<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<PreviewPanel> {
  String? _lastFilePath;
  bool? _isPreviewable;
  int _requestId = 0;
  Timer? _debounce;

  @override
  void didUpdateWidget(PreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Notify about file change
    if (oldWidget.selectedFile?.path != widget.selectedFile?.path) {
      if (oldWidget.selectedFile != null) {
        // Previous file is being closed
        if (kDebugMode) {
          print('Preview: Closing file ${oldWidget.selectedFile!.path}');
        }
      }
      if (widget.selectedFile != null) {
        // New file is being opened
        if (kDebugMode) {
          print('Preview: Opening file ${widget.selectedFile!.path}');
        }
      }

      _schedulePreviewableCheck(widget.selectedFile?.path);
    }
  }

  @override
  void initState() {
    super.initState();
    _schedulePreviewableCheck(widget.selectedFile?.path);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _schedulePreviewableCheck(String? path) {
    _debounce?.cancel();
    _isPreviewable = null;
    if (widget.fastMode) {
      return;
    }
    if (path == null || path.isEmpty) {
      return;
    }

    // Debounce rapid selection changes (arrow keys / marquee).
    final id = ++_requestId;
    _debounce = Timer(const Duration(milliseconds: 120), () async {
      final ok = await PreviewService.isPreviewable(path);
      if (!mounted || id != _requestId) return;
      setState(() {
        _isPreviewable = ok;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.selectedFile == null) {
      _lastFilePath = null;
      _isPreviewable = null;
      return Container(
        width: 300,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.previewSelectFile),
          ),
        ),
      );
    }

    final file = widget.selectedFile!;
    
    // Force rebuild if file path changed
    if (_lastFilePath != file.path) {
      if (_lastFilePath != null) {
        // Notify about file closure
        if (kDebugMode) {
          print('Preview: File changed from $_lastFilePath to ${file.path}');
        }
      }
      _lastFilePath = file.path;
    }

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 400),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Text(
                  l10n.previewPanelTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // File info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.previewPanelSizeLine(
                    file.isDir ? '\u2014' : _formatSize(file.size),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  l10n.previewPanelModifiedLine(_formatDate(file.modified)),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Preview content
          Expanded(
            child: Builder(
              builder: (context) {
                if (widget.fastMode) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          file.isDir ? Icons.folder : Icons.insert_drive_file,
                          size: 72,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Anteprima veloce attiva',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final ok = _isPreviewable;
                if (ok == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ok) {
                  return PreviewService.getPreview(context, file.path);
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        file.isDir ? Icons.folder : Icons.insert_drive_file,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        file.isDir
                            ? l10n.fileListTypeFolder
                            : l10n.previewNotAvailable,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) => formatBytesBinary(bytes);

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
