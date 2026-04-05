import 'dart:convert';
import 'dart:io';

import 'package:filemanager/models/file_info.dart';

class FileSearchService {
  static bool _skipPathForSystemFilter(String entityPath, bool includeSystemFiles) {
    if (includeSystemFiles) return false;
    if (entityPath.contains('/proc/') ||
        entityPath.contains('/sys/') ||
        entityPath.contains('/dev/') ||
        entityPath.startsWith('/tmp/') ||
        entityPath.contains('/snap/') ||
        entityPath.contains('/var/cache/')) {
      return true;
    }
    if (entityPath.contains('/run/') &&
        !entityPath.contains('/run/media/') &&
        !entityPath.contains('/gvfs/') &&
        !entityPath.contains('/fm_cifs_')) {
      return true;
    }
    return false;
  }

  static bool _preferFindFallback(String searchPath) {
    if (!Platform.isLinux) return false;
    final n = searchPath.trim();
    if (n.isEmpty || n == '/') return true;
    return n.startsWith('/mnt') || n.startsWith('/media');
  }

  /// Normalizza la radice per `find(1)`: non ridurre mai `/` a stringa vuota.
  static String _normalizeFindRoot(String searchPath) {
    var root = searchPath.trim();
    if (root.isEmpty) return '/';
    while (root.length > 1 && root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }
    return root.isEmpty ? '/' : root;
  }

  static Stream<FileSystemEntity> _listRecursiveResilient(Directory directory) {
    return directory.list(recursive: true, followLinks: false).handleError(
          (Object _, StackTrace _) {},
          test: (e) => e is FileSystemException,
        );
  }

