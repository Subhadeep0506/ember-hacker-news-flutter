import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/models/models.dart';
import 'auth_view_model.dart';
import 'settings_view_model.dart';

/// Ordering applied to comment threads at every nesting level.
enum CommentSort { oldestFirst, newestFirst }

class FlatComment {
  final Comment comment;
  final int depth;
  final int childCount;

  /// One entry per ancestor column (length == [depth]). `rails[c] == true` means
  /// the vertical thread line at ancestor column `c` continues through this row,
  /// i.e. the node on this row's path at depth `c + 1` still has siblings below.
  final List<bool> rails;

  /// Whether this comment has visible children below it, so a thread rail should
  /// descend from its avatar to connect them.
  final bool hasChildRail;

  const FlatComment({
    required this.comment,
    required this.depth,
    this.childCount = 0,
    this.rails = const [],
    this.hasChildRail = false,
  });
}

class PostDetailState {
  final AsyncValue<PostDetail> post;
  final List<FlatComment> flatComments;
  final Set<int> collapsedIds;
  final Set<int> upvotedIds;
  final Set<int> votingIds;
  final CommentSort commentSort;
  final int? currentPostId;

  const PostDetailState({
    this.post = const AsyncValue.loading(),
    this.flatComments = const [],
    this.collapsedIds = const {},
    this.upvotedIds = const {},
    this.votingIds = const {},
    this.commentSort = CommentSort.oldestFirst,
    this.currentPostId,
  });

  PostDetailState copyWith({
    AsyncValue<PostDetail>? post,
    List<FlatComment>? flatComments,
    Set<int>? collapsedIds,
    Set<int>? upvotedIds,
    Set<int>? votingIds,
    CommentSort? commentSort,
    int? currentPostId,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      flatComments: flatComments ?? this.flatComments,
      collapsedIds: collapsedIds ?? this.collapsedIds,
      upvotedIds: upvotedIds ?? this.upvotedIds,
      votingIds: votingIds ?? this.votingIds,
      commentSort: commentSort ?? this.commentSort,
      currentPostId: currentPostId ?? this.currentPostId,
    );
  }
}

List<Comment> _sortedComments(List<Comment> comments, CommentSort sort) {
  final copy = List<Comment>.from(comments);
  copy.sort((a, b) {
    final ta = a.time ?? 0;
    final tb = b.time ?? 0;
    return sort == CommentSort.newestFirst
        ? tb.compareTo(ta)
        : ta.compareTo(tb);
  });
  return copy;
}

/// Flattens the nested comment tree into a display list, honouring the current
/// [sort], the [collapsed] set, and whether dead/deleted comments are visible.
List<FlatComment> flattenComments(
  List<Comment> comments,
  int depth,
  Set<int> collapsed,
  CommentSort sort,
  bool showDeadDeleted, [
  List<bool> parentRails = const [],
]) {
  // Filter first so "last sibling" is measured against actually-rendered rows.
  final eligible = _sortedComments(
    comments,
    sort,
  ).where((c) => showDeadDeleted || (!c.dead && !c.deleted)).toList();

  final result = <FlatComment>[];
  for (var i = 0; i < eligible.length; i++) {
    final comment = eligible[i];
    final isLast = i == eligible.length - 1;
    final expanded = !collapsed.contains(comment.id);

    // This row's rails (length == depth). Each entry says whether that ancestor
    // column's line continues past this row; the last entry (this comment's own
    // column) is true when this comment still has siblings below it. Top-level
    // rows have no ancestor columns. Children extend this row's rails with their
    // own last-sibling flag, so every row carries its own flag — not its parent's.
    final rails = depth == 0 ? const <bool>[] : [...parentRails, !isLast];

    final children = expanded
        ? flattenComments(
            comment.children,
            depth + 1,
            collapsed,
            sort,
            showDeadDeleted,
            rails,
          )
        : const <FlatComment>[];

    result.add(
      FlatComment(
        comment: comment,
        depth: depth,
        childCount: comment.totalChildCount,
        rails: rails,
        hasChildRail: children.isNotEmpty,
      ),
    );
    result.addAll(children);
  }
  return result;
}

/// Collects the ids of comments at or below [threshold] depth, so threads can
/// be auto-collapsed on load (0 disables auto-collapse).
Set<int> _autoCollapsedIds(List<Comment> comments, int depth, int threshold) {
  final ids = <int>{};
  for (final comment in comments) {
    if (depth >= threshold && comment.children.isNotEmpty) {
      ids.add(comment.id);
    }
    ids.addAll(_autoCollapsedIds(comment.children, depth + 1, threshold));
  }
  return ids;
}

