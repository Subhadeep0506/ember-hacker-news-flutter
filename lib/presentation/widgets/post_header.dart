import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_icons.dart';
import '../../config/di/providers.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/link_launcher.dart';
import '../../utils/time_ago.dart';
import '../../utils/url_utils.dart';
import '../components/cross_platform_image.dart' as platform_image;
import '../components/ember_domain_avatar.dart';
import '../components/ember_gradient_hero.dart';
import '../components/tappable_username.dart';

/// Full post header: hero image stacked above the textual content.
///
/// Retained for the loading skeleton and any non-collapsing usage. The detail
/// screen composes [PostHeroImage] and [PostHeaderContent] separately so the
/// image can scroll away while the content pins.
class PostHeader extends StatelessWidget {
  final ItemResponse item;

  const PostHeader({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.url != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: PostHeroImage(articleUrl: item.url ?? ''),
          ),
        ],
        PostHeaderContent(item: item),
      ],
    );
  }
}

/// Textual portion of the post header (title, domain, metadata, open button).
///
/// Contains no image so it can be pinned by the collapsing sticky header.
class PostHeaderContent extends StatelessWidget {
  final ItemResponse item;

  const PostHeaderContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final domain = extractDomain(item.url);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title ?? '', style: postTitleStyle(textTheme)),
          if (domain != null) ...[
            const SizedBox(height: 8),
            _DomainRow(
              domain: domain,
              url: item.url,
              ember: ember,
              textTheme: textTheme,
            ),
          ],
          const SizedBox(height: 12),
          _MetadataRow(item: item, ember: ember, textTheme: textTheme),
          if (item.url != null) ...[
            const SizedBox(height: 16),
            _OpenArticleButton(url: item.url),
          ],
        ],
      ),
    );
  }
}

/// Shared title text style so measurement and rendering stay in sync.
TextStyle? postTitleStyle(TextTheme textTheme) =>
    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.3);

/// Hero image for a post, resolved via [ogImageProvider] with a domain-aware
/// fallback placeholder. Public so it can be used as a standalone sliver.
class PostHeroImage extends ConsumerWidget {
  final String articleUrl;

  /// When true the image fills its box edge-to-edge with no rounding or border,
  /// used behind a [SliverAppBar]'s floating controls on the detail screen.
  final bool fullBleed;

  const PostHeroImage({
    super.key,
    required this.articleUrl,
    this.fullBleed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final asyncImage = ref.watch(ogImageProvider(articleUrl));
    final height = fullBleed ? double.infinity : 180.0;

    return asyncImage.when(
      loading: () => _LoadingPlaceholder(ember: ember, fullBleed: fullBleed),
      error: (_, _) =>
          EmberGradientHero(seed: articleUrl.hashCode, fullBleed: fullBleed),
      data: (imageUrl) {
        if (imageUrl == null) {
          return EmberGradientHero(
            seed: articleUrl.hashCode,
            fullBleed: fullBleed,
          );
        }

        final image = platform_image.buildPlatformImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorWidget: (_, url, error) {
            log('Hero image failed for $url: $error', name: 'PostHeader');
            return EmberGradientHero(
              seed: articleUrl.hashCode,
              fullBleed: fullBleed,
            );
          },
        );

        if (fullBleed) {
          // Dissolve the image's lower edge into the content-sheet colour so it
          // blends into the sheet below instead of ending in a hard seam.
          return SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                _HeroBottomFade(ember: ember),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image,
          ),
        );
      },
    );
  }
}

/// Gradient scrim over the hero's lower edge, fading to the scaffold/content
/// sheet colour so a full-bleed image blends into the sheet below with no seam.
class _HeroBottomFade extends StatelessWidget {
  final EmberThemeExtension? ember;

  const _HeroBottomFade({required this.ember});

  @override
  Widget build(BuildContext context) {
    final fade =
        ember?.scaffoldBackground ?? Theme.of(context).scaffoldBackgroundColor;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fade.withValues(alpha: 0), fade],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Neutral placeholder shown while the OG image is being fetched. Kept subtle
/// (not the gradient) so we don't flash a mesh gradient and then swap in a real
/// image once the fetch resolves.
class _LoadingPlaceholder extends StatelessWidget {
  final EmberThemeExtension? ember;
  final bool fullBleed;

  const _LoadingPlaceholder({required this.ember, this.fullBleed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullBleed ? double.infinity : 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (ember?.accentOrange ?? Colors.orange).withAlpha(25),
            (ember?.accentOrange ?? Colors.orange).withAlpha(8),
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ember?.accentOrange.withAlpha(100),
          ),
        ),
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  final String domain;
  final String? url;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _DomainRow({
    required this.domain,
    required this.url,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Reuse EmberDomainAvatar so the favicon loads via a platform-safe image
        // (avoids the web CORS failure that Image.network hits here).
        EmberDomainAvatar(url: url, size: 16),
        const SizedBox(width: 6),
        Text(
          '($domain)',
          style: textTheme.bodySmall?.copyWith(color: ember?.domainColor),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final ItemResponse item;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _MetadataRow({
    required this.item,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
      fontSize: 13,
    );
    final time = timeAgo(item.time);

    return Row(
      children: [
        Icon(AppIcons.upvote, size: 18, color: ember?.upvoteColor),
        Text('${item.score ?? 0}', style: metaStyle),
        const SizedBox(width: 12),
        Icon(AppIcons.comment, size: 14, color: ember?.metadataColor),
        const SizedBox(width: 4),
        Text('${item.descendants ?? 0}', style: metaStyle),
        if (time.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(time, style: metaStyle),
        ],
        const SizedBox(width: 12),
        Icon(AppIcons.user, size: 14, color: ember?.metadataColor),
        const SizedBox(width: 4),
        TappableUsername(username: item.by, style: metaStyle),
      ],
    );
  }
}

class _OpenArticleButton extends ConsumerWidget {
  final String? url;

  const _OpenArticleButton({required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () {
        final target = url;
        if (target != null) {
          openLink(context, ref, target);
        }
      },
      icon: const Icon(AppIcons.openExternal, size: 16),
      label: const Text('Open article'),
    );
  }
}
