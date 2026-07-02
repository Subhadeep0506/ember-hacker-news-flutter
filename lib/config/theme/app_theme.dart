import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ember_theme_extension.dart';

class AppTheme {
  static const _seedColor = Color(0xFFFF6600);

  static ThemeData light({VisualDensity? density}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(colorScheme, EmberThemeExtension.light(), density);
  }

  static ThemeData dark({VisualDensity? density}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    );
    return _buildTheme(colorScheme, EmberThemeExtension.dark(), density);
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    EmberThemeExtension ember,
    VisualDensity? density,
  ) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(colorScheme: colorScheme).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      visualDensity: density ?? VisualDensity.standard,
      extensions: [ember],
      scaffoldBackgroundColor: ember.scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: ember.scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ember.scaffoldBackground,
        indicatorColor: ember.accentOrange.withAlpha(30),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
      ),
      cardTheme: CardThemeData(
        color: ember.storyCardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withAlpha(40)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ember.accentOrange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ember.accentOrange,
          side: BorderSide(color: ember.accentOrange),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ember.chipUnselectedBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ember.accentOrange, width: 1.5),
        ),
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
