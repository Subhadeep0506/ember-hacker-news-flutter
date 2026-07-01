import 'dart:developer';

import '../../domain/models/models.dart';
import '../api/feed_api_service.dart';
import '../local/read_history_dao.dart';
import '../local/story_dao.dart';

class FeedResult {
  final List<HnItem> items;
  final int total;
  final int page;
  final int limit;
  final bool fromCache;
  final Set<int> readIds;

  const FeedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.fromCache,
    required this.readIds,
  });
}

class FeedRepository {
  final FeedApiService _apiService;
  final StoryDao _storyDao;
  final ReadHistoryDao _readHistoryDao;

  FeedRepository(this._apiService, this._storyDao, this._readHistoryDao);

  Future<FeedResult> getFeed(
    FeedType type, {
    int page = 0,
    int limit = 30,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _storyDao.getCachedFeed(type, page);
      if (cached != null) {
        log('Cache hit for ${type.apiValue} page $page', name: 'FeedRepo');
        final readIds = await _readHistoryDao.getReadIds(
          cached.map((s) => s.id).toList(),
        );
        return FeedResult(
          items: cached,
          total: cached.length,
          page: page,
          limit: limit,
          fromCache: true,
          readIds: readIds,
        );
      }
    }

    try {
      final response = await _apiService.getFeed(
        type,
        page: page,
        limit: limit,
      );

      await _storyDao.insertStories(response.items);
      await _storyDao.cacheFeedPage(
        type,
        page,
        response.items.map((s) => s.id).toList(),
      );

      final readIds = await _readHistoryDao.getReadIds(
        response.items.map((s) => s.id).toList(),
      );

      return FeedResult(
        items: response.items,
        total: response.total,
        page: response.page,
        limit: response.limit,
        fromCache: false,
        readIds: readIds,
      );
    } catch (e) {
      log('Network error, falling back to stale cache: $e', name: 'FeedRepo');
      final staleCache = await _storyDao.getCachedFeed(
        type,
        page,
        maxAge: const Duration(days: 7),
      );
      if (staleCache != null) {
        final readIds = await _readHistoryDao.getReadIds(
          staleCache.map((s) => s.id).toList(),
        );
        return FeedResult(
          items: staleCache,
          total: staleCache.length,
          page: page,
          limit: limit,
          fromCache: true,
          readIds: readIds,
        );
      }
      rethrow;
    }
  }

  Future<void> markRead(int storyId) async {
    await _readHistoryDao.markRead(storyId);
  }
}
