import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../components/ember_chip.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberChip — selected', group: 'Controls')
Widget emberChipSelectedPreview() {
  return EmberChip(label: 'Top', selected: true, onTap: () {});
}

@EmberPreview(name: 'EmberChip — unselected', group: 'Controls')
Widget emberChipUnselectedPreview() {
  return EmberChip(label: 'New', selected: false, onTap: () {});
}

@EmberPreview(name: 'EmberChip — with icon', group: 'Controls')
Widget emberChipWithIconPreview() {
  return EmberChip(
    label: 'Search',
    selected: true,
    onTap: () {},
    icon: AppIcons.search,
  );
}

@EmberPreview(name: 'EmberChip — row', group: 'Controls')
Widget emberChipRowPreview() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EmberChip(label: 'Top', selected: true, onTap: () {}),
      const SizedBox(width: 8),
      EmberChip(label: 'New', selected: false, onTap: () {}),
      const SizedBox(width: 8),
      EmberChip(label: 'Best', selected: false, onTap: () {}),
    ],
  );
}
