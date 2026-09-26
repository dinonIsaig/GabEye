import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:gabeye/core/services/object_detection_service.dart';

/// Scales and translates an ML Kit bounding box from raw camera sensor dimensions
/// ([imageSize]) to the logical Flutter screen canvas coordinates ([canvasSize]).
///
/// Mathematical Steps Handled:
/// 1. Sensor Orientation & Axis Swapping:
///    In portrait mode (90° / 270°), sensor X and Y axes are swapped relative to the display.
///    If the raw coordinates are in unrotated landscape space ([0, rawWidth] x [0, rawHeight]),
///    they are rotated into upright portrait space ([0, uprightWidth] x [0, uprightHeight]).
/// 2. Uniform [BoxFit.cover] Aspect Scaling:
///    scale = max(canvasWidth / uprightWidth, canvasHeight / uprightHeight)
/// 3. Centering Offsets & Viewport Cropping:
///    offsetX = (canvasWidth - uprightWidth * scale) / 2.0
///    offsetY = (canvasHeight - uprightHeight * scale) / 2.0
/// 4. Front-Camera Horizontal Mirroring (if applicable).
Rect scaleBoundingBox({
  required Rect rawBox,
  required Size imageSize,
  required Size canvasSize,
  CameraDescription? cameraDescription,
  InputImageRotation? rotation,
  CameraLensDirection? cameraLensDirection,
}) {
  if (imageSize.width <= 0 || imageSize.height <= 0 || canvasSize.width <= 0 || canvasSize.height <= 0) {
    return rawBox;
  }

  // Determine rotation degrees (defaults to 90° for mobile portrait back camera)
  int rotationDegrees = 90;
  if (rotation != null) {
    rotationDegrees = rotation.rawValue;
  } else if (cameraDescription != null) {
    rotationDegrees = cameraDescription.sensorOrientation;
  }

  // Determine camera lens direction (front camera requires horizontal mirroring)
  final CameraLensDirection direction = cameraLensDirection ??
      cameraDescription?.lensDirection ??
      CameraLensDirection.back;
  final bool isFrontCamera = direction == CameraLensDirection.front;

  final bool isRotated = rotationDegrees == 90 || rotationDegrees == 270;

  // In portrait orientation (90°/270°), the display's upright image dimensions are swapped:
  // uprightWidth is the short dimension (e.g., 720)
  // uprightHeight is the long dimension (e.g., 1280)
  final double uprightWidth = isRotated ? math.min(imageSize.width, imageSize.height) : imageSize.width;
  final double uprightHeight = isRotated ? math.max(imageSize.width, imageSize.height) : imageSize.height;

  // 1. Coordinate Normalization & Axis Rotation:
  // Detect if rawBox coordinates are in unrotated landscape sensor space
  // (e.g., box.right > uprightWidth indicates coordinates are in the [0..1280] sensor domain).
  Rect uprightRect;
  final bool isLandscapeSensor = imageSize.width > imageSize.height;
  final bool isRawSensorSpace = isRotated &&
      (isLandscapeSensor ||
       rawBox.right > uprightWidth ||
       rawBox.left > uprightWidth ||
       rawBox.width > uprightWidth);

  if (isRawSensorSpace) {
    // Coordinates are in raw landscape sensor space ([0, 1280] x [0, 720]).
    // For 90° clockwise rotation to upright portrait:
    // Screen X corresponds to (sensorHeight - sensorY)
    // Screen Y corresponds to sensorX
    final double rawSensorHeight = math.min(imageSize.width, imageSize.height);
    if (rotationDegrees == 90) {
      final double left = rawSensorHeight - rawBox.bottom;
      final double top = rawBox.left;
      final double width = rawBox.height;
      final double height = rawBox.width;
      uprightRect = Rect.fromLTWH(left, top, width, height);
    } else {
      // 270° (e.g., front camera sensor orientation)
      final double left = rawBox.top;
      final double top = math.max(imageSize.width, imageSize.height) - rawBox.right;
      final double width = rawBox.height;
      final double height = rawBox.width;
      uprightRect = Rect.fromLTWH(left, top, width, height);
    }
  } else {
    // Coordinates are already in upright portrait space ([0, 720] x [0, 1280])
    uprightRect = rawBox;
  }

  // 2. Uniform BoxFit.cover Scaling Factor:
  // Preserves aspect ratio by scaling the preview uniformly until the canvas is completely covered.
  final double scaleX = canvasSize.width / uprightWidth;
  final double scaleY = canvasSize.height / uprightHeight;
  final double scale = math.max(scaleX, scaleY);

  // 3. Centering Offsets (Crop Calculation):
  // Since BoxFit.cover centers the preview, overflow edges are cropped symmetrically.
  final double scaledWidth = uprightWidth * scale;
  final double scaledHeight = uprightHeight * scale;
  final double offsetX = (canvasSize.width - scaledWidth) / 2.0;
  final double offsetY = (canvasSize.height - scaledHeight) / 2.0;

  // 4. Transform coordinates to screen canvas pixels
  double left = uprightRect.left * scale + offsetX;
  double top = uprightRect.top * scale + offsetY;
  double right = uprightRect.right * scale + offsetX;
  double bottom = uprightRect.bottom * scale + offsetY;

  // 5. Front Camera Horizontal Mirroring:
  if (isFrontCamera) {
    final double mirroredLeft = canvasSize.width - right;
    final double mirroredRight = canvasSize.width - left;
    left = mirroredLeft;
    right = mirroredRight;
  }

  // Ensure left <= right and top <= bottom
  final double sortedLeft = math.min(left, right);
  final double sortedRight = math.max(left, right);
  final double sortedTop = math.min(top, bottom);
  final double sortedBottom = math.max(top, bottom);

  return Rect.fromLTRB(sortedLeft, sortedTop, sortedRight, sortedBottom);
}

