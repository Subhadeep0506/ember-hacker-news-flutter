import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_icons.dart';
import '../../config/di/providers.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/time_ago.dart';
import '../../utils/url_utils.dart';
import '../components/cross_platform_image.dart' as platform_image;
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
          Text(
            item.title ?? '',
            style: postTitleStyle(textTheme),
          ),
          if (domain != null) ...[
            const SizedBox(height: 8),
            _DomainRow(domain: domain, ember: ember, textTheme: textTheme),
          ],
          const SizedBox(height: 12),
          _MetadataRow(item: item, ember: ember, textTheme: textTheme),
          if (item.url != null) ...[
            const SizedBox(height: 16),
            _OpenArticleButton(url: item.url, ember: ember),
          ],
        ],
      ),
    );
  }
}

/// Shared title text style so measurement and rendering stay in sync.
TextStyle? postTitleStyle(TextTheme textTheme) => textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.3,
    );

/// Hero image for a post, resolved via [ogImageProvider] with a domain-aware
/// fallback placeholder. Public so it can be used as a standalone sliver.
class PostHeroImage extends ConsumerWidget {
  final String articleUrl;

  const PostHeroImage({super.key, required this.articleUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final domain = extractDomain(articleUrl);
    final asyncImage = ref.watch(ogImageProvider(articleUrl));

    return asyncImage.when(
      loading: () => _FallbackPlaceholder(
        domain: domain,
        ember: ember,
        showLoading: true,
      ),
      error: (_, _) => _FallbackPlaceholder(domain: domain, ember: ember),
      data: (imageUrl) {
        if (imageUrl == null) {
          return _FallbackPlaceholder(domain: domain, ember: ember);
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outlineVariant.withAlpha(40),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: platform_image.buildPlatformImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorWidget: (_, url, error) {
                log('Hero image failed for $url: $error',
                    name: 'PostHeader');
                return _FallbackPlaceholder(domain: domain, ember: ember);
              },
            ),
          ),
        );
      },
    );
  }
}

class _FallbackPlaceholder extends StatelessWidget {
  final String? domain;
  final EmberThemeExtension? ember;
  final bool showLoading;

  const _FallbackPlaceholder({
    required this.domain,
    required this.ember,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ember?.accentOrange.withAlpha(100),
                ),
              )
            else
              Icon(
                AppIcons.imageError,
                size: 32,
                color: ember?.metadataColor.withAlpha(100),
              ),
            if (domain != null) ...[
              const SizedBox(height: 8),
              Text(
                domain ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: ember?.domainColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  final String domain;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _DomainRow({
    required this.domain,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.network(
          'https://www.google.com/s2/favicons?domain=$domain&sz=32',
          width: 16,
          height: 16,
          errorBuilder: (_, _, _) =>
              Icon(AppIcons.globe, size: 16, color: ember?.domainColor),
        ),
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

class _OpenArticleButton extends StatelessWidget {
  final String? url;
  final EmberThemeExtension? ember;

  const _OpenArticleButton({required this.url, required this.ember});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        if (url != null) {
          launchUrl(Uri.parse(url ?? ''), mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(AppIcons.openExternal, size: 16),
      label: const Text('Open article'),
      style: OutlinedButton.styleFrom(
        foregroundColor: ember?.accentOrange,
        side: BorderSide(color: ember?.accentOrange ?? Colors.orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
