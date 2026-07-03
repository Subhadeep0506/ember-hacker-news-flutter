import 'package:flutter/material.dart';

import '../components/ember_navigation_bar.dart';
import 'ember_preview.dart';

@EmberPreview(
  name: 'EmberNavigationBar — feeds',
  group: 'Navigation',
  size: Size(400, 80),
)
Widget emberNavigationBarFeedsPreview() {
  return EmberNavigationBar(
    selectedIndex: 0,
    onDestinationSelected: (_) {},
  );
}

@EmberPreview(
  name: 'EmberNavigationBar — settings',
  group: 'Navigation',
  size: Size(400, 80),
)
Widget emberNavigationBarSettingsPreview() {
  return EmberNavigationBar(
    selectedIndex: 3,
    onDestinationSelected: (_) {},
  );
}
