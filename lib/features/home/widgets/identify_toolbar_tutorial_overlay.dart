import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Item model for Identify (KNN) Mode tutorial steps.
class IdentifyTutorialStep {
  final String title;
  final String description;
  final IconData icon;

  const IdentifyTutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// A dedicated floating tutorial overlay widget for Identify (KNN Color Identification) mode.
/// Uses exact [Rect] target positions derived from GlobalKeys for pixel-perfect placement.
class IdentifyToolbarTutorialOverlay extends StatelessWidget {
  final int stepIndex;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  static const List<IdentifyTutorialStep> steps = [
    IdentifyTutorialStep(
      title: 'Object Labeling (ML Kit)',
      description: 'Identifies objects in live camera view with real-time bounding boxes & labels.',
      icon: Icons.category_rounded,
    ),
    IdentifyTutorialStep(
      title: 'Zoom Control',
      description: 'Adjust camera magnification from 1.0x to 5.0x for detailed color inspection.',
      icon: Icons.zoom_in_rounded,
    ),
    IdentifyTutorialStep(
      title: 'Split Screen View',
      description: 'Side-by-side comparison (Top = Color Identification / Bottom = CVD Simulation).',
      icon: Icons.splitscreen_rounded,
    ),
    IdentifyTutorialStep(
      title: 'Voice Narration',
      description: 'Tap to hear spoken audio feedback of current identified colors or detected objects.',
      icon: Icons.volume_up_rounded,
    ),
  ];

  const IdentifyToolbarTutorialOverlay({
    super.key,
    required this.stepIndex,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLastStep = stepIndex >= steps.length - 1;
    final step = steps[stepIndex.clamp(0, steps.length - 1)];

    final Rect target = targetRect ??
        Rect.fromLTWH(
          MediaQuery.of(context).size.width - 60,
          MediaQuery.of(context).size.height / 2,
          48,
          48,
        );

    final double modalTop = (target.top + (target.height / 2) - 80)
        .clamp(80.0, MediaQuery.of(context).size.height - 240);

    return Stack(
      children: [
        // Semi-transparent backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: isLastStep ? onComplete : onNext,
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ),

        // Pixel-perfect Target Pulse Ring around floating button
        Positioned(
          left: target.left - 4,
          top: target.top - 4,
          width: target.width + 8,
          height: target.height + 8,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.65),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Glassmorphic Modal Card & Pointer Arrow
        Positioned(
          right: (MediaQuery.of(context).size.width - target.left + 8).clamp(60.0, MediaQuery.of(context).size.width - 270),
          top: modalTop,
          child: Material(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modal Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Step Badge & Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colors.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  'Identify Step ${stepIndex + 1} of ${steps.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              Icon(step.icon, size: 20, color: colors.primary),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Description
                          Text(
                            step.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: onSkip,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(fontSize: 12, color: Colors.white54),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: isLastStep ? onComplete : onNext,
                                icon: Icon(
                                  isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Colors.black,
                                ),
                                label: Text(
                                  isLastStep ? 'Got it!' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Arrow Pointer pointing to the target button
                Icon(
                  Icons.arrow_right_rounded,
                  size: 32,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
