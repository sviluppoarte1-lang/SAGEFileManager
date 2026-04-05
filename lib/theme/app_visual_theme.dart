import 'package:flutter/material.dart';

/// Estensione tema per valori non coperti da [ThemeData] (es. ombra icone griglia).
class AppVisualTheme extends ThemeExtension<AppVisualTheme> {
  /// 0 = nessuna ombra; 1 = intensità di riferimento (legacy).
  final double iconShadowIntensity;

  /// Colore icone cartella in lista/griglia (allineato a [ThemeConfig.folderColor]).
  final Color folderIconColor;

  const AppVisualTheme({
    this.iconShadowIntensity = 1.0,
    this.folderIconColor = const Color(0xFF2196F3),
  });

  @override
  AppVisualTheme copyWith({
    double? iconShadowIntensity,
    Color? folderIconColor,
  }) {
    return AppVisualTheme(
      iconShadowIntensity: iconShadowIntensity ?? this.iconShadowIntensity,
      folderIconColor: folderIconColor ?? this.folderIconColor,
    );
  }

  @override
  AppVisualTheme lerp(ThemeExtension<AppVisualTheme>? other, double t) {
    if (other is! AppVisualTheme) return this;
    return AppVisualTheme(
      iconShadowIntensity:
          iconShadowIntensity +
          (other.iconShadowIntensity - iconShadowIntensity) * t,
      folderIconColor: Color.lerp(folderIconColor, other.folderIconColor, t)!,
    );
  }
}
