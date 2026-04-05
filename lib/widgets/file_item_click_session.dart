import 'package:flutter/foundation.dart';

/// Istanza dedicata per **un** elemento della lista/griglia: distingue tap singolo
/// e doppio tap sul modello desktop (tutto su **pointer up**), senza stato statico globale.
///
/// Secondo up entro [doubleTapMaxInterval] dal precedente up che ha eseguito [select]
/// viene trattato come doppio tap e chiama [openOnDouble] senza ripetere [select].
class FileItemClickSession {
  FileItemClickSession({
    this.doubleTapMaxInterval = const Duration(milliseconds: 300),
  });

  final Duration doubleTapMaxInterval;

  DateTime? _lastSelectUpTime;

  /// Chiamare solo quando il movimento down→up è classificato come click (slop).
  void onPrimaryUpClick({
    required VoidCallback select,
    VoidCallback? openOnDouble,
  }) {
    if (openOnDouble == null) {
      select();
      return;
    }
    final now = DateTime.now();
    if (_lastSelectUpTime != null &&
        now.difference(_lastSelectUpTime!) <= doubleTapMaxInterval) {
      _lastSelectUpTime = null;
      openOnDouble();
      return;
    }
    _lastSelectUpTime = now;
    select();
  }

  void reset() {
    _lastSelectUpTime = null;
  }
}
