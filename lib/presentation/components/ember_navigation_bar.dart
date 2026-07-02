import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';

class EmberNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const EmberNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  // Lucide is stroke-only, so active/inactive use the same glyph; the selected
  // tab is distinguished by accent color + the indicator pill below.
  static const _destinations = [
    _NavItem(
      icon: AppIcons.navFeeds,
      activeIcon: AppIcons.navFeeds,
      label: 'Feeds',
    ),
    _NavItem(
      icon: AppIcons.search,
      activeIcon: AppIcons.search,
      label: 'Search',
    ),
    _NavItem(
      icon: AppIcons.navSubmit,
      activeIcon: AppIcons.navSubmit,
      label: 'Submit',
    ),
    _NavItem(
      icon: AppIcons.navSettings,
      activeIcon: AppIcons.navSettings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final colorScheme = Theme.of(context).colorScheme;

    // Web cannot blur behind native HTML image layers, so use an opaque
    // surface there; mobile gets a real frosted-glass BackdropFilter.
    final surface = ember?.scaffoldBackground ?? colorScheme.surface;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: kIsWeb ? surface : surface.withAlpha(210),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(60),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        indicatorColor: ember?.accentOrange.withAlpha(30),
        destinations: _destinations.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon, color: colorScheme.onSurface.withAlpha(150)),
            selectedIcon: Icon(item.activeIcon, color: ember?.accentOrange),
            label: item.label,
          );
        }).toList(),
      ),
    );

    if (kIsWeb) return content;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: content,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
