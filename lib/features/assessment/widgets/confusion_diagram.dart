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

    return Column(
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.all(16),
          child: CustomPaint(
            size: const Size(268, 268),
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
  }

  Widget _buildLegend(ColorScheme colors) {
    return Wrap(
      spacing: 16,
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
        Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
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

    // Dashed reference axes
    void drawAxis(double angleRad, Color color) {
      final axisPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final dx = math.cos(angleRad) * radius;
      final dy = math.sin(angleRad) * radius;
      const int dashCount = 15;
      final start = center - Offset(dx, dy);
      final end = center + Offset(dx, dy);

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

    drawAxis(12 * math.pi / 180, Colors.red.withOpacity(0.3)); // Protan
    drawAxis(-2 * math.pi / 180, Colors.amber.withOpacity(0.3)); // Deutan
    drawAxis(-80 * math.pi / 180, Colors.blue.withOpacity(0.3)); // Tritan

    // Precompute coordinates for each cap in a circular layout
    final List<Offset> capCoords = [];
    final double startAngle = 135 * math.pi / 180;
    final double angleDelta = 22.5 * math.pi / 180; // 360 / 16

    for (int i = 0; i < 16; i++) {
      final double angle = startAngle - i * angleDelta;
      capCoords.add(Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ));
    }

    if (fullList.length == 16) {
      for (int i = 0; i < fullList.length - 1; i++) {
        final int capA = fullList[i];
        final int capB = fullList[i + 1];
        final int diffDistance = (capA - capB).abs();

        final Color segmentColor;
        if (diffDistance <= 1) {
          segmentColor = normalSegmentColor;
        } else if (diffDistance >= 4) {
          segmentColor = AppSemanticColors.majorError;
        } else {
          segmentColor = AppSemanticColors.minorError;
        }

        final linePaint = Paint()
          ..color = segmentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(capCoords[capA], capCoords[capB], linePaint);
      }
    }

    // Draw colored cap circles and numbers
    for (int i = 0; i < 16; i++) {
      final pos = capCoords[i];
      final color = ColorCap.getVisualColor(i);

      if (i == 0) {
        canvas.drawCircle(pos, 10.0, Paint()..color = labelColor);
      }

      canvas.drawCircle(pos, 8.0, Paint()..color = color);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(color: labelShadowColor.withOpacity(0.8), blurRadius: 1.5, offset: const Offset(0.5, 0.5)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant ConfusionDiagramPainter oldDelegate) {
    return oldDelegate.arrangedCaps != arrangedCaps;
  }
}