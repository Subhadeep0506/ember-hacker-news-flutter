import '../../domain/models/models.dart';
import 'api_client.dart';

class UserApiService {
  final ApiClient _client;

  UserApiService(this._client);

  Future<HnUser> getUser(String username) async {
    final json = await _client.get('/user/$username');
    return HnUser.fromJson(json);
  }

  Future<SearchResponse> getSubmissions(
    String username, {
    int page = 0,
    int limit = 20,
  }) async {
    final json = await _client.get(
      '/user/$username/submissions',
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
    return SearchResponse.fromJson(json);
  }

  Future<UserCommentsResponse> getComments(
    String username, {
    int page = 0,
    int limit = 20,
  }) async {
    final json = await _client.get(
      '/user/$username/comments',
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
    return UserCommentsResponse.fromJson(json);
  }
}
