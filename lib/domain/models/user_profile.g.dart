// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  username: json['username'] as String,
  karma: (json['karma'] as num?)?.toDouble(),
  created: (json['created'] as num?)?.toDouble(),
  about: json['about'] as String?,
  email: json['email'] as String?,
  showdead: json['showdead'] as String?,
  noprocrast: json['noprocrast'] as String?,
  maxvisit: json['maxvisit'] as String?,
  minaway: json['minaway'] as String?,
  delay: json['delay'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'username': instance.username,
      'karma': instance.karma,
      'created': instance.created,
      'about': instance.about,
      'email': instance.email,
      'showdead': instance.showdead,
      'noprocrast': instance.noprocrast,
      'maxvisit': instance.maxvisit,
      'minaway': instance.minaway,
      'delay': instance.delay,
    };
