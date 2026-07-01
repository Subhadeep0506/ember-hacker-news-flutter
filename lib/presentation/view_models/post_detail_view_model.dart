import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/models/models.dart';
import 'auth_view_model.dart';

class FlatComment {
  final Comment comment;
  final int depth;
  final int childCount;

  const FlatComment({
    required this.comment,
    required this.depth,
    this.childCount = 0,
  });
}

class PostDetailState {
  final AsyncValue<PostDetail> post;
  final List<FlatComment> flatComments;
  final Set<int> collapsedIds;
  final Set<int> upvotedIds;
  final int? currentPostId;

  const PostDetailState({
    this.post = const AsyncValue.loading(),
    this.flatComments = const [],
    this.collapsedIds = const {},
    this.upvotedIds = const {},
    this.currentPostId,
  });

  PostDetailState copyWith({
    AsyncValue<PostDetail>? post,
    List<FlatComment>? flatComments,
    Set<int>? collapsedIds,
    Set<int>? upvotedIds,
    int? currentPostId,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      flatComments: flatComments ?? this.flatComments,
      collapsedIds: collapsedIds ?? this.collapsedIds,
      upvotedIds: upvotedIds ?? this.upvotedIds,
      currentPostId: currentPostId ?? this.currentPostId,
    );
  }
}

List<FlatComment> flattenComments(
  List<Comment> comments,
  int depth,
  Set<int> collapsed,
) {
  final result = <FlatComment>[];
  for (final comment in comments) {
    result.add(
      FlatComment(
        comment: comment,
        depth: depth,
        childCount: comment.totalChildCount,
      ),
    );
    if (!collapsed.contains(comment.id)) {
      result.addAll(flattenComments(comment.children, depth + 1, collapsed));
    }
  }
  return result;
}

class PostDetailViewModel extends Notifier<PostDetailState> {
  @override
  PostDetailState build() {
    return const PostDetailState();
  }

  Future<void> loadPost(int id) async {
    state = PostDetailState(
      currentPostId: id,
      post: const AsyncValue.loading(),
    );

    try {
      final repo = ref.read(postRepositoryProvider);
      final result = await repo.getPost(id);
      final flat = flattenComments(result.comments, 0, const {});
      state = PostDetailState(
        currentPostId: id,
        post: AsyncValue.data(result),
        flatComments: flat,
      );
    } catch (e, st) {
      state = PostDetailState(currentPostId: id, post: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() async {
    final id = state.currentPostId;
    if (id != null) {
      await loadPost(id);
    }
  }

  Future<bool> upvoteItem(int itemId) async {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isLoggedIn || authState.token == null) return false;

    final isUpvoted = state.upvotedIds.contains(itemId);
    final direction = isUpvoted ? 'un' : 'up';

    try {
      final repo = ref.read(voteRepositoryProvider);
      await repo.vote(
        itemId: itemId,
        direction: direction,
        token: authState.token ?? '',
      );

      final newUpvoted = Set<int>.from(state.upvotedIds);
      if (isUpvoted) {
        newUpvoted.remove(itemId);
      } else {
        newUpvoted.add(itemId);
      }
      state = state.copyWith(upvotedIds: newUpvoted);
      return true;
    } catch (_) {
      return false;
    }
  }

  void toggleCollapse(int commentId) {
    final collapsed = Set<int>.from(state.collapsedIds);
    if (collapsed.contains(commentId)) {
      collapsed.remove(commentId);
    } else {
      collapsed.add(commentId);
    }

    final post = state.post;
    if (post is! AsyncData<PostDetail>) return;

    final flat = flattenComments(post.value.comments, 0, collapsed);
    state = state.copyWith(collapsedIds: collapsed, flatComments: flat);
  }
}

final postDetailViewModelProvider =
    NotifierProvider<PostDetailViewModel, PostDetailState>(
      PostDetailViewModel.new,
    );
