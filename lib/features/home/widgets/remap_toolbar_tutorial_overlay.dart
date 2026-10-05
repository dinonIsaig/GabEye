import 'package:flutter/material.dart';
import 'package:gabeye/features/home/widgets/toolbar_tutorial_overlay.dart';

/// A dedicated floating tutorial overlay widget for Remapping (Daltonization) mode.
/// Uses exact [Rect] target positions derived from GlobalKeys for pixel-perfect placement.
class RemapToolbarTutorialOverlay extends StatelessWidget {
  final int stepIndex;
  final bool isSplitScreenView;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  /// Every Remap step; use [stepsFor] for the ones that apply to the current view.
  static const List<ToolbarTutorialStep> allSteps = [
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.zoom,
      title: 'Zoom Control',
      description: 'Zoom in up to 5x to get a closer look at colors.',
      icon: Icons.zoom_in_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.torch,
      title: 'Flashlight',
      description: 'Turn on your flashlight in dark places so colors show up more accurately.',
      icon: Icons.flash_on_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.cvdPerception,
      title: 'CVD Perception View',
      description: 'Switch the comparison to see colors the way you see them: the top simulates your color vision, the bottom shows how the adjusted colors look to you.',
      icon: Icons.visibility_outlined,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.splitScreen,
      title: 'Split Screen View',
      description: 'Compare views: the top shows the original colors, the bottom shows the adjusted colors.',
      icon: Icons.splitscreen_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.upload,
      title: 'Upload a Photo',
      description: 'Choose a photo from your gallery to adjust its colors instead of using the camera.',
      icon: Icons.collections_outlined,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.shutter,
      title: 'Camera Shutter',
      description: 'Tap to take a photo with the adjusted colors and save it to your gallery.',
      icon: Icons.camera_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.modeSwitch,
      title: 'Switch to Identify',
      description: 'Tap Identify to find out the names of colors. The same button changes to Remap so you can switch back anytime.',
      icon: Icons.palette_outlined,
    ),
  ];

  /// Only the steps whose control is on screen in the current view (see [ToolbarTutorialTarget.isVisibleIn]).
  static List<ToolbarTutorialStep> stepsFor({required bool isSplitScreenView}) =>
      allSteps.where((step) => step.target.isVisibleIn(isSplitScreenView: isSplitScreenView)).toList();

  const RemapToolbarTutorialOverlay({
    super.key,
    required this.stepIndex,
    required this.isSplitScreenView,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ToolbarTutorialOverlay(
      modeLabel: 'Remap',
      steps: stepsFor(isSplitScreenView: isSplitScreenView),
      stepIndex: stepIndex,
      targetRect: targetRect,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
    );
  }
}
