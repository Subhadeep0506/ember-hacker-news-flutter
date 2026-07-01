import '../../domain/models/models.dart';
import 'api_client.dart';

class FeedApiService {
  final ApiClient _client;

  FeedApiService(this._client);

  Future<FeedResponse> getFeed(
    FeedType type, {
    int page = 0,
    int limit = 30,
  }) async {
    final json = await _client.get(
      '/feed/${type.apiValue}',
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
    return FeedResponse.fromJson(json);
  }

  Future<ItemResponse> getItem(int id) async {
    final json = await _client.get('/item/$id');
    return ItemResponse.fromJson(json);
  }
}
