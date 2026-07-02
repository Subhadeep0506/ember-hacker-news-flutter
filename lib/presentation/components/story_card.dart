import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';
import 'story_card_view.dart';

/// Feed story card, rendered from an [HnItem] via the shared [StoryCardView].
class StoryCard extends StatelessWidget {
  final HnItem item;
  final int rank;
  final bool isRead;
  final bool isUpvoted;
  final bool showDomain;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const StoryCard({
    super.key,
    required this.item,
    required this.rank,
    this.isRead = false,
    this.isUpvoted = false,
    this.showDomain = true,
    this.onTap,
    this.onUpvote,
    this.onShare,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return StoryCardView(
      url: item.url,
      title: item.title ?? '',
      author: item.by,
      timeText: timeAgo(item.time),
      score: item.score ?? 0,
      commentCount: item.descendants ?? 0,
      isRead: isRead,
      isUpvoted: isUpvoted,
      showDomain: showDomain,
      onTap: onTap,
      onUpvote: onUpvote,
      onShare: onShare,
      onMore: onMore,
    );
  }
}
