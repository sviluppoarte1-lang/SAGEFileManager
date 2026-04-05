import 'package:flutter/material.dart';
import 'package:filemanager/models/disk_info.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/utils/format_bytes.dart';
import 'package:filemanager/widgets/copy_progress.dart';

class StatusBar extends StatelessWidget {
  final int itemCount;
  final DiskInfo? diskInfo;
  final bool? isCopying;
  final String? copySourceName;
  final String? copyDestName;
  final int? copyTotalBytes;
  final int? copyCopiedBytes;
  final double? copySpeedBytesPerSecond;
  final String? copyCurrentFile;
  final VoidCallback? onCancelCopy;
  final double? copyProgressFraction;
  final int? copyDisplayTotalBytes;
  final bool? copyEstimatedTotal;
  final String? copyPanelTitle;
  final IconData? copyLeadingIcon;

  const StatusBar({
    super.key,
    required this.itemCount,
    this.diskInfo,
    this.isCopying,
    this.copySourceName,
    this.copyDestName,
    this.copyTotalBytes,
    this.copyCopiedBytes,
    this.copySpeedBytesPerSecond,
    this.copyCurrentFile,
    this.onCancelCopy,
    this.copyProgressFraction,
    this.copyDisplayTotalBytes,
    this.copyEstimatedTotal,
    this.copyPanelTitle,
    this.copyLeadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final copying = isCopying == true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.statusItems(itemCount)),
              const SizedBox(width: 16),
              if (diskInfo != null) ...[
                Text(l10n.statusFree(formatBytesBinary(diskInfo!.free))),
                const SizedBox(width: 8),
                Text(l10n.statusUsed(formatBytesBinary(diskInfo!.used))),
                const SizedBox(width: 8),
                Text(l10n.statusTotal(formatBytesBinary(diskInfo!.total))),
                const SizedBox(width: 16),
                if (!copying) ...[
                  Expanded(
                    child: LinearProgressIndicator(
                      value: diskInfo!.usedPercentage / 100,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        diskInfo!.usedPercentage > 90
                            ? Colors.red
                            : diskInfo!.usedPercentage > 70
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.statusDiskPercent(
                      diskInfo!.usedPercentage.toStringAsFixed(1),
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      l10n.statusDiskPercent(
                        diskInfo!.usedPercentage.toStringAsFixed(1),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (copying) ...[
            const SizedBox(height: 8),
            CopyProgressDetails(
              sourceName: copySourceName ?? '',
              destName: copyDestName ?? '',
              totalBytes: copyTotalBytes ?? 0,
              copiedBytes: copyCopiedBytes ?? 0,
              progressFraction: (copyProgressFraction ?? 0).clamp(0.0, 1.0),
              displayTotalBytes: copyDisplayTotalBytes ?? 0,
              estimatedTotal: copyEstimatedTotal == true,
              speedBytesPerSecond: copySpeedBytesPerSecond ?? 0,
              currentFile: copyCurrentFile,
              onCancel: onCancelCopy,
              panelTitle: copyPanelTitle,
              leadingIcon: copyLeadingIcon ?? Icons.copy,
              progressBarMinHeight: 17,
              borderRadius: 8,
              showCardChrome: true,
            ),
          ],
        ],
      ),
    );
  }
}
