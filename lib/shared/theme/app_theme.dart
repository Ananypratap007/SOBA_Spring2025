import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const lightBackgroundColor = Color(0xFFFFFFFF);
  static const lightPrimaryColor = Color(0xFF003366);
  static const lightSecondaryColor = Color(0xFF4CAF93);
  static const lightAccentColor = Color(0xFFFF6F61);
  static const lightPrimaryTextColor = Color(0xFF000000);
  static const lightOnPrimaryColor = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const darkBackgroundColor = Color(0xFF121212);
  static const darkPrimaryColor = Color(0xFF0A58CA);
  static const darkSecondaryColor = Color(0xFF34C759);
  static const darkAccentColor = Color(0xFFFF6B4D);
  static const darkPrimaryTextColor = Color(0xFFFFFFFF);
  static const darkOnPrimaryColor = Color(0xFF000000);
}

abstract class _ThemeColors {
  Color get background;
  Color get primary;
  Color get secondary;
  Color get accent;
  Color get text;
  Color get onPrimary;
}

class _LightColors extends _ThemeColors {
  @override
  Color get background => AppColors.lightBackgroundColor;
  @override
  Color get primary => AppColors.lightPrimaryColor;
  @override
  Color get secondary => AppColors.lightSecondaryColor;
  @override
  Color get accent => AppColors.lightAccentColor;
  @override
  Color get text => AppColors.lightPrimaryTextColor;
  @override
  Color get onPrimary => AppColors.lightOnPrimaryColor;
}

class _DarkColors extends _ThemeColors {
  @override
  Color get background => AppColors.darkBackgroundColor;
  @override
  Color get primary => AppColors.darkPrimaryColor;
  @override
  Color get secondary => AppColors.darkSecondaryColor;
  @override
  Color get accent => AppColors.darkAccentColor;
  @override
  Color get text => AppColors.darkPrimaryTextColor;
  @override
  Color get onPrimary => AppColors.darkOnPrimaryColor;
}

class AppTheme {
  static ThemeData get lightTheme => _themeFromColors(isDark: false);
  static ThemeData get darkTheme => _themeFromColors(isDark: true);

  static ThemeData _themeFromColors({required bool isDark}) {
    final colors = isDark ? _DarkColors() : _LightColors();
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.background,
        error: colors.accent,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onPrimary,
        onSurface: colors.text,
        onError: colors.onPrimary,
        brightness: brightness,
      ),
      textTheme: _textTheme(colors.text, colors.onPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.primary,
        size: 24,
      ),
      dividerTheme: DividerThemeData(
        color: colors.secondary.withOpacity(0.2),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.secondary),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor, Color onPrimaryColor) {
    return TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 16),
      bodyMedium: TextStyle(color: textColor, fontSize: 14),
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: onPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
