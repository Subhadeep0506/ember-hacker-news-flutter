import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../domain/models/models.dart';
import '../../utils/comment_markdown.dart';
import '../../utils/time_ago.dart';
import '../components/comment_avatar.dart';
import '../components/tappable_username.dart';
import '../view_models/post_detail_view_model.dart';
import 'comment_thread_painter.dart';

class CommentTile extends StatelessWidget {
  final FlatComment flatComment;
  final bool isCollapsed;
  final bool isUpvoted;
  final bool isVoting;
  final bool isOp;
  final TextStyle? bodyTextStyle;
  final VoidCallback onToggleCollapse;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;
  final ValueChanged<String>? onOpenLink;

  const CommentTile({
    super.key,
    required this.flatComment,
    required this.isCollapsed,
    this.isUpvoted = false,
    this.isVoting = false,
    this.isOp = false,
    this.bodyTextStyle,
    required this.onToggleCollapse,
    this.onUpvote,
    this.onReply,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final comment = flatComment.comment;

    final baseBodyStyle = (bodyTextStyle ?? textTheme.bodyMedium)?.copyWith(
      height: 1.5,
    );

    final Widget bubbleChild = comment.deleted
        ? Text(
            '[deleted]',
            style: textTheme.bodySmall?.copyWith(
              color: ember?.metadataColor,
              fontStyle: FontStyle.italic,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentHeader(
                comment: flatComment,
                isCollapsed: isCollapsed,
                isOp: isOp,
                onToggleCollapse: onToggleCollapse,
                ember: ember,
                textTheme: textTheme,
              ),
              if (!isCollapsed && comment.text != null) ...[
                const SizedBox(height: 8),
                HtmlWidget(
                  renderCommentMarkdown(comment.text ?? ''),
                  onTapUrl: (url) {
                    if (onOpenLink != null) {
                      onOpenLink?.call(url);
                    } else {
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    return true;
                  },
                  textStyle: baseBodyStyle,
                ),
              ],
              if (!isCollapsed) ...[
                const SizedBox(height: 8),
                _CommentActions(
                  ember: ember,
                  isUpvoted: isUpvoted,
                  isVoting: isVoting,
                  onUpvote: onUpvote,
                  onReply: onReply,
                ),
              ],
            ],
          );

    return _ThreadedRow(
      flatComment: flatComment,
      isOp: isOp,
      isDeleted: comment.deleted,
      ember: ember,
      child: bubbleChild,
    );
  }
}

/// Lays out the thread rails (via [CommentThreadPainter]), the author avatar,
/// and the rounded content bubble for a single comment row.
class _ThreadedRow extends StatelessWidget {
  final FlatComment flatComment;
  final bool isOp;
  final bool isDeleted;
  final EmberThemeExtension? ember;
  final Widget child;

  const _ThreadedRow({
    required this.flatComment,
    required this.isOp,
    required this.isDeleted,
    required this.ember,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final depth = flatComment.depth;

    return CustomPaint(
      painter: CommentThreadPainter(
        depth: depth,
        rails: flatComment.rails,
        hasChildRail: flatComment.hasChildRail,
        color: colorScheme.outlineVariant,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: kCommentTopPad,
          bottom: 8,
          right: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: depth * kCommentIndent),
            CommentAvatar(
              username: isDeleted ? null : flatComment.comment.by,
              size: kCommentAvatarRadius * 2,
              isOp: isOp,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ember?.chipUnselectedBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder for a comment, reusing the real tile's avatar, bubble,
/// and thread-rail layout ([_ThreadedRow]) so the skeleton matches the loaded
/// state. Meant to be wrapped in a `Skeletonizer`.
class SkeletonCommentTile extends StatelessWidget {
  final int depth;
  final List<bool> rails;
  final bool hasChildRail;

  const SkeletonCommentTile({
    super.key,
    this.depth = 0,
    this.rails = const [],
    this.hasChildRail = false,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
      fontSize: 12,
    );
    final actionStyle = textTheme.labelSmall?.copyWith(
      color: ember?.commentActionColor,
      fontSize: 11,
    );

    final fake = FlatComment(
      comment: const Comment(id: 0, by: 'username'),
      depth: depth,
      rails: rails,
      hasChildRail: hasChildRail,
    );

    return _ThreadedRow(
      flatComment: fake,
      isOp: false,
      isDeleted: false,
      ember: ember,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'username',
                style: textTheme.bodySmall?.copyWith(
                  color: ember?.commentAuthorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text('2h', style: metaStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is a placeholder comment body line used for the loading state.',
            style: textTheme.bodyMedium,
          ),
          Text('A shorter second line.', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Upvote', style: actionStyle),
              const SizedBox(width: 16),
              Text('Reply', style: actionStyle),
              const SizedBox(width: 16),
              Text('Link', style: actionStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final FlatComment comment;
  final bool isCollapsed;
  final bool isOp;
  final VoidCallback onToggleCollapse;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _CommentHeader({
    required this.comment,
    required this.isCollapsed,
    required this.isOp,
    required this.onToggleCollapse,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final c = comment.comment;
    final time = timeAgo(c.time);
    final accent = ember?.accentOrange;

    final metaStyle = textTheme.bodySmall?.copyWith(
      color: ember?.metadataColor,
      fontSize: 12,
    );

    return GestureDetector(
      onTap: onToggleCollapse,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          TappableUsername(
            username: c.by ?? 'anon',
            style: textTheme.bodySmall?.copyWith(
              color: isOp ? accent : ember?.commentAuthorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isOp) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: accent?.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OP',
                style: textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (time.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(time, style: metaStyle),
          ],
          if (comment.childCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              '· ${comment.childCount} ${comment.childCount == 1 ? 'reply' : 'replies'}',
              style: metaStyle,
            ),
          ],
          const Spacer(),
          Icon(
            isCollapsed ? AppIcons.chevronRight : AppIcons.chevronDown,
            size: 18,
            color: ember?.metadataColor,
          ),
        ],
      ),
    );
  }
}

class _CommentActions extends StatelessWidget {
  final EmberThemeExtension? ember;
  final bool isUpvoted;
  final bool isVoting;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;

  const _CommentActions({
    required this.ember,
    this.isUpvoted = false,
    this.isVoting = false,
    this.onUpvote,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final color = ember?.commentActionColor;
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: color, fontSize: 11);

    return Row(
      children: [
        _CommentActionChip(
          icon: AppIcons.upvote,
          label: 'Upvote',
          isLoading: isVoting,
          color: isUpvoted ? ember?.accentOrange : color,
          style: isUpvoted
              ? style?.copyWith(color: ember?.accentOrange)
              : style,
          onTap: onUpvote,
        ),
        const SizedBox(width: 16),
        _CommentActionChip(
          icon: AppIcons.reply,
          label: 'Reply',
          color: color,
          style: style,
          onTap: onReply,
        ),
        const SizedBox(width: 16),
        _CommentActionChip(
          icon: AppIcons.link,
          label: 'Link',
          color: color,
          style: style,
        ),
        const SizedBox(width: 16),
        _CommentActionChip(
          icon: AppIcons.openExternal,
          label: 'HN',
          color: color,
          style: style,
        ),
      ],
    );
  }
}

class _CommentActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final TextStyle? style;
  final VoidCallback? onTap;
  final bool isLoading;

  const _CommentActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.style,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: style),
        ],
      ),
    );
  }
}
