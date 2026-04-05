import 'package:flutter/material.dart';
import 'package:filemanager/theme/app_visual_theme.dart';

class ThemeConfig {
  final String name;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final Color folderColor;
  final Color fileColor;
  final Color locationColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color textSecondaryColor;
  
  // Font settings
  final String? fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final bool enableTextShadow;
  final Color? textShadowColor;
  final double textShadowBlur;
  final Offset textShadowOffset;
  final double textShadowIntensity; // Opacity/intensity of shadow (0.0 to 1.0)

  /// Ombreggiatura icone in vista griglia (file/cartelle).
  final bool enableIconShadow;
  final double iconShadowIntensity;

  ThemeConfig({
    required this.name,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.folderColor,
    required this.fileColor,
    required this.locationColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textSecondaryColor,
    this.fontFamily,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.enableTextShadow = false,
    this.textShadowColor,
    this.textShadowBlur = 2.0,
    this.textShadowOffset = const Offset(1.0, 1.0),
    this.textShadowIntensity = 0.3,
    this.enableIconShadow = true,
    this.iconShadowIntensity = 1.0,
  });

  ThemeConfig copyWith({
    String? name,
    bool? isDark,
    Color? primaryColor,
    Color? secondaryColor,
    Color? folderColor,
    Color? fileColor,
    Color? locationColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Color? textSecondaryColor,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    bool? enableTextShadow,
    Color? textShadowColor,
    double? textShadowBlur,
    Offset? textShadowOffset,
    double? textShadowIntensity,
    bool? enableIconShadow,
    double? iconShadowIntensity,
  }) {
    return ThemeConfig(
      name: name ?? this.name,
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      folderColor: folderColor ?? this.folderColor,
      fileColor: fileColor ?? this.fileColor,
      locationColor: locationColor ?? this.locationColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      enableTextShadow: enableTextShadow ?? this.enableTextShadow,
      textShadowColor: textShadowColor ?? this.textShadowColor,
      textShadowBlur: textShadowBlur ?? this.textShadowBlur,
      textShadowOffset: textShadowOffset ?? this.textShadowOffset,
      textShadowIntensity: textShadowIntensity ?? this.textShadowIntensity,
      enableIconShadow: enableIconShadow ?? this.enableIconShadow,
      iconShadowIntensity: iconShadowIntensity ?? this.iconShadowIntensity,
    );
  }

