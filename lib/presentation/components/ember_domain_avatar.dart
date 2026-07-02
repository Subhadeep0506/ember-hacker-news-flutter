import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';
import '../../utils/url_utils.dart';
import 'cross_platform_image.dart' as platform_image;

/// Small circular favicon for a story's source domain.
///
/// Loads the icon from Google's favicon service via [buildPlatformImage] (which
/// routes through an `<img>` element on web to avoid CORS). Falls back to a
/// tinted tile with the domain's first letter when there is no URL or the icon
/// fails to load.
class EmberDomainAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const EmberDomainAvatar({super.key, required this.url, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final favicon = faviconUrl(url, size: 64);

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: favicon == null
            ? _fallback(context)
            : platform_image.buildPlatformImage(
                imageUrl: favicon,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _fallback(context),
              ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final domain = extractDomain(url);
    final letter = (domain != null && domain.isNotEmpty)
        ? domain.characters.first.toUpperCase()
        : '?';

    return Container(
      color: ember?.accentOrange.withAlpha(38),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ember?.accentOrange,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
