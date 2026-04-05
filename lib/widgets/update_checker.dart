import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/package_service.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  List<Map<String, String>> updates = [];
  bool isLoading = false;
  bool isInstalling = false;
  Set<int> installingIndices = {};

  Future<void> _checkUpdates() async {
    setState(() => isLoading = true);
    final found = await PackageService.checkUpdates();
    setState(() {
      updates = found;
      isLoading = false;
    });
  }

  Future<void> _installUpdate(int index) async {
    if (isInstalling || installingIndices.contains(index)) return;

    setState(() {
      installingIndices.add(index);
      isInstalling = true;
    });

    try {
      final success = await PackageService.installUpdate(updates[index]);
      if (!mounted) return;

      if (success) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateUpdatedSuccess(updates[index]['name'] ?? '')),
            backgroundColor: Colors.green,
          ),
        );
        // Remove from list
        setState(() {
          updates.removeAt(index);
        });
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateOneFailed(updates[index]['name'] ?? '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          installingIndices.remove(index);
          isInstalling = installingIndices.isNotEmpty;
        });
      }
    }
  }

  Future<void> _installAllUpdates() async {
    if (isInstalling || updates.isEmpty) return;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateInstallAllTitle),
        content: Text(l10n.updateInstallAllBody(updates.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pkgInstallButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isInstalling = true);

    try {
      final success = await PackageService.installAllUpdates(updates);
      if (!mounted) return;

      if (success) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.updateAllSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _checkUpdates();
      } else {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.updateAllFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.commonError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isInstalling = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUpdates();
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
                      updates.isNotEmpty
                          ? l10n.updateTitleWithCount(updates.length)
                          : l10n.updateTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (updates.isNotEmpty && !isInstalling)
                    TextButton.icon(
                      icon: const Icon(Icons.download),
                      label: Text(l10n.updateInstallAll),
                      onPressed: _installAllUpdates,
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: isLoading ? null : _checkUpdates,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : updates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.updateNoneAvailable,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            if (isInstalling)
                              const LinearProgressIndicator(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: updates.length,
                                itemBuilder: (context, index) {
                                  final update = updates[index];
                                  final isInstallingThis = installingIndices.contains(index);
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: ListTile(
                                      leading: Icon(
                                        _getTypeIcon(update['type'] ?? ''),
                                      ),
                                      title: Text(
                                        update['name'] ?? '',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.updateTypeLine(update['type']?.toUpperCase() ?? ''),
                                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                          if (update['current']?.isNotEmpty == true)
                                            Text(
                                              l10n.updateCurrentVersionLine(update['current']!),
                                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                          if (update['available']?.isNotEmpty == true)
                                            Text(
                                              l10n.updateAvailableVersionLine(update['available']!),
                                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                      trailing: isInstallingThis
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.download),
                                              onPressed: () => _installUpdate(index),
                                              tooltip: l10n.updateInstallTooltip,
                                            ),
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
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'apt':
        return Icons.inventory;
      case 'snap':
        return Icons.apps;
      case 'flatpak':
        return Icons.app_blocking;
      default:
        return Icons.update;
    }
  }
}
