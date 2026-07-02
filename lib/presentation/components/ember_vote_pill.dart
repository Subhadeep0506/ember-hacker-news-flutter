import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/compact_number.dart';

/// Rounded score + upvote control shown on the trailing edge of a story card.
///
/// Hacker News has no story downvote, so this renders an up-chevron only. The
/// chevron turns [accentOrange] once [isUpvoted]; [isLoading] swaps it for a
/// small spinner while a vote request is in flight.
class EmberVotePill extends StatelessWidget {
  final int score;
  final bool isUpvoted;
  final VoidCallback? onUpvote;
  final bool isLoading;

  const EmberVotePill({
    super.key,
    required this.score,
    this.isUpvoted = false,
    this.onUpvote,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final activeColor = isUpvoted ? ember?.accentOrange : ember?.upvoteColor;

    return Material(
      color: ember?.votePillBackground,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onUpvote,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: activeColor,
                  ),
                )
              else
                Icon(AppIcons.chevronUp, size: 20, color: activeColor),
              const SizedBox(width: 6),
              Text(
                compactNumber(score),
                style: textTheme.labelLarge?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
