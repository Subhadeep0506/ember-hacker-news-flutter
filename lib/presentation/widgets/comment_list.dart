import 'package:flutter/material.dart';

import '../view_models/post_detail_view_model.dart';
import 'comment_tile.dart';

class CommentList extends StatelessWidget {
  final List<FlatComment> comments;
  final Set<int> collapsedIds;
  final Set<int> upvotedIds;
  final Set<int> votingIds;
  final String? opUsername;
  final bool highlightOP;
  final TextStyle? bodyTextStyle;
  final ValueChanged<int> onToggleCollapse;
  final ValueChanged<int>? onUpvote;
  final ValueChanged<int>? onReply;
  final ValueChanged<String>? onOpenLink;

  const CommentList({
    super.key,
    required this.comments,
    required this.collapsedIds,
    this.upvotedIds = const {},
    this.votingIds = const {},
    this.opUsername,
    this.highlightOP = false,
    this.bodyTextStyle,
    required this.onToggleCollapse,
    this.onUpvote,
    this.onReply,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final flat = comments[index];
        final id = flat.comment.id;
        // The tile owns its own left inset (per depth) and vertical padding, so
        // only a small left margin is added here.
        return Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CommentTile(
            flatComment: flat,
            isCollapsed: collapsedIds.contains(id),
            isUpvoted: upvotedIds.contains(id),
            isVoting: votingIds.contains(id),
            isOp:
                highlightOP &&
                opUsername != null &&
                flat.comment.by == opUsername,
            bodyTextStyle: bodyTextStyle,
            onToggleCollapse: () => onToggleCollapse(id),
            onUpvote: onUpvote != null ? () => onUpvote?.call(id) : null,
            onReply: onReply != null ? () => onReply?.call(id) : null,
            onOpenLink: onOpenLink,
          ),
        );
      },
    );
  }
}
