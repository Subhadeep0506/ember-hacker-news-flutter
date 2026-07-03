import 'package:flutter/material.dart';

import '../components/ember_action_button.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberActionButton', group: 'Buttons')
Widget emberActionButtonPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EmberActionButton(icon: Icons.share, label: 'Share'),
      SizedBox(width: 8),
      EmberActionButton(icon: Icons.bookmark, label: 'Save'),
      SizedBox(width: 8),
      EmberActionButton(icon: Icons.reply, label: 'Reply'),
    ],
  );
}

@EmberPreview(name: 'EmberActionButton — loading', group: 'Buttons')
Widget emberActionButtonLoadingPreview() {
  return const EmberActionButton(
    icon: Icons.arrow_upward,
    label: 'Vote',
    isLoading: true,
  );
}

@EmberPreview(name: 'EmberActionButton — custom color', group: 'Buttons')
Widget emberActionButtonColorPreview() {
  return const EmberActionButton(
    icon: Icons.favorite,
    label: 'Like',
    color: Colors.red,
  );
}
