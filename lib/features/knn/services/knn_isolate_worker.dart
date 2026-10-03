import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import 'package:gabeye/features/knn/services/knn_color_classifier.dart';

/// Request message payload passed to background Dart Isolate
class KnnIsolateRequest {
  final Uint8List pixelBuffer; // YUV420 or RGBA ROI byte buffer
  final int width;
  final int height;
  final List<Map<String, dynamic>> rawDatasetJson;

  KnnIsolateRequest({
    required this.pixelBuffer,
    required this.width,
    required this.height,
    required this.rawDatasetJson,
  });
}

/// Response payload returned from background Dart Isolate
class KnnIsolateResult {
  final String colorName;
  final String hexColor;
  final double averageH;
  final double averageS;
  final double averageV;

  KnnIsolateResult({
    required this.colorName,
    required this.hexColor,
    required this.averageH,
    required this.averageS,
    required this.averageV,
  });
}

/// Off-thread background processing service for KNN pixel classification.
class KnnIsolateWorker {
  /// Computes average HSV for a region of interest in a background isolate.
  static Future<KnnIsolateResult> processRoiInIsolate(KnnIsolateRequest request) async {
    return Isolate.run(() => _executeIsolateClassification(request));
  }

  static KnnIsolateResult _executeIsolateClassification(KnnIsolateRequest req) {
    final bytes = req.pixelBuffer;
    final len = bytes.length;

    double sumSinH = 0.0;
    double sumCosH = 0.0;
    double sumS = 0.0;
    double sumV = 0.0;
    int pixelCount = 0;

    double maxS = -1.0;
    double maxSHue = 0.0;
    double maxSSat = 0.0;

    for (int i = 0; i + 2 < len; i += 3) {
      final int r = bytes[i];
      final int g = bytes[i + 1];
      final int b = bytes[i + 2];

      final hsv = _rgbToHsv(r.toDouble(), g.toDouble(), b.toDouble());
      final double h = hsv[0];
      final double s = hsv[1];
      final double v = hsv[2];

      final double rad = h * (math.pi / 180.0);
      sumSinH += math.sin(rad);
      sumCosH += math.cos(rad);
      sumS += s;
      sumV += v;
      pixelCount++;

      if (s > maxS) {
        maxS = s;
        maxSHue = h;
        maxSSat = s;
      }
    }

    final double avgS = pixelCount > 0 ? (sumS / pixelCount) : 0.0;
    final double avgV = pixelCount > 0 ? (sumV / pixelCount) : 0.0;

    double avgH = 0.0;
    if (pixelCount > 0 && (sumSinH.abs() > 0.0001 || sumCosH.abs() > 0.0001)) {
      avgH = math.atan2(sumSinH, sumCosH) * (180.0 / math.pi);
      if (avgH < 0.0) avgH += 360.0;
    }

    // If the region has prominent color saturation (> 0.08), favor the peak chromatic pixel/hue
    final double finalH = avgS > 0.08 ? (maxS > 0.15 ? maxSHue : avgH) : avgH;
    final double finalS = avgS > 0.08 ? math.max(avgS, maxSSat) : avgS;
    final double finalV = avgV; // Real luminance value (preserves true dark/black V ~ 0.0)

    // Reconstruct dataset entries in isolate
    final dataset = req.rawDatasetJson
        .map((j) => IsccNbsColorEntry.fromJson(j))
        .toList();

    final classifier = KnnColorClassifier(dataset: dataset, k: 1);
    final matched = classifier.classify(finalH, finalS, finalV);

    return KnnIsolateResult(
      colorName: matched.name,
      hexColor: matched.hex,
      averageH: finalH,
      averageS: finalS,
      averageV: finalV,
    );
  }

  static List<double> _rgbToHsv(double r, double g, double b) {
    double rNorm = r / 255.0;
    double gNorm = g / 255.0;
    double bNorm = b / 255.0;

    double maxC = [rNorm, gNorm, bNorm].reduce((curr, next) => curr > next ? curr : next);
    double minC = [rNorm, gNorm, bNorm].reduce((curr, next) => curr < next ? curr : next);
    double delta = maxC - minC;

    double h = 0.0;
    double s = maxC == 0.0 ? 0.0 : delta / maxC;
    double v = maxC;

    if (delta != 0.0) {
      if (maxC == rNorm) {
        h = 60.0 * (((gNorm - bNorm) / delta) % 6);
      } else if (maxC == gNorm) {
        h = 60.0 * (((bNorm - rNorm) / delta) + 2.0);
      } else {
        h = 60.0 * (((rNorm - gNorm) / delta) + 4.0);
      }
    }

    if (h < 0.0) h += 360.0;

    return [h, s, v];
  }
}
