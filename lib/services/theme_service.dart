import 'package:shared_preferences/shared_preferences.dart';
import 'package:filemanager/models/theme_config.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

class ThemeService {
  static const String _themeKey = 'selected_theme';

  static Future<ThemeConfig> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeJson = prefs.getString(_themeKey);
    
    ThemeConfig theme;
    if (themeJson != null) {
      try {
        theme = ThemeConfig.fromJson(json.decode(themeJson));
      } catch (e) {
        theme = ThemeConfig.lightBlue;
      }
    } else {
      theme = ThemeConfig.lightBlue;
    }

    // Preferenze → Schermata Preferenze: font globali devono sempre applicarsi sopra il tema salvato.
    final fontFamily = prefs.getString('font_family');
    final fontSize = prefs.getDouble('font_size') ?? theme.fontSize;
    final fontWeightIndex = prefs.getInt('font_weight');
    final fontWeight = fontWeightIndex != null 
        ? FontWeight.values[fontWeightIndex] 
        : theme.fontWeight;
    final enableTextShadow = prefs.getBool('enable_text_shadow') ?? theme.enableTextShadow;
    final textShadowBlur = prefs.getDouble('text_shadow_blur') ?? theme.textShadowBlur;
    final textShadowOffsetX = prefs.getDouble('text_shadow_offset_x') ?? theme.textShadowOffset.dx;
    final textShadowOffsetY = prefs.getDouble('text_shadow_offset_y') ?? theme.textShadowOffset.dy;
    final textShadowColorValue = prefs.getInt('text_shadow_color');
    final textShadowColor = textShadowColorValue != null 
        ? Color(textShadowColorValue) 
        : theme.textShadowColor;
    final textShadowIntensity = prefs.getDouble('text_shadow_intensity') ?? theme.textShadowIntensity;
    final enableIconShadow = prefs.getBool('enable_icon_shadow') ?? theme.enableIconShadow;
    final iconShadowIntensity = prefs.getDouble('icon_shadow_intensity') ?? theme.iconShadowIntensity;

    return ThemeConfig(
      name: theme.name,
      isDark: theme.isDark,
      primaryColor: theme.primaryColor,
      secondaryColor: theme.secondaryColor,
      folderColor: theme.folderColor,
      fileColor: theme.fileColor,
      locationColor: theme.locationColor,
      backgroundColor: theme.backgroundColor,
      surfaceColor: theme.surfaceColor,
      textColor: theme.textColor,
      textSecondaryColor: theme.textSecondaryColor,
      fontFamily: fontFamily ?? theme.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      enableTextShadow: enableTextShadow,
      textShadowColor: textShadowColor,
      textShadowBlur: textShadowBlur,
      textShadowOffset: Offset(textShadowOffsetX, textShadowOffsetY),
      textShadowIntensity: textShadowIntensity,
      enableIconShadow: enableIconShadow,
      iconShadowIntensity: iconShadowIntensity,
    );
  }

  static Future<void> setTheme(ThemeConfig theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, json.encode(theme.toJson()));
  }

  static Future<List<ThemeConfig>> getSavedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final themesJson = prefs.getStringList('saved_themes');
    
    if (themesJson != null) {
      return themesJson
          .map((json) => ThemeConfig.fromJson(jsonDecode(json)))
          .toList();
    }
    
    return [];
  }

  static Future<void> saveCustomTheme(ThemeConfig theme) async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemes = await getSavedThemes();
    
    // Check if theme with same name exists
    final existingIndex = savedThemes.indexWhere((t) => t.name == theme.name);
    if (existingIndex >= 0) {
      savedThemes[existingIndex] = theme;
    } else {
      savedThemes.add(theme);
    }
    
    final themesJson = savedThemes.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('saved_themes', themesJson);
  }

  static Future<void> deleteCustomTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemes = await getSavedThemes();
    savedThemes.removeWhere((t) => t.name == themeName);
    
    final themesJson = savedThemes.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('saved_themes', themesJson);
  }
}
