import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/theme/app_icons.dart';
import '../../domain/models/models.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/auth_guard.dart';
import '../../utils/link_launcher.dart';
import '../components/ember_gradient_hero.dart';
import '../components/ember_icon_button.dart';
import '../view_models/post_detail_view_model.dart';
import '../view_models/settings_view_model.dart';
import '../widgets/comment_dialog.dart';
import '../widgets/comment_list.dart';
import '../widgets/comment_tile.dart';
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

    final width = MediaQuery.sizeOf(context).width;

    return Skeletonizer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 hero placeholder mirroring the loaded full-bleed hero.
            Skeleton.leaf(
              child: Container(
                width: double.infinity,
                height: width * 9 / 16,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const PostHeaderContent(item: fakeItem),
            const PostActionBar(),
            // Comment placeholders using the real avatar/bubble/rail layout.
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  SkeletonCommentTile(depth: 0, hasChildRail: true),
                  SkeletonCommentTile(depth: 1, rails: [false]),
                  SkeletonCommentTile(depth: 0, hasChildRail: true),
                  SkeletonCommentTile(depth: 1, rails: [true]),
                  SkeletonCommentTile(depth: 1, rails: [false]),
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
      ref.read(postDetailViewModelProvider.notifier).reloadAfterReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailViewModelProvider);
    final viewModel = ref.read(postDetailViewModelProvider.notifier);
    final settings = ref.watch(settingsViewModelProvider);
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = settings.serifForArticles
        ? GoogleFonts.notoSerif(textStyle: textTheme.bodyMedium)
        : textTheme.bodyMedium;

    return Scaffold(
      body: state.post.when(
        loading: () => _WithBackButton(child: _buildSkeletonPost()),
        error: (error, _) => _WithBackButton(
          child: _ErrorView(error: error, onRetry: viewModel.refresh),
        ),
        data: (postDetail) => RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            slivers: [
              _PostHeroAppBar(
                url: postDetail.item.url,
                seed: postDetail.item.id,
              ),
              SliverStickyPostHeader(
                item: postDetail.item,
                width: MediaQuery.sizeOf(context).width,
                isUpvoted: state.upvotedIds.contains(postDetail.item.id),
                isVoting: state.votingIds.contains(postDetail.item.id),
                commentSort: state.commentSort,
                onSortNewest: () =>
                    viewModel.setCommentSort(CommentSort.newestFirst),
                onSortOldest: () =>
                    viewModel.setCommentSort(CommentSort.oldestFirst),
                onCollapseAll: viewModel.collapseAll,
                onExpandAll: viewModel.expandAll,
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
                  votingIds: state.votingIds,
                  opUsername: postDetail.item.by,
                  highlightOP: settings.highlightOP,
                  bodyTextStyle: bodyStyle,
                  onToggleCollapse: viewModel.toggleCollapse,
                  onUpvote: (id) => _handleUpvote(id),
                  onOpenLink: (url) => openLink(context, ref, url),
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
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom:
                      32 +
                      kBottomNavigationBarHeight +
                      MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Collapsing hero app bar: a 16:9 hero fills the expanded area with floating
/// circular back/share controls that stay pinned as the header collapses. Posts
/// with a URL show the OG image (falling back to a gradient); text-only posts
/// show a deterministic gradient hero seeded from the post id.
class _PostHeroAppBar extends StatelessWidget {
  final String? url;
  final int seed;

  const _PostHeroAppBar({required this.url, required this.seed});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final heroUrl = url;
    final hasArticle = heroUrl != null && heroUrl.isNotEmpty;
    const scrim = Color(0x40000000);

    final surface = ember?.scaffoldBackground ?? Colors.black;
    // 16:9 of the screen width so the hero reads as a proper cover image.
    final expandedHeight = MediaQuery.sizeOf(context).width * 9 / 16;

    return SliverAppBar(
      pinned: true,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      expandedHeight: expandedHeight,
      leadingWidth: 60,
      leading: Center(
        child: EmberIconButton(
          icon: AppIcons.back,
          tooltip: 'Back',
          color: Colors.white,
          background: scrim,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        EmberIconButton(
          icon: AppIcons.share,
          tooltip: 'Share',
          color: Colors.white,
          background: scrim,
          onTap: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasArticle
            ? PostHeroImage(articleUrl: heroUrl, fullBleed: true)
            : EmberGradientHero(seed: seed, fullBleed: true),
      ),
      // A scaffold-coloured strip with rounded top corners, pinned at the bar's
      // bottom so it laps over the hero's lower edge as a content sheet. Using
      // `bottom` (not a clip) keeps the curve visible in both expanded and
      // collapsed states and works on web, where the OG image is an unclippable
      // HTML platform view.
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}

/// Wraps a non-scrolling child (skeleton / error) with a floating back button,
/// since those states don't render the [SliverAppBar].
class _WithBackButton extends StatelessWidget {
  final Widget child;

  const _WithBackButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: EmberIconButton(
              icon: AppIcons.back,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
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
