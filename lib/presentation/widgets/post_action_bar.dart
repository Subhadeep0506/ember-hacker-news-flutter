import 'package:flutter/material.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../components/ember_action_button.dart';
import '../view_models/post_detail_view_model.dart';

class PostActionBar extends StatelessWidget {
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;
  final bool isUpvoted;
  final bool isVoting;
  final CommentSort commentSort;
  final VoidCallback? onSortNewest;
  final VoidCallback? onSortOldest;
  final VoidCallback? onCollapseAll;
  final VoidCallback? onExpandAll;

  const PostActionBar({
    super.key,
    this.onUpvote,
    this.onReply,
    this.isUpvoted = false,
    this.isVoting = false,
    this.commentSort = CommentSort.oldestFirst,
    this.onSortNewest,
    this.onSortOldest,
    this.onCollapseAll,
    this.onExpandAll,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          EmberActionButton(
            icon: AppIcons.upvote,
            label: 'Upvote',
            isLoading: isVoting,
            color: isUpvoted ? ember?.accentOrange : null,
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
          _MoreMenuButton(
            commentSort: commentSort,
            onSortNewest: onSortNewest,
            onSortOldest: onSortOldest,
            onCollapseAll: onCollapseAll,
            onExpandAll: onExpandAll,
          ),
        ],
      ),
    );
  }
}

/// The "More" action, rendered as a Material 3 [MenuAnchor] dropdown offering
/// comment sort order plus collapse/expand-all shortcuts.
class _MoreMenuButton extends StatelessWidget {
  final CommentSort commentSort;
  final VoidCallback? onSortNewest;
  final VoidCallback? onSortOldest;
  final VoidCallback? onCollapseAll;
  final VoidCallback? onExpandAll;

  const _MoreMenuButton({
    required this.commentSort,
    this.onSortNewest,
    this.onSortOldest,
    this.onCollapseAll,
    this.onExpandAll,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final accent = ember?.accentOrange ?? Theme.of(context).colorScheme.primary;
    final isNewest = commentSort == CommentSort.newestFirst;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      builder: (context, controller, _) => EmberActionButton(
        icon: AppIcons.more,
        label: 'More',
        onTap: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            AppIcons.chevronUp,
            color: isNewest ? accent : null,
          ),
          onPressed: onSortNewest,
          child: Text(
            'Newest first',
            style: isNewest ? TextStyle(color: accent) : null,
          ),
        ),
        MenuItemButton(
          leadingIcon: Icon(
            AppIcons.chevronDown,
            color: !isNewest ? accent : null,
          ),
          onPressed: onSortOldest,
          child: Text(
            'Oldest first',
            style: !isNewest ? TextStyle(color: accent) : null,
          ),
        ),
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(AppIcons.collapseAll),
          onPressed: onCollapseAll,
          child: const Text('Collapse all'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(AppIcons.expandAll),
          onPressed: onExpandAll,
          child: const Text('Expand all'),
        ),
      ],
    );
  }
}
