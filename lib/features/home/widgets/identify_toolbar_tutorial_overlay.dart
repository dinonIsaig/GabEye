import 'package:flutter/material.dart';
import 'package:gabeye/features/home/widgets/toolbar_tutorial_overlay.dart';

/// A dedicated floating tutorial overlay widget for Identify (KNN Color Identification) mode.
/// Uses exact [Rect] target positions derived from GlobalKeys for pixel-perfect placement.
class IdentifyToolbarTutorialOverlay extends StatelessWidget {
  final int stepIndex;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  /// Order must match the target keys in VisionLensScreen._getIdentifyTutorialTargetRect.
  static const List<ToolbarTutorialStep> steps = [
    ToolbarTutorialStep(
      title: 'Object Labels',
      description: 'Shows the names of objects the camera sees, right on the screen.',
      icon: Icons.category_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Zoom Control',
      description: 'Zoom in up to 5x to get a closer look at colors.',
      icon: Icons.zoom_in_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Split Screen View',
      description: 'Compare views: the top names the colors, the bottom shows how colors may look with color vision deficiency.',
      icon: Icons.splitscreen_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Voice Narration',
      description: 'Tap to hear the name of the color or objects on your screen read out loud.',
      icon: Icons.volume_up_rounded,
      emphasis: 'Turn your volume up!',
      emphasisIcon: Icons.volume_up_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Upload a Photo',
      description: 'Choose a photo from your gallery to find out its colors instead of using the camera.',
      icon: Icons.collections_outlined,
    ),
    ToolbarTutorialStep(
      title: 'Switch to Remap',
      description: 'Tap Remap to go back to adjusting colors so they are easier to tell apart. The same button changes to Identify so you can return anytime.',
      icon: Icons.auto_awesome,
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
    return ToolbarTutorialOverlay(
      modeLabel: 'Identify',
      steps: steps,
      stepIndex: stepIndex,
      targetRect: targetRect,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
    );
  }
}
