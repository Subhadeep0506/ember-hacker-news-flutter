import '../api/favorite_api_service.dart';

class FavoriteRepository {
  final FavoriteApiService _apiService;

  FavoriteRepository(this._apiService);

  Future<bool> favorite({
    required int itemId,
    required bool favorite,
    required String token,
  }) async {
    return _apiService.favorite(
      itemId: itemId,
      favorite: favorite,
      token: token,
    );
  }

  Future<bool> isFavorited({required int itemId, required String token}) {
    return _apiService.getFavoriteStatus(itemId: itemId, token: token);
  }
}
