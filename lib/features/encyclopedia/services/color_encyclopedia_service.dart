import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';

/// Helper model for a single color flashcard quiz question.
class ColorQuizQuestion {
  final IsccNbsColorEntry entry;
  final String actualName;
  final String umbrellaTerm;
  final String wrongName;
  final List<String> options;

  const ColorQuizQuestion({
    required this.entry,
    required this.actualName,
    required this.umbrellaTerm,
    required this.wrongName,
    required this.options,
  });
}

/// Service managing color encyclopedia queries, filtering, and quiz generation.
class ColorEncyclopediaService {
  /// The 7 historical ISCC-NBS centroids without RGB-to-HSV mapping.
  static const Set<int> skippedIds = {49, 66, 124, 142, 161, 167, 170};

  /// Known ISCC-NBS umbrella hue categories.
  static const List<String> umbrellaCategories = [
    'Pink',
    'Red',
    'Orange',
    'Brown',
    'Yellow',
    'Olive',
    'Green',
    'Blue',
    'Violet',
    'Purple',
    'White',
    'Gray',
    'Black',
  ];

  /// Extracts the base umbrella color term from an ISCC-NBS name.
  static String extractUmbrellaTerm(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return name;
    final last = parts.last;
    if (umbrellaCategories.contains(last)) {
      return last;
    }
    return parts.last;
  }

  /// Extracts the modifier part of an ISCC-NBS color name (e.g. "Vivid", "Light Grayish").
  static String extractModifier(String name) {
    final parts = name.trim().split(' ');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join(' ');
  }

  /// Converts an entry's hex string into a pure, untinted Flutter Color.
  static Color entryToColor(IsccNbsColorEntry entry) {
    try {
      final hexClean = entry.hex.replaceAll('#', '');
      return Color(int.parse('0xFF$hexClean'));
    } catch (_) {
      return Color.fromRGBO(
        entry.r ?? 128,
        entry.g ?? 128,
        entry.b ?? 128,
        1.0,
      );
    }
  }

  /// Generates a brief layman explanation of why an ISCC-NBS name fits a color.
  static String getEducationalExplanation(IsccNbsColorEntry entry) {
    final umbrella = extractUmbrellaTerm(entry.name);
    final modifier = extractModifier(entry.name);

    if (modifier.isEmpty) {
      return 'This is the pure, base reference for $umbrella in the universal color dictionary.';
    }

    final lowerMod = modifier.toLowerCase();
    String attributeDesc;
    if (lowerMod.contains('vivid') || lowerMod.contains('brilliant') || lowerMod.contains('strong')) {
      attributeDesc = 'high color purity and vibrant saturation';
    } else if (lowerMod.contains('deep') || lowerMod.contains('dark')) {
      attributeDesc = 'rich depth with lower lightness';
    } else if (lowerMod.contains('pale') || lowerMod.contains('light')) {
      attributeDesc = 'soft, gentle tone with higher brightness';
    } else if (lowerMod.contains('grayish')) {
      attributeDesc = 'subtle, muted tone blended with neutral gray';
    } else {
      attributeDesc = 'distinct hue and lightness characteristics';
    }

    return 'In standard naming, "$modifier" specifies $attributeDesc within the broad $umbrella family.';
  }

  /// Generates a 5-question flashcard quiz from the dataset.
  static List<ColorQuizQuestion> generateQuiz(List<IsccNbsColorEntry> dataset) {
    // 1. Filter out the 7 non-convertible IDs and colors where name equals umbrella term
    final eligible = dataset.where((e) {
      if (skippedIds.contains(e.id)) return false;
      if (e.r == null || e.g == null || e.b == null) return false;
      final umbrella = extractUmbrellaTerm(e.name);
      // Ensure name has a modifier so umbrella term != actual name
      return e.name.trim().toLowerCase() != umbrella.toLowerCase();
    }).toList();

    if (eligible.length < 5) return [];

    final random = math.Random();
    final shuffled = List<IsccNbsColorEntry>.from(eligible)..shuffle(random);
    final selected = shuffled.take(5).toList();

    final questions = <ColorQuizQuestion>[];

    for (final entry in selected) {
      final actual = entry.name;
      final umbrella = extractUmbrellaTerm(entry.name);

      // Pick a plausible wrong answer from a completely different umbrella family
      final wrongCandidates = eligible.where((c) {
        final candUmbrella = extractUmbrellaTerm(c.name);
        return candUmbrella != umbrella && c.name != actual;
      }).toList();

      final wrongEntry = wrongCandidates.isNotEmpty
          ? wrongCandidates[random.nextInt(wrongCandidates.length)]
          : eligible[random.nextInt(eligible.length)];
      final wrong = wrongEntry.name;

      // Randomize the 3 options
      final options = [actual, umbrella, wrong]..shuffle(random);

      questions.add(ColorQuizQuestion(
        entry: entry,
        actualName: actual,
        umbrellaTerm: umbrella,
        wrongName: wrong,
        options: options,
      ));
    }

    return questions;
  }
}
