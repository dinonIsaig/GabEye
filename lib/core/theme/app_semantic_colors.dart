import 'package:flutter/material.dart';

/// Diagnosis-axis identity palette. These represent the fixed confusion-line
/// axes of the D-15 test itself (not result severity or pass/fail cues), so
/// they stay constant regardless of CVD personalization — see
/// GabEyeSemanticColors for the cue colors that do change.
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
}