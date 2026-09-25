import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_scaffold.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorColor = context.semanticColors.error;

    return PreAssessmentScaffold(
      currentStep: 4,
      totalSteps: 4,
      onNext: () {
        Navigator.pushNamed(context, AppRoutes.assessment);
      },
      onBack: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Before you continue, here\'s something worth knowing. It\'ll only take a moment to read, and it\'ll help you understand exactly what this assessment is for.',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
            ),
          ),
          SizedBox(height: Responsive.space(context, base: 20, min: 14, max: 26)),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: Responsive.space(context, base: 17, min: 12, max: 22),
                      color: errorColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: Responsive.all(context, base: 20, min: 14, max: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Note',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: Responsive.font(context, base: 14, min: 12, max: 16),
                              ),
                            ),
                            SizedBox(height: Responsive.space(context, base: 6, min: 4, max: 10)),
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: errorColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Disclaimer',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontFamily: 'AtkinsonHyperlegible',
                                    fontSize: Responsive.font(context, base: 24, min: 18, max: 28),
                                    color: errorColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.space(context, base: 14, min: 10, max: 20)),
                            Text.rich(
                              TextSpan(
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'This assessment is for informational and digital optimization purposes only. ',
                                  ),
                                  TextSpan(
                                    text: 'It does not constitute a medical diagnosis.',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' For official vision certification, please consult a licensed optometrist.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}