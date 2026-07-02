/// Formats [value] as a short, human-readable string: `950`, `2.4k`, `1.2M`.
///
/// Values under 1000 are returned as-is. Thousands and millions are shown with
/// one decimal, dropping a trailing `.0` (e.g. `2000` -> `2k`, `2400` -> `2.4k`).
String compactNumber(int value) {
  if (value < 1000) return '$value';
  if (value < 1000000) return '${_trim(value / 1000)}k';
  return '${_trim(value / 1000000)}M';
}

String _trim(double n) {
  final fixed = n.toStringAsFixed(1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}
