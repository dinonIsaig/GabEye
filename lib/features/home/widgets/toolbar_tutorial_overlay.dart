import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';

/// Item model for a Vision Lens tutorial step.
class ToolbarTutorialStep {
  final String title;
  final String description;
  final IconData icon;

  /// Optional callout rendered as a highlighted banner under the description
  /// (e.g. "Turn your volume up" for voice narration).
  final String? emphasis;
  final IconData? emphasisIcon;

  const ToolbarTutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.emphasis,
    this.emphasisIcon,
  });
}

/// Shared floating tutorial overlay for the Vision Lens camera controls.
/// Uses exact [Rect] target positions (relative to the camera viewport) derived from GlobalKeys.
/// Targets on the right-side toolbar get the card to their left; targets in the bottom
/// action bar get the card above them.
class ToolbarTutorialOverlay extends StatelessWidget {
  final String modeLabel;
  final List<ToolbarTutorialStep> steps;
  final int stepIndex;
  final Rect? targetRect;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  const ToolbarTutorialOverlay({
    super.key,
    required this.modeLabel,
    required this.steps,
    required this.stepIndex,
    required this.targetRect,
    required this.onNext,
    required this.onSkip,
    required this.onComplete,
  });

  static const double _arrowSize = 36;
  static const double _edgeMargin = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size area = constraints.biggest;
        final isLastStep = stepIndex >= steps.length - 1;

        final Rect target = targetRect ??
            Rect.fromLTWH(
              area.width - 60,
              area.height / 2,
              48,
              48,
            );

        // Bottom action bar targets (Upload, mode switch) sit in the lower part of the viewport.
        final bool isBottomTarget = target.center.dy > area.height * 0.6;

        return Stack(
          children: [
            // Dimmed backdrop with a spotlight cut-out, so the highlighted control
            // (icon and label) stays at full brightness and pops out of the dimmed screen.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isLastStep ? onComplete : onNext,
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    spotlight: _spotlightFor(target),
                    scrimColor: Colors.black.withValues(alpha: 0.6),
                    outlineColor: context.semanticColors.primaryButton,
                  ),
                ),
              ),
            ),

            if (isBottomTarget)
              _buildCardAboveTarget(context, area, target, isLastStep)
            else
              _buildCardLeftOfTarget(context, area, target, isLastStep),
          ],
        );
      },
    );
  }

  /// Spotlight hole around the target: a circle for round buttons, a pill for wider ones.
  static RRect _spotlightFor(Rect target) {
    final Rect hole = target.inflate(6);
    return RRect.fromRectAndRadius(hole, Radius.circular(math.min(hole.width, hole.height) / 2));
  }

  Widget _buildCardLeftOfTarget(BuildContext context, Size area, Rect target, bool isLastStep) {
    final accent = context.semanticColors.primaryButton;
    // Grow the card on larger screens while keeping it (plus the arrow) inside the page.
    final double cardWidth = (area.width - 110).clamp(220.0, 320.0);
    final double maxRight = math.max(60.0, area.width - cardWidth - _arrowSize - 8);
    final double modalTop = (target.center.dy - 110).clamp(80.0, math.max(80.0, area.height - 320));

    return Positioned(
      right: (area.width - target.left + 8).clamp(60.0, maxRight),
      top: modalTop,
      child: Material(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCard(context, cardWidth, isLastStep),
            // Arrow Pointer pointing to the target button
            Icon(
              Icons.arrow_right_rounded,
              size: _arrowSize,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAboveTarget(BuildContext context, Size area, Rect target, bool isLastStep) {
    final accent = context.semanticColors.primaryButton;
    final double cardWidth = math.min(340.0, area.width - _edgeMargin * 2);
    final double left = (target.center.dx - cardWidth / 2)
        .clamp(_edgeMargin, math.max(_edgeMargin, area.width - cardWidth - _edgeMargin));
    // Keep the arrow under the target even when the card is pushed against a screen edge.
    final double arrowLeft = (target.center.dx - left - _arrowSize / 2).clamp(0.0, cardWidth - _arrowSize);

    return Positioned(
      left: left,
      bottom: area.height - target.top + 4,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(context, cardWidth, isLastStep),
            // Arrow Pointer pointing down to the target button
            Padding(
              padding: EdgeInsets.only(left: arrowLeft),
              child: Icon(
                Icons.arrow_drop_down_rounded,
                size: _arrowSize,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, double cardWidth, bool isLastStep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Same accent as the app's primary buttons: light blue in dark mode, navy in light mode.
    final accent = context.semanticColors.primaryButton;
    final onAccent = isDark ? AppColors.darkSurface : Colors.white;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bodyColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final step = steps[stepIndex.clamp(0, steps.length - 1)];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withValues(alpha: 0.65),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '$modeLabel Step ${stepIndex + 1} of ${steps.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                  Icon(step.icon, size: 26, color: accent),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 14,
                  color: bodyColor,
                  height: 1.4,
                ),
              ),

              // Emphasized callout
              if (step.emphasis != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(step.emphasisIcon ?? Icons.info_rounded, size: 22, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step.emphasis!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: bodyColor),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isLastStep ? onComplete : onNext,
                    icon: Icon(
                      isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      size: 18,
                      color: onAccent,
                    ),
                    label: Text(
                      isLastStep ? 'Got it!' : 'Next',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: onAccent,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the tutorial scrim everywhere except the spotlight, plus a solid outline around it.
class _SpotlightPainter extends CustomPainter {
  final RRect spotlight;
  final Color scrimColor;
  final Color outlineColor;

  const _SpotlightPainter({
    required this.spotlight,
    required this.scrimColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(spotlight);
    canvas.drawPath(scrim, Paint()..color = scrimColor);
    canvas.drawRRect(
      spotlight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = outlineColor,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.spotlight != spotlight ||
      oldDelegate.scrimColor != scrimColor ||
      oldDelegate.outlineColor != outlineColor;
}
