import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/gabeye_theme.dart';
import 'core/theme/theme_controller.dart';

void main() {
  runApp(const GabEye());
}

class GabEye extends StatelessWidget {
  const GabEye({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, child) => MaterialApp(
        title: 'GabEye',
        debugShowCheckedModeBanner: false,
        theme: GabEyeTheme.lightTheme,
        darkTheme: GabEyeTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: AppRoutes.preAssessmentHowItWorks,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
