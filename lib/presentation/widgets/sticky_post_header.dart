import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../utils/url_utils.dart';
import 'post_action_bar.dart';
import 'post_header.dart';

// Layout constants used to size the collapsing header. They mirror the paddings
// and row heights inside [PostHeaderContent] and [PostActionBar] so the header's
// natural (expanded) height can be computed for `maxExtent`.
const double _kContentPadding = 16;
const double _kActionBarHeight = 64;
const double _kDomainBlock = 24; // 8px gap + ~16px favicon row
const double _kMetaGap = 12;
const double _kMetaRow = 20;
const double _kOpenButtonBlock = 60; // 16px gap + ~44px outlined button
const double _kCondensedTitleRegion = 48; // vertical padding + one text line

/// Pinned, scroll-driven collapsing header for the post detail screen.
///
/// Cross-fades between the full [PostHeaderContent] and a condensed one-line
/// title while keeping the [PostActionBar] visible in both states. The
/// transition is driven directly by the scroll `shrinkOffset`, so it animates
/// both ways (collapsing on scroll down, expanding on scroll up).
class SliverStickyPostHeader extends StatelessWidget {
  final ItemResponse item;
  final double width;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;

  const SliverStickyPostHeader({
    super.key,
    required this.item,
    required this.width,
    this.onUpvote,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyPostHeaderDelegate(
        item: item,
        width: width,
        titleStyle: postTitleStyle(Theme.of(context).textTheme),
        onUpvote: onUpvote,
        onReply: onReply,
      ),
    );
  }
}

class _StickyPostHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ItemResponse item;
  final double width;
  final TextStyle? titleStyle;
  final VoidCallback? onUpvote;
  final VoidCallback? onReply;
  final double _expandedTitleHeight;

  _StickyPostHeaderDelegate({
    required this.item,
    required this.width,
    required this.titleStyle,
    this.onUpvote,
    this.onReply,
  }) : _expandedTitleHeight = _measureTitleHeight(item.title, titleStyle, width);

  static double _measureTitleHeight(
    String? title,
    TextStyle? style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: title ?? '', style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - _kContentPadding * 2);
    return painter.height;
  }

  double get _fullContentHeight {
    final hasDomain = extractDomain(item.url) != null;
    final hasUrl = item.url != null;
    return _kContentPadding * 2 +
        _expandedTitleHeight +
        (hasDomain ? _kDomainBlock : 0) +
        _kMetaGap +
        _kMetaRow +
        (hasUrl ? _kOpenButtonBlock : 0);
  }

  @override
  double get maxExtent => _fullContentHeight + _kActionBarHeight;

  @override
  double get minExtent => _kCondensedTitleRegion + _kActionBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);

    return _HeaderSurface(
      collapsed: t,
      child: Column(
        children: [
          Expanded(child: _TitleRegion(item: item, collapsed: t)),
          PostActionBar(onUpvote: onUpvote, onReply: onReply),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyPostHeaderDelegate oldDelegate) {
    return item.id != oldDelegate.item.id ||
        item.title != oldDelegate.item.title ||
        width != oldDelegate.width;
  }
}

/// Opaque background so scrolling comments never bleed through the pinned bar,
/// with a bottom divider + subtle shadow that fade in as the header collapses.
class _HeaderSurface extends StatelessWidget {
  final double collapsed;
  final Widget child;

  const _HeaderSurface({required this.collapsed, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withAlpha((collapsed * 60).round()),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((collapsed * 20).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Cross-fades the full header content with a condensed one-line title. The
/// [ClipRect] + top-anchored [Positioned] lets each layer keep its natural
/// height while the region shrinks, avoiding overflow during the transition.
class _TitleRegion extends StatelessWidget {
  final ItemResponse item;
  final double collapsed;

  const _TitleRegion({required this.item, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsed > 0.5,
              child: Opacity(
                opacity: 1 - collapsed,
                child: PostHeaderContent(item: item),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsed < 0.5,
              child: Opacity(
                opacity: collapsed,
                child: _CondensedTitle(title: item.title ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CondensedTitle extends StatelessWidget {
  final String title;

  const _CondensedTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
