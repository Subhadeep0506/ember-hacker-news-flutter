import 'package:json_annotation/json_annotation.dart';

part 'algolia_story_hit.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AlgoliaStoryHit {
  @JsonKey(name: 'objectID')
  final String objectId;
  final String title;
  final String? url;
  final String author;
  final int points;
  final int numComments;
  final String? storyText;
  final String createdAt;
  final int createdAtI;

  const AlgoliaStoryHit({
    required this.objectId,
    required this.title,
    this.url,
    required this.author,
    required this.points,
    required this.numComments,
    this.storyText,
    required this.createdAt,
    required this.createdAtI,
  });

  factory AlgoliaStoryHit.fromJson(Map<String, dynamic> json) =>
      AlgoliaStoryHit(
        objectId: _stringValue(json['objectID'] ?? json['story_id']),
        title: _stringValue(json['title'] ?? json['story_title'], 'Untitled'),
        url: _nullableString(json['url'] ?? json['story_url']),
        author: _stringValue(json['author']),
        points: _intValue(json['points']),
        numComments: _intValue(json['num_comments']),
        storyText: _nullableString(json['story_text']),
        createdAt: _stringValue(json['created_at']),
        createdAtI: _intValue(json['created_at_i']),
      );

  Map<String, dynamic> toJson() => _$AlgoliaStoryHitToJson(this);
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
