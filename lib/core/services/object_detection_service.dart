import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';

/// On-device object detection and image labeling service utilizing Google ML Kit.
///
/// Supports both:
/// 1. High-specificity custom TensorFlow Lite (`.tflite`) models via [ImageLabeler]
///    and [LocalLabelerOptions] for granular labels (e.g., "French Fries", "Keyboard").
/// 2. Stream-based [ObjectDetector] as fallback for real-time bounding box classifications.
class ObjectDetectionService {
  ObjectDetectionService._();
  static final ObjectDetectionService instance = ObjectDetectionService._();

  ObjectDetector? _objectDetector;
  ImageLabeler? _imageLabeler;
  bool _isInitialized = false;
  bool _isCustomModelLoaded = false;
  bool get isCustomModelLoaded => _isCustomModelLoaded;

  bool _isProcessingLiveFrame = false;

  /// Candidate asset paths for custom fine-grained .tflite object detection models.
  static const List<String> candidateModelAssets = [
    'assets/models/object_labeler.tflite',
    'assets/models/custom_model.tflite',
  ];

  /// Initializes ML Kit models.
  Future<void> initialize({String? customModelAssetPath}) async {
    if (_isInitialized) return;

    // Purge any stale incompatible models from previous test runs
    try {
      final dir = await getApplicationSupportDirectory();
      final staleFile = File('${dir.path}/efficientdet_lite0.tflite');
      if (await staleFile.exists()) {
        await staleFile.delete();
      }
    } catch (_) {}

    // 1. Attempt to locate and copy custom .tflite model from Flutter assets
    String? localModelPath;
    if (customModelAssetPath != null) {
      localModelPath = await _copyAssetToLocalFile(customModelAssetPath);
    } else {
      for (final asset in candidateModelAssets) {
        localModelPath = await _copyAssetToLocalFile(asset);
        if (localModelPath != null) break;
      }
    }

    // 2. Initialize ObjectDetector with custom local model or default detector
    if (localModelPath != null) {
      try {
        final localOptions = LocalObjectDetectorOptions(
          mode: DetectionMode.stream,
          modelPath: localModelPath,
          classifyObjects: true,
          multipleObjects: true, // Detects objects across the scene reliably
          confidenceThreshold: 0.35, // Allows specific child classes (e.g. Laptop at ~0.45+) to pass
          maximumLabelsPerObject: 3, // Retrieves candidate labels so specific items can be selected
        );
        _objectDetector = ObjectDetector(options: localOptions);
        _isCustomModelLoaded = true;
        debugPrint(
          '[ObjectDetectionService] ✅ Successfully loaded custom fine-grained model: $localModelPath',
        );
      } catch (e) {
        debugPrint(
          '[ObjectDetectionService] ⚠️ Failed to initialize custom model ($e). Falling back to base ML Kit.',
        );
        _initDefaultObjectDetector();
      }
    } else {
      debugPrint(
        '[ObjectDetectionService] ℹ️ No custom model found in assets/models/. Using base ML Kit detector.',
      );
      _initDefaultObjectDetector();
    }

    // 3. Initialize fallback ImageLabeler for single-image crop inspections
    final defaultLabelerOptions = ImageLabelerOptions(confidenceThreshold: 0.4);
    _imageLabeler = ImageLabeler(options: defaultLabelerOptions);

    _isInitialized = true;
  }

