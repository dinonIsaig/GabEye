import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/theme/cvd_personalization_controller.dart';
import 'package:gabeye/data/local/database_helper.dart';
import 'package:gabeye/data/models/accessibility_preferences.dart';
import 'package:gabeye/data/models/adaptive_ui_settings.dart';
import 'package:gabeye/data/models/diagnostic_data.dart';
import 'package:gabeye/data/models/user_profile.dart';

/// Screen displaying the user's live local SQLite database records across
/// User_Profile, Diagnostic_Data, Adaptive_UI_Settings, and Accessibility_Preferences.
class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  UserProfile? _userProfile;
  DiagnosticData? _diagnosticData;
  AdaptiveUiSettings? _uiSettings;
  AccessibilityPreferences? _accessibilityPreferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  Future<void> _loadDatabaseData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await DatabaseHelper.instance.getUserProfile(1);
      final diagnostic = await DatabaseHelper.instance.getDiagnosticData(1);
      final ui = await DatabaseHelper.instance.getUiSettings(1);
      final accessibility = await DatabaseHelper.instance.getAccessibilityPreferences(1);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _diagnosticData = diagnostic;
          _uiSettings = ui;
          _accessibilityPreferences = accessibility;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetDiagnosticData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Diagnostic Data?'),
        content: const Text(
          'This will clear the stored D-15 assessment result and reset UI themes back to Default. You will be able to take the assessment again from scratch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.resetAssessmentData(1);
      VisionProfileService.instance.clearAssessmentResult();
      cvdPersonalizationController.resetForNewAttempt();
      await _loadDatabaseData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnostic assessment data has been reset.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Personal Data',
          onBack: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Offline Security Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: isDark ? context.accentColor : AppColors.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offline Local Storage Active',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Protected under RA 10173 (Data Privacy Act). All health profiles and settings are stored locally on your device.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Table 1: User_Profile
                    _buildTableCard(
                      context,
                      title: 'Table: User_Profile',
                      subtitle: 'Local root profile & creation timestamps',
                      icon: Icons.person_outline_rounded,
                      rows: [
                        _DataRowInfo('_id', '${_userProfile?.id ?? 1}', 'INTEGER (PK)'),
                        _DataRowInfo(
                          'created_at',
                          _userProfile?.createdAt.toLocal().toString().split('.').first ?? 'N/A',
                          'TEXT (ISO-8601)',
                        ),
                        _DataRowInfo(
                          'updated_at',
                          _userProfile?.updatedAt.toLocal().toString().split('.').first ?? 'N/A',
                          'TEXT (ISO-8601)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Table 2: Diagnostic_Data
                    _buildTableCard(
                      context,
                      title: 'Table: Diagnostic_Data',
                      subtitle: 'Farnsworth D-15 assessment result',
                      icon: Icons.biotech_outlined,
                      rows: [
                        _DataRowInfo('user_id', '${_diagnosticData?.userId ?? 1}', 'INTEGER (PK, FK)'),
                        _DataRowInfo(
                          'has_taken_test',
                          '${_diagnosticData?.hasTakenTest ?? false}',
                          'INTEGER (BOOLEAN)',
                        ),
                        _DataRowInfo('cvd_type', _diagnosticData?.cvdType ?? 'null (Not Taken)', 'TEXT'),
                        _DataRowInfo('severity', _diagnosticData?.severity ?? 'null (Not Taken)', 'TEXT'),
                        _DataRowInfo(
                          'test_date',
                          _diagnosticData?.testDate != null
                              ? _diagnosticData!.testDate!.toLocal().toString().split('.').first
                              : 'null',
                          'TEXT (ISO-8601)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Table 3: Adaptive_UI_Settings
                    _buildTableCard(
                      context,
                      title: 'Table: Adaptive_UI_Settings',
                      subtitle: 'WCAG-compliant UI theme & accessibility tokens',
                      icon: Icons.palette_outlined,
                      rows: [
                        _DataRowInfo('user_id', '${_uiSettings?.userId ?? 1}', 'INTEGER (PK, FK)'),
                        _DataRowInfo('applied_theme', _uiSettings?.appliedTheme ?? 'Default', 'TEXT'),
                        _DataRowInfo(
                          'color_agnostic_mode',
                          '${_uiSettings?.colorAgnosticMode ?? false}',
                          'INTEGER (BOOLEAN)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Table 4: Accessibility_Preferences
                    _buildTableCard(
                      context,
                      title: 'Table: Accessibility_Preferences',
                      subtitle: 'Text-to-Speech audio narration speed & state',
                      icon: Icons.record_voice_over_outlined,
                      rows: [
                        _DataRowInfo(
                          'user_id',
                          '${_accessibilityPreferences?.userId ?? 1}',
                          'INTEGER (PK, FK)',
                        ),
                        _DataRowInfo(
                          'tts_enabled',
                          '${_accessibilityPreferences?.ttsEnabled ?? false}',
                          'INTEGER (BOOLEAN)',
                        ),
                        _DataRowInfo(
                          'tts_speech_rate',
                          '${_accessibilityPreferences?.ttsSpeechRate.toStringAsFixed(2) ?? '0.50'}x',
                          'REAL (FLOAT)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loadDatabaseData,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Refresh Data'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetDiagnosticData,
                            icon: const Icon(Icons.restart_alt_rounded, size: 18, color: Colors.redAccent),
                            label: const Text(
                              'Reset Data',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_DataRowInfo> rows,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.cardBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.atkinsonHyperlegible(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.columnName,
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            row.dataType,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: row.value.contains('null')
                              ? Colors.orangeAccent
                              : (row.value == 'true'
                                  ? Colors.greenAccent.shade700
                                  : colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DataRowInfo {
  final String columnName;
  final String value;
  final String dataType;

  _DataRowInfo(this.columnName, this.value, this.dataType);
}
