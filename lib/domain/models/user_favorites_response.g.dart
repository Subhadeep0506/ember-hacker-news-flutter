// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favorites_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFavoritesResponse _$UserFavoritesResponseFromJson(
  Map<String, dynamic> json,
) => UserFavoritesResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => HnItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
);

Map<String, dynamic> _$UserFavoritesResponseToJson(
  UserFavoritesResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'totalPages': instance.totalPages,
  'hasMore': instance.hasMore,
};
