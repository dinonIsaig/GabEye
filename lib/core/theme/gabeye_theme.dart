import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/theme/cvd_color_tokens.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';

class GabEyeTheme {
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 34,
        height: 1.3,
        color: color,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 30,
        height: 1.3,
        color: color,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 26,
        height: 1.3,
        color: color,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        height: 1.3,
        color: color,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 28,
        height: 1.5,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 24,
        height: 1.5,
        color: color,
      ),
      titleLarge: TextStyle( //heading
        color: color,
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: color,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: color,
      ),
      bodyLarge: TextStyle( //body-bold
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      bodyMedium: TextStyle( //body
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.5,
      ),
      labelLarge: TextStyle( //caption / button
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  static final ThemeData lightTheme = _buildLight(CvdProfile.none);
  static final ThemeData darkTheme = _buildDark(CvdProfile.none);

  /// Builds the theme for a given brightness + CVD personalization profile.
  /// `CvdProfile.none` reproduces today's default palette exactly.
  static ThemeData themeFor(Brightness brightness, CvdProfile profile) {
    return brightness == Brightness.dark
        ? _buildDark(profile)
        : _buildLight(profile);
  }

  static ThemeData _buildLight(CvdProfile profile) {
    final tokens = CvdColorTokens.resolve(Brightness.light, profile);
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'AtkinsonHyperlegible',
      scaffoldBackgroundColor: AppColors.lightSurface,
      colorScheme: ColorScheme.light(
        primary: tokens.primaryButton,
        onPrimary: tokens.primaryButton,
        surface: AppColors.lightSurface,
        surfaceContainer: AppColors.altLightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        error: tokens.error,
        tertiary: tokens.info,
        outline: tokens.border,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primaryButton,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primaryButton,
          foregroundColor: AppColors.lightSurface,
          disabledBackgroundColor: AppColors.disabledButton,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: tokens.primaryButton,
          side: BorderSide(color: tokens.border, width: 1),
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
      textTheme: _buildTextTheme(AppColors.lightTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
      ),
      extensions: [GabEyeSemanticColors.fromTokens(tokens)],
    );
  }

  static ThemeData _buildDark(CvdProfile profile) {
    final tokens = CvdColorTokens.resolve(Brightness.dark, profile);
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'AtkinsonHyperlegible',
      scaffoldBackgroundColor: AppColors.darkMode,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.darkTextSecondary,
        surface: AppColors.darkSurface,
        surfaceContainer: AppColors.altDarkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        error: tokens.error,
        tertiary: tokens.info,
        outline: tokens.border,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primaryButton,
          foregroundColor: AppColors.darkSurface,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primaryButton,
          surfaceTintColor: AppColors.lightTextSecondary,
          foregroundColor: AppColors.darkSurface,
          disabledBackgroundColor: AppColors.disabledButton,
          disabledForegroundColor: AppColors.disabledText,
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.altDarkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          side: BorderSide(color: tokens.border, width: 1),
          minimumSize: const Size(double.infinity, 55),
        ),
      ),
      textTheme: _buildTextTheme(AppColors.darkTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkMode,
      ),
      extensions: [GabEyeSemanticColors.fromTokens(tokens)],
    );
  }
}



