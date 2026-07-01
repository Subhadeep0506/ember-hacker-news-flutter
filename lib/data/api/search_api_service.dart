import '../../domain/models/models.dart';
import 'api_client.dart';

class SearchApiService {
  final ApiClient _client;

  SearchApiService(this._client);

  Future<SearchResponse> search(
    String query, {
    String sort = 'relevance',
    int page = 0,
    int limit = 20,
  }) async {
    final json = await _client.get(
      '/feed/search',
      queryParams: {
        'query': query,
        'sort': sort,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return SearchResponse.fromJson(json);
  }
}
