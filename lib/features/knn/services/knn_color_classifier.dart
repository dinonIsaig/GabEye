import 'dart:math' as math;
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';

/// KNN (K-Nearest Neighbors) color classification algorithm operating in
/// cylindrical HSV space with saturation-adaptive weighting.
class KnnColorClassifier {
  final List<IsccNbsColorEntry> dataset;
  final int k;

  static const double _degToRad = math.pi / 180.0;

  KnnColorClassifier({
    required this.dataset,
    this.k = 1,
  });

  /// Classifies a target (H, S, V) color vector into the nearest ISCC-NBS category.
  /// [targetH] in [0, 360], [targetS] in [0, 1], [targetV] in [0, 1].
  IsccNbsColorEntry classify(double targetH, double targetS, double targetV) {
    if (dataset.isEmpty) {
      return const IsccNbsColorEntry(
        id: 265,
        name: 'Medium Gray',
        r: 138,
        g: 132,
        b: 137,
        hue: 310,
        saturation: 0.04,
        value: 0.54,
        hex: '#8A8489',
      );
    }

    // Adaptive weights based on chromaticity.
    // For chromatic targets, prioritize the chromatic (H, S) plane so camera lighting/shadows
    // on V do not alter the detected color category.
    // For achromatic targets (near-zero saturation or extremely dark), prioritize V so
    // whites, grays, and blacks separate reliably without hue sensor noise.
    final bool isChromatic = targetS > 0.12 && targetV > 0.15;
    final double wC = isChromatic ? 3.0 : 1.0;
    final double wV = isChromatic ? 1.2 : 3.0;

    // Fast-path: Nearest Centroid (K=1) runs in O(N) without list allocation or sorting
    if (k <= 1) {
      IsccNbsColorEntry bestEntry = dataset.first;
      double minDistanceSq = double.infinity;

      for (final entry in dataset) {
        final distSq = _computeCylindricalDistanceSq(
          targetH, targetS, targetV,
          entry.hue, entry.saturation, entry.value,
          wC, wV,
        );

        if (distSq < minDistanceSq) {
          minDistanceSq = distSq;
          bestEntry = entry;
        }
      }

      return bestEntry;
    }

    // K > 1: Collect distances, sort, and perform distance-weighted voting
    final distances = <_DistancePair>[];
    for (final entry in dataset) {
      final distSq = _computeCylindricalDistanceSq(
        targetH, targetS, targetV,
        entry.hue, entry.saturation, entry.value,
        wC, wV,
      );
      distances.add(_DistancePair(entry: entry, distanceSq: distSq));
    }

    distances.sort((a, b) => a.distanceSq.compareTo(b.distanceSq));

    final kNeighbors = distances.take(math.min(k, distances.length));
    final voteWeights = <String, double>{};
    final entryMap = <String, IsccNbsColorEntry>{};

    for (final pair in kNeighbors) {
      final name = pair.entry.name;
      // Inverse distance weighting: closer neighbor has strictly higher influence
      final weight = 1.0 / (math.sqrt(pair.distanceSq) + 0.0001);
      voteWeights[name] = (voteWeights[name] ?? 0.0) + weight;
      entryMap[name] = pair.entry;
    }

    String topName = kNeighbors.first.entry.name;
    double maxWeight = -1.0;

    voteWeights.forEach((name, weight) {
      if (weight > maxWeight) {
        maxWeight = weight;
        topName = name;
      }
    });

    return entryMap[topName] ?? kNeighbors.first.entry;
  }

  /// Calculates squared distance in cylindrical HSV space.
  /// Chromatic plane distance squared = S1^2 + S2^2 - 2 * S1 * S2 * cos(deltaH)
  /// Value axis distance squared = (V1 - V2)^2
  static double _computeCylindricalDistanceSq(
    double h1, double s1, double v1,
    double h2, double s2, double v2,
    double wC, double wV,
  ) {
    // Angular difference wrapped to [0, 180] degrees
    double rawDiffH = (h1 - h2).abs() % 360.0;
    double dh = rawDiffH > 180.0 ? 360.0 - rawDiffH : rawDiffH;

    // Chromatic distance squared in polar/cylindrical coordinates
    // As either s1 or s2 approaches 0, the angular term naturally shrinks to 0.
    double cosDh = math.cos(dh * _degToRad);
    double chromaticDistSq = (s1 * s1) + (s2 * s2) - (2.0 * s1 * s2 * cosDh);
    if (chromaticDistSq < 0.0) chromaticDistSq = 0.0; // guard against float precision

    double dv = v1 - v2;
    double valueDistSq = dv * dv;

    return (wC * chromaticDistSq) + (wV * valueDistSq);
  }
}

class _DistancePair {
  final IsccNbsColorEntry entry;
  final double distanceSq;

  _DistancePair({required this.entry, required this.distanceSq});
}
