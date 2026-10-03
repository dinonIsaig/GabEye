import 'package:flutter/foundation.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

/// Central singleton controller for storing and listening to the latest
/// Farnsworth D-15 assessment result across the app (Profile tab, Lookback, etc.).
class AssessmentController extends ValueNotifier<List<int>> {
  AssessmentController()
      : super(const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

  bool _hasTakenAssessment = false;

  /// Returns true if the user has completed at least one assessment during this session.
  bool get hasTakenAssessment => _hasTakenAssessment;

  /// The computed D-15 score result for the current cap arrangement.
  D15ScoreResult get currentResult => ScoringService.calculateScore(value);

  /// Updates the stored cap arrangement and notifies all listeners (e.g. Profile tab).
  void setArrangedCaps(List<int> caps) {
    _hasTakenAssessment = true;
    value = List<int>.unmodifiable(caps);
  }

  /// Resets the assessment back to the default (Normal vision) arrangement.
  void reset() {
    _hasTakenAssessment = false;
    value = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  }
}

/// Global instance of [AssessmentController].
final AssessmentController assessmentController = AssessmentController();
