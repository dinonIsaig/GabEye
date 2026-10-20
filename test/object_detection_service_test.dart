import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:gabeye/core/services/object_detection_service.dart';

void main() {
  group('ObjectDetectionService 631-Class Resolution Tests', () {
    final service = ObjectDetectionService.instance;

    test('cleanObjectLabel formats words in title case and takes first synonym', () {
      expect(service.cleanObjectLabel('potato'), 'Potato');
      expect(service.cleanObjectLabel('electric kettle'), 'Electric Kettle');
      expect(service.cleanObjectLabel('cell phone, mobile phone'), 'Cell Phone');
      expect(service.cleanObjectLabel('french fries'), 'French Fries');
      expect(service.cleanObjectLabel('???'), 'Object');
      expect(service.cleanObjectLabel(''), 'Object');
    });

    test('resolves non-COCO 631 classes directly without COCO-80 restriction', () {
      final labels = [
        Label(text: 'potato', confidence: 0.88, index: 1),
      ];
      expect(service.resolveBestDisplayLabel(labels), 'Potato');

      final chickenLabels = [
        Label(text: 'chicken', confidence: 0.92, index: 2),
      ];
      expect(service.resolveBestDisplayLabel(chickenLabels), 'Chicken');

      final kettleLabels = [
        Label(text: 'electric kettle', confidence: 0.79, index: 3),
      ];
      expect(service.resolveBestDisplayLabel(kettleLabels), 'Electric Kettle');
    });

    test('prioritizes specific food/item over umbrella categories', () {
      final candidateLabels = [
        Label(text: 'food', confidence: 0.95, index: 0),
        Label(text: 'potato', confidence: 0.89, index: 1),
      ];
      expect(service.resolveBestDisplayLabel(candidateLabels), 'Potato');

      final tableCandidates = [
        Label(text: 'tableware', confidence: 0.96, index: 0),
        Label(text: 'coffee cup', confidence: 0.84, index: 1),
      ];
      expect(service.resolveBestDisplayLabel(tableCandidates), 'Coffee Cup');
    });

    test('falls back to top label if all candidates are umbrella categories', () {
      final onlyUmbrella = [
        Label(text: 'food', confidence: 0.80, index: 0),
      ];
      expect(service.resolveBestDisplayLabel(onlyUmbrella), 'Food');
    });

    test('findMatchedLabel returns exact candidate label and confidence for 631-class items', () {
      final candidateLabels = [
        Label(text: 'food', confidence: 0.95, index: 0),
        Label(text: 'potato', confidence: 0.89, index: 1),
      ];
      final matched = service.findMatchedLabel(candidateLabels);
      expect(matched, isNotNull);
      expect(matched!.text, 'potato');
      expect(matched.confidence, closeTo(0.89, 0.001));
    });

    test('prioritizes Coffeemaker over Home Appliance and Kitchen Appliance in candidate labels', () {
      final applianceCandidates = [
        Label(text: 'home appliance', confidence: 0.95, index: 0),
        Label(text: 'kitchen appliance', confidence: 0.90, index: 1),
        Label(text: 'coffeemaker', confidence: 0.60, index: 2),
      ];
      expect(service.resolveBestDisplayLabel(applianceCandidates), 'Coffeemaker');

      final matched = service.findMatchedLabel(applianceCandidates);
      expect(matched, isNotNull);
      expect(matched!.text, 'coffeemaker');
      expect(matched.confidence, closeTo(0.60, 0.001));
    });

    test('computeIoU and computeEnclosureRatio calculate correct spatial overlaps', () {
      const boxA = Rect.fromLTWH(100, 100, 200, 200); // Area = 40000
      const boxB = Rect.fromLTWH(120, 120, 180, 180); // Inside boxA
      final iou = ObjectDetectionService.computeIoU(boxA, boxB);
      final enclosure = ObjectDetectionService.computeEnclosureRatio(boxA, boxB);

      expect(iou, greaterThan(0.5));
      expect(enclosure, closeTo(1.0, 0.01)); // boxB is 100% inside boxA
    });

    test('suppressOverlappingGenericObjects suppresses generic box when specific box occupies same space', () {
      final specificObj = DetectedObject(
        boundingBox: const Rect.fromLTWH(100, 100, 200, 200),
        labels: [Label(text: 'coffeemaker', confidence: 0.60, index: 0)],
        trackingId: 1,
      );
      final genericObj = DetectedObject(
        boundingBox: const Rect.fromLTWH(95, 95, 210, 210), // Almost identical overlapping area
        labels: [Label(text: 'home appliance', confidence: 0.95, index: 1)],
        trackingId: 2,
      );

      // Even if generic comes first with 95% confidence, it must be suppressed by specific
      final filtered = service.suppressOverlappingGenericObjects([genericObj, specificObj]);
      expect(filtered.length, 1);
      expect(filtered.first.trackingId, 1);
      expect(service.resolveBestDisplayLabel(filtered.first.labels), 'Coffeemaker');
    });

    test('suppressOverlappingGenericObjects preserves distinct non-overlapping objects', () {
      final objA = DetectedObject(
        boundingBox: const Rect.fromLTWH(10, 10, 50, 50),
        labels: [Label(text: 'coffee cup', confidence: 0.85, index: 0)],
        trackingId: 1,
      );
      final objB = DetectedObject(
        boundingBox: const Rect.fromLTWH(200, 200, 80, 80),
        labels: [Label(text: 'laptop', confidence: 0.90, index: 1)],
        trackingId: 2,
      );

      final filtered = service.suppressOverlappingGenericObjects([objA, objB]);
      expect(filtered.length, 2);
    });
  });
}

