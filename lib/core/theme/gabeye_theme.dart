import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';



class GabEyeTheme {

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightSurface,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimaryButton,
      onPrimary: AppColors.lightPrimaryButton,
      surface: AppColors.lightSurface,
      surfaceContainer: AppColors.altLightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.errorRed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimaryButton,
        foregroundColor: AppColors.lightSurface,
        disabledBackgroundColor: AppColors.disabledButton,
        disabledForegroundColor: AppColors.disabledText,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      titleLarge: TextStyle(color: AppColors.lightTextPrimary),
      labelLarge: TextStyle(color: AppColors.lightTextPrimary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkMode,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.darkTextSecondary,
      surface: AppColors.darkMode,
      surfaceContainer: AppColors.altDarkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.errorRed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryButton,
        foregroundColor: AppColors.darkSurface,
        disabledBackgroundColor: AppColors.disabledButton,
        disabledForegroundColor: AppColors.disabledText,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      titleLarge: TextStyle(color: AppColors.darkTextPrimary),
      labelLarge: TextStyle(color: AppColors.darkTextPrimary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkMode,
    ),
  );


}


