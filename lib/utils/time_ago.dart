String timeAgo(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds == 0) return '';

  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final diff = now.difference(date);

  if (diff.isNegative) return '';
  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 30) return '${diff.inDays}d';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}
