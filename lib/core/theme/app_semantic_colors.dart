import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

// Centralized semantic colors used across the assessment result screens

class AppSemanticColors {
  AppSemanticColors._();

  // Diagnosis-type colors
  static const Color normal = AppColors.successGreen;
  static const Color protan = AppColors.errorRed;
  static const Color deutan = Color(0xFFF59E0B); // amber-500
  static const Color tritan = Color(0xFF3B82F6); // blue-500
  static const Color unclassified = Color.fromARGB(255, 94, 98, 105); // slate-400

  // Confusion-line error severity
  static const Color majorError = Color(0xFFF43F5E); // rose-500
  static const Color minorError = AppColors.successGreen;

  // Result severity band colors (Normal / Moderate / Strong)
  static const Color severityNormal = AppColors.successGreen;
  static const Color severityModerate = AppColors.warningYellow;
  static const Color severityStrong = AppColors.errorRed;
}