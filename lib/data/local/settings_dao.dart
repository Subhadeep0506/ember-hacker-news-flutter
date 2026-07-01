import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class SettingsDao {
  Future<void> set(String key, String value) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> get(String key) async {
    if (kIsWeb) return null;

    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<Map<String, String>> getAll() async {
    if (kIsWeb) return {};

    final db = await DatabaseHelper.database;
    final rows = await db.query('settings');
    return {
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
  }

  Future<void> delete(String key) async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clearAll() async {
    if (kIsWeb) return;

    final db = await DatabaseHelper.database;
    await db.delete('settings');
  }
}
