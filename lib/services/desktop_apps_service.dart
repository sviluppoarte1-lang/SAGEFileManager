import 'dart:io';

import 'package:path/path.dart' as p;

/// One installed application from a `.desktop` file (incl. Snap / Flatpak).
class DesktopAppEntry {
  final String name;
  final String desktopPath;
  final String desktopId;
  final String execLine;

  const DesktopAppEntry({
    required this.name,
    required this.desktopPath,
    required this.desktopId,
    required this.execLine,
  });

  String get subtitle => execLine.isNotEmpty ? execLine : desktopPath;
}

/// Result of the "Open with" dialog — keeps launch and "set default" explicit.
class OpenWithChoice {
  /// Use [xdg-open] with the MIME default (same as double-click).
  const OpenWithChoice.xdgDefault()
      : useXdgDefault = true,
        desktopPath = null,
        customExecutablePath = null,
        setDefaultAfterOpen = false;

  /// Launch via `.desktop` ([gio launch] / [gtk-launch] / Exec fallback).
  const OpenWithChoice.desktop(
    this.desktopPath, {
    this.setDefaultAfterOpen = false,
  })  : useXdgDefault = false,
        customExecutablePath = null;

  /// Raw executable from the file picker.
  const OpenWithChoice.customExecutable(this.customExecutablePath)
      : useXdgDefault = false,
        desktopPath = null,
        setDefaultAfterOpen = false;

  final bool useXdgDefault;
  final String? desktopPath;
  final String? customExecutablePath;
  final bool setDefaultAfterOpen;
}

/// Discovers `.desktop` apps (XDG + Snap + Flatpak) and launches them reliably.
class DesktopAppsService {
  DesktopAppsService._();

  static final _extMimeFallback = {
    '.txt': 'text/plain',
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.odt': 'application/vnd.oasis.opendocument.text',
    '.ods': 'application/vnd.oasis.opendocument.spreadsheet',
    '.odp': 'application/vnd.oasis.opendocument.presentation',
    '.xls': 'application/vnd.ms-excel',
    '.xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.ppt': 'application/vnd.ms-powerpoint',
    '.pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.mp4': 'video/mp4',
    '.mp3': 'audio/mpeg',
    '.zip': 'application/zip',
    '.html': 'text/html',
    '.csv': 'text/csv',
  };

  /// MIME from `xdg-mime query filetype`, then extension fallback.
  static Future<String> queryMimeTypeForPath(String filePath) async {
    try {
      final f = File(filePath);
      if (await f.exists()) {
        final r = await Process.run('xdg-mime', ['query', 'filetype', filePath]);
        if (r.exitCode == 0) {
          final m = r.stdout.toString().trim();
          if (m.isNotEmpty && m != 'inode/directory') {
            return m;
          }
        }
      }
    } catch (_) {}
    final ext = p.extension(filePath).toLowerCase();
    return _extMimeFallback[ext] ?? 'application/octet-stream';
  }

  static List<String> _desktopDirsToScan() {
    final dirs = <String>[];
    void add(String d) {
      if (d.isEmpty) return;
      if (!dirs.contains(d)) dirs.add(d);
    }

    add('/usr/share/applications');
    add('/usr/local/share/applications');
    final xdg = Platform.environment['XDG_DATA_DIRS'] ?? '';
    for (final part in xdg.split(':')) {
      if (part.isEmpty) continue;
      add(p.normalize(p.join(part, 'applications')));
    }
    add('/var/lib/flatpak/exports/share/applications');
    add('/var/lib/snapd/desktop/applications');
    final home = Platform.environment['HOME'];
    if (home != null) {
      add(p.normalize(p.join(home, '.local/share/flatpak/exports/share/applications')));
      add(p.normalize(p.join(home, '.local/share/applications')));
    }
    return dirs;
  }

  static String? _preferredLocaleTag() {
    final lang = (Platform.environment['LC_ALL'] ??
            Platform.environment['LC_MESSAGES'] ??
            Platform.environment['LANG'] ??
            '')
        .trim();
    if (lang.isEmpty) return null;
    // Examples: "it_IT.UTF-8" -> "it_IT", "en_US" -> "en_US", "C" -> null
    final base = lang.split('.').first;
    if (base.isEmpty || base == 'C' || base == 'POSIX') return null;
    return base;
  }

