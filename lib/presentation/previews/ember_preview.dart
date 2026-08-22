import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../config/theme/app_theme.dart';

final class EmberPreview extends Preview {
  const EmberPreview({
    super.name,
    super.group,
    super.size,
    super.textScaleFactor,
    super.wrapper,
    super.brightness,
  }) : super(theme: EmberPreview._theme);

  static PreviewThemeData _theme() => const _EmberPreviewThemeData();
}

final class _EmberPreviewThemeData extends PreviewThemeData {
  const _EmberPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDark ? AppTheme.dark() : AppTheme.light(),
      child: child,
    );
  }
}
