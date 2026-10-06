import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/services/auditory_feedback_service.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/theme/cvd_color_tokens.dart';
import 'package:gabeye/core/theme/cvd_personalization_controller.dart';
import 'package:gabeye/core/theme/theme_controller.dart';

/// Screen allowing users to configure Personalized Accessibility settings:
/// - Visual: Dark Mode & Personalize UI (CVD theme adaptation)
/// - Auditory: Voice Narration (TTS) toggle, Speech Speed slider, and Test Voice
class PersonalizedAccessibilityScreen extends StatefulWidget {
  const PersonalizedAccessibilityScreen({super.key});

  @override
  State<PersonalizedAccessibilityScreen> createState() =>
      _PersonalizedAccessibilityScreenState();
}

class _PersonalizedAccessibilityScreenState
    extends State<PersonalizedAccessibilityScreen> {
  late bool _ttsEnabled;
  late double _speechRate;

  @override
  void initState() {
    super.initState();
    _ttsEnabled = AuditoryFeedbackService.instance.ttsEnabled;
    _speechRate = AuditoryFeedbackService.instance.ttsSpeechRate;
  }

  String _getSpeedLabel(double rate) {
    if (rate <= 0.35) return 'Slow';
    if (rate <= 0.60) return 'Normal';
    if (rate <= 0.80) return 'Fast';
    return 'Very Fast';
  }

  String _getCvdProfileLabel(CvdProfile profile) {
    switch (profile) {
      case CvdProfile.protan:
        return 'Protan';
      case CvdProfile.deutan:
        return 'Deutan';
      case CvdProfile.tritan:
        return 'Tritan';
      case CvdProfile.none:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Personalized Accessibility',
          onBack: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Description
              Text(
                'Customize your visual and auditory experience in GabEye to suit your sight and interaction preferences.',
                style: GoogleFonts.atkinsonHyperlegible(
                  fontSize: 14,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Visual Experience
              Text(
                'Visual Experience',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildVisualSection(context, isDark, colorScheme, textTheme),

              const SizedBox(height: 28),

              // Section 2: Voice Feedback & Narration
              Text(
                'Voice Feedback & Narration',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildAuditorySection(context, isDark, colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualSection(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.primaryNavy.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          // Dark Mode Toggle
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeController,
            builder: (context, themeMode, _) {
              final isDarkMode = themeMode == ThemeMode.dark;
              return InkWell(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                onTap: () => themeController.setDarkMode(!isDarkMode),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.dark_mode_outlined,
                        size: 22,
                        color: isDark ? Colors.white : AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Switch between dark and light themes',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        onChanged: themeController.setDarkMode,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.cardBorder.withValues(alpha: 0.5),
          ),

          // Personalize UI Toggle
          AnimatedBuilder(
            animation: cvdPersonalizationController,
            builder: (context, _) {
              final supported = cvdPersonalizationController.isSupported;
              final enabled = cvdPersonalizationController.isEnabled;
              final activeProfile = cvdPersonalizationController.activeProfile;

              String subtitle;
              if (supported) {
                final profileLabel = _getCvdProfileLabel(activeProfile);
                final profileName = activeProfile != CvdProfile.none
                    ? '$profileLabel profile'
                    : 'your assessment diagnosis';
                subtitle = 'Adapted UI palette for $profileName';
              } else {
                subtitle =
                    'Available once assessment identifies a supported CVD profile';
              }

              return InkWell(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                onTap: supported
                    ? () => cvdPersonalizationController.setEnabled(!enabled)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 22,
                        color: supported
                            ? (isDark ? Colors.white : AppColors.primaryNavy)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Personalize UI',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: supported
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                  ),
                                ),
                                if (enabled && activeProfile != CvdProfile.none) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.accentColor
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getCvdProfileLabel(activeProfile),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: context.accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              subtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: supported ? 1.0 : 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: enabled,
                        onChanged: supported
                            ? cvdPersonalizationController.setEnabled
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditorySection(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.primaryNavy.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice Feedback Toggle
          Row(
            children: [
              Icon(
                _ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: isDark ? Colors.white : AppColors.primaryNavy,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Narration (TTS)',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Spoken object & color feedback',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _ttsEnabled,
                onChanged: (val) async {
                  setState(() => _ttsEnabled = val);
                  await AuditoryFeedbackService.instance.setTtsEnabled(val);
                },
              ),
            ],
          ),
          const Divider(height: 24),

          // Speech Speed Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speech Speed',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${_speechRate.toStringAsFixed(2)}x (${_getSpeedLabel(_speechRate)})',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: context.accentColor,
                ),
              ),
            ],
          ),
          Slider(
            value: _speechRate.clamp(0.25, 1.0),
            min: 0.25,
            max: 1.0,
            divisions: 15,
            onChanged: _ttsEnabled
                ? (val) {
                    setState(() => _speechRate = val);
                    AuditoryFeedbackService.instance.setTtsSpeechRate(val);
                  }
                : null,
          ),

          // Test Voice Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _ttsEnabled
                  ? () {
                      AuditoryFeedbackService.instance.speakText(
                        'Testing GabEye voice speed at ${_speechRate.toStringAsFixed(2)} speed.',
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Test Voice'),
            ),
          ),
        ],
      ),
    );
  }
}