  /// All visible [Type=Application] entries; later directories override IDs (user over system).
  static Future<List<DesktopAppEntry>> discoverApplications() async {
    final byId = <String, DesktopAppEntry>{};

    for (final dirPath in _desktopDirsToScan()) {
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;
      // KDE (and some distro packages) can place desktop files in subfolders
      // like `/usr/share/applications/kde4/…`. Scan recursively.
      await for (final entity in dir.list(followLinks: false, recursive: true)) {
        // Flatpak / Snap exports are often symlinks; include both File and Link.
        if (!entity.path.endsWith('.desktop')) continue;
        if (entity is! File && entity is! Link) continue;
        final entry = await _parseDesktopFile(entity.path);
        if (entry != null) {
          byId[entry.desktopId] = entry;
        }
      }
    }

    final list = byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  static Future<DesktopAppEntry?> _parseDesktopFile(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      var inDesktopEntry = false;
      String? type;
      var noDisplay = false;
      var hidden = false;
      String? name;
      final localizedNames = <String, String>{};
      String? exec;
      final preferredLocale = _preferredLocaleTag();

      for (final raw in content.split('\n')) {
        var line = raw.trimRight();
        if (line.isEmpty || line.startsWith('#')) continue;
        if (line.startsWith('[')) {
          inDesktopEntry = line == '[Desktop Entry]';
          continue;
        }
        if (!inDesktopEntry) continue;
        if (line.startsWith('Type=')) {
          type = line.substring(5).trim();
        } else if (line == 'NoDisplay=true') {
          noDisplay = true;
        } else if (line == 'Hidden=true') {
          hidden = true;
        } else if (line.startsWith('Name=')) {
          name ??= line.substring(5).trim();
        } else if (line.startsWith('Name[')) {
          final close = line.indexOf(']=');
          if (close > 5) {
            final tag = line.substring(5, close).trim();
            final value = line.substring(close + 2).trim();
            if (tag.isNotEmpty && value.isNotEmpty) {
              localizedNames[tag] = value;
            }
          }
        } else if (line.startsWith('Exec=') && exec == null) {
          exec = line.substring(5).trim();
        }
      }

      if (noDisplay || hidden || exec == null || exec.isEmpty) return null;
      if (type != null && type.toLowerCase() != 'application') return null;

      final id = p.basename(filePath);
      return DesktopAppEntry(
        name: (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : (() {
                if (preferredLocale != null) {
                  // Try full tag (it_IT) then base (it)
                  final full = localizedNames[preferredLocale];
                  if (full != null && full.trim().isNotEmpty) return full.trim();
                  final base = preferredLocale.split('_').first;
                  final baseValue = localizedNames[base];
                  if (baseValue != null && baseValue.trim().isNotEmpty) {
                    return baseValue.trim();
                  }
                }
                // Fallback: any localized name
                for (final v in localizedNames.values) {
                  if (v.trim().isNotEmpty) return v.trim();
                }
                return id.replaceAll('.desktop', '');
              })(),
        desktopPath: p.normalize(filePath),
        desktopId: id,
        execLine: exec.length > 96 ? '${exec.substring(0, 93)}…' : exec,
      );
    } catch (_) {
      return null;
    }
  }

  /// Human-readable name for the default `.desktop` id (e.g. from `xdg-mime query default`).
  static Future<String> friendlyNameForDesktopId(String desktopId) async {
    if (desktopId.isEmpty) return desktopId;
    for (final dirPath in _desktopDirsToScan()) {
      final f = File(p.join(dirPath, desktopId));
      if (await f.exists()) {
        final e = await _parseDesktopFile(f.path);
        if (e != null) return e.name;
      }
    }
    return desktopId.replaceAll('.desktop', '');
  }

  /// Current default `.desktop` basename for [mimeType].
  static Future<String?> defaultDesktopIdForMime(String mimeType) async {
    try {
      final r = await Process.run('xdg-mime', ['query', 'default', mimeType]);
      if (r.exitCode != 0) return null;
      final id = r.stdout.toString().trim();
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setDefaultForMime(String desktopId, String mimeType) async {
    if (!desktopId.endsWith('.desktop')) return false;
    try {
      final r = await Process.run('xdg-mime', ['default', desktopId, mimeType]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Launch using `.desktop` so Snap / Flatpak / complex Exec lines work.
  static Future<ProcessResult> launchWithDesktopFile(
    String desktopPath,
    String filePath,
  ) async {
    final pathNorm = p.normalize(desktopPath);
    final fileNorm = p.normalize(filePath);
    final uri = Uri.file(fileNorm, windows: false).toString();

    try {
      final gio = await Process.run('gio', ['launch', pathNorm, fileNorm]);
      if (gio.exitCode == 0) return gio;
    } catch (_) {}

    try {
      final gtk = await Process.run('gtk-launch', [p.basename(pathNorm), uri]);
      if (gtk.exitCode == 0) return gtk;
    } catch (_) {}

    final exec = await _readExecFromDesktop(pathNorm);
    if (exec != null) {
      final cmd = _substituteExecFieldCodes(exec, fileNorm);
      return Process.run('sh', ['-c', cmd], runInShell: false);
    }

    return ProcessResult(-1, 1, '', 'no launcher');
  }

  static Future<String?> _readExecFromDesktop(String desktopPath) async {
    try {
      final content = await File(desktopPath).readAsString();
      var inDesktopEntry = false;
      for (final raw in content.split('\n')) {
        final line = raw.trimRight();
        if (line.startsWith('[')) {
          inDesktopEntry = line == '[Desktop Entry]';
          continue;
        }
        if (inDesktopEntry && line.startsWith('Exec=')) {
          return line.substring(5).trim();
        }
      }
    } catch (_) {}
    return null;
  }

  static String _substituteExecFieldCodes(String exec, String filePath) {
    final uri = Uri.file(filePath, windows: false).toString();
    final escaped = filePath.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    var s = exec;
    s = s.replaceAll('%%', '\x00PERCENT\x00');
    s = s.replaceAll('%f', '"$escaped"');
    s = s.replaceAll('%F', '"$escaped"');
    s = s.replaceAll('%u', uri);
    s = s.replaceAll('%U', uri);
    for (final code in ['%i', '%c', '%k']) {
      s = s.replaceAll(code, '');
    }
    s = s.replaceAll(RegExp(r' %[a-zA-Z]'), '');
    s = s.replaceAll('\x00PERCENT\x00', '%');
    return s.trim();
  }
}
