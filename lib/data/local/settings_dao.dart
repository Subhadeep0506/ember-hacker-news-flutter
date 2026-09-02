import 'package:shared_preferences/shared_preferences.dart';

/// Key/value store for small, persistent app state (settings, auth token,
/// upvoted item ids). Backed by [SharedPreferences] so it persists across
/// restarts on every platform — including web (localStorage), where the
/// sqflite-backed DAOs are no-ops.
class SettingsDao {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> set(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> get(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<Map<String, String>> getAll() async {
    final prefs = await _prefs;
    final result = <String, String>{};
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value is String) result[key] = value;
    }
    return result;
  }

  Future<void> delete(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
