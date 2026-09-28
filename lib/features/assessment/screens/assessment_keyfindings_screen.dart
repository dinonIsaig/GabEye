import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/config/diagnosis_presentation.dart';
import 'package:gabeye/features/assessment/screens/assessment_recommendations_screen.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/features/assessment/widgets/post_assessment_progressbar.dart';
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';


class AssessmentKeyfindingsScreen extends StatefulWidget {
  final List<int> arrangedCaps;

  const AssessmentKeyfindingsScreen({
    super.key,
    required this.arrangedCaps,
  });

  @override
  State<AssessmentKeyfindingsScreen> createState() => _AssessmentKeyfindingsScreenState();
}

class _AssessmentKeyfindingsScreenState extends State<AssessmentKeyfindingsScreen> {
  late final D15ScoreResult _result;

  @override
  void initState() {
    super.initState();
    _result = ScoringService.calculateScore(widget.arrangedCaps);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final diagnosisStyle = diagnosisStyleFor(context, result.diagnosisType);

    return ProgressBarScaffold(
      currentStep: 2,
      totalSteps: 3,
      onBack: () => Navigator.pop(context),
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
                          textTheme,
                          diagnosisStyle,
                        ),
                        const SizedBox(height: 20),
                        _buildCloserLookCard(
                          context,
                          colors,
                          diagnosisStyle,
                          result.diagnosisType,
                        ),
                        const SizedBox(height: 20),


                        SizedBox(
                          width: double.infinity,
                          height: Responsive.space(context, base: 55, min: 48, max: 64),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _goToRecommendations(context),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: Responsive.font(context, base: 16, min: 14, max: 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.space(context, base: 10, min: 6, max: 14)),
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.space(context, base: 55, min: 48, max: 64),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: Responsive.font(context, base: 16, min: 14, max: 20),
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
    TextTheme textTheme,
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
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Key Findings',
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            textTheme: textTheme,
            icon: Icons.palette_outlined,
            description: diagnosisStyle.keyFindingOne,
          ),

          const SizedBox(height: 16),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            textTheme: textTheme,
            icon: Icons.visibility_outlined,
            description: diagnosisStyle.keyFindingTwo,
          ),

          const SizedBox(height: 16),

          _buildKeyFindingsRow(
            context: context,
            colors: colors,
            textTheme: textTheme,
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
    required TextTheme textTheme,
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
                  fontFamily: 'Inter',
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
    ColorDeficiencyType diagnosisType,
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
                  fontFamily: 'Inter',
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
          ),

          const SizedBox(height: 2),

          Text(
            'A closer look...',
            style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              diagnosisStyle.imagePath,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image_outlined, color: colors.onSurfaceVariant),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            diagnosisStyle.closerLook,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                  height: 1.5,
                ) ??
                TextStyle(
                  fontFamily: 'Inter',
                  color: colors.onSurfaceVariant,
                  fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                  height: 1.5,
                ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide(color: colors.outline, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => _openArticle(context, diagnosisType),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Read More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Navigation / actions --------------------
  void _openArticle(BuildContext context, ColorDeficiencyType diagnosisType) {
    Widget screen;
    switch (diagnosisType) {
      case ColorDeficiencyType.protan:
        screen = const ProtanArticleScreen();
        break;
      case ColorDeficiencyType.deutan:
        screen = const DeutanArticleScreen();
        break;
      case ColorDeficiencyType.tritan:
        screen = const TritanArticleScreen();
        break;
      case ColorDeficiencyType.normal:
      case ColorDeficiencyType.unclassified:
      case ColorDeficiencyType.random:
      default:
        screen = const FarnsworthD15ArticleScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _goToRecommendations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentRecommendationsScreen(
          arrangedCaps: widget.arrangedCaps,
        ),
      ),
    );
  }
}