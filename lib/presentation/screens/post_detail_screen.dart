import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_icons.dart';
import '../../domain/models/models.dart';
import '../../utils/auth_guard.dart';
import '../view_models/post_detail_view_model.dart';
import '../widgets/comment_dialog.dart';
import '../widgets/comment_list.dart';
import '../widgets/post_action_bar.dart';
import '../widgets/post_header.dart';
import '../widgets/sticky_post_header.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final int itemId;

  const PostDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postDetailViewModelProvider.notifier).loadPost(widget.itemId);
    });
  }

  Widget _buildSkeletonPost() {
    const fakeItem = ItemResponse(
      id: 0,
      type: 'story',
      time: 1719700000,
      title: 'This is a placeholder title for loading skeleton state here',
      by: 'username',
      score: 142,
      descendants: 87,
      url: 'https://example.com/article',
    );

    return Skeletonizer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeader(item: fakeItem),
            const PostActionBar(),
            const Divider(),
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comment author · 2h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a placeholder comment body text for the skeleton loading state display.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpvote(int itemId) async {
    final loggedIn = await ensureLoggedIn(context, ref);
    if (!loggedIn) return;
    ref.read(postDetailViewModelProvider.notifier).upvoteItem(itemId);
  }

  Future<void> _handleReply(
    int parentId, {
    String? parentAuthor,
    String? parentText,
  }) async {
    final loggedIn = await ensureLoggedIn(context, ref);
    if (!loggedIn || !mounted) return;

    final result = await showCommentDialog(
      context,
      ref,
      parentId: parentId,
      parentAuthor: parentAuthor,
      parentText: parentText,
    );
    if (result == true && mounted) {
      ref.read(postDetailViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailViewModelProvider);
    final viewModel = ref.read(postDetailViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Discussion'),
      ),
      body: state.post.when(
        loading: () => _buildSkeletonPost(),
        error: (error, _) =>
            _ErrorView(error: error, onRetry: viewModel.refresh),
        data: (postDetail) => RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            slivers: [
              if (postDetail.item.url != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: PostHeroImage(articleUrl: postDetail.item.url ?? ''),
                  ),
                ),
              SliverStickyPostHeader(
                item: postDetail.item,
                width: MediaQuery.sizeOf(context).width,
                onUpvote: () => _handleUpvote(postDetail.item.id),
                onReply: () => _handleReply(
                  postDetail.item.id,
                  parentAuthor: postDetail.item.by,
                  parentText: postDetail.item.text ?? postDetail.item.title,
                ),
              ),
              if (state.flatComments.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No comments yet')),
                  ),
                )
              else
                CommentList(
                  comments: state.flatComments,
                  collapsedIds: state.collapsedIds,
                  upvotedIds: state.upvotedIds,
                  onToggleCollapse: viewModel.toggleCollapse,
                  onUpvote: (id) => _handleUpvote(id),
                  onReply: (id) {
                    final comment = state.flatComments
                        .where((fc) => fc.comment.id == id)
                        .firstOrNull;
                    _handleReply(
                      id,
                      parentAuthor: comment?.comment.by,
                      parentText: comment?.comment.text,
                    );
                  },
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
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
              AppIcons.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load post',
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
