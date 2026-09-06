import 'package:flutter/material.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class AssessmentIntroModal extends StatelessWidget {
  const AssessmentIntroModal({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- How it works ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: colors.onSurfaceVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works?',
                    style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arrange discs by hues',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drag and drop the color discs below to arrange them in a continuous sequence, starting from the fixed reference disc on the left.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                        Navigator.popAndPushNamed(context, AppRoutes.preAssessmentHowItWorks);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.darkSurface : colors.onSurface,
                      backgroundColor: isDark ? AppColors.darkPrimaryButton : Colors.transparent,
                      side: isDark
                          ? BorderSide.none
                          : BorderSide(
                              color: colors.onSurfaceVariant.withOpacity(0.4),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 18,
                          color: isDark ? AppColors.darkSurface : colors.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.darkSurface : colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
           
            const SizedBox(height: 16),
           
            // --- Ready to Start ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: colors.onSurfaceVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checking in...',
                    style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to Start?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Drag and drop the color discs below to arrange them in a continuous sequence, starting from the fixed reference disc on the left.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // assessment flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkPrimaryButton : AppColors.lightPrimaryButton,
                      foregroundColor: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      'Start Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.getStarted),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.darkSurface : colors.onSurface,
                      backgroundColor: isDark ? AppColors.darkPrimaryButton : Colors.transparent,
                      side: isDark
                          ? BorderSide.none
                          : BorderSide(
                              color: colors.onSurfaceVariant.withOpacity(0.4),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      'Not Ready',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Update the function to use showDialog instead of showModalBottomSheet
void showAssessmentIntroModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents closing when tapping outside, matching the previous logic
    builder: (BuildContext context) {
      return const AssessmentIntroModal();
    },
  );
}

