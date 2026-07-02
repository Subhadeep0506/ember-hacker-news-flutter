import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

/// Small circular avatar showing a comment author's initial.
///
/// Uses a brand-orange tinted circle with the ember-orange letter, matching the
/// [EmberDomainAvatar] fallback style. OP avatars get a slightly stronger fill
/// and a thin accent ring.
class CommentAvatar extends StatelessWidget {
  final String? username;
  final double size;
  final bool isOp;

  const CommentAvatar({
    super.key,
    required this.username,
    this.size = 32,
    this.isOp = false,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final accent = ember?.accentOrange ?? Colors.orange;
    final name = username;
    final letter = (name != null && name.isNotEmpty)
        ? name.characters.first.toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
        border: isOp ? Border.all(color: accent.withAlpha(140)) : null,
      ),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ember?.scaffoldBackground ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
