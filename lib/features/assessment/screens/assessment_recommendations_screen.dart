import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/core/theme/cvd_personalization_controller.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import 'package:gabeye/features/home/screens/delay_screen.dart';
import 'package:gabeye/features/home/screens/home_screen.dart';
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
                                borderRadius: BorderRadius.circular(24),
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
                                      fontFamily: 'Inter',
                                      fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
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
                                borderRadius: BorderRadius.circular(24),
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
                                      fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
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

  Future<void> _goToPersonalizedUI(BuildContext context) async {
    if (cvdPersonalizationController.isSupported) {
      // Same switch the menu's "Personalize UI" toggle flips; the theme
      // rebuilds right away, so the loading screen already shows it.
      cvdPersonalizationController.setEnabled(true);
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const DelayScreen(
              duration: Duration(milliseconds: 4500),
              message: 'Personalizing your colors. Please wait.',
              footer: _PersonalizationNote(),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
    if (!context.mounted) return;
    _goHome(context);
  }

  void _goToGabEyeCamera(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.home),
        builder: (context) => const HomeScreen(initialIndex: 1),
      ),
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

/// Explains, on the personalization loading screen, what the adjusted colors
/// are for, with a swatch of each state color in the new palette.
class _PersonalizationNote extends StatelessWidget {
  const _PersonalizationNote();

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GabEye is adjusting its colors to your color vision profile, so '
          'the interface is easier to tell apart and states stand out at a '
          'glance:',
          style: TextStyle(fontSize: 12, height: 1.4, color: textColor),
        ),
        const SizedBox(height: 12),
        _StateSwatch(color: semantic.success, label: 'Success', textColor: textColor),
        _StateSwatch(color: semantic.warning, label: 'Warning', textColor: textColor),
        _StateSwatch(color: semantic.info, label: 'Disclaimer & info', textColor: textColor),
        _StateSwatch(color: semantic.error, label: 'Error', textColor: textColor),
        const SizedBox(height: 8),
        Text(
          'You can turn this off anytime from "Personalize UI" in the menu.',
          style: TextStyle(
            fontSize: 11,
            height: 1.4,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _StateSwatch extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _StateSwatch({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
