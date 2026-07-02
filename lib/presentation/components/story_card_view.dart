import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/url_utils.dart';
import 'ember_domain_avatar.dart';
import 'ember_vote_pill.dart';
import 'story_thumbnail.dart';
import 'tappable_username.dart';

/// Shared presentation for a story card, used by both the feed's [StoryCard]
/// (from an `HnItem`) and the search/profile `SearchStoryCard` (from an Algolia
/// hit). Keeping the layout here guarantees the two stay visually identical.
class StoryCardView extends StatelessWidget {
  final String? url;
  final String title;
  final String? author;
  final String timeText;
  final int score;
  final int commentCount;
  final bool isRead;
  final bool isUpvoted;
  final bool showDomain;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const StoryCardView({
    super.key,
    required this.url,
    required this.title,
    required this.author,
    required this.timeText,
    required this.score,
    required this.commentCount,
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
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                url: url,
                author: author,
                timeText: timeText,
                showDomain: showDomain,
                onMore: onMore,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: isRead ? ember?.readStoryTitle : null,
                ),
              ),
              const SizedBox(height: 12),
              StoryThumbnail(url: url),
              _Footer(
                score: score,
                commentCount: commentCount,
                isUpvoted: isUpvoted,
                onUpvote: onUpvote,
                onShare: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String? url;
  final String? author;
  final String timeText;
  final bool showDomain;
  final VoidCallback? onMore;

  const _Header({
    required this.url,
    required this.author,
    required this.timeText,
    required this.showDomain,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final domain =
        (showDomain ? extractDomain(url) : null) ?? 'news.ycombinator.com';
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
    );

    return Row(
      children: [
        EmberDomainAvatar(url: url),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                domain,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text('by ', style: metaStyle),
                  Flexible(
                    child: TappableUsername(username: author, style: metaStyle),
                  ),
                  if (timeText.isNotEmpty)
                    Text(' · $timeText', style: metaStyle),
                ],
              ),
            ],
          ),
        ),
        if (onMore != null)
          IconButton(
            onPressed: onMore,
            visualDensity: VisualDensity.compact,
            icon: Icon(AppIcons.more, size: 20, color: ember?.metadataColor),
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final int score;
  final int commentCount;
  final bool isUpvoted;
  final VoidCallback? onUpvote;
  final VoidCallback? onShare;

  const _Footer({
    required this.score,
    required this.commentCount,
    required this.isUpvoted,
    this.onUpvote,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FooterAction(icon: AppIcons.comment, label: '$commentCount'),
        const SizedBox(width: 4),
        _FooterAction(icon: AppIcons.share, onTap: onShare),
        const SizedBox(width: 4),
        _FooterAction(icon: AppIcons.gift),
        const Spacer(),
        EmberVotePill(score: score, isUpvoted: isUpvoted, onUpvote: onUpvote),
      ],
    );
  }
}

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  const _FooterAction({required this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final color = ember?.metadataColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label ?? '',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
