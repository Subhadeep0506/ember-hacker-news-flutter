import '../api/comment_api_service.dart';

class CommentRepository {
  final CommentApiService _apiService;

  CommentRepository(this._apiService);

  Future<bool> postComment({
    required int parentId,
    required String text,
    required String token,
  }) async {
    return _apiService.postComment(
      parentId: parentId,
      text: text,
      token: token,
    );
  }
}