/// Standalone CustomPainter that paints [DetectedObject]s over a camera preview,
/// applying [scaleBoundingBox] to map raw ML Kit coordinates into screen coordinates
/// matching the [BoxFit.cover] camera geometry.
class ObjectDetectorPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Color primaryColor;

  ObjectDetectorPainter({
    required this.objects,
    required this.imageSize,
    this.rotation = InputImageRotation.rotation90deg,
    this.cameraLensDirection = CameraLensDirection.back,
    this.primaryColor = const Color(0xFF00E5FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (objects.isEmpty) return;

    final boxPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    final badgeBgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final badgeBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final object in objects) {
      // 1. Transform raw ML Kit boundingBox to screen coordinates
      final Rect scaledRect = scaleBoundingBox(
        rawBox: object.boundingBox,
        imageSize: imageSize,
        canvasSize: size,
        rotation: rotation,
        cameraLensDirection: cameraLensDirection,
      );

      // 2. Draw outer shadow and bounding box
      final rrect = RRect.fromRectAndRadius(scaledRect, const Radius.circular(8));
      canvas.drawRRect(rrect, shadowPaint);
      canvas.drawRRect(rrect, boxPaint);

      // 3. Format label and confidence percentage
      final label = ObjectDetectionService.instance.resolveBestDisplayLabel(object.labels);
      final matched = ObjectDetectionService.instance.findMatchedLabel(object.labels) ??
          (object.labels.isNotEmpty ? object.labels.first : null);
      final confidence = matched != null ? (matched.confidence * 100).round() : 0;
      final confidenceStr = confidence > 0 ? ' ($confidence%)' : '';
      final displayText = '$label$confidenceStr';

      // 4. Position label and confidence percentage directly above scaled bounding box
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'AtkinsonHyperlegible',
        letterSpacing: 0.3,
      );

      final textSpan = TextSpan(text: displayText, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      const paddingH = 8.0;
      const paddingV = 4.0;
      final badgeWidth = textPainter.width + paddingH * 2;
      final badgeHeight = textPainter.height + paddingV * 2;

      // Position directly above the bounding box. If too close to top of screen (< 8px), flip inside.
      double badgeTop = scaledRect.top - badgeHeight - 6.0;
      if (badgeTop < 8.0) {
        badgeTop = scaledRect.top + 6.0;
      }

      // Clamp horizontally within screen edges
      double badgeLeft = scaledRect.left;
      if (badgeLeft + badgeWidth > size.width - 8.0) {
        badgeLeft = size.width - badgeWidth - 8.0;
      }
      if (badgeLeft < 8.0) {
        badgeLeft = 8.0;
      }

      final badgeRect = Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight);
      final badgeRRect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(6));

      // Draw floating badge background, border, and text
      canvas.drawRRect(badgeRRect, badgeBgPaint);
      canvas.drawRRect(badgeRRect, badgeBorderPaint);
      textPainter.paint(canvas, Offset(badgeLeft + paddingH, badgeTop + paddingV));
    }
  }

  @override
  bool shouldRepaint(covariant ObjectDetectorPainter oldDelegate) {
    return oldDelegate.objects != objects ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Real-time bounding box and label overlay widget rendered over the camera preview.
///
/// Features:
/// 1. 60 FPS Bounding Box Smooth Gliding (Continuous position & opacity lerp across camera stream updates).
/// 2. Temporal Label Debouncing & Confidence Smoothing (Rock-solid text, zero jitter).
/// 3. Top-2 Prominence Filtering (Area * Center Proximity ranking, noise-floor pruning, Primary/Secondary hierarchy).
/// 4. Missed-Frame Grace Period (Prevents box flickering/strobing on single-frame drops).
/// 5. Rate-Limited Assistive Micro-Haptic Confirmation on target lock.
class ObjectDetectionOverlay extends StatefulWidget {
  final List<DetectedObject> objects;
  final Size imageSize;
  final CameraDescription? cameraDescription;

  const ObjectDetectionOverlay({
    super.key,
    required this.objects,
    required this.imageSize,
    this.cameraDescription,
  });

  @override
  State<ObjectDetectionOverlay> createState() => _ObjectDetectionOverlayState();
}

class _ObjectDetectionOverlayState extends State<ObjectDetectionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _animation;

  List<_TrackedBox> _trackedBoxes = [];
  Size _lastCanvasSize = Size.zero;
  bool _isFirstLayout = true;
  DateTime _lastHapticTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    // 150ms matches the ~6.7 FPS camera ingestion frame cadence
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant ObjectDetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.objects != oldWidget.objects ||
        widget.imageSize != oldWidget.imageSize) {
      if (_lastCanvasSize.width > 0 && _lastCanvasSize.height > 0) {
        _syncTrackedBoxes(widget.objects);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerHapticFeedback() {
    final now = DateTime.now();
    if (now.difference(_lastHapticTimestamp) > const Duration(milliseconds: 1200)) {
      _lastHapticTimestamp = now;
      HapticFeedback.selectionClick();
    }
  }

  void _syncTrackedBoxes(List<DetectedObject> incomingObjects) {
    if (_lastCanvasSize.width <= 0 || _lastCanvasSize.height <= 0) return;

    final double currentProgress = _animation.value;

    if (incomingObjects.isEmpty) {
      if (_trackedBoxes.isNotEmpty) {
        final remainingBoxes = <_TrackedBox>[];
        for (final box in _trackedBoxes) {
          box.missedFrames++;
          final currentPos = Rect.lerp(box.startRect, box.targetRect, currentProgress) ?? box.targetRect;
          final currentOpacity = ui.lerpDouble(box.startOpacity, box.targetOpacity, currentProgress) ?? box.targetOpacity;

          box.startRect = currentPos;
          box.targetRect = currentPos;
          box.startOpacity = currentOpacity;

          if (box.missedFrames <= 2) {
            // Grace period: keep visible with slight dimming
            box.targetOpacity = 0.5;
            remainingBoxes.add(box);
          } else {
            // Exceeded grace period: fade out
            box.targetOpacity = 0.0;
            if (currentOpacity > 0.05) {
              remainingBoxes.add(box);
            }
          }
        }
        _trackedBoxes = remainingBoxes;
        _animController.forward(from: 0.0);
      }
      return;
    }

    // 1. Map incoming objects to screen-space coordinates using scaleBoundingBox
    final mapped = <_IncomingObject>[];
    final screenCenter = Offset(_lastCanvasSize.width / 2.0, _lastCanvasSize.height / 2.0);
    final double maxDist = screenCenter.distance > 0 ? screenCenter.distance : 1.0;
    final double totalScreenArea = _lastCanvasSize.width * _lastCanvasSize.height;
    final double minAreaThreshold = totalScreenArea > 0 ? totalScreenArea * 0.015 : 1600.0;

    for (final obj in incomingObjects) {
      final screenRect = scaleBoundingBox(
        rawBox: obj.boundingBox,
        imageSize: widget.imageSize,
        canvasSize: _lastCanvasSize,
        cameraDescription: widget.cameraDescription,
      );

      final double area = screenRect.width * screenRect.height;
      // Step 3 (Noise Floor): Discard tiny background artifacts (< 40px or < 1.5% screen area)
      if (screenRect.width < 40.0 || screenRect.height < 40.0 || area < minAreaThreshold) {
        // If it's the sole detection in the frame, preserve it if above basic 32px noise floor
        if (incomingObjects.length > 1 || screenRect.width < 32.0 || screenRect.height < 32.0) {
          continue;
        }
      }

      // Step 3 (Center-Weighted Prominence): Area boosted by proximity to camera crosshair center
      final double distFromCenter = (screenRect.center - screenCenter).distance;
      final double centerProximity = 1.0 - (0.4 * (distFromCenter / maxDist).clamp(0.0, 1.0));
      final double prominenceScore = area * centerProximity;

      final label = ObjectDetectionService.instance.resolveBestDisplayLabel(obj.labels);
      final matched = ObjectDetectionService.instance.findMatchedLabel(obj.labels) ??
          (obj.labels.isNotEmpty ? obj.labels.first : null);
      final rawConfidence = matched != null ? (matched.confidence * 100).round() : 0;

      mapped.add(_IncomingObject(
        screenRect: screenRect,
        label: label,
        confidence: rawConfidence,
        trackingId: obj.trackingId,
        area: area,
        prominenceScore: prominenceScore,
      ));
    }

    // 2. Step 3 (Top-2 Prominence Filter): Sort by prominence score descending & take Top 2
    mapped.sort((a, b) => b.prominenceScore.compareTo(a.prominenceScore));
    final topCandidates = mapped.take(2).toList();

    // 3. Match new objects with existing tracked boxes (IoU + Proximity + Label)
    final updatedBoxes = <_TrackedBox>[];
    final matchedExisting = <_TrackedBox>{};

    for (int i = 0; i < topCandidates.length; i++) {
      final candidate = topCandidates[i];
      final bool isPrimary = (i == 0); // Primary focus object vs Secondary item

      _TrackedBox? bestMatch;
      double bestSimilarity = -1.0;

      for (final existing in _trackedBoxes) {
        if (matchedExisting.contains(existing)) continue;

        final similarity = _computeSimilarity(candidate, existing, _lastCanvasSize);
        // Generous threshold so moving/panning objects remain smoothly locked
        final isSingleObjectScene = (topCandidates.length == 1 && _trackedBoxes.length == 1);
        final minThreshold = isSingleObjectScene ? 0.25 : 0.40;

        if (similarity >= minThreshold && similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestMatch = existing;
        }
      }

      if (bestMatch != null) {
        matchedExisting.add(bestMatch);

        // Step 1: Smooth Gliding - Sample exact current interpolated position
        final currentPos = Rect.lerp(bestMatch.startRect, bestMatch.targetRect, currentProgress) ??
            bestMatch.targetRect;
        final currentOpacity = ui.lerpDouble(bestMatch.startOpacity, bestMatch.targetOpacity, currentProgress) ??
            bestMatch.targetOpacity;

        bestMatch.startRect = currentPos;
        bestMatch.targetRect = candidate.screenRect;
        bestMatch.startOpacity = currentOpacity;
        bestMatch.targetOpacity = 1.0;
        bestMatch.missedFrames = 0;
        bestMatch.trackingId = candidate.trackingId;
        bestMatch.isPrimary = isPrimary;

        // Step 2: Label Stability & Anti-Flicker Debouncing
        if (candidate.label == bestMatch.stableLabel) {
          bestMatch.pendingCount = 0;
          bestMatch.pendingLabel = '';
        } else {
          final isDecisiveConfidence = candidate.confidence >= (bestMatch.confidence + 25);
          if (candidate.label == bestMatch.pendingLabel) {
            bestMatch.pendingCount++;
            if (bestMatch.pendingCount >= 2 || isDecisiveConfidence) {
              bestMatch.stableLabel = candidate.label;
              bestMatch.pendingCount = 0;
              bestMatch.pendingLabel = '';
              _triggerHapticFeedback();
            }
          } else {
            if (isDecisiveConfidence) {
              bestMatch.stableLabel = candidate.label;
              bestMatch.pendingCount = 0;
              bestMatch.pendingLabel = '';
              _triggerHapticFeedback();
            } else {
              bestMatch.pendingLabel = candidate.label;
              bestMatch.pendingCount = 1;
            }
          }
        }

        // Confidence Jitter Smoothing: EMA + Quantize to 5% steps
        final smoothed = (bestMatch.confidence * 0.6 + candidate.confidence * 0.4).round();
        bestMatch.confidence = ((smoothed / 5).round() * 5).clamp(5, 100);

        updatedBoxes.add(bestMatch);
      } else {
        // Brand-new detected object entering view: Smooth Fade In
        final newBox = _TrackedBox(
          startRect: candidate.screenRect,
          targetRect: candidate.screenRect,
          startOpacity: 0.0,
          targetOpacity: 1.0,
          stableLabel: candidate.label,
          confidence: ((candidate.confidence / 5).round() * 5).clamp(5, 100),
          trackingId: candidate.trackingId,
          isPrimary: isPrimary,
        );
        updatedBoxes.add(newBox);
        _triggerHapticFeedback();
      }
    }

    // Grace Period: Retain unmatched existing boxes for up to 2 frames (~300ms)
    for (final existing in _trackedBoxes) {
      if (!matchedExisting.contains(existing)) {
        existing.missedFrames++;
        final currentPos = Rect.lerp(existing.startRect, existing.targetRect, currentProgress) ??
            existing.targetRect;
        final currentOpacity = ui.lerpDouble(existing.startOpacity, existing.targetOpacity, currentProgress) ??
            existing.targetOpacity;

        existing.startRect = currentPos;
        existing.targetRect = currentPos;
        existing.startOpacity = currentOpacity;

        if (existing.missedFrames <= 2) {
          // Grace period: keep visible, slightly dim
          existing.targetOpacity = 0.6;
          updatedBoxes.add(existing);
        } else {
          // Exceeded grace: fade out to 0
          existing.targetOpacity = 0.0;
          if (currentOpacity > 0.05) {
            updatedBoxes.add(existing);
          }
        }
      }
    }

    _trackedBoxes = updatedBoxes;
    _animController.forward(from: 0.0);
  }

  double _computeSimilarity(_IncomingObject candidate, _TrackedBox existing, Size canvasSize) {
    // 1. Direct tracking ID match
    if (candidate.trackingId != null &&
        existing.trackingId != null &&
        candidate.trackingId == existing.trackingId) {
      return 1000.0;
    }

    // 2. Intersection over Union (IoU)
    final intersection = candidate.screenRect.intersect(existing.targetRect);
    double iou = 0.0;
    if (!intersection.isEmpty && intersection.width > 0 && intersection.height > 0) {
      final interArea = intersection.width * intersection.height;
      final unionArea = (candidate.screenRect.width * candidate.screenRect.height) +
          (existing.targetRect.width * existing.targetRect.height) -
          interArea;
      if (unionArea > 0) {
        iou = interArea / unionArea;
      }
    }

    // 3. Proximity score (normalized center distance)
    final diagonal = math.sqrt(canvasSize.width * canvasSize.width + canvasSize.height * canvasSize.height);
    final centerDist = (candidate.screenRect.center - existing.targetRect.center).distance;
    final normalizedDist = diagonal > 0 ? (centerDist / diagonal).clamp(0.0, 1.0) : 1.0;
    final proximityScore = (1.0 - normalizedDist);

    // 4. Label consistency bonus
    final labelBonus = (candidate.label == existing.stableLabel) ? 0.35 : 0.0;

    return (iou * 2.0) + proximityScore + labelBonus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }

          final newCanvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (_lastCanvasSize != newCanvasSize) {
            _lastCanvasSize = newCanvasSize;
            if (_isFirstLayout) {
              _isFirstLayout = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _syncTrackedBoxes(widget.objects);
                }
              });
            }
          }

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ObjectDetectionOverlayPainter(
                  boxes: _trackedBoxes,
                  animProgress: _animation.value,
                  primaryColor: primaryColor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _IncomingObject {
  final Rect screenRect;
  final String label;
  final int confidence;
  final int? trackingId;
  final double area;
  final double prominenceScore;

  _IncomingObject({
    required this.screenRect,
    required this.label,
    required this.confidence,
    this.trackingId,
    required this.area,
    required this.prominenceScore,
  });
}

class _TrackedBox {
  Rect startRect;
  Rect targetRect;
  double startOpacity;
  double targetOpacity;
  String stableLabel;
  String pendingLabel = '';
  int pendingCount = 0;
  int confidence;
  int? trackingId;
  int missedFrames = 0;
  bool isPrimary;

  _TrackedBox({
    required this.startRect,
    required this.targetRect,
    required this.startOpacity,
    required this.targetOpacity,
    required this.stableLabel,
    required this.confidence,
    this.trackingId,
    this.isPrimary = true,
  });
}

/// CustomPainter rendering smooth 60 FPS interpolated bounding boxes and floating pill badges.
///
/// Distinguishes the Primary focus object from the Secondary object with distinct border weights
/// and high-contrast corner brackets.
class _ObjectDetectionOverlayPainter extends CustomPainter {
  final List<_TrackedBox> boxes;
  final double animProgress;
  final Color primaryColor;

  _ObjectDetectionOverlayPainter({
    required this.boxes,
    required this.animProgress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boxes.isEmpty) return;

    for (final box in boxes) {
      final opacity = (ui.lerpDouble(box.startOpacity, box.targetOpacity, animProgress) ?? box.targetOpacity).clamp(0.0, 1.0);
      if (opacity <= 0.02) continue;

      // 60 FPS Continuous Linear Interpolation (Glide smoothly across frames)
      final rect = Rect.lerp(box.startRect, box.targetRect, animProgress)!;
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

      // Visual prominence differentiation: Primary (2.5px) vs Secondary (1.8px)
      final double borderWidth = box.isPrimary ? 2.5 : 1.8;
      final double shadowWidth = box.isPrimary ? 4.5 : 3.0;

      final boxBorderPaint = Paint()
        ..color = (box.isPrimary ? primaryColor : primaryColor.withValues(alpha: 0.85)).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      final boxShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: (box.isPrimary ? 0.45 : 0.3) * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = shadowWidth;

      final cornerAccentPaint = Paint()
        ..color = (box.isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.75)).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = box.isPrimary ? 3.5 : 2.5
        ..strokeCap = StrokeCap.round;

      final badgeBgPaint = Paint()
        ..color = Colors.black.withValues(alpha: (box.isPrimary ? 0.88 : 0.78) * opacity)
        ..style = PaintingStyle.fill;

      final badgeBorderPaint = Paint()
        ..color = primaryColor.withValues(alpha: (box.isPrimary ? 1.0 : 0.7) * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = box.isPrimary ? 1.3 : 1.0;

      // 1. Draw outer shadow and primary bounding box
      canvas.drawRRect(rrect, boxShadowPaint);
      canvas.drawRRect(rrect, boxBorderPaint);

      // 2. Draw high-tech vision-lens corner accents (prominent on primary)
      _drawCornerBrackets(canvas, rect, cornerAccentPaint, box.isPrimary);

      // 3. Format and draw floating pill badge
      final confidenceStr = box.confidence > 0 ? ' (${box.confidence}%)' : '';
      final displayText = '${box.stableLabel}$confidenceStr';

      _drawLabelBadge(
        canvas: canvas,
        text: displayText,
        boxRect: rect,
        canvasSize: size,
        badgeBgPaint: badgeBgPaint,
        badgeBorderPaint: badgeBorderPaint,
        opacity: opacity,
        isPrimary: box.isPrimary,
      );
    }
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect, Paint paint, bool isPrimary) {
    final double maxCorner = isPrimary ? 16.0 : 12.0;
    final double cornerLength = math.min(maxCorner, math.min(rect.width, rect.height) / 4);
    if (cornerLength <= 0) return;

    // Top-Left
    canvas.drawLine(Offset(rect.left, rect.top + cornerLength), Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top), paint);

    // Top-Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.top), Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right + cornerLength, rect.top), paint);

    // Bottom-Left
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength), Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom), paint);

    // Bottom-Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.bottom), Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right - cornerLength, rect.bottom), paint);
  }

  void _drawLabelBadge({
    required Canvas canvas,
    required String text,
    required Rect boxRect,
    required Size canvasSize,
    required Paint badgeBgPaint,
    required Paint badgeBorderPaint,
    required double opacity,
    required bool isPrimary,
  }) {
    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: opacity),
      fontSize: 12.0,
      fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
      fontFamily: 'AtkinsonHyperlegible',
      letterSpacing: 0.3,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final paddingH = isPrimary ? 8.0 : 7.0;
    const paddingV = 4.0;
    final badgeWidth = textPainter.width + paddingH * 2;
    final badgeHeight = textPainter.height + paddingV * 2;

    // Position directly above bounding box. If too close to screen top (< 8px), flip inside.
    double badgeTop = boxRect.top - badgeHeight - 6.0;
    if (badgeTop < 8.0) {
      badgeTop = boxRect.top + 6.0;
    }

    double badgeLeft = boxRect.left;
    if (badgeLeft + badgeWidth > canvasSize.width - 8.0) {
      badgeLeft = canvasSize.width - badgeWidth - 8.0;
    }
    if (badgeLeft < 8.0) {
      badgeLeft = 8.0;
    }

    final badgeRect = Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight);
    final badgeRRect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(8));

    // Shadow
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = Colors.black.withValues(alpha: (isPrimary ? 0.5 : 0.35) * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Background & border
    canvas.drawRRect(badgeRRect, badgeBgPaint);
    canvas.drawRRect(badgeRRect, badgeBorderPaint);

    // Render text
    textPainter.paint(canvas, Offset(badgeLeft + paddingH, badgeTop + paddingV));
  }

  @override
  bool shouldRepaint(covariant _ObjectDetectionOverlayPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.boxes != boxes ||
        oldDelegate.primaryColor != primaryColor;
  }
}
