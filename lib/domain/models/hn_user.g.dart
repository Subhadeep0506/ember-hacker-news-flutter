// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hn_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HnUser _$HnUserFromJson(Map<String, dynamic> json) => HnUser(
  id: json['id'] as String,
  created: (json['created'] as num).toDouble(),
  karma: (json['karma'] as num).toDouble(),
  about: json['about'] as String?,
  submitted: (json['submitted'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$HnUserToJson(HnUser instance) => <String, dynamic>{
  'id': instance.id,
  'created': instance.created,
  'karma': instance.karma,
  'about': instance.about,
  'submitted': instance.submitted,
};
