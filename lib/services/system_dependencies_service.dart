import 'dart:io';
import 'package:filemanager/services/rust_ffi.dart';

/// Famiglia di distro: gestore pacchetti e mapping nomi pacchetto.
enum DistroFamily {
  debian,
  fedora,
  arch,
  suse,
  alpine,
  voidLinux,
  solus,
  unknown,
}

/// Dipendenza opzionale: eseguibile + pacchetti per distro.
class SystemDependency {
  final String id;
  final String executable;
  final String debianPackage;
  final String fedoraPackage;
  final String archPackage;
  final String susePackage;
  final String alpinePackage;
  final String voidPackage;

  const SystemDependency({
    required this.id,
    required this.executable,
    required this.debianPackage,
    required this.fedoraPackage,
    required this.archPackage,
    required this.susePackage,
    required this.alpinePackage,
    required this.voidPackage,
  });

  String? packageFor(DistroFamily f) {
    switch (f) {
      case DistroFamily.debian:
        return debianPackage;
      case DistroFamily.fedora:
      case DistroFamily.solus:
        return fedoraPackage;
      case DistroFamily.arch:
        return archPackage;
      case DistroFamily.suse:
        return susePackage;
      case DistroFamily.alpine:
        return alpinePackage;
      case DistroFamily.voidLinux:
        return voidPackage;
      case DistroFamily.unknown:
        return null;
    }
  }
}

/// Esito installazione via pkexec (include output del gestore pacchetti).
class PkexecInstallResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final bool pkexecMissing;

  const PkexecInstallResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.pkexecMissing = false,
  });

  static const PkexecInstallResult noPackages = PkexecInstallResult(
    exitCode: 0,
    stdout: '',
    stderr: '',
  );

  String get combinedOutput {
    final a = stderr.trim();
    final b = stdout.trim();
    if (a.isNotEmpty && b.isNotEmpty) {
      return '$a\n$b';
    }
    return a.isNotEmpty ? a : b;
  }
}

/// Risultato del controllo all'avvio.
class DependencyCheckResult {
  final List<SystemDependency> missingCommands;
  final bool rustAvailable;
  final DistroFamily distroFamily;

  const DependencyCheckResult({
    required this.missingCommands,
    required this.rustAvailable,
    required this.distroFamily,
  });

  bool get needsAttention =>
      missingCommands.isNotEmpty || !rustAvailable;

  bool get canAutoInstall =>
      distroFamily != DistroFamily.unknown && missingCommands.isNotEmpty;

  List<String> packagesToInstall(DistroFamily f) {
    final set = <String>{};
    for (final d in missingCommands) {
      final p = d.packageFor(f);
      if (p != null && p.isNotEmpty) set.add(p);
    }
    return set.toList()..sort();
  }

  /// Nomi pacchetto Debian/Ubuntu per suggerimento manuale se la distro è sconosciuta.
  List<String> get debianPackagesHint {
    final set = <String>{};
    for (final d in missingCommands) {
      if (d.debianPackage.isNotEmpty) set.add(d.debianPackage);
    }
    return set.toList()..sort();
  }
}

/// Verifica comandi e libreria Rust; prepara installazione via pkexec.
///
/// **SMB / CIFS:** il montaggio delle condivisioni usa `mount.cifs` ([SystemDependency]
/// id `mount_cifs`, pacchetto tipico `cifs-utils`). Richiede permessi di sistema adeguati
/// (spesso root o voci in `/etc/fstab` con `user`).
class SystemDependenciesService {
  SystemDependenciesService._();

  /// Suggerimento installazione manuale (Debian/Ubuntu) per il montaggio SMB.
  static const String debianSmbMountStackHint = 'cifs-utils (mount.cifs)';

  static const int _maxOutputChars = 3500;

