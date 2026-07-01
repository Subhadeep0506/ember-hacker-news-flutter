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
  final int parentId;
  final String createdAt;
  final int createdAtI;
  final int points;

  const AlgoliaCommentHit({
    required this.objectId,
    required this.author,
    required this.commentText,
    required this.storyId,
    this.storyTitle,
    this.storyUrl,
    required this.parentId,
    required this.createdAt,
    required this.createdAtI,
    required this.points,
  });

  factory AlgoliaCommentHit.fromJson(Map<String, dynamic> json) =>
      _$AlgoliaCommentHitFromJson(json);

  Map<String, dynamic> toJson() => _$AlgoliaCommentHitToJson(this);
}
