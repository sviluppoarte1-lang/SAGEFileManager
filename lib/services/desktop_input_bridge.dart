import 'package:flutter/services.dart';

import 'package:filemanager/services/desktop_session_service.dart';

/// Traccia Ctrl/Meta/Shift da [KeyDownEvent]/[KeyUpEvent] (flusso tastiera reale).
/// La selezione multipla manuale (Ctrl+click) deve basarsi su questo, non su
/// [HardwareKeyboard.syncKeyboardState] al momento del click.
class DesktopInputBridge {
  DesktopInputBridge._();

  static final DesktopInputBridge instance = DesktopInputBridge._();

  /// Modificatori visti come premuti (KeyDown → add, KeyUp → remove).
  final Set<LogicalKeyboardKey> _heldModifiers = <LogicalKeyboardKey>{};

  /// Include le pseudo-key [LogicalKeyboardKey.control] / [meta] (unione L/R).
  bool get stickyCtrlOrMeta =>
      _heldModifiers.contains(LogicalKeyboardKey.control) ||
      _heldModifiers.contains(LogicalKeyboardKey.controlLeft) ||
      _heldModifiers.contains(LogicalKeyboardKey.controlRight) ||
      _heldModifiers.contains(LogicalKeyboardKey.meta) ||
      _heldModifiers.contains(LogicalKeyboardKey.metaLeft) ||
      _heldModifiers.contains(LogicalKeyboardKey.metaRight);

  bool get stickyShift =>
      _heldModifiers.contains(LogicalKeyboardKey.shift) ||
      _heldModifiers.contains(LogicalKeyboardKey.shiftLeft) ||
      _heldModifiers.contains(LogicalKeyboardKey.shiftRight);

  /// Da [HardwareKeyboard.addHandler]: unico aggiornamento di [_heldModifiers].
  bool ingestHardwareKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _applyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _applyUp(event.logicalKey);
    }
    return false;
  }

  void _applyDown(LogicalKeyboardKey k) {
    if (k == LogicalKeyboardKey.control ||
        k == LogicalKeyboardKey.controlLeft ||
        k == LogicalKeyboardKey.controlRight ||
        k == LogicalKeyboardKey.meta ||
        k == LogicalKeyboardKey.metaLeft ||
        k == LogicalKeyboardKey.metaRight ||
        k == LogicalKeyboardKey.shift ||
        k == LogicalKeyboardKey.shiftLeft ||
        k == LogicalKeyboardKey.shiftRight) {
      _heldModifiers.add(k);
    }
  }

  void _applyUp(LogicalKeyboardKey k) {
    _heldModifiers.remove(k);
  }

  /// Unione contatore tasti + stato engine (dopo eventuale sync).
  bool effectiveCtrlOrMeta() {
    final hw = HardwareKeyboard.instance;
    return stickyCtrlOrMeta ||
        hw.isControlPressed ||
        hw.isMetaPressed;
  }

  bool effectiveShift() {
    final hw = HardwareKeyboard.instance;
    return stickyShift || hw.isShiftPressed;
  }

  /// Su Wayland richiamare spesso aiuta il client GTK a ripristinare i modificatori.
  static bool get shouldSyncKeyboardEachFrame =>
      DesktopSessionService.isWayland;
}
