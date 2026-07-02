// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

part of 'algolia_comment_hit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlgoliaCommentHit _$AlgoliaCommentHitFromJson(Map<String, dynamic> json) =>
    AlgoliaCommentHit(
      objectId: json['objectID'] as String,
      author: json['author'] as String,
      commentText: json['comment_text'] as String,
      storyId: (json['story_id'] as num).toInt(),
      storyTitle: json['story_title'] as String?,
      storyUrl: json['story_url'] as String?,
      parentId: (json['parent_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
      createdAtI: (json['created_at_i'] as num).toInt(),
      points: (json['points'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AlgoliaCommentHitToJson(AlgoliaCommentHit instance) =>
    <String, dynamic>{
      'objectID': instance.objectId,
      'author': instance.author,
      'comment_text': instance.commentText,
      'story_id': instance.storyId,
      'story_title': instance.storyTitle,
      'story_url': instance.storyUrl,
      'parent_id': instance.parentId,
      'created_at': instance.createdAt,
      'created_at_i': instance.createdAtI,
      'points': instance.points,
    };
