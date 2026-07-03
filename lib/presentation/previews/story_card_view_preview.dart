import 'package:flutter/material.dart';

import '../components/story_card_view.dart';
import 'ember_preview.dart';

@EmberPreview(
  name: 'StoryCardView — default',
  group: 'Cards',
  size: Size(420, 300),
)
Widget storyCardViewPreview() {
  return StoryCardView(
    url: 'https://github.com/flutter/flutter',
    title: 'Flutter 3.38 introduces widget previews for rapid UI iteration',
    author: 'pg',
    timeText: '3h ago',
    score: 256,
    commentCount: 142,
    onTap: () {},
    onUpvote: () {},
    onShare: () {},
    onMore: () {},
  );
}

@EmberPreview(
  name: 'StoryCardView — read',
  group: 'Cards',
  size: Size(420, 300),
)
Widget storyCardViewReadPreview() {
  return StoryCardView(
    url: 'https://news.ycombinator.com',
    title: 'Show HN: A new way to explore Hacker News stories',
    author: 'dang',
    timeText: '1d ago',
    score: 89,
    commentCount: 34,
    isRead: true,
    onTap: () {},
  );
}

@EmberPreview(
  name: 'StoryCardView — upvoted',
  group: 'Cards',
  size: Size(420, 300),
)
Widget storyCardViewUpvotedPreview() {
  return StoryCardView(
    url: 'https://www.rust-lang.org',
    title: 'Rust 2026 edition is released with major ergonomic improvements',
    author: 'steveklabnik',
    timeText: '5h ago',
    score: 512,
    commentCount: 201,
    isUpvoted: true,
    onTap: () {},
    onUpvote: () {},
  );
}
