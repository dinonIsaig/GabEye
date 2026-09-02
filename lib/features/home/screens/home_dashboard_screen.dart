import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback onLaunchCamera;

  const HomeDashboardScreen({
    super.key,
    required this.onLaunchCamera,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'GabEye Vision Hub',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.15),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.remove_red_eye_rounded,
                  color: colors.primary,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active D-15 Vision Profile Summary Card
          ValueListenableBuilder(
            valueListenable: VisionProfileService.instance,
            builder: (context, result, _) {
              final hasAssessment = VisionProfileService.instance.hasCompletedAssessment;
              final profileLabel = VisionProfileService.instance.activeProfileLabel;
              final severityLabel = VisionProfileService.instance.severityLabel;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [colors.primaryContainer, colors.surfaceContainerHigh]
                        : [colors.primary, colors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colors.onPrimaryContainer.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasAssessment ? Icons.verified_rounded : Icons.pending_rounded,
                                size: 14,
                                color: isDark ? colors.onPrimaryContainer : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasAssessment ? 'Calibrated D-15 Profile' : 'Default Profile',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? colors.onPrimaryContainer : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.preAssessmentIntro);
                          },
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: isDark ? colors.onPrimaryContainer : Colors.white,
                          ),
                          tooltip: 'Retake Assessment',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profileLabel,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? colors.onPrimaryContainer : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAssessment
                          ? 'Calibrated LMS error shifting active for $severityLabel deficiency.'
                          : 'Complete the D-15 test to personalize contrast enhancement.',
                      style: TextStyle(
                        fontSize: 13,
                        color: (isDark ? colors.onPrimaryContainer : Colors.white)
                            .withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (hasAssessment) {
                          onLaunchCamera();
                        } else {
                          Navigator.pushNamed(context, AppRoutes.preAssessmentIntro);
                        }
                      },
                      icon: Icon(
                        hasAssessment ? Icons.videocam_rounded : Icons.play_arrow_rounded,
                        size: 18,
                      ),
                      label: Text(
                        hasAssessment ? 'Open Vision Lens' : 'Take D-15 Assessment',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? colors.primary : Colors.white,
                        foregroundColor: isDark ? colors.onPrimary : colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Quick Action Cards Grid
          Text(
            'Vision Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Vision Lens',
                  subtitle: 'Live LMS remapping',
                  icon: Icons.camera_alt_rounded,
                  color: colors.primary,
                  onTap: onLaunchCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'D-15 Test',
                  subtitle: 'Color vision test',
                  icon: Icons.assignment_turned_in_rounded,
                  color: colors.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.preAssessmentIntro);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Featured Reads',
                  subtitle: 'Articles & Insights',
                  icon: Icons.article_rounded,
                  color: colors.tertiary,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.article);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  title: 'Settings',
                  subtitle: 'App & Theme',
                  icon: Icons.settings_rounded,
                  color: colors.outline,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vision Accessibility Information Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Physiological Daltonization',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transforms RGB colors to LMS cone space, calculating perceived color loss and projecting it into visible channels.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
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
    );
  }
}
