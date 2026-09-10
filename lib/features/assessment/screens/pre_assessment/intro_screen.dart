import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_cards.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_scaffold.dart';
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';

class PreAssessmentIntroScreen extends StatelessWidget {
  const PreAssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PreAssessmentScaffold(
      currentStep: 1,
      totalSteps: 4,
      onNext: () {
        Navigator.pushNamed(context, AppRoutes.preAssessmentHowItWorks);
      },
      onBack: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
              children: const [
                TextSpan(
                  text: 'Identify your color vision profile to optimize your digital experience. GabEye uses a color vision tool called ',
                ),
                TextSpan(
                  text: 'Farnsworth D-15.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          PreAssessmentArticleCard(
            imagePath: 'assets/images/farnsworth_d15_banner.png', 
            subtitle: 'Know more about',
            title: 'Farnsworth D-15',
            description:
                'The Farnsworth D-15 is a simple color arrangement test where you arrange 15 colored discs in sequence to identify your color vision pattern...',
            onReadMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarnsworthD15ArticleScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}