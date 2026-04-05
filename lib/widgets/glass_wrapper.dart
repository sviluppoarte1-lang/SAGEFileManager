import 'package:flutter/material.dart';
import 'dart:ui';

/// Wrapper widget che applica un effetto glass/trasparenza con blur
/// Basato sulle best practices per effetti di trasparenza in Flutter
class GlassWrapper extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;

  const GlassWrapper({
    super.key,
    required this.child,
    this.opacity = 0.7,
    this.blur = 10.0,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? 
        theme.scaffoldBackgroundColor.withOpacity(opacity); // Usa scaffoldBackgroundColor come default

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
