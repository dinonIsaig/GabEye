import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/onboarding/services/scoring_service.dart';
import 'package:gabeye/features/onboarding/widgets/confusion_diagram.dart';

class ResultsPage extends StatelessWidget {
  final List<int> arrangedCaps;

  const ResultsPage({super.key, required this.arrangedCaps});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // scoring calculation
    final D15ScoreResult result = ScoringService.calculateScore(arrangedCaps);

    // Diagnosis badge color stays semantic (red = Protan, amber = Deutan,
    // etc.) regardless of light/dark mode — these carry meaning, they're
    // not decorative theme colors.
    Color diagColor;
    String badgeText;
    switch (result.diagnosisType) {
      case ColorDeficiencyType.normal:
        diagColor = AppSemanticColors.normal;
        badgeText = "Normal";
        break;
      case ColorDeficiencyType.protan:
        diagColor = AppSemanticColors.protan;
        badgeText = "Protan Defect";
        break;
      case ColorDeficiencyType.deutan:
        diagColor = AppSemanticColors.deutan;
        badgeText = "Deutan Defect";
        break;
      case ColorDeficiencyType.tritan:
        diagColor = AppSemanticColors.tritan;
        badgeText = "Tritan Defect";
        break;
      default:
        diagColor = colors.onSurfaceVariant;
        badgeText = "Deficiency";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Results', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grid Layout for larger screens, sequential for smaller screens
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  ConfusionDiagram(arrangedCaps: arrangedCaps),
                                  const SizedBox(height: 12),
                                  Text(
                                    'CIE L*u*v* Confusion Plot',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 5,
                              child: _buildDiagnosticDetails(context, result, badgeText, diagColor),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  ConfusionDiagram(arrangedCaps: arrangedCaps),
                                  const SizedBox(height: 8),
                                  Text(
                                    'CIE L*u*v* Confusion Plot',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDiagnosticDetails(context, result, badgeText, diagColor),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Metrics Card Row
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard(context, 'C-Index', result.cIndex.toStringAsFixed(2))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard(context, 'S-Index', result.sIndex.toStringAsFixed(2))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard(context, 'Angle', '${result.angle.toStringAsFixed(1)}°')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Crossover Line Summary List
                  Container(
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
                          'Confusion Line Summary',
                          style: TextStyle(color: colors.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (result.crossings.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No crossing errors detected. Perfect arrangement!',
                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                            ),
                          )
                        else
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
                                  color: colors.onSurfaceVariant.withOpacity(0.03),
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
                                    Text(
                                      'Cap ${error.capA} → Cap ${error.capB}',
                                      style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      isMajor
                                          ? 'Major Crossover (dist: ${error.distance})'
                                          : 'Minor Swap (dist: ${error.distance})',
                                      style: TextStyle(
                                        color: isMajor ? AppSemanticColors.majorError : AppSemanticColors.minorError,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context), // Retake: back to the arrangement tray
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticDetails(
      BuildContext context, D15ScoreResult result, String badgeText, Color diagColor) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: diagColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: diagColor.withOpacity(0.4)),
          ),
          child: Text(
            badgeText,
            style: TextStyle(color: diagColor, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          result.diagnosisName,
          style: TextStyle(color: colors.onSurface, fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          result.conesAffected,
          style: TextStyle(color: colors.primary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          result.description,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: colors.onSurface, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// semantic colors for diagnosis results and error severity.
// These are intentionally NOT pulled from the light/dark theme 
// will change this according to the updated ui
class AppSemanticColors {
  AppSemanticColors._();

  static const Color normal = AppColors.successGreen;
  static const Color protan = AppColors.errorRed;
  static const Color deutan = Color(0xFFF59E0B); // amber-500 — not yet in AppColors
  static const Color tritan = Color(0xFF3B82F6); // blue-500 — not yet in AppColors
  static const Color majorError = Color(0xFFF43F5E); // rose-500 — not yet in AppColors
  static const Color minorError = AppColors.successGreen;
}