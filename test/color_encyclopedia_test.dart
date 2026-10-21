import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/features/encyclopedia/screens/color_encyclopedia_screen.dart';
import 'package:gabeye/features/encyclopedia/services/color_encyclopedia_service.dart';
import 'package:gabeye/features/encyclopedia/widgets/color_quiz_dialog.dart';
import 'package:gabeye/features/encyclopedia/widgets/color_quiz_intro_dialog.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockDataset = [
    const IsccNbsColorEntry(
      id: 1,
      name: 'Vivid Pink',
      r: 253,
      g: 121,
      b: 146,
      hue: 349,
      saturation: 0.52,
      value: 0.99,
      hex: '#FD7992',
    ),
    const IsccNbsColorEntry(
      id: 11,
      name: 'Vivid Red',
      r: 213,
      g: 28,
      b: 60,
      hue: 350,
      saturation: 0.87,
      value: 0.84,
      hex: '#D51C3C',
    ),
    const IsccNbsColorEntry(
      id: 48,
      name: 'Vivid Orange',
      r: 247,
      g: 118,
      b: 11,
      hue: 27,
      saturation: 0.96,
      value: 0.97,
      hex: '#F7760B',
    ),
    // Non-convertible ID that should be skipped in quiz
    const IsccNbsColorEntry(
      id: 49,
      name: 'Brilliant Orange',
      r: 255,
      g: 140,
      b: 0,
      hue: 30,
      saturation: 1.0,
      value: 1.0,
      hex: '#FF8C00',
    ),
    const IsccNbsColorEntry(
      id: 82,
      name: 'Vivid Yellow',
      r: 241,
      g: 191,
      b: 21,
      hue: 46,
      saturation: 0.91,
      value: 0.95,
      hex: '#F1BF15',
    ),
    const IsccNbsColorEntry(
      id: 139,
      name: 'Vivid Green',
      r: 35,
      g: 234,
      b: 165,
      hue: 159,
      saturation: 0.85,
      value: 0.92,
      hex: '#23EAA5',
    ),
    const IsccNbsColorEntry(
      id: 176,
      name: 'Vivid Blue',
      r: 27,
      g: 92,
      b: 215,
      hue: 219,
      saturation: 0.87,
      value: 0.84,
      hex: '#1B5CD7',
    ),
    const IsccNbsColorEntry(
      id: 216,
      name: 'Vivid Purple',
      r: 185,
      g: 53,
      b: 213,
      hue: 290,
      saturation: 0.75,
      value: 0.84,
      hex: '#B935D5',
    ),
  ];

  group('ColorEncyclopediaService Tests', () {
    test('extracts umbrella term and modifier properly', () {
      expect(ColorEncyclopediaService.extractUmbrellaTerm('Vivid Red'), 'Red');
      expect(ColorEncyclopediaService.extractModifier('Vivid Red'), 'Vivid');

      expect(
        ColorEncyclopediaService.extractUmbrellaTerm('Light Grayish Blue'),
        'Blue',
      );
      expect(
        ColorEncyclopediaService.extractModifier('Light Grayish Blue'),
        'Light Grayish',
      );
    });

    test(
      'generateQuiz skips non-convertible IDs and creates 5 valid questions with 3 options',
      () {
        final quiz = ColorEncyclopediaService.generateQuiz(mockDataset);
        expect(quiz.length, 5);

        for (final q in quiz) {
          expect(
            ColorEncyclopediaService.skippedIds.contains(q.entry.id),
            isFalse,
          );
          expect(q.options.length, 3);
          expect(q.options.contains(q.actualName), isTrue);
          expect(q.options.contains(q.umbrellaTerm), isTrue);
          expect(q.options.contains(q.wrongName), isTrue);
        }
      },
    );
  });

  group('ColorQuizIntroDialog Widget Tests', () {
    testWidgets('renders intro content, cancel and start buttons', (
      tester,
    ) async {
      bool started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ColorQuizIntroDialog.show(
                  context,
                  onStart: () => started = true,
                ),
                child: const Text('Open Intro'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Intro'));
      await tester.pumpAndSettle();

      expect(find.text('Color Flashcard Quiz'), findsOneWidget);
      expect(find.text('5-Color Identification Challenge'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);

      // Tap Start Quiz
      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();
      expect(started, isTrue);
    });
  });

  group('ColorQuizDialog Widget Tests', () {
    testWidgets(
      'shows "What is the name of this color?" and handles umbrella selection',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ColorQuizDialog(dataset: mockDataset)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('What is the name of this color?'), findsOneWidget);
        expect(find.textContaining('Color 1 of 5'), findsOneWidget);

        // Find an umbrella term on screen and tap it
        final umbrellaFinder = find.byWidgetPredicate((w) {
          if (w is Text &&
              ColorEncyclopediaService.umbrellaCategories.contains(w.data)) {
            return true;
          }
          return false;
        });

        if (umbrellaFinder.evaluate().isNotEmpty) {
          await tester.tap(umbrellaFinder.first);
          await tester.pumpAndSettle();

          expect(find.textContaining('broad category'), findsOneWidget);
          expect(find.text('Next Color'), findsOneWidget);
        }
      },
    );
  });

  group('ColorEncyclopediaScreen Widget Tests', () {
    testWidgets('lays out correctly on a narrow viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: GabEyeTheme.lightTheme,
          home: const ColorEncyclopediaScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Color Encyclopedia'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
