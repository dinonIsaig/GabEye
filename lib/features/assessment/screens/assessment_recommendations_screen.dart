import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
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
                          description:
                              "Read more about your results, know what is GabEye and what it can do for you.",
                          buttonText: 'Featured Reads',
                          onPressed: () => _goToFeaturedReads(context),
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
                        ElevatedButton.icon(
                          onPressed: () => _goHome(context),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 55),
                          ),
                          label: const Text(
                            'Go to Home',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          label: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          iconAlignment: IconAlignment.start,
                          icon: const Icon(Icons.arrow_back, size: 20),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: colors.onSurface,
                            side: BorderSide(color: colors.onSurfaceVariant.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 55),
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
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.1)),
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
    final line = Divider(color: colors.onSurfaceVariant.withOpacity(0.2), height: 1);
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

  void _goToFeaturedReads(BuildContext context) {
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