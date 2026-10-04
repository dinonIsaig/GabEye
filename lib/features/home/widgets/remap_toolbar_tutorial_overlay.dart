import 'package:flutter/material.dart';
import 'package:gabeye/features/home/widgets/toolbar_tutorial_overlay.dart';

/// A dedicated floating tutorial overlay widget for Remapping (Daltonization) mode.
/// Uses exact [Rect] target positions derived from GlobalKeys for pixel-perfect placement.
class RemapToolbarTutorialOverlay extends StatelessWidget {
  final int stepIndex;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  /// Order must match the target keys in VisionLensScreen._getRemapTutorialTargetRect.
  static const List<ToolbarTutorialStep> steps = [
    ToolbarTutorialStep(
      title: 'Zoom Control',
      description: 'Zoom in up to 5x to get a closer look at colors.',
      icon: Icons.zoom_in_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Flashlight',
      description: 'Turn on your flashlight in dark places so colors show up more accurately.',
      icon: Icons.flash_on_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Split Screen View',
      description: 'Compare views: the top shows the original colors, the bottom shows the adjusted colors.',
      icon: Icons.splitscreen_rounded,
    ),
    ToolbarTutorialStep(
      title: 'Upload a Photo',
      description: 'Choose a photo from your gallery to adjust its colors instead of using the camera.',
      icon: Icons.collections_outlined,
    ),
    ToolbarTutorialStep(
      title: 'Switch to Identify',
      description: 'Tap Identify to find out the names of colors. The same button changes to Remap so you can switch back anytime.',
      icon: Icons.palette_outlined,
    ),
  ];

  const RemapToolbarTutorialOverlay({
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
      modeLabel: 'Remap',
      steps: steps,
      stepIndex: stepIndex,
      targetRect: targetRect,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
    );
  }
}
