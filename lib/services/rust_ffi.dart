import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:filemanager/services/logging_service.dart';

/// Tipo per il callback di progresso (deve essere top-level)
/// Usa Int64 per compatibilità con i64 in Rust FFI
/// Void è necessario per FFI native functions
typedef ProgressCallbackNative = Void Function(Int64, Pointer<Utf8>);
typedef ProgressCallbackDart = void Function(int, Pointer<Utf8>);

/// Tipo per la funzione copy_file_with_progress (deve essere top-level)
typedef CopyFileWithProgressNative =
    Int32 Function(
      Pointer<Utf8> source,
      Pointer<Utf8> dest,
      Pointer<NativeFunction<ProgressCallbackNative>> callback,
    );
typedef CopyFileWithProgressDart =
    int Function(
      Pointer<Utf8> source,
      Pointer<Utf8> dest,
      Pointer<NativeFunction<ProgressCallbackNative>> callback,
    );

/// Tipo per la funzione copy_file_fast (versione semplificata senza callback)
typedef CopyFileFastNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef CopyFileFastDart = int Function(Pointer<Utf8>, Pointer<Utf8>);

// New FFI types for drag control state bridging with Rust
typedef SetDragCtrlStateNative = Void Function(Int32);
typedef SetDragCtrlStateDart = void Function(int);

// FFI type for getting keyboard modifiers from Rust (more reliable on Wayland)
typedef GetKeyboardModifiersNative = Int32 Function();
typedef GetKeyboardModifiersDart = int Function();

/// Tipo per list_smb_directory_via_shell
typedef ListSmbDirectoryViaShellNative =
    Pointer<Utf8> Function(
      Pointer<Utf8> server,
      Pointer<Utf8> share,
      Pointer<Utf8> path,
      Pointer<Utf8> username,
      Pointer<Utf8> password,
    );
typedef ListSmbDirectoryViaShellDart =
    Pointer<Utf8> Function(
      Pointer<Utf8> server,
      Pointer<Utf8> share,
      Pointer<Utf8> path,
      Pointer<Utf8> username,
      Pointer<Utf8> password,
    );

/// Tipo per free_smb_shell_result
typedef FreeSmbShellResultNative = Void Function(Pointer<Utf8>);
typedef FreeSmbShellResultDart = void Function(Pointer<Utf8>);

/// Tipo per start_native_drag
typedef StartNativeDragNative = Int32 Function(Pointer<Utf8>);
typedef StartNativeDragDart = int Function(Pointer<Utf8>);

/// Wrapper FFI per le funzioni Rust ottimizzate
class RustFFI {
  static DynamicLibrary? _lib;

  /// Evita lookup FFI e probe ripetuti (leggero sulla UI / hot path copia).
  static bool? _copyFastAvailable;
  static CopyFileFastDart? _copyFileFastImpl;
  static SetDragCtrlStateDart? _setDragCtrlStateImpl;
  static GetKeyboardModifiersDart? _getKeyboardModifiersImpl;

  static bool _ensureCopyFileFastResolved() {
    if (_copyFastAvailable == false) return false;
    if (_copyFileFastImpl != null) return true;
    try {
      _copyFileFastImpl = RustFFI.lib
          .lookupFunction<CopyFileFastNative, CopyFileFastDart>(
            'copy_file_fast',
          );
      _copyFastAvailable = true;
      return true;
    } catch (_) {
      _copyFastAvailable = false;
      _copyFileFastImpl = null;
      return false;
    }
  }

  /// Resolve set_drag_ctrl_state binding
  static bool _ensureSetDragCtrlStateResolved() {
    if (_setDragCtrlStateImpl != null) return true;
    try {
      final lib = RustFFI.lib;
      final func = lib
          .lookupFunction<SetDragCtrlStateNative, SetDragCtrlStateDart>(
            'set_drag_ctrl_state',
          );
      _setDragCtrlStateImpl = func;
      return true;
    } catch (_) {
      _setDragCtrlStateImpl = null;
      return false;
    }
  }

  /// Bind a drag ctrl state to the Rust side (0/1)
  static void setDragCtrlState(int state) {
    if (!_ensureSetDragCtrlStateResolved()) return;
    _setDragCtrlStateImpl!(state);
  }

  /// Resolve get_keyboard_modifiers binding
  static bool _ensureGetKeyboardModifiersResolved() {
    if (_getKeyboardModifiersImpl != null) return true;
    try {
      final lib = RustFFI.lib;
      final func = lib
          .lookupFunction<GetKeyboardModifiersNative, GetKeyboardModifiersDart>(
            'get_keyboard_modifiers',
          );
      _getKeyboardModifiersImpl = func;
      return true;
    } catch (_) {
      _getKeyboardModifiersImpl = null;
      return false;
    }
  }

