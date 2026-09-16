import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

/// Central singleton service that holds the user's Farnsworth D-15 assessment result
/// and feeds calibrated input parameters (type & severity intensity) to the GLSL Daltonization shader.
class VisionProfileService extends ValueNotifier<D15ScoreResult?> {
  VisionProfileService._() : super(null);

  static final VisionProfileService instance = VisionProfileService._();

  List<int> _arrangedCaps = List.generate(15, (i) => i + 1);
  double? _customIntensityOverride;

  /// Get arranged cap sequence from latest assessment
  List<int> get arrangedCaps => _arrangedCaps;

  /// Custom intensity slider value or calibrated shader intensity
  double get customIntensityOverride => _customIntensityOverride ?? shaderIntensity;

  /// Update manual shift intensity override from Profile slider
  void setCustomIntensityOverride(double val) {
    _customIntensityOverride = val;
    notifyListeners();
  }

  /// Save the D-15 assessment result to calibrate Daltonization shaders
  void updateAssessmentResult(D15ScoreResult result, {List<int>? arrangedCaps}) {
    if (arrangedCaps != null) {
      _arrangedCaps = List<int>.from(arrangedCaps);
    }
    _customIntensityOverride = null; // reset override to use new assessment calibration
    value = result;
  }

  /// Map D-15 diagnosis result to GLSL float input (uType uniform)
  /// 0.0 = Protanopia, 1.0 = Deuteranopia, 2.0 = Tritanopia, 3.0 = Normal Vision
  double get shaderType {
    if (value == null) return 1.0; // Default to Deutan if unassessed
    switch (value!.diagnosisType) {
      case ColorDeficiencyType.protan:
        return 0.0;
      case ColorDeficiencyType.deutan:
        return 1.0;
      case ColorDeficiencyType.tritan:
        return 2.0;
      case ColorDeficiencyType.normal:
      case ColorDeficiencyType.unclassified:
      case ColorDeficiencyType.random:
        return 3.0;
    }
  }

  /// The static recommended intensity calculated strictly from D-15 assessment severity.
  double get recommendedIntensity {
    if (value == null) return 0.50; // Unassessed default baseline (50%)
    if (value!.diagnosisType == ColorDeficiencyType.normal) return 0.0;

    switch (value!.severity) {
      case SeverityLevel.none:
        return 0.0;
      case SeverityLevel.moderate:
        // Range for Moderate: 40% to 65% (0.40 to 0.65)
        final double rawRatio = (value!.cIndex - 1.0) / 1.5;
        return rawRatio.clamp(0.40, 0.65);
      case SeverityLevel.strong:
        // Range for Severe / Strong: 70% to 100% (0.70 to 1.00)
        final double rawRatio = 0.70 + ((value!.cIndex - 2.5) / 1.5) * 0.30;
        return rawRatio.clamp(0.70, 1.00);
    }
  }

  /// Recommended intensity range label for display (40%–65% for Moderate, 70%–100% for Severe).
  String get recommendedRangeLabel {
    if (value == null) return '40%–65%';
    if (value!.diagnosisType == ColorDeficiencyType.normal) return '0%';

    switch (value!.severity) {
      case SeverityLevel.none:
        return '0%';
      case SeverityLevel.moderate:
        return '40%–65%';
      case SeverityLevel.strong:
        return '70%–100%';
    }
  }

  /// Get calibrated Daltonization shift intensity based on D-15 assessment severity or manual override.
  double get shaderIntensity {
    return _customIntensityOverride ?? recommendedIntensity;
  }

  /// Human-readable profile label with severity
  String get activeProfileLabel {
    if (value == null) return 'Deuteranopia (Default)';
    if (value!.diagnosisType == ColorDeficiencyType.normal) return 'Normal Vision';
    return '${value!.shortName} • ${value!.severityLabel}';
  }

  /// Short severity label
  String get severityLabel {
    if (value == null) return 'Moderate';
    return value!.severityLabel;
  }

  /// Whether the user has completed a D-15 assessment
  bool get hasCompletedAssessment => value != null;
}
