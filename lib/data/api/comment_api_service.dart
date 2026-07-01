import 'api_client.dart';

class CommentApiService {
  final ApiClient _client;

  CommentApiService(this._client);

  Future<bool> postComment({
    required int parentId,
    required String text,
    required String token,
  }) async {
    final json = await _client.post(
      '/write/comment',
      body: {'parentId': parentId, 'text': text},
      token: token,
    );
    return json['ok'] as bool;
  }
}
