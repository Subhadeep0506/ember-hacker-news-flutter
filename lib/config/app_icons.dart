import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Central mapping of semantic icon roles to concrete [Lucide](https://lucide.dev)
/// glyphs. This is the single place in the app that references `LucideIcons`, so
/// swapping an icon (or the icon set entirely) happens here rather than at every
/// call site.
abstract final class AppIcons {
  // Voting / engagement
  static const IconData upvote = LucideIcons.arrowBigUp;
  static const IconData comment = LucideIcons.messageSquare;
  static const IconData reply = LucideIcons.reply;
  static const IconData favorite = LucideIcons.star;
  static const IconData save = LucideIcons.bookmark;
  static const IconData share = LucideIcons.share2;
  static const IconData gift = LucideIcons.gift;
  static const IconData more = LucideIcons.moreHorizontal;
  static const IconData back = LucideIcons.arrowLeft;
  static const IconData flame = LucideIcons.flame;

  // Links / navigation affordances
  static const IconData openExternal = LucideIcons.externalLink;
  static const IconData link = LucideIcons.link;
  static const IconData close = LucideIcons.x;
  static const IconData login = LucideIcons.logIn;
  static const IconData search = LucideIcons.search;
  static const IconData user = LucideIcons.user;
  static const IconData globe = LucideIcons.globe;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronUp = LucideIcons.chevronUp;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData check = LucideIcons.check;
  static const IconData collapseAll = LucideIcons.chevronsDownUp;
  static const IconData expandAll = LucideIcons.chevronsUpDown;

  // Status / feedback
  static const IconData imageError = LucideIcons.imageOff;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData wifiOff = LucideIcons.wifiOff;
  static const IconData error = LucideIcons.alertCircle;
  static const IconData info = LucideIcons.info;
  static const IconData lock = LucideIcons.lock;

  // Settings
  static const IconData palette = LucideIcons.palette;
  static const IconData themeSystem = LucideIcons.monitor;
  static const IconData themeDark = LucideIcons.moon;
  static const IconData themeLight = LucideIcons.sun;
  static const IconData notifications = LucideIcons.bell;
  static const IconData shield = LucideIcons.shield;
  static const IconData storage = LucideIcons.database;
  static const IconData reset = LucideIcons.rotateCcw;
  static const IconData stories = LucideIcons.bookOpen;
  static const IconData feedSection = LucideIcons.layoutList;

  // Bottom navigation (Lucide is stroke-only; selected state uses color, not fill)
  static const IconData navFeeds = LucideIcons.newspaper;
  static const IconData navSubmit = LucideIcons.plusSquare;
  static const IconData navSettings = LucideIcons.settings;
}
