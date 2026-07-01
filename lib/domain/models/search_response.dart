import 'package:json_annotation/json_annotation.dart';

import 'algolia_story_hit.dart';

part 'search_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SearchResponse {
  final List<AlgoliaStoryHit> items;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;

  const SearchResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}
