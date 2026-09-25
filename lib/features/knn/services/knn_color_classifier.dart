import 'dart:math' as math;
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';

/// KNN (K-Nearest Neighbors) color classification algorithm operating in 3D HSV space.
class KnnColorClassifier {
  final List<IsccNbsColorEntry> dataset;
  final int k;

  // HSV distance weighting constants (Hue, Saturation, Value)
  static const double weightH = 1.0;
  static const double weightS = 1.5;
  static const double weightV = 1.2;

  KnnColorClassifier({
    required this.dataset,
    this.k = 3,
  });

  /// Classifies a target (H, S, V) color vector into the nearest ISCC-NBS category.
  /// [targetH] in [0, 360], [targetS] in [0, 1], [targetV] in [0, 1].
  IsccNbsColorEntry classify(double targetH, double targetS, double targetV) {
    if (dataset.isEmpty) {
      return const IsccNbsColorEntry(
        id: 136,
        name: 'Medium Gray',
        hue: 0,
        saturation: 0,
        value: 0.5,
        hex: '#808080',
      );
    }

    final bool isChromatic = targetS > 0.12 && targetV > 0.15;
    final double wH = isChromatic ? 4.0 : 0.5;
    final double wS = isChromatic ? 1.5 : 2.5;
    final double wV = isChromatic ? 1.0 : 2.5;

    final distances = <_DistancePair>[];

    for (final entry in dataset) {
      // Circular hue difference (wrapping around 360 degrees)
      double rawDiffH = (targetH - entry.hue).abs() % 360.0;
      double dh = rawDiffH > 180.0 ? 360.0 - rawDiffH : rawDiffH;
      // Normalize dh to [0, 1] range for 3D Euclidean distance calculation
      double normDh = dh / 180.0;

      double ds = targetS - entry.saturation;
      double dv = targetV - entry.value;

      double distSq = (wH * normDh * normDh) +
          (wS * ds * ds) +
          (wV * dv * dv);

      distances.add(_DistancePair(entry: entry, distanceSq: distSq));
    }

    // Sort by smallest distance
    distances.sort((a, b) => a.distanceSq.compareTo(b.distanceSq));

    // Majority vote among top K neighbors
    final kNeighbors = distances.take(math.min(k, distances.length));
    final voteCounts = <String, int>{};
    final entryMap = <String, IsccNbsColorEntry>{};

    for (final pair in kNeighbors) {
      final name = pair.entry.name;
      voteCounts[name] = (voteCounts[name] ?? 0) + 1;
      entryMap[name] = pair.entry;
    }

    String topName = kNeighbors.first.entry.name;
    int maxVotes = 0;

    voteCounts.forEach((name, count) {
      if (count > maxVotes) {
        maxVotes = count;
        topName = name;
      }
    });

    return entryMap[topName] ?? kNeighbors.first.entry;
  }
}

class _DistancePair {
  final IsccNbsColorEntry entry;
  final double distanceSq;

  _DistancePair({required this.entry, required this.distanceSq});
}
