import 'package:json_annotation/json_annotation.dart';

part 'item_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemResponse {
  final int id;
  final String type;
  final String? by;
  final int time;
  final String? text;
  final String? url;
  final String? title;
  final int? score;
  final int? descendants;
  final List<int>? kids;
  final int? parent;
  final bool? dead;
  final bool? deleted;
  final List<dynamic>? children;

  const ItemResponse({
    required this.id,
    required this.type,
    this.by,
    required this.time,
    this.text,
    this.url,
    this.title,
    this.score,
    this.descendants,
    this.kids,
    this.parent,
    this.dead,
    this.deleted,
    this.children,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ItemResponseToJson(this);
}
