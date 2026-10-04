import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/features/onboarding/widgets/terms_and_conditions_content.dart';
import 'help_feedback_screen.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Terms & Conditions',
          onBack: () => Navigator.maybePop(context),
          onMenuSelected: (option) {
            if (option.label == 'Help & Feedback') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpFeedbackScreen(),
                ),
              );
            } else if (option.label == 'About GabEye') {
              Navigator.pushNamed(context, '/article');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: const TermsAndConditionsContent(),
                ),
              ),
            ),
    );
  }
}
