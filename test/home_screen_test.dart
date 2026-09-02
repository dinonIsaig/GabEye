import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/features/home/screens/home.dart';

void main() {
  testWidgets('HomeScreen renders Vision Lens viewport, top preset chips, and floating controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GabEyeTheme.lightTheme,
        darkTheme: GabEyeTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );

    // Verify navigation labels
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Vision Lens'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // Verify top preset selector chips in Vision Lens tab
    expect(find.text('Protan'), findsOneWidget);
    expect(find.text('Deutan'), findsOneWidget);
    expect(find.text('Tritan'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);

    // Verify floating controls bar buttons
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Remap'), findsOneWidget);
  });

  testWidgets('HomeScreen logo header click redirects to Home overview dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GabEyeTheme.lightTheme,
        darkTheme: GabEyeTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );

    // Tap logo header in GabEyeHomeNavbar
    await tester.tap(find.byType(SvgPicture).first);
    await tester.pumpAndSettle();

    // Verify redirected to Home Overview tab
    expect(find.text('GabEye Vision Hub'), findsOneWidget);
  });
}
