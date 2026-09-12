import 'package:flutter/material.dart';
import 'package:gabeye/core/widgets/gabeye_app_bar.dart';

class ProgressBarScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ProgressBarScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GabEyeAppBar(
        showBackButton: showBackButton,
        showLogo: false,
        progressValue: currentStep / totalSteps,
        progressText: 'Step $currentStep/$totalSteps',
        onBackPressed: onBack,
      ),
      body: child,
    );
  }
}