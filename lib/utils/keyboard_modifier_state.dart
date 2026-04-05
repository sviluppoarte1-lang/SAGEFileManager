import 'package:flutter/services.dart';

class KeyboardModifierState {
  KeyboardModifierState._();

  static final KeyboardModifierState instance = KeyboardModifierState._();

  final Set<LogicalKeyboardKey> _heldModifiers = <LogicalKeyboardKey>{};

  int _lastCtrlPressTime = 0;
  int _lastShiftPressTime = 0;
  int _lastMetaPressTime = 0;

  static const int _recentThresholdMs = 200;

  bool _initialized = false;

  void ensureSynced() {
    if (_initialized) return;
    _initialized = true;
    HardwareKeyboard.instance.addHandler((KeyEvent event) {
      if (event is KeyDownEvent) {
        _applyDown(event.logicalKey);
      } else if (event is KeyUpEvent) {
        _applyUp(event.logicalKey);
      }
      return false;
    });
  }

  void _applyDown(LogicalKeyboardKey key) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      _heldModifiers.add(key);
      _lastCtrlPressTime = now;
      print('DEBUG KEY_DOWN: Ctrl pressed at $now');
    } else if (key == LogicalKeyboardKey.meta ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight) {
      _heldModifiers.add(key);
      _lastMetaPressTime = now;
    } else if (key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      _heldModifiers.add(key);
      _lastShiftPressTime = now;
    }
  }

  void _applyUp(LogicalKeyboardKey key) {
    final wasCtrl =
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight;
    _heldModifiers.remove(key);
    if (wasCtrl) {
      print(
        'DEBUG KEY_UP: Ctrl released, _lastCtrlPressTime=$_lastCtrlPressTime',
      );
    }
  }

  void syncNow() {
    final hw = HardwareKeyboard.instance;

    try {
      hw.syncKeyboardState();
    } catch (_) {}

    final keys = hw.logicalKeysPressed;

    print('DEBUG syncNow: keysPressed=${keys.toList()}');

    _heldModifiers.clear();

    for (final key in keys) {
      if (key == LogicalKeyboardKey.control ||
          key == LogicalKeyboardKey.controlLeft ||
          key == LogicalKeyboardKey.controlRight ||
          key == LogicalKeyboardKey.meta ||
          key == LogicalKeyboardKey.metaLeft ||
          key == LogicalKeyboardKey.metaRight ||
          key == LogicalKeyboardKey.shift ||
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight) {
        _heldModifiers.add(key);
      }
    }
  }

  bool _wasRecentlyPressed(int lastPressTime) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastPressTime) < _recentThresholdMs;
  }

  bool get isCtrlPressed {
    syncNow();
    final hw = HardwareKeyboard.instance;
    final held =
        _heldModifiers.contains(LogicalKeyboardKey.control) ||
        _heldModifiers.contains(LogicalKeyboardKey.controlLeft) ||
        _heldModifiers.contains(LogicalKeyboardKey.controlRight);
    final enginePressed = hw.isControlPressed;
    final recent = _wasRecentlyPressed(_lastCtrlPressTime);
    final result = held || enginePressed || recent;

    if (result) {
      print(
        'DEBUG isCtrlPressed: held=$held, engine=$enginePressed, recent=$recent (lastPressTime=$_lastCtrlPressTime)',
      );
    }
    return result;
  }

  bool get isShiftPressed {
    syncNow();
    final hw = HardwareKeyboard.instance;
    final held =
        _heldModifiers.contains(LogicalKeyboardKey.shift) ||
        _heldModifiers.contains(LogicalKeyboardKey.shiftLeft) ||
        _heldModifiers.contains(LogicalKeyboardKey.shiftRight);
    final enginePressed = hw.isShiftPressed;
    final recent = _wasRecentlyPressed(_lastShiftPressTime);
    final result = held || enginePressed || recent;

    if (result) {
      print(
        'DEBUG isShiftPressed: held=$held, engine=$enginePressed, recent=$recent',
      );
    }
    return result;
  }

  bool get isMetaPressed {
    syncNow();
    final hw = HardwareKeyboard.instance;
    return _heldModifiers.contains(LogicalKeyboardKey.meta) ||
        _heldModifiers.contains(LogicalKeyboardKey.metaLeft) ||
        _heldModifiers.contains(LogicalKeyboardKey.metaRight) ||
        hw.isMetaPressed ||
        _wasRecentlyPressed(_lastMetaPressTime);
  }

  bool get isCtrlOrMetaPressed => isCtrlPressed || isMetaPressed;

  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _applyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _applyUp(event.logicalKey);
    }
    return false;
  }

  void clear() {
    _heldModifiers.clear();
    _lastCtrlPressTime = 0;
    _lastShiftPressTime = 0;
    _lastMetaPressTime = 0;
  }
}
