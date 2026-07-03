import 'package:flutter/material.dart';

import '../components/tappable_username.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'TappableUsername', group: 'Text')
Widget tappableUsernamePreview() {
  return const TappableUsername(username: 'pg');
}

@EmberPreview(name: 'TappableUsername — styled', group: 'Text')
Widget tappableUsernameStyledPreview() {
  return const TappableUsername(
    username: 'dang',
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
  );
}

@EmberPreview(name: 'TappableUsername — empty', group: 'Text')
Widget tappableUsernameEmptyPreview() {
  return const TappableUsername(username: '');
}
