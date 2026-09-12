import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// On-device object detection service utilizing Google ML Kit.
class ObjectDetectionService {
  ObjectDetectionService._();
  static final ObjectDetectionService instance = ObjectDetectionService._();

  ObjectDetector? _objectDetector;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;

    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: false,
    );
    _objectDetector = ObjectDetector(options: options);
    _isInitialized = true;
  }

  /// Processes a CameraImage frame plane and returns detected object label.
  Future<String?> detectObjectInFrame(CameraImage image) async {
    if (!_isInitialized || _objectDetector == null) {
      initialize();
    }

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return null;

      final objects = await _objectDetector!.processImage(inputImage);
      if (objects.isNotEmpty) {
        final firstObj = objects.first;
        if (firstObj.labels.isNotEmpty) {
          final topLabel = firstObj.labels.first.text;
          return _cleanObjectLabel(topLabel);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _cleanObjectLabel(String label) {
    if (label.isEmpty) return 'Object';
    final capitalized = label[0].toUpperCase() + label.substring(1).toLowerCase();
    return capitalized;
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation = InputImageRotation.rotation0deg;
      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : image.width,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _objectDetector?.close();
    _isInitialized = false;
  }
}