  ThemeData toThemeData() {
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: textColor,
            onBackground: textColor,
          )
        : ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            background: backgroundColor,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: textColor,
            onBackground: textColor,
          );

    final iconVis = enableIconShadow ? iconShadowIntensity.clamp(0.0, 1.0) : 0.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      extensions: <ThemeExtension<dynamic>>[
        AppVisualTheme(
          iconShadowIntensity: iconVis,
          folderIconColor: folderColor,
        ),
      ],
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textColor,
        textColor: textColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black).withOpacity(textShadowIntensity),
                    blurRadius: textShadowBlur,
                    offset: textShadowOffset,
                  ),
                ]
              : null,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize * 0.9,
          fontWeight: fontWeight,
          color: textColor,
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black).withOpacity(textShadowIntensity),
                    blurRadius: textShadowBlur,
                    offset: textShadowOffset,
                  ),
                ]
              : null,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize * 0.8,
          fontWeight: fontWeight,
          color: textSecondaryColor,
          // Caption più piccola: stesso blur/offset del body è illeggibile (es. IP in sidebar).
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black)
                        .withOpacity(textShadowIntensity * 0.45),
                    blurRadius: (textShadowBlur * 0.35).clamp(0.0, 8.0),
                    offset: Offset(
                      textShadowOffset.dx * 0.45,
                      textShadowOffset.dy * 0.45,
                    ),
                  ),
                ]
              : null,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize * 1.5,
          fontWeight: FontWeight.bold,
          color: textColor,
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black).withOpacity(textShadowIntensity),
                    blurRadius: textShadowBlur,
                    offset: textShadowOffset,
                  ),
                ]
              : null,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize * 1.2,
          fontWeight: FontWeight.w600,
          color: textColor,
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black).withOpacity(textShadowIntensity),
                    blurRadius: textShadowBlur,
                    offset: textShadowOffset,
                  ),
                ]
              : null,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
          shadows: enableTextShadow
              ? [
                  Shadow(
                    color: (textShadowColor ?? Colors.black).withOpacity(textShadowIntensity),
                    blurRadius: textShadowBlur,
                    offset: textShadowOffset,
                  ),
                ]
              : null,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: (fontSize * 0.86).clamp(11.0, 15.0),
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDark': isDark,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'folderColor': folderColor.value,
      'fileColor': fileColor.value,
      'locationColor': locationColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'textColor': textColor.value,
      'textSecondaryColor': textSecondaryColor.value,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'enableTextShadow': enableTextShadow,
      'textShadowColor': textShadowColor?.value,
      'textShadowBlur': textShadowBlur,
      'textShadowOffsetX': textShadowOffset.dx,
      'textShadowOffsetY': textShadowOffset.dy,
      'textShadowIntensity': textShadowIntensity,
      'enableIconShadow': enableIconShadow,
      'iconShadowIntensity': iconShadowIntensity,
    };
  }

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      name: json['name'] as String,
      isDark: json['isDark'] as bool,
      primaryColor: Color(json['primaryColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
      folderColor: Color(json['folderColor'] as int),
      fileColor: Color(json['fileColor'] as int),
      locationColor: Color(json['locationColor'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      surfaceColor: Color(json['surfaceColor'] as int),
      textColor: Color(json['textColor'] as int),
      textSecondaryColor: Color(json['textSecondaryColor'] as int),
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      fontWeight: FontWeight.values[json['fontWeight'] as int? ?? FontWeight.normal.index],
      enableTextShadow: json['enableTextShadow'] as bool? ?? false,
      textShadowColor: json['textShadowColor'] != null ? Color(json['textShadowColor'] as int) : null,
      textShadowBlur: (json['textShadowBlur'] as num?)?.toDouble() ?? 2.0,
      textShadowOffset: Offset(
        (json['textShadowOffsetX'] as num?)?.toDouble() ?? 1.0,
        (json['textShadowOffsetY'] as num?)?.toDouble() ?? 1.0,
      ),
      textShadowIntensity: (json['textShadowIntensity'] as num?)?.toDouble() ?? 0.3,
      enableIconShadow: json['enableIconShadow'] as bool? ?? true,
      iconShadowIntensity: (json['iconShadowIntensity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  // Predefined themes
  static ThemeConfig get lightBlue {
    return ThemeConfig(
      name: 'Blu Chiaro',
      isDark: false,
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF03A9F4),
      folderColor: const Color(0xFF2196F3),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF5F5F5), // Softer white
      surfaceColor: const Color(0xFFFFFBFE), // Softer white
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkBlue {
    return ThemeConfig(
      name: 'Blu Scuro',
      isDark: true,
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF03A9F4),
      folderColor: const Color(0xFF2196F3),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF4CAF50),
      // Slightly lighter dark like the provided screenshot.
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightGreen {
    return ThemeConfig(
      name: 'Verde Chiaro',
      isDark: false,
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF8BC34A),
      folderColor: const Color(0xFF4CAF50),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF2196F3),
      backgroundColor: const Color(0xFFF5F5F5), // Softer white
      surfaceColor: const Color(0xFFFFFBFE), // Softer white
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkGreen {
    return ThemeConfig(
      name: 'Verde Scuro',
      isDark: true,
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF8BC34A),
      folderColor: const Color(0xFF4CAF50),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF2196F3),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightPurple {
    return ThemeConfig(
      name: 'Viola Chiaro',
      isDark: false,
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFBA68C8),
      folderColor: const Color(0xFF9C27B0),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF00BCD4),
      backgroundColor: const Color(0xFFF5F5F5), // Softer white
      surfaceColor: const Color(0xFFFFFBFE), // Softer white
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkPurple {
    return ThemeConfig(
      name: 'Viola Scuro',
      isDark: true,
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFBA68C8),
      folderColor: const Color(0xFF9C27B0),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF00BCD4),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightOrange {
    return ThemeConfig(
      name: 'Arancione Chiaro',
      isDark: false,
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFC107),
      folderColor: const Color(0xFFFF9800),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF5F5F5),
      surfaceColor: const Color(0xFFFFFBFE),
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkOrange {
    return ThemeConfig(
      name: 'Arancione Scuro',
      isDark: true,
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFC107),
      folderColor: const Color(0xFFFF9800),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightRed {
    return ThemeConfig(
      name: 'Rosso Chiaro',
      isDark: false,
      primaryColor: const Color(0xFFF44336),
      secondaryColor: const Color(0xFFE91E63),
      folderColor: const Color(0xFFF44336),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF5F5F5),
      surfaceColor: const Color(0xFFFFFBFE),
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkRed {
    return ThemeConfig(
      name: 'Rosso Scuro',
      isDark: true,
      primaryColor: const Color(0xFFF44336),
      secondaryColor: const Color(0xFFE91E63),
      folderColor: const Color(0xFFF44336),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightTeal {
    return ThemeConfig(
      name: 'Teal Chiaro',
      isDark: false,
      primaryColor: const Color(0xFF009688),
      secondaryColor: const Color(0xFF00BCD4),
      folderColor: const Color(0xFF009688),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF5F5F5),
      surfaceColor: const Color(0xFFFFFBFE),
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkTeal {
    return ThemeConfig(
      name: 'Teal Scuro',
      isDark: true,
      primaryColor: const Color(0xFF009688),
      secondaryColor: const Color(0xFF00BCD4),
      folderColor: const Color(0xFF009688),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static ThemeConfig get lightIndigo {
    return ThemeConfig(
      name: 'Indaco Chiaro',
      isDark: false,
      primaryColor: const Color(0xFF3F51B5),
      secondaryColor: const Color(0xFF5C6BC0),
      folderColor: const Color(0xFF3F51B5),
      fileColor: const Color(0xFF757575),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFFF5F5F5),
      surfaceColor: const Color(0xFFFFFBFE),
      textColor: const Color(0xFF212121),
      textSecondaryColor: const Color(0xFF757575),
    );
  }

  static ThemeConfig get darkIndigo {
    return ThemeConfig(
      name: 'Indaco Scuro',
      isDark: true,
      primaryColor: const Color(0xFF3F51B5),
      secondaryColor: const Color(0xFF5C6BC0),
      folderColor: const Color(0xFF3F51B5),
      fileColor: const Color(0xFFBDBDBD),
      locationColor: const Color(0xFF4CAF50),
      backgroundColor: const Color(0xFF263238),
      surfaceColor: const Color(0xFF2E3A40),
      textColor: const Color(0xFFE0E0E0),
      textSecondaryColor: const Color(0xFFBDBDBD),
    );
  }

  static List<ThemeConfig> get predefinedThemes => [
        lightBlue,
        darkBlue,
        lightGreen,
        darkGreen,
        lightPurple,
        darkPurple,
        lightOrange,
        darkOrange,
        lightRed,
        darkRed,
        lightTeal,
        darkTeal,
        lightIndigo,
        darkIndigo,
      ];
}
