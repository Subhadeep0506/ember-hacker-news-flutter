import 'package:json_annotation/json_annotation.dart';

import 'hn_item.dart';

part 'user_favorites_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserFavoritesResponse {
  final List<HnItem> items;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int totalPages;
  @JsonKey(name: 'hasMore')
  final bool hasMore;

  const UserFavoritesResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasMore,
  });

  factory UserFavoritesResponse.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesResponseToJson(this);
}