  static final List<SystemDependency> _tracked = [
    const SystemDependency(
      id: 'xdg_open',
      executable: 'xdg-open',
      debianPackage: 'xdg-utils',
      fedoraPackage: 'xdg-utils',
      archPackage: 'xdg-utils',
      susePackage: 'xdg-utils',
      alpinePackage: 'xdg-utils',
      voidPackage: 'xdg-utils',
    ),
    const SystemDependency(
      id: 'mount_cifs',
      executable: 'mount.cifs',
      debianPackage: 'cifs-utils',
      fedoraPackage: 'cifs-utils',
      archPackage: 'cifs-utils',
      susePackage: 'cifs-utils',
      alpinePackage: 'cifs-utils',
      voidPackage: 'cifs-utils',
    ),
    const SystemDependency(
      id: 'smbclient',
      executable: 'smbclient',
      debianPackage: 'smbclient',
      fedoraPackage: 'samba-client',
      archPackage: 'smbclient',
      susePackage: 'samba-client',
      alpinePackage: 'samba-client',
      voidPackage: 'samba',
    ),
    const SystemDependency(
      id: 'nmblookup',
      executable: 'nmblookup',
      debianPackage: 'samba-common-bin',
      fedoraPackage: 'samba-common-tools',
      archPackage: 'samba',
      susePackage: 'samba-client',
      alpinePackage: 'samba-common',
      voidPackage: 'samba',
    ),
    const SystemDependency(
      id: 'avahi_browse',
      executable: 'avahi-browse',
      debianPackage: 'avahi-utils',
      fedoraPackage: 'avahi-tools',
      archPackage: 'avahi',
      susePackage: 'avahi-utils',
      alpinePackage: 'avahi-utils',
      voidPackage: 'avahi-utils',
    ),
    const SystemDependency(
      id: 'avahi_resolve',
      executable: 'avahi-resolve-address',
      debianPackage: 'avahi-utils',
      fedoraPackage: 'avahi-tools',
      archPackage: 'avahi',
      susePackage: 'avahi-utils',
      alpinePackage: 'avahi-utils',
      voidPackage: 'avahi-utils',
    ),
  ];

  /// Strumenti usati da rete SMB (scoperta host, nomi, montaggio). Per banner contestuali.
  static const Set<String> networkDiscoveryDependencyIds = {
    'smbclient',
    'mount_cifs',
    'nmblookup',
    'avahi_browse',
    'avahi_resolve',
  };

  /// Solo `mount.cifs` (pacchetto cifs-utils), per controlli mirati prima del mount SMB.
  static const Set<String> cifsMountOnlyDependencyIds = {'mount_cifs'};

  /// True se `mount.cifs` è disponibile nel PATH (o in directory di sistema note).
  static Future<bool> isMountCifsAvailable() async {
    if (!Platform.isLinux) return false;
    final r = await checkDependenciesByIds(cifsMountOnlyDependencyIds);
    return r.missingCommands.isEmpty;
  }

  /// `pkexec` presente (per installazione pacchetti o mount con privilegi).
  static Future<bool> hasPkexec() => _hasPkexec();

  static SystemDependency? trackedById(String id) {
    for (final d in _tracked) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Controlla solo un sottoinsieme di dipendenze (es. rete) per offerte di installazione mirate.
  static Future<DependencyCheckResult> checkDependenciesByIds(
    Set<String> ids,
  ) async {
    if (!Platform.isLinux) {
      return const DependencyCheckResult(
        missingCommands: [],
        rustAvailable: true,
        distroFamily: DistroFamily.unknown,
      );
    }

    final missing = <SystemDependency>[];
    for (final id in ids) {
      final d = trackedById(id);
      if (d == null) continue;
      if (!await _commandOnPath(d.executable)) {
        missing.add(d);
      }
    }

    var rust = false;
    try {
      rust = RustFFI.isAvailable();
    } catch (_) {
      rust = false;
    }

    final family = await detectDistroFamily();

    return DependencyCheckResult(
      missingCommands: missing,
      rustAvailable: rust,
      distroFamily: family,
    );
  }

  static final RegExp _safePackage = RegExp(r'^[a-zA-Z0-9.+-]+$');

  static bool _isValidPackage(String p) => _safePackage.hasMatch(p);

  static String _strOut(Object? o) {
    if (o == null) return '';
    final s = o.toString().trim();
    return s;
  }

  static String truncateForUi(String text, {int max = _maxOutputChars}) {
    final t = text.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}\n…';
  }

