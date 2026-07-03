import 'package:flutter/material.dart';

import '../components/ember_gradient_hero.dart';
import 'ember_preview.dart';

@EmberPreview(
  name: 'EmberGradientHero — seed 42',
  group: 'Decorative',
  size: Size(400, 200),
)
Widget emberGradientHeroPreview() {
  return const EmberGradientHero(seed: 42);
}

@EmberPreview(
  name: 'EmberGradientHero — seed 99',
  group: 'Decorative',
  size: Size(400, 200),
)
Widget emberGradientHeroSeed99Preview() {
  return const EmberGradientHero(seed: 99);
}

@EmberPreview(
  name: 'EmberGradientHero — seed 1337',
  group: 'Decorative',
  size: Size(400, 200),
)
Widget emberGradientHeroSeed1337Preview() {
  return const EmberGradientHero(seed: 1337);
}
