import 'package:flutter/material.dart';

import '../view_models/post_detail_view_model.dart';
import 'comment_tile.dart';

class CommentList extends StatelessWidget {
  final List<FlatComment> comments;
  final Set<int> collapsedIds;
  final Set<int> upvotedIds;
  final ValueChanged<int> onToggleCollapse;
  final ValueChanged<int>? onUpvote;
  final ValueChanged<int>? onReply;

  const CommentList({
    super.key,
    required this.comments,
    required this.collapsedIds,
    this.upvotedIds = const {},
    required this.onToggleCollapse,
    this.onUpvote,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: comments.length,
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final flat = comments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CommentTile(
            flatComment: flat,
            isCollapsed: collapsedIds.contains(flat.comment.id),
            isUpvoted: upvotedIds.contains(flat.comment.id),
            onToggleCollapse: () => onToggleCollapse(flat.comment.id),
            onUpvote: onUpvote != null
                ? () => onUpvote?.call(flat.comment.id)
                : null,
            onReply: onReply != null
                ? () => onReply?.call(flat.comment.id)
                : null,
          ),
        );
      },
    );
  }
}
