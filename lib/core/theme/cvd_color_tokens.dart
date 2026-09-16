import 'package:flutter/material.dart';

/// Which color-vision-deficiency lens the UI's color cues should be tuned
/// for. `none` is the default (unmodified) palette; the other three mirror
/// the Farnsworth D-15 diagnosis axes in [ColorDeficiencyType].
enum CvdProfile { none, protan, deutan, tritan }

/// One resolved set of "cue" colors — the tokens exported from Figma
/// (gabeye color.zip) that actually move between color-vision profiles.
/// Everything else (background, surface, text) is identical across
/// profiles and stays in [AppColors].
@immutable
class CvdColorSet {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color border;
  final Color primaryButton;

  const CvdColorSet({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
    required this.primaryButton,
  });
}

/// Token source of truth, transcribed from the Figma variable export
/// (`Light`, `Dark`, `Protan/Deutan/Tritan (Light|Dark)` token files).
class CvdColorTokens {
  CvdColorTokens._();

  static const Map<CvdProfile, CvdColorSet> light = {
    CvdProfile.none: CvdColorSet(
      success: Color(0xFF009E73),
      warning: Color(0xFFD39201),
      error: Color(0xFFA33612),
      info: Color(0xFF1D4E82),
      border: Color(0xFF31363D),
      primaryButton: Color(0xFF14395F),
    ),
    CvdProfile.protan: CvdColorSet(
      success: Color(0xFF12879A),
      warning: Color(0xFFD39201),
      error: Color(0xFFC81E62),
      info: Color(0xFF14395F),
      border: Color(0xFF31363D),
      primaryButton: Color(0xFF14395F),
    ),
    CvdProfile.deutan: CvdColorSet(
      success: Color(0xFF12879A),
      warning: Color(0xFFD39201),
      error: Color(0xFFC81E62),
      info: Color(0xFF14395F),
      border: Color(0xFF6B7684),
      primaryButton: Color(0xFF14395F),
    ),
    CvdProfile.tritan: CvdColorSet(
      success: Color(0xFF009E73),
      warning: Color(0xFFD39201),
      error: Color(0xFFA33612),
      info: Color(0xFF14395F),
      border: Color(0xFF6B7684),
      primaryButton: Color(0xFF14395F),
    ),
  };

  static const Map<CvdProfile, CvdColorSet> dark = {
    CvdProfile.none: CvdColorSet(
      success: Color(0xFF009E73),
      warning: Color(0xFFD39201),
      error: Color(0xFFA33612),
      info: Color(0xFF6E93B8),
      border: Color(0xFF8A8BA2),
      primaryButton: Color(0xFFB0C6D9),
    ),
    CvdProfile.protan: CvdColorSet(
      success: Color(0xFF12879A),
      warning: Color(0xFFD39201),
      error: Color(0xFFC81E62),
      info: Color(0xFF6E93B8),
      border: Color(0xFF8A8BA2),
      primaryButton: Color(0xFF6E93B8),
    ),
    CvdProfile.deutan: CvdColorSet(
      success: Color(0xFF12879A),
      warning: Color(0xFFE69F00),
      error: Color(0xFFC81E62),
      info: Color(0xFF6E93B8),
      border: Color(0xFF384250),
      primaryButton: Color(0xFF6E93B8),
    ),
    CvdProfile.tritan: CvdColorSet(
      success: Color(0xFF009E73),
      warning: Color(0xFFD39201),
      error: Color(0xFFA33612),
      info: Color(0xFF6E93B8),
      border: Color(0xFF384250),
      primaryButton: Color(0xFF6E93B8),
    ),
  };

  static CvdColorSet resolve(Brightness brightness, CvdProfile profile) {
    final map = brightness == Brightness.dark ? dark : light;
    return map[profile]!;
  }
}
