import 'package:json_annotation/json_annotation.dart';

part 'hn_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class HnItem {
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

  const HnItem({
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
  });

  HnItem copyWith({
    int? id,
    String? type,
    String? by,
    int? time,
    String? text,
    String? url,
    String? title,
    int? score,
    int? descendants,
    List<int>? kids,
    int? parent,
    bool? dead,
    bool? deleted,
  }) {
    return HnItem(
      id: id ?? this.id,
      type: type ?? this.type,
      by: by ?? this.by,
      time: time ?? this.time,
      text: text ?? this.text,
      url: url ?? this.url,
      title: title ?? this.title,
      score: score ?? this.score,
      descendants: descendants ?? this.descendants,
      kids: kids ?? this.kids,
      parent: parent ?? this.parent,
      dead: dead ?? this.dead,
      deleted: deleted ?? this.deleted,
    );
  }

  factory HnItem.fromJson(Map<String, dynamic> json) => _$HnItemFromJson(json);

  Map<String, dynamic> toJson() => _$HnItemToJson(this);
}
