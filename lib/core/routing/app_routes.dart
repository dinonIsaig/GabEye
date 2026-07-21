import 'package:flutter/material.dart';
import 'package:gabeye/features/assessment/practice_screen.dart';
// Import all your feature screens here
import 'package:gabeye/features/onboarding/screens/get_started_screen.dart';
import 'package:gabeye/features/assessment/practice_screen.dart';

class AppRoutes {
  // Define strict string constants for route names
  static const String getStarted = '/';
  // use '/' in ur route soo it will be the landing
  // static const String practice = '/practice'; // <-- this is an example of defining

  // Map the routes to their respective screens
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      getStarted: (context) => const GetStartedScreen(),
      
      // practice: (context) => const PracticeScreen(),
      // assessment: (context) => const AssessmentScreen(),
      // liveCamera: (context) => const LiveCameraScreen(),
      // Add more routes here
    };
  }
}