import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/core/widgets/gabeye_app_bar.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tones = context.errorAccentTones;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GabEyeAppBar(
        showBackButton: true,
        showLogo: false,
        progressValue: 1.0,
        progressText: 'Step 4/4',
      ),
      body: SafeArea(
        top: false,
        child: Responsive.constrainWidth(
          context,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight - 50,
                ),
                child: const PreAssessmentHeroHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: Responsive.symmetricH(context, base: 20, min: 14, max: 28)
                      .copyWith(top: 16, bottom: 16),
                  child: Column(
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
                                  color: tones.accent,
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
                                              color: tones.accent,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Disclaimer',
                                              style: textTheme.titleLarge?.copyWith(
                                                fontFamily: 'Inter',
                                                fontSize: Responsive.font(context, base: 24, min: 18, max: 28),
                                                color: tones.accent,
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
                ),
              ),

              Padding(
                padding: Responsive.only(
                  context,
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: 16,
                ),
                child: Column(
                  children: [
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
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.assessment);
                        },
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}