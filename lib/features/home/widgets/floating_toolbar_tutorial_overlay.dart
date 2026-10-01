import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Item model representing a single step in the floating toolbar tutorial.
class TutorialStepItem {
  final String title;
  final String description;
  final IconData icon;
  final String buttonTooltip;

  const TutorialStepItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonTooltip,
  });
}

/// A modular floating modal overlay for Vision Lens right-side toolbar buttons.
class FloatingToolbarTutorialOverlay extends StatelessWidget {
  final int currentStepIndex;
  final int totalSteps;
  final TutorialStepItem stepItem;
  final double targetButtonBottomOffset;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  const FloatingToolbarTutorialOverlay({
    super.key,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.stepItem,
    required this.targetButtonBottomOffset,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLastStep = currentStepIndex >= totalSteps - 1;

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

        // Floating Target Pulse Ring over right-side button
        Positioned(
          right: 18,
          bottom: targetButtonBottomOffset - 3,
          child: IgnorePointer(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary,
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating Tutorial Card Modal (Positioned left of the toolbar)
        Positioned(
          right: 84,
          bottom: (targetButtonBottomOffset - 25).clamp(100.0, MediaQuery.of(context).size.height - 250),
          child: Material(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tooltip Glassmorphic Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
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
                                  'Step ${currentStepIndex + 1} of $totalSteps',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              Icon(
                                stepItem.icon,
                                size: 20,
                                color: colors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            stepItem.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Description
                          Text(
                            stepItem.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Actions: Skip vs Next/Got it!
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
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

                // Right Arrow Pointer pointing toward target button
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
