import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/utils/format_bytes.dart';

/// Contenuto condiviso tra [CopyProgress] (pannello destro) e [StatusBar] durante la copia.
class CopyProgressDetails extends StatelessWidget {
  final String sourceName;
  final String destName;
  final int totalBytes;
  final int copiedBytes;
  final double progressFraction;
  final int displayTotalBytes;
  final bool estimatedTotal;
  final double speedBytesPerSecond;
  final String? currentFile;
  final VoidCallback? onCancel;
  /// Se non null sostituisce [AppLocalizations.copyProgressTitle] nella riga titolo.
  final String? panelTitle;
  final IconData leadingIcon;
  /// Altezza barra avanzamento (pannello: ~12, status: 16–18 per massima leggibilità).
  final double progressBarMinHeight;
  final double borderRadius;
  /// Se true avvolge in card come il pannello laterale; se false solo padding (status bar).
  final bool showCardChrome;

  const CopyProgressDetails({
    super.key,
    required this.sourceName,
    required this.destName,
    required this.totalBytes,
    required this.copiedBytes,
    required this.progressFraction,
    required this.displayTotalBytes,
    this.estimatedTotal = false,
    required this.speedBytesPerSecond,
    this.currentFile,
    this.onCancel,
    this.panelTitle,
    this.leadingIcon = Icons.copy,
    this.progressBarMinHeight = 12,
    this.borderRadius = 8,
    this.showCardChrome = true,
  });

  static String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond >= 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
    if (bytesPerSecond >= 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    }
    return '${bytesPerSecond.toInt()} B/s';
  }

  static String formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).ceil()}m ${seconds % 60}s';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours}h ${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = progressFraction;
    final hasKnownTotal = totalBytes > 0;
    final remainingBytes = hasKnownTotal
        ? (totalBytes - copiedBytes)
        : (displayTotalBytes > copiedBytes
            ? displayTotalBytes - copiedBytes
            : 0);
    final remainingSeconds = speedBytesPerSecond > 0
        ? (remainingBytes / speedBytesPerSecond).ceil()
        : 0;

    final track = scheme.surfaceContainerHighest;
    final fill = scheme.primary;

    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(leadingIcon, size: showCardChrome ? 20 : 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                panelTitle ?? l10n.copyProgressTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onCancel != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onCancel,
                tooltip: l10n.copyProgressCancelTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          sourceName.isEmpty ? '—' : sourceName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.copyProgressDestLine(destName.isEmpty ? '—' : destName),
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (currentFile != null && currentFile!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            currentFile!,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.58),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: showCardChrome ? 10 : 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: progressBarMinHeight,
            width: double.infinity,
            child: LinearProgressIndicator(
              value: hasKnownTotal || copiedBytes > 0 ? progress.clamp(0.0, 1.0) : null,
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation<Color>(fill),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                estimatedTotal
                    ? '${formatBytesBinary(copiedBytes)} / ~${formatBytesBinary(displayTotalBytes)}'
                    : '${formatBytesBinary(copiedBytes)} / ${formatBytesBinary(displayTotalBytes)}',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.copySpeed(formatSpeed(speedBytesPerSecond)),
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              l10n.copyRemaining(formatTime(remainingSeconds)),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );

    if (!showCardChrome) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: inner,
      );
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: inner,
      ),
    );
  }
}

class CopyProgress extends StatelessWidget {
  final String sourceName;
  final String destName;
  final int totalBytes;
  final int copiedBytes;
  final double progressFraction;
  final int displayTotalBytes;
  final bool estimatedTotal;
  final double speedBytesPerSecond;
  final String? currentFile;
  final VoidCallback? onCancel;
  final String? panelTitle;
  final IconData leadingIcon;

  const CopyProgress({
    super.key,
    required this.sourceName,
    required this.destName,
    required this.totalBytes,
    required this.copiedBytes,
    required this.progressFraction,
    required this.displayTotalBytes,
    this.estimatedTotal = false,
    required this.speedBytesPerSecond,
    this.currentFile,
    this.onCancel,
    this.panelTitle,
    this.leadingIcon = Icons.copy,
  });

  @override
  Widget build(BuildContext context) {
    return CopyProgressDetails(
      sourceName: sourceName,
      destName: destName,
      totalBytes: totalBytes,
      copiedBytes: copiedBytes,
      progressFraction: progressFraction,
      displayTotalBytes: displayTotalBytes,
      estimatedTotal: estimatedTotal,
      speedBytesPerSecond: speedBytesPerSecond,
      currentFile: currentFile,
      onCancel: onCancel,
      panelTitle: panelTitle,
      leadingIcon: leadingIcon,
      progressBarMinHeight: 12,
      showCardChrome: true,
    );
  }
}
