import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

class SeverityStyle {
  final Color color;
  final IconData icon;

  const SeverityStyle({
    required this.color,
    required this.icon,
  });
}

const Map<SeverityLevel, SeverityStyle> severityStyles = {
  SeverityLevel.none: SeverityStyle(
    color: AppSemanticColors.severityNormal,
    icon: Icons.check,
  ),
  SeverityLevel.moderate: SeverityStyle(
    color: AppSemanticColors.severityModerate,
    icon: Icons.info_outline,
  ),
  SeverityLevel.strong: SeverityStyle(
    color: AppSemanticColors.severityStrong,
    icon: Icons.priority_high,
  ),
};

class DiagnosisStyle {
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final String? axisFamily;
  final String subtitle;
  final String highlightPhrase;
  final String shortSummary;

  // Key Findings descriptions
  final String keyFindingOne;
  final String keyFindingTwo;
  final String keyFindingThree;
  final String closerLook;

  const DiagnosisStyle({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.axisFamily,
    required this.subtitle,
    required this.highlightPhrase,
    required this.shortSummary,
    required this.keyFindingOne,
    required this.keyFindingTwo,
    required this.keyFindingThree,
    required this.closerLook,
  });
}

const Map<ColorDeficiencyType, DiagnosisStyle> diagnosisStyles = {
  ColorDeficiencyType.protan: DiagnosisStyle(
    primaryColor: AppSemanticColors.red,
    secondaryColor: AppSemanticColors.murky,
    tertiaryColor: AppSemanticColors.beige,
    axisFamily: 'red-green',
    subtitle: 'Red-green color vision difference',
    highlightPhrase: 'harder time telling red apart from green.',
    shortSummary:
        'Your results suggest a protan-type color vision difference, one of the two forms of red-green color blindness.',

    keyFindingOne:
        'Colors across the spectrum may not appear as distinct as they do for most people, especially colors involving red.',
    keyFindingTwo:
        'You may have more difficulty telling similar hues apart when red and green are involved.',
    keyFindingThree:
        'Your results suggest a red-green color vision difference rather than a typical color vision pattern.',
    closerLook:
        'You may have difficulty with certain reds and greens in everyday life. This might mean some traffic lights, warning signs, or color-coded maps look a little different to you than to others.',
  ),

  ColorDeficiencyType.deutan: DiagnosisStyle(
    primaryColor: AppSemanticColors.lemon,
    secondaryColor: AppSemanticColors.murky,
    tertiaryColor: AppSemanticColors.beige,
    axisFamily: 'red-green',
    subtitle: 'Red-green color vision difference',
    highlightPhrase: 'harder time telling green apart from red.',
    shortSummary:
        'Your results suggest a deutan-type color vision difference, one of the two forms of red-green color blindness.',

    keyFindingOne:
        'Colors across the spectrum may not appear as distinct as they do for most people, especially colors involving green.',
    keyFindingTwo:
        'You may have more difficulty telling similar hues apart when green and red are close in appearance.',
    keyFindingThree:
        'Your results suggest a red-green color vision difference rather than a typical color vision pattern.',
    closerLook:
        'You may have difficulty distinguishing greens, yellows, and reds in everyday life. This might mean color-coded charts, ripe fruits, or certain electronics indicators look a little different to you than to others.',
  ),

  ColorDeficiencyType.tritan: DiagnosisStyle(
    primaryColor: AppSemanticColors.teal,
    secondaryColor: AppSemanticColors.salmon,
    tertiaryColor: AppSemanticColors.lightgray,
    axisFamily: 'blue-yellow',
    subtitle: 'Blue-yellow color vision difference',
    highlightPhrase: 'harder time telling blue apart from yellow.',
    shortSummary:
        'Your results suggest a tritan-type color vision difference, a form of blue-yellow color blindness.',

    keyFindingOne:
        'Some colors across the spectrum may appear less distinct, particularly colors involving blue and yellow.',
    keyFindingTwo:
        'You may have more difficulty telling similar hues apart when blue and yellow are close in appearance.',
    keyFindingThree:
        'Your results suggest a blue-yellow color vision difference rather than a typical color vision pattern.',
    closerLook:
        'You may have difficulty distinguishing blues and greens, or yellows and pinks in everyday life. This might mean certain user interfaces, clothing combinations, or safety signs look a little different to you than to others.',
  ),

  ColorDeficiencyType.unclassified: DiagnosisStyle(
    primaryColor: AppSemanticColors.darkgray,
    secondaryColor: AppSemanticColors.gray,
    tertiaryColor: AppSemanticColors.lightgray,
    axisFamily: null,
    subtitle: 'Mixed color vision difference',
    highlightPhrase: "pattern that doesn't fit neatly into one category.",
    shortSummary:
        "Your results suggest a color vision difference that doesn't align with a single axis.",

    keyFindingOne:
        'Colors across the spectrum may appear less distinct, but the pattern does not point clearly to one color axis.',
    keyFindingTwo:
        'You may have difficulty telling some similar hues apart across more than one part of the color spectrum.',
    keyFindingThree:
        'Your results show a mixed color vision pattern that does not fit neatly into one specific category.',
    closerLook:
        'You may experience mixed difficulties distinguishing colors across the spectrum in everyday life. This might mean some color-coded information is harder to read, though it does not follow a predictable pattern.',
  ),

  ColorDeficiencyType.random: DiagnosisStyle(
    primaryColor: AppSemanticColors.beige,
    secondaryColor: AppSemanticColors.royal,
    tertiaryColor: AppSemanticColors.lemon,
    axisFamily: null,
    subtitle: 'Inconsistent color vision pattern',
    highlightPhrase:
        'inconsistent pattern rather than one specific difference.',
    shortSummary:
        'Your results show an inconsistent color-matching pattern rather than one specific type of color vision difference.',

    keyFindingOne:
        'Your color-matching pattern was inconsistent across the spectrum rather than concentrated around one color group.',
    keyFindingTwo:
        'Some similar hues may have been difficult to distinguish, but the pattern was not consistent enough to identify one type.',
    keyFindingThree:
        'Your results show an inconsistent color-matching pattern, so they do not point to one specific color vision difference.',
    closerLook:
        'Your results indicate an inconsistent pattern of color discrimination during this test.',
  ),

  ColorDeficiencyType.normal: DiagnosisStyle(
    primaryColor: AppSemanticColors.severityNormal,
    secondaryColor: AppSemanticColors.orange,
    tertiaryColor: AppSemanticColors.lemon,
    axisFamily: null,
    subtitle: 'Normal color vision',
    highlightPhrase: '',
    shortSummary: '',

    keyFindingOne:
        'Colors across the spectrum (reds, blues) appear as most people see them.',
    keyFindingTwo:
        'No consistent difficulty telling similar hues apart, even close ones like violet and dark blue.',
    keyFindingThree:
        'Your results fall within the typical range for color vision.',
    closerLook:
        'You likely experience no difficulty distinguishing colors in everyday life.' ,
  ),
};