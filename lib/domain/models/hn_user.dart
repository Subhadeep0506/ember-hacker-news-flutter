import 'package:json_annotation/json_annotation.dart';

part 'hn_user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class HnUser {
  final String id;
  final double created;
  final double karma;
  final String? about;
  final List<double>? submitted;

  const HnUser({
    required this.id,
    required this.created,
    required this.karma,
    this.about,
    this.submitted,
  });

  factory HnUser.fromJson(Map<String, dynamic> json) => _$HnUserFromJson(json);

  Map<String, dynamic> toJson() => _$HnUserToJson(this);
}
