import 'package:share_plus/share_plus.dart';

import '../domain/models/models.dart';
import 'html_unescape.dart';

/// Shares a post as plain text containing its title, the article URL (when the
/// post links out), and the Hacker News discussion link.
///
/// Uses the native share sheet on mobile/desktop and the Web Share API (with a
/// clipboard fallback) on web.
Future<void> sharePost(ItemResponse item) async {
  final title = htmlUnescape(item.title ?? '').trim();
  final discussionUrl = 'https://news.ycombinator.com/item?id=${item.id}';
  final articleUrl = item.url;

  final lines = <String>[
    if (title.isNotEmpty) title,
    if (articleUrl != null && articleUrl.isNotEmpty) articleUrl,
    'Discussion: $discussionUrl',
  ];

  await SharePlus.instance.share(
    ShareParams(
      text: lines.join('\n\n'),
      subject: title.isNotEmpty ? title : 'Hacker News',
    ),
  );
}
