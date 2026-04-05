import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

/// Servizio di logging completo che scrive su file
/// Registra tutti i movimenti dell'app per diagnosticare problemi
class LoggingService {
  static File? _logFile;
  static bool _initialized = false;
  static final List<String> _logBuffer = [];
  static const int _maxBufferSize = 100;

  /// Inizializza il sistema di logging
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Ottieni la directory per i log
      final directory = await getApplicationSupportDirectory();
      final logDir = Directory(path.join(directory.path, 'logs'));
      
      // Crea la directory se non esiste
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Crea il file di log con timestamp
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final logFilePath = path.join(logDir.path, 'filemanager_$timestamp.log');
      _logFile = File(logFilePath);

      // Crea anche un link simbolico al log più recente
      final latestLogPath = path.join(logDir.path, 'latest.log');
      final latestLogFile = File(latestLogPath);
      if (await latestLogFile.exists()) {
        await latestLogFile.delete();
      }
      await _logFile!.create();
      await _logFile!.writeAsString('=== File Manager Log Started ===\n');
      await _logFile!.writeAsString('Timestamp: ${DateTime.now().toIso8601String()}\n');
      await _logFile!.writeAsString('Log file: $logFilePath\n\n', mode: FileMode.append);

      // Scrivi il buffer se ci sono log precedenti
      if (_logBuffer.isNotEmpty) {
        await _logFile!.writeAsString(
          _logBuffer.join('\n') + '\n',
          mode: FileMode.append,
        );
        _logBuffer.clear();
      }

      _initialized = true;
      await log('INFO', 'LoggingService', 'Logging system initialized', {
        'log_file': logFilePath,
      });
    } catch (e) {
      // Fallback: usa directory temporanea
      final tempDir = Directory.systemTemp;
      final logFilePath = path.join(tempDir.path, 'filemanager.log');
      _logFile = File(logFilePath);
      await _logFile!.create();
      await log('ERROR', 'LoggingService', 'Failed to initialize logging in app directory, using temp: $e');
    }
  }

  /// Ottiene il path del file di log
  static String? getLogFilePath() {
    return _logFile?.path;
  }

  /// Scrive un log entry
  static Future<void> log(
    String level,
    String category,
    String message, [
    Map<String, dynamic>? data,
  ]) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final dataStr = data != null ? ' | Data: ${data.toString()}' : '';
    final logEntry = '[$timestamp] [$level] [$category] $message$dataStr';

    // Stampa anche su console
    print(logEntry);

    // Se non inizializzato, aggiungi al buffer
    if (!_initialized) {
      _logBuffer.add(logEntry);
      if (_logBuffer.length > _maxBufferSize) {
        _logBuffer.removeAt(0);
      }
      return;
    }

    // Scrivi su file
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$logEntry\n', mode: FileMode.append);
      }
    } catch (e) {
      print('ERROR: Failed to write log: $e');
    }
  }

  /// Log di debug
  static Future<void> debug(String category, String message, [Map<String, dynamic>? data]) {
    return log('DEBUG', category, message, data);
  }

  /// Log di info
  static Future<void> info(String category, String message, [Map<String, dynamic>? data]) {
    return log('INFO', category, message, data);
  }

  /// Log di warning
  static Future<void> warning(String category, String message, [Map<String, dynamic>? data]) {
    return log('WARNING', category, message, data);
  }

  /// Log di errore
  static Future<void> error(String category, String message, [Map<String, dynamic>? data, StackTrace? stackTrace]) {
    final dataWithStack = data ?? <String, dynamic>{};
    if (stackTrace != null) {
      dataWithStack['stack_trace'] = stackTrace.toString();
    }
    return log('ERROR', category, message, dataWithStack);
  }

  /// Log per drag & drop
  static Future<void> dragDrop(String message, [Map<String, dynamic>? data]) {
    return log('DRAG_DROP', 'DragAndDrop', message, data);
  }

  /// Log per network/SMB
  static Future<void> network(String message, [Map<String, dynamic>? data]) {
    return log('NETWORK', 'Network', message, data);
  }

  /// Flush del buffer (forza scrittura su disco)
  static Future<void> flush() async {
    if (_logFile != null && _initialized) {
      try {
        // Force sync to disk
        final sink = _logFile!.openWrite(mode: FileMode.append);
        await sink.flush();
        await sink.close();
      } catch (e) {
        print('ERROR: Failed to flush log: $e');
      }
    }
  }
}
