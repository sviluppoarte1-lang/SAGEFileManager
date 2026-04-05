import 'package:flutter/material.dart';

class FileIconService {
  // Map file extensions to icon asset paths
  static const Map<String, String> _iconMap = {
    // Documents
    'pdf': 'assets/icons/file_types/pdf.png',
    'doc': 'assets/icons/file_types/doc.png',
    'docx': 'assets/icons/file_types/docx.png',
    'odt': 'assets/icons/file_types/odt.png',
    'rtf': 'assets/icons/file_types/rtf.png',
    'txt': 'assets/icons/file_types/txt.png',
    
    // Spreadsheets
    'xls': 'assets/icons/file_types/xls.png',
    'xlsx': 'assets/icons/file_types/xlsx.png',
    'ods': 'assets/icons/file_types/ods.png',
    'csv': 'assets/icons/file_types/csv.png',
    
    // Presentations
    'ppt': 'assets/icons/file_types/ppt.png',
    'pptx': 'assets/icons/file_types/pptx.png',
    'odp': 'assets/icons/file_types/odp.png',
    
    // Images
    'jpg': 'assets/icons/file_types/jpg.png',
    'jpeg': 'assets/icons/file_types/jpg.png',
    'png': 'assets/icons/file_types/png.png',
    'gif': 'assets/icons/file_types/gif.png',
    'bmp': 'assets/icons/file_types/bmp.png',
    'webp': 'assets/icons/file_types/webp.png',
    'svg': 'assets/icons/file_types/svg.png',
    'ico': 'assets/icons/file_types/ico.png',
    
    // Packages
    'deb': 'assets/icons/file_types/deb.png',

    // Archives
    'zip': 'assets/icons/file_types/zip.png',
    'rar': 'assets/icons/file_types/rar.png',
    '7z': 'assets/icons/file_types/7z.png',
    'tar': 'assets/icons/file_types/tar.png',
    'gz': 'assets/icons/file_types/gz.png',
    
    // Audio
    'mp3': 'assets/icons/file_types/mp3.png',
    'wav': 'assets/icons/file_types/wav.png',
    'flac': 'assets/icons/file_types/flac.png',
    'ogg': 'assets/icons/file_types/ogg.png',
    'm4a': 'assets/icons/file_types/m4a.png',
    
    // Video
    'mp4': 'assets/icons/file_types/mp4.png',
    'avi': 'assets/icons/file_types/avi.png',
    'mkv': 'assets/icons/file_types/mkv.png',
    'mov': 'assets/icons/file_types/mov.png',
    'wmv': 'assets/icons/file_types/wmv.png',
    'flv': 'assets/icons/file_types/flv.png',
    
    // Code
    'js': 'assets/icons/file_types/js.png',
    'ts': 'assets/icons/file_types/ts.png',
    'html': 'assets/icons/file_types/html.png',
    'css': 'assets/icons/file_types/css.png',
    'py': 'assets/icons/file_types/py.png',
    'java': 'assets/icons/file_types/java.png',
    'cpp': 'assets/icons/file_types/cpp.png',
    'c': 'assets/icons/file_types/c.png',
    'dart': 'assets/icons/file_types/dart.png',
    
    // Databases
    'db': 'assets/icons/file_types/db.png',
    'sqlite': 'assets/icons/file_types/sqlite.png',
    'sql': 'assets/icons/file_types/sql.png',
  };

  // Fallback Material Icons with reduced contrast
  static const Map<String, IconData> _fallbackIcons = {
    'pdf': Icons.picture_as_pdf,
    'doc': Icons.description,
    'docx': Icons.description,
    'odt': Icons.description,
    'rtf': Icons.description,
    'txt': Icons.text_snippet,
    'xls': Icons.table_chart,
    'xlsx': Icons.table_chart,
    'ods': Icons.table_chart,
    'csv': Icons.table_chart,
    'ppt': Icons.slideshow,
    'pptx': Icons.slideshow,
    'odp': Icons.slideshow,
    'jpg': Icons.image,
    'jpeg': Icons.image,
    'png': Icons.image,
    'gif': Icons.image,
    'bmp': Icons.image,
    'webp': Icons.image,
    'svg': Icons.image,
    'ico': Icons.image,
    'deb': Icons.inventory_2_outlined,
    'zip': Icons.archive,
    'rar': Icons.archive,
    '7z': Icons.archive,
    'tar': Icons.archive,
    'gz': Icons.archive,
    'mp3': Icons.audiotrack,
    'wav': Icons.audiotrack,
    'flac': Icons.audiotrack,
    'ogg': Icons.audiotrack,
    'm4a': Icons.audiotrack,
    'mp4': Icons.video_file,
    'avi': Icons.video_file,
    'mkv': Icons.video_file,
    'mov': Icons.video_file,
    'wmv': Icons.video_file,
    'flv': Icons.video_file,
    'js': Icons.code,
    'ts': Icons.code,
    'html': Icons.code,
    'css': Icons.code,
    'py': Icons.code,
    'java': Icons.code,
    'cpp': Icons.code,
    'c': Icons.code,
    'dart': Icons.code,
    'db': Icons.storage,
    'sqlite': Icons.storage,
    'sql': Icons.storage,
  };

  static String? getIconPath(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return _iconMap[ext];
  }

  static IconData? getFallbackIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return _fallbackIcons[ext];
  }

  static Widget buildFileIcon(String fileName, BuildContext context, {double size = 64}) {
    final iconPath = getIconPath(fileName);
    
    if (iconPath != null) {
      // PNG spesso ha arte centrata rispetto al bordo: ancoriamo a sinistra per
      // allineare con le icone cartella (Material); offset leggero solo su asset.
      return Transform.translate(
        offset: Offset(-(size * 0.06).clamp(1.0, 3.0), 0),
        child: Image.asset(
          iconPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to Material Icon with reduced contrast
            final fallbackIcon =
                getFallbackIcon(fileName) ?? Icons.insert_drive_file;
            return Icon(
              fallbackIcon,
              size: size,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            );
          },
        ),
      );
    }
    
    // Use Material Icon with reduced contrast
    final fallbackIcon = getFallbackIcon(fileName) ?? Icons.insert_drive_file;
    return Icon(
      fallbackIcon,
      size: size,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );
  }
}
