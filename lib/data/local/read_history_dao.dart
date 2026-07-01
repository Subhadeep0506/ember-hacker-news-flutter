import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class ReadHistoryDao {
  Future<void> markRead(int storyId) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.insert('read_history', {
      'story_id': storyId,
      'read_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isRead(int storyId) async {
    if (kIsWeb) return false;

    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'read_history',
      where: 'story_id = ?',
      whereArgs: [storyId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<int>> getReadIds(List<int> storyIds) async {
    if (kIsWeb) return {};
    if (storyIds.isEmpty) return {};

    final db = await DatabaseHelper.database;
    final placeholders = List.filled(storyIds.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT story_id FROM read_history WHERE story_id IN ($placeholders)',
      storyIds,
    );

    return rows.map((r) => r['story_id'] as int).toSet();
  }

  Future<void> clearAll() async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.delete('read_history');
  }
}
