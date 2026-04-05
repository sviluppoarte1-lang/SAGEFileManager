import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../models/file_info.dart';
import 'network_browser_service.dart';
import 'network_credentials_store.dart';
import 'rust_ffi.dart';
import 'logging_service.dart';

/// Elenco directory negato (EACCES/EPERM, tipico di `/root` senza privilegi).
class DirectoryListingPermissionException implements Exception {
  final String directoryPath;
  DirectoryListingPermissionException(this.directoryPath);
}

/// Argomenti serializzabili per la copia Rust su isolate worker (non blocca l'UI isolate).
class _RustCopyIsolateArgs {
  final String source;
  final String dest;
  _RustCopyIsolateArgs(this.source, this.dest);
}

bool _rustCopyFileOnIsolate(_RustCopyIsolateArgs args) {
  return RustFFI.copyFileWithProgress(
    args.source,
    args.dest,
    (int copied, String? name) {},
  );
}

class FileService {
  /// Output numerico ASCII da sottoprocessi (`rsync`, `du`, `stat`, `df`, …).
  static Map<String, String> cLocaleEnvironment() {
    final e = Map<String, String>.from(Platform.environment);
    e['LANG'] = 'C';
    e['LC_ALL'] = 'C';
    e['LC_NUMERIC'] = 'C';
    return e;
  }

  /// `rsync --info=progress2`: primi campi sono byte trasferiti (spesso con separatori locali se LANG≠C).
  static int? _parseRsyncProgress2Bytes(String rawLine) {
    final line = rawLine.trim();
    if (line.isEmpty || !line.contains('%')) return null;
    final m = RegExp(r'^\s*([\d][\d.,]*)').firstMatch(line);
    if (m == null) return null;
    return _parseIntDropThousands(m.group(1)!);
  }

  /// Chiave stabile `device:inode` per hard link (Linux).
  static Future<String?> _linuxFileInodeKey(String p) async {
    if (!Platform.isLinux) return null;
    try {
      final r = await Process.run(
        'stat',
        ['-c', '%d:%i', p],
        environment: cLocaleEnvironment(),
      );
      if (r.exitCode != 0) return null;
      final s = r.stdout.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  static int? _parseIntDropThousands(String t) {
    t = t.trim();
    if (t.isEmpty) return null;
    if (t.contains('.') && t.contains(',')) {
      final comma = t.lastIndexOf(',');
      final dot = t.lastIndexOf('.');
      if (comma > dot) {
        t = t.substring(0, comma).replaceAll('.', '');
      } else {
        t = t.substring(0, dot).replaceAll(',', '');
      }
    } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(t)) {
      t = t.replaceAll('.', '');
    } else if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(t)) {
      t = t.replaceAll(',', '');
    } else {
      t = t.replaceAll(',', '');
    }
    return int.tryParse(t);
  }

  static bool _isDirectoryListingEacces(Object e) {
    if (e is PathAccessException) return true;
    if (e is FileSystemException) {
      final c = e.osError?.errorCode;
      if (c == 13) return true;
    }
    final s = e.toString().toLowerCase();
    return s.contains('errno = 13') &&
        (s.contains('listing') || s.contains('directory'));
  }

  /// Destinazioni CIFS/FUSE: cedere al loop degli eventi riduce blocchi UI (Wayland/GPU).
  static bool _isSlowNetworkWriteDest(String destPath) {
    final d = destPath.toLowerCase();
    return d.contains('fm_cifs_') ||
        d.contains('/gvfs/') ||
        d.contains('smb-share');
  }

  static Future<int> _networkCopyYieldAccumulated(
    String dest,
    int chunkLen,
    int accumulatedBytes,
  ) async {
    if (!_isSlowNetworkWriteDest(dest)) return accumulatedBytes + chunkLen;
    final next = accumulatedBytes + chunkLen;
    if (next >= 512 * 1024) {
      await Future<void>.delayed(Duration.zero);
      return 0;
    }
    return next;
  }

  /// Sotto questa soglia la copia Rust è così breve che non serve stat periodico.
  static const int _rustSparseProgressMinFileBytes = 8 * 1024 * 1024;
  static const Duration _rustSparseProgressInterval = Duration(
    milliseconds: 2500,
  );

  /// Copia Rust in isolate; per file grandi aggiorna [onCopyProgress] ogni ~2,5s via stat (leggero).
  static Future<bool> _rustCopyWithSparseProgress({
    required String source,
    required String dest,
    required int totalSize,
    required String progressName,
    Future<void> Function(int bytesCopied, String? fileName)? onCopyProgress,
  }) async {
    if (onCopyProgress != null) {
      await onCopyProgress(0, progressName);
    }

    Timer? timer;
    var finished = false;

    if (onCopyProgress != null &&
        totalSize >= _rustSparseProgressMinFileBytes) {
      timer = Timer.periodic(_rustSparseProgressInterval, (_) {
        if (finished) return;
        try {
          final df = File(dest);
          if (df.existsSync()) {
            final sz = df.statSync().size;
            if (!finished) {
              unawaited(onCopyProgress(sz, progressName));
            }
          }
        } catch (_) {}
      });
    }

    final ok = await Isolate.run(
      () => _rustCopyFileOnIsolate(_RustCopyIsolateArgs(source, dest)),
    );
    finished = true;
    timer?.cancel();
    return ok;
  }

  /// GVFS/SMB/FUSE: copia per-file (Rust/Dart); altrimenti conviene `cp`/`rsync`.
  static bool _isLikelyLocalFilesystemPath(String p) {
    final lower = p.toLowerCase();
    if (lower.contains('/gvfs/')) return false;
    if (lower.contains('/fm_cifs_')) return false;
    if (lower.contains('smb-share')) return false;
    if (lower.contains('fuse.sshfs')) return false;
    return true;
  }