  /// Fallback con `find(1)` su `/`, `/mnt`, `/media` se `Directory.list(recursive)` fallisce (permessi, FUSE, …).
  static Stream<FileInfo> _searchFilesStreamFind({
    required String searchPath,
    String? nameFilter,
    String? extensionFilter,
    int? minSize,
    int? maxSize,
    String? fileType,
    String? dateFilter,
    bool includeSystemFiles = false,
    bool Function()? shouldStop,
  }) async* {
    final root = _normalizeFindRoot(searchPath);
    if (root.isEmpty) return;

    final args = <String>[root, '-xdev', '-type', 'f'];
    if (extensionFilter != null && extensionFilter.isNotEmpty) {
      final pat = extensionFilter.startsWith('*.')
          ? '*.${extensionFilter.substring(2)}'
          : '*.$extensionFilter';
      args.addAll(['-iname', pat]);
    } else if (nameFilter != null && nameFilter.isNotEmpty) {
      args.addAll(['-iname', '*${nameFilter.replaceAll("'", '')}*']);
    }

    Process proc;
    try {
      proc = await Process.start(
        'find',
        args,
        environment: {...Platform.environment, 'LC_ALL': 'C'},
      );
    } catch (_) {
      return;
    }

    try {
      await for (final line in proc.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (shouldStop?.call() == true) {
          proc.kill(ProcessSignal.sigterm);
          break;
        }
        final path = line.trim();
        if (path.isEmpty) continue;
        try {
          if (_skipPathForSystemFilter(path, includeSystemFiles)) continue;

          final fileName = path.split('/').last;
          final fileExt =
              fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

          if (extensionFilter != null && extensionFilter.isNotEmpty) {
            if (extensionFilter.startsWith('*.')) {
              final ext = extensionFilter.substring(2).toLowerCase();
              if (fileExt != ext) continue;
            } else if (fileExt != extensionFilter.toLowerCase()) {
              continue;
            }
          }

          if (nameFilter != null && nameFilter.isNotEmpty) {
            if (!fileName.toLowerCase().contains(nameFilter.toLowerCase())) {
              continue;
            }
          }

          final stat = await File(path).stat();
          if (minSize != null && stat.size < minSize) continue;
          if (maxSize != null && stat.size > maxSize) continue;

          if (fileType != null && fileType.isNotEmpty) {
            if (!_matchesFileType(fileName, fileType)) continue;
          }

          if (dateFilter != null && dateFilter.isNotEmpty) {
            if (!_matchesDateFilter(stat.modified, dateFilter)) continue;
          }

          yield FileInfo(
            path: path,
            name: fileName,
            size: stat.size,
            isDir: false,
            modified: stat.modified.millisecondsSinceEpoch ~/ 1000,
            created: stat.changed.millisecondsSinceEpoch ~/ 1000,
          );
        } catch (_) {}
      }
    } catch (_) {}
    try {
      await proc.exitCode;
    } catch (_) {}
  }

  static Stream<FileInfo> searchFilesStream({
    required String searchPath,
    String? nameFilter,
    String? extensionFilter,
    int? minSize,
    int? maxSize,
    String? fileType,
    String? dateFilter,
    bool includeSystemFiles = false,
    bool Function()? shouldStop,
  }) async* {
    try {
      final directory = Directory(searchPath);
      if (!await directory.exists()) return;

      // Ignora errori di permesso su singole directory (fondamentale su / e tree di sistema).
      await for (final entity in _listRecursiveResilient(directory)) {
        if (shouldStop?.call() == true) break;

        try {
          if (!includeSystemFiles) {
            if (_skipPathForSystemFilter(entity.path, false)) continue;
          }

          final fileName = entity.path.split('/').last;
          final fileExt =
              fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

          // Early exit: Check extension filter first (fastest check)
          if (extensionFilter != null && extensionFilter.isNotEmpty) {
            if (extensionFilter.startsWith('*.')) {
              final ext = extensionFilter.substring(2).toLowerCase();
              if (fileExt != ext) continue;
            } else if (fileExt != extensionFilter.toLowerCase()) {
              continue;
            }
          }

          // Early exit: Check name filter before stat (faster)
          if (nameFilter != null && nameFilter.isNotEmpty) {
            if (!fileName.toLowerCase().contains(nameFilter.toLowerCase())) {
              continue;
            }
          }

          // Only stat if filters passed (stat is expensive)
          final stat = await entity.stat();

          // Apply other filters
          if (minSize != null && stat.size < minSize) continue;
          if (maxSize != null && stat.size > maxSize) continue;

          if (fileType != null && fileType.isNotEmpty) {
            if (!_matchesFileType(fileName, fileType)) continue;
          }

          if (dateFilter != null && dateFilter.isNotEmpty) {
            if (!_matchesDateFilter(stat.modified, dateFilter)) continue;
          }

          yield FileInfo(
            path: entity.path,
            name: fileName,
            size: stat.size,
            isDir: entity is Directory,
            modified: stat.modified.millisecondsSinceEpoch ~/ 1000,
            created: stat.changed.millisecondsSinceEpoch ~/ 1000,
          );
        } catch (e) {
          // Skip files that can't be accessed
          continue;
        }
      }
    } on FileSystemException catch (_) {
      if (_preferFindFallback(searchPath)) {
        yield* _searchFilesStreamFind(
          searchPath: searchPath,
          nameFilter: nameFilter,
          extensionFilter: extensionFilter,
          minSize: minSize,
          maxSize: maxSize,
          fileType: fileType,
          dateFilter: dateFilter,
          includeSystemFiles: includeSystemFiles,
          shouldStop: shouldStop,
        );
      }
    } catch (_) {
      if (_preferFindFallback(searchPath)) {
        yield* _searchFilesStreamFind(
          searchPath: searchPath,
          nameFilter: nameFilter,
          extensionFilter: extensionFilter,
          minSize: minSize,
          maxSize: maxSize,
          fileType: fileType,
          dateFilter: dateFilter,
          includeSystemFiles: includeSystemFiles,
          shouldStop: shouldStop,
        );
      }
    }
  }

  /// Cerca su più radici (dedup per path), utile per tutti i volumi montati.
  static Stream<FileInfo> searchFilesStreamMultiRoots({
    required Iterable<String> searchRoots,
    String? nameFilter,
    String? extensionFilter,
    int? minSize,
    int? maxSize,
    String? fileType,
    String? dateFilter,
    bool includeSystemFiles = false,
    bool Function()? shouldStop,
  }) async* {
    final seen = <String>{};
    for (final root in searchRoots) {
      if (shouldStop?.call() == true) break;
      final trimmed = root.trim();
      if (trimmed.isEmpty) continue;
      await for (final fileInfo in searchFilesStream(
        searchPath: trimmed,
        nameFilter: nameFilter,
        extensionFilter: extensionFilter,
        minSize: minSize,
        maxSize: maxSize,
        fileType: fileType,
        dateFilter: dateFilter,
        includeSystemFiles: includeSystemFiles,
        shouldStop: shouldStop,
      )) {
        if (seen.add(fileInfo.path)) {
          yield fileInfo;
        }
      }
    }
  }

  static Future<List<FileInfo>> searchFiles({
    required String searchPath,
    String? nameFilter,
    String? extensionFilter,
    int? minSize,
    int? maxSize,
    String? fileType,
    String? dateFilter,
    bool includeSystemFiles = false,
    Function(int found)? onProgress,
    bool Function()? shouldStop,
  }) async {
    final results = <FileInfo>[];
    
    await for (final fileInfo in searchFilesStream(
      searchPath: searchPath,
      nameFilter: nameFilter,
      extensionFilter: extensionFilter,
      minSize: minSize,
      maxSize: maxSize,
      fileType: fileType,
      dateFilter: dateFilter,
      includeSystemFiles: includeSystemFiles,
      shouldStop: shouldStop,
    )) {
      results.add(fileInfo);
      onProgress?.call(results.length);
    }

    return results;
  }

  /// Canonical keys: images, video, audio, documents, archives, executables
  static bool _matchesFileType(String fileName, String type) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (type) {
      case 'images':
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'].contains(ext);
      case 'video':
        return ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'].contains(ext);
      case 'audio':
        return ['mp3', 'wav', 'flac', 'ogg', 'aac', 'm4a'].contains(ext);
      case 'documents':
        return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'odt', 'ods'].contains(ext);
      case 'archives':
        return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(ext);
      case 'executables':
        return ['exe', 'bin', 'sh', 'deb', 'rpm', 'AppImage'].contains(ext);
      default:
        return true;
    }
  }

  /// Canonical keys: today, week, month, year
  static bool _matchesDateFilter(DateTime fileDate, String filter) {
    final now = DateTime.now();
    final difference = now.difference(fileDate);

    switch (filter) {
      case 'today':
        return difference.inDays == 0;
      case 'week':
        return difference.inDays <= 7;
      case 'month':
        return difference.inDays <= 30;
      case 'year':
        return difference.inDays <= 365;
      default:
        return true;
    }
  }
}
