import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/package_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class PackageManager extends StatefulWidget {
  const PackageManager({super.key});

  @override
  State<PackageManager> createState() => _PackageManagerState();
}

class _PackageManagerState extends State<PackageManager> {
  List<PackageInfo> packages = [];
  bool isLoading = true;
  String searchQuery = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => isLoading = true);
    final loaded = await PackageService.getInstalledPackages();
    setState(() {
      packages = loaded;
      isLoading = false;
    });
  }

  Future<void> _uninstallPackage(PackageInfo package) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pkgUninstallTitle),
        content: Text(l10n.pkgUninstallConfirm(package.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pkgUninstallButton),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Check dependencies
      final deps = await PackageService.checkDependencies(package);
      if (deps.isNotEmpty && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.pkgDepsTitle),
            content: Text(
              l10n.pkgDepsUsedByBody(deps.take(5).join('\n')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.dialogCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.pkgProceedAnyway),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      final success = await PackageService.uninstallPackage(package);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pkgUninstalled(package.name))),
        );
        _loadPackages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pkgUninstallFailed)),
        );
      }
    }
  }

  List<String> get availableCategories {
    final categories = packages.map((p) => p.type.toUpperCase()).toSet().toList();
    categories.sort();
    return categories;
  }

  List<PackageInfo> get filteredPackages {
    var filtered = packages;
    
    // Filter by category
    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.type.toUpperCase() == selectedCategory).toList();
    }
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pkgPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: l10n.pkgInstallFromFileTooltip,
            onPressed: _installPackageFromFile,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPackages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                FilterChip(
                  label: Text(l10n.pkgFilterAll),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => selectedCategory = null);
                  },
                ),
                const SizedBox(width: 8),
                ...availableCategories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() => selectedCategory = selected ? category : null);
                        },
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enableInteractiveSelection: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: l10n.pkgSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredPackages.length,
                    itemBuilder: (context, index) {
                      final package = filteredPackages[index];
                      return ListTile(
                        leading: _getTypeIcon(package.type),
                        title: Text(package.name),
                        subtitle: Text(
                          '${package.type.toUpperCase()} • ${package.version}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _uninstallPackage(package),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<ProcessResult> _runInstallerWithProgressDialog(
    String executable,
    List<String> arguments,
  ) async {
    if (!mounted) {
      return ProcessResult(-1, -1, '', '');
    }
    final code = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PackageInstallProgressDialog(
        executable: executable,
        arguments: arguments,
      ),
    );
    final exit = code ?? -1;
    return ProcessResult(-1, exit, '', '');
  }

  Future<void> _installPackageFromFile() async {
    final l10n = AppLocalizations.of(context);
    FilePickerResult? result;
    try {
      // Su Linux, `FileType.any` con `allowedExtensions` può bloccare il dialogo;
      // si filtra l’estensione dopo la scelta.
      result = await FilePicker.platform.pickFiles(
        dialogTitle: l10n.pkgInstallFromFileTooltip,
        type: FileType.any,
        allowMultiple: false,
        lockParentWindow: true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError(e.toString()))),
      );
      return;
    }

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final lower = fileName.toLowerCase();
      
      if (!mounted) return;
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.pkgInstallDialogTitle),
          content: Text(l10n.pkgInstallConfirm(fileName)),
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

      if (confirmed == true && mounted) {
        try {
          late ProcessResult processResult;

          if (lower.endsWith('.deb')) {
            processResult = await _runInstallerWithProgressDialog(
              'sudo',
              ['dpkg', '-i', filePath],
            );
          } else if (lower.endsWith('.rpm')) {
            processResult = await _runInstallerWithProgressDialog(
              'sudo',
              ['rpm', '-i', filePath],
            );
          } else if (lower.endsWith('.snap')) {
            processResult = await _runInstallerWithProgressDialog('sudo', [
              'snap',
              'install',
              '--dangerous',
              filePath,
            ]);
          } else if (lower.endsWith('.flatpak') ||
              lower.endsWith('.flatpakref')) {
            processResult = await _runInstallerWithProgressDialog('flatpak', [
              'install',
              '--user',
              '-y',
              '--noninteractive',
              filePath,
            ]);
            if (processResult.exitCode != 0) {
              processResult = await _runInstallerWithProgressDialog('flatpak', [
                'install',
                '-y',
                '--noninteractive',
                filePath,
              ]);
            }
          } else if (lower.endsWith('.appimage')) {
            processResult = await _runInstallerWithProgressDialog('chmod', [
              '+x',
              filePath,
            ]);
            if (mounted) {
              if (processResult.exitCode == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pkgExecutableMade(fileName))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.pkgInstallFailedWithError(
                        'chmod exit ${processResult.exitCode}',
                      ),
                    ),
                  ),
                );
              }
            }
            return;
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pkgUnsupportedPackage)),
              );
            }
            return;
          }
          
          if (mounted) {
            if (processResult.exitCode == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pkgInstalledSuccess(fileName))),
              );
              _loadPackages();
            } else {
              final err = [
                processResult.stderr.toString().trim(),
                processResult.stdout.toString().trim(),
              ].where((s) => s.isNotEmpty).join('\n');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.pkgInstallFailedWithError(
                      err.isEmpty ? 'exit ${processResult.exitCode}' : err,
                    ),
                  ),
                  duration: const Duration(seconds: 8),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.commonError(e.toString()))),
            );
          }
        }
      }
    }
  }

  Widget _getTypeIcon(String type) {
    final typeLower = type.toLowerCase();
    final iconPath = 'assets/icons/package_types/$typeLower.png';
    
    // Try to load custom icon, fallback to Material icon
    try {
      return Image.asset(
        iconPath,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(_getTypeIconData(type), size: 40);
        },
      );
    } catch (e) {
      return Icon(_getTypeIconData(type), size: 40);
    }
  }

  IconData _getTypeIconData(String type) {
    switch (type.toLowerCase()) {
      case 'apt':
        return Icons.inventory;
      case 'snap':
        return Icons.apps;
      case 'flatpak':
        return Icons.app_blocking;
      case 'gnome':
        return Icons.desktop_windows;
      case 'kde':
        return Icons.dashboard;
      default:
        return Icons.apps;
    }
  }
}

