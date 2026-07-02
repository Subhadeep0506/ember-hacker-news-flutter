import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';

class EmberAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  final double bottomHeight;

  const EmberAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.bottomHeight = 0,
  });

  double totalHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top + kToolbarHeight + bottomHeight;
  }

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    // Web cannot blur behind native HTML image layers, so use an opaque
    // surface there; mobile gets a real frosted-glass BackdropFilter.
    final surface = ember?.scaffoldBackground ?? colorScheme.surface;
    final decoration = BoxDecoration(
      color: kIsWeb ? surface : surface.withAlpha(200),
      border: Border(
        bottom: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
    );

    final content = Container(
      decoration: decoration,
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: ember?.accentOrange.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.flame,
                      size: 22,
                      color: ember?.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  ...?actions,
                ],
              ),
            ),
          ),
          bottom ?? const SizedBox.shrink(),
        ],
      ),
    );

    if (kIsWeb) return content;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: content,
      ),
    );
  }
}
