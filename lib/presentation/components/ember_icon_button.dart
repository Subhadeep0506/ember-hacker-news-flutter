import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

/// Circular, softly tinted icon button used for header affordances such as
/// back, share and more. Sits on top of imagery or plain surfaces, reading its
/// background from [EmberThemeExtension.iconButtonBackground].
class EmberIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? background;

  const EmberIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.size = 40,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final button = Material(
      color: background ?? ember?.iconButtonBackground,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.5,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );

    final label = tooltip;
    return label == null ? button : Tooltip(message: label, child: button);
  }
}
