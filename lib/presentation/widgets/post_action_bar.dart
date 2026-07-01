import 'package:flutter/material.dart';

import '../../config/app_icons.dart';
import '../components/ember_action_button.dart';

class PostActionBar extends StatelessWidget {
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;

  const PostActionBar({super.key, this.onUpvote, this.onReply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          EmberActionButton(
            icon: AppIcons.upvote,
            label: 'Upvote',
            onTap: onUpvote,
          ),
          EmberActionButton(
            icon: AppIcons.comment,
            label: 'Reply',
            onTap: onReply,
          ),
          EmberActionButton(
            icon: AppIcons.favorite,
            label: 'Favorite',
            onTap: () {},
          ),
          EmberActionButton(
            icon: AppIcons.save,
            label: 'Save',
            onTap: () {},
          ),
          EmberActionButton(
            icon: AppIcons.share,
            label: 'Share',
            onTap: () {},
          ),
          EmberActionButton(
            icon: AppIcons.more,
            label: 'More',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
