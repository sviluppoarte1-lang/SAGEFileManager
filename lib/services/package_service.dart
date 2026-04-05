import 'dart:io';
import 'package:filemanager/services/file_service.dart';

class PackageInfo {
  final String name;
  final String version;
  final String type; // apt, snap, flatpak, gnome
  final String description;
  final bool isInstalled;

  PackageInfo({
    required this.name,
    required this.version,
    required this.type,
    required this.description,
    required this.isInstalled,
  });
}

class PackageService {
  static Future<String> getLinuxDistro() async {
    return await FileService.detectLinuxDistro();
  }

  static Future<List<PackageInfo>> getInstalledPackages() async {
    final List<PackageInfo> packages = [];
    final distro = await getLinuxDistro();

    // DNF packages (Fedora/RHEL)
    if (distro == 'fedora' || distro == 'rhel') {
      try {
        final result = await Process.run('dnf', ['list', 'installed']);
        final lines = result.stdout.toString().split('\n');
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            packages.add(PackageInfo(
              name: parts[0],
              version: parts[1],
              type: 'dnf',
              description: parts.length > 2 ? parts.sublist(2).join(' ') : '',
              isInstalled: true,
            ));
          }
        }
      } catch (e) {
        // Error reading DNF packages
      }
    }

    // Pacman packages (Arch)
    if (distro == 'arch') {
      try {
        final result = await Process.run('pacman', ['-Q']);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          final parts = trimmed.split(' ');
          if (parts.length >= 2) {
            packages.add(PackageInfo(
              name: parts[0],
              version: parts[1],
              type: 'pacman',
              description: '',
              isInstalled: true,
            ));
          }
        }
      } catch (e) {
        // Error reading pacman packages
      }
    }

    // APT packages (Debian/Ubuntu)
    if (distro == 'debian' || distro == 'ubuntu' || distro == 'linuxmint') {
      try {
        final result = await Process.run('dpkg', ['-l']);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.startsWith('ii')) {
            final parts = line.split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              packages.add(PackageInfo(
                name: parts[1],
                version: parts[2],
                type: 'apt',
                description: parts.length > 4 ? parts.sublist(4).join(' ') : '',
                isInstalled: true,
              ));
            }
          }
        }
      } catch (e) {
        // Error reading APT packages
      }
    }

    // Snap packages
    try {
      final result = await Process.run('snap', ['list']);
      final lines = result.stdout.toString().split('\n');
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          packages.add(PackageInfo(
            name: parts[0],
            version: parts[1],
            type: 'snap',
            description: parts.length > 5 ? parts.sublist(5).join(' ') : '',
            isInstalled: true,
          ));
        }
      }
    } catch (e) {
      // Snap not available
    }

    // Flatpak packages
    try {
      final result = await Process.run('flatpak', ['list', '--columns=application,version']);
      final lines = result.stdout.toString().split('\n');
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length >= 2) {
          packages.add(PackageInfo(
            name: parts[0],
            version: parts[1],
            type: 'flatpak',
            description: '',
            isInstalled: true,
          ));
        }
      }
    } catch (e) {
      // Flatpak not available
    }

    // GNOME packages (from flatpak with org.gnome namespace)
    try {
      final result = await Process.run('flatpak', ['list', '--columns=application,version']);
      final lines = result.stdout.toString().split('\n');
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length >= 1 && parts[0].startsWith('org.gnome.')) {
          packages.add(PackageInfo(
            name: parts[0],
            version: parts.length >= 2 ? parts[1] : '',
            type: 'gnome',
            description: '',
            isInstalled: true,
          ));
        }
      }
    } catch (e) {
      // GNOME packages not available
    }

    // KDE packages (from flatpak with org.kde namespace)
    try {
      final result = await Process.run('flatpak', ['list', '--columns=application,version']);
      final lines = result.stdout.toString().split('\n');
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length >= 1 && parts[0].startsWith('org.kde.')) {
          packages.add(PackageInfo(
            name: parts[0],
            version: parts.length >= 2 ? parts[1] : '',
            type: 'kde',
            description: '',
            isInstalled: true,
          ));
        }
      }
    } catch (e) {
      // KDE packages not available
    }

    return packages;
  }

  static Future<bool> uninstallPackage(PackageInfo package) async {
    try {
      switch (package.type) {
        case 'apt':
          await Process.run('sudo', ['apt', 'remove', '--yes', package.name]);
          break;
        case 'snap':
          await Process.run('sudo', ['snap', 'remove', package.name]);
          break;
        case 'flatpak':
        case 'gnome':
        case 'kde':
          await Process.run('flatpak', [
            'uninstall',
            '-y',
            '--noninteractive',
            package.name,
          ]);
          break;
        case 'dnf':
          await Process.run('sudo', ['dnf', 'remove', '-y', package.name]);
          break;
        case 'pacman':
          await Process.run('sudo', ['pacman', '-R', '--noconfirm', package.name]);
          break;
        default:
          return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> checkDependencies(PackageInfo package) async {
    final List<String> dependencies = [];

    if (package.type == 'apt') {
      try {
        final result = await Process.run('apt-cache', ['rdepends', package.name]);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith(package.name)) {
            dependencies.add(trimmed);
          }
        }
      } catch (e) {
        // Error checking dependencies
      }
    } else if (package.type == 'dnf') {
      try {
        final result = await Process.run('dnf', ['repoquery', '--whatrequires', package.name]);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed != package.name) {
            dependencies.add(trimmed);
          }
        }
      } catch (e) {
        // Error checking dependencies
      }
    } else if (package.type == 'pacman') {
      try {
        final result = await Process.run('pactree', ['-r', package.name]);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed != package.name) {
            dependencies.add(trimmed);
          }
        }
      } catch (e) {
        // Error checking dependencies
      }
    }

    return dependencies;
  }

  static Future<List<Map<String, String>>> checkUpdates() async {
    final List<Map<String, String>> updates = [];
    final distro = await getLinuxDistro();

    // APT updates (include apt update && upgrade check)
    if (distro == 'debian' || distro == 'ubuntu' || distro == 'linuxmint') {
      try {
        // Esegui apt update per aggiornare la lista dei pacchetti
        await Process.run('sudo', ['apt', 'update']);
        // Controlla i pacchetti aggiornabili
        final result = await Process.run('apt', ['list', '--upgradable']);
        final lines = result.stdout.toString().split('\n');
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split('/');
          if (parts.length >= 2) {
            // Estrai versione corrente e disponibile se disponibile
            final versionParts = parts[1].split(' ');
            updates.add({
              'name': parts[0],
              'type': 'apt',
              'current': versionParts.length > 1 ? versionParts[1] : '',
              'available': versionParts[0],
            });
          }
        }
      } catch (e) {
        // Error checking APT updates
      }
    }

    // Snap updates
    try {
      final result = await Process.run('snap', ['refresh', '--list']);
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.contains('would be refreshed')) {
          final parts = line.split(' ');
          if (parts.isNotEmpty) {
            updates.add({
              'name': parts[0],
              'type': 'snap',
              'current': '',
              'available': '',
            });
          }
        }
      }
    } catch (e) {
      // Error checking snap updates
    }

    // Flatpak updates
    try {
      final result = await Process.run('flatpak', ['remote-ls', '--updates', '--columns=application,version']);
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final parts = trimmed.split('\t');
        if (parts.length >= 2) {
          updates.add({
            'name': parts[0],
            'type': 'flatpak',
            'current': '',
            'available': parts[1],
          });
        }
      }
    } catch (e) {
      // Error checking flatpak updates
    }

    // GNOME updates
    try {
      final result = await Process.run('gnome-software', ['--list-updates'], runInShell: true);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.contains('gnome') || line.contains('GNOME')) {
            updates.add({
              'name': line.trim(),
              'type': 'gnome',
              'current': '',
              'available': '',
            });
          }
        }
      }
    } catch (e) {
      // GNOME Software might not be available
    }

    // KDE updates
    try {
      final result = await Process.run('pkcon', ['get-updates'], runInShell: true);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.contains('kde') || line.contains('KDE') || line.contains('plasma')) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              updates.add({
                'name': parts[0],
                'type': 'kde',
                'current': parts.length > 1 ? parts[1] : '',
                'available': parts.length > 2 ? parts[2] : '',
              });
            }
          }
        }
      }
    } catch (e) {
      // KDE PackageKit might not be available
    }

    // System updates (check for system packages)
    if (distro == 'debian' || distro == 'ubuntu' || distro == 'linuxmint') {
      try {
        final result = await Process.run('apt', ['list', '--upgradable']);
        final lines = result.stdout.toString().split('\n');
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split('/');
          if (parts.length >= 2) {
            final name = parts[0];
            // Check if it's a system package
            if (name.contains('linux-') || name.contains('systemd') || name.contains('base')) {
              updates.add({
                'name': name,
                'type': 'sistema',
                'current': '',
                'available': parts[1].split(' ')[0],
              });
            }
          }
        }
      } catch (e) {
        // Error checking system updates
      }
    }

    // DNF updates (Fedora/RHEL)
    if (distro == 'fedora' || distro == 'rhel') {
      try {
        await Process.run('sudo', ['dnf', 'check-update']);
        final result = await Process.run('dnf', ['list', 'updates']);
        final lines = result.stdout.toString().split('\n');
        for (int i = 2; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            updates.add({
              'name': parts[0],
              'type': 'dnf',
              'current': parts[1],
              'available': parts.length > 2 ? parts[2] : '',
            });
          }
        }
      } catch (e) {
        // Error checking DNF updates
      }
    }

    // Pacman updates (Arch)
    if (distro == 'arch') {
      try {
        final result = await Process.run('pacman', ['-Qu']);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          final parts = trimmed.split(' ');
          if (parts.length >= 2) {
            updates.add({
              'name': parts[0],
              'type': 'pacman',
              'current': '',
              'available': parts[1],
            });
          }
        }
      } catch (e) {
        // Error checking pacman updates
      }
    }

    return updates;
  }

  static Future<bool> installUpdate(Map<String, String> update) async {
    try {
      final type = update['type'] ?? '';
      final name = update['name'] ?? '';

      switch (type) {
        case 'apt':
          await Process.run('sudo', ['apt', 'upgrade', '-y', name]);
          break;
        case 'snap':
          await Process.run('sudo', ['snap', 'refresh', name]);
          break;
        case 'flatpak':
          await Process.run('flatpak', ['update', '-y', name]);
          break;
        case 'dnf':
          await Process.run('sudo', ['dnf', 'update', '-y', name]);
          break;
        case 'pacman':
          await Process.run('sudo', ['pacman', '-Syu', '--noconfirm', name]);
          break;
        default:
          return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> installAllUpdates(List<Map<String, String>> updates) async {
    try {
      final distro = await getLinuxDistro();
      final aptUpdates = updates.where((u) => u['type'] == 'apt').toList();
      final snapUpdates = updates.where((u) => u['type'] == 'snap').toList();
      final flatpakUpdates = updates.where((u) => u['type'] == 'flatpak').toList();

      // Install APT updates
      if (aptUpdates.isNotEmpty && (distro == 'debian' || distro == 'ubuntu' || distro == 'linuxmint')) {
        await Process.run('sudo', ['apt', 'upgrade', '-y']);
      }

      // Install Snap updates
      if (snapUpdates.isNotEmpty) {
        await Process.run('sudo', ['snap', 'refresh']);
      }

      // Install Flatpak updates
      if (flatpakUpdates.isNotEmpty) {
        await Process.run('flatpak', ['update', '-y']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
