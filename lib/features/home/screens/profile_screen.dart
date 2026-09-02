import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/pdf_report_service.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _customIntensity = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: ValueListenableBuilder(
        valueListenable: VisionProfileService.instance,
        builder: (context, result, _) {
          final hasAssessment = VisionProfileService.instance.hasCompletedAssessment;
          final profileLabel = VisionProfileService.instance.activeProfileLabel;
          final scoreResult = VisionProfileService.instance.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar & Name Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vision Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        profileLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Farnsworth D-15 Assessment Results Card
              Text(
                'D-15 Assessment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      context,
                      label: 'Diagnosis Type',
                      value: scoreResult?.shortName ?? 'Unassessed',
                      icon: Icons.remove_red_eye,
                    ),
                    const Divider(height: 20),
                    _buildMetricRow(
                      context,
                      label: 'Deficiency Severity',
                      value: scoreResult?.severityLabel ?? 'Moderate (Default)',
                      icon: Icons.speed,
                    ),
                    const Divider(height: 20),
                    _buildMetricRow(
                      context,
                      label: 'Confusion Index (C-Index)',
                      value: scoreResult != null
                          ? scoreResult.cIndex.toStringAsFixed(2)
                          : '1.50 (Standard)',
                      icon: Icons.analytics_outlined,
                    ),
                    if (scoreResult != null) ...[
                      const Divider(height: 20),
                      _buildMetricRow(
                        context,
                        label: 'Major Error Angle',
                        value: '${scoreResult.angle.toStringAsFixed(1)}°',
                        icon: Icons.explore_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.preAssessmentIntro);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          hasAssessment ? 'Retake Farnsworth D-15 Test' : 'Take D-15 Assessment',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          PdfReportService.generateAndExportPdf(
                            context,
                            scoreResult: scoreResult,
                            arrangedCaps: VisionProfileService.instance.arrangedCaps,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: const Text(
                          'Export PDF Report for Professionals',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          side: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Daltonization Calibration & Preview
              Text(
                'LMS Daltonization Shift Calibration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enhancement Intensity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          '${(_customIntensity * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _customIntensity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: colors.primary,
                      onChanged: (val) {
                        setState(() {
                          _customIntensity = val;
                        });
                      },
                    ),
                    Text(
                      'Adjusts visible error channel projection to maximize color contrast for Protan, Deutan, and Tritan views.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings & Quick Options List
              Text(
                'Account & Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              _buildOptionTile(
                context,
                title: 'Settings',
                subtitle: 'Theme, permissions, and app config',
                icon: Icons.settings_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                context,
                title: 'Help & Feedback',
                subtitle: 'FAQs, contact support, send feedback',
                icon: Icons.help_outline_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.helpFeedback),
              ),
              const SizedBox(height: 8),
              _buildOptionTile(
                context,
                title: 'About GabEye',
                subtitle: 'Version info, research & documentation',
                icon: Icons.info_outline_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.article),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    // Using Container with InkWell for custom border radius
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
