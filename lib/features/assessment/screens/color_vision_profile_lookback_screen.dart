import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/home_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/pdf_report_service.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/config/diagnosis_presentation.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/features/assessment/services/assessment_controller.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';
import 'package:gabeye/features/assessment/widgets/profile_heading_banner.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/features/home/widgets/gabeye_bottom_nav.dart';

/// Screen for users to look back at their Color Vision Profile anytime
/// from the bottom navigation bar and download their PDF copy.
class ColorVisionProfileLookbackScreen extends StatelessWidget {
  final List<int>? arrangedCaps;

  const ColorVisionProfileLookbackScreen({
    super.key,
    this.arrangedCaps,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCaps = arrangedCaps ?? assessmentController.value;

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
        child: ColorVisionProfileLookbackContent(arrangedCaps: effectiveCaps),
      ),
      bottomNavigationBar: GabEyeBottomNav(
        selectedIndex: 2,
        onItemSelected: (index) {
          if (index == 0 || index == 1) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          }
        },
      ),
    );
  }
}

/// Standalone content widget for Color Vision Profile lookback, reusable in
/// [HomeScreen]'s [IndexedStack] and in [ColorVisionProfileLookbackScreen].
class ColorVisionProfileLookbackContent extends StatelessWidget {
  final List<int>? arrangedCaps;

  const ColorVisionProfileLookbackContent({
    super.key,
    this.arrangedCaps,
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
    final effectiveCaps = arrangedCaps ?? assessmentController.value;
    final colors = Theme.of(context).colorScheme;
    final List<int> effectiveCaps = arrangedCaps ?? VisionProfileService.instance.arrangedCaps;
    final D15ScoreResult result = (arrangedCaps == null && VisionProfileService.instance.value != null)
        ? VisionProfileService.instance.value!
        : ScoringService.calculateScore(effectiveCaps);
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      padding: const EdgeInsets.all(16),
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
                    fontSize: 20,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                ) ??
                const TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  fontSize: 16,
                ),
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
          _buildDescription(context, colors, result, diagnosisStyle),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.5,
                ) ??
                TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _goToDetailedResult(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimaryButton : AppColors.lightPrimaryButton,
              foregroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'View Detailed Result',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _downloadPdf(context, result),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              backgroundColor: isDark ? colors.surfaceContainer : Colors.transparent,
              side: BorderSide(
                color: isDark ? colors.outline : colors.onSurfaceVariant.withValues(alpha: 0.4),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Download PDF Copy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.download, size: 16, color: colors.onSurface),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Description --------------------
  Widget _buildDescription(
    BuildContext context,
    ColorScheme colors,
    D15ScoreResult result,
    DiagnosisStyle style,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = (textTheme.bodyMedium ?? const TextStyle(fontFamily: 'AtkinsonHyperlegible')).copyWith(
      color: colors.onSurfaceVariant,
      fontSize: 16,
      height: 1.5,
    );
    final boldStyle = (textTheme.bodyLarge ?? const TextStyle(fontFamily: 'AtkinsonHyperlegible')).copyWith(
      color: colors.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.5,
    );

    if (result.diagnosisType == ColorDeficiencyType.normal) {
      return RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(
              text:
                  'Your results suggest typical color vision with no significant color deficiency detected. This means your eyes have ',
            ),
            TextSpan(
              text: style.highlightPhrase.isNotEmpty
                  ? style.highlightPhrase
                  : 'no difficulty distinguishing colors across the spectrum.',
              style: boldStyle,
            ),
          ],
        ),
      );
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
            style: boldStyle,
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Actions --------------------
  void _goToDetailedResult(BuildContext context) {
    final caps = arrangedCaps ?? VisionProfileService.instance.arrangedCaps;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(arrangedCaps: caps),
      ),
    );
  }

  void _downloadPdf(BuildContext context, D15ScoreResult result) {
    final caps = arrangedCaps ?? VisionProfileService.instance.arrangedCaps;
    PdfReportService.generateAndExportPdf(
      context,
      scoreResult: result,
      arrangedCaps: caps,
    );
  }
}
