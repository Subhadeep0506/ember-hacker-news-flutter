// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_comments_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCommentsResponse _$UserCommentsResponseFromJson(
  Map<String, dynamic> json,
) => UserCommentsResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => AlgoliaCommentHit.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$UserCommentsResponseToJson(
  UserCommentsResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'totalPages': instance.totalPages,
};
