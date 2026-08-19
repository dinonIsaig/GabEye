import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primaryColor = Color(0xFF2C4670);

  // Semantic
  static const Color errorRed = Color(0xFF961320);
  static const Color errorOrange = Color(0xFFA33612);
  static const Color warning = Color(0xFFD39201);
  static const Color successGreen = Color(0xFF16A34A);

  // Light mode tokens
  static const Color lightSurface = Color(0xFFF7F9FB);
  static const Color lightMode = lightSurface;
  static const Color lightTextPrimary = Color(0xFF12161C);
  static const Color lightTextSecondary = Color(0xFF2B343F);
  static const Color lightPrimaryButton = Color(0xFF14395F);
  static const Color borderLight = Color(0xFF31363D);
  
  // Dark mode tokens
  static const Color darkSurface = Color(0xFF1B222B);
  static const Color darkMode = Color(0xFF12161C);
  static const Color darkTextPrimary = Color(0xFFF4F6F8);
  static const Color darkTextSecondary = Color(0xFFCAD3DE);
  static const Color darkPrimaryButton = Color(0xFFB0C6D9);
  static const Color borderDark = Color(0xFF8A8BA2);

  // Shared UI state tokens
  static const Color disabledButton = Color(0xFFE5E7EB);
  static const Color disabledText = Color(0xFF6B7684);

  // Alt Surfaces
  static const Color altLightSurface   = Color(0xFFF2F6FA);
  static const Color altDarkSurface   = Color(0xFF232B36);

  //Info Cards
  static const Color lightInfo = Color(0xFF1D4E82);
  static const Color darkInfo = Color(0xFF6E93B8);
}