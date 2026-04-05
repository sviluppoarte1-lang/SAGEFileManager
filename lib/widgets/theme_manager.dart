import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:filemanager/models/theme_config.dart';
import 'package:filemanager/services/theme_service.dart';
import 'package:filemanager/services/folder_icon_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeManager extends StatefulWidget {
  final Function(ThemeConfig) onThemeChanged;

  const ThemeManager({super.key, required this.onThemeChanged});

  @override
  State<ThemeManager> createState() => _ThemeManagerState();
}

class _ThemeManagerState extends State<ThemeManager> {
  ThemeConfig? currentTheme;
  List<ThemeConfig> customThemes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => isLoading = true);
    final theme = await ThemeService.getCurrentTheme();
    final custom = await ThemeService.getSavedThemes();
    setState(() {
      currentTheme = theme;
      customThemes = custom;
      isLoading = false;
    });
  }

  /// [showSnackBar]: solo per selezione esplicita del tema (lista o salvataggio dialogo).
  /// I controlli a destra (slider, colori, font) chiamano [showSnackBar] false per evitare
  /// snackbar in loop a ogni tick dello slider.
  Future<void> _applyTheme(ThemeConfig theme, {bool showSnackBar = false}) async {
    await ThemeService.setTheme(theme);
    setState(() => currentTheme = theme);
    widget.onThemeChanged(theme);
    // Theme change must override any folder color customizations.
    try {
      await FolderIconService.clearAllFolderColors();
      await FolderIconService.setSelectedColorIsCustom(false);
      await FolderIconService.setSelectedColor(theme.folderColor.value);
    } catch (_) {}
    if (mounted && showSnackBar) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.themeAppliedSnackbar(theme.name))),
      );
    }
  }

  Future<Color?> _showColorPicker(
    AppLocalizations l10n,
    String title,
    Color currentColor,
  ) async {
    Color selectedColor = currentColor;
    final result = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hslWithSaturation,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, selectedColor),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _showCustomThemeEditor([ThemeConfig? theme]) async {
    final l10n = AppLocalizations.of(context);
    final isEditing = theme != null;
    final editingTheme = theme ?? ThemeConfig.lightBlue;
    
    ThemeConfig newTheme = ThemeConfig(
      name: editingTheme.name,
      isDark: editingTheme.isDark,
      primaryColor: editingTheme.primaryColor,
      secondaryColor: editingTheme.secondaryColor,
      folderColor: editingTheme.folderColor,
      fileColor: editingTheme.fileColor,
      locationColor: editingTheme.locationColor,
      backgroundColor: editingTheme.backgroundColor,
      surfaceColor: editingTheme.surfaceColor,
      textColor: editingTheme.textColor,
      textSecondaryColor: editingTheme.textSecondaryColor,
      fontFamily: editingTheme.fontFamily,
      fontSize: editingTheme.fontSize,
      fontWeight: editingTheme.fontWeight,
      enableTextShadow: editingTheme.enableTextShadow,
      textShadowColor: editingTheme.textShadowColor,
      textShadowBlur: editingTheme.textShadowBlur,
      textShadowOffset: editingTheme.textShadowOffset,
      textShadowIntensity: editingTheme.textShadowIntensity,
      enableIconShadow: editingTheme.enableIconShadow,
      iconShadowIntensity: editingTheme.iconShadowIntensity,
    );
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? l10n.themeEditTitle : l10n.themeNewTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  enableInteractiveSelection: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: l10n.themeFieldName,
                    border: const OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: newTheme.name),
                  onChanged: (value) {
                    setDialogState(() {
                      newTheme = ThemeConfig(
                        name: value,
                        isDark: newTheme.isDark,
                        primaryColor: newTheme.primaryColor,
                        secondaryColor: newTheme.secondaryColor,
                        folderColor: newTheme.folderColor,
                        fileColor: newTheme.fileColor,
                        locationColor: newTheme.locationColor,
                        backgroundColor: newTheme.backgroundColor,
                        surfaceColor: newTheme.surfaceColor,
                        textColor: newTheme.textColor,
                        textSecondaryColor: newTheme.textSecondaryColor,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.themeDarkThemeSwitch),
                  value: newTheme.isDark,
                  onChanged: (value) {
                    setDialogState(() {
                      newTheme = ThemeConfig(
                        name: newTheme.name,
                        isDark: value,
                        primaryColor: newTheme.primaryColor,
                        secondaryColor: newTheme.secondaryColor,
                        folderColor: newTheme.folderColor,
                        fileColor: newTheme.fileColor,
                        locationColor: newTheme.locationColor,
                        backgroundColor: value
                            ? const Color(0xFF263238)
                            : const Color(0xFFFAFAFA),
                        surfaceColor: value
                            ? const Color(0xFF2E3A40)
                            : Colors.white,
                        textColor: value
                            ? const Color(0xFFE0E0E0)
                            : const Color(0xFF212121),
                        textSecondaryColor: value
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFF757575),
                      );
                    });
                  },
                ),
                const Divider(),
                _buildColorPickerTile(
                  l10n.themeColorPrimary,
                  newTheme.primaryColor,
                  (color) async {
                    final selected = await _showColorPicker(l10n, l10n.themeColorPrimary, color);
                    if (selected != null) {
                      setDialogState(() {
                        newTheme = ThemeConfig(
                          name: newTheme.name,
                          isDark: newTheme.isDark,
                          primaryColor: selected,
                          secondaryColor: newTheme.secondaryColor,
                          folderColor: newTheme.folderColor,
                          fileColor: newTheme.fileColor,
                          locationColor: newTheme.locationColor,
                          backgroundColor: newTheme.backgroundColor,
                          surfaceColor: newTheme.surfaceColor,
                          textColor: newTheme.textColor,
                          textSecondaryColor: newTheme.textSecondaryColor,
                        );
                      });
                    }
                  },
                ),
                _buildColorPickerTile(
                  l10n.themeColorSecondary,
                  newTheme.secondaryColor,
                  (color) async {
                    final selected = await _showColorPicker(l10n, l10n.themeColorSecondary, color);
                    if (selected != null) {
                      setDialogState(() {
                        newTheme = ThemeConfig(
                          name: newTheme.name,
                          isDark: newTheme.isDark,
                          primaryColor: newTheme.primaryColor,
                          secondaryColor: selected,
                          folderColor: newTheme.folderColor,
                          fileColor: newTheme.fileColor,
                          locationColor: newTheme.locationColor,
                          backgroundColor: newTheme.backgroundColor,
                          surfaceColor: newTheme.surfaceColor,
                          textColor: newTheme.textColor,
                          textSecondaryColor: newTheme.textSecondaryColor,
                        );
                      });
                    }
                  },
                ),
                _buildColorPickerTile(
                  l10n.themeColorFile,
                  newTheme.fileColor,
                  (color) async {
                    final selected = await _showColorPicker(l10n, l10n.themeColorFile, color);
                    if (selected != null) {
                      setDialogState(() {
                        newTheme = ThemeConfig(
                          name: newTheme.name,
                          isDark: newTheme.isDark,
                          primaryColor: newTheme.primaryColor,
                          secondaryColor: newTheme.secondaryColor,
                          folderColor: newTheme.folderColor,
                          fileColor: selected,
                          locationColor: newTheme.locationColor,
                          backgroundColor: newTheme.backgroundColor,
                          surfaceColor: newTheme.surfaceColor,
                          textColor: newTheme.textColor,
                          textSecondaryColor: newTheme.textSecondaryColor,
                        );
                      });
                    }
                  },
                ),
                _buildColorPickerTile(
                  l10n.themeColorLocation,
                  newTheme.locationColor,
                  (color) async {
                    final selected = await _showColorPicker(l10n, l10n.themeColorLocation, color);
                    if (selected != null) {
                      setDialogState(() {
                        newTheme = ThemeConfig(
                          name: newTheme.name,
                          isDark: newTheme.isDark,
                          primaryColor: newTheme.primaryColor,
                          secondaryColor: newTheme.secondaryColor,
                          folderColor: newTheme.folderColor,
                          fileColor: newTheme.fileColor,
                          locationColor: selected,
                          backgroundColor: newTheme.backgroundColor,
                          surfaceColor: newTheme.surfaceColor,
                          textColor: newTheme.textColor,
                          textSecondaryColor: newTheme.textSecondaryColor,
                        );
                      });
                    }
                  },
                ),
                _buildColorPickerTile(
                  l10n.themeColorBackground,
                  newTheme.backgroundColor,
                  (color) async {
                    final selected = await _showColorPicker(l10n, l10n.themeColorBackground, color);
                    if (selected != null) {
                      setDialogState(() {
                        newTheme = ThemeConfig(
                          name: newTheme.name,
                          isDark: newTheme.isDark,
                          primaryColor: newTheme.primaryColor,
                          secondaryColor: newTheme.secondaryColor,
                          folderColor: newTheme.folderColor,
                          fileColor: newTheme.fileColor,
                          locationColor: newTheme.locationColor,
                          backgroundColor: selected,
                          surfaceColor: newTheme.surfaceColor,
                          textColor: newTheme.textColor,
                          textSecondaryColor: newTheme.textSecondaryColor,
                        );
                      });
                    }
                  },
                ),
                const Divider(),
                // Sezione Font
                _buildFontSection(l10n, (updatedTheme) {
                  setDialogState(() {
                    newTheme = updatedTheme;
                  });
                }, newTheme),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ThemeService.saveCustomTheme(newTheme);
                // Apply the theme if it's the current theme or if it's a new theme
                if (isEditing && currentTheme?.name == newTheme.name) {
                  await _applyTheme(newTheme, showSnackBar: true);
                }
                _loadThemes();
              },
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerTile(String title, Color color, Function(Color) onColorChanged) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
      onTap: () => onColorChanged(color),
    );
  }

  Widget _buildFontSection(AppLocalizations l10n, Function(ThemeConfig) updateTheme, ThemeConfig newTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeFontHeader,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildColorPickerTile(
          l10n.themeFontFamilyRow,
          Colors.transparent,
          (_) async {
            final selectedFont = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.labelSelectFont),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(l10n.fontFamilyDefaultSystem),
                        onTap: () => Navigator.pop(ctx, null),
                      ),
                      ListTile(
                        title: const Text('Roboto'),
                        onTap: () => Navigator.pop(ctx, 'Roboto'),
                      ),
                      ListTile(
                        title: const Text('Open Sans'),
                        onTap: () => Navigator.pop(ctx, 'Open Sans'),
                      ),
                      ListTile(
                        title: const Text('Lato'),
                        onTap: () => Navigator.pop(ctx, 'Lato'),
                      ),
                      ListTile(
                        title: const Text('Montserrat'),
                        onTap: () => Navigator.pop(ctx, 'Montserrat'),
                      ),
                      ListTile(
                        title: const Text('Raleway'),
                        onTap: () => Navigator.pop(ctx, 'Raleway'),
                      ),
                      ListTile(
                        title: const Text('Ubuntu'),
                        onTap: () => Navigator.pop(ctx, 'Ubuntu'),
                      ),
                      ListTile(
                        title: const Text('Noto Sans'),
                        onTap: () => Navigator.pop(ctx, 'Noto Sans'),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (selectedFont != null || selectedFont == null) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: selectedFont,
                fontSize: newTheme.fontSize,
                fontWeight: newTheme.fontWeight,
              ));
            }
          },
        ),
        ListTile(
          title: Text(l10n.themeFontSizeRow(newTheme.fontSize.toStringAsFixed(1))),
          subtitle: Slider(
            value: newTheme.fontSize,
            min: 10.0,
            max: 24.0,
            divisions: 28,
            onChanged: (value) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: newTheme.fontFamily,
                fontSize: value,
                fontWeight: newTheme.fontWeight,
              ));
            },
          ),
        ),
        RadioListTile<FontWeight>(
          title: Text(l10n.prefsFontWeightNormal),
          value: FontWeight.normal,
          groupValue: newTheme.fontWeight,
          onChanged: (value) {
            if (value != null) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: newTheme.fontFamily,
                fontSize: newTheme.fontSize,
                fontWeight: value,
              ));
            }
          },
        ),
        RadioListTile<FontWeight>(
          title: Text(l10n.prefsFontWeightBold),
          value: FontWeight.bold,
          groupValue: newTheme.fontWeight,
          onChanged: (value) {
            if (value != null) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: newTheme.fontFamily,
                fontSize: newTheme.fontSize,
                fontWeight: value,
              ));
            }
          },
        ),
        RadioListTile<FontWeight>(
          title: Text(l10n.prefsFontWeightSemiBold),
          value: FontWeight.w600,
          groupValue: newTheme.fontWeight,
          onChanged: (value) {
            if (value != null) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: newTheme.fontFamily,
                fontSize: newTheme.fontSize,
                fontWeight: value,
              ));
            }
          },
        ),
        RadioListTile<FontWeight>(
          title: Text(l10n.prefsFontWeightMedium),
          value: FontWeight.w500,
          groupValue: newTheme.fontWeight,
          onChanged: (value) {
            if (value != null) {
              updateTheme(ThemeConfig(
                name: newTheme.name,
                isDark: newTheme.isDark,
                primaryColor: newTheme.primaryColor,
                secondaryColor: newTheme.secondaryColor,
                folderColor: newTheme.folderColor,
                fileColor: newTheme.fileColor,
                locationColor: newTheme.locationColor,
                backgroundColor: newTheme.backgroundColor,
                surfaceColor: newTheme.surfaceColor,
                textColor: newTheme.textColor,
                textSecondaryColor: newTheme.textSecondaryColor,
                fontFamily: newTheme.fontFamily,
                fontSize: newTheme.fontSize,
                fontWeight: value,
              ));
            }
          },
        ),
      ],
    );
  }

  String _folderIconLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case 'folder':
        return l10n.themeFolderIconFolder;
      case 'folder_open':
        return l10n.themeFolderIconFolderOpen;
      case 'folder_special':
        return l10n.themeFolderIconFolderSpecial;
      case 'folder_shared':
        return l10n.themeFolderIconFolderShared;
      case 'folder_copy':
        return l10n.themeFolderIconFolderCopy;
      case 'folder_delete':
        return l10n.themeFolderIconFolderDelete;
      case 'folder_zip':
        return l10n.themeFolderIconFolderZip;
      case 'folder_off':
        return l10n.themeFolderIconFolderOff;
      case 'folder_plus':
        return l10n.themeFolderIconFolderPlus;
      case 'folder_home':
        return l10n.themeFolderIconFolderHome;
      case 'folder_drive':
        return l10n.themeFolderIconFolderDrive;
      case 'folder_cloud':
        return l10n.themeFolderIconFolderCloud;
      default:
        return id;
    }
  }

  Widget _buildFolderIconsSection(AppLocalizations l10n) {
    final folderIcons = [
      {'id': 'folder', 'iconData': Icons.folder},
      {'id': 'folder_open', 'iconData': Icons.folder_open},
      {'id': 'folder_special', 'iconData': Icons.folder_special},
      {'id': 'folder_shared', 'iconData': Icons.folder_shared},
      {'id': 'folder_copy', 'iconData': Icons.folder_copy},
      {'id': 'folder_delete', 'iconData': Icons.folder_delete},
      {'id': 'folder_zip', 'iconData': Icons.folder_zip},
      {'id': 'folder_off', 'iconData': Icons.folder_off},
      {'id': 'folder_plus', 'iconData': Icons.create_new_folder},
      {'id': 'folder_home', 'iconData': Icons.home},
      {'id': 'folder_drive', 'iconData': Icons.storage},
      {'id': 'folder_cloud', 'iconData': Icons.cloud},
    ];

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadFolderIconSettings(),
      builder: (context, snapshot) {
        final selectedIcon = snapshot.data?['icon'] ?? 'folder';
        final selectedColor = snapshot.data?['color'] as Color?;
        final effectiveColor = selectedColor ?? currentTheme?.folderColor ?? Colors.orange;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              l10n.themeFolderIconsHint,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: folderIcons.map((iconData) {
                    final id = iconData['id'] as String;
                    final isSelected = id == selectedIcon;
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData['iconData'] as IconData,
                            size: 40,
                            color: effectiveColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _folderIconLabel(l10n, iconData['id'] as String),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.themeFolderIconPickColor,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                    Colors.teal,
                    Colors.amber,
                    Colors.pink,
                    Colors.indigo,
                    Colors.cyan,
                    Colors.brown,
                    Colors.grey,
                  ].map((color) {
                    final isSelected = selectedColor?.value == color.value;
                    return InkWell(
                      onTap: () async {
                        await FolderIconService.setSelectedColor(color.value);
                        await FolderIconService.setSelectedColorIsCustom(true);
                        if (mounted) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.themeColorPickedSnack),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadFolderIconSettings() async {
    final icon = await FolderIconService.getSelectedIcon();
    final colorValue = await FolderIconService.getSelectedColor();
    return {
      'icon': icon,
      'color': colorValue != null ? Color(colorValue) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.themeManagerTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCustomThemeEditor(),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    // Colonna sinistra: Nomi dei temi
                    Expanded(
                      flex: 2,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.themeBuiltinHeader,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...ThemeConfig.predefinedThemes.map((theme) => _buildThemeCard(l10n, theme)),
                          if (customThemes.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                l10n.themeCustomHeader,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...customThemes.map((theme) => _buildThemeCard(l10n, theme, isCustom: true)),
                          ],
                        ],
                      ),
                    ),
                    // Divider verticale
                    const VerticalDivider(width: 1),
                    // Colonna destra: Font, ombreggiatura, cartelle e colori
                    Expanded(
                      flex: 3,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.themeCustomizationHeader,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (currentTheme != null) ...[
                            _buildFontSectionForCurrentTheme(l10n, currentTheme!),
                            const SizedBox(height: 16),
                            _buildColorSectionForCurrentTheme(l10n, currentTheme!),
                            const SizedBox(height: 16),
                            _buildFolderIconsSection(l10n),
                          ] else
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(l10n.themeSelectPrompt),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(AppLocalizations l10n, ThemeConfig theme, {bool isCustom = false}) {
    final isSelected = currentTheme?.name == theme.name;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          theme.name,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          theme.isDark ? l10n.themeVariantDark : l10n.themeVariantLight,
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check, color: Colors.green, size: 18),
            if (isCustom) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showCustomThemeEditor(theme),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await ThemeService.deleteCustomTheme(theme.name);
                  _loadThemes();
                },
              ),
            ],
          ],
        ),
        onTap: () => _applyTheme(theme, showSnackBar: true),
      ),
    );
  }

  Widget _buildFontSectionForCurrentTheme(AppLocalizations l10n, ThemeConfig theme) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.themeFontHeader,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Famiglia font
            ListTile(
              dense: true,
              title: Text(l10n.themeFontFamilyRow, style: const TextStyle(fontSize: 14)),
              subtitle: Text(theme.fontFamily ?? l10n.fontFamilyDefaultSystem, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final selectedFont = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.labelSelectFont),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(l10n.fontFamilyDefaultSystem),
                            onTap: () => Navigator.pop(ctx, null),
                          ),
                          ListTile(
                            title: const Text('Roboto'),
                            onTap: () => Navigator.pop(ctx, 'Roboto'),
                          ),
                          ListTile(
                            title: const Text('Open Sans'),
                            onTap: () => Navigator.pop(ctx, 'Open Sans'),
                          ),
                          ListTile(
                            title: const Text('Lato'),
                            onTap: () => Navigator.pop(ctx, 'Lato'),
                          ),
                          ListTile(
                            title: const Text('Montserrat'),
                            onTap: () => Navigator.pop(ctx, 'Montserrat'),
                          ),
                          ListTile(
                            title: const Text('Raleway'),
                            onTap: () => Navigator.pop(ctx, 'Raleway'),
                          ),
                          ListTile(
                            title: const Text('Ubuntu'),
                            onTap: () => Navigator.pop(ctx, 'Ubuntu'),
                          ),
                          ListTile(
                            title: const Text('Noto Sans'),
                            onTap: () => Navigator.pop(ctx, 'Noto Sans'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (selectedFont != null || selectedFont == null) {
                  final updatedTheme = ThemeConfig(
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
                    fontFamily: selectedFont,
                    fontSize: theme.fontSize,
                    fontWeight: theme.fontWeight,
                    enableTextShadow: theme.enableTextShadow,
                    textShadowColor: theme.textShadowColor,
                    textShadowBlur: theme.textShadowBlur,
                    textShadowOffset: theme.textShadowOffset,
                    textShadowIntensity: theme.textShadowIntensity,
                    enableIconShadow: theme.enableIconShadow,
                    iconShadowIntensity: theme.iconShadowIntensity,
                  );
                  await ThemeService.setTheme(updatedTheme);
                  await _applyTheme(updatedTheme);
                }
              },
            ),
            // Dimensione font
            ListTile(
              dense: true,
              title: Text(l10n.themeFontSizeRow(theme.fontSize.toStringAsFixed(1)), style: const TextStyle(fontSize: 14)),
              subtitle: Slider(
                value: theme.fontSize,
                min: 10.0,
                max: 24.0,
                divisions: 28,
                onChanged: (value) async {
                  final updatedTheme = ThemeConfig(
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
                    fontFamily: theme.fontFamily,
                    fontSize: value,
                    fontWeight: theme.fontWeight,
                    enableTextShadow: theme.enableTextShadow,
                    textShadowColor: theme.textShadowColor,
                    textShadowBlur: theme.textShadowBlur,
                    textShadowOffset: theme.textShadowOffset,
                    textShadowIntensity: theme.textShadowIntensity,
                    enableIconShadow: theme.enableIconShadow,
                    iconShadowIntensity: theme.iconShadowIntensity,
                  );
                  await ThemeService.setTheme(updatedTheme);
                  await _applyTheme(updatedTheme);
                },
              ),
            ),
            // Peso font
            ListTile(
              dense: true,
              title: Text(l10n.themeFontWeightHeader, style: const TextStyle(fontSize: 14)),
              subtitle: Column(
                children: [
                  RadioListTile<FontWeight>(
                    dense: true,
                    title: Text(l10n.prefsFontWeightNormal, style: const TextStyle(fontSize: 12)),
                    value: FontWeight.normal,
                    groupValue: theme.fontWeight,
                    onChanged: (value) async {
                      if (value != null) {
                        final updatedTheme = ThemeConfig(
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
                          fontFamily: theme.fontFamily,
                          fontSize: theme.fontSize,
                          fontWeight: value,
                          enableTextShadow: theme.enableTextShadow,
                          textShadowColor: theme.textShadowColor,
                          textShadowBlur: theme.textShadowBlur,
                          textShadowOffset: theme.textShadowOffset,
                          textShadowIntensity: theme.textShadowIntensity,
                          enableIconShadow: theme.enableIconShadow,
                          iconShadowIntensity: theme.iconShadowIntensity,
                        );
                        await ThemeService.setTheme(updatedTheme);
                        await _applyTheme(updatedTheme);
                      }
                    },
                  ),
                  RadioListTile<FontWeight>(
                    dense: true,
                    title: Text(l10n.prefsFontWeightBold, style: const TextStyle(fontSize: 12)),
                    value: FontWeight.bold,
                    groupValue: theme.fontWeight,
                    onChanged: (value) async {
                      if (value != null) {
                        final updatedTheme = ThemeConfig(
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
                          fontFamily: theme.fontFamily,
                          fontSize: theme.fontSize,
                          fontWeight: value,
                          enableTextShadow: theme.enableTextShadow,
                          textShadowColor: theme.textShadowColor,
                          textShadowBlur: theme.textShadowBlur,
                          textShadowOffset: theme.textShadowOffset,
                          textShadowIntensity: theme.textShadowIntensity,
                          enableIconShadow: theme.enableIconShadow,
                          iconShadowIntensity: theme.iconShadowIntensity,
                        );
                        await ThemeService.setTheme(updatedTheme);
                        await _applyTheme(updatedTheme);
                      }
                    },
                  ),
                ],
              ),
            ),
            // Ombreggiatura
            SwitchListTile(
              dense: true,
              title: Text(l10n.themeTextShadow, style: const TextStyle(fontSize: 14)),
              value: theme.enableTextShadow,
              onChanged: (value) async {
                final updatedTheme = ThemeConfig(
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
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize,
                  fontWeight: theme.fontWeight,
                  enableTextShadow: value,
                  textShadowColor: theme.textShadowColor ?? Colors.black,
                  textShadowBlur: theme.textShadowBlur,
                  textShadowOffset: theme.textShadowOffset,
                  textShadowIntensity: theme.textShadowIntensity,
                  enableIconShadow: theme.enableIconShadow,
                  iconShadowIntensity: theme.iconShadowIntensity,
                );
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              },
            ),
            // Intensità ombreggiatura (solo se ombreggiatura è abilitata)
            if (theme.enableTextShadow)
              ListTile(
                dense: true,
                title: Text(
                  l10n.themeShadowIntensityRow((theme.textShadowIntensity * 100).toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Slider(
                  value: theme.textShadowIntensity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (value) async {
                    final updatedTheme = ThemeConfig(
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
                      fontFamily: theme.fontFamily,
                      fontSize: theme.fontSize,
                      fontWeight: theme.fontWeight,
                      enableTextShadow: theme.enableTextShadow,
                      textShadowColor: theme.textShadowColor ?? Colors.black,
                      textShadowBlur: theme.textShadowBlur,
                      textShadowOffset: theme.textShadowOffset,
                      textShadowIntensity: value,
                      enableIconShadow: theme.enableIconShadow,
                      iconShadowIntensity: theme.iconShadowIntensity,
                    );
                    await ThemeService.setTheme(updatedTheme);
                    await _applyTheme(updatedTheme);
                  },
                ),
              ),
            SwitchListTile(
              dense: true,
              title: Text(
                l10n.themeIconShadowTitle,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                l10n.themeIconShadowSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              value: theme.enableIconShadow,
              onChanged: (value) async {
                final updatedTheme = theme.copyWith(enableIconShadow: value);
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              },
            ),
            if (theme.enableIconShadow)
              ListTile(
                dense: true,
                title: Text(
                  l10n.themeIconShadowIntensity(
                    (theme.iconShadowIntensity * 100).toStringAsFixed(0),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Slider(
                  value: theme.iconShadowIntensity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (value) async {
                    final updatedTheme = theme.copyWith(iconShadowIntensity: value);
                    await ThemeService.setTheme(updatedTheme);
                    await _applyTheme(updatedTheme);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSectionForCurrentTheme(AppLocalizations l10n, ThemeConfig theme) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.themeColorsHeader,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildColorPickerTile(l10n.themeColorPrimary, theme.primaryColor, (color) async {
              final selected = await _showColorPicker(l10n, l10n.themeColorPrimary, color);
              if (selected != null) {
                final updatedTheme = ThemeConfig(
                  name: theme.name,
                  isDark: theme.isDark,
                  primaryColor: selected,
                  secondaryColor: theme.secondaryColor,
                  folderColor: theme.folderColor,
                  fileColor: theme.fileColor,
                  locationColor: theme.locationColor,
                  backgroundColor: theme.backgroundColor,
                  surfaceColor: theme.surfaceColor,
                  textColor: theme.textColor,
                  textSecondaryColor: theme.textSecondaryColor,
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize,
                  fontWeight: theme.fontWeight,
                  enableTextShadow: theme.enableTextShadow,
                  textShadowColor: theme.textShadowColor,
                  textShadowBlur: theme.textShadowBlur,
                  textShadowOffset: theme.textShadowOffset,
                  textShadowIntensity: theme.textShadowIntensity,
                  enableIconShadow: theme.enableIconShadow,
                  iconShadowIntensity: theme.iconShadowIntensity,
                );
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              }
            }),
            _buildColorPickerTile(l10n.themeColorSecondary, theme.secondaryColor, (color) async {
              final selected = await _showColorPicker(l10n, l10n.themeColorSecondary, color);
              if (selected != null) {
                final updatedTheme = ThemeConfig(
                  name: theme.name,
                  isDark: theme.isDark,
                  primaryColor: theme.primaryColor,
                  secondaryColor: selected,
                  folderColor: theme.folderColor,
                  fileColor: theme.fileColor,
                  locationColor: theme.locationColor,
                  backgroundColor: theme.backgroundColor,
                  surfaceColor: theme.surfaceColor,
                  textColor: theme.textColor,
                  textSecondaryColor: theme.textSecondaryColor,
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize,
                  fontWeight: theme.fontWeight,
                  enableTextShadow: theme.enableTextShadow,
                  textShadowColor: theme.textShadowColor,
                  textShadowBlur: theme.textShadowBlur,
                  textShadowOffset: theme.textShadowOffset,
                  textShadowIntensity: theme.textShadowIntensity,
                  enableIconShadow: theme.enableIconShadow,
                  iconShadowIntensity: theme.iconShadowIntensity,
                );
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              }
            }),
            _buildColorPickerTile(l10n.themeColorFolder, theme.folderColor, (color) async {
              final selected = await _showColorPicker(l10n, l10n.themeColorFolder, color);
              if (selected != null) {
                final updatedTheme = ThemeConfig(
                  name: theme.name,
                  isDark: theme.isDark,
                  primaryColor: theme.primaryColor,
                  secondaryColor: theme.secondaryColor,
                  folderColor: selected,
                  fileColor: theme.fileColor,
                  locationColor: theme.locationColor,
                  backgroundColor: theme.backgroundColor,
                  surfaceColor: theme.surfaceColor,
                  textColor: theme.textColor,
                  textSecondaryColor: theme.textSecondaryColor,
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize,
                  fontWeight: theme.fontWeight,
                  enableTextShadow: theme.enableTextShadow,
                  textShadowColor: theme.textShadowColor,
                  textShadowBlur: theme.textShadowBlur,
                  textShadowOffset: theme.textShadowOffset,
                  textShadowIntensity: theme.textShadowIntensity,
                  enableIconShadow: theme.enableIconShadow,
                  iconShadowIntensity: theme.iconShadowIntensity,
                );
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              }
            }),
            _buildColorPickerTile(l10n.themeColorFile, theme.fileColor, (color) async {
              final selected = await _showColorPicker(l10n, l10n.themeColorFile, color);
              if (selected != null) {
                final updatedTheme = ThemeConfig(
                  name: theme.name,
                  isDark: theme.isDark,
                  primaryColor: theme.primaryColor,
                  secondaryColor: theme.secondaryColor,
                  folderColor: theme.folderColor,
                  fileColor: selected,
                  locationColor: theme.locationColor,
                  backgroundColor: theme.backgroundColor,
                  surfaceColor: theme.surfaceColor,
                  textColor: theme.textColor,
                  textSecondaryColor: theme.textSecondaryColor,
                  fontFamily: theme.fontFamily,
                  fontSize: theme.fontSize,
                  fontWeight: theme.fontWeight,
                  enableTextShadow: theme.enableTextShadow,
                  textShadowColor: theme.textShadowColor,
                  textShadowBlur: theme.textShadowBlur,
                  textShadowOffset: theme.textShadowOffset,
                  textShadowIntensity: theme.textShadowIntensity,
                  enableIconShadow: theme.enableIconShadow,
                  iconShadowIntensity: theme.iconShadowIntensity,
                );
                await ThemeService.setTheme(updatedTheme);
                await _applyTheme(updatedTheme);
              }
            }),
          ],
        ),
      ),
    );
  }

}