  /// Get keyboard modifier state from Rust (more reliable on Wayland)
  /// Returns bitmask: bit 0 = Ctrl, bit 1 = Shift, bit 2 = Meta/Super
  static int getKeyboardModifiers() {
    if (!_ensureGetKeyboardModifiersResolved()) return 0;
    return _getKeyboardModifiersImpl!();
  }

  /// Check if Ctrl/Meta is pressed (bit 0 of modifier mask)
  static bool get isCtrlPressed => (getKeyboardModifiers() & 1) != 0;

  /// Check if Shift is pressed (bit 1 of modifier mask)
  static bool get isShiftPressed => (getKeyboardModifiers() & 2) != 0;

  /// Check if Meta/Super is pressed (bit 2 of modifier mask)
  static bool get isMetaPressed => (getKeyboardModifiers() & 4) != 0;

  /// Carica la libreria Rust
  static DynamicLibrary get lib {
    if (_lib != null) return _lib!;

    try {
      // Prova a caricare la libreria Rust
      // Su Linux, la libreria viene linkata automaticamente durante il build
      // Il nome della libreria dipende dalla configurazione di build
      if (Platform.isLinux) {
        // Prova diversi nomi possibili per la libreria Rust
        // La libreria potrebbe essere linkata staticamente o dinamicamente
        try {
          // Prova prima il nome standard
          _lib = DynamicLibrary.open('libfilemanager_rust.so');
        } catch (e) {
          try {
            // Prova il path relativo dalla directory corrente
            _lib = DynamicLibrary.open('./libfilemanager_rust.so');
          } catch (e2) {
            try {
              // Prova il path relativo dalla directory dell'eseguibile
              // Su Linux, le librerie sono nella stessa directory dell'eseguibile o in lib/
              final executablePath = Platform.resolvedExecutable;
              final executableDir = path.dirname(executablePath);
              _lib = DynamicLibrary.open(
                '$executableDir/lib/libfilemanager_rust.so',
              );
            } catch (e3) {
              // Prova DynamicLibrary.process() che carica librerie linkate staticamente
              try {
                _lib = DynamicLibrary.process();
              } catch (e4) {
                // Ultimo fallback: DynamicLibrary.executable()
                _lib = DynamicLibrary.executable();
              }
            }
          }
        }
      } else {
        _lib = DynamicLibrary.executable();
      }

      return _lib!;
    } catch (e) {
      throw Exception('Failed to load Rust library: $e');
    }
  }

  // Callback storage per mantenere i riferimenti durante la copia
  static void Function(int, String?)? _currentProgressCallback;

  /// Funzione Rust ottimizzata per copiare file con progresso
  ///
  /// Parametri:
  /// - source: percorso file sorgente
  /// - dest: percorso file destinazione
  /// - onProgress: callback chiamato periodicamente con (bytesCopied, fileName)
  ///
  /// Ritorna: true se successo, false se errore
  static bool copyFileWithProgress(
    String source,
    String dest,
    void Function(int bytesCopied, String? fileName) onProgress,
  ) {
    if (!_ensureCopyFileFastResolved() || _copyFileFastImpl == null) {
      return false;
    }
    final copyFastFunc = _copyFileFastImpl!;
    try {
      final sourceCStr = source.toNativeUtf8();
      final destCStr = dest.toNativeUtf8();
      try {
        final result = copyFastFunc(sourceCStr, destCStr);
        return result == 1;
      } finally {
        malloc.free(sourceCStr);
        malloc.free(destCStr);
      }
    } catch (_) {
      _currentProgressCallback = null;
      return false;
    }
  }

  /// Risultato memorizzato: niente probe ripetuti.
  static bool isAvailable() {
    if (_copyFastAvailable != null) return _copyFastAvailable!;
    return _ensureCopyFileFastResolved();
  }

