import 'package:json_annotation/json_annotation.dart';

import 'algolia_comment_hit.dart';

part 'user_comments_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserCommentsResponse {
  final List<AlgoliaCommentHit> items;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;

  const UserCommentsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory UserCommentsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserCommentsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserCommentsResponseToJson(this);
}
