import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'ember_hn.db';
  static const _databaseVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stories (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        by_user TEXT,
        time INTEGER NOT NULL,
        title TEXT,
        url TEXT,
        text TEXT,
        score INTEGER,
        descendants INTEGER,
        dead INTEGER DEFAULT 0,
        deleted INTEGER DEFAULT 0,
        cached_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE feed_cache (
        feed_type TEXT NOT NULL,
        page INTEGER NOT NULL,
        story_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        cached_at INTEGER NOT NULL,
        PRIMARY KEY (feed_type, page, position)
      )
    ''');

    await db.execute('''
      CREATE TABLE read_history (
        story_id INTEGER PRIMARY KEY,
        read_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
