import 'package:flutter/material.dart';

import '../components/ember_domain_avatar.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberDomainAvatar — with URL', group: 'Avatars')
Widget emberDomainAvatarWithUrlPreview() {
  return const EmberDomainAvatar(url: 'https://github.com/flutter');
}

@EmberPreview(name: 'EmberDomainAvatar — null URL', group: 'Avatars')
Widget emberDomainAvatarFallbackPreview() {
  return const EmberDomainAvatar(url: null);
}

@EmberPreview(name: 'EmberDomainAvatar — sizes', group: 'Avatars')
Widget emberDomainAvatarSizesPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      EmberDomainAvatar(url: 'https://news.ycombinator.com', size: 24),
      SizedBox(width: 12),
      EmberDomainAvatar(url: 'https://news.ycombinator.com', size: 36),
      SizedBox(width: 12),
      EmberDomainAvatar(url: 'https://news.ycombinator.com', size: 48),
    ],
  );
}
