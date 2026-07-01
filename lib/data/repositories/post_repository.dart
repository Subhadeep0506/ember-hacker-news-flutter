import '../../domain/models/models.dart';
import '../api/feed_api_service.dart';

class PostDetail {
  final ItemResponse item;
  final List<Comment> comments;

  const PostDetail({required this.item, required this.comments});
}

class PostRepository {
  final FeedApiService _apiService;

  PostRepository(this._apiService);

  Future<PostDetail> getPost(int id) async {
    final response = await _apiService.getItem(id);
    final comments = (response.children ?? [])
        .whereType<Map<String, dynamic>>()
        .map((c) => Comment.fromJson(c))
        .where((c) => !c.deleted && !c.dead && c.id != 0)
        .toList();
    return PostDetail(item: response, comments: comments);
  }
}
