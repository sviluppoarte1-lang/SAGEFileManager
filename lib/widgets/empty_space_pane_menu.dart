import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/widgets/compact_menu_row.dart';

/// Menu contestuale spazio vuoto: compatto, sottomenu «Crea nuovo» all’hover.
class EmptySpacePaneMenu {
  EmptySpacePaneMenu._();

  static const double _rowH = CompactMenuRow.rowHeight;
  static const double _minW = 212;

  /// Offset verticale del bordo superiore della riga «Crea nuovo» (indici 0..4 sopra).
  static const double _createNewRowTop =
      _rowH + 1 + _rowH + _rowH + _rowH + _rowH;

  static const double _subMenuOverlap = 24;

  static Future<String?> show(
    BuildContext context, {
    required Offset globalPosition,
    required AppLocalizations l10n,
    required bool showHiddenFiles,
    required bool pasteEnabled,
  }) {
    final completer = Completer<String?>();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    void finish(String? value) {
      if (entry.mounted) entry.remove();
      if (!completer.isCompleted) completer.complete(value);
    }

    entry = OverlayEntry(
      builder: (ctx) => _EmptySpacePaneMenuOverlay(
        globalPosition: globalPosition,
        l10n: l10n,
        showHiddenFiles: showHiddenFiles,
        pasteEnabled: pasteEnabled,
        onSelected: (v) => finish(v),
        onDismiss: () => finish(null),
      ),
    );
    overlay.insert(entry);
    return completer.future;
  }

  static Widget _row({
    required IconData icon,
    required String label,
    Widget? trailing,
  }) {
    return CompactMenuRow(
      icon: icon,
      label: label,
      trailing: trailing,
    );
  }

  static List<Widget> buildMainRows(
    AppLocalizations l10n, {
    required bool showHiddenFiles,
  }) {
    return [
      _row(icon: Icons.terminal, label: l10n.ctxOpenTerminal),
      const Divider(height: 1),
      _row(icon: Icons.create_new_folder, label: l10n.ctxNewFolder),
      _row(
        icon: Icons.admin_panel_settings,
        label: l10n.ctxOpenAsRoot,
      ),
      _row(
        icon: showHiddenFiles ? Icons.visibility_off : Icons.visibility,
        label: showHiddenFiles ? l10n.viewHideHidden : l10n.viewShowHidden,
        trailing: showHiddenFiles
            ? Icon(Icons.check, size: 14, color: Colors.grey.shade400)
            : null,
      ),
      _row(
        icon: Icons.post_add_outlined,
        label: l10n.ctxCreateNew,
        trailing: Icon(
          Icons.chevron_right,
          size: 16,
          color: Colors.grey.shade500,
        ),
      ),
      _row(icon: Icons.paste, label: l10n.ctxPaste),
      _row(icon: Icons.info, label: l10n.sidebarProperties),
    ];
  }

  static List<Widget> buildSubmenuRows(AppLocalizations l10n) {
    return [
      _row(
        icon: Icons.description_outlined,
        label: l10n.ctxNewTextDocumentShort,
      ),
      _row(icon: Icons.description, label: l10n.ctxNewWordDocument),
      _row(
        icon: Icons.table_chart_outlined,
        label: l10n.ctxNewExcelSpreadsheet,
      ),
    ];
  }

  static List<String> mainValues({required bool pasteEnabled}) {
    return [
      'open_terminal',
      '__div__',
      'new_folder',
      'open_as_root',
      'toggle_hidden',
      '__sub__',
      pasteEnabled ? 'paste' : '__paste_disabled__',
      'properties',
    ];
  }

  static const List<String> subValues = ['new_txt', 'new_docx', 'new_xlsx'];
}

class _EmptySpacePaneMenuOverlay extends StatefulWidget {
  const _EmptySpacePaneMenuOverlay({
    required this.globalPosition,
    required this.l10n,
    required this.showHiddenFiles,
    required this.pasteEnabled,
    required this.onSelected,
    required this.onDismiss,
  });

  final Offset globalPosition;
  final AppLocalizations l10n;
  final bool showHiddenFiles;
  final bool pasteEnabled;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  @override
  State<_EmptySpacePaneMenuOverlay> createState() =>
      _EmptySpacePaneMenuOverlayState();
}

class _EmptySpacePaneMenuOverlayState extends State<_EmptySpacePaneMenuOverlay> {
  final GlobalKey _mainKey = GlobalKey();
  final GlobalKey _subKey = GlobalKey();
  final FocusNode _focus = FocusNode();

