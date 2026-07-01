import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_icons.dart';
import '../../config/theme/ember_theme_extension.dart';
import '../../utils/time_ago.dart';
import '../components/tappable_username.dart';
import '../view_models/post_detail_view_model.dart';

class CommentTile extends StatelessWidget {
  final FlatComment flatComment;
  final bool isCollapsed;
  final bool isUpvoted;
  final VoidCallback onToggleCollapse;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.flatComment,
    required this.isCollapsed,
    this.isUpvoted = false,
    required this.onToggleCollapse,
    this.onUpvote,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final ember = Theme.of(context).extension<EmberThemeExtension>();
    final textTheme = Theme.of(context).textTheme;
    final comment = flatComment.comment;
    final depth = flatComment.depth;

    if (comment.deleted) {
      return _buildDeletedComment(context, depth, ember);
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Container(
        decoration: depth > 0
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color:
                        ember?.commentBorderForDepth(depth - 1) ??
                        Colors.orange,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Padding(
          padding: EdgeInsets.only(
            left: depth > 0 ? 12 : 0,
            top: 12,
            bottom: 12,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentHeader(
                comment: flatComment,
                isCollapsed: isCollapsed,
                onToggleCollapse: onToggleCollapse,
                ember: ember,
                textTheme: textTheme,
              ),
              if (!isCollapsed && comment.text != null) ...[
                const SizedBox(height: 8),
                HtmlWidget(
                  comment.text ?? '',
                  onTapUrl: (url) {
                    launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                    return true;
                  },
                  textStyle: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
              if (!isCollapsed) ...[
                const SizedBox(height: 8),
                _CommentActions(
                  ember: ember,
                  isUpvoted: isUpvoted,
                  onUpvote: onUpvote,
                  onReply: onReply,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedComment(
    BuildContext context,
    int depth,
    EmberThemeExtension? ember,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Container(
        decoration: depth > 0
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color:
                        ember?.commentBorderForDepth(depth - 1) ??
                        Colors.orange,
                    width: 2,
                  ),
                ),
              )
            : null,
        padding: EdgeInsets.only(left: depth > 0 ? 12 : 0, top: 8, bottom: 8),
        child: Text(
          '[deleted]',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ember?.metadataColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final FlatComment comment;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final EmberThemeExtension? ember;
  final TextTheme textTheme;

  const _CommentHeader({
    required this.comment,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.ember,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final c = comment.comment;
    final time = timeAgo(c.time);

    return GestureDetector(
      onTap: onToggleCollapse,
      child: Row(
        children: [
          Icon(
            isCollapsed ? AppIcons.chevronRight : AppIcons.chevronDown,
            size: 18,
            color: ember?.metadataColor,
          ),
          const SizedBox(width: 4),
          TappableUsername(
            username: c.by ?? 'anon',
            style: textTheme.bodySmall?.copyWith(
              color: ember?.commentAuthorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              time,
              style: textTheme.bodySmall?.copyWith(
                color: ember?.metadataColor,
                fontSize: 12,
              ),
            ),
          ],
          if (comment.childCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              '· ${comment.childCount} ${comment.childCount == 1 ? 'reply' : 'replies'}',
              style: textTheme.bodySmall?.copyWith(
                color: ember?.metadataColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentActions extends StatelessWidget {
  final EmberThemeExtension? ember;
  final bool isUpvoted;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;

  const _CommentActions({
    required this.ember,
    this.isUpvoted = false,
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

  const _CommentActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: style),
        ],
      ),
    );
  }
}