  static Future<bool> _linuxHasGnuStyleRsync() async {
    if (!Platform.isLinux) return false;
    try {
      final r = await Process.run('which', ['rsync']);
      return r.exitCode == 0 && r.stdout.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static bool get _useUnixSystemCopy => Platform.isLinux || Platform.isMacOS;

  /// Linux: `du -sb`. macOS: `du -sk` → byte approssimativi.
  static Future<int> _duTotalBytesUnix(String p) async {
    try {
      if (Platform.isLinux) {
        final du = await Process
            .run('du', ['-sb', p], environment: cLocaleEnvironment())
            .timeout(
          // Alberi grandi su HDD: 60s può bastare raramente; 0 stdout → barra bloccata.
          const Duration(seconds: 180),
          onTimeout: () => ProcessResult(-1, 0, '', ''),
        );
        if (du.exitCode == 0) {
          final line = du.stdout.toString().trim();
          if (line.isEmpty) return 0;
          final tab = line.indexOf('\t');
          final numToken = tab >= 0
              ? line.substring(0, tab)
              : line.split(RegExp(r'\s+')).first;
          return int.tryParse(numToken) ?? 0;
        }
      } else if (Platform.isMacOS) {
        final du = await Process
            .run('du', ['-sk', p], environment: cLocaleEnvironment())
            .timeout(
          const Duration(seconds: 180),
          onTimeout: () => ProcessResult(-1, 0, '', ''),
        );
        if (du.exitCode == 0) {
          final line = du.stdout.toString().trim();
          final kb = int.tryParse(line.split(RegExp(r'\s+')).first);
          if (kb != null) return kb * 1024;
        }
      }
    } catch (_) {}
    return 0;
  }

  /// Durante `ditto`/`cp`: `du` sulla destinazione ogni ~260 ms (stesso label → byte monotoni per l’aggregatore in main).
  static Future<int> _waitProcessWithDestDuPolling({
    required Process proc,
    required String destForDu,
    required int sourceTotalBytes,
    required String progressLabel,
    Future<void> Function(int bytesCopied, String? currentFile)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    // IMPORTANTE (Dart SDK): se stdout non viene consumato, il buffer del pipe si
    // riempie e il processo (es. rsync) si blocca: stderr smette di aggiornarsi e la
    // barra di copia resta ferma (vedi dart-lang/sdk#50674).
    final stdoutDrain = proc.stdout.listen((_) {}, cancelOnError: false);

    var duBusy = false;
    /// Evita onProgress(0) dopo byte reali: timeout `du` altrimenti resetta il delta in main.
    var lastDuEmitted = -1;
    if (onProgress != null) {
      unawaited(onProgress(0, progressLabel));
    }

    final poller = Stream.periodic(const Duration(milliseconds: 260)).listen((
      _,
    ) {
      if (shouldCancel?.call() == true) {
        proc.kill(ProcessSignal.sigterm);
        return;
      }
      if (onProgress == null) return;
      if (duBusy) return;
      duBusy = true;
      _duTotalBytesUnix(destForDu).then((n) {
        duBusy = false;
        if (shouldCancel?.call() == true) return;
        if (n <= 0) return;
        if (lastDuEmitted >= 0 && n < lastDuEmitted) return;
        lastDuEmitted = n;
        // Non limitare a sourceTotalBytes: `du` sulla sorgente può sottostimare (link,
        // cache FS, race) e allora la barra si pianta a un valore fisso (es. ~1 GiB)
        // mentre rsync/cp continuano. La destinazione è la fonte di verità per l’avanzamento.
        unawaited(onProgress(n, progressLabel));
      });
    });

    try {
      return await proc.exitCode;
    } finally {
      await poller.cancel();
      await stdoutDrain.cancel();
    }
  }

  /// Un solo processo kernel per tutto l'albero (niente isolate per file).
  ///
  /// Il parsing di `--info=progress2` su stderr fallisce con alcune versioni/locale di rsync;
  /// il polling `du` sulla destinazione (come per `cp`) aggiorna la barra in modo affidabile.
  static Future<bool> _copyDirectoryLinuxRsync(
    String source,
    String dest, {
    Future<void> Function(int bytesCopied, String? currentFile)? onProgress,
    bool Function()? shouldCancel,
    required int sourceTotalBytes,
  }) async {
    final srcAbs = path.absolute(source);
    final dstAbs = path.absolute(dest);
    final srcArg = srcAbs.endsWith('/') ? srcAbs : '$srcAbs/';
    final dstArg = dstAbs.endsWith('/') ? dstAbs : '$dstAbs/';

    Process? proc;

    try {
      proc = await Process.start(
        'rsync',
        [
          '-a',
          '-H',
          '-S',
          '--info=progress2',
          '--no-human-readable',
          srcArg,
          dstArg,
        ],
        mode: ProcessStartMode.normal,
        environment: cLocaleEnvironment(),
      );

      final progressLabel = path.basename(source);
      // Byte da stderr (affidabile) + du su dest: la UI usa max(...) in [applyCopyProgress].
      var stderrCarry = '';
      final stderrSub = proc.stderr
          .transform(utf8.decoder)
          .listen(
        (chunk) {
          stderrCarry += chunk;
          final parts = stderrCarry.split('\r');
          stderrCarry = parts.last;
          for (var i = 0; i < parts.length - 1; i++) {
            final b = _parseRsyncProgress2Bytes(parts[i]);
            if (b != null && onProgress != null) {
              unawaited(onProgress(b, progressLabel));
            }
          }
        },
        onDone: () {
          final b = _parseRsyncProgress2Bytes(stderrCarry);
          if (b != null && onProgress != null) {
            unawaited(onProgress(b, progressLabel));
          }
        },
        cancelOnError: false,
      );

      try {
        final code = await _waitProcessWithDestDuPolling(
          proc: proc,
          destForDu: dstAbs,
          sourceTotalBytes: sourceTotalBytes,
          progressLabel: progressLabel,
          onProgress: onProgress,
          shouldCancel: shouldCancel,
        );
        if (shouldCancel?.call() == true) {
          return false;
        }
        if (code == 0) {
          if (onProgress != null) {
            final destSz = await _duTotalBytesUnix(dstAbs);
            final snap = destSz > 0
                ? destSz
                : (sourceTotalBytes > 0 ? sourceTotalBytes : 0);
            if (snap > 0) {
              await onProgress(snap, progressLabel);
            }
          }
          return true;
        }
      } finally {
        await stderrSub.cancel();
      }
    } catch (_) {
      proc?.kill(ProcessSignal.sigterm);
    }
    return false;
  }

  /// macOS: preserva metadati Apple; merge come `cp -a sorgente/. dest/`.
  static Future<bool> _copyDirectoryMacDitto(
    String source,
    String dest, {
    bool Function()? shouldCancel,
    Future<void> Function(int bytesCopied, String? currentFile)? onProgress,
    int sourceTotalBytes = 0,
  }) async {
    if (!Platform.isMacOS) return false;
    final srcAbs = path.absolute(source);
    final dstAbs = path.absolute(dest);
    final srcArg = '$srcAbs/.';
    try {
      final proc = await Process.start('ditto', [
        srcArg,
        dstAbs,
      ], mode: ProcessStartMode.normal);

      final code = await _waitProcessWithDestDuPolling(
        proc: proc,
        destForDu: dstAbs,
        sourceTotalBytes: sourceTotalBytes,
        progressLabel: path.basename(source),
        onProgress: onProgress,
        shouldCancel: shouldCancel,
      );
      if (shouldCancel?.call() == true) {
        return false;
      }
      return code == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _copyDirectoryUnixCp(
    String source,
    String dest, {
    bool Function()? shouldCancel,
    Future<void> Function(int bytesCopied, String? currentFile)? onProgress,
    int sourceTotalBytes = 0,
  }) async {
    final srcAbs = path.absolute(source);
    final dstAbs = path.absolute(dest);
    final srcArg = '$srcAbs/.';
    try {
      final proc = await Process.start(
        'cp',
        [
          '-a',
          srcArg,
          dstAbs,
        ],
        mode: ProcessStartMode.normal,
        environment: cLocaleEnvironment(),
      );

      final code = await _waitProcessWithDestDuPolling(
        proc: proc,
        destForDu: dstAbs,
        sourceTotalBytes: sourceTotalBytes,
        progressLabel: path.basename(source),
        onProgress: onProgress,
        shouldCancel: shouldCancel,
      );
      if (shouldCancel?.call() == true) {
        return false;
      }
      return code == 0;
    } catch (_) {
      return false;
    }
  }

  /// `cp` di sistema: niente isolate per file (Linux + macOS).
  static Future<bool> _copySingleFileUnixCp(String source, String dest) async {
    if (!Platform.isLinux && !Platform.isMacOS) return false;
    try {
      if (Platform.isLinux) {
        final r = await Process.run('cp', [
          '--sparse=auto',
          '--reflink=auto',
          source,
          dest,
        ]);
        if (r.exitCode != 0) {
          final r2 = await Process.run('cp', [source, dest]);
          return r2.exitCode == 0;
        }
        return true;
      }
      final r = await Process.run('cp', ['-a', source, dest]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// HOME effettivo dell’utente reale (evita `HOME=/root` con EUID≠0 dopo pkexec/shell strani).
  static Future<String> _linuxHomeFromPasswd() async {
    try {
      final u = (await Process.run('id', ['-un'])).stdout.toString().trim();
      if (u.isEmpty) return '';
      final r = await Process.run('getent', ['passwd', u]);
      if (r.exitCode != 0) return '';
      final parts = r.stdout.toString().trim().split(':');
      if (parts.length >= 6) return parts[5];
    } catch (_) {}
    return '';
  }

  static Future<String> getHomeDirectory() async {
    if (Platform.isLinux) {
      try {
        final uidStr = (await Process.run('id', [
          '-u',
        ])).stdout.toString().trim();
        final uid = int.tryParse(uidStr) ?? -1;
        final envHome = Platform.environment['HOME'] ?? '';
        if (uid != 0) {
          if (envHome == '/root' || envHome.isEmpty) {
            final pw = await _linuxHomeFromPasswd();
            if (pw.isNotEmpty) return pw;
          } else {
            try {
              if (!await Directory(envHome).exists()) {
                final pw = await _linuxHomeFromPasswd();
                if (pw.isNotEmpty) return pw;
              }
            } catch (_) {
              final pw = await _linuxHomeFromPasswd();
              if (pw.isNotEmpty) return pw;
            }
          }
        }
      } catch (_) {}
    }
    final h = Platform.environment['HOME'];
    if (h != null && h.isNotEmpty) return h;
    final u = Platform.environment['USER'];
    if (u != null && u.isNotEmpty) return '/home/$u';
    return '/';
  }

  static Future<List<String>> getStandardDirectories() async {
    final home = await getHomeDirectory();
    final List<String> dirs = [home];

    // Try Italian names first, then English
    final possibleDirs = [
      ['Desktop', 'Scrivania'],
      ['Documents', 'Documenti'],
      ['Pictures', 'Immagini'],
      ['Music', 'Musica'],
      ['Videos', 'Video'],
      ['Downloads', 'Scaricati'],
    ];

    for (final dirNames in possibleDirs) {
      for (final dirName in dirNames) {
        final dirPath = path.join(home, dirName);
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          dirs.add(dirPath);
          break;
        }
      }
    }

    // Always add Trash (create if doesn't exist)
    final trashPath = path.join(home, '.local/share/Trash/files');
    final trashDir = Directory(trashPath);
    if (!await trashDir.exists()) {
      await trashDir.create(recursive: true);
    }
    dirs.add(trashPath);

    return dirs;
  }

  // Cache for directory listings - increased cache time for better performance
  static final Map<String, List<FileInfo>> _directoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(
    seconds: 30,
  ); // Increased from 5 to 30 seconds

  // Get optimal number of workers based on CPU cores
  static int _getOptimalWorkerCount() {
    final processorCount = Platform.numberOfProcessors;
    // Use 75% of available cores, minimum 2, maximum 8
    return (processorCount * 0.75).ceil().clamp(2, 8);
  }

  static Future<List<FileInfo>> _listSmbShellDirectory(
    String displayPath,
    SmbShellLocation loc, {
    required bool showHidden,
    required bool showSystem,
  }) async {
    final cacheKey = '$displayPath:$showHidden:$showSystem:smbsh';
    final now = DateTime.now();
    if (_directoryCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null && now.difference(cacheTime) < _cacheExpiry) {
        return _directoryCache[cacheKey]!;
      }
    }

    String? u;
    String? p;
    final saved = await NetworkCredentialsStore.load(loc.server);
    if (saved != null) {
      u = saved.$1;
      p = saved.$2;
    }

    final raw = await RustFFI.listSmbDirectoryViaShell(
      loc.server,
      loc.share,
      loc.relativePath,
      u,
      p,
    );

    if (raw == null || raw['success'] != true) {
      return [];
    }

    final files = <FileInfo>[];
    final parentUri = displayPath.endsWith('/')
        ? displayPath
        : '$displayPath/';
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    void addEntry(String name, bool isDir) {
      if (!showHidden && name.startsWith('.')) return;
      if (!showSystem && name == 'lost+found') return;
      final childPath = NetworkBrowserService.smbShellChildPath(
        parentUri,
        name,
        isDirectory: isDir,
      );
      files.add(
        FileInfo(
          path: childPath,
          name: name,
          size: 0,
          isDir: isDir,
          modified: ts,
          created: ts,
        ),
      );
    }

    final entries = raw['entries'];
    if (entries is List) {
      for (final e in entries) {
        if (e is! Map) continue;
        final name = e['name']?.toString() ?? '';
        if (name.isEmpty) continue;
        addEntry(name, e['is_dir'] == true);
      }
    } else {
      final fl = raw['files'];
      if (fl is List) {
        for (final n in fl) {
          if (n is String && n.isNotEmpty) addEntry(n, false);
        }
      }
    }

    files.sort((a, b) {
      if (a.isDir && !b.isDir) return -1;
      if (!a.isDir && b.isDir) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    _directoryCache[cacheKey] = files;
    _cacheTimestamps[cacheKey] = now;
    return files;
  }

  /// Lista directory ottimizzata - esegue in background per non bloccare l'UI
  static Future<List<FileInfo>> listDirectory(
    String dirPath, {
    bool showHidden = false,
    bool showSystem = true,
  }) async {
    await LoggingService.info('FileService', 'listDirectory called', {
      'dir_path': dirPath,
      'show_hidden': showHidden,
      'show_system': showSystem,
      'is_gvfs': dirPath.contains('gvfs') ||
          dirPath.contains('smb-share') ||
          dirPath.contains('fm_cifs_'),
    });

    // CRITICAL for SMB/GVFS: Ensure trailing slash for directory paths
    // Many SMB implementations require trailing slash for list operations
    String normalizedPath = dirPath;
    if (!normalizedPath.endsWith('/') && !normalizedPath.endsWith('\\')) {
      if (NetworkBrowserService.isSmbShellPath(normalizedPath)) {
        normalizedPath = '$normalizedPath/';
      } else {
        final dir = Directory(normalizedPath);
        final exists = await dir.exists();
        await LoggingService.info('FileService', 'Path normalization check', {
          'original': dirPath,
          'exists': exists,
        });

        if (exists) {
          normalizedPath = '$normalizedPath/';
        } else if (normalizedPath.contains('gvfs') ||
            normalizedPath.contains('smb-share') ||
            normalizedPath.contains('fm_cifs_')) {
          normalizedPath = '$normalizedPath/';
          await LoggingService.info(
            'FileService',
            'Network/CIFS path detected, adding trailing slash',
          );
        }
      }
    }

    await LoggingService.info('FileService', 'Using normalized path', {
      'normalized': normalizedPath,
    });

    final smbLoc = NetworkBrowserService.tryParseSmbShellPath(normalizedPath);
    if (smbLoc != null) {
      return _listSmbShellDirectory(
        normalizedPath,
        smbLoc,
        showHidden: showHidden,
        showSystem: showSystem,
      );
    }

    final directory = Directory(normalizedPath);
    final exists = await directory.exists();
    if (!exists) {
      await LoggingService.warning('FileService', 'Directory does not exist', {
        'path': normalizedPath,
      });
      return [];
    }

    await LoggingService.info(
      'FileService',
      'Directory exists, starting listing',
    );

    // Check cache
    final cacheKey = '$dirPath:$showHidden:$showSystem';
    final now = DateTime.now();
    if (_directoryCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null && now.difference(cacheTime) < _cacheExpiry) {
        // Ottimizzazione RAM: restituisci lista esistente senza copia se possibile
        // Nota: List.from crea una copia per sicurezza, ma possiamo ottimizzare
        return _directoryCache[cacheKey]!;
      }
    }

    final List<FileInfo> files = [];
    final List<Future<FileInfo?>> futures = [];

    // Get optimal worker count based on CPU
    final workerCount = _getOptimalWorkerCount();
    final batchSize = workerCount * 10; // Process in batches

    // Use listSync for faster synchronous listing, then process in parallel
    // CRITICAL for SMB/GVFS: listSync works with GVFS mounts
    try {
      final isGvfs = normalizedPath.contains('gvfs') ||
          normalizedPath.contains('smb-share') ||
          normalizedPath.contains('fm_cifs_');
      if (isGvfs) {
        await LoggingService.network('Listing SMB/network mount directory', {
          'path': normalizedPath,
        });
      }

      final entities = directory.listSync(followLinks: false);

      await LoggingService.info('FileService', 'Directory listing completed', {
        'path': normalizedPath,
        'entities_count': entities.length,
        'is_gvfs': isGvfs,
      });

      for (final entity in entities) {
        final fileName = path.basename(entity.path);
        // Skip hidden files if not requested
        if (!showHidden && fileName.startsWith('.')) {
          continue;
        }

        // Skip system files if not requested
        if (!showSystem) {
          final entityPath = entity.path;
          // Filtra file/directory di sistema comuni su Linux
          if (entityPath.startsWith('/sys/') ||
              entityPath.startsWith('/proc/') ||
              entityPath.startsWith('/dev/') ||
              entityPath.startsWith('/run/') ||
              entityPath.startsWith('/tmp/.') ||
              fileName == 'lost+found' ||
              (fileName.startsWith('.') &&
                  (fileName == '.cache' ||
                      fileName == '.config' ||
                      fileName == '.local'))) {
            continue;
          }
        }

        // Process stat in parallel with controlled concurrency
        futures.add(_getFileInfoAsync(entity, fileName));

        // Limit concurrent operations to prevent overwhelming the system
        if (futures.length >= batchSize) {
          final batchResults = await Future.wait(futures);
          for (final fileInfo in batchResults) {
            if (fileInfo != null) {
              files.add(fileInfo);
            }
          }
          futures.clear();
          // Rimossi delay per massimizzare velocità
        }
      }

      // Process remaining futures
      if (futures.isNotEmpty) {
        final results = await Future.wait(futures);
        for (final fileInfo in results) {
          if (fileInfo != null) {
            files.add(fileInfo);
          }
        }
      }
    } catch (e) {
      if (_isDirectoryListingEacces(e)) {
        throw DirectoryListingPermissionException(normalizedPath);
      }
      try {
        final stream = directory.list();
        await for (final entity in stream) {
          try {
            final fileName = path.basename(entity.path);
            if (!showHidden && fileName.startsWith('.')) {
              continue;
            }

            final stat = await entity.stat();
            files.add(
              FileInfo(
                path: entity.path,
                name: fileName,
                size: stat.size,
                isDir: entity is Directory,
                modified: stat.modified.millisecondsSinceEpoch ~/ 1000,
                created: stat.changed.millisecondsSinceEpoch ~/ 1000,
              ),
            );
          } catch (_) {
            continue;
          }
        }
      } catch (e2) {
        if (_isDirectoryListingEacces(e2)) {
          throw DirectoryListingPermissionException(normalizedPath);
        }
        rethrow;
      }
    }

    // Sort: directories first, then by name
    files.sort((a, b) {
      if (a.isDir && !b.isDir) return -1;
      if (!a.isDir && b.isDir) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    // Cache the result
    _directoryCache[cacheKey] = files;
    _cacheTimestamps[cacheKey] = now;

    return files;
  }

  static Future<FileInfo?> _getFileInfoAsync(
    FileSystemEntity entity,
    String fileName,
  ) async {
    try {
      final stat = await entity.stat();
      return FileInfo(
        path: entity.path,
        name: fileName,
        size: stat.size,
        isDir: entity is Directory,
        modified: stat.modified.millisecondsSinceEpoch ~/ 1000,
        created: stat.changed.millisecondsSinceEpoch ~/ 1000,
      );
    } catch (e) {
      return null;
    }
  }

  // Clear cache for a specific directory
  static void clearDirectoryCache(String dirPath) {
    final keysToRemove = <String>[];
    for (final key in _directoryCache.keys) {
      if (key.startsWith('$dirPath:')) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _directoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // Clear all cache
  static void clearAllCache() {
    _directoryCache.clear();
    _cacheTimestamps.clear();
  }

  static Future<bool> areFilesIdentical(String path1, String path2) async {
    try {
      final file1 = File(path1);
      final file2 = File(path2);

      if (!await file1.exists() || !await file2.exists()) {
        return false;
      }

      final stat1 = await file1.stat();
      final stat2 = await file2.stat();

      // Check size and modification time
      return stat1.size == stat2.size &&
          stat1.modified == stat2.modified &&
          stat1.changed == stat2.changed;
    } catch (e) {
      return false;
    }
  }

  /// Copia file ottimizzata - usa Rust FFI se disponibile, altrimenti fallback Dart
  static Future<void> copyFileSmart(
    String source,
    String dest, {
    Function(int copied, int skipped, int errors)? onProgress,
    Future<void> Function(int bytesCopied, String? fileName)? onCopyProgress,
  }) async {
    int copied = 0;
    int skipped = 0;
    int errors = 0;

    final sourceFile = File(source);
    final destFile = File(dest);

    if (await destFile.exists()) {
      if (await areFilesIdentical(source, dest)) {
        skipped++;
        onProgress?.call(copied, skipped, errors);
        return;
      }
    }

    try {
      // Create parent directory if needed
      await destFile.parent.create(recursive: true);

      // Ottimizzazione per file piccoli: copia diretta senza buffer
      // Best practice: per file molto piccoli (< 64KB) usa readAsBytes diretto
      // Per file medi (64KB-1MB) usa stream con buffer ottimizzato
      final sourceStat = await sourceFile.stat();
      final fileSize = sourceStat.size;

      if (_useUnixSystemCopy &&
          _isLikelyLocalFilesystemPath(source) &&
          _isLikelyLocalFilesystemPath(dest) &&
          await _copySingleFileUnixCp(source, dest)) {
        await destFile.setLastModified(sourceStat.modified);
        onCopyProgress?.call(fileSize, path.basename(source));
        copied++;
        onProgress?.call(copied, skipped, errors);
        return;
      }

      if (fileSize < 64 * 1024) {
        // < 64KB: copia diretta (best practice per file molto piccoli)
        final bytes = await sourceFile.readAsBytes();
        // Nessun flush forzato: lascia al kernel il batching come Nautilus/cp.
        await destFile.writeAsBytes(bytes);
        if (_isSlowNetworkWriteDest(dest)) {
          await Future<void>.delayed(Duration.zero);
        }
        onCopyProgress?.call(fileSize, path.basename(source));
        return;
      } else if (fileSize < 1024 * 1024) {
        // 64KB-1MB: stream con buffer ottimizzato
        const bufferSize = 256 * 1024;
        final sourceStream = sourceFile.openRead();
        final destSink = destFile.openWrite();

        int totalCopied = 0;
        var yieldAccum = 0;
        await for (final chunk in sourceStream) {
          destSink.add(chunk);
          totalCopied += chunk.length;
          yieldAccum = await _networkCopyYieldAccumulated(
            dest,
            chunk.length,
            yieldAccum,
          );
          // Aggiorna progresso ogni 16KB
          if (onCopyProgress != null &&
              totalCopied % bufferSize < chunk.length) {
            onCopyProgress(totalCopied, path.basename(source));
          }
        }
        await destSink.close();
        onCopyProgress?.call(fileSize, path.basename(source));
        return;
      }

      final rustUsable = RustFFI.isAvailable();
      try {
        if (rustUsable) {
          final totalSize = fileSize;
          final success = await _rustCopyWithSparseProgress(
            source: source,
            dest: dest,
            totalSize: totalSize,
            progressName: path.basename(source),
            onCopyProgress: onCopyProgress,
          );

          if (success) {
            if (onCopyProgress != null) {
              await onCopyProgress(totalSize, path.basename(source));
            }

            // Preserve file metadata
            await destFile.setLastModified(sourceStat.modified);
            copied++;
            onProgress?.call(copied, skipped, errors);
            return;
          }
        }
      } catch (e) {
        // Se Rust fallisce, usa il fallback Dart
        if (kDebugMode) {
          print('Rust copy failed, using Dart fallback: $e');
        }
      }

      // FALLBACK: Usa la versione Dart ottimizzata
      // Get disk type for optimization
      // Note: sourceStat and fileSize are already declared above
      final diskType = await getIoProfileForPath(dest);
      var bufferSize = _getOptimalBufferSize(diskType);

      // Per file di grandi dimensioni (>100MB), aumenta il buffer e riduci la frequenza di flush
      final isLargeFile = fileSize > 100 * 1024 * 1024; // >100MB
      if (isLargeFile) {
        // Aumenta il buffer per file grandi (fino a 32MB per NVMe, 16MB per SSD)
        switch (diskType) {
          case 'nvme':
            bufferSize = (bufferSize * 2).clamp(
              16 * 1024 * 1024,
              32 * 1024 * 1024,
            ); // Max 32MB
            break;
          case 'ssd':
            bufferSize = (bufferSize * 2).clamp(
              8 * 1024 * 1024,
              16 * 1024 * 1024,
            ); // Max 16MB
            break;
          case 'hdd':
            bufferSize = ((bufferSize * 1.5).round()).clamp(
              4 * 1024 * 1024,
              8 * 1024 * 1024,
            ); // Max 8MB
            break;
          default:
            break;
        }
      }

      // Copia ottimizzata con buffer più grande e sync per massime prestazioni
      final sourceStream = sourceFile.openRead();
      final destStream = destFile.openWrite();

      final buffer = <int>[];
      var yieldAccum = 0;
      await for (final chunk in sourceStream) {
        buffer.addAll(chunk);
        yieldAccum = await _networkCopyYieldAccumulated(
          dest,
          chunk.length,
          yieldAccum,
        );
        while (buffer.length >= bufferSize) {
          destStream.add(Uint8List.fromList(buffer.sublist(0, bufferSize)));
          buffer.removeRange(0, bufferSize);
          yieldAccum = await _networkCopyYieldAccumulated(
            dest,
            bufferSize,
            yieldAccum,
          );
        }
      }
      if (buffer.isNotEmpty) {
        destStream.add(Uint8List.fromList(buffer));
      }
      await destStream.close();

      // Preserve file metadata
      await destFile.setLastModified(sourceStat.modified);

      copied++;
    } catch (e) {
      errors++;
    }

    onProgress?.call(copied, skipped, errors);
  }

  static Future<void> copyDirectorySmartWithProgress(
    String source,
    String dest, {
    Future<void> Function(int bytesCopied, String? currentFile)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    final sourceDir = Directory(source);
    final destDir = Directory(dest);

    if (!await sourceDir.exists()) {
      return;
    }

    // Create destination directory
    await destDir.create(recursive: true);

    if (_useUnixSystemCopy &&
        _isLikelyLocalFilesystemPath(source) &&
        _isLikelyLocalFilesystemPath(dest)) {
      final sourceTotalBytes = await _duTotalBytesUnix(source);

      Future<void> resetDestForFallback() async {
        try {
          await destDir.delete(recursive: true);
          await destDir.create(recursive: true);
        } catch (_) {}
      }

      Future<void> emitCompleteIfKnown() async {
        if (onProgress == null) return;
        final destSz = await _duTotalBytesUnix(dest);
        final snap = destSz > 0
            ? destSz
            : (sourceTotalBytes > 0 ? sourceTotalBytes : 0);
        if (snap > 0) {
          await onProgress(snap, path.basename(source));
        }
      }

      var systemCopyDone = false;

      if (Platform.isLinux && await _linuxHasGnuStyleRsync()) {
        systemCopyDone = await _copyDirectoryLinuxRsync(
          source,
          dest,
          onProgress: onProgress,
          shouldCancel: shouldCancel,
          sourceTotalBytes: sourceTotalBytes,
        );
        if (shouldCancel?.call() == true) {
          return;
        }
        if (systemCopyDone) {
          return;
        }
        await resetDestForFallback();
      }

      if (Platform.isMacOS) {
        systemCopyDone = await _copyDirectoryMacDitto(
          source,
          dest,
          shouldCancel: shouldCancel,
          onProgress: onProgress,
          sourceTotalBytes: sourceTotalBytes,
        );
        if (shouldCancel?.call() == true) {
          return;
        }
        if (systemCopyDone) {
          await emitCompleteIfKnown();
          return;
        }
        await resetDestForFallback();
      }

      systemCopyDone = await _copyDirectoryUnixCp(
        source,
        dest,
        shouldCancel: shouldCancel,
        onProgress: onProgress,
        sourceTotalBytes: sourceTotalBytes,
      );
      if (shouldCancel?.call() == true) {
        return;
      }
      if (systemCopyDone) {
        await emitCompleteIfKnown();
        return;
      }
      await resetDestForFallback();
    }

    final rustCopyAvailable = RustFFI.isAvailable();
    final linuxHardlinkDestByInode = <String, String>{};

    // Copy all files and subdirectories. followLinks: false is required: the default
    // (true) traverses symlinked directories and duplicates data (e.g. Flutter
    // .pub-cache, build/ links), inflating size vs `du` / rsync.
    await for (final entity in sourceDir.list(recursive: true, followLinks: false)) {
      // Check for cancellation
      if (shouldCancel?.call() == true) {
        break;
      }

      // Rimossi delay per massimizzare velocità - il sistema operativo gestisce automaticamente lo scheduling

      try {
        final relativePath = path.relative(entity.path, from: source);
        final destPath = path.join(dest, relativePath);

        if (entity is File) {
          if (await File(destPath).exists()) {
            if (await areFilesIdentical(entity.path, destPath)) {
              continue;
            }
          }

          if (Platform.isLinux) {
            final iKey = await _linuxFileInodeKey(entity.path);
            if (iKey != null) {
              final priorDest = linuxHardlinkDestByInode[iKey];
              if (priorDest != null) {
                await Directory(path.dirname(destPath)).create(recursive: true);
                try {
                  final ex = File(destPath);
                  if (await ex.exists()) await ex.delete();
                } catch (_) {}
                final lr = await Process.run(
                  'ln',
                  [priorDest, destPath],
                  environment: cLocaleEnvironment(),
                );
                if (lr.exitCode == 0) {
                  if (onProgress != null) {
                    await onProgress(0, path.basename(entity.path));
                  }
                  continue;
                }
              }
            }
          }

          bool rustSuccess = false;
          if (rustCopyAvailable) {
            try {
              // Ottieni la dimensione del file per il progresso
              final sourceFile = File(entity.path);
              final fileStat = await sourceFile.stat();
              final totalSize = fileStat.size;

              rustSuccess = await _rustCopyWithSparseProgress(
                source: entity.path,
                dest: destPath,
                totalSize: totalSize,
                progressName: path.basename(entity.path),
                onCopyProgress: onProgress,
              );

              if (rustSuccess) {
                if (onProgress != null) {
                  await onProgress(totalSize, path.basename(entity.path));
                }

                // Preserve file metadata
                final destFile = File(destPath);
                await destFile.setLastModified(fileStat.modified);

                if (Platform.isLinux) {
                  final ik = await _linuxFileInodeKey(entity.path);
                  if (ik != null) linuxHardlinkDestByInode[ik] = destPath;
                }
                continue; // File copiato con successo, passa al prossimo
              }
            } catch (e) {
              print(
                'Rust copy failed for ${entity.path}, using Dart fallback: $e',
              );
            }
          }

          // FALLBACK: Usa la versione Dart ottimizzata
          // Copy file with progress tracking and optimized buffer
          final sourceFile = File(entity.path);
          final destFile = File(destPath);
          await destFile.parent.create(recursive: true);

          // Get file size for optimization
          final fileStat = await sourceFile.stat();
          final fileSize = fileStat.size;

          // Get disk type for optimization
          final diskType = await getIoProfileForPath(destPath);
          var bufferSize = _getOptimalBufferSize(diskType);

          // Per file di grandi dimensioni (>100MB), aumenta il buffer e riduci la frequenza di flush
          final isLargeFile = fileSize > 100 * 1024 * 1024; // >100MB
          if (isLargeFile) {
            // Aumenta il buffer per file grandi (fino a 4x per NVMe, 2x per SSD)
            switch (diskType) {
              case 'nvme':
                bufferSize = (bufferSize * 2).clamp(
                  16 * 1024 * 1024,
                  32 * 1024 * 1024,
                ); // Max 32MB
                break;
              case 'ssd':
                bufferSize = (bufferSize * 2).clamp(
                  8 * 1024 * 1024,
                  16 * 1024 * 1024,
                ); // Max 16MB
                break;
              case 'hdd':
                bufferSize = ((bufferSize * 1.5).round()).clamp(
                  4 * 1024 * 1024,
                  8 * 1024 * 1024,
                ); // Max 8MB
                break;
              default:
                break;
            }
          }

          final sourceStream = sourceFile.openRead();
          final destStream = destFile.openWrite();

          int fileBytesCopied = 0;
          final buffer = <int>[];
          int lastProgressUpdate = 0;
          final progressUpdateInterval = isLargeFile ? 2097152 : 524288;

          await for (final chunk in sourceStream) {
            buffer.addAll(chunk);
            fileBytesCopied += chunk.length;
            while (buffer.length >= bufferSize) {
              destStream.add(Uint8List.fromList(buffer.sublist(0, bufferSize)));
              buffer.removeRange(0, bufferSize);
            }
            if (onProgress != null &&
                (fileBytesCopied - lastProgressUpdate) >=
                    progressUpdateInterval) {
              await onProgress(fileBytesCopied, path.basename(entity.path));
              lastProgressUpdate = fileBytesCopied;
            }
          }
          if (onProgress != null && fileBytesCopied > lastProgressUpdate) {
            await onProgress(fileBytesCopied, path.basename(entity.path));
          }
          if (buffer.isNotEmpty) {
            destStream.add(Uint8List.fromList(buffer));
          }
          await destStream.close();
          if (Platform.isLinux) {
            final ik = await _linuxFileInodeKey(entity.path);
            if (ik != null) linuxHardlinkDestByInode[ik] = destPath;
          }
        } else if (entity is Directory) {
          await Directory(destPath).create(recursive: true);
        } else if (entity is Link) {
          final srcLink = Link(entity.path);
          String targetStr;
          try {
            targetStr = await srcLink.target();
          } catch (_) {
            continue;
          }
          await Directory(path.dirname(destPath)).create(recursive: true);
          final destLink = Link(destPath);
          try {
            if (await destLink.exists()) {
              await destLink.delete();
            }
          } catch (_) {}
          try {
            await Link(destPath).create(targetStr, recursive: false);
          } catch (_) {
            // VFAT/exFAT: no symlinks — copy referent (file or tree).
            try {
              final realPath = await srcLink.resolveSymbolicLinks();
              final realType =
                  await FileSystemEntity.type(realPath, followLinks: false);
              if (realType == FileSystemEntityType.file) {
                await Directory(path.dirname(destPath)).create(recursive: true);
                await File(realPath).copy(destPath);
              } else if (realType == FileSystemEntityType.directory) {
                await Directory(destPath).create(recursive: true);
                await copyDirectorySmartWithProgress(
                  realPath,
                  destPath,
                  onProgress: onProgress,
                  shouldCancel: shouldCancel,
                );
              }
            } catch (_) {
              continue;
            }
          }
        }
      } catch (e) {
        // Skip files that can't be accessed
        continue;
      }
    }
  }

  // RIMOSSO: copyDirectorySmart - funzione duplicata e meno ottimizzata
  // Usa copyDirectorySmartWithProgress invece, che è più recente e ottimizzata

  /// Verifica se un file è un eseguibile ELF (inclusi eseguibili Flutter)
  /// Controlla i magic bytes ELF (0x7F 'ELF') e i permessi di esecuzione
  static Future<bool> isElfExecutable(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      // Controlla i permessi di esecuzione
      final stat = await file.stat();
      final mode = stat.mode;
      // Controlla se ha permessi di esecuzione per owner, group o others
      final isExecutable =
          (mode & 0x111) !=
          0; // 0x111 = 0b001001001 (x per owner, group, others)

      if (!isExecutable) {
        return false;
      }

      // Leggi i primi 4 byte per verificare il magic number ELF
      final randomAccessFile = await file.open();
      try {
        final bytes = await randomAccessFile.read(4);
        await randomAccessFile.close();

        // ELF magic: 0x7F 'E' 'L' 'F'
        if (bytes.length >= 4) {
          return bytes[0] == 0x7F &&
              bytes[1] == 0x45 && // 'E'
              bytes[2] == 0x4C && // 'L'
              bytes[3] == 0x46; // 'F'
        }
      } catch (e) {
        // Se non riesce a leggere, non è un eseguibile ELF
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Esegue un eseguibile direttamente (per eseguibili Flutter e altri ELF)
  /// Mantiene xdg-open per tutti gli altri file
  static Future<bool> executeFile(String filePath) async {
    try {
      // Verifica se è un eseguibile ELF
      if (await isElfExecutable(filePath)) {
        // Esegui direttamente l'eseguibile in background (detached)
        await Process.start(
          filePath,
          [],
          mode: ProcessStartMode.detached,
          runInShell: false,
        );

        // Non aspettare il completamento, l'eseguibile gira in background
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Tipo filesystem (colonna TYPE di `df -T`, Linux).
  static Future<String> getFilesystemType(String mountPath) async {
    if (!Platform.isLinux) return '';
    try {
      final result = await Process.run('df', ['-T', mountPath]);
      final lines = result.stdout.toString().trim().split('\n');
      if (lines.length >= 2) {
        final parts = lines[1].trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) return parts[1];
      }
    } catch (_) {}
    return '';
  }

  static Future<Map<String, dynamic>> getDiskInfo(String path) async {
    try {
      if (Platform.isLinux) {
        final gnu = await Process.run(
          'df',
          [
            '-B1',
            '--output=size,used,avail',
            path,
          ],
          environment: cLocaleEnvironment(),
        );
        if (gnu.exitCode == 0) {
          final lines = gnu.stdout.toString().trim().split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].trim().split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              final total = int.tryParse(parts[0]) ?? 0;
              final used = int.tryParse(parts[1]) ?? 0;
              final free = int.tryParse(parts[2]) ?? 0;
              if (total > 0) {
                return {
                  'path': path,
                  'name': path.split('/').last,
                  'total': total,
                  'used': used,
                  'free': free,
                };
              }
            }
          }
        }
      }

      final result = await Process.run(
        'df',
        ['-B1', path],
        environment: cLocaleEnvironment(),
      );
      final lines = result.stdout.toString().split('\n');
      if (lines.length > 1) {
        final parts = lines[1].trim().split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          final total = int.tryParse(parts[1]) ?? 0;
          final used = int.tryParse(parts[2]) ?? 0;
          final free = int.tryParse(parts[3]) ?? 0;

          return {
            'path': path,
            'name': path.split('/').last,
            'total': total,
            'used': used,
            'free': free,
          };
        }
      }
    } catch (e) {
      // Fallback
    }

    return {
      'path': path,
      'name': path.split('/').last,
      'total': 0,
      'used': 0,
      'free': 0,
    };
  }

  static int _getOptimalBufferSize(String diskType) {
    switch (diskType) {
      case 'nvme':
        return 16 *
            1024 *
            1024; // 16MB for NVME (aumentato per velocità massima)
      case 'ssd':
        return 8 * 1024 * 1024; // 8MB for SSD (aumentato per velocità alta)
      case 'hdd':
        return 4 * 1024 * 1024; // 4MB for HDD (aumentato per velocità media)
      case 'network':
        return 512 * 1024; // NFS/CIFS/FUSE: buffer piccoli, meno latenza
      default:
        return 8 * 1024 * 1024; // 8MB default (aumentato)
    }
  }

  // Public method for getting optimal buffer size
  static int getOptimalBufferSize(String diskType) {
    return _getOptimalBufferSize(diskType);
  }

  // Public method for getting disk type for a path
  static Future<String> getDiskTypeForPath(String filePath) async {
    return await _getDiskTypeForPath(filePath);
  }

  /// Profilo I/O: filesystem di rete/FUSE vs tipo disco (rotational). `df -T` è GNU/Linux.
  static Future<String> getIoProfileForPath(String filePath) async {
    if (Platform.isLinux) {
      try {
        final result = await Process.run('df', ['-T', filePath]);
        final lines = result.stdout.toString().split('\n');
        if (lines.length > 1) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            final fstype = parts[1].toLowerCase();
            if (fstype == 'nfs' ||
                fstype == 'nfs4' ||
                fstype == 'cifs' ||
                fstype == 'smb3' ||
                fstype == 'smb2' ||
                fstype == 'fuse.sshfs' ||
                fstype == 'fuseblk' ||
                fstype.startsWith('fuse')) {
              return 'network';
            }
            if (fstype == 'tmpfs') {
              return 'ssd';
            }
          }
        }
      } catch (_) {}
    }
    return _getDiskTypeForPath(filePath);
  }

  static Future<String> _getDiskTypeForPath(String filePath) async {
    try {
      // Find which disk this path is on
      final result = await Process.run('df', ['-T', filePath]);
      final lines = result.stdout.toString().split('\n');
      if (lines.length > 1) {
        final parts = lines[1].trim().split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final device = parts[0];
          return await getDiskType(device);
        }
      }
    } catch (e) {
      // Ignore
    }
    return 'unknown';
  }

  static Future<String> getDiskType(String devicePath) async {
    try {
      // Extract device name from path (e.g., /dev/sda1 -> sda)
      final deviceMatch = RegExp(r'/([a-z]+)(\d+)?').firstMatch(devicePath);
      if (deviceMatch == null) return 'unknown';

      final deviceName = deviceMatch.group(1) ?? '';

      // Check if it's NVME
      if (deviceName.startsWith('nvme')) {
        return 'nvme';
      }

      // Check rotational flag
      final rotationalFile = File('/sys/block/$deviceName/queue/rotational');
      if (await rotationalFile.exists()) {
        final content = await rotationalFile.readAsString();
        final isRotational = content.trim() == '1';
        return isRotational ? 'hdd' : 'ssd';
      }

      // Fallback: check via lsblk
      try {
        final result = await Process.run('lsblk', [
          '-d',
          '-o',
          'NAME,ROTA',
          '-n',
        ]);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 2 && parts[0] == deviceName) {
            return parts[1] == '1' ? 'hdd' : 'ssd';
          }
        }
      } catch (e) {
        // Ignore
      }

      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Mount da non mostrare nella sidebar (snap, portal documenti, container, tmp fuse).
  static bool isSidebarMountNoise(String mountPoint) {
    final mp = mountPoint.trim();
    if (mp.isEmpty) return true;
    if (mp.startsWith('/snap/')) return true;
    if (mp.startsWith('/var/lib/snapd/')) return true;
    if (mp.startsWith('/var/lib/flatpak/')) return true;
    if (mp.startsWith('/var/lib/docker/')) return true;
    if (mp.startsWith('/var/lib/containers/')) return true;
    if (RegExp(r'^/run/user/\d+/doc(?:/|$)').hasMatch(mp)) return true;
    if (mp.startsWith('/tmp/.mount_')) return true;
    return false;
  }

  static Future<List<Map<String, dynamic>>> getMountedDisks() async {
    final List<Map<String, dynamic>> disks = [];

    try {
      // PATH evita ambiguità (es. nvme, mapper); getDiskInfo in parallelo per velocità.
      final result = await Process.run('lsblk', [
        '-o',
        'NAME,LABEL,MOUNTPOINT,SIZE,TYPE,PATH',
        '-P',
        '-n',
      ]);
      final lines = result.stdout.toString().split('\n');

      final pending = <Map<String, String>>[];

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        String? diskName;
        String? label;
        String? mountPoint;
        String? type;
        String? pathDev;

        final nameMatch = RegExp(r'NAME="([^"]*)"').firstMatch(line);
        if (nameMatch != null) diskName = nameMatch.group(1);

        final labelMatch = RegExp(r'LABEL="([^"]*)"').firstMatch(line);
        if (labelMatch != null) label = labelMatch.group(1);

        final mountMatch = RegExp(r'MOUNTPOINT="([^"]*)"').firstMatch(line);
        if (mountMatch != null) mountPoint = mountMatch.group(1);

        final typeMatch = RegExp(r'TYPE="([^"]*)"').firstMatch(line);
        if (typeMatch != null) type = typeMatch.group(1);

        final pathMatch = RegExp(r'PATH="([^"]*)"').firstMatch(line);
        if (pathMatch != null) {
          final p = pathMatch.group(1)!;
          if (p.isNotEmpty && p != '-') pathDev = p;
        }

        if (mountPoint != null &&
            mountPoint != '-' &&
            mountPoint.isNotEmpty &&
            mountPoint.startsWith('/') &&
            !mountPoint.startsWith('/proc') &&
            !mountPoint.startsWith('/sys') &&
            !mountPoint.startsWith('/dev') &&
            !mountPoint.startsWith('/run') &&
            !mountPoint.startsWith('/tmp') &&
            !mountPoint.startsWith('/boot') &&
            (type == 'part' ||
                type == 'disk' ||
                type == 'loop' ||
                type == 'crypt')) {
          if (isSidebarMountNoise(mountPoint)) continue;
          String displayName;
          if (label != null && label.isNotEmpty && label != '-') {
            displayName = label;
          } else {
            if (mountPoint.startsWith('/media/')) {
              final parts = mountPoint.split('/');
              displayName = parts.length > 2
                  ? parts[2]
                  : mountPoint.split('/').last;
            } else if (mountPoint.startsWith('/mnt/')) {
              final parts = mountPoint.split('/');
              displayName = parts.length > 2
                  ? parts[2]
                  : mountPoint.split('/').last;
            } else {
              displayName = mountPoint.split('/').last.isEmpty
                  ? 'Root'
                  : mountPoint.split('/').last;
            }
          }
          final block =
              pathDev ??
              (diskName != null && diskName.isNotEmpty ? '/dev/$diskName' : '');
          pending.add({
            'mount_point': mountPoint,
            'display_name': displayName,
            'name': diskName ?? mountPoint.split('/').last,
            'device': diskName ?? '',
            'block_device': block,
          });
        }
      }

      if (pending.isNotEmpty) {
        final enriched = await Future.wait(
          pending.map((p) async {
            final mountPoint = p['mount_point']!;
            try {
              final info = await getDiskInfo(mountPoint);
              info['display_name'] = p['display_name'];
              info['name'] = p['name'];
              info['mount_point'] = mountPoint;
              info['device'] = p['device'];
              if (p['block_device']!.isNotEmpty) {
                info['block_device'] = p['block_device'];
              }
              return info;
            } catch (_) {
              return <String, dynamic>{};
            }
          }),
        );
        for (final e in enriched) {
          if (e.isNotEmpty) disks.add(e);
        }
      }

      // Fallback to df if lsblk fails
      if (disks.isEmpty) {
        final dfResult = await Process.run('df', ['-h']);
        final dfLines = dfResult.stdout.toString().split('\n');
        final mpList = <String>[];

        for (int i = 1; i < dfLines.length; i++) {
          final line = dfLines[i].trim();
          if (line.isEmpty) continue;

          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 6) {
            final mountPoint = parts[5];
            if (mountPoint.startsWith('/') &&
                !mountPoint.startsWith('/proc') &&
                !mountPoint.startsWith('/sys') &&
                !mountPoint.startsWith('/dev') &&
                !mountPoint.startsWith('/run') &&
                !isSidebarMountNoise(mountPoint)) {
              mpList.add(mountPoint);
            }
          }
        }

        final enriched = await Future.wait(
          mpList.map((mountPoint) async {
            try {
              final info = await getDiskInfo(mountPoint);
              String displayName;
              if (mountPoint.startsWith('/media/')) {
                final p = mountPoint.split('/');
                displayName = p.length > 2 ? p[2] : mountPoint.split('/').last;
              } else if (mountPoint.startsWith('/mnt/')) {
                final p = mountPoint.split('/');
                displayName = p.length > 2 ? p[2] : mountPoint.split('/').last;
              } else {
                displayName = mountPoint.split('/').last.isEmpty
                    ? 'Root'
                    : mountPoint.split('/').last;
              }
              info['display_name'] = displayName;
              info['mount_point'] = mountPoint;
              return info;
            } catch (_) {
              return <String, dynamic>{};
            }
          }),
        );
        for (final e in enriched) {
          if (e.isNotEmpty) disks.add(e);
        }
      }
    } catch (e) {
      // Error reading mounts
    }

    return disks;
  }

  static Future<bool> unmountDisk(String mountPoint) async {
    try {
      // Try umount first
      final result = await Process.run('umount', [mountPoint]);
      if (result.exitCode == 0) {
        return true;
      }
      // Try with sudo if needed
      final sudoResult = await Process.run('sudo', ['umount', mountPoint]);
      return sudoResult.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<String> detectLinuxDistro() async {
    try {
      final file = File('/etc/os-release');
      if (await file.exists()) {
        final content = await file.readAsString();
        for (final line in content.split('\n')) {
          if (line.startsWith('ID=')) {
            return line.substring(3).replaceAll('"', '').trim();
          }
        }
      }
    } catch (e) {
      // Error reading os-release
    }
    return 'unknown';
  }

  static bool _isSearchableMountTarget(String t) {
    if (t.isEmpty) return false;
    if (Platform.isWindows) {
      return t.length >= 2 && t[1] == ':';
    }
    if (!t.startsWith('/')) return false;
    if (t == '/proc' || t.startsWith('/proc/')) return false;
    if (t == '/sys' || t.startsWith('/sys/')) return false;
    if (t == '/dev' || t.startsWith('/dev/')) return false;
    if (t.startsWith('/run/credentials')) return false;
    if (t.startsWith('/snap/')) return false;
    if (t.startsWith('/var/lib/docker/')) return false;
    if (t.startsWith('/run/')) {
      if (t.startsWith('/run/media/') ||
          t.contains('/gvfs') ||
          t.contains('/fm_cifs_')) {
        return true;
      }
      return false;
    }
    return true;
  }

  /// Punti di innesco per la ricerca file su tutti i volumi (locali, USB, GVFS, …).
  static Future<List<String>> getSearchableMountPoints() async {
    if (Platform.isWindows) {
      final roots = <String>[];
      for (var i = 0; i < 26; i++) {
        final letter = String.fromCharCode(65 + i);
        final drive = '$letter:\\';
        try {
          if (Directory(drive).existsSync()) roots.add(drive);
        } catch (_) {}
      }
      return roots.isEmpty ? ['C:\\'] : roots;
    }

    if (Platform.isMacOS) {
      final paths = <String>{'/'};
      try {
        final volumes = Directory('/Volumes');
        if (volumes.existsSync()) {
          for (final e in volumes.listSync(followLinks: false)) {
            if (e is Directory) paths.add(e.path);
          }
        }
      } catch (_) {}
      return paths.toList();
    }

    final collected = <String>{};
    try {
      final r = await Process.run('findmnt', ['-rn', '-o', 'TARGET']);
      if (r.exitCode == 0) {
        for (final line in r.stdout.toString().split('\n')) {
          final t = line.trim();
          if (_isSearchableMountTarget(t)) collected.add(t);
        }
      }
    } catch (_) {}

    // Unisci sempre i mount da lsblk/df: findmnt può omettere sotto-mount (es. /mnt/…).
    try {
      final disks = await getMountedDisks();
      for (final d in disks) {
        final m = d['mount_point'] as String? ?? d['path'] as String?;
        if (m != null && _isSearchableMountTarget(m)) collected.add(m);
      }
    } catch (_) {}

    await _addGvfsFuseSearchRoots(collected);

    // /mnt/<uuid> e simili: spesso assenti da findmnt/lsblk come mount “pulito” ma sono cartelle reali
    // (bind, btrfs, udisks, …). Includerle come radici evita che Find funzioni solo su NFS ecc.
    await _addFirstLevelDirectoriesAsRoots(collected, '/mnt');
    await _addFirstLevelDirectoriesAsRoots(collected, '/media');

    if (collected.isEmpty) return ['/'];
    final list = collected.toList()
      ..sort((a, b) {
        // Cerca prima mount “specifici” (/home, /mnt, GVFS…): `/` per ultimo evita che la ricerca
        // sembri bloccata solo sul filesystem root.
        if (a == '/') return 1;
        if (b == '/') return -1;
        return a.length.compareTo(b.length);
      });
    return list;
  }

  /// Ogni sottocartella diretta (es. `/mnt/<uuid>`, `/media/<etichetta>`) come radice di ricerca.
  static Future<void> _addFirstLevelDirectoriesAsRoots(
    Set<String> collected,
    String parent,
  ) async {
    if (!Platform.isLinux) return;
    final dir = Directory(parent);
    if (!await dir.exists()) return;
    var anyChild = false;
    try {
      await for (final ent in dir.list(followLinks: false)) {
        if (ent is! Directory) continue;
        anyChild = true;
        final p = ent.path;
        final norm = p.endsWith(Platform.pathSeparator)
            ? p
            : '$p${Platform.pathSeparator}';
        if (_isSearchableMountTarget(norm)) collected.add(norm);
      }
    } catch (_) {}
    // Se non riusciamo a elencare i figli (permessi) ma /mnt o /media è leggibile, usa il genitore.
    if (!anyChild && (parent == '/mnt' || parent == '/media')) {
      final norm = parent.endsWith(Platform.pathSeparator)
          ? parent
          : '$parent${Platform.pathSeparator}';
      if (_isSearchableMountTarget(norm)) collected.add(norm);
    }
  }

  /// Aggiunge condivisioni GVFS/FUSE (spesso assenti da findmnt) così Find include rete montata.
  static Future<void> _addGvfsFuseSearchRoots(Set<String> collected) async {
    if (!Platform.isLinux) return;
    try {
      var uid = Platform.environment['UID']?.trim() ?? '';
      if (uid.isEmpty) {
        uid = (await Process.run('id', ['-u'])).stdout.toString().trim();
      }
      if (uid.isEmpty) return;

      Future<void> scanGvfs(String gvfsRoot) async {
        final gd = Directory(gvfsRoot);
        if (!await gd.exists()) return;
        await for (final e in gd.list(followLinks: false)) {
          if (e is! Directory) continue;
          final p = e.path;
          final leaf = p.split('/').last.toLowerCase();
          if (leaf.contains('smb-share') ||
              leaf.contains('cifs') ||
              leaf.contains('ftp') ||
              leaf.contains('sftp') ||
              leaf.contains('dav')) {
            final norm = p.endsWith('/') ? p : '$p/';
            if (_isSearchableMountTarget(norm)) collected.add(norm);
          }
        }
      }

      await scanGvfs('/run/user/$uid/gvfs');

      final runUser = Directory('/run/user');
      if (await runUser.exists()) {
        await for (final udir in runUser.list(followLinks: false)) {
          if (udir is! Directory) continue;
          await scanGvfs('${udir.path}/gvfs');
        }
      }
    } catch (_) {}
  }
}
