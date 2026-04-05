import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/computer_disk_service.dart';
import 'package:filemanager/services/file_service.dart';
import 'package:filemanager/services/network_browser_service.dart';
import 'package:filemanager/services/network_credentials_store.dart';
import 'package:filemanager/services/system_dependencies_service.dart';
import 'package:filemanager/widgets/dependency_install_dialog.dart';
import 'package:filemanager/widgets/network_dependencies_banner.dart';
import 'package:filemanager/widgets/disk_properties_dialog.dart';
import 'package:filemanager/widgets/fluid_context_menu.dart';

/// Vista tipo “Altre posizioni”: volumi locali e server di rete.
class ComputerLocationsPage extends StatefulWidget {
  final void Function(String path) onOpenPath;
  final VoidCallback onFindFilesAndFolders;
  final VoidCallback onOpenPackageManager;
  final VoidCallback onOpenSystemUpdates;

  const ComputerLocationsPage({
    super.key,
    required this.onOpenPath,
    required this.onFindFilesAndFolders,
    required this.onOpenPackageManager,
    required this.onOpenSystemUpdates,
  });

  @override
  State<ComputerLocationsPage> createState() => _ComputerLocationsPageState();
}

class _ComputerLocationsPageState extends State<ComputerLocationsPage> {
  List<Map<String, dynamic>> _disks = [];
  List<Map<String, String>> _servers = [];
  bool _loadingDisks = true;
  bool _scanningNetwork = false;
  String? _error;
  DependencyCheckResult? _networkDepsBanner;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _loadingDisks = true;
      _scanningNetwork = true;
    });

    try {
      final disks = await FileService.getMountedDisks();
      if (!mounted) return;
      setState(() {
        _disks = disks;
        _loadingDisks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingDisks = false;
        _scanningNetwork = false;
      });
      return;
    }

    try {
      final servers =
          await NetworkBrowserService.discoverNetworkServers(
            onPartial: (partial) {
              if (mounted) setState(() => _servers = partial);
            },
          ).timeout(
            const Duration(seconds: 28),
            onTimeout: () => <Map<String, String>>[],
          );
      if (mounted) {
        setState(() {
          _servers = servers;
          _scanningNetwork = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _servers = [];
          _scanningNetwork = false;
        });
      }
    }

    await _refreshNetworkDepsBanner();
  }

  Future<void> _refreshNetworkDepsBanner() async {
    if (!Platform.isLinux) {
      if (mounted) setState(() => _networkDepsBanner = null);
      return;
    }
    final r = await SystemDependenciesService.checkDependenciesByIds(
      SystemDependenciesService.networkDiscoveryDependencyIds,
    );
    if (!mounted) return;
    setState(() {
      _networkDepsBanner = r.missingCommands.isNotEmpty ? r : null;
    });
  }

  Future<void> _afterNetworkDepsInstall() async {
    await _refreshNetworkDepsBanner();
    if (!mounted) return;
    if (_networkDepsBanner == null) {
      await _load();
    }
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _openNetworkServer(Map<String, String> server) async {
    final l10n = AppLocalizations.of(context);
    final address = (server['address'] ?? '').trim();
    if (address.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.computerMounting)),
            ],
          ),
        ),
      ),
    );

    List<Map<String, String>> shares = [];
    String? credUser;
    String? credPass;

    try {
      final saved = await NetworkCredentialsStore.load(address);
      if (saved != null) {
        shares = await NetworkBrowserService.listShares(
          address,
          username: saved.$1,
          password: saved.$2,
        );
        credUser = saved.$1;
        credPass = saved.$2;
      }
      if (shares.isEmpty) {
        shares = await NetworkBrowserService.listShares(address);
      }
    } catch (_) {
      shares = [];
    }

    if (mounted) Navigator.of(context).pop();

    if (!mounted) return;

    if (shares.isEmpty) {
      final creds = await _promptCredentials(address);
      if (!mounted || creds == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.computerMountNoShares)));
        }
        return;
      }
      credUser = creds.user;
      credPass = creds.pass;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(child: Text(l10n.computerMounting)),
              ],
            ),
          ),
        ),
      );
      try {
        shares = await NetworkBrowserService.listShares(
          address,
          username: credUser,
          password: credPass,
        );
      } catch (_) {
        shares = [];
      }
      if (mounted) Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (shares.isNotEmpty &&
        (credUser ?? '').trim().isNotEmpty &&
        credPass != null) {
      await NetworkCredentialsStore.save(address, credUser!.trim(), credPass);
    }

    if (shares.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.computerMountNoShares)));
      return;
    }

    Map<String, String>? picked;
    if (shares.length == 1) {
      picked = shares.first;
    } else {
      picked = await showDialog<Map<String, String>>(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text(l10n.computerSelectShare),
            children: [
              for (final s in shares)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, s),
                  child: Text(s['name'] ?? ''),
                ),
            ],
          );
        },
      );
    }

    if (picked == null || !mounted) return;
    final share = (picked['name'] ?? '').trim();
    if (share.isEmpty) return;

    if (Platform.isLinux) {
      final depsOk = await ensureMountCifsForNetwork(context);
      if (!depsOk || !mounted) return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.computerMounting)),
            ],
          ),
        ),
      ),
    );

    NetworkMountOutcome outcome;
    try {
      final user = (credUser ?? '').trim();
      if (user.isNotEmpty && credPass != null) {
        outcome = await NetworkBrowserService.connectToShareWithOutcome(
          address,
          share,
          username: user,
          password: credPass,
        );
      } else {
        outcome = await NetworkBrowserService.connectToShareWithOutcome(
          address,
          share,
        );
      }
      if (!outcome.isSuccess) {
        final creds = await _promptCredentials(address);
        if (creds != null) {
          credUser = creds.user;
          credPass = creds.pass;
          outcome = await NetworkBrowserService.connectToShareWithOutcome(
            address,
            share,
            username: creds.user,
            password: creds.pass,
          );
        }
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
    }

    if (!mounted) return;
    if (outcome.isSuccess) {
      final user = (credUser ?? '').trim();
      if (user.isNotEmpty && credPass != null) {
        await NetworkCredentialsStore.save(address, user, credPass);
      }
      widget.onOpenPath(outcome.path!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_computerMountErrorText(l10n, outcome.message))),
      );
    }
  }

  String _computerMountErrorText(AppLocalizations l10n, String? code) {
    if (code == null || code.isEmpty) return l10n.computerMountFailed;
    if (code == 'missing_mount_cifs') return l10n.computerMountMissingGio;
    if (code == 'need_password') return l10n.computerMountNeedPassword;
    if (code == 'cifs_mount_failed') return l10n.computerMountFailed;
    final short = code.length > 280 ? '${code.substring(0, 280)}…' : code;
    return '${l10n.computerMountFailed}\n$short';
  }

  Future<({String user, String pass, bool remember})?> _promptCredentials(
    String server,
  ) async {
    final l10n = AppLocalizations.of(context);
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    var remember = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(l10n.computerCredentialsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(server, style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(labelText: l10n.computerUsername),
                autofocus: true,
              ),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: l10n.computerPassword),
                obscureText: true,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.networkRememberPassword),
                value: remember,
                onChanged: (v) => setSt(() => remember = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.computerConnect),
            ),
          ],
        ),
      ),
    );
    if (result != true || !mounted) return null;
    return (
      user: userCtrl.text.trim(),
      pass: passCtrl.text,
      remember: remember,
    );
  }

  Future<void> _showVolumeMenu(
    BuildContext context,
    Offset globalPosition,
    Map<String, dynamic> disk,
  ) async {
    final l10n = AppLocalizations.of(context);
    final mount =
        disk['mount_point'] as String? ?? disk['path'] as String? ?? '/';
    final overlayObject = Navigator.of(
      context,
    ).overlay?.context.findRenderObject();
    if (overlayObject is! RenderBox) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlayObject.size,
    );

    // Build menu items for FluidContextMenu
    final List<Widget> menuItems = [
      PopupMenuItem<String>(
        value: 'open',
        child: Text(l10n.computerVolumeOpen),
      ),
      PopupMenuItem<String>(
        value: 'properties',
        child: Text(l10n.computerDiskProperties),
      ),
      PopupMenuItem<String>(
        value: 'format',
        child: Text(l10n.computerFormatVolume),
      ),
    ];

    // Show fluid context menu
    final overlayEntry = FluidContextMenu.show(
      context,
      position: Offset(position.left, position.top),
      menuItems: menuItems,
      onSelected: (value) {
        // Handle menu selection
        if (!mounted) return;
        if (value == 'open') {
          widget.onOpenPath(mount);
        } else if (value == 'properties') {
          showDiskPropertiesDialog(context, disk);
        } else if (value == 'format') {
          _formatVolumeFlow(context, disk, mount);
        }
      },
      onDismiss: () {
        // Menu dismissed
      },
      dismissOnSelect: true,
    );

    // FluidContextMenu handles the selection internally via onSelected callback
  }

  Future<void> _formatVolumeFlow(
    BuildContext context,
    Map<String, dynamic> disk,
    String mountPoint,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (!Platform.isLinux) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.computerFormatNotSupported)));
      return;
    }

    final block = disk['block_device'] as String?;
    if (block == null || block.isEmpty || !block.startsWith('/dev/')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.computerFormatNoDevice)));
      return;
    }

    if (await ComputerDiskService.isProtectedFromFormat(
      mountPoint: mountPoint,
      blockDevice: block,
    )) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.computerFormatSystemBlockedTitle),
          content: Text(l10n.computerFormatSystemBlockedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonOk),
            ),
          ],
        ),
      );
      return;
    }

    var selectedFs = ComputerDiskService.udisksFormatTypes.first;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Text(l10n.computerFormatTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.computerFormatWarning,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.computerFormatFilesystem),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedFs,
                    items: [
                      for (final t in ComputerDiskService.udisksFormatTypes)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) {
                      if (v != null) setLocal(() => selectedFs = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$mountPoint\n$block',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.dialogCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.computerFormatConfirm),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.computerFormatRunning)),
            ],
          ),
        ),
      ),
    );

    final res = await ComputerDiskService.formatBlockDevice(
      blockDevice: block,
      fstype: selectedFs,
    );

    if (mounted) Navigator.of(context).pop();

    if (!mounted) return;

    if (res.ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.computerFormatDone)));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.computerFormatFailed(res.message))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);
    final cardBg = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: 0.25);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.computerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.computerRefresh,
            onPressed: _loadingDisks ? null : _load,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (_networkDepsBanner != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: NetworkDependenciesBanner(
                        result: _networkDepsBanner!,
                        onDismiss: () =>
                            setState(() => _networkDepsBanner = null),
                        onAfterInstallAttempt: _afterNetworkDepsInstall,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.computerOnDevice,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_loadingDisks)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  if (!_loadingDisks && _disks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Text(
                        l10n.computerNoVolumes,
                        style: TextStyle(color: muted),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth;
                          // Windows-like: a few large tiles per row.
                          final crossAxisCount = w >= 860
                              ? 3
                              : (w >= 560 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _disks.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 3.8,
                                ),
                            itemBuilder: (context, i) {
                              final d = _disks[i];
                              final mount =
                                  d['mount_point'] as String? ??
                                  d['path'] as String? ??
                                  '/';
                              final name =
                                  d['display_name'] as String? ??
                                  d['name'] as String? ??
                                  mount;
                              final total = d['total'] as int? ?? 0;
                              final free = d['free'] as int? ?? 0;
                              final used = d['used'] as int? ?? 0;
                              final pct = total > 0
                                  ? (used / total).clamp(0.0, 1.0)
                                  : 0.0;
                              final capLine = total > 0
                                  ? '${l10n.computerFreeShort(_fmt(free))} · ${_fmt(total)}'
                                  : mount;

                              return GestureDetector(
                                onSecondaryTapDown: (details) {
                                  _showVolumeMenu(
                                    context,
                                    details.globalPosition,
                                    d,
                                  );
                                },
                                child: InkWell(
                                  onTap: () => widget.onOpenPath(mount),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: border),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.storage_outlined,
                                          size: 44,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: LinearProgressIndicator(
                                                  value: total > 0 ? pct : null,
                                                  minHeight: 8,
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .surfaceContainerHighest
                                                      .withValues(alpha: 0.55),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                capLine,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(color: muted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.computerNetworks,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_scanningNetwork && _servers.isEmpty)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  if (!_scanningNetwork && _servers.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Text(
                        l10n.computerNoServers,
                        style: TextStyle(color: muted),
                      ),
                    ),
                  ],
                  ..._servers.map((s) {
                    final name = (s['name'] ?? '').trim();
                    final addr = (s['address'] ?? '').trim();
                    final type = s['type'] ?? 'SMB';
                    final nameIsIp = RegExp(
                      r'^\d{1,3}(\.\d{1,3}){3}$',
                    ).hasMatch(name);
                    final hasHostname =
                        name.isNotEmpty &&
                        addr.isNotEmpty &&
                        name != addr &&
                        !nameIsIp;
                    final title = hasHostname
                        ? name
                        : (addr.isNotEmpty ? addr : name);
                    final ipLine = addr.isNotEmpty
                        ? l10n.computerNetworkIpLine(addr)
                        : '';
                    return ListTile(
                      leading: Icon(
                        Icons.dns,
                        color: theme.colorScheme.secondary,
                      ),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: ipLine.isEmpty
                          ? Text(
                              type,
                              style: TextStyle(fontSize: 12, color: muted),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipLine,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  type,
                                  style: TextStyle(fontSize: 11, color: muted),
                                ),
                              ],
                            ),
                      isThreeLine: ipLine.isNotEmpty,
                      onTap: () => _openNetworkServer(s),
                    );
                  }),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      l10n.computerTools,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _ToolTile(
                          icon: Icons.search,
                          title: l10n.computerToolFindFiles,
                          onTap: widget.onFindFilesAndFolders,
                        ),
                        const SizedBox(height: 10),
                        _ToolTile(
                          icon: Icons.apps,
                          title: l10n.computerToolPackages,
                          onTap: widget.onOpenPackageManager,
                        ),
                        const SizedBox(height: 10),
                        _ToolTile(
                          icon: Icons.system_update_alt,
                          title: l10n.computerToolSystemUpdates,
                          onTap: widget.onOpenSystemUpdates,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: 0.25);
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.14),
      blurRadius: 10,
      spreadRadius: 0.3,
      offset: const Offset(0, 4),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
          boxShadow: [shadow],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
