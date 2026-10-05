import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/routing/app_routes.dart';
import 'core/services/auditory_feedback_service.dart';
import 'core/services/vision_profile_service.dart';
import 'core/theme/cvd_personalization_controller.dart';
import 'core/theme/gabeye_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/local/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode (disable landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SQLite database
  await DatabaseHelper.instance.database;

  // Hydrate in-memory services from SQLite
  await VisionProfileService.instance.loadFromDatabase();
  await AuditoryFeedbackService.instance.loadFromDatabase();

  // Determine cold-start entrypoint: bypass onboarding if assessment is already completed
  final diagnosticData = await DatabaseHelper.instance.getDiagnosticData(1);
  final bool hasTakenTest = diagnosticData?.hasTakenTest ?? false;

  final String initialRoute = hasTakenTest ? AppRoutes.home : AppRoutes.getStarted;

  runApp(GabEye(initialRoute: initialRoute));
}

class GabEye extends StatelessWidget {
  final String initialRoute;

  const GabEye({
    super.key,
    this.initialRoute = AppRoutes.getStarted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, cvdPersonalizationController]),
      builder: (context, child) {
        final profile = cvdPersonalizationController.activeProfile;
        return MaterialApp(
          title: 'GabEye',
          debugShowCheckedModeBanner: false,
          theme: GabEyeTheme.themeFor(Brightness.light, profile),
          darkTheme: GabEyeTheme.themeFor(Brightness.dark, profile),
          themeMode: themeController.value,
          initialRoute: initialRoute,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}