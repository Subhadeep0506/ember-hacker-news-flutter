import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/link_launcher.dart';
import '../components/ember_avatar_tile.dart';
import '../components/ember_icon_button.dart';
import '../components/search_story_card.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile_comment_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).loadUser(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Scaffold(
      body: Stack(
        children: [
          state.user.when(
            loading: () => _ProfileSkeleton(ember: ember),
            error: (error, _) => _ErrorView(
              error: error,
              onRetry: () => viewModel.loadUser(widget.username),
            ),
            data: (user) => RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(user: user, ember: ember),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      selectedTab: state.selectedTab,
                      onTabChanged: viewModel.selectTab,
                    ),
                  ),
                  if (state.selectedTab == 0)
                    _SubmissionsList(
                      submissions: state.submissions,
                      onRetry: viewModel.loadSubmissions,
                    )
                  else
                    _CommentsList(
                      comments: state.comments,
                      onRetry: viewModel.loadComments,
                    ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EmberIconButton(
                    icon: AppIcons.back,
                    tooltip: 'Back',
                    color: Colors.white,
                    background: Colors.black.withAlpha(45),
                    onTap: () => context.pop(),
                  ),
                  EmberIconButton(
                    icon: AppIcons.share,
                    tooltip: 'Share',
                    color: Colors.white,
                    background: Colors.black.withAlpha(45),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final HnUser user;
  final EmberThemeExtension? ember;

  const _ProfileHeader({required this.user, required this.ember});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent = ember?.accentOrange ?? colorScheme.primary;
    final joinDate = DateTime.fromMillisecondsSinceEpoch(
      user.created.toInt() * 1000,
    );
    final about = _stripHtml(user.about ?? '');

    return Column(
      children: [
        // Gradient banner with the avatar tile overlapping its lower edge.
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 152,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(accent, Colors.white, 0.15) ?? accent,
                        accent,
                      ],
                    ),
                  ),
                ),
              ),
              EmberAvatarTile(letter: user.id[0].toUpperCase()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.id,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => openLink(
            context,
            ref,
            'https://news.ycombinator.com/user?id=${user.id}',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'news.ycombinator.com',
                style: textTheme.bodySmall?.copyWith(
                  color: ember?.metadataColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                AppIcons.openExternal,
                size: 12,
                color: ember?.metadataColor,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: NumberFormat.decimalPattern().format(
                        user.karma.toInt(),
                      ),
                      label: 'KARMA',
                      ember: ember,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: DateFormat('d MMM y').format(joinDate),
                      label: 'JOINED',
                      ember: ember,
                    ),
                  ),
                ],
              ),
              if (about.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AboutCard(text: about, ember: ember),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final EmberThemeExtension? ember;

  const _StatCard({
    required this.value,
    required this.label,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ember?.storyCardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: ember?.accentOrange,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ember?.metadataColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final String text;
  final EmberThemeExtension? ember;

  const _AboutCard({required this.text, required this.ember});

  @override
  Widget build(BuildContext context) {
    final isLink = text.startsWith('http://') || text.startsWith('https://');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ember?.storyCardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.4,
          color: isLink ? ember?.commentAuthorColor : null,
        ),
      ),
    );
  }
}

/// Pinned underline tab bar (Submissions / Comments) for the profile scroll
/// view. Rendered via [SliverPersistentHeader] so it sticks below the banner.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  _TabBarDelegate({required this.selectedTab, required this.onTabChanged});

  static const _height = 52.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Container(
      color: ember?.scaffoldBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabItem(
            label: 'Submissions',
            selected: selectedTab == 0,
            onTap: () => onTabChanged(0),
            ember: ember,
          ),
          const SizedBox(width: 24),
          _TabItem(
            label: 'Comments',
            selected: selectedTab == 1,
            onTap: () => onTabChanged(1),
            ember: ember,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.selectedTab != selectedTab;
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EmberThemeExtension? ember;

  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ember?.accentOrange;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: selected ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionsList extends StatelessWidget {
  final AsyncValue<SearchResponse>? submissions;
  final VoidCallback onRetry;

  const _SubmissionsList({required this.submissions, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (submissions == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return submissions!.when(
      loading: () => const _SubmissionsSkeleton(),
      error: (error, _) => SliverToBoxAdapter(
        child: _ErrorView(error: error, onRetry: onRetry),
      ),
      data: (response) {
        if (response.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No submissions yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).extension<EmberThemeExtension>()?.metadataColor,
                  ),
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          sliver: SliverList.builder(
            itemCount: response.items.length,
            itemBuilder: (context, index) {
              final hit = response.items[index];
              return SearchStoryCard(
                hit: hit,
                onTap: () => context.push('/feeds/post/${hit.objectId}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _CommentsList extends StatelessWidget {
  final AsyncValue<UserCommentsResponse>? comments;
  final VoidCallback onRetry;

  const _CommentsList({required this.comments, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (comments == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return comments!.when(
      loading: () => const _CommentsSkeleton(),
      error: (error, _) => SliverToBoxAdapter(
        child: _ErrorView(error: error, onRetry: onRetry),
      ),
      data: (response) {
        if (response.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No comments yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).extension<EmberThemeExtension>()?.metadataColor,
                  ),
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          sliver: SliverList.builder(
            itemCount: response.items.length,
            itemBuilder: (context, index) {
              final comment = response.items[index];
              return ProfileCommentCard(
                comment: comment,
                onTap: () => context.push('/feeds/post/${comment.storyId}'),
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
              AppIcons.error,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
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

// Placeholder data used to shape the skeleton loading state.
const _fakeUser = HnUser(
  id: 'username',
  created: 1300000000,
  karma: 12345,
  about:
      'A short placeholder bio that spans a line or two while the real '
      'profile loads in the background.',
);

const _fakeStoryHit = AlgoliaStoryHit(
  objectId: '0',
  title: 'This is a placeholder submission title for the skeleton state',
  url: 'https://example.com/article',
  author: 'username',
  points: 128,
  numComments: 42,
  createdAt: '',
  createdAtI: 1719700000,
);

const _fakeCommentHit = AlgoliaCommentHit(
  objectId: '0',
  author: 'username',
  commentText:
      'This is a placeholder comment body used for the skeleton '
      'loading state, spanning a couple of lines of text.',
  storyId: 0,
  storyTitle: 'Placeholder story title for the skeleton state',
  parentId: 0,
  createdAt: '',
  createdAtI: 1719700000,
  points: 12,
);

/// Full-screen skeleton shown while the user's details are loading. The header
/// and tab bar stay fixed; only the placeholder feed list occupies the
/// scrollable region, matching the loaded layout.
class _ProfileSkeleton extends StatelessWidget {
  final EmberThemeExtension? ember;

  const _ProfileSkeleton({required this.ember});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Skeletonizer(
            child: _ProfileHeader(user: _fakeUser, ember: ember),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(selectedTab: 0, onTabChanged: (_) {}),
        ),
        const _SubmissionsSkeleton(),
      ],
    );
  }
}

class _SubmissionsSkeleton extends StatelessWidget {
  const _SubmissionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      child: SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, _) => const SearchStoryCard(hit: _fakeStoryHit),
      ),
    );
  }
}

class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      child: SliverList.builder(
        itemCount: 6,
        itemBuilder: (_, _) =>
            const ProfileCommentCard(comment: _fakeCommentHit),
      ),
    );
  }
}
