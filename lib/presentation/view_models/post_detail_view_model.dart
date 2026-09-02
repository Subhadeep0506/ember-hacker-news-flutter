import 'dart:async';

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

  /// When non-null, this row is not a comment but a synthetic "show more replies"
  /// marker sitting under the parent comment with this id. [hiddenReplyCount] is
  /// how many further replies are collapsed behind it.
  final int? showMoreForParentId;
  final int hiddenReplyCount;

  const FlatComment({
    required this.comment,
    required this.depth,
    this.childCount = 0,
    this.rails = const [],
    this.hasChildRail = false,
    this.showMoreForParentId,
    this.hiddenReplyCount = 0,
  });

  /// True when this row is the "show more replies" expander rather than a comment.
  bool get isShowMore => showMoreForParentId != null;
}

class PostDetailState {
  final AsyncValue<PostDetail> post;
  final List<FlatComment> flatComments;
  final Set<int> collapsedIds;
  final Set<int> upvotedIds;
  final Set<int> votingIds;
  final Set<int> favoritedIds;
  final Set<int> favoritingIds;
  final Set<int> expandedRepliesIds;
  final CommentSort commentSort;
  final int? currentPostId;

  const PostDetailState({
    this.post = const AsyncValue.loading(),
    this.flatComments = const [],
    this.collapsedIds = const {},
    this.upvotedIds = const {},
    this.votingIds = const {},
    this.favoritedIds = const {},
    this.favoritingIds = const {},
    this.expandedRepliesIds = const {},
    this.commentSort = CommentSort.oldestFirst,
    this.currentPostId,
  });

