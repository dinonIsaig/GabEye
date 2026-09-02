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

  // Result state colors (UX audit 2.1)
  static const Color resultAboveTypicalColor = Color(0xFFDC2626); // Red
  static const Color resultModerateColor = Color(0xFFEA580C);     // Orange
  static const Color resultNormalColor = Color(0xFF16A34A);       // Green
  static const Color resultUnidentifiedColor = Color(0xFF64748B); // Gray

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
  
  // To be Removed
  static const Color warningYellow = Color(0xFFD39201);
  
  // UI Elements
  static const Color darkPrimaryButton = Color(0xFFB0C6D9);
  static const Color borderDark = Color(0xFF8A8BA2);

  // Shared UI state tokens
  static const Color disabledButton = Color(0xFFE5E7EB);
  static const Color disabledText = Color(0xFF6B7684);

  // Alt Surfaces
  static const Color altLightSurface   = Color(0xFFF2F6FA);
  static const Color altDarkSurface   = Color(0xFF232B36);

  // Info Cards & Accents
  static const Color lightInfo = Color(0xFF1D4E82);
  static const Color darkInfo = Color(0xFF6E93B8);

  // Homepage / Design Tokens
  static const Color primaryNavy = Color(0xFF14395F);
  static const Color deepNavy = Color(0xFF0F2C4C);
  static const Color accentBlue = Color(0xFF1D4E82);
  static const Color mutedAccent = Color(0xFF2C4670);
  static const Color cardBorder = Color(0xFF6E6E6E);
  static const Color iconChipTint = Color(0x1A00327D); // rgba(0,50,125,0.1)
  static const Color headingText = Color(0xFF12161C);
  static const Color bodyText = Color(0xFF434653);
}