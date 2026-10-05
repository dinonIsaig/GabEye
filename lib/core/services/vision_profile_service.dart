import 'package:flutter/material.dart';
import 'package:gabeye/data/local/database_helper.dart';
import 'package:gabeye/data/models/adaptive_ui_settings.dart';
import 'package:gabeye/data/models/diagnostic_data.dart';
import 'package:gabeye/features/assessment/services/assessment_controller.dart';
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

  /// Hydrate VisionProfileService and linked controllers from local SQLite database.
  Future<void> loadFromDatabase() async {
    try {
      final diagnosticData = await DatabaseHelper.instance.getDiagnosticData(1);
      if (diagnosticData != null && diagnosticData.hasTakenTest && diagnosticData.cvdType != null) {
        final ColorDeficiencyType type = ColorDeficiencyType.values.firstWhere(
          (t) => t.name.toLowerCase() == diagnosticData.cvdType!.toLowerCase(),
          orElse: () => ColorDeficiencyType.deutan,
        );

        final SeverityLevel severity = SeverityLevel.values.firstWhere(
          (s) => s.name.toLowerCase() == (diagnosticData.severity ?? '').toLowerCase(),
          orElse: () => SeverityLevel.moderate,
        );

        value = _reconstituteResult(type, severity);
        assessmentController.setAssessmentCompleted(hasCompleted: true);
      }

      final uiSettings = await DatabaseHelper.instance.getUiSettings(1);
      if (uiSettings != null) {
        // Update color agnostic mode state
        // (cvdPersonalizationController handles activeProfile based on this)
      }
    } catch (e) {
      debugPrint('VisionProfileService.loadFromDatabase error: $e');
    }
  }

  /// Save the D-15 assessment result to calibrate Daltonization shaders and persist to SQLite.
  void updateAssessmentResult(D15ScoreResult result, {List<int>? arrangedCaps}) {
    if (arrangedCaps != null) {
      _arrangedCaps = List<int>.from(arrangedCaps);
    }
    _customIntensityOverride = null; // reset override to use new assessment calibration
    value = result;

    // Persist assessment result to SQLite asynchronously
    _persistAssessmentResult(result);
  }

  Future<void> _persistAssessmentResult(D15ScoreResult result) async {
    try {
      await DatabaseHelper.instance.saveDiagnosticData(
        DiagnosticData(
          userId: 1,
          hasTakenTest: true,
          cvdType: result.diagnosisType.name,
          severity: result.severity.name,
          testDate: DateTime.now(),
        ),
      );

      await DatabaseHelper.instance.saveUiSettings(
        AdaptiveUiSettings(
          userId: 1,
          appliedTheme: result.diagnosisType.name,
          colorAgnosticMode: true,
        ),
      );
    } catch (e) {
      debugPrint('VisionProfileService._persistAssessmentResult error: $e');
    }
  }

  D15ScoreResult _reconstituteResult(ColorDeficiencyType type, SeverityLevel severity) {
    String name = 'Deuteranopia / Deuteranomaly';
    String shortName = 'Deutan';
    String cones = 'M-Cone Photoreceptor Defect (Green-Weak)';
    String conesShort = 'M-Cones';
    String desc = 'Your color arrangement indicates reduced sensitivity in the M-cones (medium wavelength).';
    String tip = 'Use GabEye Daltonization and high-contrast cues to differentiate red and green elements.';

    switch (type) {
      case ColorDeficiencyType.protan:
        name = 'Protanopia / Protanomaly';
        shortName = 'Protan';
        cones = 'L-Cone Photoreceptor Defect (Red-Weak)';
        conesShort = 'L-Cones';
        desc = 'Your color arrangement indicates reduced sensitivity in the L-cones (long wavelength).';
        tip = 'Red hues may appear darker or brownish; use the Protan Daltonization mode.';
        break;
      case ColorDeficiencyType.deutan:
        name = 'Deuteranopia / Deuteranomaly';
        shortName = 'Deutan';
        cones = 'M-Cone Photoreceptor Defect (Green-Weak)';
        conesShort = 'M-Cones';
        desc = 'Your color arrangement indicates reduced sensitivity in the M-cones (medium wavelength).';
        tip = 'Green hues may blend with reddish-browns; use the Deutan Daltonization mode.';
        break;
      case ColorDeficiencyType.tritan:
        name = 'Tritanopia / Tritanomaly';
        shortName = 'Tritan';
        cones = 'S-Cone Photoreceptor Defect (Blue-Weak)';
        conesShort = 'S-Cones';
        desc = 'Your color arrangement indicates reduced sensitivity in the S-cones (short wavelength).';
        tip = 'Blue and yellow hues may be confused; use the Tritan Daltonization mode.';
        break;
      case ColorDeficiencyType.normal:
        name = 'Normal Color Vision';
        shortName = 'Normal';
        cones = 'Normal Trichromatic Photoreceptors';
        conesShort = 'Normal';
        desc = 'Your cap arrangement closely matches what is expected for standard color vision.';
        tip = 'No color correction required.';
        break;
      case ColorDeficiencyType.unclassified:
      case ColorDeficiencyType.random:
        name = 'Unclassified / Random Errors';
        shortName = 'Unclassified';
        cones = 'Non-Specific General Color Confusion';
        conesShort = 'Non-Specific';
        desc = 'Your color arrangement shows scattered errors without a single clear axis.';
        tip = 'Retesting in consistent, standard lighting is recommended.';
        break;
    }

    final double cIndex = severity == SeverityLevel.strong
        ? 3.2
        : (severity == SeverityLevel.moderate ? 2.0 : 1.0);

    return D15ScoreResult(
      cIndex: cIndex,
      sIndex: 1.0,
      angle: 0.0,
      majorRadius: 1.0,
      minorRadius: 1.0,
      totalError: 100.0,
      diagnosisType: type,
      diagnosisName: name,
      shortName: shortName,
      conesAffected: cones,
      conesShortLabel: conesShort,
      description: desc,
      crossings: const [],
      severity: severity,
      severityLabel: severity == SeverityLevel.strong
          ? 'Strong'
          : (severity == SeverityLevel.moderate ? 'Moderate' : 'Normal'),
      rangeHeadline: severity != SeverityLevel.none
          ? 'Your result is above the typical range.'
          : 'Your result is within the typical range.',
      rangeBody: severity != SeverityLevel.none
          ? 'Your caps arrangement shows a measurable deviation from the typical range.'
          : 'Your cap arrangement closely matches normal vision.',
      practicalTip: tip,
    );
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

  /// Clears the stored result and returns calibration to the unassessed
  /// default. Call this whenever a new assessment attempt starts (e.g.
  /// "Take Assessment", "Retake D-15")
  void clearAssessmentResult() {
    _arrangedCaps = List.generate(15, (i) => i + 1);
    _customIntensityOverride = null;
    value = null;
  }
}