import 'package:flutter/material.dart';

import '../components/ember_dropdown.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberDropdown', group: 'Controls')
Widget emberDropdownPreview() {
  return EmberDropdown<String>(
    items: const [
      EmberDropdownItem(value: 'top', label: 'Top'),
      EmberDropdownItem(value: 'new', label: 'New'),
      EmberDropdownItem(value: 'best', label: 'Best'),
      EmberDropdownItem(value: 'ask', label: 'Ask HN'),
    ],
    value: 'top',
    onChanged: (_) {},
  );
}
