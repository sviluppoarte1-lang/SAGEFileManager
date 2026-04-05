import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
// (foundation) provided by material.dart in this file.
import 'package:filemanager/models/file_info.dart';
import 'package:filemanager/theme/app_visual_theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:filemanager/services/thumbnail_cache_service.dart';
import 'package:filemanager/services/folder_icon_service.dart';
import 'package:filemanager/services/file_icon_service.dart';
import 'package:selection_marquee/selection_marquee.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:filemanager/services/logging_service.dart';
import 'package:filemanager/services/rust_ffi.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:filemanager/utils/format_bytes.dart';
import 'package:filemanager/utils/keyboard_modifier_state.dart';
import 'package:filemanager/widgets/file_item_click_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// [File.existsSync] is **false** for directory paths on Linux/macOS; drag must use this.
bool entityPathExistsSync(String p) {
  return FileSystemEntity.typeSync(p, followLinks: true) !=
      FileSystemEntityType.notFound;
}

// Tracks whether a pointer down occurred with modifiers (ctrl/meta/shift)
Map<int, bool> _pointerDownHadModifier = {};

/// [DataReader] is often null during [onDropOver] on desktop; [DropItem.canProvide]
/// and [DropItem.localData] still describe the session (super_drag_and_drop docs).
bool dropSessionAcceptsFileItems(DropSession session) {
  return session.items.any((i) {
    if (i.canProvide(Formats.fileUri) || i.canProvide(Formats.uri)) {
      return true;
    }
    final r = i.dataReader;
    if (r != null &&
        (r.canProvide(Formats.fileUri) || r.canProvide(Formats.uri))) {
      return true;
    }
    final local = i.localData;
    if (local is List) {
      for (final e in local) {
        if (e is String && e.isNotEmpty) return true;
      }
    }
    return false;
  });
}

/// Use for [DropRegion.onDropOver] hover / highlight. On Linux/desktop,
/// [DataReader] is often still null on early drag-move frames; strict
/// [dropSessionAcceptsFileItems] then returns false, the inner folder
/// [DropRegion] is skipped, and the pane-level [DropRegion] wins — folders
/// never highlight and repeat drags feel broken.
bool dropSessionAcceptsFileItemsLenient(DropSession session) {
  if (dropSessionAcceptsFileItems(session)) return true;
  if (session.items.isEmpty) return false;
  final ops = session.allowedOperations;
  if (!ops.contains(DropOperation.move) && !ops.contains(DropOperation.copy)) {
    return false;
  }
  return true;
}

/// When [dragItemProvider] returns an item, the package may still abort if the
/// snapshot fails; [cancelSession] then sets [dragCompleted] so we can reset.
void _attachDragSessionCleanup(DragItemRequest request) {
  void listener() {
    if (request.session.dragCompleted.value != null) {
      request.session.dragCompleted.removeListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetPointerGuardsAfterNativeDrag();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          resetPointerGuardsAfterNativeDrag();
        });
      });
    }
  }

  request.session.dragCompleted.addListener(listener);
}

enum ViewMode { list, grid, details }

enum _HitTag { fileItem, fileToggleRegion }

bool _hitTestPathTouchesFile(BoxHitTestResult result) {
  return result.path.any((entry) {
    final t = entry.target;
    return t is RenderMetaData &&
        (t.metaData == _HitTag.fileItem ||
            t.metaData == _HitTag.fileToggleRegion);
  });
}

/// Solo icona + etichetta: per DnD e per non bloccare la selezione rettangolare sul resto della riga/cella.
bool _hitTestPathTouchesIconOrLabel(BoxHitTestResult result) {
  return result.path.any((entry) {
    final t = entry.target;
    return t is RenderMetaData && t.metaData == _HitTag.fileToggleRegion;
  });
}

bool _hitTestGlobalOnIconOrLabel(Offset globalPosition, BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.attached) return false;
  final result = BoxHitTestResult();
  box.hitTest(result, position: box.globalToLocal(globalPosition));
  return _hitTestPathTouchesIconOrLabel(result);
}

/// Solo hit-test metadata: la selezione avviene dal [Listener] della riga/cella
/// (un solo percorso, nessun [GestureDetector.onTap] concorrente che richiede
/// un tap più deciso su Wayland/desktop).
class _ToggleRegion extends StatelessWidget {
  final Widget child;

  const _ToggleRegion({required this.child});

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: _HitTag.fileToggleRegion,
      behavior: HitTestBehavior.deferToChild,
      child: child,
    );
  }
}

/// [Listener] **sopra** [DraggableWidget]: riceve sempre up/down; [FileItemClickSession]
/// è un'istanza per riga (stato nel [State]).
class _FileRowClickSessionWidget extends StatefulWidget {
  const _FileRowClickSessionWidget({
    super.key,
    required this.file,
    required this.child,
    required this.onSelectWithPointer,
    this.onOpenOnDoubleClick,
    this.onRightClick,
    required this.hitTestIconOrLabel,
    this.gridRustSync = false,
  });

  final FileInfo file;
  final Widget child;
  final void Function(FileInfo file, int pointer) onSelectWithPointer;
  final VoidCallback? onOpenOnDoubleClick;
  final void Function(FileInfo file, Offset pos)? onRightClick;
  final bool Function(Offset global, BuildContext context) hitTestIconOrLabel;
  final bool gridRustSync;

  @override
  State<_FileRowClickSessionWidget> createState() =>
      _FileRowClickSessionWidgetState();
}

class _FileRowClickSessionWidgetState extends State<_FileRowClickSessionWidget> {
  final FileItemClickSession _clickSession = FileItemClickSession();

  static const double _clickSlopPx = 56.0;

  int? _primaryDownPointer;
  Offset? _primaryDownGlobal;

  @override
  void dispose() {
    _clickSession.reset();
    super.dispose();
  }

  bool _netMovementIsClick(Offset upGlobal) {
    final start = _primaryDownGlobal;
    if (start == null) return false;
    return (upGlobal - start).distance < _clickSlopPx;
  }

  void _clearDown() {
    _primaryDownPointer = null;
    _primaryDownGlobal = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons & kSecondaryMouseButton != 0) {
      widget.onRightClick?.call(widget.file, event.position);
      return;
    }
    if (event.buttons & kPrimaryButton == 0) return;

    if (widget.hitTestIconOrLabel(event.position, context)) {
      _MarqueeDragGuard.itemCellPrimaryDown();
    }
    _primaryDownPointer = event.pointer;
    _primaryDownGlobal = event.position;

