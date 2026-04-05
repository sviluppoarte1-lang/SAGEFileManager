import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FolderThemeService {
  // Direct list of available folder icon themes with working download URLs
  // Using GitHub API to get actual file URLs
  static Future<List<Map<String, dynamic>>> _fetchThemesFromGitHub() async {
    try {
      // Try different API endpoints
      final urls = [
        'https://api.github.com/repos/papirus-team/papirus-icon-theme/contents/Papirus/48x48/places?ref=main',
        'https://api.github.com/repos/papirus-team/papirus-icon-theme/contents/Papirus/48x48/places',
      ];
      
      for (final apiUrl in urls) {
        try {
          final response = await http.get(
            Uri.parse(apiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
            },
          ).timeout(const Duration(seconds: 15));
          
          if (response.statusCode == 200) {
            final List<dynamic> files = json.decode(response.body);
            final themes = files
                .where((file) => 
                    (file['type'] == null || file['type'] == 'file') &&
                    (file['name'].toString().endsWith('.svg') || 
                     file['name'].toString().endsWith('.png')) &&
                    file['name'].toString().startsWith('folder'))
                .map((file) {
                  final fileName = file['name'].toString();
                  String themeName = fileName
                      .replaceAll('.svg', '')
                      .replaceAll('.png', '')
                      .replaceAll('folder-', '')
                      .replaceAll('folder', 'Folder')
                      .replaceAll('-', ' ')
                      .split(' ')
                      .map((word) => word.isEmpty 
                          ? '' 
                          : word[0].toUpperCase() + word.substring(1))
                      .join(' ');
                  
                  if (themeName.isEmpty) themeName = 'Folder';
                  
                  final downloadUrl = file['download_url'] ?? 
                    'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/$fileName';
                  
                  return {
                    'name': themeName,
                    'originalName': fileName,
                    'downloadUrl': downloadUrl,
                    'previewUrl': downloadUrl,
                    'source': 'Papirus',
                    'isLocal': false,
                  };
                })
                .toList();
            
            if (themes.isNotEmpty) {
              return themes;
            }
          }
        } catch (e) {
          continue; // Try next URL
        }
      }
    } catch (e) {
      print('Error fetching themes from GitHub: $e');
    }
    return [];
  }
  
  // Fallback static list with verified URLs (using main branch)
  static final List<Map<String, dynamic>> fallbackThemes = [
    {
      'name': 'Folder',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Documents',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-documents.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-documents.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Download',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-download.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-download.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Music',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-music.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-music.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Pictures',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-pictures.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-pictures.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Videos',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-video.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-video.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Public',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-publicshare.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-publicshare.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Home',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-home.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-home.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Desktop',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-desktop.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-desktop.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
    {
      'name': 'Folder Open',
      'downloadUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-open.svg',
      'previewUrl': 'https://raw.githubusercontent.com/papirus-team/papirus-icon-theme/main/Papirus/48x48/places/folder-open.svg',
      'source': 'Papirus',
      'isLocal': false,
    },
  ];
  
  static Future<String> getThemesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final themesDir = Directory(path.join(appDir.path, 'folder_themes'));
    if (!await themesDir.exists()) {
      await themesDir.create(recursive: true);
    }
    return themesDir.path;
  }

  static Future<List<Map<String, dynamic>>> getAvailableThemes() async {
    List<Map<String, dynamic>> allThemes = [];
    
    // Try to fetch from GitHub API first
    final githubThemes = await _fetchThemesFromGitHub();
    if (githubThemes.isNotEmpty) {
      allThemes.addAll(githubThemes);
    } else {
      // Fallback to static list
      allThemes.addAll(fallbackThemes);
    }
    
    // Add local themes
    final localThemes = await _getLocalThemes();
    allThemes.addAll(localThemes);
    
    // Remove duplicates
    final seen = <String>{};
    allThemes = allThemes.where((theme) {
      final name = theme['name'].toString().toLowerCase();
      if (seen.contains(name)) return false;
      seen.add(name);
      return true;
    }).toList();
    
    return allThemes;
  }

  static Future<List<Map<String, dynamic>>> _getLocalThemes() async {
    final List<Map<String, dynamic>> themes = [];
    
    // Check assets folder first
    try {
      final assetThemes = [
        'folder.svg',
        'folder-documents.svg',
        'folder-download.svg',
        'folder-music.svg',
        'folder-pictures.svg',
        'folder-video.svg',
        'folder-publicshare.svg',
        'folder-home.svg',
        'folder-desktop.svg',
        'folder-open.svg',
      ];
      
      for (final themeFile in assetThemes) {
        final themeName = themeFile
            .replaceAll('.svg', '')
            .replaceAll('.png', '')
            .replaceAll('folder-', '')
            .replaceAll('folder', 'Folder')
            .replaceAll('-', ' ')
            .split(' ')
            .map((word) => word.isEmpty 
                ? '' 
                : word[0].toUpperCase() + word.substring(1))
            .join(' ');
        
        themes.add({
          'name': themeName.isEmpty ? 'Folder' : themeName,
          'downloadUrl': 'assets/icons/folder_themes/$themeFile',
          'previewUrl': 'assets/icons/folder_themes/$themeFile',
          'isLocal': true,
          'source': 'Assets',
          'assetPath': 'assets/icons/folder_themes/$themeFile',
        });
      }
    } catch (e) {
      // Ignore
    }
    
    // Also check downloaded themes directory
    try {
      final themesDir = await getThemesDirectory();
      final dir = Directory(themesDir);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && 
              (entity.path.endsWith('.svg') || entity.path.endsWith('.png'))) {
            final fileName = path.basename(entity.path);
            final themeName = fileName
                .replaceAll('.svg', '')
                .replaceAll('.png', '')
                .replaceAll('folder-', '')
                .replaceAll('folder', 'Folder')
                .replaceAll('-', ' ')
                .split(' ')
                .map((word) => word.isEmpty 
                    ? '' 
                    : word[0].toUpperCase() + word.substring(1))
                .join(' ');
            
            themes.add({
              'name': themeName.isEmpty ? 'Folder' : themeName,
              'downloadUrl': entity.path,
              'previewUrl': entity.path,
              'isLocal': true,
              'source': 'Downloaded',
            });
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    
    return themes;
  }

  static Future<bool> downloadTheme(String themeName, String downloadUrl) async {
    try {
      final themesDir = await getThemesDirectory();
      
      // Try multiple download strategies
      final headers = {
        'Accept': 'application/octet-stream, */*',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };
      
      http.Response? response;
      
      // Try direct download
      try {
        response = await http.get(
          Uri.parse(downloadUrl),
          headers: headers,
        ).timeout(const Duration(seconds: 30));
      } catch (e) {
        // If direct download fails, try with different URL format
        final altUrl = downloadUrl.replaceAll('/master/', '/main/');
        try {
          response = await http.get(
            Uri.parse(altUrl),
            headers: headers,
          ).timeout(const Duration(seconds: 30));
        } catch (e2) {
          print('Error downloading theme from both URLs: $e, $e2');
          return false;
        }
      }
      
      if (response.statusCode == 200) {
        // Determine file extension from URL or content type
        String extension = '.svg';
        if (downloadUrl.endsWith('.png') ||
            response.headers['content-type']?.contains('png') == true) {
          extension = '.png';
        } else if (downloadUrl.endsWith('.svg') ||
            response.headers['content-type']?.contains('svg') == true) {
          extension = '.svg';
        }
        
        // Use original name if available, otherwise create safe filename
        String fileName;
        if (themeName.endsWith('.svg') || themeName.endsWith('.png')) {
          fileName = themeName;
        } else {
          final safeName = themeName
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .replaceAll(' ', '_')
              .toLowerCase();
          fileName = '$safeName$extension';
        }
        
        final file = File(path.join(themesDir, fileName));
        await file.writeAsBytes(response.bodyBytes);
        
        // Verify file was written
        if (await file.exists() && await file.length() > 0) {
          return true;
        }
      } else {
        print('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading theme: $e');
      return false;
    }
    return false;
  }

  static Future<String?> getThemePath(String themeName) async {
    final themesDir = await getThemesDirectory();
    // Try to find by exact name
    final pngPath = path.join(themesDir, '$themeName.png');
    final svgPath = path.join(themesDir, '$themeName.svg');
    
    if (await File(pngPath).exists()) return pngPath;
    if (await File(svgPath).exists()) return svgPath;
    
    // Try to find by sanitized name
    final safeName = themeName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    final safePngPath = path.join(themesDir, '$safeName.png');
    final safeSvgPath = path.join(themesDir, '$safeName.svg');
    
    if (await File(safePngPath).exists()) return safePngPath;
    if (await File(safeSvgPath).exists()) return safeSvgPath;
    
    return null;
  }

  static Future<bool> deleteTheme(String themeName) async {
    try {
      final themesDir = await getThemesDirectory();
      final pngPath = path.join(themesDir, '$themeName.png');
      final svgPath = path.join(themesDir, '$themeName.svg');
      
      bool deleted = false;
      if (await File(pngPath).exists()) {
        await File(pngPath).delete();
        deleted = true;
      }
      if (await File(svgPath).exists()) {
        await File(svgPath).delete();
        deleted = true;
      }
      return deleted;
    } catch (e) {
      return false;
    }
  }
}