  bool _hoverSub = false;
  bool _pointerOverSubZone = false;
  Timer? _closeSubTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _closeSubTimer?.cancel();
    _focus.dispose();
    super.dispose();
  }

  void _scheduleCloseSub() {
    _closeSubTimer?.cancel();
    _closeSubTimer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      if (!_pointerOverSubZone) {
        setState(() => _hoverSub = false);
      }
    });
  }

  bool _globalHit(RenderBox? box, Offset global) {
    if (box == null || !box.hasSize) return false;
    final o = box.localToGlobal(Offset.zero);
    final r = o & box.size;
    return r.contains(global);
  }

  bool _isInsideMenus(Offset global) {
    final main = _mainKey.currentContext?.findRenderObject() as RenderBox?;
    if (_globalHit(main, global)) return true;
    if (_hoverSub) {
      final sub = _subKey.currentContext?.findRenderObject() as RenderBox?;
      if (_globalHit(sub, global)) return true;
    }
    return false;
  }

  void _onPick(String value) {
    if (value == '__div__' || value == '__sub__') return;
    if (value == '__paste_disabled__') return;
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.sizeOf(context);
    final mainRows = EmptySpacePaneMenu.buildMainRows(
      widget.l10n,
      showHiddenFiles: widget.showHiddenFiles,
    );
    final values = EmptySpacePaneMenu.mainValues(
      pasteEnabled: widget.pasteEnabled,
    );
    final subRows = EmptySpacePaneMenu.buildSubmenuRows(widget.l10n);
    final subValues = EmptySpacePaneMenu.subValues;

    const pad = 8.0;
    double left = widget.globalPosition.dx;
    double top = widget.globalPosition.dy;
    if (left + EmptySpacePaneMenu._minW + 200 > media.width) {
      left = (media.width - EmptySpacePaneMenu._minW - 200 - pad).clamp(
        pad,
        media.width,
      );
    }
    if (top + 320 > media.height) {
      top = (media.height - 320 - pad).clamp(pad, media.height);
    }

    Widget tile(int i) {
      final v = values[i];
      final row = mainRows[i];
      final enabled = v != '__paste_disabled__' && v != '__div__';

      if (v == '__div__') {
        return const SizedBox(height: 1, child: Divider(height: 1));
      }

      if (v == '__sub__') {
        return MouseRegion(
          onEnter: (_) {
            _closeSubTimer?.cancel();
            setState(() {
              _hoverSub = true;
              _pointerOverSubZone = true;
            });
          },
          onExit: (_) {
            _pointerOverSubZone = false;
            _scheduleCloseSub();
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              canRequestFocus: false,
              mouseCursor: SystemMouseCursors.basic,
              child: Ink(
                height: EmptySpacePaneMenu._rowH,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: row,
              ),
            ),
          ),
        );
      }

      return MouseRegion(
        onEnter: (_) {
          if (_hoverSub) setState(() => _hoverSub = false);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => _onPick(v) : null,
            canRequestFocus: false,
            mouseCursor:
                enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: Ink(
              height: EmptySpacePaneMenu._rowH,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Opacity(
                opacity: enabled ? 1 : 0.45,
                child: row,
              ),
            ),
          ),
        ),
      );
    }

    final mainPanel = Material(
      key: _mainKey,
      color: Colors.transparent,
      child: Container(
        width: EmptySpacePaneMenu._minW,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(mainRows.length, tile),
        ),
      ),
    );

    Widget subColumn() {
      return MouseRegion(
        onEnter: (_) {
          _closeSubTimer?.cancel();
          setState(() {
            _hoverSub = true;
            _pointerOverSubZone = true;
          });
        },
        onExit: (_) {
          _pointerOverSubZone = false;
          _scheduleCloseSub();
        },
        child: Material(
          key: _subKey,
          color: Colors.transparent,
          child: Container(
            width: EmptySpacePaneMenu._minW,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(subRows.length, (j) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onPick(subValues[j]),
                    canRequestFocus: false,
                    mouseCursor: SystemMouseCursors.click,
                    child: Ink(
                      height: EmptySpacePaneMenu._rowH,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: subRows[j],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          widget.onDismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) {
                if (_isInsideMenus(e.position)) return;
                widget.onDismiss();
              },
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topLeft,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mainPanel,
                    if (_hoverSub)
                      Transform.translate(
                        offset: Offset(
                          -EmptySpacePaneMenu._subMenuOverlap,
                          EmptySpacePaneMenu._createNewRowTop,
                        ),
                        child: subColumn(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
