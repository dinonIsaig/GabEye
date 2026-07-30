import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_cards.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_scaffold.dart';

class WhatToMindScreen extends StatelessWidget {
  const WhatToMindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PreAssessmentScaffold(
      currentStep: 3,
      instructionHeader: 'Assessment reminders',
      instructionTitle: 'What to mind?',
      onBack: () => Navigator.pop(context),
      onNext: () {
        Navigator.pushNamed(context, AppRoutes.preAssessmentDisclaimer);
      },
      body: Column(
        children: [
          PreAssessmentInfoCard(
            title: 'Well-being',
            headerColor: Theme.of(context).colorScheme.tertiary,
            iconWidget: const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 20),
            normalTextBefore: 'Ensure that ',
            boldText: 'you are ready',
            normalTextAfter: ' to take the assessment that will only take 1-3 minutes.',
          ),
          const PreAssessmentInfoCard(
            title: 'Screen Brightness',
            headerColor: AppColors.warning,
            iconWidget: Icon(Icons.wb_sunny, color: Colors.white, size: 20),
            normalTextBefore: 'Set your screen brightness to 100%. ',
            boldText: 'Disable \'Night Shift\', \'Eye protection\'',
            normalTextAfter: ', and other similar filters before starting.',
          ),
          const PreAssessmentInfoCard(
            title: 'Precautions',
            headerColor: AppColors.errorOrange,
            iconWidget: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            normalTextBefore: 'Take the assessment in ',
            boldText: 'comfortable and safe place',
            normalTextAfter: '. We do not recommend the taking of assessment while moving.',
          ),
        ],
      ),
    );
  }
}