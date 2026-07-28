import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cap.dart';


/// Renders the CIE L*u*v* confusion plot: all 16 caps placed around a
/// circle, connected in the order the user arranged them, with reference
/// axes for the three classic confusion lines (Protan / Deutan / Tritan).
class ConfusionDiagram extends StatelessWidget {
  final List<int> arrangedCaps;

  const ConfusionDiagram({super.key, required this.arrangedCaps});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
          lineColor: colors.onSurfaceVariant,
          labelColor: colors.onSurface,
          labelShadowColor: colors.surface,
        ),
      ),
    );
  }
}

class ConfusionDiagramPainter extends CustomPainter {
  final List<int> arrangedCaps;
  final Color circleColor;
  final Color lineColor;
  final Color labelColor;
  final Color labelShadowColor;

  ConfusionDiagramPainter({
    required this.arrangedCaps,
    required this.circleColor,
    required this.lineColor,
    required this.labelColor,
    required this.labelShadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final fullList = [0, ...arrangedCaps];

    // Paint for background circle
    final circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, circlePaint);

    // Helper to draw dashed reference axes
    void drawAxis(double angleRad, Color color) {
      final axisPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final dx = math.cos(angleRad) * radius;
      final dy = math.sin(angleRad) * radius;

      // Draw dashed line using canvas lines
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

    // Draw reference axes (Protan, Deutan, Tritan) — these keep their
    // semantic colors (red/amber/blue) since they identify *which*
    // deficiency axis is which, independent of light/dark theme.
    drawAxis(12 * math.pi / 180, Colors.red.withOpacity(0.4)); // Protan
    drawAxis(-2 * math.pi / 180, Colors.amber.withOpacity(0.4)); // Deutan
    drawAxis(-80 * math.pi / 180, Colors.blue.withOpacity(0.4)); // Tritan

    // 2. Precompute coordinates for each cap in a circular layout
    final List<Offset> capCoords = [];
    final double startAngle = 135 * math.pi / 180; // Start at top left
    final double angleDelta = 22.5 * math.pi / 180; // 360 / 16

    for (int i = 0; i < 16; i++) {
      final double angle = startAngle - i * angleDelta;
      capCoords.add(Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      ));
    }

    // 3. Draw arranged connection lines
    if (fullList.length == 16) {
      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final startPos = capCoords[fullList[0]];
      path.moveTo(startPos.dx, startPos.dy);

      for (int i = 1; i < fullList.length; i++) {
        final pos = capCoords[fullList[i]];
        path.lineTo(pos.dx, pos.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // 4. Draw colored cap circles and numbers
    for (int i = 0; i < 16; i++) {
      final pos = capCoords[i];
      final color = ColorCap.getVisualColor(i);

      // Draw highlight border for Pilot cap (Cap 0)
      if (i == 0) {
        canvas.drawCircle(
          pos,
          10.0,
          Paint()..color = labelColor,
        );
      }

      // Draw cap circle
      canvas.drawCircle(
        pos,
        8.0,
        Paint()..color = color,
      );

      // Draw text label (cap index)
      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                color: labelShadowColor.withOpacity(0.8),
                blurRadius: 1.5,
                offset: const Offset(0.5, 0.5),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConfusionDiagramPainter oldDelegate) {
    return oldDelegate.arrangedCaps != arrangedCaps ||
        oldDelegate.lineColor != lineColor;
  }
}