    KeyboardModifierState.instance.syncNow();
    if (widget.gridRustSync) {
      final isCtrl = KeyboardModifierState.instance.isCtrlOrMetaPressed;
      final isShift = KeyboardModifierState.instance.isShiftPressed;
      final modifierActiveNow = isCtrl || isShift;
      _pointerDownHadModifier[event.pointer] = modifierActiveNow;
      RustFFI.setDragCtrlState(modifierActiveNow ? 1 : 0);
      if (modifierActiveNow) {
        _ModifierClickGuard.mark(event.pointer);
        widget.onSelectWithPointer(widget.file, event.pointer);
        _pointerDownHadModifier[event.pointer] = true;
      } else {
        _pointerDownHadModifier[event.pointer] = false;
      }
    } else {
      if (KeyboardModifierState.instance.isCtrlOrMetaPressed ||
          KeyboardModifierState.instance.isShiftPressed) {
        _ModifierClickGuard.mark(event.pointer);
        widget.onSelectWithPointer(widget.file, event.pointer);
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _ModifierClickGuard.clear(event.pointer);
    _MarqueeDragGuard.itemCellPrimaryUpOrCancel();
    if (event.pointer == _primaryDownPointer) {
      _clearDown();
    }
    if (widget.gridRustSync) {
      _pointerDownHadModifier.remove(event.pointer);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _MarqueeDragGuard.itemCellPrimaryUpOrCancel();
    if (widget.gridRustSync) {
      RustFFI.setDragCtrlState(0);
    }

    if (event.pointer != _primaryDownPointer) {
      return;
    }

    final upPos = event.position;
    final wasClick = _netMovementIsClick(upPos);
    _clearDown();

    if (_ModifierClickGuard.takeHadModifierDownSelect(event.pointer)) {
      return;
    }

    if (!wasClick) {
      KeyboardModifierState.instance.syncNow();
      if (KeyboardModifierState.instance.isCtrlOrMetaPressed ||
          KeyboardModifierState.instance.isShiftPressed) {
        _clickSession.onPrimaryUpClick(
          select: () => widget.onSelectWithPointer(widget.file, event.pointer),
          openOnDouble: widget.onOpenOnDoubleClick,
        );
      }
      return;
    }

    _clickSession.onPrimaryUpClick(
      select: () => widget.onSelectWithPointer(widget.file, event.pointer),
      openOnDouble: widget.onOpenOnDoubleClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}

/// Suppresses grid marquee while a primary pointer is down on a file row/cell so
/// [super_drag_and_drop] can win the arena for the whole gesture — not a short
/// time window (that caused: first drag OK, later drag drew the selection rect).
class _MarqueeDragGuard {
  _MarqueeDragGuard._();

  static int _primaryDownOnFileCellCount = 0;

  static void itemCellPrimaryDown() {
    _primaryDownOnFileCellCount++;
  }

  static void itemCellPrimaryUpOrCancel() {
    if (_primaryDownOnFileCellCount > 0) {
      _primaryDownOnFileCellCount--;
    }
  }

  /// True while at least one pointer that started on a file cell is still down.
  static bool get shouldSuppressGridMarquee => _primaryDownOnFileCellCount > 0;

  /// After OS drag-and-drop, [itemCellPrimaryUpOrCancel] may never run for the
  /// cell that started the drag, leaving a stale count and breaking the next drag.
  static void reset() {
    _primaryDownOnFileCellCount = 0;
  }
}

/// Resets marquee and click/drag guards after a native DnD session ends.
void resetPointerGuardsAfterNativeDrag() {
  _MarqueeDragGuard.reset();
  _ModifierClickGuard.resetAll();
}

/// Ctrl/Maiusc: selezione sul press (pointer down), tap istantaneo come nei
/// file manager desktop; sul release non si ripete [_invokeFileSelectedFromPointer].
class _ModifierClickGuard {
  static final Set<int> _selectedOnDown = <int>{};

  static void mark(int pointer) => _selectedOnDown.add(pointer);

  /// Rimuove e indica se il down aveva già applicato la selezione con modificatore.
  static bool takeHadModifierDownSelect(int pointer) =>
      _selectedOnDown.remove(pointer);

  static void clear(int pointer) => _selectedOnDown.remove(pointer);

  static void resetAll() => _selectedOnDown.clear();
}

/// Mouse drag-to-scroll off the grid so [GridView] competes less with
/// [super_drag_and_drop]; wheel / trackpad scrolling unchanged in practice.
class _GridScrollBehavior extends MaterialScrollBehavior {
  const _GridScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}

/// Defers marquee selection until the pointer moves past [minDragDistance],
/// matching [SelectionMarquee] so OS file drag can win the gesture arena first.
class _GridMarqueeShell extends StatefulWidget {
  const _GridMarqueeShell({
    required this.child,
    this.selectionController,
    this.marqueeKey,
    this.onPaneBackgroundPrimaryTap,
    this.onSecondaryTapDown,
    this.minDragDistance = 36,
  });

  final Widget child;
  final SelectionController? selectionController;
  final GlobalKey? marqueeKey;
  final VoidCallback? onPaneBackgroundPrimaryTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final double minDragDistance;

  @override
  State<_GridMarqueeShell> createState() => _GridMarqueeShellState();
}

class _GridMarqueeShellState extends State<_GridMarqueeShell> {
  Offset? _startLocal;
  bool _marqueeActive = false;
  int? _marqueePointerId;
  Offset? _primaryDownGlobal;
  bool _primaryDownOnCell = false;

  void _finishMarqueePan() {
    final c = widget.selectionController;
    if (c != null && c.isSelecting) {
      c.endSelection();
    }
    _startLocal = null;
    _marqueeActive = false;
    _marqueePointerId = null;
  }

  void _applyMarqueeMove(Offset globalPosition) {
    if (_MarqueeDragGuard.shouldSuppressGridMarquee) return;
    final ctrl = widget.selectionController;
    final mkey = widget.marqueeKey;
    final start = _startLocal;
    if (ctrl == null || mkey == null || start == null) return;

    final box = mkey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.globalToLocal(globalPosition);

    if (!_marqueeActive) {
      if ((pos - start).distance < widget.minDragDistance) return;

      // Ultima difesa: se il punto di partenza del drag cade ancora su
      // file/cella, non attivare mai il marquee (evita `clear()` → flash vuoto).
      final safety = BoxHitTestResult();
      box.hitTest(safety, position: start);
      if (_hitTestPathTouchesIconOrLabel(safety)) {
        _startLocal = null;
        _marqueePointerId = null;
        _primaryDownGlobal = null;
        _marqueeActive = false;
        return;
      }

      final b = KeyboardModifierState.instance;
      final isCtrl = b.isCtrlOrMetaPressed;
      final isShift = b.isShiftPressed;

      Set<String>? initial;
      var type = SelectionDragType.replace;
      if (isCtrl) {
        initial = ctrl.selectedIds;
        type = SelectionDragType.invert;
      } else if (isShift) {
        initial = ctrl.selectedIds;
        type = SelectionDragType.additive;
      } else {
        ctrl.clear();
      }

      ctrl.startSelection(start, initialSelection: initial, type: type);
      _marqueeActive = true;
    }

    ctrl.updateSelection(pos, start);
  }

  void _onPointerDown(PointerDownEvent e) {
    if ((e.buttons & kSecondaryMouseButton) != 0) {
      // Right click: show empty-space menu only if the click isn't on a file item.
      final box =
          widget.marqueeKey!.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final result = BoxHitTestResult();
        box.hitTest(result, position: box.globalToLocal(e.position));
        final hitItem = _hitTestPathTouchesFile(result);
        if (!hitItem) {
          widget.onSecondaryTapDown?.call(
            TapDownDetails(globalPosition: e.position),
          );
        }
      } else {
        widget.onSecondaryTapDown?.call(
          TapDownDetails(globalPosition: e.position),
        );
      }
      return;
    }
    if ((e.buttons & kPrimaryButton) == 0) return;
    if (widget.selectionController == null || widget.marqueeKey == null) return;

    final box =
        widget.marqueeKey!.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      _primaryDownGlobal = null;
      _marqueePointerId = null;
      _startLocal = null;
      return;
    }

    // - [fileItem]: tutta la riga/cella → non è "sfondo"; su pointer up non deve
    //   chiamare [onPaneBackgroundPrimaryTap] (altrimenti azzera la selezione del [Listener]).
    // - Solo [fileToggleRegion] (icona/etichetta): non tracciare qui il marquee (compete col DnD).
    // - Padding della riga ma ancora sotto [fileItem]: sì marquee, senza clear sul tap corto.
    final hit = BoxHitTestResult();
    box.hitTest(hit, position: box.globalToLocal(e.position));
    final onFileRow = _hitTestPathTouchesFile(hit);
    final onIconOrLabel = _hitTestPathTouchesIconOrLabel(hit);
    _primaryDownOnCell =
        onFileRow || _MarqueeDragGuard.shouldSuppressGridMarquee;
    if (onIconOrLabel) {
      _primaryDownGlobal = null;
      _marqueePointerId = null;
      _startLocal = null;
      _marqueeActive = false;
      return;
    }
    _primaryDownGlobal = e.position;
    _marqueePointerId = e.pointer;
    _startLocal = box.globalToLocal(e.position);
    _marqueeActive = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _marqueePointerId) return;
    _applyMarqueeMove(e.position);
  }

  void _onPointerUp(PointerUpEvent e) {
    final forMarquee = e.pointer == _marqueePointerId;
    final tap =
        _primaryDownGlobal != null &&
        !_primaryDownOnCell &&
        !_marqueeActive &&
        (e.position - _primaryDownGlobal!).distance < widget.minDragDistance;

    if (forMarquee) {
      _finishMarqueePan();
    }

    _primaryDownGlobal = null;
    _primaryDownOnCell = false;

    if (tap) {
      final b = KeyboardModifierState.instance;
      if (!b.isCtrlOrMetaPressed && !b.isShiftPressed) {
        widget.onPaneBackgroundPrimaryTap?.call();
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer == _marqueePointerId) {
      _finishMarqueePan();
    }
    _primaryDownGlobal = null;
    _primaryDownOnCell = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectionController == null || widget.marqueeKey == null) {
      return GestureDetector(
        onTap: () {
          final b = KeyboardModifierState.instance;
          if (b.isCtrlOrMetaPressed || b.isShiftPressed) return;
          widget.onPaneBackgroundPrimaryTap?.call();
        },
        onSecondaryTapDown: widget.onSecondaryTapDown,
        behavior: HitTestBehavior.deferToChild,
        child: widget.child,
      );
    }

    // Listener (no PanGestureRecognizer) so super_drag_and_drop's
    // ImmediateMultiDragGestureRecognizer can win the arena on file cells.
    // translucent: deferToChild misses grid gaps (no child hit), so marquee
    // never saw pointer events on empty space between cells.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}

/// Drop target for folder rows/cells: highlight on hover + guard reset so the
/// next drag works after OS DnD (pointer-up may not reach Flutter listeners).
class _FolderDropTarget extends StatefulWidget {
  const _FolderDropTarget({required this.child, required this.onPerformDrop});

  final Widget child;
  final Future<void> Function(PerformDropEvent event) onPerformDrop;

  @override
  State<_FolderDropTarget> createState() => _FolderDropTargetState();
}

class _FolderDropTargetState extends State<_FolderDropTarget> {
  /// Never drive highlight via [setState] during native drag — rebuilding
  /// [DropRegion] detaches [RenderDropRegion] and breaks later drags / hover.
  final ValueNotifier<bool> _highlight = ValueNotifier<bool>(false);

  void _endNativeDnDGuards() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetPointerGuardsAfterNativeDrag();
    });
  }

