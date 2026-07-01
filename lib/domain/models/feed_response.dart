import 'package:json_annotation/json_annotation.dart';

import 'hn_item.dart';

part 'feed_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FeedResponse {
  final List<HnItem> items;
  final int total;
  final int page;
  final int limit;

  const FeedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FeedResponseToJson(this);
}
