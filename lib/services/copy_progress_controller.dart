import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Stato dettagliato copia: notifiche frequenti ma isolate da tutto il resto dell'UI.
class CopyProgressStats extends ChangeNotifier {
  String? sourceName;
  String? destName;
  /// Titolo riga in alto (null = stringa predefinita «copia»).
  String? panelTitle;
  IconData leadingIcon = Icons.copy;
  /// Cartella da aggiornare in lista durante la copia (es. destinazione incolla).
  String? destDirectoryPath;
  int totalBytes = 0;
  int copiedBytes = 0;
  double speedBytesPerSecond = 0;
  String? currentFile;
  bool cancelRequested = false;

  DateTime? _speedLastTime;
  int? _speedLastBytes;

  DateTime? _lastCopyProgressNotify;
  String? _lastThrottledFile;
  int? _lastNotifiedCopiedBytes;

  void begin({
    required String sourceName,
    required String destName,
    String? destDirectoryPath,
    int totalBytes = 0,
    String? panelTitle,
    IconData leadingIcon = Icons.copy,
  }) {
    cancelRequested = false;
    this.sourceName = sourceName;
    this.destName = destName;
    this.panelTitle = panelTitle;
    this.leadingIcon = leadingIcon;
    this.destDirectoryPath = destDirectoryPath;
    this.totalBytes = totalBytes;
    copiedBytes = 0;
    speedBytesPerSecond = 0;
    currentFile = null;
    _speedLastTime = null;
    _speedLastBytes = null;
    _lastCopyProgressNotify = null;
    _lastThrottledFile = null;
    _lastNotifiedCopiedBytes = null;
    notifyListeners();
  }

  void requestCancel() {
    cancelRequested = true;
    notifyListeners();
  }

  /// Frazione 0–1 unica per barra in basso e pannello copia (evita discrepanze).
  double get displayProgressFraction {
    final t = totalBytes;
    final c = copiedBytes;
    if (t > 0) {
      return (c.toDouble() / t.toDouble()).clamp(0.0, 1.0);
    }
    if (c > 0) {
      final est = (c * 1.15).ceil();
      if (est <= 0) return 0.0;
      return (c.toDouble() / est.toDouble()).clamp(0.0, 0.99);
    }
    return 0.0;
  }

  /// Denominatore per la riga byte (allineato a [displayProgressFraction]).
  int get displayTotalBytesForLabel {
    if (totalBytes > 0) return totalBytes;
    if (copiedBytes > 0) return (copiedBytes * 1.15).ceil();
    return totalBytes;
  }

  bool get displayUsesEstimatedTotal => totalBytes <= 0 && copiedBytes > 0;

  void _applySpeedEma(int bytesCopied) {
    final t = DateTime.now();
    if (_speedLastTime != null && _speedLastBytes != null) {
      final dtMs = t.difference(_speedLastTime!).inMilliseconds;
      if (dtMs >= 60 && bytesCopied >= _speedLastBytes!) {
        final db = bytesCopied - _speedLastBytes!;
        if (db > 0) {
          final inst = (db / dtMs) * 1000.0;
          speedBytesPerSecond = speedBytesPerSecond <= 0
              ? inst
              : speedBytesPerSecond * 0.74 + inst * 0.26;
        }
        _speedLastTime = t;
        _speedLastBytes = bytesCopied;
      }
    } else {
      _speedLastTime = t;
      _speedLastBytes = bytesCopied;
    }
  }

  static const int _copyProgressNotifyMinIntervalMs = 90;

  /// Aggiorna barra/ETA e velocità in un solo [notifyListeners].
  /// Con [adjustTotalIfUnknown] false il totale non viene ricalcolato (batch con `du`/stat noti).
  void applyCopyProgress({
    required int bytesCopied,
    String? currentFileName,
    bool adjustTotalIfUnknown = true,
  }) {
    // `du` può oscillare leggermente: non far retrocedere la barra.
    final prev = copiedBytes;
    final mono = bytesCopied > prev ? bytesCopied : prev;
    copiedBytes = mono;
    if (currentFileName != null) {
      currentFile = currentFileName;
    }
    if (adjustTotalIfUnknown) {
      if (totalBytes <= 0 && mono > 0) {
        final hint = (mono * 1.15).ceil();
        totalBytes = totalBytes < hint ? hint : totalBytes;
      }
    }
    // Sempre: se il totale noto (batch/`du`) era sottostimato, alza il denominatore.
    // Altrimenti con adjustTotalIfUnknown false la barra resta bloccata sotto il 100%.
    if (totalBytes > 0 && mono > totalBytes) {
      totalBytes = (mono * 1.02).ceil();
    }
    _applySpeedEma(mono);

    final now = DateTime.now();
    final fileChanged = currentFileName != null &&
        currentFileName != _lastThrottledFile;
    if (fileChanged) {
      _lastThrottledFile = currentFileName;
    }
    // Throttle solo se byte e file invariati: altrimenti la UI resta indietro
    // mentre i byte avanzano (stesso nome file per rsync/du a lungo).
    final bytesChanged = mono != _lastNotifiedCopiedBytes;
    if (!bytesChanged &&
        !fileChanged &&
        _lastCopyProgressNotify != null &&
        now.difference(_lastCopyProgressNotify!).inMilliseconds <
            _copyProgressNotifyMinIntervalMs) {
      return;
    }
    _lastCopyProgressNotify = now;
    _lastNotifiedCopiedBytes = mono;
    notifyListeners();
  }

  void clear() {
    sourceName = null;
    destName = null;
    panelTitle = null;
    leadingIcon = Icons.copy;
    destDirectoryPath = null;
    totalBytes = 0;
    copiedBytes = 0;
    speedBytesPerSecond = 0;
    currentFile = null;
    cancelRequested = false;
    _speedLastTime = null;
    _speedLastBytes = null;
    _lastCopyProgressNotify = null;
    _lastThrottledFile = null;
    _lastNotifiedCopiedBytes = null;
    notifyListeners();
  }
}

/// Copia attiva (pop) vs statistiche (barra): evita rebuild dell'intero schermo ad ogni tick.
class CopyProgressController {
  final ValueNotifier<bool> active = ValueNotifier(false);
  final CopyProgressStats stats = CopyProgressStats();

  bool get shouldCancelCopy => stats.cancelRequested;

  void start({
    required String sourceName,
    required String destName,
    String? destDirectoryPath,
    int totalBytes = 0,
    String? panelTitle,
    IconData leadingIcon = Icons.copy,
  }) {
    active.value = true;
    stats.begin(
      sourceName: sourceName,
      destName: destName,
      destDirectoryPath: destDirectoryPath,
      totalBytes: totalBytes,
      panelTitle: panelTitle,
      leadingIcon: leadingIcon,
    );
  }

  void finish() {
    stats.clear();
    active.value = false;
  }

  /// Annulla operazione: consente chiusura finestra; il loop deve leggere [shouldCancelCopy].
  void userCancel() {
    active.value = false;
    stats.requestCancel();
  }

  void dispose() {
    active.dispose();
    stats.dispose();
  }
}
