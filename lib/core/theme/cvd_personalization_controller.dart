import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/services/assessment_controller.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

import 'cvd_color_tokens.dart';

/// Which [CvdProfile] a given assessment diagnosis should personalize the
/// UI with, if any. Only protan/deutan/tritan have a matching profile —
/// normal vision, unclassified, and random/anarchic results don't, so the
/// "Personalize UI" toggle stays disabled for them.
extension CvdPersonalizableProfile on ColorDeficiencyType {
  CvdProfile? get personalizableProfile {
    switch (this) {
      case ColorDeficiencyType.protan:
        return CvdProfile.protan;
      case ColorDeficiencyType.deutan:
        return CvdProfile.deutan;
      case ColorDeficiencyType.tritan:
        return CvdProfile.tritan;
      case ColorDeficiencyType.normal:
      case ColorDeficiencyType.unclassified:
      case ColorDeficiencyType.random:
        return null;
    }
  }
}

class CvdPersonalizationController extends ChangeNotifier {
  CvdPersonalizationController() {
    assessmentController.addListener(_onAssessmentChanged);
  }

  bool _enabled = false;

  /// The current diagnosis, or null if no assessment has been taken yet
  /// this session.
  ColorDeficiencyType? get diagnosisType => assessmentController.hasTakenAssessment
      ? assessmentController.currentResult.diagnosisType
      : null;

  /// Whether personalization is usable right now: an assessment must have
  /// been taken, and its diagnosis must map to a supported [CvdProfile].
  /// Normal vision, unclassified, and random results are excluded.
  bool get isSupported => diagnosisType?.personalizableProfile != null;

  /// Whether the user has switched personalization on. Always `false` when
  /// [isSupported] is `false`, no matter what was set before.
  bool get isEnabled => _enabled && isSupported;

  CvdProfile get activeProfile =>
      isEnabled ? diagnosisType!.personalizableProfile! : CvdProfile.none;


  void setEnabled(bool enabled) {
    if (!isSupported) return;
    _enabled = enabled;
    notifyListeners();
  }

  void resetForNewAttempt() {
    _enabled = false;
    notifyListeners();
  }

  void _onAssessmentChanged() {
    _enabled = false;
    notifyListeners();
  }

  @override
  void dispose() {
    assessmentController.removeListener(_onAssessmentChanged);
    super.dispose();
  }
}

final CvdPersonalizationController cvdPersonalizationController =
    CvdPersonalizationController();