import '../local/settings_dao.dart';

/// Persists the set of item ids the user has upvoted so the highlighted vote
/// state survives app restarts and web reloads. Stored as a comma-separated
/// list under a single key in [SettingsDao].
class VotesRepository {
  final SettingsDao _dao;

  static const _key = 'upvoted_item_ids';

  VotesRepository(this._dao);

  Future<Set<int>> loadUpvoted() async {
    final raw = await _dao.get(_key);
    if (raw == null || raw.isEmpty) return <int>{};
    return raw.split(',').map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> saveUpvoted(Set<int> ids) {
    return _dao.set(_key, ids.join(','));
  }
}
