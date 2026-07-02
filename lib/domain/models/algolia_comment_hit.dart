import 'package:json_annotation/json_annotation.dart';

part 'algolia_comment_hit.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AlgoliaCommentHit {
  @JsonKey(name: 'objectID')
  final String objectId;
  final String author;
  final String commentText;
  final int storyId;
  final String? storyTitle;
  final String? storyUrl;
  // Nullable: HN Algolia returns null for top-level parents and for comment
  // points (comments carry no score).
  final int? parentId;
  final String createdAt;
  final int createdAtI;
  final int? points;

  const AlgoliaCommentHit({
    required this.objectId,
    required this.author,
    required this.commentText,
    required this.storyId,
    this.storyTitle,
    this.storyUrl,
    this.parentId,
    required this.createdAt,
    required this.createdAtI,
    this.points,
  });

  factory AlgoliaCommentHit.fromJson(Map<String, dynamic> json) =>
      AlgoliaCommentHit(
        objectId: _stringValue(json['objectID'] ?? json['id']),
        author: _stringValue(json['author']),
        commentText: _stringValue(
          json['comment_text'] ?? json['story_text'] ?? json['title'],
        ),
        storyId: _intValue(json['story_id'] ?? json['objectID']),
        storyTitle: _nullableString(json['story_title'] ?? json['title']),
        storyUrl: _nullableString(json['story_url'] ?? json['url']),
        parentId: _nullableInt(json['parent_id']),
        createdAt: _stringValue(json['created_at']),
        createdAtI: _intValue(json['created_at_i']),
        points: _nullableInt(json['points']),
      );

  Map<String, dynamic> toJson() => _$AlgoliaCommentHitToJson(this);
}

String _stringValue(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  final text = value.toString();
  return text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
