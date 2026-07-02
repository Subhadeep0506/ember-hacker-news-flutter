import 'package:flutter/material.dart';

class EmberActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final double iconSize;
  final bool isLoading;

  const EmberActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.iconSize = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: effectiveColor,
                  ),
                ),
              )
            else
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
