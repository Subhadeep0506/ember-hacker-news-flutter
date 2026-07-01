import 'package:flutter/material.dart';

class EmberThemeExtension extends ThemeExtension<EmberThemeExtension> {
  final Color accentOrange;
  final Color storyCardBackground;
  final Color scoreColor;
  final Color metadataColor;
  final Color domainColor;
  final Color readStoryTitle;
  final Color upvoteColor;
  final Color commentCountColor;
  final Color commentAuthorColor;
  final Color commentActionColor;
  final Color commentBorderLevel0;
  final Color commentBorderLevel1;
  final Color commentBorderLevel2;
  final Color commentBorderLevel3;
  final Color commentBorderLevel4;

  const EmberThemeExtension({
    required this.accentOrange,
    required this.storyCardBackground,
    required this.scoreColor,
    required this.metadataColor,
    required this.domainColor,
    required this.readStoryTitle,
    required this.upvoteColor,
    required this.commentCountColor,
    required this.commentAuthorColor,
    required this.commentActionColor,
    required this.commentBorderLevel0,
    required this.commentBorderLevel1,
    required this.commentBorderLevel2,
    required this.commentBorderLevel3,
    required this.commentBorderLevel4,
  });

  Color commentBorderForDepth(int depth) {
    const colors = [0, 1, 2, 3, 4];
    switch (colors[depth % colors.length]) {
      case 0:
        return commentBorderLevel0;
      case 1:
        return commentBorderLevel1;
      case 2:
        return commentBorderLevel2;
      case 3:
        return commentBorderLevel3;
      case 4:
        return commentBorderLevel4;
      default:
        return commentBorderLevel0;
    }
  }

  factory EmberThemeExtension.dark() {
    return const EmberThemeExtension(
      accentOrange: Color(0xFFFF6600),
      storyCardBackground: Color(0xFF1E1E1E),
      scoreColor: Color(0xFFFF6600),
      metadataColor: Color(0xFF9E9E9E),
      domainColor: Color(0xFF7A7A7A),
      readStoryTitle: Color(0xFF6E6E6E),
      upvoteColor: Color(0xFF9E9E9E),
      commentCountColor: Color(0xFFFF6600),
      commentAuthorColor: Color(0xFF4FC3F7),
      commentActionColor: Color(0xFF616161),
      commentBorderLevel0: Color(0xFFFF6600),
      commentBorderLevel1: Color(0xFF4FC3F7),
      commentBorderLevel2: Color(0xFF66BB6A),
      commentBorderLevel3: Color(0xFFAB47BC),
      commentBorderLevel4: Color(0xFF26A69A),
    );
  }

  factory EmberThemeExtension.light() {
    return const EmberThemeExtension(
      accentOrange: Color(0xFFFF6600),
      storyCardBackground: Color(0xFFF5F5F5),
      scoreColor: Color(0xFFE55800),
      metadataColor: Color(0xFF757575),
      domainColor: Color(0xFF9E9E9E),
      readStoryTitle: Color(0xFFB0B0B0),
      upvoteColor: Color(0xFF757575),
      commentCountColor: Color(0xFFE55800),
      commentAuthorColor: Color(0xFF0277BD),
      commentActionColor: Color(0xFF9E9E9E),
      commentBorderLevel0: Color(0xFFE55800),
      commentBorderLevel1: Color(0xFF0277BD),
      commentBorderLevel2: Color(0xFF388E3C),
      commentBorderLevel3: Color(0xFF7B1FA2),
      commentBorderLevel4: Color(0xFF00897B),
    );
  }

  @override
  EmberThemeExtension copyWith({
    Color? accentOrange,
    Color? storyCardBackground,
    Color? scoreColor,
    Color? metadataColor,
    Color? domainColor,
    Color? readStoryTitle,
    Color? upvoteColor,
    Color? commentCountColor,
    Color? commentAuthorColor,
    Color? commentActionColor,
    Color? commentBorderLevel0,
    Color? commentBorderLevel1,
    Color? commentBorderLevel2,
    Color? commentBorderLevel3,
    Color? commentBorderLevel4,
  }) {
    return EmberThemeExtension(
      accentOrange: accentOrange ?? this.accentOrange,
      storyCardBackground: storyCardBackground ?? this.storyCardBackground,
      scoreColor: scoreColor ?? this.scoreColor,
      metadataColor: metadataColor ?? this.metadataColor,
      domainColor: domainColor ?? this.domainColor,
      readStoryTitle: readStoryTitle ?? this.readStoryTitle,
      upvoteColor: upvoteColor ?? this.upvoteColor,
      commentCountColor: commentCountColor ?? this.commentCountColor,
      commentAuthorColor: commentAuthorColor ?? this.commentAuthorColor,
      commentActionColor: commentActionColor ?? this.commentActionColor,
      commentBorderLevel0: commentBorderLevel0 ?? this.commentBorderLevel0,
      commentBorderLevel1: commentBorderLevel1 ?? this.commentBorderLevel1,
      commentBorderLevel2: commentBorderLevel2 ?? this.commentBorderLevel2,
      commentBorderLevel3: commentBorderLevel3 ?? this.commentBorderLevel3,
      commentBorderLevel4: commentBorderLevel4 ?? this.commentBorderLevel4,
    );
  }

  @override
  EmberThemeExtension lerp(EmberThemeExtension? other, double t) {
    if (other is! EmberThemeExtension) return this;
    return EmberThemeExtension(
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      storyCardBackground: Color.lerp(
        storyCardBackground,
        other.storyCardBackground,
        t,
      )!,
      scoreColor: Color.lerp(scoreColor, other.scoreColor, t)!,
      metadataColor: Color.lerp(metadataColor, other.metadataColor, t)!,
      domainColor: Color.lerp(domainColor, other.domainColor, t)!,
      readStoryTitle: Color.lerp(readStoryTitle, other.readStoryTitle, t)!,
      upvoteColor: Color.lerp(upvoteColor, other.upvoteColor, t)!,
      commentCountColor: Color.lerp(
        commentCountColor,
        other.commentCountColor,
        t,
      )!,
      commentAuthorColor: Color.lerp(
        commentAuthorColor,
        other.commentAuthorColor,
        t,
      )!,
      commentActionColor: Color.lerp(
        commentActionColor,
        other.commentActionColor,
        t,
      )!,
      commentBorderLevel0: Color.lerp(
        commentBorderLevel0,
        other.commentBorderLevel0,
        t,
      )!,
      commentBorderLevel1: Color.lerp(
        commentBorderLevel1,
        other.commentBorderLevel1,
        t,
      )!,
      commentBorderLevel2: Color.lerp(
        commentBorderLevel2,
        other.commentBorderLevel2,
        t,
      )!,
      commentBorderLevel3: Color.lerp(
        commentBorderLevel3,
        other.commentBorderLevel3,
        t,
      )!,
      commentBorderLevel4: Color.lerp(
        commentBorderLevel4,
        other.commentBorderLevel4,
        t,
      )!,
    );
  }
}
