import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/core/theme/theme_controller.dart';
import 'package:gabeye/features/featured_reads/settings/gabeye_settings.dart';
import 'package:gabeye/features/featured_reads/settings/personalized_accessibility_screen.dart';

void main() {
  testWidgets('Settings screen renders sections and navigates to Personalized Accessibility',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: GabEyeTheme.lightTheme,
        routes: AppRoutes.getRoutes(),
        initialRoute: AppRoutes.settings,
      ),
    );
    await tester.pumpAndSettle();

    // Verify sections and tiles
    expect(find.text('Accessibility & Personalization'), findsOneWidget);
    expect(find.text('Personalized Accessibility'), findsOneWidget);
    expect(find.text('Data & Storage'), findsOneWidget);
    expect(find.text('Personal Data'), findsOneWidget);

    // Tap 'Personalized Accessibility'
    await tester.tap(find.text('Personalized Accessibility'));
    await tester.pumpAndSettle();

    // Verify Personalized Accessibility screen opened
    expect(find.byType(PersonalizedAccessibilityScreen), findsOneWidget);
    expect(find.text('Visual Experience'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Personalize UI'), findsOneWidget);
    expect(find.text('Voice Feedback & Narration'), findsOneWidget);
    expect(find.text('Voice Narration (TTS)'), findsOneWidget);
    expect(find.text('Speech Speed'), findsOneWidget);
    expect(find.text('Test Voice'), findsOneWidget);

    // Toggle Dark Mode
    final initialMode = themeController.isDarkMode;
    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();
    expect(themeController.isDarkMode, !initialMode);

    // Restore mode
    themeController.setDarkMode(initialMode);
  });
}
