import 'package:flutter/material.dart';

import '../components/ember_avatar_tile.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberAvatarTile — letter', group: 'Avatars')
Widget emberAvatarTileLetterPreview() {
  return const EmberAvatarTile(letter: 'D');
}

@EmberPreview(name: 'EmberAvatarTile — icon', group: 'Avatars')
Widget emberAvatarTileIconPreview() {
  return const EmberAvatarTile(icon: Icons.settings);
}

@EmberPreview(name: 'EmberAvatarTile — sizes', group: 'Avatars')
Widget emberAvatarTileSizesPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      EmberAvatarTile(letter: 'S', size: 48),
      SizedBox(width: 12),
      EmberAvatarTile(letter: 'M', size: 72),
      SizedBox(width: 12),
      EmberAvatarTile(letter: 'L', size: 96),
    ],
  );
}
