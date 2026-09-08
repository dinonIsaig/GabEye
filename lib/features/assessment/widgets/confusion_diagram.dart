import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import '../models/cap.dart';

/// Renders the CIE L*u*v* confusion plot: all 16 caps placed around a
/// circle, connected in the order the user arranged them, with reference
/// axes for the three classic confusion lines (Protan / Deutan / Tritan).
///
/// Each connecting segment is colored by what it represents — matching
/// the same AppSemanticColors tokens used in the confusion line list
/// below the diagram, so a green line here means the same thing as a
/// green row there:
/// - neutral: caps placed correctly adjacent to each other
/// - green (AppSemanticColors.minorError): a minor swap
/// - red (AppSemanticColors.majorError): a major crossover
class ConfusionDiagram extends StatelessWidget {
  final List<int> arrangedCaps;
  final bool showLegend;

  const ConfusionDiagram({super.key, required this.arrangedCaps, this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double boxSize = math.min(availableWidth > 0 ? availableWidth : 300.0, 300.0);
        final double paintSize = math.max(boxSize - 32, 100.0);

        return Column(
          children: [
            Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                size: Size(paintSize, paintSize),
                painter: ConfusionDiagramPainter(
                  arrangedCaps: arrangedCaps,
                  circleColor: colors.onSurfaceVariant.withOpacity(0.2),
                  normalSegmentColor: colors.onSurfaceVariant.withOpacity(0.25),
                  labelColor: colors.onSurface,
                  labelShadowColor: colors.surface,
                ),
              ),
            ),
            if (showLegend) ...[
              const SizedBox(height: 12),
              _buildLegend(colors),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLegend(ColorScheme colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(colors, AppSemanticColors.minorError, 'Minor swap'),
        _legendItem(colors, AppSemanticColors.majorError, 'Major crossover'),
        _legendItem(colors, colors.onSurfaceVariant.withOpacity(0.4), 'Confusion axis'),
      ],
    );
  }

  Widget _legendItem(ColorScheme colors, Color dotColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
      ],
    );
  }
}

class ConfusionDiagramPainter extends CustomPainter {
  final List<int> arrangedCaps;
  final Color circleColor;
  final Color normalSegmentColor;
  final Color labelColor;
  final Color labelShadowColor;

  ConfusionDiagramPainter({
    required this.arrangedCaps,
    required this.circleColor,
    required this.normalSegmentColor,
    required this.labelColor,
    required this.labelShadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final fullList = [0, ...arrangedCaps];

    // Background circle
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, circlePaint);

    void drawAxis(double angleRad, Color color, {Offset shift = Offset.zero}) {
      final axisPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final dx = radius * math.cos(angleRad);
      final dy = radius * math.sin(angleRad);
      canvas.drawLine(center + shift - Offset(dx, dy), center + shift + Offset(dx, dy), axisPaint);
    }

    drawAxis(math.pi * 0.44, AppSemanticColors.salmon.withOpacity(0.35));
    drawAxis(math.pi * 0.54, AppSemanticColors.murky.withOpacity(0.35));
    drawAxis(math.pi * 0.05, AppSemanticColors.tritan.withOpacity(0.35), shift: const Offset(0, 10));

    // Outer caps + labels
    for (int i = 0; i < 16; i++) {
      final angle = (i / 16.0) * 2 * math.pi - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final capPaint = Paint()..color = ColorCap.getVisualColor(i);
      canvas.drawCircle(Offset(x, y), 8, capPaint);

      final labelRadius = radius + 11;
      final lx = center.dx + labelRadius * math.cos(angle);
      final ly = center.dy + labelRadius * math.sin(angle);

      final textSpan = TextSpan(
        text: '$i',
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: labelShadowColor, blurRadius: 2),
            Shadow(color: labelShadowColor, blurRadius: 4),
          ],
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(lx - textPainter.width / 2, ly - textPainter.height / 2));
    }

    // Arrangement line segments
    for (int i = 0; i < fullList.length - 1; i++) {
      final capA = fullList[i];
      final capB = fullList[i + 1];

      final angleA = (capA / 16.0) * 2 * math.pi - math.pi / 2;
      final angleB = (capB / 16.0) * 2 * math.pi - math.pi / 2;

      final pA = Offset(center.dx + radius * math.cos(angleA), center.dy + radius * math.sin(angleA));
      final pB = Offset(center.dx + radius * math.cos(angleB), center.dy + radius * math.sin(angleB));

      final step = (capA - capB).abs();
      Color segmentColor;
      double strokeWidth;

      if (step == 1 || step == 15) {
        segmentColor = normalSegmentColor;
        strokeWidth = 1.5;
      } else if (step == 2 || step == 14) {
        segmentColor = AppSemanticColors.minorError;
        strokeWidth = 2.0;
      } else {
        segmentColor = AppSemanticColors.majorError;
        strokeWidth = 2.5;
      }

      final linePaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(pA, pB, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfusionDiagramPainter oldDelegate) {
    return oldDelegate.arrangedCaps != arrangedCaps ||
        oldDelegate.circleColor != circleColor ||
        oldDelegate.normalSegmentColor != normalSegmentColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.labelShadowColor != labelShadowColor;
  }
}