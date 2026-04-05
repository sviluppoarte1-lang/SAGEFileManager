import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:filemanager/services/logging_service.dart';
import 'package:filemanager/services/system_dependencies_service.dart';

/// Risultato montaggio SMB via `mount.cifs` (CIFS).
class NetworkMountOutcome {
  final String? path;

  /// Messaggio tecnico o codice (es. stderr di mount.cifs, `missing_mount_cifs`).
  final String? message;
  const NetworkMountOutcome._(this.path, this.message);
  factory NetworkMountOutcome.ok(String path) =>
      NetworkMountOutcome._(path, null);
  factory NetworkMountOutcome.fail(String message) =>
      NetworkMountOutcome._(null, message);
  bool get isSuccess => path != null && path!.isNotEmpty;
}

class SmbShellLocation {
  final String server;
  final String share;
  /// Percorso nella condivisione senza slash iniziale/finale.
  final String relativePath;

  const SmbShellLocation({
    required this.server,
    required this.share,
    required this.relativePath,
  });
}

/// Servizio per esplorare condivisioni di rete SMB/CIFS
class NetworkBrowserService {
  static bool _smbAuthNeedsCredentialFile(String? username, String password) {
    final u = username ?? '';
    if (u.contains('%')) return true;
    if (password.contains('%') ||
        password.contains('\n') ||
        password.contains('\r')) {
      return true;
    }
    return false;
  }

  static String _workgroupFromEnv() =>
      (Platform.environment['WORKGROUP'] ??
              Platform.environment['SMB_WORKGROUP'] ??
              '')
          .trim();

  static final Map<String, Future<String>> _resolveWorkgroupCache = {};

  /// Workgroup/dominio NetBIOS rilevato per [server] (IP o host), con cache per host.
  /// Usa `WORKGROUP` / `SMB_WORKGROUP` se impostati; altrimenti smbclient, nmblookup, smb.conf, resolv.conf.
  static Future<String> resolveWorkgroupForServer(String server) {
    final key = server.trim().toLowerCase();
    if (key.isEmpty) {
      return Future.value('WORKGROUP');
    }
    return _resolveWorkgroupCache.putIfAbsent(
      key,
      () => _resolveWorkgroupForServerImpl(server.trim()),
    );
  }

  static Future<String> _resolveWorkgroupForServerImpl(String server) async {
    final envWg = _workgroupFromEnv();
    if (envWg.isNotEmpty) {
      _netLog('resolveWorkgroup: using env', {'server': server, 'workgroup': envWg});
      return envWg;
    }

    try {
      final probe = await Process.run(
        'smbclient',
        ['-L', smbUncHost(server), '-N', '-m', 'SMB3'],
      ).timeout(const Duration(seconds: 4));
      final combined = '${probe.stdout}${probe.stderr}';
      final parsed = _parseSmbDomainFromSmbclientOutput(combined);
      if (parsed != null && parsed.isNotEmpty) {
        _netLog('resolveWorkgroup: smbclient probe', {
          'server': server,
          'workgroup': parsed,
        });
        return parsed;
      }
    } catch (e) {
      _netLog('resolveWorkgroup: smbclient probe failed', {
        'server': server,
        'error': e.toString(),
      });
    }

    String? ip = server;
    if (!_looksLikeIpv4(server)) {
      ip = await _primaryIpv4ForHost(server);
    }
    if (ip != null && _looksLikeIpv4(ip)) {
      try {
        final r = await Process.run(
          'nmblookup',
          ['-A', ip],
        ).timeout(const Duration(seconds: 3));
        final wg = _parseWorkgroupFromNmblookup(r.stdout.toString());
        if (wg != null && wg.isNotEmpty) {
          _netLog('resolveWorkgroup: nmblookup', {
            'server': server,
            'ip': ip,
            'workgroup': wg,
          });
          return wg;
        }
      } catch (e) {
        _netLog('resolveWorkgroup: nmblookup failed', {
          'server': server,
          'error': e.toString(),
        });
      }
    }

    final fromConf = _workgroupFromSambaConf();
    if (fromConf != null && fromConf.isNotEmpty) {
      _netLog('resolveWorkgroup: smb.conf', {'workgroup': fromConf});
      return fromConf;
    }

    final fromResolv = _workgroupHintFromResolvConf();
    if (fromResolv != null && fromResolv.isNotEmpty) {
      _netLog('resolveWorkgroup: resolv.conf', {'workgroup': fromResolv});
      return fromResolv;
    }

    return 'WORKGROUP';
  }

