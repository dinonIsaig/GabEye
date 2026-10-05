import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/features/home/widgets/object_detection_overlay.dart';

void main() {
  group('scaleBoundingBox Static Image Scaling Tests', () {
    test('scales portrait image into portrait screen with letterboxing offsets', () {
      // 1000 x 2000 image inside 400 x 1000 canvas
      // scaleX = 400 / 1000 = 0.4
      // scaleY = 1000 / 2000 = 0.5
      // scale = min(0.4, 0.5) = 0.4
      // displayedWidth = 400, displayedHeight = 800
      // offsetX = (400 - 400) / 2 = 0.0
      // offsetY = (1000 - 800) / 2 = 100.0
      const imageSize = Size(1000, 2000);
      const canvasSize = Size(400, 1000);
      const rawBox = Rect.fromLTRB(100, 200, 900, 1800);

      final scaled = scaleBoundingBox(
        rawBox: rawBox,
        imageSize: imageSize,
        canvasSize: canvasSize,
        fit: BoxFit.contain,
        isStaticImage: true,
      );

      // Expected:
      // left = 100 * 0.4 + 0 = 40.0
      // top = 200 * 0.4 + 100 = 180.0
      // right = 900 * 0.4 + 0 = 360.0
      // bottom = 1800 * 0.4 + 100 = 820.0
      expect(scaled.left, closeTo(40.0, 0.01));
      expect(scaled.top, closeTo(180.0, 0.01));
      expect(scaled.right, closeTo(360.0, 0.01));
      expect(scaled.bottom, closeTo(820.0, 0.01));
    });

    test('scales landscape image into portrait screen with pillar/letterboxing', () {
      // 2000 x 1000 image inside 400 x 1000 canvas
      // scaleX = 400 / 2000 = 0.2
      // scaleY = 1000 / 1000 = 1.0
      // scale = min(0.2, 1.0) = 0.2
      // displayedWidth = 400, displayedHeight = 200
      // offsetX = 0.0
      // offsetY = (1000 - 200) / 2 = 400.0
      const imageSize = Size(2000, 1000);
      const canvasSize = Size(400, 1000);
      const rawBox = Rect.fromLTWH(500, 200, 1000, 600); // right = 1500, bottom = 800

      final scaled = scaleBoundingBox(
        rawBox: rawBox,
        imageSize: imageSize,
        canvasSize: canvasSize,
        fit: BoxFit.contain,
        isStaticImage: true,
      );

      // Expected:
      // left = 500 * 0.2 + 0 = 100.0
      // top = 200 * 0.2 + 400 = 440.0
      // right = 1500 * 0.2 + 0 = 300.0
      // bottom = 800 * 0.2 + 400 = 560.0
      expect(scaled.left, closeTo(100.0, 0.01));
      expect(scaled.top, closeTo(440.0, 0.01));
      expect(scaled.right, closeTo(300.0, 0.01));
      expect(scaled.bottom, closeTo(560.0, 0.01));
    });

    test('scales square image into wide screen with pillarboxing on X', () {
      // 1000 x 1000 image inside 800 x 400 canvas
      // scaleX = 800 / 1000 = 0.8
      // scaleY = 400 / 1000 = 0.4
      // scale = min(0.8, 0.4) = 0.4
      // displayedWidth = 400, displayedHeight = 400
      // offsetX = (800 - 400) / 2 = 200.0
      // offsetY = 0.0
      const imageSize = Size(1000, 1000);
      const canvasSize = Size(800, 400);
      const rawBox = Rect.fromLTWH(100, 100, 800, 800); // right = 900, bottom = 900

      final scaled = scaleBoundingBox(
        rawBox: rawBox,
        imageSize: imageSize,
        canvasSize: canvasSize,
        fit: BoxFit.contain,
        isStaticImage: true,
      );

      // Expected:
      // left = 100 * 0.4 + 200 = 240.0
      // top = 100 * 0.4 + 0 = 40.0
      // right = 900 * 0.4 + 200 = 560.0
      // bottom = 900 * 0.4 + 0 = 360.0
      expect(scaled.left, closeTo(240.0, 0.01));
      expect(scaled.top, closeTo(40.0, 0.01));
      expect(scaled.right, closeTo(560.0, 0.01));
      expect(scaled.bottom, closeTo(360.0, 0.01));
    });

    test('converts normalized [0..1] coordinates correctly to screen dimensions', () {
      // 1000 x 1000 image inside 500 x 500 canvas
      // scale = 0.5, offsets = 0, 0
      const imageSize = Size(1000, 1000);
      const canvasSize = Size(500, 500);
      const rawBox = Rect.fromLTWH(0.2, 0.3, 0.5, 0.4); // normalized coords

      final scaled = scaleBoundingBox(
        rawBox: rawBox,
        imageSize: imageSize,
        canvasSize: canvasSize,
        fit: BoxFit.contain,
        isStaticImage: true,
      );

      // In image pixels: left = 200, top = 300, right = 700, bottom = 700
      // On screen: left = 100.0, top = 150.0, right = 350.0, bottom = 350.0
      expect(scaled.left, closeTo(100.0, 0.01));
      expect(scaled.top, closeTo(150.0, 0.01));
      expect(scaled.right, closeTo(350.0, 0.01));
      expect(scaled.bottom, closeTo(350.0, 0.01));
    });

    test('EXIF 6 (90 deg CW portrait) maps landscape sensor box accurately to upright space', () {
      // Photo upright: w = 3000, h = 4000
      // Sensor raw buffer: width = 4000, height = 3000
      // Object in upright image is at bottom-left:
      // upright: left = 600, top = 2000, width = 900, height = 1200 (right = 1500, bottom = 3200)
      // Sensor mapping for EXIF 6:
      // Sensor X = upright Y => [2000 .. 3200] (box.left = 2000, box.width = 1200)
      // Sensor Y = w - upright X => [3000 - 1500 .. 3000 - 600] = [1500 .. 2400] (box.top = 1500, box.bottom = 2400)
      const double w = 3000;
      const double h = 4000;
      const sensorBox = Rect.fromLTWH(2000, 1500, 1200, 900); // left=2000, top=1500, right=3200, bottom=2400

      // Applying EXIF 6 transformation:
      final double rLeft = (w - sensorBox.bottom).clamp(0.0, w); // 3000 - 2400 = 600
      final double rTop = sensorBox.left.clamp(0.0, h);           // 2000
      final double rWidth = sensorBox.height.clamp(0.0, w - rLeft); // 900
      final double rHeight = sensorBox.width.clamp(0.0, h - rTop);  // 1200
      final uprightBox = Rect.fromLTWH(rLeft, rTop, rWidth, rHeight);

      expect(uprightBox.left, closeTo(600.0, 0.01));
      expect(uprightBox.top, closeTo(2000.0, 0.01));
      expect(uprightBox.width, closeTo(900.0, 0.01));
      expect(uprightBox.height, closeTo(1200.0, 0.01));

      // Now scale onto a 300 x 400 canvas (scale = 0.1, offsets = 0, 0)
      final scaled = scaleBoundingBox(
        rawBox: uprightBox,
        imageSize: const Size(w, h),
        canvasSize: const Size(300, 400),
        fit: BoxFit.contain,
        isStaticImage: true,
      );

      expect(scaled.left, closeTo(60.0, 0.01));
      expect(scaled.top, closeTo(200.0, 0.01));
      expect(scaled.width, closeTo(90.0, 0.01));
      expect(scaled.height, closeTo(120.0, 0.01));
    });
  });
}
