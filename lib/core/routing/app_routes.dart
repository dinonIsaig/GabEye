import 'package:flutter/material.dart';
// Import all your feature screens here
import 'package:gabeye/features/onboarding/screens/get_started_screen.dart';

class AppRoutes {
  // Define strict string constants for route names
  static const String getStarted = '/';


  // Map the routes to their respective screens
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      getStarted: (context) => const GetStartedScreen(),
      // assessment: (context) => const AssessmentScreen(),
      // liveCamera: (context) => const LiveCameraScreen(),
      // Add more routes here
    };
  }
}