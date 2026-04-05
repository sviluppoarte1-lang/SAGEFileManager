import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/system_dependencies_service.dart';
import 'package:filemanager/widgets/dependency_install_dialog.dart';

/// Offre installazione pkexec dei tool di rete (nmblookup, avahi, smbclient, mount.cifs) quando mancano.
class NetworkDependenciesBanner extends StatelessWidget {
  final DependencyCheckResult result;
  final VoidCallback onDismiss;
  final Future<void> Function() onAfterInstallAttempt;

  const NetworkDependenciesBanner({
    super.key,
    required this.result,
    required this.onDismiss,
    required this.onAfterInstallAttempt,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.download_outlined, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.depsNetworkBannerHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          await showDialog<void>(
                            context: context,
                            builder: (ctx) => DependencyInstallDialog(
                              initialResult: result,
                            ),
                          );
                          if (context.mounted) {
                            await onAfterInstallAttempt();
                          }
                        },
                        child: Text(l10n.depsInstallButton),
                      ),
                      TextButton(
                        onPressed: onDismiss,
                        child: Text(l10n.depsNetworkBannerLater),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
