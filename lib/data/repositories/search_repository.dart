import '../../domain/models/models.dart';
import '../api/search_api_service.dart';

class SearchRepository {
  final SearchApiService _apiService;

  SearchRepository(this._apiService);

  Future<SearchResponse> search(
    String query, {
    String sort = 'relevance',
    int page = 0,
    int limit = 20,
  }) {
    return _apiService.search(query, sort: sort, page: page, limit: limit);
  }
}
