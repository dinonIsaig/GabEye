import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/home_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/config/diagnosis_presentation.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
import 'package:gabeye/features/home/widgets/gabeye_bottom_nav.dart';

/// Screen for users to look back at their Color Vision Profile anytime
/// from the bottom navigation bar and download their PDF copy.
class ColorVisionProfileLookbackScreen extends StatelessWidget {
  final List<int> arrangedCaps;

  const ColorVisionProfileLookbackScreen({
    super.key,
    this.arrangedCaps = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GabEyeHomeNavbar(
          onBack: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: ColorVisionProfileLookbackContent(arrangedCaps: arrangedCaps),
      ),
      bottomNavigationBar: GabEyeBottomNav(
        selectedIndex: 2,
        onItemSelected: (index) {
          if (index == 0) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera feature coming soon!'),
              ),
            );
          }
        },
      ),
    );
  }
}

/// Standalone content widget for Color Vision Profile lookback, reusable in
/// [HomeScreen]'s [IndexedStack] and in [ColorVisionProfileLookbackScreen].
class ColorVisionProfileLookbackContent extends StatelessWidget {
  final List<int> arrangedCaps;

  const ColorVisionProfileLookbackContent({
    super.key,
    this.arrangedCaps = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
  });

  static Color getResultStateColor(D15ScoreResult result) {
    if (result.diagnosisType == ColorDeficiencyType.random ||
        result.diagnosisType == ColorDeficiencyType.unclassified) {
      return AppColors.resultUnidentifiedColor;
    }
    switch (result.severity) {
      case SeverityLevel.none:
        return AppColors.resultNormalColor;
      case SeverityLevel.moderate:
        return AppColors.resultModerateColor;
      case SeverityLevel.strong:
        return AppColors.resultAboveTypicalColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final D15ScoreResult result = ScoringService.calculateScore(arrangedCaps);
    final severityStyle = severityStyles[result.severity]!;
    final diagnosisStyle = diagnosisStyles[result.diagnosisType]!;

    return SingleChildScrollView(
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
                    _buildRangeBanner(context, colors, result, severityStyle),
                    const SizedBox(height: 16),
                    _buildDiagnosisCard(
                      context,
                      colors,
                      result,
                      severityStyle,
                      diagnosisStyle,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- "Above/within typical range" banner --------------------
  Widget _buildRangeBanner(
    BuildContext context,
    ColorScheme colors,
    D15ScoreResult result,
    SeverityStyle severityStyle,
  ) {
    final stateColor = getResultStateColor(result);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stateColor.withValues(alpha: isDark ? 0.6 : 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: stateColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(severityStyle.icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  result.rangeHeadline,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.rangeBody,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Main Diagnosis card --------------------
  Widget _buildDiagnosisCard(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.onSurfaceVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Based on your result, you likely have...',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildOverlappingCircles(diagnosisStyle),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.shortName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
                child: _buildMetricBox(
                  label: 'Severity',
                  value: result.severityLabel,
                  backgroundColor: severityStyle.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  label: 'Type',
                  value: result.shortName,
                  backgroundColor: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  label: 'Affected',
                  value: result.conesShortLabel,
                  backgroundColor: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            result.practicalTip,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _goToDetailedResult(context),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 16),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            label: const Text(
              'View Detailed Result',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _downloadPdf(context, result),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.download, size: 16),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              side: BorderSide(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            label: const Text(
              'Download PDF Copy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Description --------------------
  Widget _buildDescription(
    ColorScheme colors,
    D15ScoreResult result,
    DiagnosisStyle style,
  ) {
    final baseStyle = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 16,
      height: 1.5,
    );

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Overlapping color circles --------------------
  Widget _buildOverlappingCircles(DiagnosisStyle style) {
    return SizedBox(
      width: 32,
      height: 20,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: style.primaryColor,
            ),
          ),
          Positioned(
            left: 12,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: style.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Metric chip --------------------
  Widget _buildMetricBox({
    required String label,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------- Actions --------------------
  void _goToDetailedResult(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(arrangedCaps: arrangedCaps),
      ),
    );
  }

  void _downloadPdf(BuildContext context, D15ScoreResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Downloading Color Vision Profile (${result.shortName}) PDF...',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
