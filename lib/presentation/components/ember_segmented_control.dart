import 'package:flutter/material.dart';

import '../../config/theme/ember_theme_extension.dart';

/// A single choice within an [EmberSegmentedControl].
class EmberSegment<T> {
  final T value;
  final String label;
  final IconData? icon;

  const EmberSegment({required this.value, required this.label, this.icon});
}

/// Neutral-track segmented control: a muted pill track with a single raised
/// segment marking the current selection. Used for mutually-exclusive settings
/// (theme, density) where the orange [EmberChip] would read as too loud.
class EmberSegmentedControl<T> extends StatelessWidget {
  final List<EmberSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const EmberSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ember?.chipUnselectedBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments
            .map(
              (seg) => _Segment(
                segment: seg,
                isSelected: seg.value == selected,
                onTap: () => onChanged(seg.value),
                ember: ember,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  final EmberSegment<T> segment;
  final bool isSelected;
  final VoidCallback onTap;
  final EmberThemeExtension? ember;

  const _Segment({
    required this.segment,
    required this.isSelected,
    required this.onTap,
    required this.ember,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurface.withAlpha(140);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ember?.storyCardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              segment.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
