import 'package:flutter/material.dart';
import 'package:gabeye/features/home/widgets/assistance_mode_modal.dart';
import 'package:gabeye/features/home/widgets/toolbar_tutorial_overlay.dart';

/// Tutorial overlay for a photo uploaded from the gallery, with one set of steps per
/// processing option (Remap Color, Identify Color, Object Labeling). Only controls that are
/// on screen for an upload are highlighted; the shutter is disabled there so it is left out.
class UploadToolbarTutorialOverlay extends StatelessWidget {
  final AssistanceMode mode;
  final bool showDownload;
  final int stepIndex;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  static const ToolbarTutorialStep _uploadAnother = ToolbarTutorialStep(
    target: ToolbarTutorialTarget.upload,
    title: 'Upload Another Photo',
    description: 'Choose another photo from your gallery and pick how to process it.',
    icon: Icons.collections_outlined,
  );

  static const ToolbarTutorialStep _liveCamera = ToolbarTutorialStep(
    target: ToolbarTutorialTarget.modeSwitch,
    title: 'Real-Time',
    description: 'Close this photo and go back to the real-time camera.',
    icon: Icons.videocam,
  );

  static const List<ToolbarTutorialStep> remapSteps = [
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.download,
      title: 'Download Photo',
      description: 'Save this photo with the adjusted colors to your gallery.',
      icon: Icons.download_rounded,
    ),
    _uploadAnother,
    _liveCamera,
  ];

  static const List<ToolbarTutorialStep> identifySteps = [
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.photoCrosshair,
      title: 'Check a Color',
      description: 'Tap or drag anywhere on the photo to move the crosshair and see the name of that color.',
      icon: Icons.touch_app_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.audio,
      title: 'Voice Narration',
      description: 'Tap to hear the name of the color under the crosshair read out loud.',
      icon: Icons.volume_up_rounded,
      callouts: [
        ToolbarTutorialCallout('Turn your volume up!', icon: Icons.volume_up_rounded),
        ToolbarTutorialCallout('Turn off silent mode', icon: Icons.notifications_off_rounded),
        ToolbarTutorialCallout('Adjust personalized narration speed', svgAsset: 'assets/icons/turtle.svg'),
      ],
    ),
    _uploadAnother,
    _liveCamera,
  ];

  static const List<ToolbarTutorialStep> objectLabelingSteps = [
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.objectsSheet,
      title: 'Detected Objects',
      description: 'Tap here to show or hide the list of objects found in your photo.',
      icon: Icons.category_rounded,
    ),
    ToolbarTutorialStep(
      target: ToolbarTutorialTarget.audio,
      title: 'Voice Narration',
      description: 'Tap to hear the names of the detected objects read out loud.',
      icon: Icons.volume_up_rounded,
      callouts: [
        ToolbarTutorialCallout('Turn your volume up!', icon: Icons.volume_up_rounded),
        ToolbarTutorialCallout('Turn off silent mode', icon: Icons.notifications_off_rounded),
        ToolbarTutorialCallout('Adjust personalized narration speed', svgAsset: 'assets/icons/turtle.svg'),
      ],
    ),
    _uploadAnother,
    _liveCamera,
  ];

  /// Steps for [mode]; [showDownload] is false once a remapped photo is saved (no download button).
  static List<ToolbarTutorialStep> stepsFor(AssistanceMode mode, {bool showDownload = false}) => switch (mode) {
        AssistanceMode.remapColor =>
          remapSteps.where((step) => step.target != ToolbarTutorialTarget.download || showDownload).toList(),
        AssistanceMode.identifyColor => identifySteps,
        AssistanceMode.objectLabeling => objectLabelingSteps,
      };

  /// Label shown in the step badge ("<label> Step 1 of 3").
  static String labelFor(AssistanceMode mode) => switch (mode) {
        AssistanceMode.remapColor => 'Remap Photo',
        AssistanceMode.identifyColor => 'Identify Photo',
        AssistanceMode.objectLabeling => 'Object Labeling',
      };

  const UploadToolbarTutorialOverlay({
    super.key,
    required this.mode,
    this.showDownload = false,
    required this.stepIndex,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ToolbarTutorialOverlay(
      modeLabel: labelFor(mode),
      steps: stepsFor(mode, showDownload: showDownload),
      stepIndex: stepIndex,
      targetRect: targetRect,
      onNext: onNext,
      onSkip: onSkip,
      onComplete: onComplete,
    );
  }
}
