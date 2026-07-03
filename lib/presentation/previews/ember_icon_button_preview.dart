import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../components/ember_icon_button.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberIconButton', group: 'Buttons')
Widget emberIconButtonPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EmberIconButton(icon: AppIcons.back, tooltip: 'Back'),
      SizedBox(width: 12),
      EmberIconButton(icon: AppIcons.share, tooltip: 'Share'),
      SizedBox(width: 12),
      EmberIconButton(icon: AppIcons.more, tooltip: 'More'),
    ],
  );
}

@EmberPreview(name: 'EmberIconButton — sizes', group: 'Buttons')
Widget emberIconButtonSizesPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      EmberIconButton(icon: AppIcons.close, size: 32),
      SizedBox(width: 12),
      EmberIconButton(icon: AppIcons.close, size: 40),
      SizedBox(width: 12),
      EmberIconButton(icon: AppIcons.close, size: 48),
    ],
  );
}
