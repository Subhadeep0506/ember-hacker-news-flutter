import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/di/providers.dart';
import 'cross_platform_image.dart' as platform_image;

class StoryThumbnail extends ConsumerWidget {
  final String? url;

  const StoryThumbnail({super.key, required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleUrl = url;
    if (articleUrl == null || articleUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final asyncImage = ref.watch(ogImageProvider(articleUrl));

    return asyncImage.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Skeleton.leaf(
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(60),
            ),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (imageUrl) {
        if (imageUrl == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: platform_image.buildPlatformImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorWidget: (_, url, error) {
                log(
                  'Thumbnail failed for $url: $error',
                  name: 'StoryThumbnail',
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}
