import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_icons.dart';
import '../../domain/models/models.dart';
import '../../utils/auth_guard.dart';
import '../components/ember_app_bar.dart';
import '../components/ember_chip.dart';
import '../components/story_card.dart';
import '../view_models/feed_view_model.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedViewModelProvider);
    final viewModel = ref.read(feedViewModelProvider.notifier);

    final appBar = EmberAppBar(
      title: 'Ember HN',
      actions: [
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
  final Future<void> Function() onRefresh;
  final Future<void> Function(int) onMarkRead;
  final void Function(int) onUpvote;
  final Future<void> Function() onLoadMore;

  const _FeedBody({
    required this.feedState,
    required this.ref,
    required this.appBarHeight,
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
    final asyncFeed = widget.feedState.feeds[widget.feedState.selectedType];
    final isLoadingMore =
        widget.feedState.isLoadingMore[widget.feedState.selectedType] ?? false;

    if (asyncFeed == null) {
      return _buildSkeletonFeed();
    }

    return asyncFeed.when(
      loading: () => _buildSkeletonFeed(),
      error: (error, _) => _ErrorView(error: error, onRetry: widget.onRefresh),
      data: (result) => RefreshIndicator(
        onRefresh: widget.onRefresh,
        edgeOffset: widget.appBarHeight,
        child: ListView.builder(
          controller: _scrollController,
          scrollCacheExtent: const ScrollCacheExtent.pixels(500),
          padding: _listPadding(context),
          itemCount: result.items.length + (isLoadingMore ? 3 : 0),
          itemBuilder: (context, index) {
            if (index >= result.items.length) {
              return Skeletonizer(
                child: StoryCard(item: _fakeItem, rank: index + 1),
              );
            }

            final item = result.items[index];
            final rank = index + 1;

            return StoryCard(
              item: item,
              rank: rank,
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
      ),
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
