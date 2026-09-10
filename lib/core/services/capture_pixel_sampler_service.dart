import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import 'package:gabeye/features/knn/services/knn_color_classifier.dart';
import 'package:gabeye/features/knn/services/knn_isolate_worker.dart';

/// Samples a single pixel from a decoded [ui.Image] and runs synchronous KNN
/// colour classification on the main isolate.
///
/// Because we are reading exactly **one pixel** the operation is O(1) and
/// does not block the UI thread in any measurable way. There is intentionally
/// no isolate spawn here — the overhead of spawning an isolate
/// (>3 ms) would exceed the cost of the classification itself.
class CapturePixelSamplerService {
  CapturePixelSamplerService._();

  /// Reads the RGBA value at image-space pixel ([pixelX], [pixelY]),
  /// converts it to HSV, and classifies it with [KnnColorClassifier].
  ///
  /// - [image]   — the decoded [ui.Image] captured from the still frame.
  /// - [pixelX]  — horizontal pixel coordinate in image space (0 … image.width-1).
  /// - [pixelY]  — vertical pixel coordinate in image space (0 … image.height-1).
  /// - [dataset] — pre-loaded ISCC-NBS colour entries.
  ///
  /// Returns a [KnnIsolateResult] on success, or a neutral gray result if the
  /// image cannot be read (e.g. out-of-bounds coordinates).
  static Future<KnnIsolateResult> samplePixelAt({
    required ui.Image image,
    required int pixelX,
    required int pixelY,
    required List<IsccNbsColorEntry> dataset,
  }) async {
    // Clamp coordinates to valid image bounds.
    final int safeX = pixelX.clamp(0, image.width - 1);
    final int safeY = pixelY.clamp(0, image.height - 1);

    // Render the entire image into raw RGBA bytes, then index into the
    // specific pixel. toByteData gives 4 bytes per pixel (RGBA).
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (byteData == null) {
      return _neutralGray();
    }

    // Calculate byte offset: each pixel is 4 bytes (RGBA).
    // Row stride = image.width * 4 bytes.
    final int byteOffset = (safeY * image.width + safeX) * 4;

    if (byteOffset + 3 >= byteData.lengthInBytes) {
      return _neutralGray();
    }

    // Extract RGBA channels (values 0–255).
    final int r = byteData.getUint8(byteOffset);
    final int g = byteData.getUint8(byteOffset + 1);
    final int b = byteData.getUint8(byteOffset + 2);
    // Alpha channel (byteOffset + 3) is intentionally ignored for colour ID.

    // Convert RGB → HSV for the KNN classifier.
    final List<double> hsv = _rgbToHsv(r, g, b);
    final double h = hsv[0]; // [0, 360]
    final double s = hsv[1]; // [0, 1]
    final double v = hsv[2]; // [0, 1]

    // Run synchronous KNN classification (no isolate needed for single pixel).
    final classifier = KnnColorClassifier(dataset: dataset, k: 3);
    final matched = classifier.classify(h, s, v);

    return KnnIsolateResult(
      colorName: matched.name,
      hexColor: matched.hex,
      averageH: h,
      averageS: s,
      averageV: v,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts 8-bit RGB channels to HSV [hue°, saturation, value].
  ///
  /// - Hue is in [0, 360].
  /// - Saturation and Value are in [0, 1].
  static List<double> _rgbToHsv(int r, int g, int b) {
    final double rN = r / 255.0;
    final double gN = g / 255.0;
    final double bN = b / 255.0;

    final double maxC = [rN, gN, bN].reduce((a, x) => a > x ? a : x);
    final double minC = [rN, gN, bN].reduce((a, x) => a < x ? a : x);
    final double delta = maxC - minC;

    double h = 0.0;
    final double s = maxC == 0.0 ? 0.0 : delta / maxC;
    final double v = maxC;

    if (delta != 0.0) {
      if (maxC == rN) {
        h = 60.0 * (((gN - bN) / delta) % 6);
      } else if (maxC == gN) {
        h = 60.0 * (((bN - rN) / delta) + 2);
      } else {
        h = 60.0 * (((rN - gN) / delta) + 4);
      }
    }

    if (h < 0) h += 360.0;
    return [h, s, v];
  }

  /// Returns a neutral gray [KnnIsolateResult] used as a safe fallback when
  /// pixel sampling fails (e.g. null byte data or out-of-bounds access).
  static KnnIsolateResult _neutralGray() {
    return KnnIsolateResult(
      colorName: 'Medium Gray',
      hexColor: '#808080',
      averageH: 0.0,
      averageS: 0.0,
      averageV: 0.5,
    );
  }
}
