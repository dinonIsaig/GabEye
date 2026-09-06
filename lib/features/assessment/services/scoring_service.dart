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

/// How far outside the typical range the result falls: Normal, Moderate,
/// or Strong. Kept to 3 tiers to match the result screens' 3 banner/chip
/// colors — if you need finer bands later (e.g. a "Mild" tier), add it
/// here once and every screen that reads `result.severity` picks it up
/// automatically.
///
/// NOTE: the cIndex cut point below (3.0) is a practical banding choice
/// for presenting results to a general audience, not a clinically
/// validated scale on its own 
enum SeverityLevel { none, moderate, strong }

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
  final String diagnosisName; // full clinical name, e.g. "Protanopia / Protanomaly"
  final String shortName; // e.g. "Protan" — safe to use directly in chips/badges
  final String conesAffected; // full sentence, for the detailed results screen
  final String conesShortLabel; // e.g. "L-Cones" — for compact chips
  final String description; // long technical description, for the detailed results screen
  final List<CrossingError> crossings;

  // --- Fields supporting the post-assessment summary UI ---
  final SeverityLevel severity;
  final String severityLabel; // e.g. "Moderate"
  final String rangeHeadline; // e.g. "Your result is above the typical range."
  final String rangeBody; // one-sentence explanation of the pattern found
  final String practicalTip; // everyday, plain-language takeaway

  const D15ScoreResult({
    required this.cIndex,
    required this.sIndex,
    required this.angle,
    required this.majorRadius,
    required this.minorRadius,
    required this.totalError,
    required this.diagnosisType,
    required this.diagnosisName,
    required this.shortName,
    required this.conesAffected,
    required this.conesShortLabel,
    required this.description,
    required this.crossings,
    required this.severity,
    required this.severityLabel,
    required this.rangeHeadline,
    required this.rangeBody,
    required this.practicalTip,
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
    final double angleDegrees = a1 * 57.29577951308232;

    // 5. Trace transpositions and crossover errors (computed before
    // interpretation so severity/banner copy can reference crossings)
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

    // 6. Interpret results
    ColorDeficiencyType type = ColorDeficiencyType.normal;
    String name = "Normal Color Vision";
    String shortName = "Normal";
    String cones = "All Cones Intact";
    String conesShort = "All Cones";
    String desc = "Your results suggest typical color vision with no significant color deficiency detected. This means your eyes have no difficulty distinguishing colors across the spectrum.";
    String tip = "Your color perception falls within the typical range for the assessed hues.";

    final bool isAbnormal = cIndex > 1.78;

    if (isAbnormal) {
      if (sIndex >= 2.0) {
        if (angleDegrees > 3 && angleDegrees < 17) {
          type = ColorDeficiencyType.protan;
          name = "Protanopia / Protanomaly";
          shortName = "Protan";
          cones = "L-Cones (Long-Wavelength / Red) Affected / Missing";
          conesShort = "L-Cones";
          desc = "You exhibit a Protan color vision defect, commonly known as red-blindness (protanopia) or red-weakness (protanomaly). The L-cones (long-wavelength sensitive photopigments) in your retina are either absent or dysfunctional. This makes it difficult to distinguish red from green, and red colors appear darker or desaturated.";
          tip = "Reds can also appear noticeably darker or dimmer than they do for most people.";
        } else if (angleDegrees > -11 && angleDegrees < -4) {
          type = ColorDeficiencyType.deutan;
          name = "Deuteranopia / Deuteranomaly";
          shortName = "Deutan";
          cones = "M-Cones (Medium-Wavelength / Green) Affected / Missing";
          conesShort = "M-Cones";
          desc = "You exhibit a Deutan color vision defect, commonly known as green-blindness (deuteranopia) or green-weakness (deuteranomaly). The M-cones (medium-wavelength sensitive photopigments) in your retina are either absent or defective. This is the most common form of color blindness, causing green and red to look similar, along with green and grey/purple.";
          tip = "Greens and reds can look muted or similar in shade, especially in low light.";
        } else if (angleDegrees > -90 && angleDegrees < -70) {
          type = ColorDeficiencyType.tritan;
          name = "Tritanopia / Tritanomaly";
          shortName = "Tritan";
          cones = "S-Cones (Short-Wavelength / Blue) Affected / Missing";
          conesShort = "S-Cones";
          desc = "You exhibit a Tritan color vision defect, commonly known as blue-yellow color blindness. The S-cones (short-wavelength sensitive photopigments) in your retina are either absent or defective. This rare condition makes it difficult to differentiate blue from green, and yellow from pink/violet. It is frequently acquired through ocular health issues.";
          tip = "Blues and yellows can be the hardest to tell apart, especially in dim lighting.";
        } else {
          type = ColorDeficiencyType.unclassified;
          name = "Unclassified Deficiency";
          shortName = "Unclassified";
          cones = "Multiple / Unspecified Cones Affected";
          conesShort = "Multiple Cones";
          desc = "Your test indicates a significant color vision defect that is selective but does not fall perfectly within the standard Protan, Deutan, or Tritan angular zones. This can indicate a mixed or custom congenital color deficiency.";
          tip = "Your results don't cleanly match a single cone type — a follow-up test may help clarify the pattern.";
        }
      } else {
        type = ColorDeficiencyType.random;
        name = "Anarchic / Random Errors";
        shortName = "Random";
        cones = "Non-Specific General Color Confusion";
        conesShort = "Non-Specific";
        desc = "Your color arrangement has a high number of errors, but they are scattered randomly rather than aligning along a specific axis of deficiency. This general confusion can result from severe acquired vision problems, fatigue, low ambient lighting, display calibration issues, or a misunderstanding of test instructions.";
        tip = "Color differences may be inconsistent across lighting conditions — retesting in better lighting is recommended.";
      }
    }

    // 7. Severity band (3 tiers) + banner copy for the summary screen
    SeverityLevel severity;
    String severityLabel;
    if (!isAbnormal) {
      severity = SeverityLevel.none;
      severityLabel = "Normal";
    } else if (cIndex <= 3.0) {
      severity = SeverityLevel.moderate;
      severityLabel = "Moderate";
    } else {
      severity = SeverityLevel.strong;
      severityLabel = "Strong";
    }

    final String rangeHeadline = isAbnormal
        ? "Your result is above the typical range."
        : "Your result is within the typical range.";

    String rangeBody;
    if (!isAbnormal) {
      rangeBody = "Your cap arrangement closely matches what's expected for normal color vision, with only minor transpositions if any.";
    } else if (severity == SeverityLevel.moderate) {
      rangeBody = "A small number of caps were placed slightly out of order, forming a mild pattern rather than a strong one.";
    } else {
      rangeBody = "Many caps were placed significantly out of sequence, forming a strong, consistent pattern.";
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
      shortName: shortName,
      conesAffected: cones,
      conesShortLabel: conesShort,
      description: desc,
      crossings: crossings,
      severity: severity,
      severityLabel: severityLabel,
      rangeHeadline: rangeHeadline,
      rangeBody: rangeBody,
      practicalTip: tip,
    );
  }
}