  /// Lista i file in una directory SMB usando smbclient via shell command
  /// Questo è un fallback per diagnosticare problemi con la libreria Rust
  ///
  /// Parametri:
  /// - server: Nome o IP del server SMB
  /// - share: Nome della condivisione
  /// - path: Percorso relativo nella condivisione ("" per root)
  /// - username: Username per autenticazione (null per guest)
  /// - password: Password per autenticazione (null per guest)
  ///
  /// Ritorna: Map con "success", "files" (List<String>), "stdout", "stderr", "exit_code"
  static Future<Map<String, dynamic>?> listSmbDirectoryViaShell(
    String server,
    String share,
    String path,
    String? username,
    String? password,
  ) async {
    await LoggingService.network('listSmbDirectoryViaShell called', {
      'server': server,
      'share': share,
      'path': path,
      'has_username': username != null,
      'has_password': password != null,
    });

    try {
      final lib = RustFFI.lib;
      await LoggingService.network('Rust library loaded');

      final listFunc = lib
          .lookupFunction<
            ListSmbDirectoryViaShellNative,
            ListSmbDirectoryViaShellDart
          >('list_smb_directory_via_shell');

      final freeFunc = lib
          .lookupFunction<FreeSmbShellResultNative, FreeSmbShellResultDart>(
            'free_smb_shell_result',
          );

      // Crea i CString per i parametri
      final serverCStr = server.toNativeUtf8();
      final shareCStr = share.toNativeUtf8();
      final pathCStr = path.toNativeUtf8();
      final usernameCStr = username?.toNativeUtf8() ?? nullptr;
      final passwordCStr = password?.toNativeUtf8() ?? nullptr;

      try {
        await LoggingService.network(
          'Calling Rust function list_smb_directory_via_shell',
        );

        // Chiama la funzione Rust
        final resultPtr = listFunc(
          serverCStr,
          shareCStr,
          pathCStr,
          usernameCStr,
          passwordCStr,
        );

        if (resultPtr == nullptr) {
          await LoggingService.error(
            'RustFFI',
            'Function returned null pointer',
          );
          return {'success': false, 'error': 'Function returned null pointer'};
        }

        // Converti il risultato da CString a String Dart
        final resultStr = resultPtr.toDartString();
        await LoggingService.network('Rust function returned', {
          'result_length': resultStr.length,
          'result_preview': resultStr.length > 500
              ? resultStr.substring(0, 500)
              : resultStr,
        });

        // Libera la memoria allocata da Rust
        freeFunc(resultPtr);

        // Parse il JSON usando dart:convert
        try {
          final result = jsonDecode(resultStr) as Map<String, dynamic>;
          await LoggingService.network('JSON parsed successfully', {
            'success': result['success'],
            'file_count': result['file_count'] ?? 0,
            'exit_code': result['exit_code'] ?? -1,
          });
          return result;
        } catch (e, stackTrace) {
          await LoggingService.error('RustFFI', 'Failed to parse JSON', {
            'error': e.toString(),
            'raw_json': resultStr,
          }, stackTrace);
          return {
            'success': false,
            'error': 'Failed to parse JSON: $e',
            'raw_json': resultStr,
          };
        }
      } finally {
        // Libera la memoria
        malloc.free(serverCStr);
        malloc.free(shareCStr);
        malloc.free(pathCStr);
        if (usernameCStr != nullptr) malloc.free(usernameCStr);
        if (passwordCStr != nullptr) malloc.free(passwordCStr);
      }
    } catch (e, stackTrace) {
      await LoggingService.error(
        'RustFFI',
        'Exception in listSmbDirectoryViaShell',
        {'exception': e.toString()},
        stackTrace,
      );
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Start native drag operation using GTK
  /// This function initiates a drag operation from the application window
  ///
  /// Parameters:
  /// - filePath: Path to the file to drag (single file path)
  ///
  /// Returns: true if successful, false if error
  ///
  /// Note: This replaces the Flutter plugin for better Wayland compatibility
  static bool startNativeDrag(String filePath) {
    if (!Platform.isLinux) {
      return false;
    }

    try {
      final lib = RustFFI.lib;

      final startDragFunc = lib
          .lookupFunction<StartNativeDragNative, StartNativeDragDart>(
            'start_native_drag',
          );

      // Create CString for the file path
      final filePathCStr = filePath.toNativeUtf8();

      try {
        // Call the Rust function
        final result = startDragFunc(filePathCStr);

        return result == 1;
      } finally {
        // Free the memory
        malloc.free(filePathCStr);
      }
    } catch (e) {
      print('Rust FFI error in startNativeDrag: $e');
      return false;
    }
  }
}

/// Funzione top-level per il callback (richiesta da Pointer.fromFunction)
/// Questa funzione viene chiamata dalla funzione Rust
/// Deve corrispondere esattamente a ProgressCallbackNative (Void Function(Int64, Pointer<Utf8>))
/// Nota: usiamo void come tipo di ritorno, ma il cast lo converte a Void per FFI
@pragma('vm:entry-point')
void _progressCallbackNative(Int64 bytes, Pointer<Utf8> fileNamePtr) {
  // Converti il nome file da CString a String Dart
  String? fileName;
  if (fileNamePtr != nullptr) {
    try {
      fileName = fileNamePtr.toDartString();
    } catch (e) {
      fileName = null;
    }
  }

  // Chiama il callback Dart se disponibile
  // Int64 in Dart FFI è un typedef per int, ma dobbiamo fare un cast esplicito
  // perché il tipo system di Dart li tratta come tipi diversi
  RustFFI._currentProgressCallback?.call(bytes as int, fileName);
}
