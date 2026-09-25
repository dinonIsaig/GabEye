import 'package:flutter/material.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/cvd_personalization_controller.dart';
import 'core/theme/gabeye_theme.dart';
import 'core/theme/theme_controller.dart';

void main() {
  runApp(const GabEye());
}

class GabEye extends StatelessWidget {
  const GabEye({super.key});

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
          initialRoute: AppRoutes.getStarted,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}