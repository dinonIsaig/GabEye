import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/config/diagnosis_presentation.dart';
import 'package:gabeye/features/assessment/screens/assessment_recommendations_screen.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
import 'package:gabeye/features/assessment/widgets/post_assessment_progressbar.dart';


class AssessmentKeyfindingsScreen extends StatelessWidget {
  final List<int> arrangedCaps;

  const AssessmentKeyfindingsScreen({
    super.key,
    required this.arrangedCaps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final D15ScoreResult result =
        ScoringService.calculateScore(arrangedCaps);
    final diagnosisStyle = diagnosisStyles[result.diagnosisType]!;

    return ProgressBarScaffold(
      currentStep: 2,
      totalSteps: 3,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeadingBanner(),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildKeyFindingsCard(
                          context,
                          colors,
                          diagnosisStyle,
                        ),
                        const SizedBox(height: 20),
                        _buildCloserLookCard(
                          context,
                          colors,
                          diagnosisStyle,
                        ),
                        const SizedBox(height: 20),


                        ElevatedButton.icon(
                          onPressed: () => _goToRecommendations(context),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize:
                                const Size(double.infinity, 55),
                          ),
                          label: const Text(
                            'Next',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          iconAlignment: IconAlignment.start,
                          icon: const Icon(Icons.arrow_back, size: 20),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colors.surfaceContainer,
                            foregroundColor: colors.onSurface,
                            side: BorderSide(
                              color: colors.outline,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize:
                                const Size(double.infinity, 55),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Key Findings --------------------

  Widget _buildKeyFindingsCard(
    BuildContext context,
    ColorScheme colors,
    DiagnosisStyle diagnosisStyle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.onSurfaceVariant.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What this means to you?',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Key Findings',
            style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            icon: Icons.palette_outlined,
            description: diagnosisStyle.keyFindingOne,
          ),

          const SizedBox(height: 16),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            icon: Icons.visibility_outlined,
            description: diagnosisStyle.keyFindingTwo,
          ),

          const SizedBox(height: 16),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            icon: Icons.warning_amber_rounded,
            description: diagnosisStyle.keyFindingThree,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFindingsRow({
    required BuildContext context,
    required ColorScheme colors,
    required IconData icon,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 23,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.4,
                ) ??
                TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }


  Widget _buildCloserLookCard(
    BuildContext context,
    ColorScheme colors,
    DiagnosisStyle diagnosisStyle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.onSurfaceVariant.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What this means to you?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ) ??
                TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
          ),

          const SizedBox(height: 2),

          Text(
            'A closer look...',
            style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(
            diagnosisStyle.closerLook,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ) ??
                TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }

  // -------------------- Navigation / actions --------------------
  void _goToRecommendations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentRecommendationsScreen(
          arrangedCaps: arrangedCaps,
        ),
      ),
    );
  }
}