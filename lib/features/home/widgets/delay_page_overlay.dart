import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Full-screen modular Delay Page overlay component matching light & dark mode specifications.
/// Displays GabEye logo emblem, loading text, animated progress bar, and bottom hand illustration asset.
class DelayPageOverlay extends StatelessWidget {
  final double progress;

  const DelayPageOverlay({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const backgroundColor = Color(0xFF0F4C81);
    final cardBackgroundColor = isDark ? const Color(0xFF161E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    final progressTrackColor = isDark ? const Color(0xFF2C384C) : const Color(0xFFE5E7EB);
    final progressFillColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4E82);

    return Material(
      color: backgroundColor,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bottom SVG Asset (full asset display)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 140,
                child: SvgPicture.asset(
                  'assets/images/delay_assets.svg',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            // Centered Floating Card
            Center(
              child: Container(
                width: 290,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // GabEye Logo emblem
                    SvgPicture.asset(
                      'assets/images/gabEyeLogo.svg',
                      width: 90,
                      height: 90,
                    ),
                    const SizedBox(height: 20),
                    // Subtitle text
                    Text(
                      'Getting your view ready. Please wait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Smooth animated linear progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 8,
                        width: double.infinity,
                        color: progressTrackColor,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: progressFillColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
