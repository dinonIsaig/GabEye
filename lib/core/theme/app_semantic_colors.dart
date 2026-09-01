import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class AppSemanticColors {
  AppSemanticColors._();

  // Diagnosis-type colors
  static const Color royal = Color(0xFF01408F);
  static const Color lemon = Color(0xFFF5CB20); 
  static const Color beige = Color(0xFFB8A484); 
  static const Color tritan = Color(0xFF3B82F6); 
  static const Color teal = Color(0xFF018F8F);
  static const Color salmon = Color(0xFFF59D9F);
  static const Color darkgray = Color(0xFF4E4E4E);
  static const Color gray = Color(0xFF929292);
  static const Color lightgray = Color(0xFFC7C7C7);
  static const Color red = Color(0xFFDB0303);
  static const Color orange = Color(0xFFFB8721);
  static const Color murky = Color(0xFF9F8E29);


  // Confusion-line error severity
  static const Color majorError = Color(0xFFF43F5E); 
  static const Color minorError = AppColors.successGreen;

  // Result severity band colors (Normal / Moderate / Strong)
  static const Color severityNormal = AppColors.successGreen;
  static const Color severityModerate = AppColors.warning;
  static const Color severityStrong = AppColors.errorRed;
}