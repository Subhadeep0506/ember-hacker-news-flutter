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
      _$AlgoliaStoryHitFromJson(json);

  Map<String, dynamic> toJson() => _$AlgoliaStoryHitToJson(this);
}
