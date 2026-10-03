import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gabeye/main.dart';

void main() {
  testWidgets('GabEye app smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const GabEye());
    await tester.pumpAndSettle();

    // Verify initial onboarding screen loads with welcome message
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('GabEye!'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started button to open Terms and Conditions modal
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Accept Terms & Conditions to enter main HomeScreen dashboard
    final agreeButton = find.text('I Agree & Continue');
    if (agreeButton.evaluate().isNotEmpty) {
      await tester.tap(agreeButton);
      await tester.pumpAndSettle();

      // Verify that home screen loads with Core Features and Featured Reads
      expect(find.text('Core Features'), findsOneWidget);
      expect(find.text('Featured Reads'), findsOneWidget);
    }
  });
}

