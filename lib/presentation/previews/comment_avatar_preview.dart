import 'package:flutter/material.dart';

import '../components/comment_avatar.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'CommentAvatar — default', group: 'Avatars')
Widget commentAvatarPreview() {
  return const CommentAvatar(username: 'dang');
}

@EmberPreview(name: 'CommentAvatar — OP', group: 'Avatars')
Widget commentAvatarOpPreview() {
  return const CommentAvatar(username: 'pg', isOp: true);
}

@EmberPreview(name: 'CommentAvatar — null', group: 'Avatars')
Widget commentAvatarNullPreview() {
  return const CommentAvatar(username: null);
}

@EmberPreview(name: 'CommentAvatar — sizes', group: 'Avatars')
Widget commentAvatarSizesPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CommentAvatar(username: 'a', size: 24),
      SizedBox(width: 8),
      CommentAvatar(username: 'b', size: 32),
      SizedBox(width: 8),
      CommentAvatar(username: 'c', size: 40, isOp: true),
    ],
  );
}
