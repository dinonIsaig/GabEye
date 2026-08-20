import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/widgets/gabeye_app_bar.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Before you continue, here\'s something worth knowing. It\'ll only take a moment to read, and it\'ll help you understand exactly what this assessment is for.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                width: 17,
                                color: AppColors.errorRed,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Important Note',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: AppColors.errorRed,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Disclaimer',
                                            style: textTheme.titleLarge?.copyWith(
                                              fontFamily: 'Inter',
                                              fontSize: 24,
                                              color: AppColors.errorOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text.rich(
                                        TextSpan(
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}