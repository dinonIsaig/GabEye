import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

/// Visual styling for a [SeverityLevel] — color + icon, used anywhere a
/// severity banner, badge, or chip needs to look the same across screens.
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

/// Visual styling + plain-language copy for a [ColorDeficiencyType] —
/// shared by the post-assessment summary, key findings, and detailed
/// results screen so all screens describe each diagnosis consistently.
class DiagnosisStyle {
  final Color primaryColor;
  final Color secondaryColor;
  final String? axisFamily;
  final String subtitle;
  final String highlightPhrase;
  final String shortSummary;

  // Key Findings descriptions
  final String keyFindingOne;
  final String keyFindingTwo;
  final String keyFindingThree;

  const DiagnosisStyle({
    required this.primaryColor,
    required this.secondaryColor,
    required this.axisFamily,
    required this.subtitle,
    required this.highlightPhrase,
    required this.shortSummary,
    required this.keyFindingOne,
    required this.keyFindingTwo,
    required this.keyFindingThree,
  });
}

const Map<ColorDeficiencyType, DiagnosisStyle> diagnosisStyles = {
  ColorDeficiencyType.protan: DiagnosisStyle(
    primaryColor: AppSemanticColors.protan,
    secondaryColor: AppSemanticColors.deutan,
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
  ),

  ColorDeficiencyType.deutan: DiagnosisStyle(
    primaryColor: AppSemanticColors.deutan,
    secondaryColor: AppSemanticColors.protan,
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
  ),

  ColorDeficiencyType.tritan: DiagnosisStyle(
    primaryColor: AppSemanticColors.tritan,
    secondaryColor: AppSemanticColors.deutan,
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
  ),

  ColorDeficiencyType.unclassified: DiagnosisStyle(
    primaryColor: AppSemanticColors.unclassified,
    secondaryColor: AppSemanticColors.deutan,
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
  ),

  ColorDeficiencyType.random: DiagnosisStyle(
    primaryColor: AppSemanticColors.unclassified,
    secondaryColor: AppSemanticColors.tritan,
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
  ),

  ColorDeficiencyType.normal: DiagnosisStyle(
    primaryColor: AppSemanticColors.normal,
    secondaryColor: AppSemanticColors.tritan,
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
  ),
};