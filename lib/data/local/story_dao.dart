import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import '../../domain/models/models.dart';
import 'database_helper.dart';

class StoryDao {
  Future<void> insertStories(List<HnItem> stories) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final story in stories) {
      batch.insert('stories', {
        'id': story.id,
        'type': story.type,
        'by_user': story.by,
        'time': story.time,
        'title': story.title,
        'url': story.url,
        'text': story.text,
        'score': story.score,
        'descendants': story.descendants,
        'dead': (story.dead ?? false) ? 1 : 0,
        'deleted': (story.deleted ?? false) ? 1 : 0,
        'cached_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> cacheFeedPage(
    FeedType type,
    int page,
    List<int> storyIds,
  ) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.delete(
      'feed_cache',
      where: 'feed_type = ? AND page = ?',
      whereArgs: [type.apiValue, page],
    );

    final batch = db.batch();
    for (var i = 0; i < storyIds.length; i++) {
      batch.insert('feed_cache', {
        'feed_type': type.apiValue,
        'page': page,
        'story_id': storyIds[i],
        'position': i,
        'cached_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<HnItem>?> getCachedFeed(
    FeedType type,
    int page, {
    Duration maxAge = const Duration(minutes: 15),
  }) async {
    if (kIsWeb) return null;

    final db = await DatabaseHelper.database;
    final cutoff =
        DateTime.now().millisecondsSinceEpoch - maxAge.inMilliseconds;

    final rows = await db.rawQuery(
      '''
      SELECT s.* FROM feed_cache fc
      INNER JOIN stories s ON fc.story_id = s.id
      WHERE fc.feed_type = ? AND fc.page = ? AND fc.cached_at > ?
      ORDER BY fc.position ASC
      ''',
      [type.apiValue, page, cutoff],
    );

    if (rows.isEmpty) return null;

    return rows.map(_rowToHnItem).toList();
  }

  Future<void> clearFeedCache(FeedType type) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.delete(
      'feed_cache',
      where: 'feed_type = ?',
      whereArgs: [type.apiValue],
    );
  }

  Future<void> clearAllCaches() async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.delete('feed_cache');
    await db.delete('stories');
  }

  HnItem _rowToHnItem(Map<String, dynamic> row) {
    return HnItem(
      id: row['id'] as int,
      type: row['type'] as String,
      by: row['by_user'] as String?,
      time: row['time'] as int,
      title: row['title'] as String?,
      url: row['url'] as String?,
      text: row['text'] as String?,
      score: row['score'] as int?,
      descendants: row['descendants'] as int?,
      dead: (row['dead'] as int?) == 1,
      deleted: (row['deleted'] as int?) == 1,
    );
  }
}
