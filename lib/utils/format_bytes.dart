/// Human-readable sizes (1024-based) for status bars and copy progress.
/// Uses [double] division so very large totals stay numerically stable in UI.
String formatBytesBinary(int bytes) {
  final safe = bytes < 0 ? 0 : bytes;
  final b = safe.toDouble();
  if (safe < 1024) return '$safe B';
  if (safe < 1024 * 1024) return '${(b / 1024).toStringAsFixed(2)} KB';
  if (safe < 1024 * 1024 * 1024) {
    return '${(b / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  const gib = 1024 * 1024 * 1024;
  if (safe < gib * 1024) {
    return '${(b / gib).toStringAsFixed(2)} GB';
  }
  final tib = gib * 1024;
  return '${(b / tib).toStringAsFixed(2)} TB';
}
