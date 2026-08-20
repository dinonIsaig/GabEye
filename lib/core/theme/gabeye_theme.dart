import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class GabEyeTheme {
  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      bodyMedium: TextStyle( //body
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        height: 1.5,
      ),
      bodyLarge: TextStyle( //body-bold
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      titleLarge: TextStyle( //heading
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
      labelLarge: TextStyle( //caption
        color: color,
        fontFamily: 'AtkinsonHyperlegible',
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'AtkinsonHyperlegible',
    scaffoldBackgroundColor: AppColors.lightSurface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimaryButton,
      onPrimary: AppColors.lightPrimaryButton,
      surface: AppColors.lightSurface,
      surfaceContainer: AppColors.altLightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.errorRed,
      tertiary: AppColors.lightInfo,
      outline: AppColors.borderLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimaryButton,
        foregroundColor: AppColors.lightSurface,
        disabledBackgroundColor: AppColors.disabledButton,
        disabledForegroundColor: AppColors.disabledText,
      ),
    ),
    textTheme: _buildTextTheme(AppColors.lightTextPrimary),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'AtkinsonHyperlegible',
    scaffoldBackgroundColor: AppColors.darkMode,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.darkTextSecondary,
      surface: AppColors.darkSurface,
      surfaceContainer: AppColors.altDarkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.errorRed,
      tertiary: AppColors.darkInfo,
      outline: AppColors.borderDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryButton,
        surfaceTintColor: AppColors.lightTextSecondary,
        foregroundColor: AppColors.darkSurface,
        disabledBackgroundColor: AppColors.disabledButton,
        disabledForegroundColor: AppColors.disabledText,
      ),
    ),
    textTheme: _buildTextTheme(AppColors.darkTextPrimary),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkMode,
    ),
  );


}


