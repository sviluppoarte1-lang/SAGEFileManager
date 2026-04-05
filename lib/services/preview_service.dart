import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';
import 'package:filemanager/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewService {
  static Map<String, bool>? _previewExtensions;
  // Cache for previewable check results to reduce CPU usage
  static final Map<String, bool> _previewableCache = {};
  
  static Future<void> loadPreviewExtensions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extensionsJson = prefs.getString('preview_extensions');
      if (extensionsJson != null) {
        final Map<String, bool> loaded = {};
        final entries = extensionsJson.split('|');
        for (final entry in entries) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            loaded[parts[0]] = parts[1] == 'true';
          }
        }
        _previewExtensions = loaded;
      } else {
        // Valori di default
        _previewExtensions = {
          'jpg': true, 'jpeg': true, 'png': true, 'gif': true, 'bmp': true, 'webp': true,
          'pdf': true,
          'txt': true, 'text': true, 'md': true, 'nfo': true, 'sh': true,
          'html': true, 'htm': true,
          'docx': true, 'xlsx': true, 'pptx': true,
        };
      }
    } catch (e) {
      // Usa valori di default in caso di errore
      _previewExtensions = {
        'jpg': true, 'jpeg': true, 'png': true, 'gif': true, 'bmp': true, 'webp': true,
        'pdf': true,
        'txt': true, 'text': true, 'md': true, 'nfo': true, 'sh': true,
        'html': true, 'htm': true,
        'docx': true, 'xlsx': true, 'pptx': true,
      };
    }
  }
  
  static Future<bool> isPreviewable(String filePath) async {
    // Check cache first to reduce CPU usage
    if (_previewableCache.containsKey(filePath)) {
      return _previewableCache[filePath]!;
    }
    
    if (_previewExtensions == null) {
      await loadPreviewExtensions();
    }
    final ext = filePath.toLowerCase().split('.').last;
    final isPreviewable = _previewExtensions?[ext] ?? false;
    
    // Cache the result
    _previewableCache[filePath] = isPreviewable;
    
    return isPreviewable;
  }
  
  // Clear previewable cache when needed
  static void clearPreviewableCache() {
    _previewableCache.clear();
  }

  static Widget getPreview(BuildContext context, String filePath) {
    final ext = filePath.toLowerCase().split('.').last;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return ImagePreview(filePath: filePath);
      case 'pdf':
        return PdfPreview(filePath: filePath);
      case 'txt':
      case 'text':
      case 'md':
      case 'nfo':
      case 'sh':
        return TextPreview(filePath: filePath);
      case 'html':
      case 'htm':
        return HtmlPreview(filePath: filePath);
      case 'doc':
      case 'docx':
        return DocumentPreview(filePath: filePath);
      case 'xls':
      case 'xlsx':
        return SpreadsheetPreview(filePath: filePath);
      case 'pptx':
        return PresentationPreview(filePath: filePath);
      case 'odt':
      case 'ods':
      case 'odp':
        return OpenOfficePreview(filePath: filePath);
      default:
        return Center(child: Text(AppLocalizations.of(context).previewNotAvailable));
    }
  }
}

class ImagePreview extends StatelessWidget {
  final String filePath;

  const ImagePreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(filePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(child: Text(AppLocalizations.of(context).previewImageError));
      },
    );
  }
}

class PdfPreview extends StatelessWidget {
  final String filePath;

  const PdfPreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return PdfViewer.file(
      filePath,
      params: const PdfViewerParams(),
    );
  }
}

class TextPreview extends StatelessWidget {
  final String filePath;

  const TextPreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: File(filePath).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).commonError(snapshot.error.toString())),
              ],
            ),
          );
        }
        
        final content = snapshot.data ?? '';
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

class HtmlPreview extends StatelessWidget {
  final String filePath;

  const HtmlPreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: File(filePath).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).commonError(snapshot.error.toString())),
              ],
            ),
          );
        }
        
        final content = snapshot.data ?? '';
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

class DocumentPreview extends StatefulWidget {
  final String filePath;

  const DocumentPreview({super.key, required this.filePath});

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  Uint8List? _fileBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.filePath);
      final bytes = await file.readAsBytes();
      if (mounted) {
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null || _fileBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64),
            const SizedBox(height: 16),
            Text(l10n.previewDocLoadError),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.commonError(_error!),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.previewOpenExternally),
              onPressed: () {
                Process.run('xdg-open', [widget.filePath]);
              },
            ),
          ],
        ),
      );
    }
    
    // Use microsoft_viewer for DOCX files
    if (widget.filePath.toLowerCase().endsWith('.docx')) {
      return MicrosoftViewer(_fileBytes!, false);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, size: 64),
          const SizedBox(height: 16),
          Text(l10n.previewDocumentTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.previewDocLegacyFormat, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class SpreadsheetPreview extends StatefulWidget {
  final String filePath;

  const SpreadsheetPreview({super.key, required this.filePath});

  @override
  State<SpreadsheetPreview> createState() => _SpreadsheetPreviewState();
}

class _SpreadsheetPreviewState extends State<SpreadsheetPreview> {
  Uint8List? _fileBytes;
  bool _isLoading = true;
  String? _error;
  String? _lastFilePath;

  @override
  void initState() {
    super.initState();
    _lastFilePath = widget.filePath;
    _loadFile();
  }

  @override
  void didUpdateWidget(SpreadsheetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _lastFilePath = widget.filePath;
      _fileBytes = null;
      _isLoading = true;
      _error = null;
      _loadFile();
    }
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.filePath);
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // Files larger than 10MB
        final bytes = await file.readAsBytes();
        if (mounted && _lastFilePath == widget.filePath) {
          setState(() {
            _fileBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        final bytes = await file.readAsBytes();
        if (mounted && _lastFilePath == widget.filePath) {
          setState(() {
            _fileBytes = bytes;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && _lastFilePath == widget.filePath) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null || _fileBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_chart, size: 64),
            const SizedBox(height: 16),
            Text(l10n.previewSheetLoadError),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.commonError(_error!),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.previewOpenExternally),
              onPressed: () {
                Process.run('xdg-open', [widget.filePath]);
              },
            ),
          ],
        ),
      );
    }
    
    if (widget.filePath.toLowerCase().endsWith('.xlsx')) {
      return MicrosoftViewer(_fileBytes!, false);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.table_chart, size: 64),
          const SizedBox(height: 16),
          Text(l10n.previewSheetTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.previewXlsLegacyFormat, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class PresentationPreview extends StatefulWidget {
  final String filePath;

  const PresentationPreview({super.key, required this.filePath});

  @override
  State<PresentationPreview> createState() => _PresentationPreviewState();
}

class _PresentationPreviewState extends State<PresentationPreview> {
  Uint8List? _fileBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.filePath);
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // Files larger than 10MB
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _fileBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _fileBytes = bytes;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null || _fileBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.slideshow, size: 64),
            const SizedBox(height: 16),
            Text(l10n.previewPresentationLoadError),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.commonError(_error!),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.previewOpenExternally),
              onPressed: () {
                Process.run('xdg-open', [widget.filePath]);
              },
            ),
          ],
        ),
      );
    }
    
    return MicrosoftViewer(_fileBytes!, false);
  }
}

class OpenOfficePreview extends StatelessWidget {
  final String filePath;

  const OpenOfficePreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description, size: 64),
          const SizedBox(height: 16),
          Text(l10n.previewOpenOfficeTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.previewOpenOfficeBody, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.previewOpenExternally),
            onPressed: () {
              Process.run('xdg-open', [filePath]);
            },
          ),
        ],
      ),
    );
  }
}
