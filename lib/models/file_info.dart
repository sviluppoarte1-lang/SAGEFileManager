class FileInfo {
  final String path;
  final String name;
  final int size;
  final bool isDir;
  final int modified;
  final int created;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.isDir,
    required this.modified,
    required this.created,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      path: json['path'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      isDir: json['is_dir'] as bool,
      modified: json['modified'] as int,
      created: json['created'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'is_dir': isDir,
      'modified': modified,
      'created': created,
    };
  }
}
