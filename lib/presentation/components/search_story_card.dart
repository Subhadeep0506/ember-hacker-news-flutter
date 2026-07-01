import 'package:flutter/material.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';
import '../../utils/url_utils.dart';
import 'story_thumbnail.dart';
import 'tappable_username.dart';

class SearchStoryCard extends StatelessWidget {
  final AlgoliaStoryHit hit;
  final VoidCallback? onTap;

  const SearchStoryCard({super.key, required this.hit, this.onTap});

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
              StoryThumbnail(url: hit.url),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Content(
                      hit: hit,
                      textTheme: textTheme,
                      ember: ember,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CommentCount(
                    count: hit.numComments,
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

class _Content extends StatelessWidget {
  final AlgoliaStoryHit hit;
  final TextTheme textTheme;
  final EmberThemeExtension? ember;

  const _Content({
    required this.hit,
    required this.textTheme,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    final domain = extractDomain(hit.url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hit.title,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        _MetadataRow(hit: hit, domain: domain, ember: ember, textTheme: textTheme),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final AlgoliaStoryHit hit;
  final String? domain;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _MetadataRow({
    required this.hit,
    required this.domain,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
      fontSize: 12,
    );
    final time = timeAgo(hit.createdAtI);

    return Row(
      children: [
        if (domain != null) ...[
          Text(domain!, style: metaStyle),
          Text(' · ', style: metaStyle),
        ],
        Text('${hit.points} pts', style: metaStyle),
        Text(' · ', style: metaStyle),
        TappableUsername(username: hit.author, style: metaStyle),
        if (time.isNotEmpty) ...[
          Text(' · ', style: metaStyle),
          Text(time, style: metaStyle),
        ],
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
