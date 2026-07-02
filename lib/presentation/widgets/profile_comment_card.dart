import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';

class ProfileCommentCard extends StatelessWidget {
  final AlgoliaCommentHit comment;
  final VoidCallback? onTap;

  const ProfileCommentCard({
    super.key,
    required this.comment,
    this.onTap,
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
              if (comment.storyTitle != null)
                Text(
                  comment.storyTitle ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: ember?.metadataColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (comment.storyTitle != null) const SizedBox(height: 6),
              Text(
                _stripHtml(comment.commentText),
                style: textTheme.bodyMedium?.copyWith(height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                _buildMetadata(),
                style: textTheme.bodySmall?.copyWith(
                  color: ember?.metadataColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMetadata() {
    final parts = <String>[];
    final points = comment.points ?? 0;
    if (points > 0) parts.add('$points pts');
    final time = timeAgo(comment.createdAtI);
    if (time.isNotEmpty) parts.add(time);
    return parts.join(' · ');
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#x27;'), "'")
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }
}
