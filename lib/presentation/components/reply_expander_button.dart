import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';

/// A compact, indented "＋ Show N more replies" pill rendered in place of the
/// replies hidden beyond the per-thread cap. Tapping it reveals the rest.
///
/// [leftInset] aligns the pill with the reply bubbles it stands in for; the
/// caller computes it from the marker's clamped depth.
class ReplyExpanderButton extends StatelessWidget {
  final int hiddenCount;
  final double leftInset;
  final VoidCallback? onTap;

  const ReplyExpanderButton({
    super.key,
    required this.hiddenCount,
    required this.leftInset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final accent = ember?.accentOrange ?? Theme.of(context).colorScheme.primary;
    final label =
        'Show $hiddenCount more ${hiddenCount == 1 ? 'reply' : 'replies'}';

    return Padding(
      padding: EdgeInsets.only(left: leftInset, top: 4, bottom: 8, right: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: accent.withAlpha(24),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.plus, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
