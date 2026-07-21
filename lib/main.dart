import 'package:flutter/material.dart';
import 'core/theme/gabeye_theme.dart';
import 'core/routing/app_routes.dart';

void main() {
  runApp(const GabEye());
}


class GabEye extends StatelessWidget {
  const GabEye({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GabEye',
      debugShowCheckedModeBanner: false,

      theme: GabEyeTheme.lightTheme,
      darkTheme: GabEyeTheme.darkTheme,
      themeMode: ThemeMode.system, // change this to light or Dark for ur preferred workspace

      initialRoute: AppRoutes.getStarted, // change this initial route so u can directly work on your screens
      routes: AppRoutes.getRoutes(),

    );
  }
   
}
