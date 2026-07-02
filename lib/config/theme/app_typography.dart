import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    return GoogleFonts.geistTextTheme(
      ThemeData(colorScheme: colorScheme).textTheme,
    );
  }
}
