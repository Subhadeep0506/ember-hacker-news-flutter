// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algolia_story_hit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlgoliaStoryHit _$AlgoliaStoryHitFromJson(Map<String, dynamic> json) =>
    AlgoliaStoryHit(
      objectId: json['objectID'] as String,
      title: json['title'] as String,
      url: json['url'] as String?,
      author: json['author'] as String,
      points: (json['points'] as num).toInt(),
      numComments: (json['num_comments'] as num).toInt(),
      storyText: json['story_text'] as String?,
      createdAt: json['created_at'] as String,
      createdAtI: (json['created_at_i'] as num).toInt(),
    );

Map<String, dynamic> _$AlgoliaStoryHitToJson(AlgoliaStoryHit instance) =>
    <String, dynamic>{
      'objectID': instance.objectId,
      'title': instance.title,
      'url': instance.url,
      'author': instance.author,
      'points': instance.points,
      'num_comments': instance.numComments,
      'story_text': instance.storyText,
      'created_at': instance.createdAt,
      'created_at_i': instance.createdAtI,
    };
