import 'package:flutter/material.dart';
// Import all your feature screens here
import 'package:gabeye/features/featured_reads/gabeye_article.dart';
import 'package:gabeye/features/onboarding/screens/get_started_screen.dart';

class AppRoutes {
  // Define strict string constants for route names
  static const String getStarted = '/';
  static const String article = '/article';

  // Map the routes to their respective screens
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      getStarted: (context) => const GetStartedScreen(),
      article: (context) => const GabEyeArticleScreen(),
      // assessment: (context) => const AssessmentScreen(),
      // liveCamera: (context) => const LiveCameraScreen(),
      // Add more routes here as your team creates new pages
    };
  }
}