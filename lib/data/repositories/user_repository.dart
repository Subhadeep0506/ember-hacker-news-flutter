import '../../domain/models/models.dart';
import '../api/user_api_service.dart';

class UserRepository {
  final UserApiService _apiService;

  UserRepository(this._apiService);

  Future<HnUser> getUser(String username) {
    return _apiService.getUser(username);
  }

  Future<SearchResponse> getSubmissions(
    String username, {
    int page = 0,
    int limit = 20,
  }) {
    return _apiService.getSubmissions(username, page: page, limit: limit);
  }

  Future<UserCommentsResponse> getComments(
    String username, {
    int page = 0,
    int limit = 20,
  }) {
    return _apiService.getComments(username, page: page, limit: limit);
  }

  Future<UserFavoritesResponse> getFavorites(
    String username, {
    int page = 1,
    int limit = 30,
  }) {
    return _apiService.getFavorites(username, page: page, limit: limit);
  }
}
