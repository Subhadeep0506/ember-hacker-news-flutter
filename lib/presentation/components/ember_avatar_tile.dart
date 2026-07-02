import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

/// Rounded-square avatar tile with an orange gradient fill, used on the profile
/// and settings banners. Shows either a single [letter] or an [icon]; [letter]
/// takes precedence when both are supplied.
class EmberAvatarTile extends StatelessWidget {
  final String? letter;
  final IconData? icon;
  final double size;

  const EmberAvatarTile({super.key, this.letter, this.icon, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final accent = ember?.accentOrange ?? Theme.of(context).colorScheme.primary;
    final label = letter;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, Color.lerp(accent, Colors.black, 0.18) ?? accent],
        ),
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: ember?.scaffoldBackground ?? Colors.white,
          width: 4,
        ),
      ),
      alignment: Alignment.center,
      child: label != null
          ? Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
              ),
            )
          : Icon(icon, color: Colors.white, size: size * 0.42),
    );
  }
}
