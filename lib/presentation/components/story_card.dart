import 'package:flutter/material.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';
import '../../utils/url_utils.dart';
import 'story_thumbnail.dart';
import 'tappable_username.dart';

class StoryCard extends StatelessWidget {
  final HnItem item;
  final int rank;
  final bool isRead;
  final bool isUpvoted;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;

  const StoryCard({
    super.key,
    required this.item,
    required this.rank,
    this.isRead = false,
    this.isUpvoted = false,
    this.onTap,
    this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
          width: 0.5,
        ),
      ),
      color: ember?.storyCardBackground,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoryThumbnail(url: item.url),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RankAndVote(
                    rank: rank,
                    ember: ember,
                    isUpvoted: isUpvoted,
                    onUpvote: onUpvote,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StoryContent(
                      item: item,
                      isRead: isRead,
                      textTheme: textTheme,
                      ember: ember,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CommentCount(
                    count: item.descendants ?? 0,
                    ember: ember,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankAndVote extends StatelessWidget {
  final int rank;
  final EmberThemeExtension? ember;
  final bool isUpvoted;
  final VoidCallback? onUpvote;

  const _RankAndVote({
    required this.rank,
    required this.ember,
    this.isUpvoted = false,
    this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          Text(
            '$rank',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ember?.metadataColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onUpvote,
            child: Icon(
              AppIcons.upvote,
              color: isUpvoted ? ember?.accentOrange : ember?.upvoteColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  final HnItem item;
  final bool isRead;
  final TextTheme textTheme;
  final EmberThemeExtension? ember;

  const _StoryContent({
    required this.item,
    required this.isRead,
    required this.textTheme,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    final domain = extractDomain(item.url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: item.title ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isRead ? ember?.readStoryTitle : null,
                  height: 1.3,
                ),
              ),
              if (domain != null) ...[
                const TextSpan(text: ' '),
                TextSpan(
                  text: '($domain)',
                  style: textTheme.bodySmall?.copyWith(
                    color: ember?.domainColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        _MetadataRow(item: item, ember: ember, textTheme: textTheme),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final HnItem item;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _MetadataRow({
    required this.item,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
      fontSize: 12,
    );
    final time = timeAgo(item.time);

    return Row(
      children: [
        if (item.score != null) ...[
          Text('${item.score}', style: metaStyle),
          Text(' · ', style: metaStyle),
        ],
        if (item.by != null) ...[
          TappableUsername(
            username: item.by,
            style: metaStyle,
          ),
          Text(' · ', style: metaStyle),
        ],
        if (time.isNotEmpty) Text(time, style: metaStyle),
      ],
    );
  }
}

class _CommentCount extends StatelessWidget {
  final int count;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _CommentCount({
    required this.count,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(AppIcons.comment, size: 18, color: ember?.metadataColor),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: textTheme.labelSmall?.copyWith(
            color: ember?.commentCountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
