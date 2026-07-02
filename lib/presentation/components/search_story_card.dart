import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';
import 'story_card_view.dart';

/// Story card for Algolia search / profile submission results. Uses the same
/// [StoryCardView] as the feed so the two look identical.
class SearchStoryCard extends StatelessWidget {
  final AlgoliaStoryHit hit;
  final VoidCallback? onTap;

  const SearchStoryCard({super.key, required this.hit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return StoryCardView(
      url: hit.url,
      title: hit.title,
      author: hit.author,
      timeText: timeAgo(hit.createdAtI),
      score: hit.points,
      commentCount: hit.numComments,
      onTap: onTap,
    );
  }
}
