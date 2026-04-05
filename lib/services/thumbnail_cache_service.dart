import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ThumbnailCacheService {
  static const int maxCacheSize = 256 * 1024 * 1024;
  static Directory? _cacheDir;

  static Future<void> initialize() async {
    final appDir = await getApplicationCacheDirectory();
    _cacheDir = Directory(path.join(appDir.path, 'thumbnails'));
    await _cacheDir!.create(recursive: true);
  }

  static String _getCacheKey(String filePath) {
    final bytes = utf8.encode(filePath);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<String?> getCachedThumbnail(String filePath) async {
    if (_cacheDir == null) await initialize();
    
    final key = _getCacheKey(filePath);
    final cachedFile = File(path.join(_cacheDir!.path, '$key.thumb'));
    
    if (await cachedFile.exists()) {
      return cachedFile.path;
    }
    return null;
  }

  static Future<void> saveThumbnail(String filePath, Uint8List thumbnailData) async {
    if (_cacheDir == null) await initialize();
    
    // Check cache size and clean if needed
    await _cleanCacheIfNeeded(thumbnailData.length);
    
    final key = _getCacheKey(filePath);
    final cachedFile = File(path.join(_cacheDir!.path, '$key.thumb'));
    
    await cachedFile.writeAsBytes(thumbnailData);
    
    // Update metadata
    final metadataFile = File(path.join(_cacheDir!.path, '$key.meta'));
    await metadataFile.writeAsString(jsonEncode({
      'original_path': filePath,
      'size': thumbnailData.length,
      'created': DateTime.now().toIso8601String(),
    }));
  }

  static Future<void> _cleanCacheIfNeeded(int newFileSize) async {
    if (_cacheDir == null) await initialize();
    
    int totalSize = 0;
    final files = <File>[];
    
    await for (final entity in _cacheDir!.list()) {
      if (entity is File && entity.path.endsWith('.thumb')) {
        final stat = await entity.stat();
        totalSize += stat.size;
        files.add(entity);
      }
    }
    
    if (totalSize + newFileSize > maxCacheSize) {
      // Sort by modification time (oldest first)
      final fileStats = <MapEntry<File, FileStat>>[];
      for (final file in files) {
        final stat = await file.stat();
        fileStats.add(MapEntry(file, stat));
      }
      fileStats.sort((a, b) => a.value.modified.compareTo(b.value.modified));
      final sortedFiles = fileStats.map((e) => e.key).toList();
      
      // Remove oldest files until we have enough space
      for (final file in sortedFiles) {
        if (totalSize + newFileSize <= maxCacheSize) break;
        
        final stat = await file.stat();
        await file.delete();
        totalSize -= stat.size;
        
        // Also delete metadata
        final metaFile = File(file.path.replaceAll('.thumb', '.meta'));
        if (await metaFile.exists()) {
          await metaFile.delete();
        }
      }
    }
  }

  static Future<int> getCacheSize() async {
    if (_cacheDir == null) await initialize();
    
    int totalSize = 0;
    await for (final entity in _cacheDir!.list()) {
      if (entity is File && entity.path.endsWith('.thumb')) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    return totalSize;
  }

  static Future<void> clearCache() async {
    if (_cacheDir == null) await initialize();
    
    await for (final entity in _cacheDir!.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  /// Drops oldest thumbnails when cache is above ~70% of [maxCacheSize].
  static Future<void> maintenanceTrim() async {
    if (_cacheDir == null) await initialize();
    final threshold = (maxCacheSize * 0.72).round();
    int totalSize = 0;
    final fileStats = <MapEntry<File, FileStat>>[];
    await for (final entity in _cacheDir!.list()) {
      if (entity is File && entity.path.endsWith('.thumb')) {
        final stat = await entity.stat();
        totalSize += stat.size;
        fileStats.add(MapEntry(entity, stat));
      }
    }
    if (totalSize <= threshold) return;
    fileStats.sort((a, b) => a.value.modified.compareTo(b.value.modified));
    final target = (maxCacheSize * 0.55).round();
    for (final e in fileStats) {
      if (totalSize <= target) break;
      final f = e.key;
      final stat = e.value;
      await f.delete();
      totalSize -= stat.size;
      final meta = File(f.path.replaceAll('.thumb', '.meta'));
      if (await meta.exists()) await meta.delete();
    }
  }
}
