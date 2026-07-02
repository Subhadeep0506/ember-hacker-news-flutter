import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/theme/app_icons.dart';
import '../../domain/models/models.dart';
import '../../utils/auth_guard.dart';
import '../components/ember_app_bar.dart';
import '../components/ember_chip.dart';
import '../components/story_card.dart';
import '../view_models/feed_view_model.dart';
import '../view_models/settings_view_model.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedViewModelProvider);
    final viewModel = ref.read(feedViewModelProvider.notifier);
    final settings = ref.watch(settingsViewModelProvider);

    final appBar = EmberAppBar(
      title: 'Home',
      actions: [
        IconButton(
          icon: const Icon(AppIcons.search),
          onPressed: () => context.go('/search'),
        ),
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: viewModel.refresh,
        ),
      ],
      bottom: _FeedTypeTabBar(
        selectedType: feedState.selectedType,
        onSelected: viewModel.selectFeedType,
      ),
      bottomHeight: 48,
    );

    return Scaffold(
      body: Stack(
        children: [
          _FeedBody(
            feedState: feedState,
            ref: ref,
            appBarHeight: appBar.totalHeight(context),
            showDomainBadges: settings.showDomainBadges,
            hideJobPosts: settings.hideJobPosts,
            markReadOnScroll: settings.markReadOnScroll,
            onRefresh: viewModel.refresh,
            onMarkRead: viewModel.markRead,
            onUpvote: (itemId) async {
              final loggedIn = await ensureLoggedIn(context, ref);
              if (!loggedIn) return;
              viewModel.upvoteStory(itemId);
            },
            onLoadMore: viewModel.loadNextPage,
          ),
          appBar,
        ],
      ),
    );
  }
}

class _FeedTypeTabBar extends StatelessWidget {
  final FeedType selectedType;
  final ValueChanged<FeedType> onSelected;

  const _FeedTypeTabBar({required this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: FeedType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: EmberChip(
              label: type.displayName,
              selected: type == selectedType,
              onTap: () => onSelected(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeedBody extends StatefulWidget {
  final FeedState feedState;
  final WidgetRef ref;
  final double appBarHeight;
  final bool showDomainBadges;
  final bool hideJobPosts;
  final bool markReadOnScroll;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int) onMarkRead;
  final void Function(int) onUpvote;
  final Future<void> Function() onLoadMore;

  const _FeedBody({
    required this.feedState,
    required this.ref,
    required this.appBarHeight,
    required this.showDomainBadges,
    required this.hideJobPosts,
    required this.markReadOnScroll,
    required this.onRefresh,
    required this.onMarkRead,
    required this.onUpvote,
    required this.onLoadMore,
  });

  @override
  State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final _scrollController = ScrollController();
  final _autoMarked = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  static const _fakeItem = HnItem(
    id: 0,
    type: 'story',
    time: 1719700000,
    title: 'This is a placeholder title for the skeleton loading state',
    by: 'username',
    score: 142,
    descendants: 87,
    url: 'https://example.com/article',
  );

  EdgeInsets _listPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 64;
    return EdgeInsets.only(
      top: widget.appBarHeight + 4,
      bottom: bottomInset + 4,
    );
  }

  Widget _buildSkeletonFeed() {
    return Skeletonizer(
      child: Builder(
        builder: (context) => ListView.builder(
          padding: _listPadding(context),
          itemCount: 10,
          itemBuilder: (_, index) =>
              StoryCard(item: _fakeItem, rank: index + 1),
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = widget.feedState.selectedType;
    final asyncFeed = widget.feedState.feeds[selectedType];
    final isLoadingMore = widget.feedState.isLoadingMore[selectedType] ?? false;

    if (asyncFeed == null) {
      return _buildSkeletonFeed();
    }

    return asyncFeed.when(
      loading: () => _buildSkeletonFeed(),
      error: (error, _) => _ErrorView(error: error, onRetry: widget.onRefresh),
      data: (result) {
        final items = widget.hideJobPosts && selectedType != FeedType.job
            ? result.items.where((i) => i.type != 'job').toList()
            : result.items;

        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          edgeOffset: widget.appBarHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollCacheExtent: const ScrollCacheExtent.pixels(500),
            padding: _listPadding(context),
            itemCount: items.length + (isLoadingMore ? 3 : 0),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return Skeletonizer(
                  child: StoryCard(item: _fakeItem, rank: index + 1),
                );
              }

              final item = items[index];
              final rank = index + 1;

              if (widget.markReadOnScroll &&
                  !result.readIds.contains(item.id) &&
                  _autoMarked.add(item.id)) {
                widget.onMarkRead(item.id);
              }

              return StoryCard(
                item: item,
                rank: rank,
                showDomain: widget.showDomainBadges,
                isRead: result.readIds.contains(item.id),
                isUpvoted: widget.feedState.upvotedIds.contains(item.id),
                onTap: () {
                  widget.onMarkRead(item.id);
                  context.go('/feeds/post/${item.id}');
                },
                onUpvote: () => widget.onUpvote(item.id),
              );
            },
          ),
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
              AppIcons.wifiOff,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load stories',
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
