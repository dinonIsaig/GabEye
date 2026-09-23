import 'package:flutter/material.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/core/widgets/gabeye_app_bar.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

class PreAssessmentScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? instructionHeader;
  final String? instructionTitle;
  final Widget body;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const PreAssessmentScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.instructionHeader,
    this.instructionTitle,
    required this.body,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final appBar = GabEyeAppBar(
      showBackButton: true,
      showLogo: false,
      progressValue: currentStep / totalSteps,
      progressText: 'Step $currentStep/$totalSteps',
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: Responsive.constrainWidth(
          context,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + appBar.preferredSize.height,
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
                      if (instructionHeader != null && instructionTitle != null)
                        Container(
                          width: double.infinity,
                          padding: Responsive.symmetricH(context, base: 16, min: 12, max: 20)
                              .copyWith(top: 14, bottom: 14),
                          margin: EdgeInsets.only(
                            bottom: Responsive.space(context, base: 16, min: 12, max: 20),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instructionHeader!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: Responsive.space(context, base: 4, min: 2, max: 8)),
                              Text(
                                instructionTitle!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: Responsive.font(context, base: 24, min: 18, max: 28),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      body,
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: onNext,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
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
                                color: onBack == null 
                                ? Theme.of(context).colorScheme.outline.withOpacity(0.38)
                                : Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: onBack,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                    color: onBack == null
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                                    : Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
                                  fontWeight: FontWeight.bold,
                                      color: onBack == null
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                                      : Theme.of(context).colorScheme.onSurface,
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