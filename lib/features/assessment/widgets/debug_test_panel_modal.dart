import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/config/debug_test_profiles.dart';

class DebugTestPanelModal extends StatelessWidget {
  final void Function(List<int> arrangedCaps) onProfileSelected;

  const DebugTestPanelModal({super.key, required this.onProfileSelected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'TESTING PANEL',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: colors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Auto-fill Tray',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Instantly places a pre-verified arrangement so you can preview a given result without dragging 15 caps by hand.',
              style: TextStyle(fontSize: 13, height: 1.4, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: debugTestProfiles.map((profile) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onProfileSelected(profile.arrangedCaps);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkSurface : colors.onSurface,
                          backgroundColor: isDark ? AppColors.darkPrimaryButton : Colors.transparent,
                          side: isDark ? BorderSide.none : BorderSide(color: colors.onSurfaceVariant.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          profile.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.darkSurface : colors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showDebugTestPanel(BuildContext context, {required void Function(List<int>) onProfileSelected}) {
  showDialog(
    context: context,
    builder: (context) => DebugTestPanelModal(onProfileSelected: onProfileSelected),
  );
}
