# Custom TensorFlow Lite (.tflite) Models for GabEye

Place your custom `.tflite` model files in this directory (`assets/models/`).

## Supported Models
You can bundle fine-grained object detection models (such as quantized **EfficientDet-Lite0**, **MobileNet SSD v2**, or **COCO SSD**):

1. **Bundled Model**:
   - Currently bundled: `assets/models/object_labeler.tflite` (~3.6 MB, ML Kit compatible image classifier with fine-grained everyday classes)
   - Other supported candidate filenames:
     * `assets/models/ssd_mobilenet.tflite`
     * `assets/models/custom_model.tflite`
   - Ensure any alternative `.tflite` model has embedded metadata (TFLite Model Metadata with label map).

2. **Asset Declaration (`pubspec.yaml`)**:
   `assets/models/` is already declared under `assets:` in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/models/
   ```

3. **Android AAPT Compression**:
   The AAPT uncompressed asset rule is configured in `android/app/build.gradle.kts`:
   ```kotlin
   aaptOptions {
       noCompress("tflite")
   }
   ```

4. **Runtime Loading**:
   On app launch, `ObjectDetectionService.instance.initialize()`:
   - Checks for `assets/models/object_labeler.tflite` (or `custom_model.tflite`).
   - Copies it to the local device application support storage (offline-first).
   - Initializes `LocalObjectDetectorOptions(modelPath: localModelPath, mode: DetectionMode.stream, classifyObjects: true, multipleObjects: true)`.
   - If no custom model is found, it cleanly falls back to the standard `ObjectDetectorOptions`.
