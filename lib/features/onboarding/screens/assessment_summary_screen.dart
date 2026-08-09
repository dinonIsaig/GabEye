import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import 'package:gabeye/features/onboarding/screens/results_screen.dart';
import 'package:gabeye/features/onboarding/services/scoring_service.dart';

/// Post-assessment 9: the plain-language summary shown right after the
/// user finishes arranging the caps, before the technical breakdown on
/// the next screen (post-assessment 8 / ResultsPage).
class AssessmentSummaryScreen extends StatelessWidget {
  final List<int> arrangedCaps;

  const AssessmentSummaryScreen({super.key, required this.arrangedCaps});

  @override
  Widget build(BuildContext context) {
    // Follows whichever theme is currently active (light or dark),
    // same as main.dart's ThemeMode.system — no override here.
    final colors = Theme.of(context).colorScheme;
    final D15ScoreResult result = ScoringService.calculateScore(arrangedCaps);
    final severityStyle = _severityStyles[result.severity]!;
    final diagnosisStyle = _diagnosisStyles[result.diagnosisType]!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NOTE: the step progress bar ("Profile 1/4" + "...") is
              // intentionally not built here — it's provided by your
              // existing reusable token, meant to sit above this screen.
              _buildHeadingArt(colors),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRangeBanner(colors, result, severityStyle),
                    const SizedBox(height: 16),
                    _buildDiagnosisCard(context, colors, result, severityStyle, diagnosisStyle),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: proceed to the next onboarding step
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      label: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Heading art --------------------
  Widget _buildHeadingArt(ColorScheme colors) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Container(
        width: double.infinity,
        height: 140,
        color: colors.surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset('assets/images/articleHeading.svg', fit: BoxFit.cover),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Text(
                'Color Vision Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- "Above/within typical range" banner --------------------
  Widget _buildRangeBanner(ColorScheme colors, D15ScoreResult result, _SeverityStyle severityStyle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: severityStyle.color, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Icon(severityStyle.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.rangeHeadline,
                  style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold, height: 1.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.rangeBody,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // -------------------- Diagnosis card --------------------
  Widget _buildDiagnosisCard(
    BuildContext context,
    ColorScheme colors,
    D15ScoreResult result,
    _SeverityStyle severityStyle,
    _DiagnosisStyle diagnosisStyle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Based on your result, you likely have...',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOverlappingCircles(diagnosisStyle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.shortName,
                  style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDescription(colors, result, diagnosisStyle),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(label: 'Severity', value: result.severityLabel, backgroundColor: severityStyle.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(label: 'Type', value: result.shortName, backgroundColor: diagnosisStyle.primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(label: 'Affected', value: result.conesShortLabel, backgroundColor: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            result.practicalTip,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _goToDetailedResult(context),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 16),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              minimumSize: const Size(double.infinity, 44),
            ),
            label: const Text('View Detailed Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _exportAsPdf(context),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.download, size: 16),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              side: BorderSide(color: colors.onSurfaceVariant.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              minimumSize: const Size(double.infinity, 44),
            ),
            label: const Text('Export as PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // -------------------- Description --------------------
  /// Generates the short, plain-language sentence for this card — as
  /// opposed to `result.description`, which is the longer technical
  /// version used on the detailed results screen. Reads its wording
  /// entirely from `diagnosisStyle`, so it's automatically correct for
  /// every type (e.g. Tritan gets "blue-yellow" instead of the
  /// "red-green" wording that only applies to Protan/Deutan).
  Widget _buildDescription(ColorScheme colors, D15ScoreResult result, _DiagnosisStyle style) {
    final baseStyle = TextStyle(color: colors.onSurfaceVariant, fontSize: 13, height: 1.5);

    if (result.diagnosisType == ColorDeficiencyType.normal) {
      return Text(result.description, style: baseStyle);
    }

    final String prefix = style.axisFamily != null
        ? "Your results suggest a ${result.shortName.toLowerCase()}-type color vision difference, one of the forms of ${style.axisFamily} color blindness. This means your eyes have a "
        : "Your results suggest a color vision difference that doesn't align with a single axis. This means you may have a ";

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: style.highlightPhrase,
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  // -------------------- Overlapping color circles --------------------
  Widget _buildOverlappingCircles(_DiagnosisStyle style) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          Positioned(left: 0, child: CircleAvatar(radius: 10, backgroundColor: style.primaryColor)),
          Positioned(left: 12, child: CircleAvatar(radius: 10, backgroundColor: style.secondaryColor)),
        ],
      ),
    );
  }

  // -------------------- Metric chip --------------------
  /// White text throughout regardless of accent color — every severity
  /// and diagnosis color in this app is a deeply saturated tone (amber,
  /// red, blue, green), so white reads reliably across all of them
  /// instead of picking a text color per-background. This part is
  /// intentionally NOT theme-reactive, same reasoning as
  /// AppSemanticColors: chip backgrounds are fixed semantic colors, so
  /// their text stays fixed too, regardless of light/dark mode.
  Widget _buildMetricBox({required String label, required String value, required Color backgroundColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------- Navigation / actions --------------------
  void _goToDetailedResult(BuildContext context) {
    // TODO: once the profile step flow exists, confirm whether this
    // should always land here, or on a different step in that flow.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultsPage(arrangedCaps: arrangedCaps)),
    );
  }

  void _exportAsPdf(BuildContext context) {
    // TODO: wire up real PDF export (e.g. the `pdf` + `printing`
    // packages) once you're ready — that needs a pubspec dependency
    // addition, so left as a stub rather than adding a package without
    // checking with you first.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon')),
    );
  }
}

// ============================================================================
// CONFIG: severity -> visual style
// ============================================================================

class _SeverityStyle {
  final Color color;
  final IconData icon;
  const _SeverityStyle({required this.color, required this.icon});
}

const Map<SeverityLevel, _SeverityStyle> _severityStyles = {
  SeverityLevel.none: _SeverityStyle(color: AppSemanticColors.severityNormal, icon: Icons.check),
  SeverityLevel.moderate: _SeverityStyle(color: AppSemanticColors.severityModerate, icon: Icons.info_outline),
  SeverityLevel.strong: _SeverityStyle(color: AppSemanticColors.severityStrong, icon: Icons.priority_high),
};

// ============================================================================
// CONFIG: diagnosis type -> visual style + plain-language copy
// ============================================================================

class _DiagnosisStyle {
  final Color primaryColor;
  final Color secondaryColor;
  final String? axisFamily; // "red-green" / "blue-yellow" / null (not axis-based)
  final String highlightPhrase; // the bolded clause in the summary sentence

  const _DiagnosisStyle({
    required this.primaryColor,
    required this.secondaryColor,
    required this.axisFamily,
    required this.highlightPhrase,
  });
}

const Map<ColorDeficiencyType, _DiagnosisStyle> _diagnosisStyles = {
  ColorDeficiencyType.protan: _DiagnosisStyle(
    primaryColor: AppSemanticColors.protan,
    secondaryColor: AppSemanticColors.deutan,
    axisFamily: 'red-green',
    highlightPhrase: 'harder time telling red apart from green.',
  ),
  ColorDeficiencyType.deutan: _DiagnosisStyle(
    primaryColor: AppSemanticColors.deutan,
    secondaryColor: AppSemanticColors.protan,
    axisFamily: 'red-green',
    highlightPhrase: 'harder time telling green apart from red.',
  ),
  ColorDeficiencyType.tritan: _DiagnosisStyle(
    primaryColor: AppSemanticColors.tritan,
    secondaryColor: AppSemanticColors.deutan,
    axisFamily: 'blue-yellow',
    highlightPhrase: 'harder time telling blue apart from yellow.',
  ),
  ColorDeficiencyType.unclassified: _DiagnosisStyle(
    primaryColor: AppSemanticColors.unclassified,
    secondaryColor: AppSemanticColors.deutan,
    axisFamily: null,
    highlightPhrase: "pattern that doesn't fit neatly into one category.",
  ),
  ColorDeficiencyType.random: _DiagnosisStyle(
    primaryColor: AppSemanticColors.unclassified,
    secondaryColor: AppSemanticColors.tritan,
    axisFamily: null,
    highlightPhrase: 'inconsistent pattern rather than one specific difference.',
  ),
  ColorDeficiencyType.normal: _DiagnosisStyle(
    primaryColor: AppSemanticColors.normal,
    secondaryColor: AppSemanticColors.tritan,
    axisFamily: null,
    highlightPhrase: '',
  ),
};