import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import 'package:gabeye/features/assessment/config/diagnosis_presentation.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';
import 'package:gabeye/features/assessment/widgets/confusion_diagram.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';

/// Post-assessment 8: the detailed technical breakdown, reached from the
/// "View Detailed Result" button on AssessmentSummaryScreen (post-
/// assessment 9). Severity/type/affected chips and diagnosis colors are
/// pulled from the same shared config that screen uses, so both screens
/// always agree on what a given result looks like.
class ResultsPage extends StatelessWidget {
  final List<int> arrangedCaps;

  const ResultsPage({super.key, required this.arrangedCaps});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final D15ScoreResult result = ScoringService.calculateScore(arrangedCaps);
    final severityStyle = severityStyles[result.severity]!;
    final diagnosisStyle = diagnosisStyles[result.diagnosisType]!;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Color Vision Profile',
          onBack: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeadingBanner(title: 'Color Vision Profile'),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDiagnosisAndPlotCard(context, colors, result, severityStyle, diagnosisStyle),
                        const SizedBox(height: 20),
                        _buildTechnicalBreakdownCard(colors, result, diagnosisStyle),
                        const SizedBox(height: 20),
                        _buildConfusionLineCard(colors, result),
                        const SizedBox(height: 32),
                        _buildFooterButtons(context, colors),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Diagnosis header + confusion plot --------------------
  Widget _buildDiagnosisAndPlotCard(
    BuildContext context,
    ColorScheme colors,
    D15ScoreResult result,
    SeverityStyle severityStyle,
    DiagnosisStyle diagnosisStyle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildOverlappingCircles(diagnosisStyle),
              const SizedBox(width: 8),
              Text(
                result.shortName,
                style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            diagnosisStyle.subtitle,
            style: TextStyle(color: diagnosisStyle.primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Center(child: ConfusionDiagram(arrangedCaps: arrangedCaps)),
          const SizedBox(height: 20),
          Text(
            result.diagnosisType == ColorDeficiencyType.normal ? result.description : diagnosisStyle.shortSummary,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(label: 'Severity', value: result.severityLabel, backgroundColor: severityStyle.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(label: 'Type', value: result.shortName, backgroundColor: colors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(label: 'Affected', value: result.conesShortLabel, backgroundColor: colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildOverlappingCircles(DiagnosisStyle style) {
    return SizedBox(
      width: 44,
      height: 20,
      child: Stack(
        children: [
          Positioned(left: 0, child: CircleAvatar(radius: 10, backgroundColor: style.primaryColor)),
          Positioned(left: 12, child: CircleAvatar(radius: 10, backgroundColor: style.secondaryColor)),
          Positioned(left: 24, child: CircleAvatar(radius: 10, backgroundColor: style.tertiaryColor)),
        ],
      ),
    );
  }


  Widget _buildMetricBox({required String label, required String value, required Color backgroundColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------- Technical Breakdown --------------------
  Widget _buildTechnicalBreakdownCard(ColorScheme colors, D15ScoreResult result, DiagnosisStyle diagnosisStyle) {
    final String angleDescription = diagnosisStyle.axisFamily != null
        ? "The confusion axis angle on the color wheel — this result lines up with ${result.shortName}."
        : "The confusion axis angle on the color wheel — this result doesn't line up cleanly with a single axis.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Breakdown',
            style: TextStyle(color: colors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'Own reference, or share with an eye care provider',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 28),
          _buildTechnicalRow(
            colors: colors,
            badgeLabel: 'C-Index',
            badgeValue: result.cIndex.toStringAsFixed(2),
            title: 'Confusion Index',
            description: 'How much your cap order deviates from ideal. Higher = more errors.',
          ),
          const SizedBox(height: 16),
          _buildTechnicalRow(
            colors: colors,
            badgeLabel: 'S-Index',
            badgeValue: result.sIndex.toStringAsFixed(2),
            title: 'Selectivity Index',
            description: 'How strongly your errors point to one axis.',
          ),
          const SizedBox(height: 16),
          _buildTechnicalRow(
            colors: colors,
            badgeLabel: 'Angle',
            badgeValue: '${result.angle.toStringAsFixed(1)}°',
            title: 'Confusion Axis Angle',
            description: angleDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalRow({
    required ColorScheme colors,
    required String badgeLabel,
    required String badgeValue,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 105,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(
                badgeLabel,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                badgeValue,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------- Confusion Line --------------------
  Widget _buildConfusionLineCard(ColorScheme colors, D15ScoreResult result) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confusion Line',
            style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (result.crossings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No crossing errors detected. Perfect arrangement!',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
              ),
            )
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.crossings.length,
              itemBuilder: (context, index) {
                final error = result.crossings[index];
                final isMajor = error.isMajor;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isMajor ? AppSemanticColors.majorError : AppSemanticColors.minorError).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: isMajor ? AppSemanticColors.majorError : AppSemanticColors.minorError,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cap ${error.capA} → Cap ${error.capB}',
                          style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          isMajor ? 'Major Crossover (dist: ${error.distance})' : 'Minor Swap (dist: ${error.distance})',
                          style: TextStyle(
                            color: colors.onSurfaceVariant.withOpacity(0.75),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildConfusionLineLegendText(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildConfusionLineLegendText(ColorScheme colors) {
    final baseStyle = TextStyle(color: colors.onSurfaceVariant, fontSize: 13, height: 1.5);
    final boldStyle = TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 13, height: 1.5);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'A '),
          TextSpan(text: '"swap"', style: boldStyle),
          const TextSpan(
            text: ' means two neighboring caps were placed close but out of order, usually harmless and common even in typical vision. \n\n A ',
          ),
          TextSpan(text: '"crossover"', style: boldStyle),
          const TextSpan(
            text: ' means caps far apart on the wheel were confused for each other, which is the stronger signal of a real color vision difference. Higher distance numbers mean a bigger jump.',
          ),
        ],
      ),
    );
  }

// -------------------- Footer buttons --------------------
  Widget _buildFooterButtons(BuildContext context, ColorScheme colors) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _exportAsPdf(context),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.download, size: 20),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            minimumSize: const Size(double.infinity, 55),
          ),
          label: const Text('Export as PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter')),
        ),
        const SizedBox(height: 12), 
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          label: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter')),
          iconAlignment: IconAlignment.start,
          icon: const Icon(Icons.arrow_back, size: 20),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onSurface,
            side: BorderSide(color: colors.onSurfaceVariant.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  void _exportAsPdf(BuildContext context) {
    // TODO: wire up real PDF export (e.g. the `pdf` + `printing` packages) —
    // same stub as AssessmentSummaryScreen's Export button.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon')),
    );
  }
}