  void _initDefaultObjectDetector() {
    final objectOptions = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: objectOptions);
    _isCustomModelLoaded = false;
  }

  /// Copies a bundled asset .tflite model to local app support storage.
  ///
  /// Native ML Kit (Android/iOS) cannot read directly from Flutter's asset bundle
  /// URI (`assets/...`). Copying it to disk once ensures 100% offline execution.
  Future<String?> _copyAssetToLocalFile(String assetPath) async {
    try {
      // 1. Verify asset exists in Flutter bundle first
      final ByteData byteData;
      try {
        byteData = await rootBundle.load(assetPath);
      } catch (_) {
        // Asset is not part of the active bundle
        return null;
      }

      final directory = await getApplicationSupportDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${directory.path}/$fileName');

      // 2. Write or refresh file if size differs or missing
      if (!await file.exists() || await file.length() != byteData.lengthInBytes) {
        await file.writeAsBytes(
          byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
          flush: true,
        );
      }
      return file.path;
    } catch (_) {
      // Asset failed to copy; fallback to default labeler.
      return null;
    }
  }

  /// Processes a live [CameraImage] frame and returns the detected object label
  /// whose bounding box contains the specified [normalizedCrosshair] point.
  ///
  /// If [normalizedCrosshair] is not provided, defaults to the frame center (0.5, 0.5).
  /// If no detected object contains the crosshair point, returns null.
  Future<String?> detectObjectAtCrosshairInFrame({
    required CameraImage image,
    Offset normalizedCrosshair = const Offset(0.5, 0.5),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return null;

      final crosshairPoint = Offset(
        image.width * normalizedCrosshair.dx.clamp(0.0, 1.0),
        image.height * normalizedCrosshair.dy.clamp(0.0, 1.0),
      );

      // Check ObjectDetector bounding boxes for spatial collision with crosshair
      if (_objectDetector != null) {
        final objects = await _objectDetector!.processImage(inputImage);
        for (final obj in objects) {
          if (obj.boundingBox.contains(crosshairPoint)) {
            if (obj.labels.isNotEmpty) {
              return _cleanObjectLabel(obj.labels.first.text);
            }
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Crops a Region of Interest (ROI) around [normalizedCrosshair] from [image]
  /// and returns the detected object label for that targeted region.
  ///
  /// [roiFactor] specifies what fraction of the shortest image edge the ROI box
  /// should span (default 0.35 = 35%, clamped between 224 and image dimensions).
  Future<String?> detectObjectInImageRoi({
    required ui.Image image,
    required Offset normalizedCrosshair,
    double roiFactor = 0.35,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();

      final double shortest = imgW < imgH ? imgW : imgH;
      final double boxSize = (shortest * roiFactor).clamp(224.0, shortest);

      final double centerX = (normalizedCrosshair.dx * imgW).clamp(0.0, imgW);
      final double centerY = (normalizedCrosshair.dy * imgH).clamp(0.0, imgH);

      double left = centerX - (boxSize / 2.0);
      double top = centerY - (boxSize / 2.0);

      if (left < 0) left = 0;
      if (top < 0) top = 0;
      if (left + boxSize > imgW) left = (imgW - boxSize).clamp(0.0, imgW);
      if (top + boxSize > imgH) top = (imgH - boxSize).clamp(0.0, imgH);

      final srcRect = Rect.fromLTWH(left, top, boxSize, boxSize);
      final dstRect = Rect.fromLTWH(0, 0, boxSize, boxSize);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(image, srcRect, dstRect, ui.Paint());
      final picture = recorder.endRecording();
      final croppedUiImage = await picture.toImage(boxSize.round(), boxSize.round());

      final byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);
      croppedUiImage.dispose();
      picture.dispose();

      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/gabeye_crosshair_roi.png');
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );

      final inputImage = InputImage.fromFilePath(tempFile.path);
      return await _processInputImage(inputImage);
    } catch (_) {
      return null;
    }
  }

  /// Processes a static image file (e.g. from gallery upload or freeze frame)
  /// and returns the detected object label.
  Future<String?> detectObjectInFilePath(String filePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      return await _processInputImage(inputImage);
    } catch (_) {
      return null;
    }
  }

  /// Processes a live [CameraImage] frame and returns the detected object label.
  Future<String?> detectObjectInFrame(CameraImage image) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return null;
      return await _processInputImage(inputImage);
    } catch (_) {
      return null;
    }
  }

  /// Unified processor prioritizing granular [ImageLabeler] over coarse [ObjectDetector].
  Future<String?> _processInputImage(InputImage inputImage) async {
    // Priority 1: Fine-grained ImageLabeler (Custom TFLite or 400+ label set)
    if (_imageLabeler != null) {
      try {
        final labels = await _imageLabeler!.processImage(inputImage);
        if (labels.isNotEmpty) {
          return _cleanObjectLabel(labels.first.label);
        }
      } catch (_) {}
    }

    // Priority 2: Fallback to ObjectDetector
    if (_objectDetector != null) {
      try {
        final objects = await _objectDetector!.processImage(inputImage);
        if (objects.isNotEmpty) {
          final firstObj = objects.first;
          if (firstObj.labels.isNotEmpty) {
            final topLabel = firstObj.labels.first.text;
            return _cleanObjectLabel(topLabel);
          }
        }
      } catch (_) {}
    }

    return null;
  }

  /// Formats raw model labels (e.g., "laptop" -> "Laptop", "cell phone" -> "Cell Phone").
  String cleanObjectLabel(String label) {
    if (label.isEmpty || label.contains('???')) return 'Object';
    // Take the first synonym before any comma delimiter
    final primary = label.split(',').first.trim();
    if (primary.isEmpty || primary.contains('???')) return 'Object';

    // Capitalize each word nicely
    return primary
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
        .join(' ');
  }

  String _cleanObjectLabel(String label) => cleanObjectLabel(label);

  /// Broad umbrella / parent category names that should be deprioritized in favor of specific child objects.
  static const Set<String> umbrellaCategories = {
    'electronic device',
    'consumer electronics',
    'home good',
    'office supplies',
    'kitchen appliance',
    'tableware',
    'footwear',
    'clothing',
    'container',
    'packaged goods',
    'personal care',
    'fashion accessory',
    'vehicle',
    'sports equipment',
    'musical instrument',
    'food',
    'furniture',
  };

  /// Canonical COCO-80 vocabulary mapping associating model labels and common
  /// synonyms to the standard 80 COCO categories.
  static const Map<String, String> coco80LabelMap = {
    // Electronics & Workspace (COCO: laptop, mouse, keyboard, tv, cell phone)
    'laptop': 'Laptop',
    'computer keyboard': 'Keyboard',
    'musical keyboard': 'Keyboard',
    'keyboard': 'Keyboard',
    'mouse': 'Mouse',
    'computer monitor': 'TV',
    'tv': 'TV',
    'television': 'TV',
    'cell phone': 'Cell Phone',
    'mobile phone': 'Cell Phone',
    'telephone': 'Cell Phone',

    // Furniture & Indoors (COCO: chair, couch, potted plant, bed, dining table, toilet)
    'chair': 'Chair',
    'armchair': 'Chair',
    'folding chair': 'Chair',
    'couch': 'Couch',
    'sofa': 'Couch',
    'bed': 'Bed',
    'dining table': 'Dining Table',
    'table': 'Dining Table',
    'coffee table': 'Dining Table',
    'kitchen & dining room table': 'Dining Table',
    'billiard table': 'Dining Table',
    'toilet': 'Toilet',
    'potted plant': 'Potted Plant',
    'houseplant': 'Potted Plant',

    // Kitchen & Appliances (COCO: bottle, wine glass, cup, fork, knife, spoon, bowl, microwave, oven, toaster, sink, refrigerator)
    'bottle': 'Bottle',
    'water bottle': 'Bottle',
    'vacuum flask': 'Bottle',
    'wine glass': 'Wine Glass',
    'cup': 'Cup',
    'coffee cup': 'Cup',
    'tumbler': 'Cup',
    'mug': 'Cup',
    'fork': 'Fork',
    'knife': 'Knife',
    'spoon': 'Spoon',
    'bowl': 'Bowl',
    'microwave': 'Microwave',
    'oven': 'Oven',
    'toaster': 'Toaster',
    'sink': 'Sink',
    'refrigerator': 'Refrigerator',

    // Food (COCO: banana, apple, sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake)
    'banana': 'Banana',
    'apple': 'Apple',
    'sandwich': 'Sandwich',
    'orange': 'Orange',
    'broccoli': 'Broccoli',
    'carrot': 'Carrot',
    'hot dog': 'Hot Dog',
    'pizza': 'Pizza',
    'donut': 'Donut',
    'doughnut': 'Donut',
    'cake': 'Cake',

    // Personal & Everyday (COCO: backpack, umbrella, handbag, tie, suitcase, book, clock, vase, scissors, teddy bear, hair drier, toothbrush)
    'backpack': 'Backpack',
    'umbrella': 'Umbrella',
    'handbag': 'Handbag',
    'purse': 'Handbag',
    'tie': 'Tie',
    'necktie': 'Tie',
    'suitcase': 'Suitcase',
    'luggage': 'Suitcase',
    'book': 'Book',
    'notebook': 'Book',
    'clock': 'Clock',
    'alarm clock': 'Clock',
    'vase': 'Vase',
    'scissors': 'Scissors',
    'teddy bear': 'Teddy Bear',
    'hair drier': 'Hair Drier',
    'toothbrush': 'Toothbrush',

    // Outdoor & Vehicles (COCO: person, bicycle, car, motorcycle, airplane, bus, train, truck, boat, traffic light, fire hydrant, stop sign, parking meter, bench)
    'person': 'Person',
    'man': 'Person',
    'woman': 'Person',
    'child': 'Person',
    'bicycle': 'Bicycle',
    'kid bike': 'Bicycle',
    'bike': 'Bicycle',
    'car': 'Car',
    'motorcycle': 'Motorcycle',
    'airplane': 'Airplane',
    'aeroplane': 'Airplane',
    'bus': 'Bus',
    'train': 'Train',
    'truck': 'Truck',
    'boat': 'Boat',
    'traffic light': 'Traffic Light',
    'fire hydrant': 'Fire Hydrant',
    'stop sign': 'Stop Sign',
    'parking meter': 'Parking Meter',
    'bench': 'Bench',

    // Animals (COCO: bird, cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe)
    'bird': 'Bird',
    'cat': 'Cat',
    'dog': 'Dog',
    'horse': 'Horse',
    'sheep': 'Sheep',
    'cow': 'Cow',
    'elephant': 'Elephant',
    'bear': 'Bear',
    'zebra': 'Zebra',
    'giraffe': 'Giraffe',

    // Sports (COCO: frisbee, skis, snowboard, sports ball, kite, baseball bat, baseball glove, skateboard, surfboard, tennis racket)
    'frisbee': 'Frisbee',
    'skis': 'Skis',
    'snowboard': 'Snowboard',
    'sports ball': 'Sports Ball',
    'football': 'Sports Ball',
    'soccer ball': 'Sports Ball',
    'basketball': 'Sports Ball',
    'kite': 'Kite',
    'baseball bat': 'Baseball Bat',
    'baseball glove': 'Baseball Glove',
    'skateboard': 'Skateboard',
    'surfboard': 'Surfboard',
    'tennis racket': 'Tennis Racket',
  };

  /// Selects the most specific [Label] from a list of detected [labels].
  ///
  /// Prioritizes specific items (e.g., "Laptop", "Computer keyboard", "Coffee cup", "Chair")
  /// over broad umbrella classifications (e.g., "Electronic device", "Tableware").
  Label? selectBestLabel(List<Label> labels) {
    if (labels.isEmpty) return null;
    if (labels.length == 1) return labels.first;

    // Search for the first specific, non-umbrella label
    for (final label in labels) {
      final textLower = label.text.toLowerCase().trim();
      if (!umbrellaCategories.contains(textLower) && !textLower.contains('???')) {
        return label;
      }
    }

    // Fall back to top label if all are umbrella categories
    return labels.first;
  }

  /// Resolves the optimal display label strictly mapped to the 80 COCO categories.
  ///
  /// Priority 1 (COCO-80 Whitelist): Searches candidates for a direct match or
  /// synonym within the standard 80 COCO categories.
  /// Priority 2: Returns the most specific non-umbrella child category.
  /// Priority 3: Fallback to the top label or 'Object'.
  String resolveBestDisplayLabel(List<Label> labels) {
    if (labels.isEmpty) return 'Object';

    // 1. Search candidate labels for a COCO-80 match
    for (final label in labels) {
      final cleanText = label.text.toLowerCase().trim();
      if (umbrellaCategories.contains(cleanText) || cleanText.contains('???')) {
        continue;
      }

      // Direct match
      final direct = coco80LabelMap[cleanText];
      if (direct != null) return direct;

      // Substring match for compound phrases (e.g. "laptop computer" -> "Laptop")
      for (final entry in coco80LabelMap.entries) {
        if (cleanText == entry.key ||
            cleanText.startsWith('${entry.key} ') ||
            cleanText.endsWith(' ${entry.key}') ||
            cleanText.contains(' ${entry.key} ')) {
          return entry.value;
        }
      }
    }

    // 2. Fall back to best non-umbrella specific label
    final best = selectBestLabel(labels);
    if (best != null) {
      return cleanObjectLabel(best.text);
    }

    return 'Object';
  }

  /// Finds the candidate [Label] that produced the best COCO-80 match, for confidence display.
  Label? findMatchedLabel(List<Label> labels) {
    if (labels.isEmpty) return null;
    final bestDisplayName = resolveBestDisplayLabel(labels);
    for (final label in labels) {
      final cleanText = label.text.toLowerCase().trim();
      if (umbrellaCategories.contains(cleanText) || cleanText.contains('???')) {
        continue;
      }
      if (coco80LabelMap[cleanText] == bestDisplayName) {
        return label;
      }
      for (final entry in coco80LabelMap.entries) {
        if ((cleanText == entry.key ||
             cleanText.startsWith('${entry.key} ') ||
             cleanText.endsWith(' ${entry.key}') ||
             cleanText.contains(' ${entry.key} ')) &&
            entry.value == bestDisplayName) {
          return label;
        }
      }
    }
    return selectBestLabel(labels) ?? labels.first;
  }

  /// Filters and sorts detected objects to retain only the top [maxObjects]
  /// most prominent items (based on bounding box area and center proximity).
  ///
  /// Eliminates distant background clutter, tiny sensor artifacts, and noise.
  List<DetectedObject> filterProminentObjects(
    List<DetectedObject> objects, {
    required Size frameSize,
    int maxObjects = 2,
    double minAreaFraction = 0.015,
  }) {
    if (objects.isEmpty) return [];

    final double totalArea = frameSize.width * frameSize.height;
    final double minArea = totalArea > 0 ? totalArea * minAreaFraction : 1600.0;
    final frameCenter = Offset(frameSize.width / 2.0, frameSize.height / 2.0);
    final double maxDistance = frameCenter.distance > 0 ? frameCenter.distance : 1.0;

    // 1. Filter out tiny artifacts / distant specks
    final candidates = objects.where((obj) {
      final box = obj.boundingBox;
      if (box.width < 40.0 || box.height < 40.0) return false;
      final area = box.width * box.height;
      return area >= minArea;
    }).toList();

    if (candidates.isEmpty) {
      // If all were small, fallback to the single largest object if above minimal noise floor
      final largest = objects.reduce((a, b) =>
          (a.boundingBox.width * a.boundingBox.height) >=
          (b.boundingBox.width * b.boundingBox.height) ? a : b);
      if (largest.boundingBox.width >= 32.0 && largest.boundingBox.height >= 32.0) {
        return [largest];
      }
      return [];
    }

    // 2. Score candidates by Area * Center Proximity Weight
    candidates.sort((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final distA = (a.boundingBox.center - frameCenter).distance;
      final weightA = 1.0 - (0.4 * (distA / maxDistance).clamp(0.0, 1.0));
      final scoreA = areaA * weightA;

      final areaB = b.boundingBox.width * b.boundingBox.height;
      final distB = (b.boundingBox.center - frameCenter).distance;
      final weightB = 1.0 - (0.4 * (distB / maxDistance).clamp(0.0, 1.0));
      final scoreB = areaB * weightB;

      return scoreB.compareTo(scoreA);
    });

    return candidates.take(maxObjects).toList();
  }

  /// Processes a live camera frame independently for real-time object detection mode.
  ///
  /// Uses an internal concurrency guard [_isProcessingLiveFrame] to drop late frames
  /// and sustain high frame-rate rendering without queuing latency.
  Future<List<DetectedObject>> processLiveFrame({
    required CameraImage image,
    required CameraDescription camera,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_objectDetector == null || _isProcessingLiveFrame) {
      return [];
    }

    _isProcessingLiveFrame = true;
    try {
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) {
        _isProcessingLiveFrame = false;
        return [];
      }

      final rawObjects = await _objectDetector!.processImage(inputImage);
      _isProcessingLiveFrame = false;

      // Recommended Step 3: Top-2 Prominence Filter (Reduces Visual Clutter & CPU)
      return filterProminentObjects(
        rawObjects,
        frameSize: Size(image.width.toDouble(), image.height.toDouble()),
        maxObjects: 2,
      );
    } catch (_) {
      _isProcessingLiveFrame = false;
      return [];
    }
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image, [CameraDescription? camera]) {
    try {
      final Uint8List bytes;
      if (image.planes.length == 1) {
        bytes = image.planes.first.bytes;
      } else {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        bytes = allBytes.done().buffer.asUint8List();
      }

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final int rotationDegrees = camera?.sensorOrientation ?? 0;
      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(rotationDegrees) ?? InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              (Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21);

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
    _imageLabeler?.close();
    _isInitialized = false;
  }
}