  PostDetailState copyWith({
    AsyncValue<PostDetail>? post,
    List<FlatComment>? flatComments,
    Set<int>? collapsedIds,
    Set<int>? upvotedIds,
    Set<int>? votingIds,
    Set<int>? favoritedIds,
    Set<int>? favoritingIds,
    Set<int>? expandedRepliesIds,
    CommentSort? commentSort,
    int? currentPostId,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      flatComments: flatComments ?? this.flatComments,
      collapsedIds: collapsedIds ?? this.collapsedIds,
      upvotedIds: upvotedIds ?? this.upvotedIds,
      votingIds: votingIds ?? this.votingIds,
      favoritedIds: favoritedIds ?? this.favoritedIds,
      favoritingIds: favoritingIds ?? this.favoritingIds,
      expandedRepliesIds: expandedRepliesIds ?? this.expandedRepliesIds,
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

/// How many replies are shown per thread before a "show more" expander appears.
const int kVisibleRepliesLimit = 3;

/// Flattens the nested comment tree into a display list, honouring the current
/// [sort], the [collapsed] set, the [expandedReplies] set, and whether
/// dead/deleted comments are visible.
///
/// Replies (any level below a parent comment, i.e. [parentId] != null) are
/// capped to [kVisibleRepliesLimit] rows, followed by a synthetic "show more"
/// marker, unless the parent is in [expandedReplies]. Top-level comments
/// ([parentId] == null) are never capped.
List<FlatComment> flattenComments(
  List<Comment> comments,
  int depth,
  Set<int> collapsed,
  Set<int> expandedReplies,
  CommentSort sort,
  bool showDeadDeleted, [
  List<bool> parentRails = const [],
  int? parentId,
]) {
  // Filter first so "last sibling" is measured against actually-rendered rows.
  final eligible = _sortedComments(
    comments,
    sort,
  ).where((c) => showDeadDeleted || (!c.dead && !c.deleted)).toList();

  final capReplies =
      parentId != null &&
      !expandedReplies.contains(parentId) &&
      eligible.length > kVisibleRepliesLimit;
  final visible = capReplies
      ? eligible.take(kVisibleRepliesLimit).toList()
      : eligible;
  // The marker (if any) is the true last row at this level, so no visible child
  // counts as "last" when capping.
  final renderedCount = visible.length + (capReplies ? 1 : 0);

  final result = <FlatComment>[];
  for (var i = 0; i < visible.length; i++) {
    final comment = visible[i];
    final isLast = i == renderedCount - 1;
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
            expandedReplies,
            sort,
            showDeadDeleted,
            rails,
            comment.id,
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

  if (capReplies) {
    // Marker row sits at the same depth as the replies it stands in for and is
    // the last row at this level (its own column does not continue below).
    final markerRails = depth == 0 ? const <bool>[] : [...parentRails, false];
    result.add(
      FlatComment(
        comment: Comment(id: -parentId, parent: parentId),
        depth: depth,
        rails: markerRails,
        showMoreForParentId: parentId,
        hiddenReplyCount: eligible.length - kVisibleRepliesLimit,
      ),
    );
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
    // Preserve the user's vote/favorite state across reloads (e.g. pull-to-
    // refresh) so the buttons don't reset and allow duplicate actions. These
    // sets are keyed by item id, so carrying them over is safe even for a
    // different post. Upvotes are also merged from the persistent store so the
    // highlight survives an app restart / web reload.
    final persistedUpvoted = await ref
        .read(votesRepositoryProvider)
        .loadUpvoted();
    final preservedUpvoted = {...state.upvotedIds, ...persistedUpvoted};
    final preservedFavorited = state.favoritedIds;
    final preservedExpandedReplies = state.expandedRepliesIds;

    state = PostDetailState(
      currentPostId: id,
      post: const AsyncValue.loading(),
      upvotedIds: preservedUpvoted,
      favoritedIds: preservedFavorited,
      expandedRepliesIds: preservedExpandedReplies,
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
        preservedExpandedReplies,
        CommentSort.oldestFirst,
        settings.showDeadDeleted,
      );
      state = PostDetailState(
        currentPostId: id,
        post: AsyncValue.data(result),
        flatComments: flat,
        collapsedIds: collapsed,
        upvotedIds: preservedUpvoted,
        favoritedIds: preservedFavorited,
        expandedRepliesIds: preservedExpandedReplies,
      );
      // Confirm the favorite highlight against the server (source of truth)
      // without blocking the post render.
      unawaited(_seedFavoriteStatus(id));
    } catch (e, st) {
      state = PostDetailState(
        currentPostId: id,
        post: AsyncValue.error(e, st),
        upvotedIds: preservedUpvoted,
        favoritedIds: preservedFavorited,
        expandedRepliesIds: preservedExpandedReplies,
      );
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
      state.expandedRepliesIds,
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
      await ref.read(votesRepositoryProvider).saveUpvoted(newUpvoted);
      state = state.copyWith(upvotedIds: newUpvoted);
      _applyOptimisticScore(itemId, isUpvoted ? -1 : 1);
      return true;
    } catch (_) {
      return false;
    } finally {
      final voting = Set<int>.from(state.votingIds)..remove(itemId);
      state = state.copyWith(votingIds: voting);
    }
  }

  /// Optimistically nudges the displayed score for the main post header. Comment
  /// scores aren't shown, so only the post item is updated. A server re-fetch is
  /// avoided on purpose: HN caches scores (so it would return stale values) and
  /// re-fetching would rebuild the whole comment tree.
  void _applyOptimisticScore(int itemId, int delta) {
    final post = state.post;
    if (post is! AsyncData<PostDetail>) return;
    final detail = post.value;
    if (detail.item.id != itemId) return;
    final updated = detail.copyWith(
      item: detail.item.copyWith(score: (detail.item.score ?? 0) + delta),
    );
    state = state.copyWith(post: AsyncValue.data(updated));
  }

  /// Seeds the favorite highlight from the server so it reflects the user's real
  /// HN favorites on load (and survives restarts). Runs off the render path and
  /// is ignored if the user has navigated to a different post meanwhile.
  Future<void> _seedFavoriteStatus(int id) async {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isLoggedIn || authState.token == null) return;
    try {
      final favorited = await ref
          .read(favoriteRepositoryProvider)
          .isFavorited(itemId: id, token: authState.token ?? '');
      if (state.currentPostId != id) return;
      final newFavorited = Set<int>.from(state.favoritedIds);
      if (favorited) {
        newFavorited.add(id);
      } else {
        newFavorited.remove(id);
      }
      state = state.copyWith(favoritedIds: newFavorited);
    } catch (_) {}
  }

  Future<bool> toggleFavorite(int itemId) async {
    final authState = ref.read(authViewModelProvider);
    if (!authState.isLoggedIn || authState.token == null) return false;
    if (state.favoritingIds.contains(itemId)) return false;

    final isFavorited = state.favoritedIds.contains(itemId);

    state = state.copyWith(favoritingIds: {...state.favoritingIds, itemId});
    try {
      final repo = ref.read(favoriteRepositoryProvider);
      await repo.favorite(
        itemId: itemId,
        favorite: !isFavorited,
        token: authState.token ?? '',
      );

      final newFavorited = Set<int>.from(state.favoritedIds);
      if (isFavorited) {
        newFavorited.remove(itemId);
      } else {
        newFavorited.add(itemId);
      }
      state = state.copyWith(favoritedIds: newFavorited);
      return true;
    } catch (_) {
      return false;
    } finally {
      final favoriting = Set<int>.from(state.favoritingIds)..remove(itemId);
      state = state.copyWith(favoritingIds: favoriting);
    }
  }

  void toggleRepliesExpanded(int parentId) {
    final expanded = Set<int>.from(state.expandedRepliesIds);
    if (expanded.contains(parentId)) {
      expanded.remove(parentId);
    } else {
      expanded.add(parentId);
    }
    _reflatten(expandedRepliesIds: expanded);
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

  void _reflatten({
    Set<int>? collapsedIds,
    Set<int>? expandedRepliesIds,
    CommentSort? commentSort,
  }) {
    final post = state.post;
    if (post is! AsyncData<PostDetail>) return;
    final collapsed = collapsedIds ?? state.collapsedIds;
    final expandedReplies = expandedRepliesIds ?? state.expandedRepliesIds;
    final sort = commentSort ?? state.commentSort;
    final flat = flattenComments(
      post.value.comments,
      0,
      collapsed,
      expandedReplies,
      sort,
      _showDeadDeleted,
    );
    state = state.copyWith(
      collapsedIds: collapsed,
      expandedRepliesIds: expandedReplies,
      commentSort: sort,
      flatComments: flat,
    );
  }
}

final postDetailViewModelProvider =
    NotifierProvider<PostDetailViewModel, PostDetailState>(
      PostDetailViewModel.new,
    );
