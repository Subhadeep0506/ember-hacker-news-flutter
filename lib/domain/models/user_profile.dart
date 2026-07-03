import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile {
  final String username;
  final double? karma;
  final double? created;
  final String? about;
  final String? email;
  final String? showdead;
  final String? noprocrast;
  final String? maxvisit;
  final String? minaway;
  final String? delay;

  const UserProfile({
    required this.username,
    this.karma,
    this.created,
    this.about,
    this.email,
    this.showdead,
    this.noprocrast,
    this.maxvisit,
    this.minaway,
    this.delay,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
