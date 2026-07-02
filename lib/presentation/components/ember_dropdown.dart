import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';

/// A single option within an [EmberDropdown].
class EmberDropdownItem<T> {
  final T value;
  final String label;

  const EmberDropdownItem({required this.value, required this.label});
}

/// Rounded dropdown built on [MenuAnchor]: a pill trigger showing the current
/// label plus a chevron, opening a rounded menu whose selected row is marked
/// with an accent check. Matches the settings selectors in the mockups.
class EmberDropdown<T> extends StatelessWidget {
  final List<EmberDropdownItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  const EmberDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final currentLabel = items
        .firstWhere(
          (i) => i.value == value,
          orElse: () => items.first,
        )
        .label;

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(ember?.storyCardBackground),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      menuChildren: items
          .map(
            (item) => MenuItemButton(
              trailingIcon: item.value == value
                  ? Icon(AppIcons.check, size: 16, color: ember?.accentOrange)
                  : const SizedBox(width: 16),
              onPressed: () => onChanged(item.value),
              child: Text(item.label),
            ),
          )
          .toList(),
      builder: (context, controller, _) {
        return GestureDetector(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ember?.chipUnselectedBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentLabel, style: textTheme.labelLarge),
                const SizedBox(width: 6),
                Icon(
                  AppIcons.chevronDown,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
