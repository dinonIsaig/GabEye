import 'package:flutter/material.dart';
// Import all your feature screens here
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';
import 'package:gabeye/features/onboarding/screens/get_started_screen.dart';
import 'package:gabeye/features/assessment/screens/assessment_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/how_it_works_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/what_to_mind_screen.dart';
import 'package:gabeye/features/assessment/screens/pre_assessment/disclaimer_screen.dart';

class AppRoutes {
  // Define strict string constants for route names
  static const String getStarted = '/';
  static const String assessment = '/assessment';

  static const String article = '/article';
  static const String preAssessmentHowItWorks = '/pre-assessment/how-it-works';
  static const String preAssessmentWhatToMind = '/pre-assessment/what-to-mind';
  static const String preAssessmentDisclaimer = '/pre-assessment/disclaimer';
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


      // practice: (context) => const PracticeScreen(),
      // assessment: (context) => const AssessmentScreen(),
      // liveCamera: (context) => const LiveCameraScreen(),
      // Add more routes here
    };
  }
}