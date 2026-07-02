import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../data/repositories/feed_repository.dart';
import '../../domain/models/models.dart';
import 'auth_view_model.dart';
import 'settings_view_model.dart';

class FeedState {
  final FeedType selectedType;
  final Map<FeedType, AsyncValue<FeedResult>> feeds;
  final bool isRefreshing;
  final Set<int> upvotedIds;
  final Map<FeedType, int> currentPages;
  final Map<FeedType, bool> hasMore;
  final Map<FeedType, bool> isLoadingMore;

  const FeedState({
    this.selectedType = FeedType.top,
    this.feeds = const {},
    this.isRefreshing = false,
    this.upvotedIds = const {},
    this.currentPages = const {},
    this.hasMore = const {},
    this.isLoadingMore = const {},
  });

  FeedState copyWith({
    FeedType? selectedType,
    Map<FeedType, AsyncValue<FeedResult>>? feeds,
    bool? isRefreshing,
    Set<int>? upvotedIds,
    Map<FeedType, int>? currentPages,
    Map<FeedType, bool>? hasMore,
    Map<FeedType, bool>? isLoadingMore,
  }) {
    return FeedState(
      selectedType: selectedType ?? this.selectedType,
      feeds: feeds ?? this.feeds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      upvotedIds: upvotedIds ?? this.upvotedIds,
      currentPages: currentPages ?? this.currentPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FeedViewModel extends Notifier<FeedState> {
  @override
  FeedState build() {
    Future.microtask(_loadInitialFeed);
    return const FeedState();
  }

  Future<void> _loadInitialFeed() async {
    await ref.read(settingsViewModelProvider.notifier).ensureLoaded();
    final defaultType = FeedType.fromSettingsValue(
      ref.read(settingsViewModelProvider).defaultFeedType,
    );
    state = state.copyWith(selectedType: defaultType);
    await _loadFeed(defaultType);
  }

  void selectFeedType(FeedType type) {
    state = state.copyWith(selectedType: type);
    if (!state.feeds.containsKey(type)) {
      _loadFeed(type);
    }
  }

  Future<void> refresh() async {
    final type = state.selectedType;
    state = state.copyWith(
      isRefreshing: true,
      currentPages: {...state.currentPages, type: 0},
      hasMore: {...state.hasMore, type: true},
    );
    await _loadFeed(type, forceRefresh: true);
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> loadNextPage() async {
    final type = state.selectedType;
    if (state.isLoadingMore[type] == true) return;
    if (state.hasMore[type] == false) return;

    final currentPage = state.currentPages[type] ?? 0;
    final nextPage = currentPage + 1;

    state = state.copyWith(isLoadingMore: {...state.isLoadingMore, type: true});

    await _loadFeed(type, page: nextPage);

    state = state.copyWith(
      isLoadingMore: {...state.isLoadingMore, type: false},
    );
  }

  Future<void> _loadFeed(
    FeedType type, {
    int page = 0,
    bool forceRefresh = false,
  }) async {
    if (page == 0) {
      state = state.copyWith(
        feeds: {...state.feeds, type: const AsyncValue.loading()},
      );
    }

    try {
      final repo = ref.read(feedRepositoryProvider);
      final result = await repo.getFeed(
        type,
        page: page,
        forceRefresh: forceRefresh,
      );

      final existingFeed = page > 0 ? state.feeds[type] : null;
      final FeedResult merged;
      if (existingFeed is AsyncData<FeedResult> && page > 0) {
        merged = FeedResult(
          items: [...existingFeed.value.items, ...result.items],
          total: result.total,
          page: result.page,
          limit: result.limit,
          fromCache: result.fromCache,
          readIds: {...existingFeed.value.readIds, ...result.readIds},
        );
      } else {
        merged = result;
      }

      final moreAvailable = result.items.length >= result.limit;

      state = state.copyWith(
        feeds: {...state.feeds, type: AsyncValue.data(merged)},
        currentPages: {...state.currentPages, type: page},
        hasMore: {...state.hasMore, type: moreAvailable},
      );
    } catch (e, st) {
      if (page == 0) {
        state = state.copyWith(
          feeds: {...state.feeds, type: AsyncValue.error(e, st)},
        );
      }
    }
  }

  Future<bool> upvoteStory(int itemId) async {
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

      final type = state.selectedType;
      final feed = state.feeds[type];
      if (feed is AsyncData<FeedResult>) {
        final updatedItems = feed.value.items.map((item) {
          if (item.id == itemId) {
            final delta = isUpvoted ? -1 : 1;
            return item.copyWith(score: (item.score ?? 0) + delta);
          }
          return item;
        }).toList();

        state = state.copyWith(
          upvotedIds: newUpvoted,
          feeds: {
            ...state.feeds,
            type: AsyncValue.data(
              FeedResult(
                items: updatedItems,
                total: feed.value.total,
                page: feed.value.page,
                limit: feed.value.limit,
                fromCache: feed.value.fromCache,
                readIds: feed.value.readIds,
              ),
            ),
          },
        );
      } else {
        state = state.copyWith(upvotedIds: newUpvoted);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markRead(int storyId) async {
    final repo = ref.read(feedRepositoryProvider);
    await repo.markRead(storyId);
  }
}

final feedViewModelProvider = NotifierProvider<FeedViewModel, FeedState>(
  FeedViewModel.new,
);