Set<int> _idsWithChildren(List<Comment> comments) {
  final ids = <int>{};
  for (final comment in comments) {
    if (comment.children.isNotEmpty) ids.add(comment.id);
    ids.addAll(_idsWithChildren(comment.children));
  }
  return ids;
}

class PostDetailViewModel extends Notifier<PostDetailState> {
  @override
  PostDetailState build() {
    return const PostDetailState();
  }

  bool get _showDeadDeleted =>
      ref.read(settingsViewModelProvider).showDeadDeleted;

  Future<void> loadPost(int id) async {
    state = PostDetailState(
      currentPostId: id,
      post: const AsyncValue.loading(),
    );

    try {
      final repo = ref.read(postRepositoryProvider);
      final result = await repo.getPost(id);
      final settings = ref.read(settingsViewModelProvider);
      final collapsed = settings.autoCollapseDepth > 0
          ? _autoCollapsedIds(result.comments, 0, settings.autoCollapseDepth)
          : <int>{};
      final flat = flattenComments(
        result.comments,
        0,
        collapsed,
        CommentSort.oldestFirst,
        settings.showDeadDeleted,
      );
      state = PostDetailState(
        currentPostId: id,
        post: AsyncValue.data(result),
        flatComments: flat,
        collapsedIds: collapsed,
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

  /// Silently reloads the thread after the user posts a reply, keeping the
  /// current post visible (no skeleton flash) and preserving collapse/vote/sort
  /// state. Retries once if the backend hasn't yet reflected the new comment.
  Future<void> reloadAfterReply() async {
    final id = state.currentPostId;
    if (id == null) return;

    final previousCount = _currentDescendants();
    try {
      final repo = ref.read(postRepositoryProvider);
      var result = await repo.getPost(id);
      if ((result.item.descendants ?? 0) <= previousCount) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        result = await repo.getPost(id);
      }
      _applyResult(result);
    } catch (_) {}
  }

  void _applyResult(PostDetail result) {
    final flat = flattenComments(
      result.comments,
      0,
      state.collapsedIds,
      state.commentSort,
      _showDeadDeleted,
    );
    state = state.copyWith(post: AsyncValue.data(result), flatComments: flat);
  }

  int _currentDescendants() {
    final post = state.post;
    if (post is AsyncData<PostDetail>) {
      return post.value.item.descendants ?? 0;
    }
    return 0;
  }

  Future<bool> upvoteItem(int itemId) async {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isLoggedIn || authState.token == null) return false;
    if (state.votingIds.contains(itemId)) return false;

    final isUpvoted = state.upvotedIds.contains(itemId);
    final direction = isUpvoted ? 'un' : 'up';

    state = state.copyWith(votingIds: {...state.votingIds, itemId});
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
    } finally {
      final voting = Set<int>.from(state.votingIds)..remove(itemId);
      state = state.copyWith(votingIds: voting);
    }
  }

  void toggleCollapse(int commentId) {
    final collapsed = Set<int>.from(state.collapsedIds);
    if (collapsed.contains(commentId)) {
      collapsed.remove(commentId);
    } else {
      collapsed.add(commentId);
    }
    _reflatten(collapsedIds: collapsed);
  }

  void setCommentSort(CommentSort sort) {
    if (sort == state.commentSort) return;
    _reflatten(commentSort: sort);
  }

  void collapseAll() {
    final post = state.post;
    if (post is! AsyncData<PostDetail>) return;
    _reflatten(collapsedIds: _idsWithChildren(post.value.comments));
  }

  void expandAll() {
    _reflatten(collapsedIds: <int>{});
  }

  void _reflatten({Set<int>? collapsedIds, CommentSort? commentSort}) {
    final post = state.post;
    if (post is! AsyncData<PostDetail>) return;
    final collapsed = collapsedIds ?? state.collapsedIds;
    final sort = commentSort ?? state.commentSort;
    final flat = flattenComments(
      post.value.comments,
      0,
      collapsed,
      sort,
      _showDeadDeleted,
    );
    state = state.copyWith(
      collapsedIds: collapsed,
      commentSort: sort,
      flatComments: flat,
    );
  }
}

final postDetailViewModelProvider =
    NotifierProvider<PostDetailViewModel, PostDetailState>(
      PostDetailViewModel.new,
    );
