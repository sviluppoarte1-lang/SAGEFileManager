import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

/// Segnale annullamento compressione ZIP (utente ha chiuso la barra).
class ZipCompressionCancelled implements Exception {
  ZipCompressionCancelled();
}

class ArchiveService {
  static const String zipEncodingProgressToken = '__zip_encoding__';

  static Future<void> extractZip(String archivePath, String destDir) async {
    final file = File(archivePath);
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (filename.isEmpty) continue;

      final outputPath = path.join(destDir, filename);
      if (file.isFile) {
        final outputFile = File(outputPath);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
  }

  static Future<void> extractTarGz(String archivePath, String destDir) async {
    final file = File(archivePath);
    final bytes = await file.readAsBytes();
    final archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

    for (final file in archive) {
      final filename = file.name;
      if (filename.isEmpty) continue;

      final outputPath = path.join(destDir, filename);
      if (file.isFile) {
        final outputFile = File(outputPath);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
  }

  static Future<void> extractRar(String archivePath, String destDir) async {
    // RAR extraction requires external tool
    try {
      await Process.run('unrar', ['x', archivePath, destDir]);
    } catch (e) {
      throw Exception('unrar not installed or error extracting RAR file');
    }
  }

  static Future<void> extract7z(String archivePath, String destDir) async {
    // 7z extraction requires external tool
    try {
      await Process.run('7z', ['x', archivePath, '-o$destDir']);
    } catch (e) {
      throw Exception('7z not installed or error extracting 7z file');
    }
  }

  static Future<void> extractArchive(String archivePath, String destDir) async {
    final ext = path.extension(archivePath).toLowerCase();

    switch (ext) {
      case '.zip':
        await extractZip(archivePath, destDir);
        break;
      case '.tar.gz':
      case '.tgz':
        await extractTarGz(archivePath, destDir);
        break;
      case '.rar':
        await extractRar(archivePath, destDir);
        break;
      case '.7z':
        await extract7z(archivePath, destDir);
        break;
      default:
        throw Exception('Unsupported archive format: $ext');
    }
  }

  static bool isArchive(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.zip', '.rar', '.tar.gz', '.tgz', '.7z'].contains(ext);
  }

  /// Picks `name.zip`, `name (2).zip`, … in [directory] (must exist).
  static Future<String> uniqueZipPath(String directory, String name) async {
    var base = name;
    if (base.toLowerCase().endsWith('.zip')) {
      base = base.substring(0, base.length - 4);
    }
    if (base.isEmpty) base = 'Archive';
    var candidate = path.join(directory, '$base.zip');
    if (!await File(candidate).exists()) return candidate;
    for (var i = 2; i < 10000; i++) {
      candidate = path.join(directory, '$base ($i).zip');
      if (!await File(candidate).exists()) return candidate;
    }
    candidate = path.join(
      directory,
      '$base-${DateTime.now().millisecondsSinceEpoch}.zip',
    );
    return candidate;
  }

  static Future<void> _addDirectoryToArchive(
    Archive archive,
    String dirAbs,
    String zipRootPrefix,
    void Function(String zipPath, List<int> data) addFile,
    void Function(int bytesAdded, String displayPath)? onBytesAdded,
    bool Function()? isCancelled,
  ) async {
    final dir = Directory(dirAbs);
    if (!await dir.exists()) return;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (isCancelled?.call() == true) {
        throw ZipCompressionCancelled();
      }
      final rel = path.relative(entity.path, from: dirAbs);
      final zipPath = path
          .join(zipRootPrefix, rel)
          .replaceAll(r'\', '/');
      final data = await entity.readAsBytes();
      onBytesAdded?.call(data.length, zipPath);
      addFile(zipPath, data);
    }
  }

  /// Somma approssimativa dei byte da leggere (stessi percorsi di [createZipFromPaths]).
  static Future<int> estimateZipSourcesBytes(
    List<String> sourceAbsolutePaths,
  ) async {
    var total = 0;
    final normalized = <String>[];
    for (final raw in sourceAbsolutePaths) {
      final abs = path.normalize(File(raw).absolute.path);
      if (!normalized.contains(abs)) normalized.add(abs);
    }
    for (final abs in normalized) {
      final type = FileSystemEntity.typeSync(abs);
      if (type == FileSystemEntityType.file) {
        try {
          total += await File(abs).length();
        } catch (_) {}
      } else if (type == FileSystemEntityType.directory) {
        final dir = Directory(abs);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              try {
                total += await entity.length();
              } catch (_) {}
            }
          }
        }
      }
    }
    return total;
  }

  /// Builds a .zip containing the given files and/or directories.
  static Future<void> createZipFromPaths({
    required List<String> sourceAbsolutePaths,
    required String zipFileAbsolutePath,
    void Function(int cumulativeBytesRead, String? currentPath)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final archive = Archive();
    final used = <String>{};
    final usedRoots = <String>{};
    var cumulative = 0;

    void bumpProgress(String? current) {
      onProgress?.call(cumulative, current);
    }

    String dedupe(String zipPath) {
      var z = zipPath.replaceAll(r'\', '/');
      if (!used.contains(z)) return z;
      final d = path.dirname(z);
      final stem = path.basenameWithoutExtension(z);
      final ext = path.extension(z);
      for (var i = 2; i < 10000; i++) {
        final candidate = (d == '.' || d.isEmpty)
            ? '$stem ($i)$ext'
            : '$d/$stem ($i)$ext';
        final c = candidate.replaceAll(r'\', '/');
        if (!used.contains(c)) return c;
      }
      return z;
    }

    void addFile(String zipPath, List<int> data) {
      final p = dedupe(zipPath);
      used.add(p);
      archive.addFile(ArchiveFile(p, data.length, data));
    }

    final normalized = <String>[];
    for (final raw in sourceAbsolutePaths) {
      final abs = path.normalize(File(raw).absolute.path);
      if (!normalized.contains(abs)) normalized.add(abs);
    }

    for (final abs in normalized) {
      if (isCancelled?.call() == true) {
        throw ZipCompressionCancelled();
      }
      final type = FileSystemEntity.typeSync(abs);
      if (type == FileSystemEntityType.file) {
        final data = await File(abs).readAsBytes();
        cumulative += data.length;
        bumpProgress(path.basename(abs));
        addFile(path.basename(abs), data);
      } else if (type == FileSystemEntityType.directory) {
        var root = path.basename(abs);
        if (usedRoots.contains(root)) {
          for (var i = 2; i < 10000; i++) {
            final alt = '${path.basename(abs)} ($i)';
            if (!usedRoots.contains(alt)) {
              root = alt;
              break;
            }
          }
        }
        usedRoots.add(root);
        await _addDirectoryToArchive(
          archive,
          abs,
          root,
          addFile,
          (bytes, displayPath) {
            cumulative += bytes;
            bumpProgress(displayPath);
          },
          isCancelled,
        );
      }
    }

    if (isCancelled?.call() == true) {
      throw ZipCompressionCancelled();
    }
    bumpProgress(zipEncodingProgressToken);
    final zipBytes = ZipEncoder().encode(archive);
    await File(zipFileAbsolutePath).writeAsBytes(zipBytes);
  }
}
