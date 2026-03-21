import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF4A90E2);

  static TextTheme _textTheme(Color color) => GoogleFonts.cairoTextTheme(
    TextTheme(
      displayLarge: TextStyle(color: color, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: color, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: color),
      bodyMedium: TextStyle(color: color),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    textTheme: _textTheme(const Color(0xFF1A1A2E)),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 12,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryDark,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    textTheme: _textTheme(const Color(0xFFE8EAF6)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF21262D),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryDark,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF161B22),
    ),
  );
}