  @override
  void dispose() {
    _highlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (DropOverEvent event) {
        if (!dropSessionAcceptsFileItemsLenient(event.session)) {
          if (_highlight.value) {
            _highlight.value = false;
          }
          return DropOperation.none;
        }
        final ops = event.session.allowedOperations;
        DropOperation op = DropOperation.none;
        if (ops.contains(DropOperation.move)) {
          op = DropOperation.move;
        } else if (ops.contains(DropOperation.copy)) {
          op = DropOperation.copy;
        }
        final want = op != DropOperation.none;
        if (_highlight.value != want) {
          _highlight.value = want;
        }
        return op;
      },
      onDropEnter: (_) {
        _highlight.value = true;
      },
      onDropLeave: (_) {
        _highlight.value = false;
      },
      onDropEnded: (_) {
        _highlight.value = false;
        _endNativeDnDGuards();
      },
      onPerformDrop: (PerformDropEvent event) async {
        try {
          await widget.onPerformDrop(event);
        } finally {
          _highlight.value = false;
          _endNativeDnDGuards();
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _highlight,
        builder: (context, hl, child) {
          return AnimatedContainer(
            duration: hl ? Duration.zero : const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: hl
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.52)
                  : Colors.transparent,
              border: hl
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.72),
                      width: 2,
                    )
                  : null,
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: widget.child,
        ),
      ),
    );
  }
}

class FileList extends StatelessWidget {
  final List<FileInfo> files;
  final String? selectedPath;
  final Set<String>? selectedFiles;
  final Set<String>? cutPaths;
  final Function(FileInfo) onFileSelected;
  final void Function(
    FileInfo file, {
    bool isCtrlPressed,
    bool isShiftPressed,
    bool forceNoModifiers,
  })?
  onFileSelectedWithModifiers;
  final Function(FileInfo)? onFileDoubleClick;
  final Function(FileInfo, Offset)? onFileRightClick;
  final Future<void> Function(FileInfo folder, PerformDropEvent event)?
  onFolderDrop;
  final ViewMode viewMode;
  final Function(ViewMode)? onViewModeChanged;
  final int
  gridZoomLevel; // 1-5, where 1 is most zoomed in (fewer columns), 5 is most zoomed out (more columns)
  final Function(int)? onZoomChanged; // Callback for zoom changes
  final SelectionController? selectionController;
  final GlobalKey? marqueeKey;
  final ScrollController? scrollController;
  final FileInfo? previewFile; // File currently selected for preview
  final bool showPreview; // Whether preview is enabled
  final bool showRightPanel; // Whether right panel is visible
  /// When the right panel is hidden (F6), show fast inline thumbnails (e.g. images)
  /// in place of the standard file icon.
  final bool inlinePreviewWhenRightPanelHidden;

  /// Primary click on empty area (grid background, etc.): clear selection.
  final VoidCallback? onPaneBackgroundPrimaryTap;

  /// Bumped after each native DnD session ends so [DragItemWidget] state /
  /// [WidgetSnapshotter] are recreated (fixes “only first drag works” on Linux).
  final int nativeDragSessionEpoch;

  const FileList({
    super.key,
    required this.files,
    this.selectedPath,
    this.selectedFiles,
    this.cutPaths,
    required this.onFileSelected,
    this.onFileSelectedWithModifiers,
    this.onFileDoubleClick,
    this.onFileRightClick,
    this.onFolderDrop,
    this.viewMode = ViewMode.list,
    this.onViewModeChanged,
    this.gridZoomLevel = 3,
    this.onZoomChanged,
    this.selectionController,
    this.marqueeKey,
    this.scrollController,
    this.previewFile,
    this.showPreview = true,
    this.showRightPanel = true,
    this.inlinePreviewWhenRightPanelHidden = true,
    this.onPaneBackgroundPrimaryTap,
    this.nativeDragSessionEpoch = 0,
  });

