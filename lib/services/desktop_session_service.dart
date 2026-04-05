import 'dart:io';

import 'package:filemanager/services/logging_service.dart';

/// Linux display / session kind for embedder-specific workarounds.
enum DesktopCompositorKind {
  /// Wayland session (priorità: ambiente più comune su desktop Linux moderni).
  wayland,

  /// X11 session.
  x11,

  /// Non Linux o non determinabile.
  unknown,
}

/// Rileva Wayland vs X11 all’avvio e offre flag per ottimizzazioni (es. sync tastiera).
class DesktopSessionService {
  DesktopSessionService._();

  static DesktopCompositorKind? _kind;

  static DesktopCompositorKind get kind => _kind ?? DesktopCompositorKind.unknown;

  static bool get isWayland => kind == DesktopCompositorKind.wayland;

  static bool get isX11 => kind == DesktopCompositorKind.x11;

  /// Da chiamare una volta dopo [WidgetsFlutterBinding.ensureInitialized] (es. in main).
  static Future<void> detectAndLog() async {
    if (!Platform.isLinux) {
      _kind = DesktopCompositorKind.unknown;
      await LoggingService.info('DesktopSession', 'Non-Linux; compositor=unknown');
      return;
    }

    final env = Platform.environment;
    final sessionType = env['XDG_SESSION_TYPE']?.toLowerCase();
    final waylandDisplay = env['WAYLAND_DISPLAY'];
    final onWayland = sessionType == 'wayland' ||
        (waylandDisplay != null && waylandDisplay.isNotEmpty);

    if (onWayland) {
      _kind = DesktopCompositorKind.wayland;
    } else if (sessionType == 'x11' ||
        (env['DISPLAY'] != null && env['DISPLAY']!.isNotEmpty)) {
      _kind = DesktopCompositorKind.x11;
    } else {
      _kind = DesktopCompositorKind.unknown;
    }

    await LoggingService.info('DesktopSession', 'Session detected', {
      'compositor': _kind!.name,
      'XDG_SESSION_TYPE': sessionType ?? '',
      'WAYLAND_DISPLAY': waylandDisplay ?? '',
      'DISPLAY': env['DISPLAY'] ?? '',
    });
  }
}