/// Dialog modale con barra indeterminata e ultima riga stdout/stderr dell’installer.
class _PackageInstallProgressDialog extends StatefulWidget {
  const _PackageInstallProgressDialog({
    required this.executable,
    required this.arguments,
  });

  final String executable;
  final List<String> arguments;

  @override
  State<_PackageInstallProgressDialog> createState() =>
      _PackageInstallProgressDialogState();
}

class _PackageInstallProgressDialogState
    extends State<_PackageInstallProgressDialog> {
  late String _statusLine;

  @override
  void initState() {
    super.initState();
    _statusLine = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _run();
    });
  }

  Future<void> _run() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _statusLine = l10n.pkgInstallRunningStatus);
    var exitCode = -1;
    try {
      final proc = await Process.start(
        widget.executable,
        widget.arguments,
        environment: Platform.environment,
      );
      void attach(Stream<List<int>> stream) {
        stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          final t = line.trim();
          if (t.isNotEmpty && mounted) {
            setState(() => _statusLine = t.length > 400 ? '${t.substring(0, 400)}…' : t);
          }
        });
      }
      attach(proc.stdout);
      attach(proc.stderr);
      exitCode = await proc.exitCode;
    } catch (_) {
      exitCode = -1;
    }
    if (mounted) {
      Navigator.of(context).pop(exitCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.pkgInstallProgressTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            SelectableText(
              _statusLine.isEmpty ? l10n.pkgInstallRunningStatus : _statusLine,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
