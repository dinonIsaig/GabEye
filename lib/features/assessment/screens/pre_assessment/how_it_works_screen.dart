import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_cards.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_scaffold.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return PreAssessmentScaffold(
      currentStep: 2,
      instructionHeader: 'Assessment instructions',
      instructionTitle: 'How it works?',
      onBack: () => Navigator.pop(context),
      onNext: () {
        Navigator.pushNamed(context, AppRoutes.preAssessmentWhatToMind);
      },
      body: Column(
        children: const [
          PreAssessmentStepCard(
            stepNumber: 1,
            normalTextBefore: 'You are presented with block of colors that you need to ',
            boldText: 'arrange based on their hue',
            normalTextAfter: '.',
          ),
          PreAssessmentStepCard(
            stepNumber: 2,
            normalTextBefore: 'With given 15 discs, ',
            boldText: 'follow the cap',
            normalTextAfter: ' in order to determine the starting point to the end.',
          ),
          PreAssessmentStepCard(
            stepNumber: 3,
            normalTextBefore: 'To drag, ',
            boldText: 'hold the disc then drag',
            normalTextAfter: ' into the position which you think belongs to.',
          ),
          PreAssessmentStepCard(
            stepNumber: 4,
            normalTextBefore: 'Click ',
            boldText: 'finish assessment',
            normalTextAfter: ' to confirm, then wait for your color assessment result.',
          ),
        ],
      ),
    );
  }
}