  static Future<String?> _primaryIpv4ForHost(String host) async {
    try {
      final list = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 4));
      for (final a in list) {
        if (a.type == InternetAddressType.IPv4) return a.address;
      }
    } catch (_) {}
    return null;
  }

  static String? _parseSmbDomainFromSmbclientOutput(String combined) {
    final domainRe = RegExp(r'Domain=\[([^\]]*)\]', caseSensitive: false);
    final dm = domainRe.firstMatch(combined);
    if (dm != null) {
      final d = dm.group(1)?.trim() ?? '';
      if (d.isNotEmpty) {
        final up = d.toUpperCase();
        if (up != 'UNKNOWN' && up != 'NODOMAIN') return d;
      }
    }
    final lines = combined.split('\n');
    for (var i = 0; i < lines.length - 1; i++) {
      final low = lines[i].toLowerCase();
      if (low.contains('workgroup') && low.contains('master')) {
        for (var j = i + 1; j < lines.length && j < i + 12; j++) {
          final line = lines[j].trim();
          if (line.isEmpty) continue;
          if (line.startsWith(RegExp(r'-{3,}|={3,}'))) continue;
          final lowL = line.toLowerCase();
          if (lowL.contains('workgroup') && lowL.contains('master')) continue;
          final parts = line.split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            final first = parts.first;
            if (first.isNotEmpty &&
                first.toLowerCase() != 'workgroup' &&
                first != '---------') {
              return first;
            }
          }
        }
      }
    }
    return null;
  }

  static String? _parseWorkgroupFromNmblookup(String text) {
    for (final line in text.split('\n')) {
      if (line.contains('<GROUP>')) {
        final m = RegExp(r'^\s*(\S+)\s+<00>').firstMatch(line);
        if (m != null) {
          final w = m.group(1)?.trim();
          if (w != null && w.isNotEmpty) return w;
        }
      }
    }
    return null;
  }

  static String? _workgroupFromSambaConf() {
    try {
      final f = File('/etc/samba/smb.conf');
      if (!f.existsSync()) return null;
      for (final line in f.readAsLinesSync()) {
        final t = line.trim();
        if (t.startsWith('#') || t.startsWith(';')) continue;
        final m = RegExp(
          r'^\s*workgroup\s*=\s*(\S+)',
          caseSensitive: false,
        ).firstMatch(line);
        if (m != null) {
          final w = m.group(1)?.trim();
          if (w != null && w.isNotEmpty) return w;
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _workgroupHintFromResolvConf() {
    try {
      final f = File('/etc/resolv.conf');
      if (!f.existsSync()) return null;
      for (final line in f.readAsLinesSync()) {
        final t = line.trim();
        if (t.isEmpty || t.startsWith('#')) continue;
        final m = RegExp(r'^search\s+(\S+)').firstMatch(t);
        if (m != null) {
          final first = m.group(1)!.split('.').first.trim();
          if (first.isNotEmpty) return first.toUpperCase();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Mount senza privilegi fallito: tipico "no match in /etc/fstab" su molte distro.
  static bool _stderrLooksLikeNeedRootForMount(String combined) {
    final t = combined.toLowerCase();
    if (t.contains('nt_status') || t.contains('status_logon')) return false;
    if (t.contains('/etc/fstab') || t.contains('fstab')) return true;
    if (t.contains('operation not permitted')) return true;
    if (t.contains('permission denied') && t.contains('mount.cifs')) return true;
    return false;
  }

  static bool _stderrLooksLikeNeedCredentials(String stderrOut) {
    final s = stderrOut.toLowerCase();
    if (s.isEmpty) return false;
    return s.contains('password') ||
        s.contains('autenticazione') ||
        s.contains('authentication') ||
        s.contains('credential') ||
        s.contains('logon failure') ||
        s.contains('access denied') ||
        s.contains('domain [') ||
        s.contains('nt_status_logon_failure') ||
        s.contains('permission denied');
  }

  /// Un solo `smbclient` alla volta evita picchi CPU/I/O e blocchi dell’UI.
  static Future<void> _smbClientGate = Future.value();

  static Future<T> _runSerialized<T>(Future<T> Function() action) async {
    final previous = _smbClientGate;
    final gate = Completer<void>();
    _smbClientGate = gate.future;
    await previous;
    try {
      return await action();
    } finally {
      gate.complete();
    }
  }

  static const int _logTextMax = 480;

  static String _trunc(String s) {
    if (s.length <= _logTextMax) return s;
    return '${s.substring(0, _logTextMax)}… (len=${s.length})';
  }

  /// Log di rete senza bloccare: niente `await` su scritture disco per ogni smbclient.
  static void _netLog(String msg, [Map<String, dynamic>? data]) {
    Map<String, dynamic>? d;
    if (data != null) {
      d = {};
      for (final e in data.entries) {
        final v = e.value;
        if (v is String) {
          d[e.key] = _trunc(v);
        } else {
          d[e.key] = v;
        }
      }
    }
    unawaited(LoggingService.network(msg, d));
  }

  static final RegExp _ipv4Re = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

  static bool _looksLikeIpv4(String s) => _ipv4Re.hasMatch(s.trim());

  /// Preferisci un nome host rispetto al solo IP quando più sorgenti scoprono lo stesso indirizzo.
  static String _betterServerDisplayName({
    required String current,
    required String incoming,
    required String address,
  }) {
    final cur = current.trim();
    final inc = incoming.trim();
    final curIp = cur.isEmpty || _looksLikeIpv4(cur);
    final incIp = inc.isEmpty || _looksLikeIpv4(inc);
    if (!curIp && cur.isNotEmpty) return cur;
    if (!incIp && inc.isNotEmpty) return inc;
    if (!curIp) return cur;
    if (!incIp) return inc;
    return address;
  }

  static void _putServer(
    Map<String, Map<String, String>> out,
    String displayName,
    String address,
  ) {
    final addr = address.trim();
    final key = addr.toLowerCase();
    if (key.isEmpty) return;
    var name = displayName.trim().isEmpty ? addr : displayName.trim();
    if (name == '*' || name == '<unknown>') name = addr;

    final existing = out[key];
    if (existing == null) {
      out[key] = {
        'name': _betterServerDisplayName(
          current: '',
          incoming: name,
          address: addr,
        ),
        'type': 'SMB',
        'address': addr,
      };
      return;
    }
    existing['name'] = _betterServerDisplayName(
      current: existing['name'] ?? '',
      incoming: name,
      address: addr,
    );
  }

  static int? _cachedLinuxUid;
  static int? _cachedLinuxGid;

  static Future<int> _linuxEffectiveUid() async {
    if (_cachedLinuxUid != null) return _cachedLinuxUid!;
    var u = int.tryParse(Platform.environment['UID'] ?? '');
    if (u != null && u >= 0) {
      _cachedLinuxUid = u;
      return u;
    }
    try {
      final r = await Process.run('id', ['-u']);
      if (r.exitCode == 0) {
        u = int.tryParse(r.stdout.toString().trim());
      }
    } catch (_) {}
    _cachedLinuxUid = u ?? 1000;
    return _cachedLinuxUid!;
  }

  static Future<int> _linuxEffectiveGid() async {
    if (_cachedLinuxGid != null) return _cachedLinuxGid!;
    var g = int.tryParse(Platform.environment['GID'] ?? '');
    if (g != null && g >= 0) {
      _cachedLinuxGid = g;
      return g;
    }
    try {
      final r = await Process.run('id', ['-g']);
      if (r.exitCode == 0) {
        g = int.tryParse(r.stdout.toString().trim());
      }
    } catch (_) {}
    _cachedLinuxGid = g ?? 1000;
    return _cachedLinuxGid!;
  }

  static final Map<String, String> _activeCifsMounts = {};

  static String _cifsMountKey(String server, String share) =>
      '${server.trim().toLowerCase()}|${share.trim().toLowerCase()}';

  /// Codifica server+share in un segmento di directory senza ambiguità (underscore nel nome host/share).
  static String _cifsMountDirSegment(String server, String share) {
    final raw = '${server.trim()}\x00${share.trim()}';
    final enc = base64Url.encode(utf8.encode(raw)).replaceAll('=', '');
    return enc;
  }

  static ({String server, String share})? _tryDecodeCifsMountSegment(
    String encoded,
  ) {
    try {
      var s = encoded.trim();
      if (s.isEmpty) return null;
      final pad = (4 - s.length % 4) % 4;
      if (pad > 0) s += '=' * pad;
      final decoded = utf8.decode(base64Url.decode(s));
      final z = decoded.indexOf('\x00');
      if (z <= 0 || z >= decoded.length - 1) return null;
      return (
        server: decoded.substring(0, z),
        share: decoded.substring(z + 1),
      );
    } catch (_) {
      return null;
    }
  }

  /// Punto di montaggio previsto per `//server/share` (stesso path usato da [mountShareWithCifs]).
  static String cifsMountPointPath(String server, String share) {
    final seg = _cifsMountDirSegment(server, share);
    return '${Directory.systemTemp.path}/fm_cifs_$seg';
  }

  /// Estrae server e nome condivisione dal path locale `.../fm_cifs_<payload>` per etichette UI.
  static ({String server, String share})? tryParseFmCifsMountPath(String rawPath) {
    var p = rawPath.trim();
    if (p.endsWith('/')) p = p.substring(0, p.length - 1);
    final parts = p.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final seg = parts.last;
    if (!seg.startsWith('fm_cifs_')) return null;
    final payload = seg.substring('fm_cifs_'.length);
    final fromB64 = _tryDecodeCifsMountSegment(payload);
    if (fromB64 != null) return fromB64;

    // Legacy: `fm_cifs_<server>_<share>` (ambiguo se server/share contengono `_`)
    final ipMatch =
        RegExp(r'^((?:\d{1,3}\.){3}\d{1,3})_(.+)$').firstMatch(payload);
    if (ipMatch != null) {
      return (server: ipMatch.group(1)!, share: ipMatch.group(2)!);
    }
    final u = payload.lastIndexOf('_');
    if (u <= 0 || u >= payload.length - 1) {
      return (server: payload, share: payload);
    }
    return (
      server: payload.substring(0, u),
      share: payload.substring(u + 1),
    );
  }

  /// Montaggio SMB con `mount.cifs` (pacchetto `cifs-utils`). Richiede permessi adeguati sul sistema.
  static Future<NetworkMountOutcome> mountShareWithCifs(
    String server,
    String share, {
    String? username,
    String? password,
  }) async {
    if (!Platform.isLinux) {
      return NetworkMountOutcome.fail('not_linux');
    }

    try {
      final w = await Process.run('which', ['mount.cifs']);
      if (w.exitCode != 0) {
        return NetworkMountOutcome.fail('missing_mount_cifs');
      }
    } catch (_) {
      return NetworkMountOutcome.fail('missing_mount_cifs');
    }

    final key = _cifsMountKey(server, share);
    final prev = _activeCifsMounts[key];
    if (prev != null) {
      if (await Directory(prev).exists()) {
        var ok = true;
        try {
          final st = await Process.run('mountpoint', ['-q', prev]);
          ok = st.exitCode == 0;
        } catch (_) {
          ok = true;
        }
        if (ok) {
          final p = prev.endsWith('/') ? prev : '$prev/';
          return NetworkMountOutcome.ok(p);
        }
      }
      _activeCifsMounts.remove(key);
    }

    final uid = await _linuxEffectiveUid();
    final gid = await _linuxEffectiveGid();
    final mountPath = cifsMountPointPath(server, share);
    if (await Directory(mountPath).exists()) {
      try {
        final st = await Process.run('mountpoint', ['-q', mountPath]);
        if (st.exitCode == 0) {
          _activeCifsMounts[key] = mountPath;
          return NetworkMountOutcome.ok('$mountPath/');
        }
      } catch (_) {}
    }
    final mountDir = Directory(mountPath);
    try {
      if (!await mountDir.exists()) {
        await mountDir.create(recursive: true);
      }
    } catch (e) {
      return NetworkMountOutcome.fail('cifs_mkdir_failed: $e');
    }

    File? credFile;
    try {
      String opts;
      final uRaw = username?.trim() ?? '';
      if (uRaw.isNotEmpty) {
        var dom = '';
        var u = uRaw;
        final bs = u.indexOf(r'\');
        if (bs >= 0) {
          dom = u.substring(0, bs).trim();
          u = u.substring(bs + 1).trim();
        }
        credFile = File('$mountPath/.smbcred');
        final pw = password ?? '';
        final body = dom.isNotEmpty
            ? 'username=$u\npassword=$pw\ndomain=$dom\n'
            : 'username=$u\npassword=$pw\n';
        await credFile.writeAsString(body);
        try {
          await Process.run('chmod', ['600', credFile.path]);
        } catch (_) {}
        opts =
            'credentials=${credFile.path},uid=$uid,gid=$gid,iocharset=utf8,file_mode=0644,dir_mode=0755,vers=3.0';
      } else {
        opts =
            'guest,uid=$uid,gid=$gid,iocharset=utf8,file_mode=0644,dir_mode=0755,vers=3.0';
      }

      final unc = '//$server/$share';
      ProcessResult result = await Process.run(
        'mount.cifs',
        [unc, mountPath, '-o', opts],
      ).timeout(const Duration(seconds: 25));

      if (result.exitCode != 0) {
        var combined = '${result.stderr}${result.stdout}'.trim();
        final hadUser = uRaw.isNotEmpty;
        if (!hadUser && _stderrLooksLikeNeedCredentials(combined)) {
          try {
            if (credFile != null && await credFile.exists()) {
              await credFile.delete();
            }
          } catch (_) {}
          try {
            if (await mountDir.exists() && mountDir.listSync().isEmpty) {
              await mountDir.delete();
            }
          } catch (_) {}
          return NetworkMountOutcome.fail('need_password');
        }
        if (_stderrLooksLikeNeedRootForMount(combined) &&
            await SystemDependenciesService.hasPkexec()) {
          unawaited(
            LoggingService.network('mount.cifs retry via pkexec', {
              'path': mountPath,
            }),
          );
          result = await Process.run(
            'pkexec',
            ['mount.cifs', unc, mountPath, '-o', opts],
          ).timeout(const Duration(seconds: 120));
          combined = '${result.stderr}${result.stdout}'.trim();
        }
      }

      try {
        if (credFile != null && await credFile.exists()) {
          await credFile.delete();
        }
      } catch (_) {}

      if (result.exitCode != 0) {
        final combined = '${result.stderr}${result.stdout}'.trim();
        unawaited(
          LoggingService.warning('Network', 'mount.cifs failed', {
            'stderr': _trunc(result.stderr.toString()),
            'stdout': _trunc(result.stdout.toString()),
          }),
        );
        try {
          if (await mountDir.exists() && mountDir.listSync().isEmpty) {
            await mountDir.delete();
          }
        } catch (_) {}
        final hadUser = uRaw.isNotEmpty;
        if (!hadUser && _stderrLooksLikeNeedCredentials(combined)) {
          return NetworkMountOutcome.fail('need_password');
        }
        return NetworkMountOutcome.fail(
          combined.isEmpty ? 'cifs_mount_failed' : _trunc(combined),
        );
      }

      _activeCifsMounts[key] = mountPath;
      unawaited(
        LoggingService.network('mount.cifs ok', {'path': mountPath}),
      );
      return NetworkMountOutcome.ok('$mountPath/');
    } catch (e) {
      unawaited(
        LoggingService.warning('Network', 'mount.cifs exception', {
          'error': e.toString(),
        }),
      );
      try {
        if (credFile != null && await credFile.exists()) {
          await credFile.delete();
        }
      } catch (_) {}
      return NetworkMountOutcome.fail(e.toString());
    }
  }

  /// Se `//server/share` è già montato sul percorso usato dall’app, restituisce il path con `/` finale.
  static Future<String?> mountedCifsPathIfActive(String server, String share) async {
    if (!Platform.isLinux) return null;
    final mountPath = cifsMountPointPath(server, share);
    if (!await Directory(mountPath).exists()) return null;
    try {
      final st = await Process.run('mountpoint', ['-q', mountPath]);
      if (st.exitCode == 0) return '$mountPath/';
    } catch (_) {}
    return null;
  }

  static Future<List<String>> _neighborIpv4Addresses() async {
    final ips = <String>{};
    try {
      final r = await Process.run('ip', ['neigh', 'show']);
      for (final line in r.stdout.toString().split('\n')) {
        final m = RegExp(
          r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s',
        ).firstMatch(line.trim());
        if (m != null) ips.add(m.group(1)!);
      }
    } catch (_) {}
    return ips.toList();
  }

  static Future<List<String>> _linuxLocalIpv4Cidrs() async {
    if (!Platform.isLinux) return [];
    try {
      final r = await Process.run('ip', [
        '-4',
        'route',
        'show',
        'scope',
        'link',
      ]);
      final out = <String>{};
      for (final line in r.stdout.toString().split('\n')) {
        final m = RegExp(
          r'^(\d{1,3}(?:\.\d{1,3}){3}/\d{1,2})\s',
        ).firstMatch(line.trim());
        if (m != null) out.add(m.group(1)!);
      }
      return out.toList();
    } catch (_) {
      return [];
    }
  }

  static List<String> _ipv4HostsFromSlash24(String cidr) {
    final parts = cidr.split('/');
    if (parts.length != 2) return [];
    if (int.tryParse(parts[1]) != 24) return [];
    final quads = parts[0].split('.');
    if (quads.length != 4) return [];
    final a = int.tryParse(quads[0]) ?? -1;
    final b = int.tryParse(quads[1]) ?? -1;
    final c = int.tryParse(quads[2]) ?? -1;
    if (a < 0 || b < 0 || c < 0) return [];
    return [for (var h = 1; h <= 254; h++) '$a.$b.$c.$h'];
  }

  /// Scansione leggera /24 locale (porta 445) se la LAN ha pochi host noti.
  static Future<void> _discoverSubnetSmb445(
    Map<String, Map<String, String>> out,
  ) async {
    if (!Platform.isLinux) return;
    if (out.length >= 12) return;
    final cidrs = await _linuxLocalIpv4Cidrs();
    if (cidrs.isEmpty) return;
    final hosts = _ipv4HostsFromSlash24(cidrs.first);
    if (hosts.isEmpty) return;
    const batch = 48;
    for (var i = 0; i < hosts.length && out.length < 48; i += batch) {
      await Future.wait(
        hosts.skip(i).take(batch).map((ip) async {
          final key = ip.toLowerCase();
          if (out.containsKey(key)) return;
          try {
            final sock = await Socket.connect(
              ip,
              445,
              timeout: const Duration(milliseconds: 350),
            );
            await sock.close();
            _putServer(out, ip, ip);
          } catch (_) {}
        }),
      );
    }
  }

  /// Host nella tabella ARP/neigh con TCP 445 raggiungibile (più leggero di `smbclient -L`).
  static Future<void> _discoverArpSmbHosts(
    Map<String, Map<String, String>> out,
  ) async {
    if (!Platform.isLinux) return;
    final ips = await _neighborIpv4Addresses();
    const maxHosts = 192;
    const batch = 48;
    for (var i = 0; i < ips.length && i < maxHosts; i += batch) {
      final slice = ips.skip(i).take(batch).toList();
      await Future.wait(
        slice.map((ip) async {
          final key = ip.toLowerCase();
          if (out.containsKey(key)) return;
          try {
            final sock = await Socket.connect(
              ip,
              445,
              timeout: const Duration(milliseconds: 200),
            );
            await sock.close();
            _putServer(out, ip, ip);
          } catch (_) {}
        }),
      );
    }
  }

  static String _unescapeAvahi(String s) {
    return s.replaceAll(r'\032', ' ');
  }

  /// DNS-SD: Samba / Windows spesso annunciano _smb._tcp (richiede avahi-daemon + avahi-utils).
  static Future<void> _discoverAvahiSmb(
    Map<String, Map<String, String>> out,
  ) async {
    try {
      final result = await Process.run('avahi-browse', [
        '-tpr',
        '_smb._tcp',
      ]).timeout(const Duration(seconds: 3));

      final text = '${result.stdout}\n${result.stderr}';
      for (final raw in text.split('\n')) {
        final line = raw.trim();
        if (!line.startsWith('=')) continue;
        final p = line.split(';');
        // =;if;IPv4;name;_smb._tcp;domain;host;address;port;txt
        if (p.length < 9) continue;
        final stype = p[4];
        if (!stype.contains('smb')) continue;
        final host = _unescapeAvahi(p[6]);
        final addr = p[7].trim();
        if (addr.isEmpty) continue;
        final v4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(addr);
        final v6 = addr.contains(':');
        if (!v4 && !v6) continue;
        final shortName = host.replaceAll(RegExp(r'\.local\.?$'), '');
        _putServer(out, shortName.isEmpty ? host : shortName, addr);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'NetworkBrowserService: avahi-browse unavailable or failed: $e',
        );
      }
    }
  }

  static final RegExp _nmbIpName = RegExp(
    r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)',
  );
  static final RegExp _nmbPositiveResponse = RegExp(
    r'Got a positive name query response from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})',
  );

  static void _parseNmblookupOutput(
    String text,
    Map<String, Map<String, String>> out,
  ) {
    for (final raw in text.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      final m1 = _nmbIpName.firstMatch(line);
      if (m1 != null) {
        final ip = m1.group(1)!;
        var name = m1.group(2)!;
        final lt = name.indexOf('<');
        if (lt > 0) name = name.substring(0, lt);
        name = name.replaceAll('\\', '').trim();
        if (name.isEmpty || name == '*') {
          _putServer(out, ip, ip);
        } else {
          _putServer(out, name, ip);
        }
        continue;
      }

      final m2 = _nmbPositiveResponse.firstMatch(line);
      if (m2 != null) {
        final ip = m2.group(1)!;
        _putServer(out, ip, ip);
      }
    }
  }

  /// NetBIOS browse (spesso vuoto su reti solo SMB3 / senza WINS; utile in LAN classiche).
  static Future<void> _discoverNmblookup(
    Map<String, Map<String, String>> out,
  ) async {
    var wg = _workgroupFromEnv();
    if (wg.isEmpty) {
      wg = _workgroupFromSambaConf() ?? 'WORKGROUP';
    }
    final attempts = <List<String>>[
      ['nmblookup', '-S', '*'],
      ['nmblookup', '-S', wg],
      ['nmblookup', '*'],
      ['nmblookup', '-M', '--', '-'],
    ];
    await Future.wait(
      attempts.map((args) async {
        try {
          final bin = args.first;
          final result = await Process.run(
            bin,
            args.sublist(1),
            environment: {...Platform.environment, 'LC_ALL': 'C'},
          ).timeout(const Duration(seconds: 3));

          _parseNmblookupOutput(result.stdout.toString(), out);
          _parseNmblookupOutput(result.stderr.toString(), out);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('NetworkBrowserService: ${args.join(' ')} failed: $e');
          }
        }
      }),
      eagerError: false,
    );
  }

  /// Montaggi CIFS già attivi (fonte affidabile se usi fstab o mount manuale).
  static Future<void> _discoverProcMounts(
    Map<String, Map<String, String>> out,
  ) async {
    try {
      final f = File('/proc/mounts');
      if (!await f.exists()) return;
      final lines = await f.readAsLines();
      final re = RegExp(r'//([^/]+)/[^/\s]+');
      for (final line in lines) {
        if (!line.contains('cifs') && !line.startsWith('//')) continue;
        final m = re.firstMatch(line);
        if (m != null) {
          final server = m.group(1)!;
          _putServer(out, server, server);
        }
      }
    } catch (_) {}
  }

  /// Scopre i server SMB/CIFS nella LAN.
  ///
  /// Fase 1 (più rapida): mount CIFS noti, ARP+445, scansione /24 su 445 — non attende mDNS/NetBIOS.
  /// Fase 2: avahi-browse e nmblookup in parallelo (timeout brevi).
  ///
  /// [onPartial] viene chiamato dopo la fase 1 e dopo la fase 2.
  static Future<List<Map<String, String>>> discoverNetworkServers({
    void Function(List<Map<String, String>> partial)? onPartial,
  }) async {
    final Map<String, Map<String, String>> byAddress = {};

    await Future.wait([
      _discoverProcMounts(byAddress),
      _discoverArpSmbHosts(byAddress),
    ], eagerError: false);

    await _discoverSubnetSmb445(byAddress);

    onPartial?.call(byAddress.values.toList());

    await Future.wait([
      _discoverAvahiSmb(byAddress),
      _discoverNmblookup(byAddress),
    ], eagerError: false);

    onPartial?.call(byAddress.values.toList());

    _netLog('discoverNetworkServers completed', {
      'count': byAddress.length,
      'addresses': byAddress.keys.take(48).toList(),
    });

    return byAddress.values.toList();
  }

  /// Lista le condivisioni disponibili su un server SMB
  /// Tenta prima con accesso guest, poi richiede credenziali se necessario
  static Future<List<Map<String, String>>> listShares(
    String server, {
    String? username,
    String? password,
  }) {
    return _runSerialized(
      () => _listSharesImpl(server, username: username, password: password),
    );
  }

  static Future<List<Map<String, String>>> _listSharesImpl(
    String server, {
    String? username,
    String? password,
  }) async {
    _netLog('listShares called', {
      'server': server,
      'has_username': username != null && username.isNotEmpty,
      'has_password': password != null && password.isNotEmpty,
    });

    final List<Map<String, String>> shares = [];
    Directory? credDir;
    File? credFile;

    try {
      final wg = await resolveWorkgroupForServer(server);
      // Costruisci comando smbclient (SMB3 prima, compat Windows 10/11)
      List<String> args = ['-L', smbUncHost(server)];
      if (wg.isNotEmpty) {
        args.addAll(['-W', wg]);
      }
      args.addAll(['-m', 'SMB3']);

      if (username != null && username.trim().isNotEmpty) {
        final pw = password ?? '';
        var userCred = username.trim();
        var domainCred = wg;
        final bs = userCred.indexOf(r'\');
        if (bs >= 0) {
          domainCred = userCred.substring(0, bs).trim();
          userCred = userCred.substring(bs + 1).trim();
        }
        if (_smbAuthNeedsCredentialFile(username, pw)) {
          credDir = await Directory.systemTemp.createTemp('fm_smb_cred_');
          credFile = File('${credDir.path}/cred');
          final credBody = StringBuffer()
            ..writeln('username=$userCred')
            ..writeln('password=$pw');
          if (domainCred.isNotEmpty) {
            credBody.writeln('domain=$domainCred');
          }
          await credFile.writeAsString(credBody.toString(), flush: true);
          args.addAll(['-A', credFile.path]);
          _netLog('Using credentials via -A file', {'username': username});
        } else {
          args.addAll(['-U', '$userCred%$pw']);
          _netLog('Using credentials', {
            'username': username,
            'has_password': pw.isNotEmpty,
          });
        }
      } else {
        args.add('-N');
        _netLog('Using guest access');
      }

      _netLog('Executing smbclient', {
        'command': 'smbclient',
        'args': args,
        'full_command': 'smbclient ${args.join(" ")}',
      });

      var result = await Process.run(
        'smbclient',
        args,
      ).timeout(const Duration(seconds: 15));

      if (result.exitCode != 0 && args.contains('SMB3')) {
        final args2 = List<String>.from(args);
        final i = args2.indexOf('SMB3');
        if (i >= 0) args2[i] = 'SMB2';
        result = await Process.run(
          'smbclient',
          args2,
        ).timeout(const Duration(seconds: 15));
      }

      final out = result.stdout.toString();
      final err = result.stderr.toString();
      _netLog('smbclient completed', {
        'exit_code': result.exitCode,
        'stdout_length': out.length,
        'stderr_length': err.length,
        'stdout': out,
        'stderr': err,
      });

      if (result.exitCode == 0) {
        final output = out;
        // Righe elenco share: nome + tipo (Disk|Printer|IPC). Esclude messaggi tipo "SMB1 disabled -- ...".
        final shareDataLine = RegExp(
          r'^\s*(\S+)\s+(Disk|Printer|IPC)\b',
          caseSensitive: false,
        );
        final lines = output.split('\n');
        bool inShareSection = false;
        bool foundHeader = false;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trimRight();

          // Sezione "Workgroup / Master" = fine elenco share
          if (RegExp(
            r'Workgroup\s+Master',
            caseSensitive: false,
          ).hasMatch(line)) {
            break;
          }

          // Intestazione tabella share (no match generico su "share" nel testo)
          if (!foundHeader &&
              (line.contains('Sharename') ||
                  line.contains('Share name') ||
                  RegExp(
                    r'^\s*Share\s+Type\s+Comment',
                    caseSensitive: false,
                  ).hasMatch(line.trim()))) {
            if (i + 1 < lines.length) {
              final nextLine = lines[i + 1].trim();
              if (nextLine.contains('---') ||
                  nextLine.contains('===') ||
                  nextLine.contains('Type') ||
                  nextLine.contains('Comment')) {
                inShareSection = true;
                foundHeader = true;
                continue;
              }
            }
          }

          if (inShareSection) {
            final trimmed = line.trim();
            if (trimmed.startsWith('---') || trimmed.startsWith('===')) {
              if (shares.isNotEmpty) break;
              continue;
            }
            if (trimmed.isEmpty) continue;

            final m = shareDataLine.firstMatch(trimmed);
            if (m == null) continue;

            final shareName = m.group(1)!.trim();
            if (shareName.isEmpty) continue;
            // SMB1/SMB2 nelle righe di stato non hanno colonna tipo Disk/Printer/IPC — già esclusi.
            if (RegExp(r'^SMB\d+$', caseSensitive: false).hasMatch(shareName)) {
              continue;
            }
            if (shareName == r'IPC$' ||
                shareName.startsWith('IPC') && shareName != 'IPC') {
              continue;
            }
            if (shareName.endsWith(r'$') && shareName != r'IPC$') continue;
            if (shareName == r'print$' ||
                shareName == 'Disk' ||
                shareName == 'Printer' ||
                shareName == 'Sharename' ||
                shareName == 'Share') {
              continue;
            }

            if (!shares.any((s) => s['name'] == shareName)) {
              shares.add({
                'name': shareName,
                'server': server,
                'path': 'smb://$server/$shareName',
                'cifs_path': '${cifsMountPointPath(server, shareName)}/',
              });
            }
          }
        }

        if (shares.isEmpty && output.isNotEmpty) {
          for (final m in shareDataLine.allMatches(output)) {
            final shareName = m.group(1)!.trim();
            if (shareName.isEmpty ||
                RegExp(r'^SMB\d+$', caseSensitive: false).hasMatch(shareName)) {
              continue;
            }
            if (shareName == r'IPC$' ||
                shareName.endsWith(r'$') ||
                shareName == r'print$' ||
                shareName == 'Disk' ||
                shareName == 'Printer' ||
                shareName == 'Sharename' ||
                shareName == 'Share') {
              continue;
            }
            if (!shares.any((s) => s['name'] == shareName)) {
              shares.add({
                'name': shareName,
                'server': server,
                'path': 'smb://$server/$shareName',
                'cifs_path': '${cifsMountPointPath(server, shareName)}/',
              });
            }
          }
        }

        _netLog('Parsing completed', {
          'shares_found': shares.length,
          'shares': shares.map((s) => s['name']).toList(),
        });
      } else if (result.exitCode == 1) {
        // Accesso negato o errore
        unawaited(
          LoggingService.warning(
            'Network',
            'smbclient failed with exit code 1',
            {
              'server': server,
              'had_credentials': username != null,
              'stdout': _trunc(out),
              'stderr': _trunc(err),
            },
          ),
        );

        // Se non avevamo credenziali, potrebbe essere necessario autenticarsi
        if (username == null) {
          _netLog('No credentials provided, returning empty list');
          return [];
        } else {
          _netLog('Credentials provided but failed, returning empty list');
          return [];
        }
      } else {
        unawaited(
          LoggingService.error(
            'Network',
            'smbclient failed with unexpected exit code',
            {
              'exit_code': result.exitCode,
              'stdout': _trunc(out),
              'stderr': _trunc(err),
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      unawaited(
        LoggingService.error('Network', 'Exception in listShares', {
          'server': server,
          'exception': e.toString(),
        }, stackTrace),
      );
    } finally {
      try {
        if (credFile != null && await credFile.exists())
          await credFile.delete();
        if (credDir != null && await credDir.exists())
          await credDir.delete(recursive: true);
      } catch (_) {}
    }

    _netLog('listShares returning', {'shares_count': shares.length});

    return shares;
  }

  /// Monta la condivisione con `mount.cifs` e restituisce il path locale del punto di mount.
  static Future<NetworkMountOutcome> connectToShareWithOutcome(
    String server,
    String share, {
    String? username,
    String? password,
  }) {
    return mountShareWithCifs(
      server,
      share,
      username: username,
      password: password,
    );
  }

  /// Restituisce il path del mount CIFS oppure null (vedi [connectToShareWithOutcome] per il motivo).
  static Future<String?> connectToShare(
    String server,
    String share, {
    String? username,
    String? password,
  }) async {
    final o = await connectToShareWithOutcome(
      server,
      share,
      username: username,
      password: password,
    );
    return o.path;
  }

  /// Lista i file in una condivisione SMB montata (path locale del mount).
  /// CRITICAL: Ensures trailing slash for SMB compatibility
  static Future<List<String>> listShareContents(String mountLocalPath) async {
    _netLog('listShareContents called', {'path': mountLocalPath});

    final List<String> contents = [];

    try {
      // CRITICAL: Ensure trailing slash for SMB list operations
      final normalizedPath = mountLocalPath.endsWith('/')
          ? mountLocalPath
          : '$mountLocalPath/';

      final dir = Directory(normalizedPath);

      final exists = await dir.exists();

      if (exists) {
        await for (final entity in dir.list()) {
          contents.add(entity.path);
        }

        _netLog('Directory listing completed', {
          'total_entries': contents.length,
        });
      } else {
        unawaited(
          LoggingService.warning('Network', 'Directory does not exist', {
            'path': normalizedPath,
          }),
        );
      }
    } catch (e, stackTrace) {
      unawaited(
        LoggingService.error('Network', 'Error listing share contents', {
          'path': mountLocalPath,
          'exception': e.toString(),
        }, stackTrace),
      );
    }

    _netLog('listShareContents returning', {'contents_count': contents.length});

    return contents;
  }

  /// Monta una condivisione SMB
  static Future<String?> mountShare(
    String server,
    String share, {
    String? username,
    String? password,
  }) async {
    try {
      // Crea directory di mount
      final mountPoint = '/tmp/smb_${server}_${share}'.replaceAll(
        RegExp(r'[^a-zA-Z0-9_]'),
        '_',
      );
      final mountDir = Directory(mountPoint);
      if (!await mountDir.exists()) {
        await mountDir.create(recursive: true);
      }

      // Monta usando mount.cifs
      final uid = Platform.environment['UID'] ?? '1000';
      final gid = Platform.environment['GID'] ?? '1000';
      final List<String> mountArgs = [
        '-t',
        'cifs',
        '//$server/$share',
        mountPoint,
        '-o',
        'guest,uid=$uid,gid=$gid',
      ];

      if (username != null && password != null) {
        mountArgs.removeLast();
        mountArgs.add('-o');
        mountArgs.add(
          'username=$username,password=$password,uid=$uid,gid=$gid',
        );
      }

      final result = await Process.run('sudo', [
        'mount',
        ...mountArgs,
      ]).timeout(const Duration(seconds: 10));

      if (result.exitCode == 0) {
        return mountPoint;
      }
    } catch (e) {
      // Errore durante il mount
    }

    return null;
  }

  /// Verifica se una condivisione è già montata
  static Future<String?> getMountedPath(String server, String share) async {
    try {
      final result = await Process.run('mount', []);
      final lines = result.stdout.toString().split('\n');

      for (final line in lines) {
        if (line.contains('//$server/$share') ||
            line.contains('$server/$share')) {
          final parts = line.split(' ');
          if (parts.length >= 3) {
            return parts[2]; // Mount point
          }
        }
      }
    } catch (e) {
      // Ignora errori
    }

    return null;
  }

  static bool isSmbShellPath(String path) =>
      path.trim().toLowerCase().startsWith('fm-smb://');

  /// Argomento host per `smbclient -L` nel formato UNC `//server`.
  static String smbUncHost(String server) {
    final t = server.trim();
    if (t.startsWith(r'//')) return t;
    return '//$t';
  }

  static SmbShellLocation? tryParseSmbShellPath(String input) {
    final s = input.trim();
    if (!isSmbShellPath(s)) return null;
    final u = Uri.tryParse(s);
    if (u == null || u.host.isEmpty) return null;
    final segs = u.pathSegments.where((e) => e.isNotEmpty).toList();
    if (segs.isEmpty) return null;
    final share = segs.first;
    final rest = segs.skip(1).join('/');
    return SmbShellLocation(
      server: u.host,
      share: share,
      relativePath: rest,
    );
  }

  static String smbShellRootUri(String server, String share) {
    final uri = Uri(
      scheme: 'fm-smb',
      host: server.trim(),
      pathSegments: [share.trim()],
    );
    var out = uri.toString();
    if (!out.endsWith('/')) out = '$out/';
    return out;
  }

  static String smbShellChildPath(
    String parentVirtualPath,
    String childName, {
    required bool isDirectory,
  }) {
    final loc = tryParseSmbShellPath(parentVirtualPath);
    if (loc == null) return parentVirtualPath;
    final name = childName.trim();
    if (name.isEmpty) return parentVirtualPath;
    final sub = loc.relativePath.isEmpty
        ? name
        : '${loc.relativePath}/$name';
    final subSegs = sub.split('/').where((e) => e.isNotEmpty).toList();
    final uri = Uri(
      scheme: 'fm-smb',
      host: loc.server,
      pathSegments: [loc.share, ...subSegs],
    );
    var out = uri.toString();
    if (isDirectory && !out.endsWith('/')) out = '$out/';
    return out;
  }

  /// Cartella superiore dentro la condivisione; `null` sulla root della share.
  static String? smbShellParent(String input) {
    final loc = tryParseSmbShellPath(input);
    if (loc == null) return null;
    if (loc.relativePath.isEmpty) return null;
    final parts = loc.relativePath.split('/').where((e) => e.isNotEmpty).toList();
    if (parts.length <= 1) {
      return smbShellRootUri(loc.server, loc.share);
    }
    parts.removeLast();
    final uri = Uri(
      scheme: 'fm-smb',
      host: loc.server,
      pathSegments: [loc.share, ...parts],
    );
    var out = uri.toString();
    if (!out.endsWith('/')) out = '$out/';
    return out;
  }
}
