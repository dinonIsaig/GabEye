import 'dart:isolate';
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
    double totalR = 0;
    double totalG = 0;
    double totalB = 0;
    int sampleCount = 0;

    final bytes = req.pixelBuffer;
    final len = bytes.length;

    for (int i = 0; i + 2 < len; i += 3) {
      totalR += bytes[i];
      totalG += bytes[i + 1];
      totalB += bytes[i + 2];
      sampleCount++;
    }

    if (sampleCount == 0) sampleCount = 1;

    double avgR = (totalR / sampleCount).clamp(0.0, 255.0);
    double avgG = (totalG / sampleCount).clamp(0.0, 255.0);
    double avgB = (totalB / sampleCount).clamp(0.0, 255.0);

    // RGB to HSV conversion
    final hsv = _rgbToHsv(avgR, avgG, avgB);
    final double h = hsv[0];
    final double s = hsv[1];
    final double v = hsv[2];

    // Reconstruct dataset entries in isolate
    final dataset = req.rawDatasetJson
        .map((j) => IsccNbsColorEntry.fromJson(j))
        .toList();

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
        h = 60.0 * (((bNorm - rNorm) / delta) + 2);
      } else {
        h = 60.0 * (((rNorm - gNorm) / delta) + 4);
      }
    }

    if (h < 0) h += 360.0;

    return [h, s, v];
  }
}
