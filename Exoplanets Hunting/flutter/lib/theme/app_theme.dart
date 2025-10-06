import 'package:flutter/material.dart';

class AppTheme {
  // Space/Galaxy themed colors
  static const Color primaryDark = Color(0xFF0A0A0A);
  static const Color secondaryDark = Color(0xFF1A1A2E);
  static const Color spaceBlue = Color(0xFF16213E);
  static const Color deepSpace = Color(0xFF0F0F23);
  static const Color nebulaPurple = Color(0xFF4A148C);
  static const Color cosmicBlue = Color(0xFF1A237E);
  static const Color starWhite = Color(0xFFFFFFFF);
  static const Color starYellow = Color(0xFFFFD700);
  static const Color planetRed = Color(0xFFE74C3C);
  static const Color planetBlue = Color(0xFF3498DB);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: primaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentPurple,
        surface: secondaryDark,
        // ignore: deprecated_member_use
        background: primaryDark,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textWhite,
        // ignore: deprecated_member_use
        onBackground: textWhite,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textGray,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textGray,
          fontSize: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}