import 'dart:io';

import 'package:path/path.dart' as path;

/// Metadati cestino secondo lo spec FreeDesktop (`~/.local/share/Trash`).
class DesktopTrash {
  static String filesDir(String home) =>
      path.join(home, '.local/share/Trash/files');

  static String infoDir(String home) =>
      path.join(home, '.local/share/Trash/info');

  /// Sposta file o cartella nel cestino scrivendo il relativo `.trashinfo`.
  static Future<void> moveToTrash(String home, String sourcePath) async {
    final fDir = filesDir(home);
    final iDir = infoDir(home);
    await Directory(fDir).create(recursive: true);
    await Directory(iDir).create(recursive: true);

    final baseName = path.basename(sourcePath);
    var destName = baseName;
    var destPath = path.join(fDir, destName);
    var infoName = '$destName.trashinfo';
    var n = 1;
    while (await File(destPath).exists() || await Directory(destPath).exists()) {
      destName = '$baseName.$n';
      destPath = path.join(fDir, destName);
      infoName = '$destName.trashinfo';
      n++;
    }

    final absOrig = path.isAbsolute(sourcePath)
        ? sourcePath
        : path.absolute(sourcePath);
    final pathField = Uri.file(absOrig, windows: false).toString();
    final deletionDate =
        DateTime.now().toUtc().toIso8601String().split('.').first;
    final infoBody =
        '[Trash Info]\nPath=$pathField\nDeletionDate=$deletionDate\n';
    await File(path.join(iDir, infoName)).writeAsString(infoBody);

    final file = File(sourcePath);
    final dir = Directory(sourcePath);
    if (await file.exists()) {
      await file.rename(destPath);
    } else if (await dir.exists()) {
      await dir.rename(destPath);
    } else {
      try {
        await File(path.join(iDir, infoName)).delete();
      } catch (_) {}
      throw FileSystemException('Path not found for trash', sourcePath);
    }
  }

  /// Percorso originale dal file `info/<nomeNelCestino>.trashinfo`, o null.
  static Future<String?> readOriginalPath(String home, String trashBasename) async {
    final infoPath = path.join(infoDir(home), '$trashBasename.trashinfo');
    final infoFile = File(infoPath);
    if (!await infoFile.exists()) return null;
    try {
      final text = await infoFile.readAsString();
      for (final raw in text.split('\n')) {
        final line = raw.trim();
        if (line.startsWith('Path=')) {
          final encoded = line.substring(5).trim();
          if (encoded.startsWith('/')) return encoded;
          final uri = Uri.parse(encoded);
          if (uri.isScheme('file')) {
            return uri.toFilePath(windows: Platform.isWindows);
          }
          if (uri.path.isNotEmpty) return uri.path;
          return encoded;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> deleteTrashInfo(String home, String trashBasename) async {
    try {
      await File(path.join(infoDir(home), '$trashBasename.trashinfo')).delete();
    } catch (_) {}
  }
}
