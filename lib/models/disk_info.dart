import 'package:filemanager/utils/format_bytes.dart';

class DiskInfo {
  final String path;
  final String name;
  final int total;
  final int free;
  final int used;

  DiskInfo({
    required this.path,
    required this.name,
    required this.total,
    required this.free,
    required this.used,
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      path: json['path'] as String,
      name: json['name'] as String,
      total: json['total'] as int,
      free: json['free'] as int,
      used: json['used'] as int,
    );
  }

  double get freePercentage => total > 0 ? (free / total) * 100 : 0;
  double get usedPercentage => total > 0 ? (used / total) * 100 : 0;

  String formatBytes(int bytes) => formatBytesBinary(bytes);
}
