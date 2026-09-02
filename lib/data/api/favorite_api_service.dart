import 'api_client.dart';

class FavoriteApiService {
  final ApiClient _client;

  FavoriteApiService(this._client);

  /// Favorites ([favorite] == true) or un-favorites the given item on Hacker
  /// News via the backend. Requires an authenticated [token].
  Future<bool> favorite({
    required int itemId,
    required bool favorite,
    required String token,
  }) async {
    final json = await _client.post(
      '/write/favorite',
      body: {'itemId': itemId, 'favorite': favorite},
      token: token,
    );
    return json['ok'] as bool;
  }

  /// Reads whether the authenticated user has currently favorited [itemId] on
  /// Hacker News, per the backend (which inspects the live item page).
  Future<bool> getFavoriteStatus({
    required int itemId,
    required String token,
  }) async {
    final json = await _client.get('/item/$itemId/favorited', token: token);
    return json['favorited'] as bool? ?? false;
  }
}
