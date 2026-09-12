import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/features/home/widgets/feature_row.dart';
import 'package:gabeye/features/home/widgets/featured_reads_section.dart';
import 'package:gabeye/features/home/widgets/gabeye_bottom_nav.dart';
import 'package:gabeye/features/home/widgets/hero_section.dart';
import 'package:gabeye/features/assessment/screens/assessment_keyfindings_screen.dart';
import 'package:gabeye/features/home/widgets/vision_profile_card.dart';

void main() {
  Widget createTestWidget() {
    return MaterialApp(
      theme: GabEyeTheme.lightTheme,
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.home,
    );
  }

  testWidgets('HomeScreen renders hero, core features, featured reads, and bottom nav',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Verify Hero section content
    expect(find.byType(HeroSection), findsOneWidget);
    expect(find.text('GabEye'), findsWidgets);
    expect(find.text('Know More About GabEye'), findsOneWidget);

    // Verify Core Features section
    expect(find.text('Core Features'), findsOneWidget);
    expect(find.byType(FeatureRow), findsNWidgets(4));
    expect(find.text('Real-Time and Static Visual Processing'), findsOneWidget);
    expect(find.text('Personalized Accessibility'), findsOneWidget);
    expect(find.text('Color Diagnostic Assessment'), findsOneWidget);
    expect(find.text('Audio & Contextual Feedback'), findsOneWidget);

    // Verify CTA buttons
    expect(find.text('Try Using Camera'), findsOneWidget);
    expect(find.text('Configure in Settings'), findsOneWidget);
    expect(find.text('View Vision Profile'), findsOneWidget);
    expect(find.text('Learn More'), findsOneWidget);

    // Verify Featured Reads section & Navigation arrows
    expect(find.byType(FeaturedReadsSection), findsOneWidget);
    expect(find.text('Featured Reads'), findsOneWidget);
    expect(find.bySemanticsLabel('Previous article'), findsOneWidget);
    expect(find.bySemanticsLabel('Next article'), findsOneWidget);
    expect(find.byType(VisionProfileCard), findsNWidgets(4));
    expect(find.text('Farnsworth D-15'), findsOneWidget);
    expect(find.text('Protan'), findsOneWidget);
    expect(find.text('Deutan'), findsOneWidget);
    expect(find.text('Tritan'), findsOneWidget);
    expect(find.text('Read more'), findsNWidgets(4));

    // Verify Bottom Navigation
    expect(find.byType(GabEyeBottomNav), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('FeaturedReadsSection navigation arrows scroll correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Tap next arrow
    final nextArrow = find.bySemanticsLabel('Next article');
    await tester.tap(nextArrow);
    await tester.pumpAndSettle();
  });

  testWidgets('Tapping Read more navigates to article screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Tap first 'Read more' button
    await tester.tap(find.text('Read more').first);
    await tester.pumpAndSettle();

    // Verify Farnsworth D-15 article screen is shown
    expect(find.text('About the Farnsworth D-15'), findsWidgets);
    expect(find.text('How Is It Different From Other Tests?'), findsOneWidget);
    expect(find.text('Ishihara (dot test)'), findsOneWidget);
    expect(find.text('Farnsworth (D-15)'), findsOneWidget);
    expect(find.text('What it catches'), findsOneWidget);
    expect(find.text('What you do'), findsOneWidget);
  });

  testWidgets('Tapping Profile bottom nav item navigates to ProfileScreen with D-15 assessment details',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify Profile screen content
    expect(find.text('Based on your Farnsworth D-15 assessment...'), findsOneWidget);
    expect(find.text('Detailed Result'), findsOneWidget);
    expect(find.text('Retake D-15'), findsOneWidget);
    expect(find.text('Export PDF Report for Professionals'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Help & Feedback'), findsOneWidget);

    // Tap 'Detailed Result'
    await tester.tap(find.text('Detailed Result'));
    await tester.pumpAndSettle();

    // Verify ResultsPage is shown with Confusion Diagram and filled Export as PDF button
    expect(find.text('Export as PDF'), findsOneWidget);

    // Tap the back arrow on top navbar
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    // Verify returned to profile screen and has bottom navigation bar
    expect(find.text('Detailed Result'), findsOneWidget);
    expect(find.byType(GabEyeBottomNav), findsOneWidget);

    // Tap 'Home' on the bottom nav to return to HomeScreen Overview
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();

    // Verify back on HomeScreen overview
    expect(find.text('Core Features'), findsOneWidget);
  });

  testWidgets('Settings screen navigates to How to Use GabEye and Real-time Mode Safety',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    // Navigate to Settings
    await tester.tap(find.text('Configure in Settings'));
    await tester.pumpAndSettle();

    // Verify on Settings screen
    expect(find.text('Help & Safety'), findsOneWidget);
    expect(find.text('How to Use GabEye'), findsOneWidget);
    expect(find.text('Real-time Mode Safety'), findsOneWidget);

    // Tap 'How to Use GabEye'
    await tester.tap(find.text('How to Use GabEye'));
    await tester.pumpAndSettle();

    // Verify How to Use GabEye screen
    expect(find.text('Your Walkthrough'), findsOneWidget);
    expect(find.text('Real-Time vs. Static: Which Mode?'), findsOneWidget);

    // Go back to Settings
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    // Tap 'Real-time Mode Safety'
    await tester.tap(find.text('Real-time Mode Safety'));
    await tester.pumpAndSettle();

    // Verify Real-time Mode Safety screen
    expect(find.text('Built for Stationary Use'), findsOneWidget);
    expect(find.text('Why Lighting Matters'), findsOneWidget);
  });

  testWidgets('Tapping navbar logo navigates to GetStartedScreen (1st page of GabEye)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify on HomeScreen
    expect(find.text('Core Features'), findsOneWidget);

    // Tap the navbar logo
    await tester.tap(find.byType(SvgPicture));
    await tester.pumpAndSettle();

    // Verify on GetStartedScreen (the 1st page of GabEye)
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('GabEye!'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Assessment post-flow navigates from Key Findings to Recommendations and to Home',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testRoutes = Map<String, WidgetBuilder>.from(AppRoutes.getRoutes())
      ..remove(AppRoutes.getStarted);

    await tester.pumpWidget(MaterialApp(
      theme: GabEyeTheme.lightTheme,
      routes: testRoutes,
      home: const AssessmentKeyfindingsScreen(
        arrangedCaps: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      ),
    ));
    await tester.pumpAndSettle();

    // Verify on Step 2/3: Key Findings
    expect(find.text('Step 2/3'), findsOneWidget);
    expect(find.text('Key Findings'), findsOneWidget);

    // Tap 'Next'
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify on Step 3/3: Recommendations
    expect(find.text('Step 3/3'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.text('Recommended Steps'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);

    // Tap 'Back' on Recommendations -> returns to Step 2/3
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2/3'), findsOneWidget);
    expect(find.text('Key Findings'), findsOneWidget);

    // Tap 'Next' again to return to Recommendations
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3/3'), findsOneWidget);

    // Tap 'Go to Home' on Recommendations -> directs to Home
    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();

    // Verify now on Home screen
    expect(find.text('Core Features'), findsOneWidget);
    expect(find.text('Featured Reads'), findsOneWidget);
  });
}