  static Future<DistroFamily> detectDistroFamily() async {
    try {
      final osRelease = File('/etc/os-release');
      if (await osRelease.exists()) {
        final text = await osRelease.readAsString();
        final id = RegExp(r'^ID=(.*)', multiLine: true).firstMatch(text);
        final idLike =
            RegExp(r'^ID_LIKE=(.*)', multiLine: true).firstMatch(text);
        final v = (id?.group(1) ?? '').replaceAll('"', '').toLowerCase();
        final like = (idLike?.group(1) ?? '').replaceAll('"', '').toLowerCase();

        if (v == 'alpine') {
          return DistroFamily.alpine;
        }
        if (v == 'void') {
          return DistroFamily.voidLinux;
        }
        if (v == 'solus') {
          return DistroFamily.solus;
        }
        if (v.startsWith('opensuse') ||
            v == 'sles' ||
            v == 'sle_hpc' ||
            like.contains('suse')) {
          return DistroFamily.suse;
        }
        if (v == 'debian' ||
            v == 'ubuntu' ||
            v == 'linuxmint' ||
            v == 'pop' ||
            v == 'elementary' ||
            v == 'zorin' ||
            v == 'kali' ||
            v == 'deepin' ||
            v == 'mx' ||
            like.contains('debian') ||
            like.contains('ubuntu')) {
          return DistroFamily.debian;
        }
        if (v == 'fedora' ||
            v == 'rhel' ||
            v == 'centos' ||
            v == 'rocky' ||
            v == 'almalinux' ||
            v == 'amzn' ||
            v == 'ol' ||
            v == 'mageia' ||
            v == 'openmandriva' ||
            like.contains('fedora') ||
            like.contains('rhel') ||
            like.contains('centos')) {
          return DistroFamily.fedora;
        }
        if (v == 'arch' ||
            v == 'manjaro' ||
            v == 'endeavouros' ||
            v == 'cachyos' ||
            v == 'garuda' ||
            like.contains('arch')) {
          return DistroFamily.arch;
        }
      }
      if (await File('/etc/debian_version').exists()) {
        return DistroFamily.debian;
      }
      if (await File('/etc/arch-release').exists()) {
        return DistroFamily.arch;
      }
      if (await File('/etc/fedora-release').exists()) {
        return DistroFamily.fedora;
      }
      if (await File('/etc/SuSE-release').exists()) {
        return DistroFamily.suse;
      }
      if (await File('/etc/alpine-release').exists()) {
        return DistroFamily.alpine;
      }
    } catch (_) {}
    return DistroFamily.unknown;
  }

  /// PATH usato per `which`: le app GUI spesso ereditano un PATH senza `/usr/bin`.
  static const String _whichPathEnv =
      '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin';

  static const List<String> _executableDirFallbacks = [
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin',
    '/usr/local/bin',
    '/usr/local/sbin',
  ];

  static bool _executableFileAt(String absolutePath) {
    try {
      final type =
          FileSystemEntity.typeSync(absolutePath, followLinks: true);
      if (type != FileSystemEntityType.file) {
        return false;
      }
      if (!Platform.isLinux) return true;
      final mode = File(absolutePath).statSync().mode;
      return (mode & 0x49) != 0;
    } catch (_) {
      return false;
    }
  }

  /// True se il comando è risolvibile con PATH standard o esiste sotto le directory di sistema.
  static Future<bool> _commandOnPath(String name) async {
    if (name.contains('/') || name.contains('..')) {
      return false;
    }
    try {
      final mergedPath = Platform.environment['PATH'] != null &&
              Platform.environment['PATH']!.isNotEmpty
          ? '$_whichPathEnv:${Platform.environment['PATH']}'
          : _whichPathEnv;
      final r = await Process.run(
        'which',
        [name],
        environment: {
          ...Platform.environment,
          'PATH': mergedPath,
        },
      );
      if (r.exitCode == 0 && r.stdout.toString().trim().isNotEmpty) {
        return true;
      }
    } catch (_) {}
    for (final dir in _executableDirFallbacks) {
      if (_executableFileAt('$dir/$name')) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> _hasPkexec() async {
    return _commandOnPath('pkexec');
  }

  /// Controlla tutte le dipendenze tracciate + Rust FFI.
  static Future<DependencyCheckResult> checkAll() async {
    if (!Platform.isLinux) {
      return const DependencyCheckResult(
        missingCommands: [],
        rustAvailable: true,
        distroFamily: DistroFamily.unknown,
      );
    }

    final missing = <SystemDependency>[];
    for (final d in _tracked) {
      if (!await _commandOnPath(d.executable)) {
        missing.add(d);
      }
    }

    var rust = false;
    try {
      rust = RustFFI.isAvailable();
    } catch (_) {
      rust = false;
    }

    final family = await detectDistroFamily();

    return DependencyCheckResult(
      missingCommands: missing,
      rustAvailable: rust,
      distroFamily: family,
    );
  }

  static String suggestedDebianCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo apt-get update && sudo apt-get install -y $safe';
  }

  static String suggestedFedoraCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo dnf install -y $safe';
  }

