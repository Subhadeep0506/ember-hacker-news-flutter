String timeAgo(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds == 0) return '';

  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final diff = now.difference(date);

  if (diff.isNegative) return '';
  if (diff.inSeconds < 60) {
    final s = diff.inSeconds;
    return '$s sec${s == 1 ? '' : 's'} ago';
  }
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m min${m == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h hour${h == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 30) {
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 365) {
    final mo = (diff.inDays / 30).floor();
    return '$mo month${mo == 1 ? '' : 's'} ago';
  }
  final y = (diff.inDays / 365).floor();
  return '$y year${y == 1 ? '' : 's'} ago';
}
