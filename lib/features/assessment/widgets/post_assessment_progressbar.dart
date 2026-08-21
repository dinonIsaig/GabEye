import 'package:flutter/material.dart';
import 'package:gabeye/core/widgets/gabeye_app_bar.dart';

class ProgressBarScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Widget child;

  const ProgressBarScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GabEyeAppBar(
        showBackButton: false,
        showLogo: false,
        progressValue: currentStep / totalSteps,
        progressText: 'Step $currentStep/$totalSteps',
      ),
      body: child,
    );
  }
}