  void _invokeFileSelectedFromPointer(FileInfo file, int pointer) {
    if (onFileSelectedWithModifiers == null) {
      onFileSelected(file);
      return;
    }
    // Force immediate sync before checking modifiers
    KeyboardModifierState.instance.syncNow();
    final ctrlOrMeta = KeyboardModifierState.instance.isCtrlOrMetaPressed;
    final shift = KeyboardModifierState.instance.isShiftPressed;
    onFileSelectedWithModifiers!(
      file,
      isCtrlPressed: ctrlOrMeta,
      isShiftPressed: shift,
      forceNoModifiers: false,
    );
  }

  static final ValueNotifier<_DetailsColumnWidths> _detailsWidths =
      ValueNotifier<_DetailsColumnWidths>(
        const _DetailsColumnWidths(
          name: 0.46,
          size: 0.16,
          modified: 0.24,
          type: 0.14,
        ),
      );

  static bool _detailsWidthsLoaded = false;
  static Timer? _detailsWidthsSaveDebounce;

  static Future<void> _ensureDetailsWidthsLoaded() async {
    if (_detailsWidthsLoaded) return;
    _detailsWidthsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final n = prefs.getDouble('details_col_name');
      final s = prefs.getDouble('details_col_size');
      final m = prefs.getDouble('details_col_modified');
      final t = prefs.getDouble('details_col_type');
      if (n != null && s != null && m != null && t != null) {
        _detailsWidths.value = _DetailsColumnWidths(
          name: n,
          size: s,
          modified: m,
          type: t,
        );
      }
    } catch (_) {
      // Ignore preference load errors
    }
  }

  static void _scheduleSaveDetailsWidths(_DetailsColumnWidths w) {
    _detailsWidthsSaveDebounce?.cancel();
    _detailsWidthsSaveDebounce = Timer(
      const Duration(milliseconds: 180),
      () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('details_col_name', w.name);
          await prefs.setDouble('details_col_size', w.size);
          await prefs.setDouble('details_col_modified', w.modified);
          await prefs.setDouble('details_col_type', w.type);
        } catch (_) {
          // Ignore preference save errors
        }
      },
    );
  }

  String _formatSize(int bytes) => formatBytesBinary(bytes);

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  double _zoomT() => ((gridZoomLevel.clamp(1, 10) - 1) / 9.0);
  double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// 1 = più grande, 10 = più piccolo (coerente con griglia).
  double _rowScale() => _lerp(1.22, 0.82, _zoomT());

  bool _isImageFile(FileInfo file) {
    if (file.isDir) return false;
    final ext = file.name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  bool _isPdfFile(FileInfo file) {
    if (file.isDir) return false;
    final ext = file.name.split('.').last.toLowerCase();
    return ext == 'pdf';
  }

  static final Set<String> _thumbInFlight = <String>{};

  Future<void> _loadThumbnail(String filePath) async {
    if (_thumbInFlight.contains(filePath)) return;
    _thumbInFlight.add(filePath);
    try {
      final cached = await ThumbnailCacheService.getCachedThumbnail(filePath);
      if (cached != null) return;

      final f = File(filePath);
      if (!await f.exists()) return;

      final bytes = await f.readAsBytes();
      // Decode + resize using engine codec (fast, no extra deps).
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 160,
        targetHeight: 160,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return;
      await ThumbnailCacheService.saveThumbnail(
        filePath,
        data.buffer.asUint8List(),
      );
    } catch (_) {
      // Ignore decode errors and keep falling back to icon.
    } finally {
      _thumbInFlight.remove(filePath);
    }
  }

  Future<void> _loadPdfThumbnail(String filePath) async {
    if (_thumbInFlight.contains(filePath)) return;
    _thumbInFlight.add(filePath);
    try {
      final cached = await ThumbnailCacheService.getCachedThumbnail(filePath);
      if (cached != null) return;

      final doc = await PdfDocument.openFile(filePath);
      try {
        if (doc.pages.isEmpty) return;
        final page = doc.pages[0];
        final img = await page.render(width: 220, height: 220);
        if (img == null) return;
        try {
          final uiImage = await img.createImage();
          final data = await uiImage.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) return;
          await ThumbnailCacheService.saveThumbnail(
            filePath,
            data.buffer.asUint8List(),
          );
        } finally {
          img.dispose();
        }
      } finally {
        doc.dispose();
      }
    } catch (_) {
      // Ignore render errors.
    } finally {
      _thumbInFlight.remove(filePath);
    }
  }

  Widget _buildFileIcon(
    FileInfo file,
    BuildContext context, {
    double size = 64,
  }) {
    final tableLikeIcons =
        viewMode == ViewMode.list || viewMode == ViewMode.details;

    if (file.isDir) {
      return FutureBuilder<int?>(
        future: FolderIconService.getFolderColor(file.path),
        builder: (context, folderColorSnapshot) {
          final folderColor = folderColorSnapshot.data != null
              ? Color(folderColorSnapshot.data!)
              : null;
          return FutureBuilder<Map<String, dynamic>>(
            future: _loadFolderIconSettings(),
            builder: (context, snapshot) {
              // Automatically determine icon based on folder properties
              final autoIconName = FolderIconService.getFolderIconForPath(
                file.path,
                file.name,
                selectedPath,
              );
              // Use folder-specific color if available, otherwise use global color, then default
              final globalColor = snapshot.data?['color'] as Color?;
              final themeFolder = Theme.of(context)
                  .extension<AppVisualTheme>()
                  ?.folderIconColor;
              final effectiveColor = folderColor ??
                  globalColor ??
                  themeFolder ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);

              final iconData =
                  FolderIconService.availableIcons[autoIconName] ??
                  Icons.folder;
              // Stessa scala dei file (lista/dettagli): niente riduzione glyph o cartelle e nomi non si allineano.
              return RepaintBoundary(
                child: _build3DIcon(
                  context,
                  Icon(iconData, size: size, color: effectiveColor),
                  size,
                  flat: tableLikeIcons,
                  shadow: !tableLikeIcons,
                ),
              );
            },
          );
        },
      );
    }

    final inlinePreviewOn =
        !tableLikeIcons &&
        inlinePreviewWhenRightPanelHidden &&
        !showRightPanel &&
        showPreview;

    // Inline preview for the focused (selected) file only (keeps it responsive).
    if (inlinePreviewOn && _isImageFile(file)) {
      return FutureBuilder<String?>(
        future: ThumbnailCacheService.getCachedThumbnail(file.path),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return RepaintBoundary(
              child: _build3DIcon(
                context,
                Image.file(
                  File(snapshot.data!),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return FileIconService.buildFileIcon(
                      file.name,
                      context,
                      size: size,
                    );
                  },
                ),
                size,
                flat: tableLikeIcons,
              ),
            );
          }
          // Fire-and-forget thumbnail generation.
          unawaited(_loadThumbnail(file.path));
          return RepaintBoundary(
            child: _build3DIcon(
              context,
              FileIconService.buildFileIcon(file.name, context, size: size),
              size,
              flat: tableLikeIcons,
            ),
          );
        },
      );
    }

    if (inlinePreviewOn && _isPdfFile(file)) {
      return FutureBuilder<String?>(
        future: ThumbnailCacheService.getCachedThumbnail(file.path),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return RepaintBoundary(
              child: _build3DIcon(
                context,
                Image.file(
                  File(snapshot.data!),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return FileIconService.buildFileIcon(
                      file.name,
                      context,
                      size: size,
                    );
                  },
                ),
                size,
                flat: tableLikeIcons,
              ),
            );
          }
          unawaited(_loadPdfThumbnail(file.path));
          return RepaintBoundary(
            child: _build3DIcon(
              context,
              FileIconService.buildFileIcon(file.name, context, size: size),
              size,
              flat: tableLikeIcons,
            ),
          );
        },
      );
    }

    return RepaintBoundary(
      child: _build3DIcon(
        context,
        FileIconService.buildFileIcon(file.name, context, size: size),
        size,
        flat: tableLikeIcons,
      ),
    );
  }

  Widget _build3DIcon(
    BuildContext context,
    Widget icon,
    double size, {
    bool flat = false,
    bool shadow = false,
  }) {
    if (flat) {
      // Force a consistent "table cell" for icons (details/list):
      // every icon (Image/SVG/Icon) is centered within the same box.
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: FittedBox(
              fit: BoxFit.contain,
              child: IconTheme.merge(
                data: IconThemeData(size: size),
                child: icon,
              ),
            ),
          ),
        ),
      );
    }
    final vis = Theme.of(context).extension<AppVisualTheme>()?.iconShadowIntensity ?? 1.0;
    final themedShadow = shadow && vis > 0
        ? <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16 * vis.clamp(0.0, 1.0)),
              blurRadius: 8 * (0.35 + 0.65 * vis.clamp(0.0, 1.0)),
              spreadRadius: 0.2 * vis.clamp(0.0, 1.0),
              offset: Offset(0, 3 * vis.clamp(0.0, 1.0)),
            ),
          ]
        : const <BoxShadow>[];
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.1)
        ..rotateY(0.05),
      alignment: FractionalOffset.center,
      child: Container(
        decoration: BoxDecoration(boxShadow: themedShadow),
        child: icon,
      ),
    );
  }

  Future<Map<String, dynamic>> _loadFolderIconSettings() async {
    final icon = await FolderIconService.getSelectedIcon();
    final custom = await FolderIconService.getSelectedColorIsCustom();
    final colorValue = await FolderIconService.getSelectedColor();
    return {
      'icon': icon,
      // Colore globale da preferenze solo se l'utente l'ha scelto esplicitamente
      // (palette in Gestione temi); altrimenti si usa il tint dal [AppVisualTheme].
      'color': (custom && colorValue != null) ? Color(colorValue) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (files.isEmpty) {
      Widget emptyBody = SizedBox.expand(
        child: Center(child: Text(l10n.fileListEmpty)),
      );
      if (onZoomChanged != null) {
        emptyBody = Stack(
          children: [
            emptyBody,
            Positioned(
              bottom: 8,
              right: 8,
              child: _buildZoomControls(context),
            ),
          ],
        );
      }
      return _GridMarqueeShell(
        selectionController: selectionController,
        marqueeKey: marqueeKey,
        minDragDistance: 36,
        onPaneBackgroundPrimaryTap: onPaneBackgroundPrimaryTap,
        onSecondaryTapDown: onFileRightClick == null
            ? null
            : (details) {
                onFileRightClick!(
                  FileInfo(
                    name: '',
                    path: '',
                    size: 0,
                    modified: 0,
                    created: 0,
                    isDir: false,
                  ),
                  details.globalPosition,
                );
              },
        child: emptyBody,
      );
    }
    // Stessa fonte del [itemClicked]: evita un frame di evidenziazione “fantasma”
    // quando il genitore aggiorna [selectedFiles] un tick dopo il controller.
    final listenable = selectionController?.selectedListenable;
    Widget stackOrBody(Set<String> selectionPaths) {
      final body = viewMode == ViewMode.grid
          ? _buildGridView(selectionPaths)
          : _buildFileView(selectionPaths);
      if (onZoomChanged == null) return body;
      return Stack(
        children: [
          body,
          Positioned(bottom: 8, right: 8, child: _buildZoomControls(context)),
        ],
      );
    }

    if (listenable != null) {
      return ValueListenableBuilder<Set<String>>(
        valueListenable: listenable,
        builder: (context, selectionPaths, _) => stackOrBody(selectionPaths),
      );
    }
    return stackOrBody(selectedFiles ?? {});
  }

  Widget _buildFileView(Set<String> selectionPaths) {
    switch (viewMode) {
      case ViewMode.list:
        return _buildListView(selectionPaths);
      case ViewMode.grid:
        return _buildGridView(selectionPaths);
      case ViewMode.details:
        return _buildDetailsView(selectionPaths);
    }
  }

  Widget _buildDraggableFileItem({
    required FileInfo file,
    required Widget child,
    required BuildContext context,
    required Set<String> selectionPaths,
  }) {
    // Get selected files if multiple selection, otherwise use single file
    final filesToDrag =
        selectionPaths.isNotEmpty && selectionPaths.contains(file.path)
        ? selectionPaths
              .map((p) => File(p))
              .where((f) => entityPathExistsSync(f.path))
              .toList()
        : [File(file.path)];

    if (filesToDrag.isEmpty || !entityPathExistsSync(filesToDrag.first.path)) {
      return child;
    }

    // Get file paths as strings for drag and drop
    final filePaths = filesToDrag.map((f) => f.path).toList();

    // Use super_drag_and_drop for external drag support
    // This provides proper OS-level drag support with Wayland compatibility
    return _SuperDragHandler(
      filePaths: filePaths,
      file: file,
      filesToDrag: filesToDrag,
      nativeDragSessionEpoch: nativeDragSessionEpoch,
      child: child,
    );
  }

  Widget _buildListView(Set<String> selectionPaths) {
    final s = _rowScale();
    final iconSize = 40.0 * s;
    final padV = (10.0 * s).clamp(6.0, 14.0);
    final titleFont = 16.0 * s;
    final subtitleFont = 13.0 * s;
    return _GridMarqueeShell(
      selectionController: selectionController,
      marqueeKey: marqueeKey,
      minDragDistance: 36,
      onPaneBackgroundPrimaryTap: onPaneBackgroundPrimaryTap,
      onSecondaryTapDown: (details) {
        onFileRightClick?.call(
          FileInfo(
            name: '',
            path: '',
            size: 0,
            modified: 0,
            created: 0,
            isDir: false,
          ),
          details.globalPosition,
        );
      },
      child: ScrollConfiguration(
        behavior: const _GridScrollBehavior(),
        child: ListView.builder(
          itemCount: files.length,
          cacheExtent: 1000, // Increase cache for better performance
          addAutomaticKeepAlives:
              false, // Don't keep items alive to save memory
          addRepaintBoundaries: true, // Add repaint boundaries automatically
          itemBuilder: (context, index) {
            final file = files[index];
            final isSelected = selectionPaths.contains(file.path);
            final isCut = cutPaths?.contains(file.path) ?? false;
            final listTile = RepaintBoundary(
              child: MetaData(
                metaData: _HitTag.fileItem,
                behavior: HitTestBehavior.opaque,
                child: SelectionContainer.disabled(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: padV / 2,
                    ),
                    leading: _ToggleRegion(
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: _buildFileIcon(file, context, size: iconSize),
                      ),
                    ),
                    title: _ToggleRegion(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(
                                fontSize: titleFont,
                                fontFamily: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              file.isDir
                                  ? AppLocalizations.of(
                                      context,
                                    ).fileListTypeFolder
                                  : '${_formatSize(file.size)} • ${_formatDate(file.modified)}',
                              style: TextStyle(
                                fontSize: subtitleFont,
                                fontFamily: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    subtitle: null,
                    selected: isSelected,
                    trailing: file.isDir
                        ? const Icon(Icons.chevron_right)
                        : null,
                  ),
                ),
              ),
            );

            // SelectableItem for marquee selection (inside draggable)
            Widget finalWidget = isCut
                ? Opacity(opacity: 0.45, child: listTile)
                : listTile;
            if (selectionController != null && marqueeKey != null) {
              // Keep SelectableItem only for marquee bounds.
              // La selezione con click è in [_FileRowClickSessionWidget] sopra il drag.
              finalWidget = SelectableItem(
                id: file.path,
                controller: selectionController!,
                marqueeKey: marqueeKey!,
                selectedBuilder: (context, child, isSelected) => child,
                child: finalWidget,
              );
            }

            Widget row = _FileRowClickSessionWidget(
              key: ValueKey<String>('rowptr_${file.path}'),
              file: file,
              hitTestIconOrLabel: _hitTestGlobalOnIconOrLabel,
              onSelectWithPointer: _invokeFileSelectedFromPointer,
              onOpenOnDoubleClick: onFileDoubleClick != null
                  ? () => onFileDoubleClick!(file)
                  : null,
              onRightClick: onFileRightClick,
              child: _buildDraggableFileItem(
                file: file,
                child: finalWidget,
                context: context,
                selectionPaths: selectionPaths,
              ),
            );
            if (file.isDir && onFolderDrop != null) {
              row = _FolderDropTarget(
                onPerformDrop: (event) async {
                  await LoggingService.dragDrop('folderDrop perform begin', {
                    'dest_dir': file.path,
                    'session_items': event.session.items.length,
                  });
                  await onFolderDrop!(file, event);
                  await LoggingService.dragDrop('folderDrop perform end', {
                    'dest_dir': file.path,
                  });
                },
                child: row,
              );
            }
            return row;
          },
        ),
      ),
    );
  }

  Widget _buildGridView(Set<String> selectionPaths) {
    // Calculate crossAxisCount based on zoom level (1-10)
    // Level 1: 2 columns (most zoomed in)
    // Level 2: 3 columns
    // Level 3: 4 columns
    // Level 4: 5 columns
    // Level 5: 6 columns
    // Level 6: 7 columns
    // Level 7: 8 columns
    // Level 8: 9 columns
    // Level 9: 10 columns
    // Level 10: 11 columns (most zoomed out)
    final crossAxisCount = gridZoomLevel.clamp(1, 10) + 1;

    return _GridMarqueeShell(
      selectionController: selectionController,
      marqueeKey: marqueeKey,
      minDragDistance: 36,
      onPaneBackgroundPrimaryTap: onPaneBackgroundPrimaryTap,
      onSecondaryTapDown: (details) {
        onFileRightClick?.call(
          FileInfo(
            name: '',
            path: '',
            size: 0,
            modified: 0,
            created: 0,
            isDir: false,
          ),
          details.globalPosition,
        );
      },
      child: ScrollConfiguration(
        behavior: const _GridScrollBehavior(),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          padding: const EdgeInsets.all(4),
          cacheExtent: 1000, // Increase cache for better performance
          addAutomaticKeepAlives:
              false, // Don't keep items alive to save memory
          addRepaintBoundaries: true, // Add repaint boundaries automatically
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final isSelected = selectionPaths.contains(file.path);
            final isCut = cutPaths?.contains(file.path) ?? false;
            // [Listener] opaque + [SizedBox.expand]: tutta la cella (icona + etichetta) è cliccabile.
            final gridCellBody = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: SelectionContainer.disabled(
                // [ColoredBox] trasparente: il [Column] con mainAxisAlignment.center non
                // copre con i figli tutta l’altezza della cella; senza questo il hit-test
                // “passa” alla griglia sotto e Ctrl+click sembra deselezionare.
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Color(0x00000000)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Center(
                          child: _ToggleRegion(
                            child: _buildFileIcon(file, context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        _ToggleRegion(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Text(
                                file.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.fontSize ??
                                      (gridZoomLevel >= 8
                                          ? 8
                                          : (gridZoomLevel >= 6
                                                ? 9
                                                : (gridZoomLevel >= 4
                                                      ? 10
                                                      : (gridZoomLevel >= 2
                                                            ? 11
                                                            : 12)))),
                                  fontFamily: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontFamily,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  backgroundColor: isSelected
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            final gridCell = RepaintBoundary(
              key: ValueKey('${file.path}_$index'),
              child: MetaData(
                metaData: _HitTag.fileItem,
                behavior: HitTestBehavior.opaque,
                child: isCut
                    ? Opacity(
                        opacity: 0.45,
                        child: SizedBox.expand(child: gridCellBody),
                      )
                    : SizedBox.expand(child: gridCellBody),
              ),
            );

            Widget finalWidget = gridCell;
            if (selectionController != null && marqueeKey != null) {
              finalWidget = SelectableItem(
                id: file.path,
                controller: selectionController!,
                marqueeKey: marqueeKey!,
                selectedBuilder: (context, child, isSelected) => child,
                child: finalWidget,
              );
            }

            Widget cellChild = _FileRowClickSessionWidget(
              key: ValueKey<String>('gridptr_${file.path}'),
              file: file,
              gridRustSync: selectionController != null,
              hitTestIconOrLabel: _hitTestGlobalOnIconOrLabel,
              onSelectWithPointer: _invokeFileSelectedFromPointer,
              onOpenOnDoubleClick: onFileDoubleClick != null
                  ? () => onFileDoubleClick!(file)
                  : null,
              onRightClick: onFileRightClick,
              child: _buildDraggableFileItem(
                file: file,
                child: finalWidget,
                context: context,
                selectionPaths: selectionPaths,
              ),
            );
            if (file.isDir && onFolderDrop != null) {
              cellChild = _FolderDropTarget(
                onPerformDrop: (event) async {
                  await LoggingService.dragDrop('folderDrop perform begin', {
                    'dest_dir': file.path,
                    'session_items': event.session.items.length,
                  });
                  await onFolderDrop!(file, event);
                  await LoggingService.dragDrop('folderDrop perform end', {
                    'dest_dir': file.path,
                  });
                },
                child: cellChild,
              );
            }
            return cellChild;
          },
        ),
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: gridZoomLevel > 1 && onZoomChanged != null
                ? () => onZoomChanged!(gridZoomLevel - 1)
                : null,
            tooltip: 'Zoom out',
            iconSize: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${gridZoomLevel}/10',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: gridZoomLevel < 10 && onZoomChanged != null
                ? () => onZoomChanged!(gridZoomLevel + 1)
                : null,
            tooltip: 'Zoom in',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(Set<String> selectionPaths) {
    return _GridMarqueeShell(
      selectionController: selectionController,
      marqueeKey: marqueeKey,
      minDragDistance: 36,
      onPaneBackgroundPrimaryTap: onPaneBackgroundPrimaryTap,
      onSecondaryTapDown: (details) {
        onFileRightClick?.call(
          FileInfo(
            name: '',
            path: '',
            size: 0,
            modified: 0,
            created: 0,
            isDir: false,
          ),
          details.globalPosition,
        );
      },
      // DataTable non supporta bene bounds per marquee selection: usiamo righe custom
      // con [SelectableItem] come nella griglia.
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final s = _rowScale();
          final iconSize = 18.0 * s;
          final padV = (10.0 * s).clamp(6.0, 14.0);
          return LayoutBuilder(
            builder: (context, constraints) {
              if (!_detailsWidthsLoaded) {
                // fire-and-forget, then rebuild via notifier if values change
                unawaited(_ensureDetailsWidthsLoaded());
              }
              final theme = Theme.of(context);
              final outline = theme.colorScheme.outline.withValues(alpha: 0.25);
              final headerBg = theme.colorScheme.surfaceContainerHighest;

              // Column widths (table-like). These are kept stable and scroll horizontally if needed.
              final minTableWidth = 920.0;
              final tableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth.clamp(minTableWidth, double.infinity)
                  : minTableWidth;
              return ValueListenableBuilder<_DetailsColumnWidths>(
                valueListenable: _detailsWidths,
                builder: (context, widths, _) {
                  var nameW = tableWidth * widths.name;
                  var sizeW = tableWidth * widths.size;
                  var modW = tableWidth * widths.modified;
                  var typeW = tableWidth * widths.type;

                  // Enforce minimums so rows stay readable.
                  const minName = 260.0;
                  const minSize = 120.0;
                  const minMod = 170.0;
                  const minType = 120.0;
                  final total = nameW + sizeW + modW + typeW;
                  if (total > 0) {
                    nameW = nameW.clamp(
                      minName,
                      tableWidth - minSize - minMod - minType,
                    );
                    sizeW = sizeW.clamp(
                      minSize,
                      tableWidth - minName - minMod - minType,
                    );
                    modW = modW.clamp(
                      minMod,
                      tableWidth - minName - minSize - minType,
                    );
                    typeW = (tableWidth - nameW - sizeW - modW).clamp(
                      minType,
                      tableWidth,
                    );
                  }

                  Widget headerCell(
                    String text,
                    double w, {
                    TextAlign align = TextAlign.left,
                  }) {
                    return SizedBox(
                      width: w,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Text(
                          text,
                          textAlign: align,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }

                  Widget vSepDrag({required void Function(double dx) onDrag}) =>
                      SizedBox(
                        width: 8,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
                            child: Center(
                              child: Container(
                                width: 1,
                                height: 26,
                                color: outline,
                              ),
                            ),
                          ),
                        ),
                      );

                  Widget vSepLine() =>
                      VerticalDivider(width: 1, thickness: 1, color: outline);

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        height: constraints.maxHeight.isFinite
                            ? constraints.maxHeight
                            : MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            // Header (table-like)
                            Container(
                              decoration: BoxDecoration(
                                color: headerBg,
                                border: Border(
                                  top: BorderSide(color: outline),
                                  bottom: BorderSide(color: outline),
                                ),
                              ),
                              child: Row(
                                children: [
                                  headerCell(l10n.tableColumnName, nameW),
                                  vSepDrag(
                                    onDrag: (dx) {
                                      // Drag adjusts name vs size.
                                      final delta = dx / tableWidth;
                                      final next = widths.shift(
                                        dName: delta,
                                        dSize: -delta,
                                      );
                                      _detailsWidths.value = next;
                                      _scheduleSaveDetailsWidths(next);
                                    },
                                  ),
                                  headerCell(l10n.tableColumnSize, sizeW),
                                  vSepDrag(
                                    onDrag: (dx) {
                                      final delta = dx / tableWidth;
                                      final next = widths.shift(
                                        dSize: delta,
                                        dModified: -delta,
                                      );
                                      _detailsWidths.value = next;
                                      _scheduleSaveDetailsWidths(next);
                                    },
                                  ),
                                  headerCell(l10n.tableColumnModified, modW),
                                  vSepDrag(
                                    onDrag: (dx) {
                                      final delta = dx / tableWidth;
                                      final next = widths.shift(
                                        dModified: delta,
                                        dType: -delta,
                                      );
                                      _detailsWidths.value = next;
                                      _scheduleSaveDetailsWidths(next);
                                    },
                                  ),
                                  headerCell(l10n.tableColumnType, typeW),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  final file = files[index];
                                  final isSelected = selectionPaths.contains(
                                    file.path,
                                  );

                                  final baseRowBody = Container(
                                    color: isSelected
                                        ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withValues(alpha: 0.35)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: nameW,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: padV,
                                            ),
                                            child: Row(
                                              children: [
                                                _ToggleRegion(
                                                  child: SizedBox(
                                                    width: iconSize,
                                                    height: iconSize,
                                                    child: _buildFileIcon(
                                                      file,
                                                      context,
                                                      size: iconSize,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _ToggleRegion(
                                                    child: Text(
                                                      file.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        vSepLine(),
                                        SizedBox(
                                          width: sizeW,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: padV,
                                            ),
                                            child: Text(
                                              file.isDir
                                                  ? '—'
                                                  : _formatSize(file.size),
                                            ),
                                          ),
                                        ),
                                        vSepLine(),
                                        SizedBox(
                                          width: modW,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: padV,
                                            ),
                                            child: Text(
                                              _formatDate(file.modified),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        vSepLine(),
                                        SizedBox(
                                          width: typeW,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: padV,
                                            ),
                                            child: Text(
                                              file.isDir
                                                  ? l10n.fileListTypeFolder
                                                  : l10n.fileListTypeFile,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  final rowBody = MetaData(
                                    metaData: _HitTag.fileItem,
                                    behavior: HitTestBehavior.opaque,
                                    child: SelectionContainer.disabled(
                                      child: baseRowBody,
                                    ),
                                  );

                                  // Selectable + Draggable + Folder drop.
                                  final isCut =
                                      cutPaths?.contains(file.path) ?? false;
                                  Widget finalWidget = isCut
                                      ? Opacity(opacity: 0.45, child: rowBody)
                                      : rowBody;
                                  if (selectionController != null &&
                                      marqueeKey != null) {
                                    // Keep SelectableItem only for marquee bounds.
                                    finalWidget = SelectableItem(
                                      id: file.path,
                                      controller: selectionController!,
                                      marqueeKey: marqueeKey!,
                                      selectedBuilder:
                                          (context, child, isSelected) => child,
                                      child: finalWidget,
                                    );
                                  }

                                  Widget result = _FileRowClickSessionWidget(
                                    key: ValueKey<String>('detailptr_${file.path}'),
                                    file: file,
                                    hitTestIconOrLabel: _hitTestGlobalOnIconOrLabel,
                                    onSelectWithPointer:
                                        _invokeFileSelectedFromPointer,
                                    onOpenOnDoubleClick: onFileDoubleClick != null
                                        ? () => onFileDoubleClick!(file)
                                        : null,
                                    onRightClick: onFileRightClick,
                                    child: _buildDraggableFileItem(
                                      file: file,
                                      child: finalWidget,
                                      context: context,
                                      selectionPaths: selectionPaths,
                                    ),
                                  );
                                  if (file.isDir && onFolderDrop != null) {
                                    result = _FolderDropTarget(
                                      onPerformDrop: (event) async {
                                        await LoggingService.dragDrop(
                                          'folderDrop perform begin',
                                          {
                                            'dest_dir': file.path,
                                            'session_items':
                                                event.session.items.length,
                                          },
                                        );
                                        await onFolderDrop!(file, event);
                                        await LoggingService.dragDrop(
                                          'folderDrop perform end',
                                          {'dest_dir': file.path},
                                        );
                                      },
                                      child: result,
                                    );
                                  }
                                  return result;
                                },
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
          );
        },
      ),
    );
  }
}

@immutable
class _DetailsColumnWidths {
  const _DetailsColumnWidths({
    required this.name,
    required this.size,
    required this.modified,
    required this.type,
  });

  final double name;
  final double size;
  final double modified;
  final double type;

  _DetailsColumnWidths shift({
    double dName = 0,
    double dSize = 0,
    double dModified = 0,
    double dType = 0,
  }) {
    var n = name + dName;
    var s = size + dSize;
    var m = modified + dModified;
    var t = type + dType;

    // Keep totals stable-ish and clamp to reasonable fractional bounds.
    n = n.clamp(0.20, 0.70);
    s = s.clamp(0.10, 0.35);
    m = m.clamp(0.15, 0.45);
    t = t.clamp(0.10, 0.35);

    final sum = n + s + m + t;
    if (sum <= 0) {
      return this;
    }
    // Normalize to 1.0
    n /= sum;
    s /= sum;
    m /= sum;
    t = 1.0 - n - s - m;
    return _DetailsColumnWidths(name: n, size: s, modified: m, type: t);
  }
}

/// OS-level drag via [super_drag_and_drop](https://pub.dev/packages/super_drag_and_drop):
/// [DragItemWidget] supplies [DragItem]; [DraggableWidget] defines the hit target (package docs).
class _SuperDragHandler extends StatelessWidget {
  final List<String> filePaths;
  final FileInfo file;
  final List<File> filesToDrag;
  final int nativeDragSessionEpoch;
  final Widget child;

  const _SuperDragHandler({
    required this.filePaths,
    required this.file,
    required this.filesToDrag,
    required this.nativeDragSessionEpoch,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final previewLabel = filesToDrag.length > 1
        ? '${filesToDrag.length} items'
        : file.name;
    return DragItemWidget(
      key: ValueKey<Object>('${file.path}\u0000$nativeDragSessionEpoch'),
      dragBuilder: (context, _) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  file.isDir ? Icons.folder : Icons.insert_drive_file,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    previewLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      // Provide the drag item when drag starts
      dragItemProvider: (request) async {
        try {
          resetPointerGuardsAfterNativeDrag();
          await LoggingService.dragDrop('dragItemProvider enter', {
            'primary_name': file.name,
            'primary_path': file.path,
            'paths_arg_count': filePaths.length,
            'files_to_drag_count': filesToDrag.length,
          });
          await LoggingService.dragDrop('Drag started', {
            'file_paths_count': filePaths.length,
            'file_paths': filePaths,
          });

          // Verify files exist before starting drag
          final validFiles = <String>[];
          final missingPaths = <String>[];
          for (final filePath in filePaths) {
            if (entityPathExistsSync(filePath)) {
              validFiles.add(filePath);
            } else {
              missingPaths.add(filePath);
            }
          }
          if (missingPaths.isNotEmpty) {
            await LoggingService.dragDrop('paths missing on disk', {
              'missing_count': missingPaths.length,
              'missing_sample': missingPaths.take(5).toList(),
            });
          }

          if (validFiles.isEmpty) {
            await LoggingService.warning(
              'DragAndDrop',
              'No valid files found, aborting drag',
              {'original_paths': filePaths},
            );
            resetPointerGuardsAfterNativeDrag();
            return null;
          }

          // DragItem: URIs for cross-app drops; localData for in-app DropRegion (per package docs).
          final item = DragItem(
            suggestedName: validFiles.length == 1
                ? path.basename(validFiles.first)
                : null,
            localData: List<String>.from(validFiles),
          );

          // CRITICAL: Format URIs correctly for text/uri-list MIME type
          // Each file must be converted to file:///absolute/path format
          // super_drag_and_drop expects a List<String> containing URIs
          final uriList = <String>[];

          for (final filePath in validFiles) {
            // Ensure absolute path
            final absolutePath = path.isAbsolute(filePath)
                ? filePath
                : path.absolute(filePath);

            // Windows drive letters need Uri.file(..., windows: true)
            final fileUri = Uri.file(absolutePath, windows: Platform.isWindows);
            final uriString = fileUri.toString();

            if (!uriString.startsWith('file:')) {
              await LoggingService.error(
                'DragAndDrop',
                'URI format incorrect',
                {'uri': uriString, 'expected_format': 'file: URL'},
              );
              continue;
            }

            uriList.add(uriString);

            await LoggingService.dragDrop('URI created', {
              'original_path': filePath,
              'absolute_path': absolutePath,
              'uri': uriString,
            });
          }

          // CRITICAL: Set data as List<String> with text/uri-list MIME type
          // Use Formats.fileUri() for each URI - this handles the MIME type correctly
          // Formats.fileUri() automatically provides text/uri-list format
          if (uriList.isEmpty) {
            await LoggingService.warning(
              'DragAndDrop',
              'uriList empty after URI loop, aborting drag',
              {'valid_files': validFiles},
            );
            resetPointerGuardsAfterNativeDrag();
            return null;
          }
          for (final uriString in uriList) {
            final uri = Uri.parse(uriString);
            item.add(Formats.fileUri(uri));
          }

          await LoggingService.dragDrop('DragItem created', {
            'total_files': uriList.length,
            'uris': uriList,
            'mime_type': 'text/uri-list',
            'data_format': 'Formats.fileUri() for each URI',
            'drag_preview': 'dragBuilder',
          });

          await LoggingService.dragDrop('dragItemProvider return item', {
            'uri_count': uriList.length,
          });
          _attachDragSessionCleanup(request);
          return item;
        } catch (e, st) {
          await LoggingService.error(
            'DragAndDrop',
            'dragItemProvider failed: $e',
            {'file': file.path},
            st,
          );
          resetPointerGuardsAfterNativeDrag();
          return null;
        }
      },
      // Allow copy and move operations
      allowedOperations: () => [DropOperation.copy, DropOperation.move],
      // DraggableWidget represents the actual draggable area
      child: DraggableWidget(
        // Full cell participates in hit test so drag starts reliably (files + folders).
        hitTestBehavior: HitTestBehavior.opaque,
        // Start OS drag only when user is actually on icon/label region.
        // This keeps "empty" parts of a dense grid usable for marquee selection.
        isLocationDraggable: (globalPosition) {
          // Con modificatore, niente competizione col [ImmediateMultiDragGestureRecognizer]:
          // il click sulla cella/riga va tutto al [Listener] interno (selezione affidabile).
          final b = KeyboardModifierState.instance;
          if (b.isCtrlOrMetaPressed || b.isShiftPressed) {
            return false;
          }
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || !box.attached) return false;
          final local = box.globalToLocal(globalPosition);
          final result = BoxHitTestResult();
          box.hitTest(result, position: local);
          return _hitTestPathTouchesIconOrLabel(result);
        },
        child: child,
      ),
    );
  }
}
