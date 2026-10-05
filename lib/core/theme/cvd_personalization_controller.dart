import 'package:flutter/material.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/data/local/database_helper.dart';
import 'package:gabeye/data/models/adaptive_ui_settings.dart';
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
  bool _testInProgress = false;

  /// The current diagnosis, from either VisionProfileService (persisted) or AssessmentController (active session).
  ColorDeficiencyType? get diagnosisType {
    if (VisionProfileService.instance.value != null) {
      return VisionProfileService.instance.value!.diagnosisType;
    }
    return assessmentController.hasTakenAssessment
        ? assessmentController.currentResult.diagnosisType
        : null;
  }

  bool get isSupported => !_testInProgress && diagnosisType?.personalizableProfile != null;

  /// Whether the user has switched personalization on. Always `false` when
  /// [isSupported] is `false`, no matter what was set before.
  bool get isEnabled => _enabled && isSupported;

  CvdProfile get activeProfile =>
      isEnabled ? diagnosisType!.personalizableProfile! : CvdProfile.none;

  void setEnabled(bool enabled) {
    if (!isSupported) return;
    _enabled = enabled;
    notifyListeners();
    DatabaseHelper.instance.saveUiSettings(
      AdaptiveUiSettings(
        userId: 1,
        appliedTheme: activeProfile.name,
        colorAgnosticMode: isEnabled,
      ),
    );
  }

  void hydrateFromDatabase({required bool enabled}) {
    _enabled = enabled;
    notifyListeners();
  }

  void resetForNewAttempt() {
    _enabled = false;
    notifyListeners();
  }

  /// Locks personalization off while the assessment (cap-sorting) screen
  /// is on screen. Call with `true` from its `initState`.
  void setTestInProgress(bool inProgress) {
    _testInProgress = inProgress;
    if (_testInProgress) _enabled = false;
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