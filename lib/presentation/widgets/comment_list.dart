import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/reply_expander_button.dart';
import '../view_models/post_detail_view_model.dart';
import 'comment_thread_painter.dart';
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
  final ValueChanged<int>? onExpandReplies;

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
    this.onExpandReplies,
  });

  /// Left inset that aligns a row's content with the reply bubbles at [depth],
  /// mirroring the avatar + gap layout inside [CommentTile]'s threaded row.
  double _bubbleInset(int depth) {
    final indentDepth = math.min(depth, kMaxIndentDepth);
    return indentDepth * kCommentIndent + kCommentAvatarRadius * 2 + 8;
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final flat = comments[index];
        final showMoreParentId = flat.showMoreForParentId;
        if (showMoreParentId != null) {
          // Synthetic "show more replies" marker: render the expander in place
          // of the hidden replies, indented to align with them.
          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: ReplyExpanderButton(
              hiddenCount: flat.hiddenReplyCount,
              leftInset: _bubbleInset(flat.depth),
              onTap: onExpandReplies != null
                  ? () => onExpandReplies?.call(showMoreParentId)
                  : null,
            ),
          );
        }
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
