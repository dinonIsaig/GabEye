import 'package:flutter/material.dart';
// Import all your feature screens here
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';
import 'package:gabeye/features/onboarding/screens/get_started_screen.dart';
import 'package:gabeye/features/assessment/screens/assessment_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/how_it_works_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/what_to_mind_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/disclaimer_screen.dart';
import 'package:gabeye/features/featured_reads/settings/gabeye_settings.dart';
import 'package:gabeye/features/featured_reads/settings/help_feedback_screen.dart';

class AppRoutes {
  // Define strict string constants for route names
  static const String getStarted = '/';
  static const String assessment = '/assessment';

  static const String article = '/article';
  static const String preAssessmentHowItWorks = '/pre-assessment/how-it-works';
  static const String preAssessmentWhatToMind = '/pre-assessment/what-to-mind';
  static const String preAssessmentDisclaimer = '/pre-assessment/disclaimer';
  static const String d15Assessment = '/assessment/d15';
  static const String settings = '/settings';
  static const String helpFeedback = '/help-feedback';
  // use '/' in ur route soo it will be the landing
  // static const String practice = '/practice'; // <-- this is an example of defining

  // Map the routes to their respective screens
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      getStarted: (context) => const GetStartedScreen(),
      assessment: (context) => const AssessmentScreen(),
      article: (context) => const GabEyeArticleScreen(),
      preAssessmentHowItWorks: (context) => const HowItWorksScreen(),
      preAssessmentWhatToMind: (context) => const WhatToMindScreen(),
      preAssessmentDisclaimer: (context) => const DisclaimerScreen(),
      settings: (context) => const GabEyeSettingsScreen(),
      helpFeedback: (context) => const HelpFeedbackScreen(),

      d15Assessment: (context) =>
          const Scaffold(body: Center(child: Text('D-15 Assessment Screen'))),

      // practice: (context) => const PracticeScreen(),
      // assessment: (context) => const AssessmentScreen(),
      // liveCamera: (context) => const LiveCameraScreen(),
      // Add more routes here
    };
  }
}
