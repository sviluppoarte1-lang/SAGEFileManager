import 'dart:io';

/// Azioni privilegiate per la schermata Computer (formattazione, protezione volumi di sistema).
class ComputerDiskService {
  static Future<String?> _readlinkF(String p) async {
    try {
      final r = await Process.run('readlink', ['-f', p]);
      if (r.exitCode == 0) {
        final s = r.stdout.toString().trim();
        if (s.isNotEmpty) return s;
      }
    } catch (_) {}
    return p;
  }

  /// Device sorgente del filesystem montato su `/` (es. `/dev/nvme0n1p2`).
  static Future<String?> rootFilesystemSource() async {
    if (!Platform.isLinux) return null;
    try {
      final r = await Process.run('findmnt', ['-n', '-o', 'SOURCE', '/']);
      if (r.exitCode != 0) return null;
      var s = r.stdout.toString().trim();
      if (s.isEmpty) return null;
      if (s.startsWith('/dev/')) {
        return _readlinkF(s);
      }
      return s;
    } catch (_) {}
    return null;
  }

  static Future<String?> _resolvedBlockPath(String? blockDevice) async {
    if (blockDevice == null || blockDevice.isEmpty) return null;
    if (!blockDevice.startsWith('/dev/')) return null;
    return _readlinkF(blockDevice);
  }

  /// True se non si deve offrire la formattazione (/, /boot*, stesso device della root).
  static Future<bool> isProtectedFromFormat({
    required String mountPoint,
    String? blockDevice,
  }) async {
    final mp = mountPoint.trim();
    if (mp == '/' || mp.startsWith('/boot')) return true;

    if (!Platform.isLinux) return false;

    final root = await rootFilesystemSource();
    final mine = await _resolvedBlockPath(blockDevice);
    if (root != null && mine != null && root == mine) return true;

    return false;
  }

  /// Tipi supportati da udisks2 (nomi `udisksctl format --type`).
  static const List<String> udisksFormatTypes = [
    'ext4',
    'vfat',
    'exfat',
    'ntfs',
  ];

  /// Formatta il device a blocchi con udisks2; eventualmente tramite pkexec.
  static Future<({bool ok, String message})> formatBlockDevice({
    required String blockDevice,
    required String fstype,
  }) async {
    if (!Platform.isLinux) {
      return (ok: false, message: 'unsupported_os');
    }
    if (!udisksFormatTypes.contains(fstype)) {
      return (ok: false, message: 'bad_fstype');
    }
    final dev = blockDevice.trim();
    if (!dev.startsWith('/dev/')) {
      return (ok: false, message: 'bad_device');
    }

    try {
      var result = await Process.run(
        'udisksctl',
        ['format', '-b', dev, '--type', fstype],
      ).timeout(const Duration(minutes: 30));

      if (result.exitCode != 0) {
        final err = '${result.stderr}${result.stdout}';
        if (err.toLowerCase().contains('permission') ||
            err.toLowerCase().contains('not authorized') ||
            result.exitCode == 1) {
          result = await Process.run(
            'pkexec',
            ['udisksctl', 'format', '-b', dev, '--type', fstype],
          ).timeout(const Duration(minutes: 30));
        }
      }

      final out = '${result.stderr}${result.stdout}'.trim();
      if (result.exitCode == 0) {
        return (ok: true, message: out.isEmpty ? 'ok' : out);
      }
      return (ok: false, message: out.isEmpty ? 'exit_${result.exitCode}' : out);
    } catch (e) {
      return (ok: false, message: e.toString());
    }
  }
}
