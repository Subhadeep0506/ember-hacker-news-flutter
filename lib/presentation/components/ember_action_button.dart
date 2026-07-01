import 'package:flutter/material.dart';

class EmberActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final double iconSize;

  const EmberActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: effectiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: effectiveColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
