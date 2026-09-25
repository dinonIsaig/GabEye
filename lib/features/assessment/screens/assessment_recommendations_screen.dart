import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/features/assessment/widgets/post_assessment_progressbar.dart';
import 'package:gabeye/features/assessment/widgets/recommendation_row.dart';

class AssessmentRecommendationsScreen extends StatelessWidget {
  final List<int>? arrangedCaps;

  const AssessmentRecommendationsScreen({
    super.key,
    this.arrangedCaps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ProgressBarScaffold(
      currentStep: 3,
      totalSteps: 3,
      onBack: () => Navigator.pop(context),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeadingBanner(title: 'Recommendations'),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRecommendationCard(colors, textTheme),
                        const SizedBox(height: 16),
                        RecommendationRow(
                          title: 'Recommended Personalize UI',
                          description:
                              'We recommend high-contrast monochrome tokens to maximize legibility across all app sections.',
                          buttonText: 'Continue with Personalized UI',
                          onPressed: () => _goToPersonalizedUI(context),
                        ),
                        const SizedBox(height: 12),
                        RecommendationRow(
                          description:
                              "Allow GabEye to assist you in identifying and remapping colors you're confused with.",
                          buttonText: 'GabEye Camera',
                          onPressed: () => _goToGabEyeCamera(context),
                        ),
                        const SizedBox(height: 12),
                        RecommendationRow(
                          description:
                              "If this is getting in the way of daily life, an eye specialist can give you a proper assessment and real options.",
                          buttonText: 'Color Vision Profile',
                          onPressed: () => _goToDetailedResult(context),
                        ),
                        const SizedBox(height: 24),
                        _buildOrDivider(colors),
                        const SizedBox(height: 24),
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
                            onPressed: () => _goHome(context),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Go to Home',
                                    style: TextStyle(
                                      fontFamily: 'AtkinsonHyperlegible',
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
                                      fontFamily: 'AtkinsonHyperlegible',
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

  Widget _buildRecommendationCard(ColorScheme colors, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
        border: Border.all(color: colors.onSurfaceVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you can do?',
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Recommended Steps',
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrDivider(ColorScheme colors) {
    final line = Divider(color: colors.onSurfaceVariant.withValues(alpha: 0.2), height: 1);
    return Row(
      children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('or', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: line),
      ],
    );
  }

  void _goToDetailedResult(BuildContext context) {
    final caps = arrangedCaps ?? VisionProfileService.instance.arrangedCaps;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultsPage(arrangedCaps: caps)),
    );
  }

  void _goToPersonalizedUI(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _goToGabEyeCamera(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }
}