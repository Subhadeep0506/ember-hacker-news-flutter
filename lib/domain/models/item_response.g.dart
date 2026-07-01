// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemResponse _$ItemResponseFromJson(Map<String, dynamic> json) => ItemResponse(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  by: json['by'] as String?,
  time: (json['time'] as num).toInt(),
  text: json['text'] as String?,
  url: json['url'] as String?,
  title: json['title'] as String?,
  score: (json['score'] as num?)?.toInt(),
  descendants: (json['descendants'] as num?)?.toInt(),
  kids: (json['kids'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  parent: (json['parent'] as num?)?.toInt(),
  dead: json['dead'] as bool?,
  deleted: json['deleted'] as bool?,
  children: json['children'] as List<dynamic>?,
);

Map<String, dynamic> _$ItemResponseToJson(ItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'by': instance.by,
      'time': instance.time,
      'text': instance.text,
      'url': instance.url,
      'title': instance.title,
      'score': instance.score,
      'descendants': instance.descendants,
      'kids': instance.kids,
      'parent': instance.parent,
      'dead': instance.dead,
      'deleted': instance.deleted,
      'children': instance.children,
    };
