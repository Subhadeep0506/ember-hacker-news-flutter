import 'package:flutter/material.dart';

import '../components/ember_segmented_control.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberSegmentedControl', group: 'Controls')
Widget emberSegmentedControlPreview() {
  return EmberSegmentedControl<String>(
    segments: const [
      EmberSegment(value: 'light', label: 'Light'),
      EmberSegment(value: 'dark', label: 'Dark'),
      EmberSegment(value: 'system', label: 'System'),
    ],
    selected: 'dark',
    onChanged: (_) {},
  );
}

@EmberPreview(name: 'EmberSegmentedControl — with icons', group: 'Controls')
Widget emberSegmentedControlWithIconsPreview() {
  return EmberSegmentedControl<String>(
    segments: const [
      EmberSegment(value: 'light', label: 'Light', icon: Icons.light_mode),
      EmberSegment(value: 'dark', label: 'Dark', icon: Icons.dark_mode),
      EmberSegment(value: 'system', label: 'System', icon: Icons.devices),
    ],
    selected: 'system',
    onChanged: (_) {},
  );
}
