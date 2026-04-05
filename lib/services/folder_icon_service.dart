import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class FolderIconService {
  static const String _selectedIconKey = 'selected_folder_icon';
  static const String _selectedColorKey = 'selected_folder_color';
  static const String _selectedColorCustomKey = 'selected_folder_color_custom';
  static const String _defaultIcon = 'folder';

  // Available Flutter Material icons for folders
  static const Map<String, IconData> availableIcons = {
    'folder': Icons.folder,
    'folder_open': Icons.folder_open,
    'folder_special': Icons.folder_special,
    'folder_shared': Icons.folder_shared,
    'folder_copy': Icons.folder_copy,
    'folder_delete': Icons.folder_delete,
    'folder_zip': Icons.folder_zip,
    'folder_off': Icons.folder_off,
    'folder_plus': Icons.create_new_folder,
    'folder_home': Icons.home,
    'folder_drive': Icons.storage,
    'folder_cloud': Icons.cloud,
  };

  static Future<String> getSelectedIcon() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedIconKey) ?? _defaultIcon;
  }

  static Future<void> setSelectedIcon(String iconName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedIconKey, iconName);
  }

  static Future<int?> getSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedColorKey);
  }

  static Future<void> setSelectedColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedColorKey, colorValue);
  }

  static Future<bool> getSelectedColorIsCustom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_selectedColorCustomKey) ?? false;
  }

  static Future<void> setSelectedColorIsCustom(bool isCustom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_selectedColorCustomKey, isCustom);
  }

  // Get color for a specific folder path
  static Future<int?> getFolderColor(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('folder_color_$folderPath');
  }

  // Set color for a specific folder path
  static Future<void> setFolderColor(String folderPath, int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('folder_color_$folderPath', colorValue);
  }

  // Remove color for a specific folder path
  static Future<void> removeFolderColor(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('folder_color_$folderPath');
  }

  /// Removes all per-folder color overrides (`folder_color_<path>`).
  /// Used when applying a theme so every folder follows theme colors.
  static Future<void> clearAllFolderColors() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final toRemove = <String>[];
    for (final k in keys) {
      if (k.startsWith('folder_color_')) {
        toRemove.add(k);
      }
    }
    for (final k in toRemove) {
      await prefs.remove(k);
    }
  }


  static Widget buildFolderIconSync(String? iconName, BuildContext context, {double size = 64, Color? color}) {
    final effectiveIconName = iconName ?? _defaultIcon;
    final iconData = availableIcons[effectiveIconName] ?? Icons.folder;
    
    Color effectiveColor = color ?? Theme.of(context).colorScheme.primary.withOpacity(0.7);

    return Icon(iconData, size: size, color: effectiveColor);
  }

  // Determine icon automatically based on folder properties
  static String getFolderIconForPath(String folderPath, String folderName, String? currentPath) {
    final pathLower = folderPath.toLowerCase();
    final nameLower = folderName.toLowerCase();
    
    // Check if folder is currently open
    if (currentPath != null && currentPath == folderPath) {
      return 'folder_open';
    }
    
    // Home directory
    if (pathLower.contains('/home/') && !pathLower.contains('/home/') || 
        nameLower == 'home' || pathLower.endsWith('/home')) {
      return 'folder_home';
    }
    
    // Special system folders
    if (nameLower == 'desktop' || pathLower.contains('/desktop')) {
      return 'folder_special';
    }
    if (nameLower == 'documenti' || nameLower == 'documents' || pathLower.contains('/documents')) {
      return 'folder_special';
    }
    if (nameLower == 'immagini' || nameLower == 'pictures' || pathLower.contains('/pictures')) {
      return 'folder_special';
    }
    if (nameLower == 'musica' || nameLower == 'music' || pathLower.contains('/music')) {
      return 'folder_special';
    }
    if (nameLower == 'video' || nameLower == 'videos' || pathLower.contains('/videos')) {
      return 'folder_special';
    }
    if (nameLower == 'scaricati' || nameLower == 'downloads' || pathLower.contains('/downloads')) {
      return 'folder_special';
    }
    
    // Trash/Delete
    if (nameLower == 'cestino' || nameLower == 'trash' || pathLower.contains('/trash') || 
        pathLower.contains('/.trash')) {
      return 'folder_delete';
    }
    
    // Cloud folders
    if (pathLower.contains('/cloud') || pathLower.contains('/dropbox') || 
        pathLower.contains('/onedrive') || pathLower.contains('/google drive')) {
      return 'folder_cloud';
    }
    
    // Mounted drives
    if (pathLower.startsWith('/media/') || pathLower.startsWith('/mnt/') || 
        pathLower.startsWith('/run/media/')) {
      // Prefer standard folder icon for mounts (USB, network mounts, etc.).
      // The sidebar already shows disks explicitly; in the file view these should
      // look like normal folders.
      return 'folder';
    }
    
    // Archive folders (if name suggests it)
    if (nameLower.contains('archive') || nameLower.contains('backup') || 
        nameLower.contains('zip') || nameLower.contains('rar')) {
      return 'folder_zip';
    }
    
    // Shared folders (check permissions or name)
    if (nameLower.contains('shared') || nameLower.contains('condiviso') || 
        pathLower.contains('/shared') || pathLower.contains('/public')) {
      return 'folder_shared';
    }
    
    // Default
    return 'folder';
  }
}
