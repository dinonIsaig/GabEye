import 'dart:math' as math;
import '../models/cap.dart';

enum ColorDeficiencyType {
  normal,
  protan,
  deutan,
  tritan,
  unclassified,
  random
}

class CrossingError {
  final int capA;
  final int capB;
  final int distance;
  final bool isMajor;

  const CrossingError({
    required this.capA,
    required this.capB,
    required this.distance,
    required this.isMajor,
  });
}

class D15ScoreResult {
  final double cIndex;
  final double sIndex;
  final double angle;
  final double majorRadius;
  final double minorRadius;
  final double totalError;
  final ColorDeficiencyType diagnosisType;
  final String diagnosisName;
  final String conesAffected;
  final String description;
  final List<CrossingError> crossings;

  const D15ScoreResult({
    required this.cIndex,
    required this.sIndex,
    required this.angle,
    required this.majorRadius,
    required this.minorRadius,
    required this.totalError,
    required this.diagnosisType,
    required this.diagnosisName,
    required this.conesAffected,
    required this.description,
    required this.crossings,
  });
}

class ScoringService {
  static D15ScoreResult calculateScore(List<int> arrangedCaps) {
    // 0-based array in Dart. Prepend Pilot (0)
    final List<int> capnumbers = [0, ...arrangedCaps];
    final int tSize = 16;

    // 1. Calculate color difference vectors
    final List<double> du = [];
    final List<double> dv = [];
    for (int i = 0; i < tSize - 1; i++) {
      final int capA = capnumbers[i];
      final int capB = capnumbers[i + 1];

      // Look up CIELUV coordinates
      final capDataA = ColorCap.allCaps[capA];
      final capDataB = ColorCap.allCaps[capB];

      du.add(capDataB.u - capDataA.u);
      dv.add(capDataB.v - capDataA.v);
    }

    // 2. Compute sums of squares and cross products
    double u2 = 0;
    double v2 = 0;
    double uv = 0;
    for (int i = 0; i < du.length; i++) {
      u2 += du[i] * du[i];
      v2 += dv[i] * dv[i];
      uv += du[i] * dv[i];
    }

    // 3. Determine moments and angle A0
    final double diff = u2 - v2;
    double a0 = (diff == 0) ? 0.7854 : math.atan(2 * uv / diff) / 2;

    double i0 = u2 * math.sin(a0) * math.sin(a0) +
        v2 * math.cos(a0) * math.cos(a0) -
        2 * uv * math.sin(a0) * math.cos(a0);

    double a1 = (a0 < 0) ? a0 + 1.5708 : a0 - 1.5708;

    double i1 = u2 * math.sin(a1) * math.sin(a1) +
        v2 * math.cos(a1) * math.cos(a1) -
        2 * uv * math.sin(a1) * math.cos(a1);

    // Ensure major moment (I0) is greater than minor moment (I1)
    if (i0 <= i1) {
      final tempA = a0;
      a0 = a1;
      a1 = tempA;

      final tempI = i0;
      i0 = i1;
      i1 = tempI;
    }

    // 4. Calculate radii and scoring indices
    final double r0 = math.sqrt(i0 / 15);
    final double r1 = math.sqrt(i1 / 15);
    final double totalError = math.sqrt(r0 * r0 + r1 * r1);

    final double sIndex = r0 / r1;
    final double cIndex = r0 / 9.234669;
    final double angleDegrees = a1 * 57.29577951308232; // Convert radians to degrees

    // 5. Interpret results
    ColorDeficiencyType type = ColorDeficiencyType.normal;
    String name = "Normal Color Vision";
    String cones = "All Cones Intact";
    String desc = "";

    final bool isAbnormal = cIndex > 1.78;

    if (isAbnormal) {
      if (sIndex >= 2.0) {
        // Selective Color Deficiency
        if (angleDegrees > 3 && angleDegrees < 17) {
          type = ColorDeficiencyType.protan;
          name = "Protanopia / Protanomaly";
          cones = "L-Cones (Long-Wavelength / Red) Affected / Missing";
          desc = "You exhibit a Protan color vision defect, commonly known as red-blindness (protanopia) or red-weakness (protanomaly). The L-cones (long-wavelength sensitive photopigments) in your retina are either absent or dysfunctional. This makes it difficult to distinguish red from green, and red colors appear darker or desaturated.";
        } else if (angleDegrees > -11 && angleDegrees < -4) {
          type = ColorDeficiencyType.deutan;
          name = "Deuteranopia / Deuteranomaly";
          cones = "M-Cones (Medium-Wavelength / Green) Affected / Missing";
          desc = "You exhibit a Deutan color vision defect, commonly known as green-blindness (deuteranopia) or green-weakness (deuteranomaly). The M-cones (medium-wavelength sensitive photopigments) in your retina are either absent or defective. This is the most common form of color blindness, causing green and red to look similar, along with green and grey/purple.";
        } else if (angleDegrees > -90 && angleDegrees < -70) {
          type = ColorDeficiencyType.tritan;
          name = "Tritanopia / Tritanomaly";
          cones = "S-Cones (Short-Wavelength / Blue) Affected / Missing";
          desc = "You exhibit a Tritan color vision defect, commonly known as blue-yellow color blindness. The S-cones (short-wavelength sensitive photopigments) in your retina are either absent or defective. This rare condition makes it difficult to differentiate blue from green, and yellow from pink/violet. It is frequently acquired through ocular health issues.";
        } else {
          type = ColorDeficiencyType.unclassified;
          name = "Unclassified Deficiency";
          cones = "Multiple / Unspecified Cones Affected";
          desc = "Your test indicates a significant color vision defect that is selective but does not fall perfectly within the standard Protan, Deutan, or Tritan angular zones. This can indicate a mixed or custom congenital color deficiency.";
        }
      } else {
        // General/Random Errors
        type = ColorDeficiencyType.random;
        name = "Anarchic / Random Errors";
        cones = "Non-Specific General Color Confusion";
        desc = "Your color arrangement has a high number of errors, but they are scattered randomly rather than aligning along a specific axis of deficiency. This general confusion can result from severe acquired vision problems, fatigue, low ambient lighting, display calibration issues, or a misunderstanding of test instructions.";
      }
    } else {
      // Normal arrangement
      type = ColorDeficiencyType.normal;
      name = "Normal Color Vision";
      cones = "All Cones Intact";
      desc = "Your cap arrangement is normal! You have excellent color discrimination. Any minor transpositions (e.g. adjacent cap swaps) are within the standard threshold of normal observers under typical viewing conditions.";
    }

    // 6. Trace transpositions and crossover errors
    final List<CrossingError> crossings = [];
    for (int i = 0; i < tSize - 1; i++) {
      final int capA = capnumbers[i];
      final int capB = capnumbers[i + 1];
      final int diffDistance = (capA - capB).abs();

      if (diffDistance > 1) {
        crossings.add(CrossingError(
          capA: capA,
          capB: capB,
          distance: diffDistance,
          isMajor: diffDistance >= 4,
        ));
      }
    }

    return D15ScoreResult(
      cIndex: cIndex,
      sIndex: sIndex,
      angle: angleDegrees,
      majorRadius: r0,
      minorRadius: r1,
      totalError: totalError,
      diagnosisType: type,
      diagnosisName: name,
      conesAffected: cones,
      description: desc,
      crossings: crossings,
    );
  }
}