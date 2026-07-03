import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../components/ember_app_bar.dart';
import '../components/ember_icon_button.dart';
import 'ember_preview.dart';

@EmberPreview(
  name: 'EmberAppBar — basic',
  group: 'Navigation',
  size: Size(400, 100),
)
Widget emberAppBarPreview() {
  return const EmberAppBar(title: 'Ember HN');
}

@EmberPreview(
  name: 'EmberAppBar — with actions',
  group: 'Navigation',
  size: Size(400, 100),
)
Widget emberAppBarWithActionsPreview() {
  return const EmberAppBar(
    title: 'Ember HN',
    actions: [
      EmberIconButton(icon: AppIcons.search),
      SizedBox(width: 8),
      EmberIconButton(icon: AppIcons.user),
    ],
  );
}
