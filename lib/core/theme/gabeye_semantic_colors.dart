import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'cvd_color_tokens.dart';

/// The single source of truth for GabEye's "cue" colors (success/warning/
/// error/info/border/primaryButton). Every screen should read these from
/// [BuildContext.semanticColors] instead of reaching into [AppColors]
/// directly, so that swapping [CvdProfile] (personalization) only ever
/// requires changing what's registered here.
@immutable
class GabEyeSemanticColors extends ThemeExtension<GabEyeSemanticColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color border;
  final Color primaryButton;

  /// Neutral gray used when no diagnosis-based color cue applies
  /// (unclassified/random results). Constant across every CVD profile.
  final Color unidentified;

  const GabEyeSemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
    required this.primaryButton,
    required this.unidentified,
  });

  factory GabEyeSemanticColors.fromTokens(CvdColorSet tokens) {
    return GabEyeSemanticColors(
      success: tokens.success,
      warning: tokens.warning,
      error: tokens.error,
      info: tokens.info,
      border: tokens.border,
      primaryButton: tokens.primaryButton,
      unidentified: AppColors.resultUnidentifiedColor,
    );
  }

  @override
  GabEyeSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? border,
    Color? primaryButton,
    Color? unidentified,
  }) {
    return GabEyeSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      border: border ?? this.border,
      primaryButton: primaryButton ?? this.primaryButton,
      unidentified: unidentified ?? this.unidentified,
    );
  }

  @override
  GabEyeSemanticColors lerp(GabEyeSemanticColors? other, double t) {
    if (other == null) return this;
    return GabEyeSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryButton: Color.lerp(primaryButton, other.primaryButton, t)!,
      unidentified: Color.lerp(unidentified, other.unidentified, t)!,
    );
  }
}

/// Tonal variants for the "error accent" card style (red strip/background/
/// border) used across the featured-reads notes. Consolidates a pattern
/// that used to be duplicated with slightly different hand-rolled dark-mode
/// overrides in several screens.
@immutable
class GabEyeErrorAccentTones {
  final Color accent;
  final Color background;
  final Color border;

  const GabEyeErrorAccentTones({
    required this.accent,
    required this.background,
    required this.border,
  });
}

extension GabEyeThemeContext on BuildContext {
  GabEyeSemanticColors get semanticColors =>
      Theme.of(this).extension<GabEyeSemanticColors>()!;

  GabEyeErrorAccentTones get errorAccentTones {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    final error = semanticColors.error;
    // Dark mode uses a lighter, higher-contrast accent tone (Material 3
    // style) rather than the raw token, which is tuned for light surfaces.
    final accent = isDark ? const Color(0xFFFFB4AB) : error;
    return GabEyeErrorAccentTones(
      accent: accent,
      background: isDark
          ? error.withValues(alpha: 0.18)
          : error.withValues(alpha: 0.08),
      border: isDark
          ? accent.withValues(alpha: 0.35)
          : error.withValues(alpha: 0.25),
    );
  }
}
