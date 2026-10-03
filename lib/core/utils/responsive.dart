import 'package:flutter/material.dart';

/// Screen-size breakpoints for GabEye.
///
/// Use these when a screen needs a different layout structure (e.g. Row vs Column,
/// different flex ratios, or conditional widgets) rather than just fluid scaling.
class AppBreakpoints {
  /// Small phones (iPhone SE, older Android phones ~320–360 logical px wide).
  static const double compact = 360;

  /// Standard modern phones (~375–430 logical px wide).
  static const double medium = 400;

  /// Phablets, tablets, and desktop/web screens (600+ logical px wide).
  static const double expanded = 600;

  /// Returns true if the screen width is less than [compact].
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  /// Returns true if the screen width is between [compact] and [expanded].
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < expanded;
  }

  /// Returns true if the screen width is at or above [expanded].
  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;

  /// Direct equivalent of a CSS media-query value ladder.
  ///
  /// Evaluates screen width and returns [expandedValue] if >= 600,
  /// [mediumValue] (or [compactValue] if [mediumValue] is omitted) if >= 360,
  /// and [compactValue] otherwise.
  static T value<T>(
    BuildContext context, {
    required T compactValue,
    T? mediumValue,
    required T expandedValue,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expanded) return expandedValue;
    if (width >= compact && mediumValue != null) return mediumValue;
    return compactValue;
  }
}

/// Responsive layout utilities for fluid scaling and bounds checking in Flutter.
///
/// Implements the Flutter equivalent of CSS `clamp(min, preferred, max)` based
/// on a 375 logical pixel standard phone reference width.
class Responsive {
  /// Standard reference width used in design (iPhone 14/15 reference device).
  static const double referenceWidth = 375.0;

  /// Calculates a fluid font size clamped between [min] and [max].
  ///
  /// - [base] is the original designed font size.
  /// - [min] defaults to `base * 0.85` (-15%) if not specified.
  /// - [max] defaults to `base * 1.25` (+25%) if not specified.
  static double font(
    BuildContext context, {
    required double base,
    double? min,
    double? max,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / referenceWidth;
    final rawMin = min ?? (base * 0.85);
    final rawMax = max ?? (base * 1.25);
    final effectiveMin = rawMin <= rawMax ? rawMin : rawMax;
    final effectiveMax = rawMin <= rawMax ? rawMax : rawMin;
    final calculated = base * scale;
    return calculated.clamp(effectiveMin, effectiveMax);
  }

  /// Calculates a fluid spacing/gap/padding value clamped between [min] and [max].
  ///
  /// - [base] is the original designed spacing value.
  /// - [min] defaults to `base * 0.70` (-30%) if not specified.
  /// - [max] defaults to `base * 1.50` (+50%) if not specified.
  static double space(
    BuildContext context, {
    required double base,
    double? min,
    double? max,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / referenceWidth;
    final rawMin = min ?? (base * 0.70);
    final rawMax = max ?? (base * 1.50);
    final effectiveMin = rawMin <= rawMax ? rawMin : rawMax;
    final effectiveMax = rawMin <= rawMax ? rawMax : rawMin;
    final calculated = base * scale;
    return calculated.clamp(effectiveMin, effectiveMax);
  }

  /// Returns [EdgeInsets.symmetric] with horizontal fluid padding.
  static EdgeInsets symmetricH(
    BuildContext context, {
    required double base,
    double? min,
    double? max,
  }) {
    return EdgeInsets.symmetric(
      horizontal: space(context, base: base, min: min, max: max),
    );
  }

  /// Returns [EdgeInsets.symmetric] with vertical fluid padding.
  static EdgeInsets symmetricV(
    BuildContext context, {
    required double base,
    double? min,
    double? max,
  }) {
    return EdgeInsets.symmetric(
      vertical: space(context, base: base, min: min, max: max),
    );
  }

  /// Returns [EdgeInsets.all] with fluid padding on all sides.
  static EdgeInsets all(
    BuildContext context, {
    required double base,
    double? min,
    double? max,
  }) {
    return EdgeInsets.all(
      space(context, base: base, min: min, max: max),
    );
  }

  /// Returns [EdgeInsets.only] with fluid padding on specified non-zero sides.
  static EdgeInsets only(
    BuildContext context, {
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left > 0 ? space(context, base: left) : 0,
      top: top > 0 ? space(context, base: top) : 0,
      right: right > 0 ? space(context, base: right) : 0,
      bottom: bottom > 0 ? space(context, base: bottom) : 0,
    );
  }

  /// Constrains content to a maximum width (default 600) and centers it.
  ///
  /// Prevents content from stretching full-bleed on large screens and tablets.
  static Widget constrainWidth(
    BuildContext context, {
    required Widget child,
    double maxWidth = 600,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
