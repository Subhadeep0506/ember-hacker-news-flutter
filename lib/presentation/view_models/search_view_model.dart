import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/di/providers.dart';
import '../../domain/models/models.dart';
import 'settings_view_model.dart';

enum SearchSort {
  relevance,
  date;

  String get apiValue => name;

  String get displayName {
    switch (this) {
      case SearchSort.relevance:
        return 'Relevance';
      case SearchSort.date:
        return 'Newest';
    }
  }

  /// Maps the persisted "Default sort" setting ('relevance' / 'newest').
  static SearchSort fromSettingsValue(String value) =>
      value == 'newest' ? SearchSort.date : SearchSort.relevance;
}

class SearchState {
  final String query;
  final SearchSort sort;
  final AsyncValue<SearchResponse>? results;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const SearchState({
    this.query = '',
    this.sort = SearchSort.relevance,
    this.results,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  SearchState copyWith({
    String? query,
    SearchSort? sort,
    AsyncValue<SearchResponse>? results,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearResults = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      sort: sort ?? this.sort,
      results: clearResults ? null : (results ?? this.results),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SearchViewModel extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    Future.microtask(_applyDefaultSort);
    return const SearchState();
  }

  Future<void> _applyDefaultSort() async {
    await ref.read(settingsViewModelProvider.notifier).ensureLoaded();
    // Only adopt the default before the user has run or re-sorted a search.
    if (state.query.isEmpty && state.results == null) {
      state = state.copyWith(
        sort: SearchSort.fromSettingsValue(
          ref.read(settingsViewModelProvider).defaultSort,
        ),
      );
    }
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(clearResults: true);
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _executeSearch(),
    );
  }

  void searchImmediately() {
    _debounceTimer?.cancel();
    if (state.query.trim().isNotEmpty) _executeSearch();
  }

  void updateSort(SearchSort sort) {
    if (sort == state.sort) return;
    state = state.copyWith(sort: sort);
    if (state.query.trim().isNotEmpty) _executeSearch();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    if (state.query.trim().isEmpty) return;

    await _executeSearch(page: state.currentPage + 1);
  }

  Future<void> _executeSearch({int page = 0}) async {
    if (page == 0) {
      state = state.copyWith(
        results: const AsyncValue.loading(),
        currentPage: 0,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final repo = ref.read(searchRepositoryProvider);
      final response = await repo.search(
        state.query.trim(),
        sort: state.sort.apiValue,
        page: page,
      );

      final SearchResponse merged;
      if (page > 0 && state.results is AsyncData<SearchResponse>) {
        final existing = (state.results as AsyncData<SearchResponse>).value;
        merged = SearchResponse(
          items: [...existing.items, ...response.items],
          total: response.total,
          page: response.page,
          limit: response.limit,
          totalPages: response.totalPages,
        );
      } else {
        merged = response;
      }

      state = state.copyWith(
        results: AsyncValue.data(merged),
        currentPage: page,
        hasMore: page < response.totalPages - 1,
        isLoadingMore: false,
      );
    } catch (e, st) {
      if (page == 0) {
        state = state.copyWith(
          results: AsyncValue.error(e, st),
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    }
  }
}

final searchViewModelProvider =
    NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);
