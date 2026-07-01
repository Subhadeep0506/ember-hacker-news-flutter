import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../components/ember_chip.dart';
import '../components/search_story_card.dart';
import '../view_models/search_view_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchViewModelProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final viewModel = ref.read(searchViewModelProvider.notifier);
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          _SearchField(
            controller: _searchController,
            ember: ember,
            onChanged: viewModel.updateQuery,
            onSubmitted: viewModel.searchImmediately,
            onClear: () {
              _searchController.clear();
              viewModel.updateQuery('');
            },
          ),
          _SortChips(
            selectedSort: state.sort,
            onSortChanged: viewModel.updateSort,
          ),
          Expanded(
            child: _SearchResults(
              state: state,
              scrollController: _scrollController,
              onRefresh: viewModel.searchImmediately,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final EmberThemeExtension? ember;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.ember,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          hintText: 'Search stories...',
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(AppIcons.close),
                onPressed: onClear,
              );
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  final SearchSort selectedSort;
  final ValueChanged<SearchSort> onSortChanged;

  const _SortChips({
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: SearchSort.values.map((sort) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: EmberChip(
              label: sort.displayName,
              selected: sort == selectedSort,
              onTap: () => onSortChanged(sort),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  const _SearchResults({
    required this.state,
    required this.scrollController,
    required this.onRefresh,
  });

  static const _fakeHit = AlgoliaStoryHit(
    objectId: '0',
    title: 'This is a placeholder title for the skeleton loading state display',
    author: 'username',
    points: 142,
    numComments: 87,
    createdAt: '',
    createdAtI: 1719700000,
    url: 'https://example.com/article',
  );

  @override
  Widget build(BuildContext context) {
    final results = state.results;

    if (results == null) {
      return _EmptyHint(query: state.query);
    }

    return results.when(
      loading: () => Skeletonizer(
        child: ListView.builder(
          scrollCacheExtent: const ScrollCacheExtent.pixels(500),
          padding: EdgeInsets.only(
            top: 4,
            bottom: MediaQuery.of(context).padding.bottom + 68,
          ),
          itemCount: 8,
          itemBuilder: (_, _) => const SearchStoryCard(hit: _fakeHit),
        ),
      ),
      error: (error, _) => _ErrorView(error: error, onRetry: onRefresh),
      data: (response) {
        if (response.items.isEmpty) {
          return Center(
            child: Text(
              'No results found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .extension<EmberThemeExtension>()
                    ?.metadataColor,
              ),
            ),
          );
        }
        return _ResultsList(
          items: response.items,
          isLoadingMore: state.isLoadingMore,
          scrollController: scrollController,
        );
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String query;

  const _EmptyHint({required this.query});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.search, size: 48, color: ember?.metadataColor),
          const SizedBox(height: 16),
          Text(
            'Search Hacker News',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ember?.metadataColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<AlgoliaStoryHit> items;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const _ResultsList({
    required this.items,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      padding: EdgeInsets.only(
        top: 4,
        bottom: MediaQuery.of(context).padding.bottom + 68,
      ),
      itemCount: items.length + (isLoadingMore ? 3 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Skeletonizer(
            child: SearchStoryCard(hit: _SearchResults._fakeHit),
          );
        }
        final hit = items[index];
        return SearchStoryCard(
          hit: hit,
          onTap: () => context.go('/search/post/${hit.objectId}'),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Search failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(AppIcons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
