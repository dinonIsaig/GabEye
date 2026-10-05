import 'package:flutter/material.dart';
import 'package:gabeye/features/home/widgets/toolbar_tutorial_overlay.dart';

/// A dedicated floating tutorial overlay widget for Identify (KNN Color Identification) mode.
/// Uses exact [Rect] target positions derived from GlobalKeys for pixel-perfect placement.
class IdentifyToolbarTutorialOverlay extends StatelessWidget {
  final int stepIndex;
  final bool isSplitScreenView;
  final bool hideShutter;
  final bool isObjectLabelingOn;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  /// Every Identify step; use [stepsFor] for the ones that apply to the current view.
  static const List<ToolbarTutorialStep> allSteps = [
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.objectLabels,
      title: 'Object Labels',
      description: 'Shows the names of objects the camera sees, right on the screen.',
      icon: Icons.category_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.zoom,
      title: 'Zoom Control',
      description: 'Zoom in up to 5x to get a closer look at colors.',
      icon: Icons.zoom_in_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.splitScreen,
      title: 'Split Screen View',
      description: 'Compare views: the top names the colors, the bottom shows how colors may look with color vision deficiency.',
      icon: Icons.splitscreen_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.audio,
      title: 'Voice Narration',
      description: 'Tap to hear the name of the color or objects on your screen read out loud.',
      icon: Icons.volume_up_rounded,
      callouts: [
        ToolbarTutorialCallout('Turn your volume up!', icon: Icons.volume_up_rounded),
        ToolbarTutorialCallout('Turn off silent mode', icon: Icons.notifications_off_rounded),
      ],
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.upload,
      title: 'Upload a Photo',
      description: 'Choose a photo from your gallery to find out its colors instead of using the camera.',
      icon: Icons.collections_outlined,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.shutter,
      title: 'Camera Shutter',
      description: 'Tap to freeze the current view so you can tap around and check the colors up close. Tap it again to go back to the real-time view.',
      icon: Icons.camera_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.modeSwitch,
      title: 'Switch to Remap',
      description: 'Tap Remap to go back to adjusting colors so they are easier to tell apart. The same button changes to Identify so you can return anytime.',
      icon: Icons.auto_awesome,
    ),
  ];

  /// Only the steps whose control is on screen in the current view (see [ToolbarTutorialTarget.isVisibleIn]).
  /// [hideShutter] drops the shutter step while it is disabled (viewing a gallery upload).
  /// [isObjectLabelingOn] drops the Split Screen step, since that button is hidden while Object Labeling is on.
  static List<ToolbarTutorialStep> stepsFor({
    required bool isSplitScreenView,
    bool hideShutter = false,
    bool isObjectLabelingOn = false,
  }) =>
      allSteps
          .where((step) => step.target.isVisibleIn(isSplitScreenView: isSplitScreenView))
          .where((step) => step.target != ToolbarTutorialTarget.shutter || !hideShutter)
          .where((step) => step.target != ToolbarTutorialTarget.splitScreen || !isObjectLabelingOn)
          .toList();

  const IdentifyToolbarTutorialOverlay({
    super.key,
    required this.stepIndex,
    required this.isSplitScreenView,
    this.hideShutter = false,
    this.isObjectLabelingOn = false,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ToolbarTutorialOverlay(
      modeLabel: 'Identify',
      steps: stepsFor(
        isSplitScreenView: isSplitScreenView,
        hideShutter: hideShutter,
        isObjectLabelingOn: isObjectLabelingOn,
      ),
      stepIndex: stepIndex,
      targetRect: targetRect,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
    );
  }
}
