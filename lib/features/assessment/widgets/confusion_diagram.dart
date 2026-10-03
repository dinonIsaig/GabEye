import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_semantic_colors.dart';
import 'package:gabeye/core/theme/gabeye_semantic_colors.dart';
import '../models/cap.dart';

/// Renders the CIE L*u*v* confusion plot: all 16 caps placed around a
/// circle, connected in the order the user arranged them, with reference
/// axes for the three classic confusion lines (Protan / Deutan / Tritan).
///
/// Each connecting segment is colored by what it represents — matching
/// the same semantic colors used in the confusion line list below the
/// diagram, so a green line here means the same thing as a green row
/// there:
/// - neutral: caps placed correctly adjacent to each other
/// - green (context.semanticColors.success): a minor swap
/// - red (context.semanticColors.error): a major crossover
class ConfusionDiagram extends StatelessWidget {
  final List<int> arrangedCaps;
  final bool showLegend;

  const ConfusionDiagram({super.key, required this.arrangedCaps, this.showLegend = true});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

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
                  minorErrorColor: semantic.success.withOpacity(0.4),
                  majorErrorColor: semantic.error,
                ),
              ),
            ),
            if (showLegend) ...[
              const SizedBox(height: 12),
              _buildLegend(colors, semantic),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLegend(ColorScheme colors, GabEyeSemanticColors semantic) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(colors, semantic.success.withOpacity(0.4), 'Minor swap'),
        _legendItem(colors, semantic.error, 'Major crossover'),
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
  final Color minorErrorColor;
  final Color majorErrorColor;

  ConfusionDiagramPainter({
    required this.arrangedCaps,
    required this.circleColor,
    required this.normalSegmentColor,
    required this.labelColor,
    required this.labelShadowColor,
    required this.minorErrorColor,
    required this.majorErrorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final fullList = [0, ...arrangedCaps];
    final double cap0Angle = math.pi;

    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, circlePaint);

    final double originalCode2Start = 135 * math.pi / 180;
    final double rotationOffset = cap0Angle - originalCode2Start;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationOffset);
    canvas.translate(-center.dx, -center.dy);

    void drawAxis(double angleRad, Color color, {Offset shift = Offset.zero}) {
      final axisPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final dx = math.cos(angleRad) * radius;
      final dy = math.sin(angleRad) * radius;
      const int dashCount = 15;
      final axisCenter = center + shift;
      final start = axisCenter - Offset(dx, dy);
      final end = axisCenter + Offset(dx, dy);

      for (int i = 0; i < dashCount; i++) {
        if (i % 2 == 0) {
          final tStart = i / dashCount;
          final tEnd = (i + 1) / dashCount;
          final pStart = Offset(
            start.dx + (end.dx - start.dx) * tStart,
            start.dy + (end.dy - start.dy) * tStart,
          );
          final pEnd = Offset(
            start.dx + (end.dx - start.dx) * tEnd,
            start.dy + (end.dy - start.dy) * tEnd,
          );
          canvas.drawLine(pStart, pEnd, axisPaint);
        }
      }
    }

    drawAxis(-124 * math.pi / 180, AppSemanticColors.murky.withOpacity(0.35), shift: const Offset(-40, 25)); // Deutan
    drawAxis(-146 * math.pi / 180, AppSemanticColors.salmon.withOpacity(0.35), shift: const Offset(-23, 30)); // Protan
    drawAxis(-62 * math.pi / 180, AppSemanticColors.tritan.withOpacity(0.35), shift: const Offset(13, 0)); // Tritan
    
    canvas.restore(); 

    for (int i = 0; i < 16; i++) {
      final angle = cap0Angle + (i / 16.0) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      final pos = Offset(x, y);

      if (i == 0) {
        canvas.drawCircle(pos, 10.0, Paint()..color = labelColor);
      }

      final capPaint = Paint()..color = ColorCap.getVisualColor(i);
      canvas.drawCircle(pos, 8, capPaint);

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

    for (int i = 0; i < fullList.length - 1; i++) {
      final capA = fullList[i];
      final capB = fullList[i + 1];

      final angleA = cap0Angle + (capA / 16.0) * 2 * math.pi;
      final angleB = cap0Angle + (capB / 16.0) * 2 * math.pi;

      final pA = Offset(center.dx + radius * math.cos(angleA), center.dy + radius * math.sin(angleA));
      final pB = Offset(center.dx + radius * math.cos(angleB), center.dy + radius * math.sin(angleB));

      final step = (capA - capB).abs();
      Color segmentColor;
      double strokeWidth;

      if (step == 1 || step == 15) {
        segmentColor = normalSegmentColor;
        strokeWidth = 1.5;
      } else if (step == 2 || step == 14) {
        segmentColor = minorErrorColor;
        strokeWidth = 2.0;
      } else {
        segmentColor = majorErrorColor;
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
        oldDelegate.labelShadowColor != labelShadowColor ||
        oldDelegate.minorErrorColor != minorErrorColor ||
        oldDelegate.majorErrorColor != majorErrorColor;
  }
}