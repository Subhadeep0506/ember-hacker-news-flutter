import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ember_theme_extension.dart';

class AppTheme {
  static const _seedColor = Color(0xFFFF6600);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(colorScheme, EmberThemeExtension.light());
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    );
    return _buildTheme(colorScheme, EmberThemeExtension.dark());
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    EmberThemeExtension ember,
  ) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(colorScheme: colorScheme).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [ember],
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: ember.accentOrange.withAlpha(30),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
      ),
      cardTheme: CardThemeData(
        color: ember.storyCardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(40),
        thickness: 0.5,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        selectedColor: ember.accentOrange,
        showCheckmark: false,
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
