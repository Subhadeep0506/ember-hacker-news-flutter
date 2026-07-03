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

  static PreviewThemeData _theme() {
    return PreviewThemeData(
      materialLight: AppTheme.light(),
      materialDark: AppTheme.dark(),
    );
  }
}
