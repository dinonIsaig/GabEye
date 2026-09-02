import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

/// Central singleton service that holds the user's Farnsworth D-15 assessment result
/// and feeds calibrated input parameters (type & severity intensity) to the GLSL Daltonization shader.
class VisionProfileService extends ValueNotifier<D15ScoreResult?> {
  VisionProfileService._() : super(null);

  static final VisionProfileService instance = VisionProfileService._();

  List<int> _arrangedCaps = List.generate(15, (i) => i + 1);

  /// Get arranged cap sequence from latest assessment
  List<int> get arrangedCaps => _arrangedCaps;

  /// Save the D-15 assessment result to calibrate Daltonization shaders
  void updateAssessmentResult(D15ScoreResult result, {List<int>? arrangedCaps}) {
    if (arrangedCaps != null) {
      _arrangedCaps = List<int>.from(arrangedCaps);
    }
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

  /// Get calibrated Daltonization shift intensity based on D-15 assessment severity.
  /// - Moderate severity: proportional shift (~0.50 - 0.65 intensity)
  /// - Strong / Severe: maximum shift (1.0 intensity)
  /// - Normal vision: 0.0 shift
  double get shaderIntensity {
    if (value == null) return 0.70; // Unassessed default
    if (value!.diagnosisType == ColorDeficiencyType.normal) return 0.0;

    switch (value!.severity) {
      case SeverityLevel.none:
        return 0.0;
      case SeverityLevel.moderate:
        // Proportional calibration based on cIndex: moderate range ~ 0.50 - 0.65
        final double rawRatio = (value!.cIndex - 1.5) / 1.5;
        return rawRatio.clamp(0.50, 0.65);
      case SeverityLevel.strong:
        // Max calibration for severe deficiency
        return 1.0;
    }
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
