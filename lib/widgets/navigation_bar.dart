import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/services/network_browser_service.dart';
import 'package:filemanager/widgets/glass_wrapper.dart';
import 'package:filemanager/widgets/file_list.dart';

class NavigationBar extends StatelessWidget {
  final String currentPath;
  final String? secondPanePath; // Percorso del secondo pannello (per split view)
  final bool isSecondPaneFocused; // Indica quale pannello è attivo
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onUp;
  final Function(String)? onPathChanged;
  final Function(String)? onSecondPanePathChanged; // Callback per cambiare il percorso del secondo pannello
  final VoidCallback? onSecondPaneBack;
  final VoidCallback? onSecondPaneForward;
  final ViewMode viewMode;
  final Function(ViewMode)? onViewModeChanged;
  final Widget? menuBar; // Menu bar da mostrare a sinistra sopra i pulsanti
  /// Pulsante ordinamento file (ex «Disponi icone»), a sinistra delle icone vista.
  final Widget? arrangeMenu;

  const NavigationBar({
    super.key,
    required this.currentPath,
    this.secondPanePath,
    this.isSecondPaneFocused = false,
    this.onBack,
    this.onForward,
    this.onUp,
    this.onPathChanged,
    this.onSecondPanePathChanged,
    this.onSecondPaneBack,
    this.onSecondPaneForward,
    this.viewMode = ViewMode.list,
    this.onViewModeChanged,
    this.menuBar,
    this.arrangeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isSplitView = secondPanePath != null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Menu bar sopra i pulsanti (se fornito)
        if (menuBar != null) menuBar!,
        // Navigation bar con pulsanti avanti/indietro (angoli arrotondati + profondità)
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: GlassWrapper(
              borderRadius: BorderRadius.circular(16),
              opacity: 0.92,
              blur: 12.0,
              color: Color.alphaBlend(
                theme.colorScheme.surfaceTint.withValues(alpha: 0.05),
                theme.colorScheme.surface.withValues(alpha: 0.88),
              ),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
              // Navigation buttons
              _ModernNavButton(
                icon: Icons.arrow_back,
                tooltip: l10n.navBack,
                onPressed: isSecondPaneFocused ? onSecondPaneBack : onBack,
              ),
              const SizedBox(width: 4),
              _ModernNavButton(
                icon: Icons.arrow_forward,
                tooltip: l10n.navForward,
                onPressed: isSecondPaneFocused ? onSecondPaneForward : onForward,
              ),
              const SizedBox(width: 4),
              _ModernNavButton(
                icon: Icons.arrow_upward,
                tooltip: l10n.navUp,
                onPressed: isSecondPaneFocused
                    ? (secondPanePath != null && secondPanePath != '/'
                        ? () {
                            String? parent;
                            if (NetworkBrowserService.isSmbShellPath(
                              secondPanePath!,
                            )) {
                              parent = NetworkBrowserService.smbShellParent(
                                secondPanePath!,
                              );
                            } else {
                              final d = path.dirname(secondPanePath!);
                              parent = d != secondPanePath ? d : null;
                            }
                            if (parent != null) {
                              onSecondPanePathChanged?.call(parent);
                            }
                          }
                        : null)
                    : onUp,
              ),
          // Path bar - mostra il percorso del pannello attivo
          Expanded(
            child: isSplitView
                ? Row(
                    children: [
                      // Primo pannello (sinistra)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Cambia focus al primo pannello
                            if (onPathChanged != null) {
                              onPathChanged!(currentPath);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: !isSecondPaneFocused
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                  : theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.45),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _buildPathSegments(context, currentPath),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Secondo pannello (destra)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Cambia focus al secondo pannello
                            if (onSecondPanePathChanged != null && secondPanePath != null) {
                              onSecondPanePathChanged!(secondPanePath!);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSecondPaneFocused
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                                  : theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.45),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _buildPathSegments(context, secondPanePath ?? '/'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Ordinamento + vista
                      if (arrangeMenu != null) ...[
                        const SizedBox(width: 4),
                        arrangeMenu!,
                      ],
                      const SizedBox(width: 8),
                      _buildViewModeButton(
                        context,
                        Icons.view_list,
                        ViewMode.list,
                        l10n.prefsViewModeList,
                      ),
                      _buildViewModeButton(
                        context,
                        Icons.view_module,
                        ViewMode.grid,
                        l10n.prefsViewModeGrid,
                      ),
                      _buildViewModeButton(
                        context,
                        Icons.view_headline,
                        ViewMode.details,
                        l10n.prefsViewModeDetails,
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _buildPathSegments(context, currentPath),
                            ),
                          ),
                        ),
                        if (arrangeMenu != null) ...[
                          const SizedBox(width: 4),
                          arrangeMenu!,
                        ],
                        const SizedBox(width: 8),
                        _buildViewModeButton(
                          context,
                          Icons.view_list,
                          ViewMode.list,
                          l10n.prefsViewModeList,
                        ),
                        _buildViewModeButton(
                          context,
                          Icons.view_module,
                          ViewMode.grid,
                          l10n.prefsViewModeGrid,
                        ),
                        _buildViewModeButton(
                          context,
                          Icons.view_headline,
                          ViewMode.details,
                          l10n.prefsViewModeDetails,
                        ),
                      ],
                    ),
                  ),
              ),
            ],
            ),
          ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    IconData icon,
    ViewMode mode,
    String tooltip,
  ) {
    final isSelected = viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        onPressed: () => onViewModeChanged?.call(mode),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  List<Widget> _buildPathSegments(BuildContext context, String pathToDisplay) {
    if (NetworkBrowserService.isSmbShellPath(pathToDisplay)) {
      return _buildSmbShellPathSegments(context, pathToDisplay);
    }
    final segments = pathToDisplay.split('/').where((s) => s.isNotEmpty).toList();
    final widgets = <Widget>[];

    // Home icon
    final isSecondPane = pathToDisplay == secondPanePath;
    widgets.add(
      GestureDetector(
        onTap: () {
          if (isSecondPane && onSecondPanePathChanged != null) {
            onSecondPanePathChanged!('/');
          } else if (!isSecondPane && onPathChanged != null) {
            onPathChanged!('/');
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.home, size: 18),
        ),
      ),
    );

    // Path segments
    String currentSegmentPath = '/';
    for (int i = 0; i < segments.length; i++) {
      // Build path correctly for Linux/Unix systems
      if (currentSegmentPath == '/') {
        currentSegmentPath = '/${segments[i]}';
      } else {
        currentSegmentPath = '$currentSegmentPath/${segments[i]}';
      }
      final segment = segments[i];
      final pathToNavigate = currentSegmentPath; // Capture for closure
      
      widgets.add(
        GestureDetector(
          onTap: () {
            if (isSecondPane && onSecondPanePathChanged != null) {
              onSecondPanePathChanged!(pathToNavigate);
            } else if (!isSecondPane && onPathChanged != null) {
              onPathChanged!(pathToNavigate);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_right, size: 16),
                Text(
                  segment,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildSmbShellPathSegments(
    BuildContext context,
    String pathToDisplay,
  ) {
    final u = Uri.tryParse(pathToDisplay);
    if (u == null || u.scheme != 'fm-smb' || u.host.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(pathToDisplay, style: const TextStyle(fontSize: 14)),
        ),
      ];
    }
    final segs = u.pathSegments.where((s) => s.isNotEmpty).toList();
    final widgets = <Widget>[];
    final isSecondPane = pathToDisplay == secondPanePath;

    widgets.add(
      GestureDetector(
        onTap: () {
          if (segs.isEmpty) return;
          var target = Uri(
            scheme: 'fm-smb',
            host: u.host,
            pathSegments: [segs.first],
          ).toString();
          if (!target.endsWith('/')) target = '$target/';
          if (isSecondPane && onSecondPanePathChanged != null) {
            onSecondPanePathChanged!(target);
          } else if (!isSecondPane && onPathChanged != null) {
            onPathChanged!(target);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lan,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                u.host,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    for (var i = 0; i < segs.length; i++) {
      final pathSegs = segs.sublist(0, i + 1);
      var target = Uri(
        scheme: 'fm-smb',
        host: u.host,
        pathSegments: pathSegs,
      ).toString();
      if (!target.endsWith('/')) target = '$target/';
      final label = segs[i];
      widgets.add(
        GestureDetector(
          onTap: () {
            if (isSecondPane && onSecondPanePathChanged != null) {
              onSecondPanePathChanged!(target);
            } else if (!isSecondPane && onPathChanged != null) {
              onPathChanged!(target);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_right, size: 16),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }

}

class _ModernNavButton extends StatelessWidget {
  const _ModernNavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final primary = theme.colorScheme.primary;
    final fg = enabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.9)
        : theme.colorScheme.onSurface.withValues(alpha: 0.35);

    final ring = LinearGradient(
      colors: [
        primary.withValues(alpha: enabled ? 0.95 : 0.25),
        theme.colorScheme.secondary.withValues(alpha: enabled ? 0.85 : 0.20),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ring,
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: enabled ? 0.18 : 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 18, color: fg),
            ),
          ),
        ),
      ),
    );
  }
}
