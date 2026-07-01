import 'api_client.dart';

class VoteApiService {
  final ApiClient _client;

  VoteApiService(this._client);

  Future<bool> vote({
    required int itemId,
    required String direction,
    required String token,
  }) async {
    final json = await _client.post(
      '/write/vote',
      body: {'itemId': itemId, 'direction': direction},
      token: token,
    );
    return json['ok'] as bool;
  }
}
