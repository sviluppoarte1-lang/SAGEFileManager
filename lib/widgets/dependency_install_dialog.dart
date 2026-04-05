import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/system_dependencies_service.dart';
import 'package:filemanager/widgets/dialog_enter_scope.dart';

/// Dialog mostrato all'avvio se mancano strumenti di sistema o la libreria Rust.
class DependencyInstallDialog extends StatefulWidget {
  final DependencyCheckResult initialResult;

  const DependencyInstallDialog({super.key, required this.initialResult});

  @override
  State<DependencyInstallDialog> createState() =>
      _DependencyInstallDialogState();
}

class _DependencyInstallDialogState extends State<DependencyInstallDialog> {
  late DependencyCheckResult _result;
  bool _installing = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
  }

  static String _depLabel(AppLocalizations l, SystemDependency d) {
    switch (d.id) {
      case 'xdg_open':
        return l.depLabelXdgOpen;
      case 'mount_cifs':
        return l.depLabelMountCifs;
      case 'smbclient':
        return l.depLabelSmbclient;
      case 'nmblookup':
        return l.depLabelNmblookup;
      case 'avahi_browse':
        return l.depLabelAvahiBrowse;
      case 'avahi_resolve':
        return l.depLabelAvahiResolve;
      default:
        return d.executable;
    }
  }

  String _manualCommand(AppLocalizations l) {
    if (_result.missingCommands.isEmpty) return '';
    if (_result.distroFamily == DistroFamily.unknown) {
      return SystemDependenciesService.suggestedDebianCommand(
        _result.debianPackagesHint,
      );
    }
    return SystemDependenciesService.suggestedCommand(
      _result.distroFamily,
      _result.packagesToInstall(_result.distroFamily),
    );
  }

  Future<void> _onInstall() async {
    final l10n = AppLocalizations.of(context);
    final pkgs = _result.packagesToInstall(_result.distroFamily);
    final cmdHint =
        SystemDependenciesService.suggestedCommand(_result.distroFamily, pkgs);

    setState(() {
      _installing = true;
      _feedback = null;
    });

    final installResult =
        await SystemDependenciesService.installWithPkexec(_result);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    final fresh = await SystemDependenciesService.checkAll();
    if (!mounted) return;

    setState(() {
      _installing = false;
      _result = fresh;
      if (installResult.pkexecMissing) {
        _feedback = '${l10n.depsPkexecNotFound}\n$cmdHint';
      } else if (installResult.exitCode != 0) {
        _feedback = _formatInstallFailure(
          l10n,
          installResult,
        );
      } else if (fresh.missingCommands.isNotEmpty) {
        final detail =
            SystemDependenciesService.truncateForUi(installResult.combinedOutput);
        if (detail.isNotEmpty) {
          _feedback =
              '${l10n.depsSomeStillMissing}\n\n${l10n.depsInstallOutputIntro}\n$detail';
        } else {
          _feedback = l10n.depsSomeStillMissing;
        }
      } else if (!fresh.rustAvailable) {
        _feedback =
            '${l10n.depsInstallSuccess}\n\n${l10n.depsRustUnavailable}';
      } else {
        final detail =
            SystemDependenciesService.truncateForUi(installResult.combinedOutput);
        if (detail.isNotEmpty) {
          _feedback =
              '${l10n.depsInstallSuccess}\n\n${l10n.depsInstallOutputIntro}\n$detail';
        } else {
          _feedback = l10n.depsInstallSuccess;
        }
      }
    });
  }

  String _formatInstallFailure(
    AppLocalizations l10n,
    PkexecInstallResult r,
  ) {
    final codeLabel =
        r.exitCode == -1 ? l10n.depsInstallUnexpected : '${r.exitCode}';
    final buf = StringBuffer()..writeln(l10n.depsInstallFailed(codeLabel));
    if (r.exitCode == 126 || r.exitCode == 127) {
      buf.writeln(l10n.depsPolkitAuthFailed);
    }
    final detail = SystemDependenciesService.truncateForUi(r.combinedOutput);
    if (detail.isNotEmpty) {
      buf.writeln();
      buf.writeln(l10n.depsInstallOutputIntro);
      buf.writeln(detail);
    }
    return buf.toString().trim();
  }

  String _introText(AppLocalizations l) {
    if (_result.missingCommands.isNotEmpty) {
      return l.depsDialogIntro;
    }
    if (!_result.rustAvailable) {
      return l.depsDialogIntroRustOnly;
    }
    return l.depsDialogIntroToolsOk;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final manual = _manualCommand(l10n);
    final showAutoInstall = _result.canAutoInstall && !_installing;

    return DialogEnterScope(
      onEnterPressed: () => Navigator.of(context).pop(),
      child: AlertDialog(
        title: Text(l10n.depsDialogTitle),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(_introText(l10n)),
              if (_result.missingCommands.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._result.missingCommands.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 20, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_depLabel(l10n, d))),
                      ],
                    ),
                  ),
                ),
              ],
              if (!_result.rustAvailable) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.depsRustUnavailable)),
                  ],
                ),
              ],
              if (_result.distroFamily == DistroFamily.unknown &&
                  _result.missingCommands.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.depsUnknownDistro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (manual.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.depsManualCommandLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  manual,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              if (_installing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.depsInstalling)),
                  ],
                ),
              ],
              if (_feedback != null) ...[
                const SizedBox(height: 12),
                SelectableText(
                  _feedback!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _result.needsAttention
                  ? l10n.depsContinueButton
                  : l10n.depsCloseButton,
            ),
          ),
          if (showAutoInstall)
            FilledButton(
              onPressed: _onInstall,
              child: Text(l10n.depsInstallButton),
            ),
        ],
      ),
    );
  }
}

/// Controlla se `mount.cifs` (pacchetto cifs-utils) è disponibile; se manca, chiede e apre
/// [DependencyInstallDialog] per installarlo con pkexec.
Future<bool> ensureMountCifsForNetwork(BuildContext context) async {
  if (!Platform.isLinux) return true;
  final initial = await SystemDependenciesService.checkDependenciesByIds(
    SystemDependenciesService.cifsMountOnlyDependencyIds,
  );
  if (initial.missingCommands.isEmpty) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context);
  final want = await showDialog<bool>(
    context: context,
    builder: (ctx) => DialogEnterScope(
      onEnterPressed: () => Navigator.pop(ctx, true),
      child: AlertDialog(
        title: Text(l10n.depsCifsInstallTitle),
        content: Text(l10n.depsCifsInstallBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.depsInstallButton),
          ),
        ],
      ),
    ),
  );
  if (want != true) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.computerMountMissingGio)),
      );
    }
    return false;
  }

  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (ctx) => DependencyInstallDialog(initialResult: initial),
  );
  if (!context.mounted) return false;

  final after = await SystemDependenciesService.checkDependenciesByIds(
    SystemDependenciesService.cifsMountOnlyDependencyIds,
  );
  if (after.missingCommands.isNotEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.computerMountMissingGio)),
      );
    }
    return false;
  }
  return true;
}
