import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Credenziali SMB per server (IP/host): keyring quando disponibile **e** file JSON in
/// `~/.config/com.sagefile.manager/` (Linux) così **non dipendono** dall’APPLICATION_ID
/// del bundle e sopravvivono a riavvii anche se lo secure storage di sessione fallisce.
class NetworkCredentialsStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    lOptions: LinuxOptions(),
  );

  static const _jsonVersion = 1;
  static const _appConfigDirName = 'com.sagefile.manager';

  static String _storageKey(String server) =>
      'fm_smb_${server.trim().toLowerCase()}';

  static String _serverMapKey(String server) => server.trim().toLowerCase();

  /// Percorso stabile preferito (indipendente da APPLICATION_ID GTK/Flutter).
  static Future<File> _primaryPersistFile() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        final base = Platform.isLinux
            ? '$home/.config/$_appConfigDirName'
            : '$home/Library/Application Support/$_appConfigDirName';
        await Directory(base).create(recursive: true);
        return File('$base/network_smb_credentials.json');
      }
    }
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/network_smb_credentials.json');
  }

  static Future<List<File>> _legacyCredentialFiles() async {
    final files = <File>[];
    final home = Platform.environment['HOME'];
    if (home != null && Platform.isLinux) {
      files.addAll([
        File(
          '$home/.local/share/com.example.filemanager/network_smb_credentials.json',
        ),
        File(
          '$home/.local/share/com.sagefile.manager/network_smb_credentials.json',
        ),
      ]);
    }
    try {
      final d = await getApplicationSupportDirectory();
      files.add(File('${d.path}/network_smb_credentials.json'));
    } catch (_) {}
    return files;
  }

  static Future<File> _persistFile() async {
    final primary = await _primaryPersistFile();
    if (!await primary.exists()) {
      for (final leg in await _legacyCredentialFiles()) {
        if (await leg.exists() && leg.path != primary.path) {
          try {
            await primary.parent.create(recursive: true);
            await leg.copy(primary.path);
            if (Platform.isLinux || Platform.isMacOS) {
              try {
                await Process.run('chmod', ['600', primary.path]);
              } catch (_) {}
            }
            break;
          } catch (_) {}
        }
      }
    }
    return primary;
  }

  static Future<Map<String, dynamic>> _readEntriesFromFile() async {
    try {
      final f = await _persistFile();
      if (!await f.exists()) return {};
      final decoded = jsonDecode(await f.readAsString());
      if (decoded is! Map<String, dynamic>) return {};
      final entries = decoded['entries'];
      if (entries is! Map<String, dynamic>) return {};
      return Map<String, dynamic>.from(entries);
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeEntriesFile(Map<String, dynamic> entries) async {
    final f = await _persistFile();
    await f.parent.create(recursive: true);
    final payload = jsonEncode({
      'v': _jsonVersion,
      'entries': entries,
    });
    await f.writeAsString(payload, flush: true);
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        await Process.run('chmod', ['600', f.path]);
      } catch (_) {}
    }
  }

  /// Salva utente e password per [server] (es. `192.168.1.105`).
  static Future<void> save(
    String server,
    String username,
    String password,
  ) async {
    final u = username.trim();
    final sk = _serverMapKey(server);
    final combined = '$u\x00$password';
    try {
      await _storage.write(key: _storageKey(server), value: combined);
    } catch (_) {}
    try {
      final all = await _readEntriesFromFile();
      all[sk] = {
        'username': u,
        'passwordB64': base64Encode(utf8.encode(password)),
      };
      await _writeEntriesFile(all);
    } catch (_) {}
  }

  static Future<(String username, String password)?> load(String server) async {
    final sk = _serverMapKey(server);
    // Leggi prima il file JSON: persiste tra riavvii anche se il portachiavi
    // (libsecret) non è ancora sbloccato o usa uno storage di sessione.
    try {
      final all = await _readEntriesFromFile();
      final e = all[sk];
      if (e is Map<String, dynamic>) {
        final u = e['username'] as String?;
        final b64 = e['passwordB64'] as String?;
        if (u != null && b64 != null && u.isNotEmpty) {
          return (u, utf8.decode(base64Decode(b64)));
        }
      }
    } catch (_) {}
    try {
      final raw = await _storage.read(key: _storageKey(server));
      if (raw != null && raw.isNotEmpty) {
        final i = raw.indexOf('\x00');
        if (i > 0) {
          return (raw.substring(0, i), raw.substring(i + 1));
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> delete(String server) async {
    final sk = _serverMapKey(server);
    try {
      await _storage.delete(key: _storageKey(server));
    } catch (_) {}
    try {
      final all = await _readEntriesFromFile();
      all.remove(sk);
      await _writeEntriesFile(all);
    } catch (_) {}
  }
}
