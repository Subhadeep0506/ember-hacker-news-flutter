import '../api/vote_api_service.dart';

class VoteRepository {
  final VoteApiService _apiService;

  VoteRepository(this._apiService);

  Future<bool> vote({
    required int itemId,
    required String direction,
    required String token,
  }) async {
    return _apiService.vote(itemId: itemId, direction: direction, token: token);
  }
}