  static String suggestedArchCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo pacman -Sy --noconfirm $safe';
  }

  static String suggestedSuseCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo zypper --non-interactive install -y $safe';
  }

  static String suggestedAlpineCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo apk update && sudo apk add --no-cache $safe';
  }

  static String suggestedVoidCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo xbps-install -Sy $safe';
  }

  static String suggestedSolusCommand(List<String> packages) {
    if (packages.isEmpty) return '';
    final safe = packages.where(_isValidPackage).join(' ');
    if (safe.isEmpty) return '';
    return 'sudo eopkg it -y $safe';
  }

  static String suggestedCommand(DistroFamily f, List<String> packages) {
    switch (f) {
      case DistroFamily.debian:
        return suggestedDebianCommand(packages);
      case DistroFamily.fedora:
        return suggestedFedoraCommand(packages);
      case DistroFamily.arch:
        return suggestedArchCommand(packages);
      case DistroFamily.suse:
        return suggestedSuseCommand(packages);
      case DistroFamily.alpine:
        return suggestedAlpineCommand(packages);
      case DistroFamily.voidLinux:
        return suggestedVoidCommand(packages);
      case DistroFamily.solus:
        return suggestedSolusCommand(packages);
      case DistroFamily.unknown:
        return suggestedDebianCommand(packages);
    }
  }

  /// Esegue installazione con pkexec; include stdout/stderr dello script.
  static Future<PkexecInstallResult> installWithPkexec(
    DependencyCheckResult result,
  ) async {
    if (!Platform.isLinux) {
      return PkexecInstallResult.noPackages;
    }
    final family = result.distroFamily;
    if (family == DistroFamily.unknown) {
      return const PkexecInstallResult(
        exitCode: 1,
        stdout: '',
        stderr: 'unknown distro',
      );
    }

    final pkgs = result.packagesToInstall(family)
        .where(_isValidPackage)
        .toList();
    if (pkgs.isEmpty) {
      return PkexecInstallResult.noPackages;
    }

    if (!await _hasPkexec()) {
      return const PkexecInstallResult(
        exitCode: 126,
        stdout: '',
        stderr: '',
        pkexecMissing: true,
      );
    }

    final scriptBody = _installScriptBody(family, pkgs);
    final dir = await Directory.systemTemp.createTemp('filemanager_deps_');
    final script = File('${dir.path}/install.sh');
    try {
      await script.writeAsString(
        '#!/bin/sh\n'
        'set -e\n'
        '$scriptBody\n',
      );
      await Process.run('chmod', ['+x', script.path]);

      final proc = await Process.run(
        'pkexec',
        [script.path],
        environment: {
          ...Platform.environment,
          'LANG': Platform.environment['LANG'] ?? 'C.UTF-8',
        },
      );
      return PkexecInstallResult(
        exitCode: proc.exitCode,
        stdout: _strOut(proc.stdout),
        stderr: _strOut(proc.stderr),
      );
    } catch (e, st) {
      return PkexecInstallResult(
        exitCode: -1,
        stdout: '',
        stderr: '$e\n$st',
      );
    } finally {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    }
  }

  static String _installScriptBody(DistroFamily family, List<String> pkgs) {
    final quoted = pkgs.map((p) => "'${p.replaceAll("'", "'\\''")}'").join(' ');
    switch (family) {
      case DistroFamily.debian:
        return '''
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y $quoted
''';
      case DistroFamily.fedora:
        return 'dnf install -y $quoted';
      case DistroFamily.arch:
        return 'pacman -Sy --noconfirm $quoted';
      case DistroFamily.suse:
        return 'zypper --non-interactive install -y $quoted';
      case DistroFamily.alpine:
        return 'apk update && apk add --no-cache $quoted';
      case DistroFamily.voidLinux:
        return 'xbps-install -Sy $quoted';
      case DistroFamily.solus:
        return 'eopkg it -y $quoted';
      case DistroFamily.unknown:
        return 'exit 1';
    }
  }
}
