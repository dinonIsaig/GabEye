import 'package:flutter/material.dart';

enum AssistanceMode { remapColor, identifyColor }

/// Shows the "Choose Assistance Mode" dialog matching the GabEye design.
Future<AssistanceMode?> showAssistanceModeModal(BuildContext context) {
  return showDialog<AssistanceMode>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const AssistanceModeModal(),
  );
}

class AssistanceModeModal extends StatelessWidget {
  const AssistanceModeModal({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryButtonBg = isDark ? colors.primary : const Color(0xFF163E67);
    final primaryButtonFg = Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Paint Bucket Circular Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryButtonBg,
                border: Border.all(
                  color: isDark ? colors.primaryContainer : Colors.black87,
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.format_color_fill_rounded,
                  size: 38,
                  color: primaryButtonFg,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Choose Assistance Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              'Choose among available assistance mode to apply in your uploaded image',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Action Buttons
            // 1. Remap Color Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(AssistanceMode.remapColor),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryButtonBg,
                foregroundColor: primaryButtonFg,
                elevation: 3,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Remap Color',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Identify Color Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(AssistanceMode.identifyColor),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryButtonBg,
                foregroundColor: primaryButtonFg,
                elevation: 3,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Identify Color',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Cancel Button
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                foregroundColor: colors.onSurface,
                side: BorderSide(
                  color: colors.outline.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
