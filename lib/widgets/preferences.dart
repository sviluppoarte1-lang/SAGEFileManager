import 'package:flutter/material.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filemanager/services/thumbnail_cache_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:filemanager/widgets/dialog_enter_scope.dart';
import 'dart:io';

class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  String _selectedSection = 'general';
  
  // General settings
  String selectedLanguage = 'italiano';
  bool singleClickToOpen = false;
  bool doubleClickToRename = false;
  bool doubleClickEmptyAreaToGoUp = false;
  int executableTextFilesBehavior = 2; // 0=execute, 1=show, 2=ask
  
  // View settings
  bool showHiddenFiles = false;
  bool showPreview = true;
  bool alwaysStartWithDoublePane = false;
  bool ignoreViewPreferences = false;
  int defaultViewMode = 0; // 0=list, 1=grid, 2=details
  int defaultGridZoomLevel = 3;
  
  // File operations
  bool askBeforeMovingToTrash = false;
  bool askBeforeEmptyingTrash = true;
  bool includeDeleteCommand = true;
  bool skipTrashOnDeleteKey = false;
  bool disableFileOperationQueue = false;
  bool collapsedMenuBar = false;

  // Media
  bool autoMountRemovableDevices = true;
  bool openWindowForAutoMountedDevices = true;
  bool warnOnRemovableDeviceConnect = true;
  
  // Cache
  int cacheSize = 0;
  bool isLoadingCacheSize = true;
  
  // Font settings
  String? selectedFontFamily;
  double fontSize = 14.0;
  FontWeight fontWeight = FontWeight.normal;
  bool enableTextShadow = false;
  Color? textShadowColor;
  double textShadowBlur = 2.0;
  double textShadowOffsetX = 1.0;
  double textShadowOffsetY = 1.0;
  
  // Preview extensions settings
  Map<String, bool> previewExtensions = {
    // Immagini
    'jpg': true, 'jpeg': true, 'png': true, 'gif': true, 'bmp': true, 'webp': true,
    // Documenti
    'pdf': true,
    // Testo
    'txt': true, 'text': true, 'md': true, 'nfo': true, 'sh': true,
    // Web
    'html': true, 'htm': true,
    // Office (solo quelli supportati)
    'docx': true, 'xlsx': true, 'pptx': true,
  };
  
  // Admin password (opzionale, salvata in modo sicuro)
  String? adminPassword;
  bool saveAdminPassword = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadCacheSize();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('language') ?? 'italiano';
      singleClickToOpen = prefs.getBool('single_click_to_open') ?? false;
      doubleClickToRename = prefs.getBool('double_click_to_rename') ?? false;
      doubleClickEmptyAreaToGoUp = prefs.getBool('double_click_empty_go_up') ?? false;
      executableTextFilesBehavior = prefs.getInt('executable_text_behavior') ?? 2;
      showHiddenFiles = prefs.getBool('show_hidden_files') ?? false;
      showPreview = prefs.getBool('show_preview') ?? true;
      alwaysStartWithDoublePane = prefs.getBool('always_double_pane') ?? false;
      ignoreViewPreferences = prefs.getBool('ignore_view_prefs') ?? false;
      defaultViewMode =
          prefs.getInt('default_view_mode') ?? prefs.getInt('view_mode') ?? 0;
      defaultGridZoomLevel = prefs.getInt('default_grid_zoom_level') ??
          prefs.getInt('grid_zoom_level') ??
          3;
      askBeforeMovingToTrash = prefs.getBool('ask_before_trash') ?? false;
      askBeforeEmptyingTrash = prefs.getBool('ask_before_empty_trash') ?? true;
      includeDeleteCommand = prefs.getBool('include_delete_command') ?? true;
      skipTrashOnDeleteKey = prefs.getBool('skip_trash_on_delete') ?? false;
      disableFileOperationQueue = prefs.getBool('disable_file_queue') ?? false;
      collapsedMenuBar = prefs.getBool('collapsed_menu_bar') ?? false;
      autoMountRemovableDevices = prefs.getBool('auto_mount_removable') ?? true;
      openWindowForAutoMountedDevices = prefs.getBool('open_window_auto_mount') ?? true;
      warnOnRemovableDeviceConnect = prefs.getBool('warn_on_removable') ?? true;
      selectedFontFamily = prefs.getString('font_family');
      fontSize = prefs.getDouble('font_size') ?? 14.0;
      fontWeight = FontWeight.values[prefs.getInt('font_weight') ?? FontWeight.normal.index];
      enableTextShadow = prefs.getBool('enable_text_shadow') ?? false;
      textShadowBlur = prefs.getDouble('text_shadow_blur') ?? 2.0;
      textShadowOffsetX = prefs.getDouble('text_shadow_offset_x') ?? 1.0;
      textShadowOffsetY = prefs.getDouble('text_shadow_offset_y') ?? 1.0;
      final shadowColorValue = prefs.getInt('text_shadow_color');
      textShadowColor = shadowColorValue != null ? Color(shadowColorValue) : null;
      
      // Carica preferenze estensioni preview
      final extensionsJson = prefs.getString('preview_extensions');
      if (extensionsJson != null) {
        try {
          final Map<String, dynamic> loaded = {};
          final entries = extensionsJson.split('|');
          for (final entry in entries) {
            final parts = entry.split(':');
            if (parts.length == 2) {
              loaded[parts[0]] = parts[1] == 'true';
            }
          }
          previewExtensions = Map<String, bool>.from(loaded);
        } catch (e) {
          // Usa valori di default se il parsing fallisce
        }
      }
    });
  }

  Future<void> _loadCacheSize() async {
    setState(() => isLoadingCacheSize = true);
    final size = await ThumbnailCacheService.getCacheSize();
    setState(() {
      cacheSize = size;
      isLoadingCacheSize = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', selectedLanguage);
    await prefs.setBool('single_click_to_open', singleClickToOpen);
    await prefs.setBool('double_click_to_rename', doubleClickToRename);
    await prefs.setBool('double_click_empty_go_up', doubleClickEmptyAreaToGoUp);
    await prefs.setInt('executable_text_behavior', executableTextFilesBehavior);
    await prefs.setBool('show_hidden_files', showHiddenFiles);
    await prefs.setBool('show_preview', showPreview);
    await prefs.setBool('always_double_pane', alwaysStartWithDoublePane);
    await prefs.setBool('ignore_view_prefs', ignoreViewPreferences);
    await prefs.setInt('default_view_mode', defaultViewMode);
    await prefs.setInt('default_grid_zoom_level', defaultGridZoomLevel);
    await prefs.setInt('view_mode', defaultViewMode);
    await prefs.setInt('grid_zoom_level', defaultGridZoomLevel.clamp(1, 10));
    await prefs.setBool('ask_before_trash', askBeforeMovingToTrash);
    await prefs.setBool('ask_before_empty_trash', askBeforeEmptyingTrash);
    await prefs.setBool('include_delete_command', includeDeleteCommand);
    await prefs.setBool('skip_trash_on_delete', skipTrashOnDeleteKey);
    await prefs.setBool('disable_file_queue', disableFileOperationQueue);
    await prefs.setBool('collapsed_menu_bar', collapsedMenuBar);
    await prefs.remove('network_browse_smb_shell');
    await prefs.setBool('auto_mount_removable', autoMountRemovableDevices);
    await prefs.setBool('open_window_auto_mount', openWindowForAutoMountedDevices);
    await prefs.setBool('warn_on_removable', warnOnRemovableDeviceConnect);
    if (selectedFontFamily != null) {
      await prefs.setString('font_family', selectedFontFamily!);
    } else {
      await prefs.remove('font_family');
    }
    await prefs.setDouble('font_size', fontSize);
    await prefs.setInt('font_weight', fontWeight.index);
    await prefs.setBool('enable_text_shadow', enableTextShadow);
    await prefs.setDouble('text_shadow_blur', textShadowBlur);
    await prefs.setDouble('text_shadow_offset_x', textShadowOffsetX);
    await prefs.setDouble('text_shadow_offset_y', textShadowOffsetY);
    if (textShadowColor != null) {
      await prefs.setInt('text_shadow_color', textShadowColor!.value);
    }
    
    // Salva preferenze estensioni preview
    final extensionsList = previewExtensions.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    await prefs.setString('preview_extensions', extensionsList);
    
    // Salva password admin (se richiesto)
    await prefs.setBool('save_admin_password', saveAdminPassword);
    if (saveAdminPassword && adminPassword != null) {
      // In produzione, usa una libreria di crittografia
      await prefs.setString('admin_password', adminPassword!);
    } else {
      await prefs.remove('admin_password');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prefsPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _savePreferences();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackPrefsSaved)),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar navigation
          Container(
            width: 220,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: ListView(
              children: [
                _buildNavItem(l10n.prefsGeneral, Icons.settings, 'general'),
                _buildNavItem(l10n.prefsNavView, Icons.visibility, 'view'),
                _buildNavItem(l10n.prefsNavPreview, Icons.preview, 'preview'),
                _buildNavItem(l10n.prefsNavFileOps, Icons.folder, 'fileops'),
                _buildNavItem(l10n.prefsNavTrash, Icons.delete, 'trash'),
                _buildNavItem(l10n.prefsNavMedia, Icons.usb, 'media'),
                _buildNavItem(l10n.prefsNavCache, Icons.storage, 'cache'),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildSectionContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String id) {
    final isSelected = _selectedSection == id;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(title),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () {
        setState(() {
          _selectedSection = id;
        });
      },
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 'general':
        return _buildGeneralSection();
      case 'view':
        return _buildViewSection();
      case 'fileops':
        return _buildFileOpsSection();
      case 'trash':
        return _buildTrashSection();
      case 'media':
        return _buildMediaSection();
      case 'cache':
        return _buildCacheSection();
      case 'preview':
        return _buildPreviewSection();
      default:
        return _buildGeneralSection();
    }
  }

  Widget _buildGeneralSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsGeneral, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildSwitchTile(
            l10n.prefsSingleClickOpen,
            l10n.prefsSingleClickOpenSubtitle,
            singleClickToOpen,
            (value) {
              setState(() {
                singleClickToOpen = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsDoubleClickRename,
            l10n.prefsDoubleClickRenameSubtitle,
            doubleClickToRename,
            (value) {
              setState(() {
                doubleClickToRename = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsDoubleClickEmptyUp,
            l10n.prefsDoubleClickEmptyUpSubtitle,
            doubleClickEmptyAreaToGoUp,
            (value) {
              setState(() {
                doubleClickEmptyAreaToGoUp = value ?? false;
                _savePreferences();
              });
            },
          ),
          const Divider(),
          _buildTitle(l10n.prefsLanguage),
          DropdownButtonFormField<String>(
            value: selectedLanguage,
            decoration: InputDecoration(
              labelText: l10n.prefsLanguageLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'italiano', child: Text(l10n.langItalian)),
              DropdownMenuItem(value: 'inglese', child: Text(l10n.langEnglish)),
              DropdownMenuItem(value: 'francese', child: Text(l10n.langFrench)),
              DropdownMenuItem(value: 'portoghese', child: Text(l10n.langPortuguese)),
              DropdownMenuItem(value: 'tedesco', child: Text(l10n.langGerman)),
              DropdownMenuItem(value: 'spagnolo', child: Text(l10n.langSpanish)),
            ],
            onChanged: (value) {
              setState(() {
                selectedLanguage = value ?? 'italiano';
                _savePreferences();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            l10n.prefsMenuCompactTitle,
            l10n.prefsMenuCompactSubtitle,
            collapsedMenuBar,
            (value) {
              setState(() {
                collapsedMenuBar = value ?? false;
                _savePreferences();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTitle(l10n.prefsExecTextTitle),
          RadioListTile<int>(
            title: Text(l10n.prefsExecAuto),
            value: 0,
            groupValue: executableTextFilesBehavior,
            onChanged: (value) {
              setState(() {
                executableTextFilesBehavior = value ?? 0;
                _savePreferences();
              });
            },
          ),
          RadioListTile<int>(
            title: Text(l10n.prefsExecAlwaysShow),
            value: 1,
            groupValue: executableTextFilesBehavior,
            onChanged: (value) {
              setState(() {
                executableTextFilesBehavior = value ?? 1;
                _savePreferences();
              });
            },
          ),
          RadioListTile<int>(
            title: Text(l10n.prefsExecAlwaysAsk),
            value: 2,
            groupValue: executableTextFilesBehavior,
            onChanged: (value) {
              setState(() {
                executableTextFilesBehavior = value ?? 2;
                _savePreferences();
              });
            },
          ),
          const Divider(),
          _buildTitle(l10n.prefsDefaultFmTitle),
          const SizedBox(height: 8),
          Text(
            l10n.prefsDefaultFmBody,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _setAsDefaultFileManager(context),
            icon: const Icon(Icons.settings_applications),
            label: Text(l10n.prefsDefaultFmButton),
          ),
        ]),
      ],
    );
  }

  Future<void> _setAsDefaultFileManager(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      // Get the executable path
      final executablePath = Platform.resolvedExecutable;
      final appName = 'SAGE File Manager';
      
      // Create .desktop file in user's applications directory
      final homeDir = Platform.environment['HOME'] ?? '/home/${Platform.environment['USER']}';
      final desktopDir = '$homeDir/.local/share/applications';
      final desktopFile = File('$desktopDir/$appName.desktop');
      
      // Create directory if it doesn't exist
      await Directory(desktopDir).create(recursive: true);
      
      // Check if .desktop file already exists, if not create it
      if (!await desktopFile.exists()) {
        // Write .desktop file
        final desktopContent = '''[Desktop Entry]
Version=1.0
Type=Application
Name=File Manager
Comment=File Manager Application
Exec=$executablePath
Icon=$appName
Terminal=false
Categories=System;FileManager;
MimeType=inode/directory;
''';
        
        await desktopFile.writeAsString(desktopContent);
        
        // Make it executable
        await Process.run('chmod', ['+x', desktopFile.path]);
      }
      
      // Set as default for directories using xdg-mime
      final result = await Process.run(
        'xdg-mime',
        ['default', '$appName.desktop', 'inode/directory'],
        runInShell: true,
      );
      
      if (result.exitCode == 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.prefsDefaultFmSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Try with pkexec if xdg-mime requires root
        final pkexecResult = await Process.run(
          'pkexec',
          ['xdg-mime', 'default', '$appName.desktop', 'inode/directory'],
          runInShell: true,
        );
        
        if (pkexecResult.exitCode == 0) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.prefsDefaultFmSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception(pkexecResult.stderr);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildViewSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsNavView, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildSwitchTile(
            l10n.prefsShowHiddenTitle,
            l10n.prefsShowHiddenSubtitle,
            showHiddenFiles,
            (value) {
              setState(() {
                showHiddenFiles = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsShowPreviewPanelTitle,
            l10n.prefsShowPreviewPanelSubtitle,
            showPreview,
            (value) {
              setState(() {
                showPreview = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsAlwaysDoublePaneTitle,
            l10n.prefsAlwaysDoublePaneSubtitle,
            alwaysStartWithDoublePane,
            (value) {
              setState(() {
                alwaysStartWithDoublePane = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsIgnoreViewPerFolderTitle,
            l10n.prefsIgnoreViewPerFolderSubtitle,
            ignoreViewPreferences,
            (value) {
              setState(() {
                ignoreViewPreferences = value ?? false;
                _savePreferences();
              });
            },
          ),
          const Divider(),
          _buildTitle(l10n.prefsDefaultViewModeTitle),
          RadioListTile<int>(
            title: Text(l10n.prefsViewModeList),
            value: 0,
            groupValue: defaultViewMode,
            onChanged: (value) {
              setState(() {
                defaultViewMode = value ?? 0;
                _savePreferences();
              });
            },
          ),
          RadioListTile<int>(
            title: Text(l10n.prefsViewModeGrid),
            value: 1,
            groupValue: defaultViewMode,
            onChanged: (value) {
              setState(() {
                defaultViewMode = value ?? 1;
                _savePreferences();
              });
            },
          ),
          RadioListTile<int>(
            title: Text(l10n.prefsViewModeDetails),
            value: 2,
            groupValue: defaultViewMode,
            onChanged: (value) {
              setState(() {
                defaultViewMode = value ?? 2;
                _savePreferences();
              });
            },
          ),
          const Divider(),
          _buildTitle(l10n.prefsGridZoomTitle),
          Slider(
            value: defaultGridZoomLevel.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$defaultGridZoomLevel',
            onChanged: (value) {
              setState(() {
                defaultGridZoomLevel = value.round();
                _savePreferences();
              });
            },
          ),
          Text(
            l10n.prefsGridZoomLevel(defaultGridZoomLevel),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
        const SizedBox(height: 24),
        _buildFontSection(),
      ],
    );
  }

  Widget _buildFontSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsFontSection, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildTitle(l10n.prefsFontFamilyLabel),
          DropdownButtonFormField<String>(
            value: selectedFontFamily,
            decoration: InputDecoration(
              labelText: l10n.labelSelectFont,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.fontFamilyDefaultSystem)),
              const DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
              const DropdownMenuItem(value: 'Open Sans', child: Text('Open Sans')),
              const DropdownMenuItem(value: 'Lato', child: Text('Lato')),
              const DropdownMenuItem(value: 'Montserrat', child: Text('Montserrat')),
              const DropdownMenuItem(value: 'Raleway', child: Text('Raleway')),
              const DropdownMenuItem(value: 'Ubuntu', child: Text('Ubuntu')),
              const DropdownMenuItem(value: 'Noto Sans', child: Text('Noto Sans')),
            ],
            onChanged: (value) {
              setState(() {
                selectedFontFamily = value;
                _savePreferences();
              });
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          _buildTitle(l10n.prefsFontSizeTitle),
          Slider(
            value: fontSize,
            min: 10.0,
            max: 24.0,
            divisions: 28,
            label: fontSize.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                fontSize = value;
                _savePreferences();
              });
            },
          ),
          Text(
            l10n.prefsFontSizeValue(fontSize.toStringAsFixed(1)),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const Divider(),
          _buildTitle(l10n.prefsFontWeightTitle),
          RadioListTile<FontWeight>(
            title: Text(l10n.prefsFontWeightNormal),
            value: FontWeight.normal,
            groupValue: fontWeight,
            onChanged: (value) {
              setState(() {
                fontWeight = value ?? FontWeight.normal;
                _savePreferences();
              });
            },
          ),
          RadioListTile<FontWeight>(
            title: Text(l10n.prefsFontWeightBold),
            value: FontWeight.bold,
            groupValue: fontWeight,
            onChanged: (value) {
              setState(() {
                fontWeight = value ?? FontWeight.bold;
                _savePreferences();
              });
            },
          ),
          RadioListTile<FontWeight>(
            title: Text(l10n.prefsFontWeightSemiBold),
            value: FontWeight.w600,
            groupValue: fontWeight,
            onChanged: (value) {
              setState(() {
                fontWeight = value ?? FontWeight.w600;
                _savePreferences();
              });
            },
          ),
          RadioListTile<FontWeight>(
            title: Text(l10n.prefsFontWeightMedium),
            value: FontWeight.w500,
            groupValue: fontWeight,
            onChanged: (value) {
              setState(() {
                fontWeight = value ?? FontWeight.w500;
                _savePreferences();
              });
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          _buildTitle(l10n.prefsTextShadowSection),
          _buildSwitchTile(
            l10n.prefsTextShadowEnableTitle,
            l10n.prefsTextShadowEnableSubtitle,
            enableTextShadow,
            (value) {
              setState(() {
                enableTextShadow = value ?? false;
                _savePreferences();
              });
            },
          ),
          if (enableTextShadow) ...[
            const SizedBox(height: 16),
            _buildTitle(l10n.prefsShadowIntensityTitle),
            Slider(
              value: textShadowBlur,
              min: 0.0,
              max: 10.0,
              divisions: 20,
              label: textShadowBlur.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  textShadowBlur = value;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTitle(l10n.prefsShadowOffsetXTitle),
            Slider(
              value: textShadowOffsetX,
              min: -5.0,
              max: 5.0,
              divisions: 20,
              label: textShadowOffsetX.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  textShadowOffsetX = value;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTitle(l10n.prefsShadowOffsetYTitle),
            Slider(
              value: textShadowOffsetY,
              min: -5.0,
              max: 5.0,
              divisions: 20,
              label: textShadowOffsetY.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  textShadowOffsetY = value;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTitle(l10n.prefsShadowColorTitle),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.prefsShadowColorValue(
                      textShadowColor != null
                          ? '#${textShadowColor!.value.toRadixString(16).substring(2)}'
                          : l10n.prefsShadowColorBlack,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Color? selectedColor = textShadowColor ?? Colors.black;
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (dialogContext) => DialogEnterScope(
                        onEnterPressed: () => Navigator.pop(
                          dialogContext,
                          selectedColor,
                        ),
                        child: AlertDialog(
                          title: Text(l10n.dialogPickShadowColor),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (c) {
                                selectedColor = c;
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(l10n.dialogCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(
                                dialogContext,
                                selectedColor,
                              ),
                              child: Text(l10n.commonOk),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (color != null) {
                      setState(() {
                        textShadowColor = color;
                        _savePreferences();
                      });
                    }
                  },
                  child: Text(l10n.prefsPickColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.prefsTextPreviewLabel,
                style: TextStyle(
                  fontFamily: selectedFontFamily,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  shadows: enableTextShadow
                      ? [
                          Shadow(
                            color: textShadowColor ?? Colors.black.withOpacity(0.3),
                            blurRadius: textShadowBlur,
                            offset: Offset(textShadowOffsetX, textShadowOffsetY),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _buildFileOpsSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsNavFileOps, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildSwitchTile(
            l10n.prefsDisableFileQueueTitle,
            l10n.prefsDisableFileQueueSubtitle,
            disableFileOperationQueue,
            (value) {
              setState(() {
                disableFileOperationQueue = value ?? false;
                _savePreferences();
              });
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildTrashSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsNavTrash, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildSwitchTile(
            l10n.prefsAskTrashTitle,
            l10n.prefsAskTrashSubtitle,
            askBeforeMovingToTrash,
            (value) {
              setState(() {
                askBeforeMovingToTrash = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsAskEmptyTrashTitle,
            l10n.prefsAskEmptyTrashSubtitle,
            askBeforeEmptyingTrash,
            (value) {
              setState(() {
                askBeforeEmptyingTrash = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsIncludeDeleteTitle,
            l10n.prefsIncludeDeleteSubtitle,
            includeDeleteCommand,
            (value) {
              setState(() {
                includeDeleteCommand = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsSkipTrashDelKeyTitle,
            l10n.prefsSkipTrashDelKeySubtitle,
            skipTrashOnDeleteKey,
            (value) {
              setState(() {
                skipTrashOnDeleteKey = value ?? false;
                _savePreferences();
              });
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildMediaSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsNavMedia, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          _buildSwitchTile(
            l10n.prefsAutoMountTitle,
            l10n.prefsAutoMountSubtitle,
            autoMountRemovableDevices,
            (value) {
              setState(() {
                autoMountRemovableDevices = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsOpenWindowMountedTitle,
            l10n.prefsOpenWindowMountedSubtitle,
            openWindowForAutoMountedDevices,
            (value) {
              setState(() {
                openWindowForAutoMountedDevices = value ?? false;
                _savePreferences();
              });
            },
          ),
          _buildSwitchTile(
            l10n.prefsWarnRemovableTitle,
            l10n.prefsWarnRemovableSubtitle,
            warnOnRemovableDeviceConnect,
            (value) {
              setState(() {
                warnOnRemovableDeviceConnect = value ?? false;
                _savePreferences();
              });
            },
          ),
        ]),
      ],
    );
  }

  String _previewCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat) {
      case 'images':
        return l10n.previewCatImages;
      case 'documents':
        return l10n.previewCatDocuments;
      case 'text':
        return l10n.previewCatText;
      case 'web':
        return l10n.previewCatWeb;
      case 'office':
        return l10n.previewCatOffice;
      default:
        return cat;
    }
  }

  Widget _buildPreviewSection() {
    final l10n = AppLocalizations.of(context);
    final rows = <(String ext, String name, String cat)>[
      ('jpg', l10n.previewFmtJpeg, 'images'),
      ('jpeg', l10n.previewFmtJpeg, 'images'),
      ('png', l10n.previewFmtPng, 'images'),
      ('gif', l10n.previewFmtGif, 'images'),
      ('bmp', l10n.previewFmtBmp, 'images'),
      ('webp', l10n.previewFmtWebp, 'images'),
      ('pdf', l10n.previewFmtPdf, 'documents'),
      ('txt', l10n.previewFmtPlainText, 'text'),
      ('text', l10n.previewFmtPlainText, 'text'),
      ('md', l10n.previewFmtMarkdown, 'text'),
      ('nfo', l10n.previewFmtNfo, 'text'),
      ('sh', l10n.previewFmtShell, 'text'),
      ('html', l10n.previewFmtHtml, 'web'),
      ('htm', l10n.previewFmtHtml, 'web'),
      ('docx', l10n.previewFmtDocx, 'office'),
      ('xlsx', l10n.previewFmtXlsx, 'office'),
      ('pptx', l10n.previewFmtPptx, 'office'),
    ];
    final grouped = <String, List<(String, String)>>{};
    for (final r in rows) {
      grouped.putIfAbsent(r.$3, () => []).add((r.$1, r.$2));
    }
    const categoryOrder = ['images', 'documents', 'text', 'web', 'office'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsNavPreview, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          Text(
            l10n.prefsPreviewExtensionsIntro,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.prefsPreviewRightPanelNote,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryOrder.where((c) => grouped.containsKey(c)).map((catKey) {
            final entries = grouped[catKey]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _previewCategoryLabel(catKey, l10n),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...entries.map((pair) {
                  final extKey = pair.$1;
                  final extName = pair.$2;
                  return CheckboxListTile(
                    title: Text('.$extKey - $extName'),
                    value: previewExtensions[extKey] ?? false,
                    onChanged: (value) {
                      setState(() {
                        previewExtensions[extKey] = value ?? false;
                        _savePreferences();
                      });
                    },
                    dense: true,
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          }),
          const Divider(),
          _buildTitle(l10n.prefsAdminPasswordSection),
          _buildSwitchTile(
            l10n.prefsSaveAdminPasswordTitle,
            l10n.prefsSaveAdminPasswordSubtitle,
            saveAdminPassword,
            (value) {
              setState(() {
                saveAdminPassword = value ?? false;
                if (!saveAdminPassword) {
                  adminPassword = null;
                }
                _savePreferences();
              });
            },
          ),
          if (saveAdminPassword)
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.labelAdminPassword,
                hintText: l10n.hintAdminPassword,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                adminPassword = value;
                _savePreferences();
              },
            ),
        ]),
      ],
    );
  }

  Widget _buildCacheSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prefsCacheSectionTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _buildSectionCard([
          if (isLoadingCacheSize)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(l10n.prefsCacheSizeTitle),
                Text(
                  l10n.prefsCacheSizeCurrent(_formatBytes(cacheSize)),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: Text(l10n.prefsClearCacheButton),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => DialogEnterScope(
                        onEnterPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: AlertDialog(
                          title: Text(l10n.prefsClearCacheTitle),
                          content: Text(l10n.prefsClearCacheBody),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(l10n.dialogCancel),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(l10n.prefsClearCacheConfirm),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (confirmed == true) {
                      await ThumbnailCacheService.clearCache();
                      _loadCacheSize();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.snackPrefsCacheCleared)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
        ]),
      ],
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool?) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
