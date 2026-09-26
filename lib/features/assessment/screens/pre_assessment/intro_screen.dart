import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_cards.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_scaffold.dart';
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

class PreAssessmentIntroScreen extends StatelessWidget {
  const PreAssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PreAssessmentScaffold(
      currentStep: 1,
      totalSteps: 4,
      onNext: () {
        Navigator.pushNamed(context, AppRoutes.preAssessmentHowItWorks);
      },
      onBack: null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: GoogleFonts.atkinsonHyperlegibleNext(
                fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
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
            textAlign: TextAlign.justify,
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