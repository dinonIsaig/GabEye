import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gabeye/core/services/auditory_feedback_service.dart';
import 'package:gabeye/core/services/camera_frame_ingestion_service.dart';
import 'package:gabeye/core/services/capture_pixel_sampler_service.dart';
import 'package:gabeye/core/services/gallery_service.dart';
import 'package:gabeye/core/services/object_detection_service.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/core/widgets/daltonization_shader_widget.dart';
import 'package:gabeye/features/home/widgets/assistance_mode_modal.dart';
import 'package:gabeye/features/home/widgets/camera_permission_modal.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import 'package:gabeye/features/knn/services/knn_isolate_worker.dart';

enum PresetMode { customized, protan, deutan, tritan, off }
enum CameraRealtimeMode { daltonization, knn }

class VisionLensScreen extends StatefulWidget {
  const VisionLensScreen({super.key});

  /// Global notifier to tell HomeScreen to expand viewport & hide headers/footers in full/split-screen mode
  static final ValueNotifier<bool> isFullScreenNotifier = ValueNotifier<bool>(false);

  @override
  State<VisionLensScreen> createState() => _VisionLensScreenState();
}

class _VisionLensScreenState extends State<VisionLensScreen> {
  PresetMode _selectedPreset = PresetMode.customized;
  bool _isRemapActive = true;
  bool _isCameraPermissionGranted = false;
  bool _showCalibrationSlider = false;

  CameraController? _cameraController;
  bool _isCameraInitializing = false;

  // Flashlight Torch, Zoom, & Split Screen Full View state
  bool _isTorchOn = false;
  double _currentZoomLevel = 1.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 5.0;
  bool _showZoomSlider = false;
  bool _isSplitScreenView = false;

  // Camera Realtime Mode (Daltonization vs. KNN Color Identification)
  CameraRealtimeMode _activeCameraMode = CameraRealtimeMode.daltonization;
  bool _isUploadedIdentifyMode = false;

  // KNN & ML Kit Object Classification State
  List<IsccNbsColorEntry> _isccDataset = [];
  String _currentIdentifiedColor = 'Vivid Red';
  String? _currentIdentifiedObject;
  bool _isKnnStreamActive = false;

  // ---------------------------------------------------------------------------
  // Freeze-Frame Capture Inspection Mode State
  // ---------------------------------------------------------------------------
  // Set to true when the shutter is tapped in KNN mode; false while live scan.
  bool _isFreezeFrameActive = false;

  // Raw JPEG bytes and decoded dart:ui.Image of the captured still frame.
  Uint8List? _capturedFrameBytes;
  ui.Image? _capturedUiImage;

  // Actual pixel dimensions of the captured image (used for coordinate mapping).
  Size _capturedImageSize = Size.zero;

  // Crosshair position in normalised image-space coordinates ([0,1] × [0,1]).
  // (0.5, 0.5) = image centre.  Updated on every tap/drag inside the viewport.
  Offset _crosshairNorm = const Offset(0.5, 0.5);

  // Latest KNN result from crosshair pixel sampling.
  KnnIsolateResult? _freezeFrameColorResult;

  bool _isSamplingPixel = false; // guard against overlapping async sample calls

  // Uploaded photo state, decoded ui.Image, & notification timer
  Uint8List? _uploadedImageBytes;
  ui.Image? _uploadedUiImage;
  String? _uploadedFileName;
  bool _isDisplayingUploadedImage = false;
  bool _showUploadedNotification = false;
  Timer? _uploadedNotificationTimer;

  Future<void> _toggleTorch() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final newMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
        await _cameraController!.setFlashMode(newMode);
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      } catch (_) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } else {
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    }
  }

  Future<void> _setZoomLevel(double level) async {
    setState(() {
      _currentZoomLevel = level;
    });
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setZoomLevel(level);
      } catch (_) {}
    }
  }

  Future<void> _handleUploadedPhotoSavePrompt(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_alt_rounded, color: colors.primary),
            const SizedBox(width: 8),
            const Text('Save Photo?'),
          ],
        ),
        content: const Text(
          'Would you like to save this color-enhanced Daltonized photo to your device gallery?',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  bool success = false;
                  if (_uploadedImageBytes != null) {
                    final type = _getEffectiveShaderType();
                    final intensity = _getEffectiveShaderIntensity();
                    final fallbackMatrix = _buildCameraColorMatrix(type, intensity);

                    // Apply offscreen Daltonization filter so the saved image matches what the user sees on screen
                    final filteredBytes = await GalleryService.applyDaltonizationShaderToImageBytes(
                      _uploadedImageBytes!,
                      shaderType: type,
                      intensity: intensity,
                      fallbackMatrix: fallbackMatrix,
                    );

                    success = await GalleryService.saveImageToGallery(
                      filteredBytes,
                      filename: _uploadedFileName,
                    );
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Saved color-enhanced Daltonized photo to device Gallery.'
                              : 'Failed to save photo to Gallery.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'Save to Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: colors.onSurfaceVariant,
                  side: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Just View Result',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _captureLiveDaltonizedPhoto(BuildContext context) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        final rawBytes = await photo.readAsBytes();

        final type = _getEffectiveShaderType();
        final intensity = _getEffectiveShaderIntensity();
        final matrix = _buildCameraColorMatrix(type, intensity);

        // Apply Daltonization filter to captured camera frame bytes before saving to device gallery
        final filteredBytes = await GalleryService.applyDaltonizationShaderToImageBytes(
          rawBytes,
          shaderType: type,
          intensity: intensity,
          fallbackMatrix: matrix,
        );

        final success = await GalleryService.saveImageToGallery(
          filteredBytes,
          filename: photo.name,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Captured & saved Daltonized photo with filter applied!'
                  : 'Failed to save captured photo to Gallery.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving photo to gallery: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera is not initialized.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initKnnServices();
  }

  Future<void> _initKnnServices() async {
    final dataset = await IsccNbsColorDataset.loadDataset();
    await AuditoryFeedbackService.instance.initialize();
    ObjectDetectionService.instance.initialize();
    if (mounted) {
      setState(() {
        _isccDataset = dataset;
      });
    }
  }

  @override
  void dispose() {
    _stopKnnFrameStream();
    ObjectDetectionService.instance.dispose();
    AuditoryFeedbackService.instance.stop();
    _cameraController?.dispose();
    _uploadedNotificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startKnnFrameStream() async {
    if (_cameraController != null && _cameraController!.value.isInitialized && !_isKnnStreamActive) {
      try {
        _isKnnStreamActive = true;
        await _cameraController!.startImageStream((CameraImage image) async {
          if (_activeCameraMode == CameraRealtimeMode.knn && mounted) {
            final result = await CameraFrameIngestionService.instance.processCameraFrame(
              image: image,
              dataset: _isccDataset,
            );
            if (result != null && mounted) {
              final objectLabel = await ObjectDetectionService.instance.detectObjectInFrame(image);
              setState(() {
                _currentIdentifiedColor = result.colorName;
                _currentIdentifiedObject = objectLabel;
              });
            }
          }
        });
      } catch (_) {
        _isKnnStreamActive = false;
      }
    }
  }

  Future<void> _stopKnnFrameStream() async {
    if (_cameraController != null && _cameraController!.value.isInitialized && _isKnnStreamActive) {
      try {
        await _cameraController!.stopImageStream();
        _isKnnStreamActive = false;
      } catch (_) {
        _isKnnStreamActive = false;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Freeze-Frame Capture Methods
  // ---------------------------------------------------------------------------

  /// Called when the user taps the shutter button **while in KNN live-scan mode**.
  ///
  /// 1. Takes a still JPEG from the camera controller.
  /// 2. Stops the KNN frame stream to release GPU/CPU load.
  /// 3. Decodes the JPEG into a [ui.Image] for per-pixel access.
  /// 4. Transitions the UI to freeze-frame inspection mode.
  /// 5. Samples the centre pixel strictly for visual UI overlay (no automatic TTS).
  Future<void> _captureKnnFreezeFrame(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      // Step 1: Capture still JPEG from the live feed.
      final XFile photo = await _cameraController!.takePicture();
      final Uint8List rawBytes = await photo.readAsBytes();

      // Step 2: Stop the live KNN stream — we no longer need frame callbacks.
      await _stopKnnFrameStream();

      // Step 3: Decode JPEG bytes into a dart:ui.Image for O(1) pixel access.
      final ui.Codec codec = await ui.instantiateImageCodec(rawBytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image decodedImage = frame.image;

      if (!mounted) return;

      // Step 4: Transition to freeze-frame inspection mode.
      setState(() {
        _capturedFrameBytes = rawBytes;
        _capturedUiImage = decodedImage;
        _capturedImageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );
        // Reset crosshair to image centre on every new capture.
        _crosshairNorm = const Offset(0.5, 0.5);
        _isFreezeFrameActive = true;
      });

      // Step 5: Sample the centre pixel strictly for visual UI overlay (no automatic TTS).
      await _sampleCrosshairPixel();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not capture frame: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Discards the frozen frame and resumes the live KNN camera scan.
  ///
  /// Safe to call even if [_isFreezeFrameActive] is already false.
  Future<void> _resumeLiveKnnScan() async {
    // Free the decoded ui.Image (unmanaged native memory — must be disposed).
    _capturedUiImage?.dispose();

    setState(() {
      _isFreezeFrameActive = false;
      _capturedFrameBytes = null;
      _capturedUiImage = null;
      _capturedImageSize = Size.zero;
      _freezeFrameColorResult = null;
      _isSamplingPixel = false;
    });

    // Restart the live KNN image stream.
    await _startKnnFrameStream();
  }

  /// Called on every tap or drag update inside the freeze-frame viewport.
  ///
  /// [localPosition] is the touch point in the **render box's local coordinates**
  /// (i.e. relative to the top-left of the image display area).
  /// [renderBoxSize] is the actual rendered size of the image container widget.
  ///
  /// The method:
  ///   1. Maps screen coordinates → normalised image coordinates accounting for
  ///      [BoxFit.contain] letterboxing / pillarboxing.
  ///   2. Clamps the result to [0, 1].
  ///   3. Triggers async pixel sampling for real-time visual UI update (no TTS).
  void _onCrosshairInteraction({
    required Offset localPosition,
    required Size renderBoxSize,
  }) {
    final Offset norm = _screenTouchToNormalisedImageCoord(
      localPosition: localPosition,
      renderBoxSize: renderBoxSize,
      imagePixelSize: _capturedImageSize,
    );

    setState(() {
      _crosshairNorm = norm;
    });

    // Sample pixel strictly for real-time visual readout update (no TTS).
    _sampleCrosshairPixel();
  }

  /// Converts a touch point inside the image container to a normalised
  /// [0, 1] × [0, 1] coordinate within the **actual image content**,
  /// accounting for [BoxFit.contain] letterboxing/pillarboxing.
  ///
  /// ### Coordinate Mapping Algorithm
  /// BoxFit.contain scales the image uniformly so it fits within the container
  /// while preserving aspect ratio. This creates empty bands on either the
  /// horizontal (pillarbox) or vertical (letterbox) edges.
  ///
  ///   scaleX = containerW / imageW
  ///   scaleY = containerH / imageH
  ///   scale  = min(scaleX, scaleY)          ← the constraining axis
  ///   renderedW = imageW * scale
  ///   renderedH = imageH * scale
  ///   offsetX = (containerW - renderedW) / 2  ← pillarbox band width
  ///   offsetY = (containerH - renderedH) / 2  ← letterbox band height
  ///
  /// Touch point mapped to image-space:
  ///   normX = (touchX - offsetX) / renderedW  → clamped [0, 1]
  ///   normY = (touchY - offsetY) / renderedH  → clamped [0, 1]
  static Offset _screenTouchToNormalisedImageCoord({
    required Offset localPosition,
    required Size renderBoxSize,
    required Size imagePixelSize,
  }) {
    if (imagePixelSize.isEmpty || renderBoxSize.isEmpty) {
      return const Offset(0.5, 0.5);
    }

    final double containerW = renderBoxSize.width;
    final double containerH = renderBoxSize.height;
    final double imageW = imagePixelSize.width;
    final double imageH = imagePixelSize.height;

    // Scale factor for BoxFit.contain (the smaller axis drives the scale).
    final double scale = (containerW / imageW).clamp(0.0, containerH / imageH);
    // Alternatively: min(containerW / imageW, containerH / imageH)
    final double renderedW = imageW * scale;
    final double renderedH = imageH * scale;

    // Letterbox / pillarbox offsets (empty band on each side).
    final double offsetX = (containerW - renderedW) / 2.0;
    final double offsetY = (containerH - renderedH) / 2.0;

    // Map touch position into [0, 1] within the rendered image rect.
    final double normX = ((localPosition.dx - offsetX) / renderedW).clamp(0.0, 1.0);
    final double normY = ((localPosition.dy - offsetY) / renderedH).clamp(0.0, 1.0);

    return Offset(normX, normY);
  }

  /// Samples the pixel at [_crosshairNorm] within [_capturedUiImage],
  /// updating [_freezeFrameColorResult] and [_currentIdentifiedColor] strictly for
  /// real-time visual UI overlay rendering without triggering TTS.
  Future<void> _sampleCrosshairPixel() async {
    if (_capturedUiImage == null || _isccDataset.isEmpty || _isSamplingPixel) return;
    _isSamplingPixel = true;

    // Convert normalised coordinates to actual pixel indices.
    final int px = (_crosshairNorm.dx * (_capturedImageSize.width - 1)).round();
    final int py = (_crosshairNorm.dy * (_capturedImageSize.height - 1)).round();

    try {
      final KnnIsolateResult result = await CapturePixelSamplerService.samplePixelAt(
        image: _capturedUiImage!,
        pixelX: px,
        pixelY: py,
        dataset: _isccDataset,
      );

      if (mounted) {
        setState(() {
          _freezeFrameColorResult = result;
          _currentIdentifiedColor = result.colorName;
        });
      }
    } finally {
      _isSamplingPixel = false;
    }
  }

  Future<void> _requestCameraPermission() async {
    final granted = await showCameraPermissionModal(context);
    if (granted == true && mounted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      await _initializeCameraDevice();
    }
  }

  Future<void> _initializeCameraDevice() async {
    if (_isCameraInitializing) return;
    setState(() => _isCameraInitializing = true);
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty && mounted) {
        final controller = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await controller.initialize();
        if (mounted) {
          setState(() {
            _cameraController = controller;
            _isCameraInitializing = false;
          });
        }
      } else {
        if (mounted) setState(() => _isCameraInitializing = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isCameraInitializing = false);
    }
  }

  Future<void> _pickUploadedPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        final mode = await showAssistanceModeModal(context);
        if (mode == null || !mounted) return;

        final bytes = await picked.readAsBytes();
        _uploadedNotificationTimer?.cancel();
        setState(() {
          _uploadedImageBytes = bytes;
          _uploadedUiImage = null; // will be set after decode
          _uploadedFileName = picked.name;
          _isDisplayingUploadedImage = true;
          _showUploadedNotification = true;
          if (mode == AssistanceMode.remapColor) {
            _isRemapActive = true;
            _isUploadedIdentifyMode = false;
          } else {
            _isRemapActive = false;
            _isUploadedIdentifyMode = true;
          }
        });
        await _decodeUploadedImage(bytes);
        _uploadedNotificationTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showUploadedNotification = false;
            });
          }
        });

        if (mode == AssistanceMode.remapColor && mounted) {
          await _handleUploadedPhotoSavePrompt(context);
        }
      }
    } catch (e) {
      // Fallback sample image if running in test environment or gallery picking is unavailable
      if (mounted) {
        final mode = await showAssistanceModeModal(context);
        if (mode == null || !mounted) return;
        _uploadedNotificationTimer?.cancel();
        setState(() {
          _isDisplayingUploadedImage = true;
          _showUploadedNotification = true;
          if (mode == AssistanceMode.remapColor) {
            _isRemapActive = true;
            _isUploadedIdentifyMode = false;
          } else {
            _isRemapActive = false;
            _isUploadedIdentifyMode = true;
          }
        });
        _uploadedNotificationTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _showUploadedNotification = false;
            });
          }
        });
        if (mode == AssistanceMode.remapColor && mounted) {
          await _handleUploadedPhotoSavePrompt(context);
        }
      }
    }
  }

  Future<void> _decodeUploadedImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _uploadedUiImage = frame.image;
      });
      if (_isUploadedIdentifyMode && _isccDataset.isNotEmpty) {
        final rawDatasetJson = _isccDataset.map((e) => e.toJson()).toList();
        final request = KnnIsolateRequest(
          pixelBuffer: bytes,
          width: frame.image.width,
          height: frame.image.height,
          rawDatasetJson: rawDatasetJson,
        );
        final result = await KnnIsolateWorker.processRoiInIsolate(request);
        if (mounted) {
          setState(() {
            _currentIdentifiedColor = result.colorName;
            _currentIdentifiedObject = 'Uploaded Image';
          });
        }
      }
    }
  }

  void _switchToRealtimeCameraRemapping() {
    _uploadedNotificationTimer?.cancel();
    _stopKnnFrameStream();
    setState(() {
      _uploadedImageBytes = null;
      _uploadedUiImage = null;
      _uploadedFileName = null;
      _isDisplayingUploadedImage = false;
      _showUploadedNotification = false;
      _isUploadedIdentifyMode = false;
      _isRemapActive = true;
      _activeCameraMode = CameraRealtimeMode.daltonization;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cleared image. Active real-time LMS Daltonization enabled.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  double _getEffectiveShaderType() {
    if (!_isRemapActive || _selectedPreset == PresetMode.off) {
      return 3.0; // Normal pass-through
    }
    switch (_selectedPreset) {
      case PresetMode.customized:
        return VisionProfileService.instance.shaderType;
      case PresetMode.protan:
        return 0.0;
      case PresetMode.deutan:
        return 1.0;
      case PresetMode.tritan:
        return 2.0;
      case PresetMode.off:
        return 3.0;
    }
  }

  double _getEffectiveShaderIntensity() {
    if (!_isRemapActive || _selectedPreset == PresetMode.off) {
      return 0.0;
    }
    switch (_selectedPreset) {
      case PresetMode.customized:
        return VisionProfileService.instance.shaderIntensity;
      case PresetMode.protan:
      case PresetMode.deutan:
      case PresetMode.tritan:
        return 1.0;
      case PresetMode.off:
        return 0.0;
    }
  }

  /// Builds the 4×5 ColorFilter matrix for the live camera path.
  /// Uses Machado (2009) daltonization projection targets,
  /// interpolated by [intensity] toward the identity matrix.
  List<double> _buildCameraColorMatrix(double shaderType, double intensity) {
    // Identity matrix (pass-through)
    const identity = <double>[
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];

    if (shaderType >= 2.5 || intensity <= 0.01) return identity;

    final double k = intensity.clamp(0.0, 1.0);
    List<double> target;

    if (shaderType < 0.5) {
      // Protanopia: Shift lost red into Green (0.7x) & Blue (1.0x)
      target = [
        1.0,      0.0,       0.0,      0.0, 0.0,
        0.593400, 0.263192,  0.143408, 0.0, 0.0,
        0.847714, -1.052583, 1.204868, 0.0, 0.0,
        0.0,      0.0,       0.0,      1.0, 0.0,
      ];
    } else if (shaderType < 1.5) {
      // Deuteranopia: Shift lost green into Red (1.0x) & Blue (0.7x)
      target = [
        0.717721,  0.322233, -0.039954, 0.0, 0.0,
        0.0,       1.0,       0.0,      0.0, 0.0,
       -0.197595,  0.225563,  0.972032, 0.0, 0.0,
        0.0,       0.0,       0.0,      1.0, 0.0,
      ];
    } else {
      // Tritanopia: Shift lost blue into Red (1.0x) & Green (0.7x)
      target = [
        0.995267, -0.691367,  0.696100, 0.0, 0.0,
       -0.003313,  0.516043,  0.487270, 0.0, 0.0,
        0.0,       0.0,       1.0,      0.0, 0.0,
        0.0,       0.0,       0.0,      1.0, 0.0,
      ];
    }

    return List.generate(20, (i) {
      final identityVal = (i % 6 == 0) ? 1.0 : 0.0;
      return identityVal * (1.0 - k) + target[i] * k;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VisionProfileService.instance,
      builder: (context, profile, _) {
        return Column(
          children: [
            // Top Quick Preset Selector Bar
            _buildTopPresetSelectorBar(context),

            // Camera Viewport & Floating Control Bar
            Expanded(
              child: _buildCameraViewport(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopPresetSelectorBar(BuildContext context) {
    if (_isSplitScreenView) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ValueListenableBuilder(
        valueListenable: VisionProfileService.instance,
        builder: (context, result, _) {
          const customLabel = 'Recommended';

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildPresetChip(
                  mode: PresetMode.customized,
                  label: customLabel,
                  colors: colors,
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  mode: PresetMode.protan,
                  label: 'Protan',
                  colors: colors,
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  mode: PresetMode.deutan,
                  label: 'Deutan',
                  colors: colors,
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  mode: PresetMode.tritan,
                  label: 'Tritan',
                  colors: colors,
                ),
                const SizedBox(width: 8),
                _buildPresetChip(
                  mode: PresetMode.off,
                  label: 'Off',
                  colors: colors,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip({
    required PresetMode mode,
    required String label,
    required ColorScheme colors,
  }) {
    final isSelected = _selectedPreset == mode;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedPreset = mode;
            if (mode != PresetMode.customized) {
              _showCalibrationSlider = false;
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : colors.onSurface,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraViewport(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget viewportContent = _isFreezeFrameActive && _capturedFrameBytes != null
        // ── Freeze-Frame Inspection Mode ──────────────────────────────────────
        // Displayed when the user taps the shutter in KNN mode. Shows the still
        // captured image with a draggable crosshair overlay.
        ? _buildFreezeFrameInspectionView(context, colors)
        : (_isSplitScreenView
            ? _buildSplitScreenViewport(context, colors)
            : (_isDisplayingUploadedImage
                // Uploaded photo: pass the decoded ui.Image directly to the shader.
                ? (_uploadedUiImage != null
                    ? DaltonizationShaderWidget(
                        customType: _getEffectiveShaderType(),
                        intensity: _getEffectiveShaderIntensity(),
                        image: _uploadedUiImage!,
                      )
                    : const Center(child: CircularProgressIndicator()))
                : (_isCameraPermissionGranted
                    // In KNN mode, display natural un-filtered camera preview. Otherwise apply ColorFiltered Daltonization pass.
                    ? (_activeCameraMode == CameraRealtimeMode.knn
                        ? _buildCameraPreviewWidget(colors)
                        : ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _buildCameraColorMatrix(
                                _getEffectiveShaderType(),
                                _getEffectiveShaderIntensity(),
                              ),
                            ),
                            child: _buildCameraPreviewWidget(colors),
                          ))
                    : InkWell(
                        onTap: _requestCameraPermission,
                        child: Container(
                          color: colors.surfaceContainerHighest,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Vision Lens Access Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to allow camera access and enable real-time LMS Daltonization color remapping.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _requestCameraPermission,
                            icon: const Icon(Icons.security_rounded, size: 18, color: Colors.white),
                            label: const Text(
                              'Allow Camera Access',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))));

    return Stack(
      children: [
        // Viewport: Uploaded photo or Realtime Hardware Camera Feed through GLSL LMS Daltonization Shader
        Positioned.fill(child: viewportContent),

        // Indicator Chip when displaying uploaded photo
        if (_isDisplayingUploadedImage && !_isSplitScreenView)
          Positioned(
            top: 16,
            left: 20,
            child: AnimatedOpacity(
              opacity: _showUploadedNotification ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isUploadedIdentifyMode ? Icons.palette_outlined : Icons.image,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isUploadedIdentifyMode
                          ? 'Identify Color Mode (${_uploadedFileName ?? "Selected Image"})'
                          : 'Remap Color Mode (${_uploadedFileName ?? "Selected Image"})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Indicator Chip when Live Camera is in KNN Color Identification Mode
        // Hidden during freeze-frame (the freeze-frame view has its own status badge).
        if (!_isDisplayingUploadedImage && !_isFreezeFrameActive &&
            _activeCameraMode == CameraRealtimeMode.knn && !_isSplitScreenView)
          Positioned(
            top: 16,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.primary, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, size: 14, color: colors.primary),
                  const SizedBox(width: 6),
                  const Text(
                    'KNN Color Identification (Active)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Precision Pinpoint Dot ROI Target Overlay when in KNN / Identify Mode
        // Hidden during freeze-frame; the interactive crosshair in the freeze-frame
        // view replaces this static centre-only overlay.
        if (!_isFreezeFrameActive &&
            (_activeCameraMode == CameraRealtimeMode.knn || _isUploadedIdentifyMode) &&
            !_isSplitScreenView &&
            (_isDisplayingUploadedImage || _isCameraPermissionGranted))
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: SizedBox(
                  width: 160,
                  height: 120,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Center Pinpoint Target Ring & Dot
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.2),
                          border: Border.all(color: colors.primary, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      // Crosshair Tick Lines
                      Positioned(
                        top: 28,
                        child: Container(width: 1.5, height: 10, color: colors.primary),
                      ),
                      Positioned(
                        bottom: 48,
                        child: Container(width: 1.5, height: 10, color: colors.primary),
                      ),
                      Positioned(
                        left: 48,
                        child: Container(width: 10, height: 1.5, color: colors.primary),
                      ),
                      Positioned(
                        right: 48,
                        child: Container(width: 10, height: 1.5, color: colors.primary),
                      ),
                      // Identified Color & Object Badge below pinpoint target
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.primary.withValues(alpha: 0.6)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _currentIdentifiedObject != null && _currentIdentifiedObject!.isNotEmpty
                                  ? '$_currentIdentifiedColor ($_currentIdentifiedObject)'
                                  : _currentIdentifiedColor,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Vertically Centered Right-Side Floating Control Stack
        Positioned(
          top: 0,
          bottom: 0,
          right: 16,
          child: Center(
            child: _buildRightSideFloatingToolbar(context),
          ),
        ),

        // Vertically Centered Zoom Slider Overlay (toggled by Zoom button)
        if (_showZoomSlider)
          Positioned(
            top: 0,
            bottom: 0,
            right: 76,
            child: Center(
              child: SizedBox(
                width: 240,
                child: _buildZoomSliderOverlay(context),
              ),
            ),
          ),

        // Floating Calibration Slider Overlay (only when Customized preset and toggled)
        if (_selectedPreset == PresetMode.customized && _showCalibrationSlider)
          Positioned(
            left: 20,
            right: 20,
            bottom: 140,
            child: _buildCalibrationSliderOverlay(context),
          ),

        // Standalone Floating Open-Triangle Button (Sitting between bottom action bar and calibration container)
        if (_selectedPreset == PresetMode.customized)
          Positioned(
            left: 0,
            right: 0,
            bottom: 82,
            child: Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showCalibrationSlider = !_showCalibrationSlider;
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.65)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: _showCalibrationSlider ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: 36,
                      height: 20,
                      child: CustomPaint(
                        painter: OpenTrianglePainter(
                          color: colors.primary,
                          strokeWidth: 3.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Transparent Floating Action Card (Upload, Center Shutter Ring, Remap/Live Camera)
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: _buildTransparentFloatingActionCard(context),
        ),
      ],
    );
  }



  // ---------------------------------------------------------------------------
  // Freeze-Frame Inspection View
  // ---------------------------------------------------------------------------

  /// Builds the full-screen still-image inspection UI with:
  ///   - The captured image displayed with [BoxFit.contain] (preserves aspect ratio).
  ///   - An interactive [GestureDetector] for tap and drag crosshair repositioning.
  ///   - A [CustomPaint] overlay drawing the draggable crosshair and colour badge.
  ///   - A "Resume Live Scan" pill button at the bottom to exit freeze mode.
  ///   - A status badge at the top indicating freeze-frame mode.
  Widget _buildFreezeFrameInspectionView(BuildContext context, ColorScheme colors) {
    final Uint8List bytes = _capturedFrameBytes!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size containerSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // ── Still Image ──────────────────────────────────────────
            Positioned.fill(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                // Disable gapless playback to ensure the image renders immediately.
                gaplessPlayback: false,
              ),
            ),

            // ── Interactive Crosshair Gesture Layer ─────────────────────
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  _onCrosshairInteraction(
                    localPosition: details.localPosition,
                    renderBoxSize: containerSize,
                  );
                },
                onPanUpdate: (details) {
                  _onCrosshairInteraction(
                    localPosition: details.localPosition,
                    renderBoxSize: containerSize,
                  );
                },
                // Visual crosshair and color readout badge rendered directly over the image.
                child: CustomPaint(
                  painter: FreezeFrameCrosshairPainter(
                    normPosition: _crosshairNorm,
                    imageSize: _capturedImageSize,
                    containerSize: containerSize,
                    colorResult: _freezeFrameColorResult,
                    accentColor: colors.primary,
                  ),
                  size: containerSize,
                ),
              ),
            ),

            // ── Freeze-Frame Status Badge (top-left) ────────────────────
            Positioned(
              top: 16,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 7),
                    Text(
                      'Freeze-Frame • Tap or drag to inspect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCameraPreviewWidget(ColorScheme colors) {
    if (_isCameraInitializing) {
      return Container(
        color: colors.surfaceContainer,
        child: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 720,
          height: _cameraController!.value.previewSize?.width ?? 1280,
          child: CameraPreview(_cameraController!),
        ),
      );
    }

    // High-quality sample scene fallback
    return Image.asset(
      'assets/images/gabeye_cover.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: colors.surfaceContainer,
        child: Center(
          child: Icon(Icons.videocam, size: 64, color: colors.primary),
        ),
      ),
    );
  }

  Widget _buildTransparentFloatingActionCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.75);

    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Upload Button
              InkWell(
                onTap: _pickUploadedPhoto,
                splashColor: colors.primary.withValues(alpha: 0.15),
                highlightColor: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.collections_outlined,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Center Circular Shutter Ring
              GestureDetector(
                onTap: () {
                  if (_isDisplayingUploadedImage) {
                    // When viewing an uploaded image: clear it and return to realtime.
                    _switchToRealtimeCameraRemapping();
                  } else if (!_isCameraPermissionGranted) {
                    // Request permission if not yet granted.
                    _requestCameraPermission();
                  } else if (_isFreezeFrameActive) {
                    // Already in freeze-frame inspection: tapping shutter again
                    // resumes the live KNN scan (retake behaviour).
                    _resumeLiveKnnScan();
                  } else if (_activeCameraMode == CameraRealtimeMode.knn) {
                    // KNN live scan mode: freeze the current frame for inspection.
                    _captureKnnFreezeFrame(context);
                  } else {
                    // Daltonization mode: existing save-to-gallery behaviour.
                    _captureLiveDaltonizedPhoto(context);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      // Border pulses with brand primary when in freeze-frame inspection mode.
                      color: colors.primary,
                      width: _isFreezeFrameActive ? 5 : 4,
                    ),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Fill uses brand primary when frozen or when remapping is active.
                        color: _isFreezeFrameActive
                            ? colors.primary
                            : (_isRemapActive ? colors.primary : colors.surfaceContainerHighest),
                      ),
                      child: _isFreezeFrameActive
                          ? const Icon(Icons.replay_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ),
              ),

              // Remap / Realtime Mode Switcher Button
              InkWell(
                onTap: () {
                  if (_isDisplayingUploadedImage) {
                    _switchToRealtimeCameraRemapping();
                  } else {
                    final nextMode = _activeCameraMode == CameraRealtimeMode.daltonization
                        ? CameraRealtimeMode.knn
                        : CameraRealtimeMode.daltonization;
                    setState(() {
                      _activeCameraMode = nextMode;
                      if (nextMode == CameraRealtimeMode.knn) {
                        _isSplitScreenView = false;
                        VisionLensScreen.isFullScreenNotifier.value = false;
                      }
                    });
                    if (nextMode == CameraRealtimeMode.knn) {
                      _startKnnFrameStream();
                    } else {
                      _stopKnnFrameStream();
                    }
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _activeCameraMode == CameraRealtimeMode.knn
                              ? 'Switched to KNN Color Identification Mode'
                              : 'Switched to LMS Daltonization Mode',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                splashColor: colors.primary.withValues(alpha: 0.15),
                highlightColor: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDisplayingUploadedImage
                            ? Icons.videocam
                            : (_activeCameraMode == CameraRealtimeMode.daltonization
                                ? Icons.auto_awesome
                                : Icons.palette_outlined),
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isDisplayingUploadedImage
                            ? 'Remap'
                            : (_activeCameraMode == CameraRealtimeMode.daltonization ? 'Remap' : 'Identify'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalibrationSliderOverlay(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.90);

    final double recIntensity = VisionProfileService.instance.recommendedIntensity;
    final int currentPercent = (VisionProfileService.instance.customIntensityOverride * 100).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.change_history_rounded, size: 18, color: colors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'LMS Shift Calibration',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            VisionProfileService.instance.setCustomIntensityOverride(recIntensity);
                          },
                          splashColor: colors.primary.withValues(alpha: 0.15),
                          highlightColor: colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.onSurfaceVariant.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.onSurfaceVariant.withValues(alpha: 0.4), width: 1),
                            ),
                            child: Text(
                              'Rec: ${VisionProfileService.instance.recommendedRangeLabel}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$currentPercent%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCalibrationSlider = false;
                          });
                        },
                        child: Icon(Icons.close, size: 18, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: VisionProfileService.instance.customIntensityOverride.clamp(0.0, 1.0),
                min: 0.0,
                max: 1.0,
                divisions: 20, // 5% per slide step increment
                activeColor: colors.onSurfaceVariant,
                inactiveColor: colors.onSurfaceVariant.withValues(alpha: 0.25),
                onChanged: (val) {
                  final roundedVal = (val * 20).round() / 20.0;
                  VisionProfileService.instance.setCustomIntensityOverride(roundedVal);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightSideFloatingToolbar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.85);
    final iconColor = isDark ? Colors.white : Colors.black87;

    final bool isKnnMode =
        _activeCameraMode == CameraRealtimeMode.knn || _isUploadedIdentifyMode || _isFreezeFrameActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom Toggle Button
        _buildFloatingCircleButton(
          icon: Icons.zoom_in_rounded,
          isActive: _showZoomSlider,
          onTap: () {
            setState(() {
              _showZoomSlider = !_showZoomSlider;
            });
          },
          bgColor: bgColor,
          activeBgColor: colors.primary,
          iconColor: _showZoomSlider ? Colors.white : iconColor,
          tooltip: 'Zoom Control',
        ),
        const SizedBox(height: 12),
        // Flashlight Torch Toggle Button
        _buildFloatingCircleButton(
          icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          isActive: _isTorchOn,
          onTap: _toggleTorch,
          bgColor: bgColor,
          activeBgColor: Colors.amber.shade700,
          iconColor: _isTorchOn ? Colors.white : iconColor,
          tooltip: 'Flashlight',
        ),
        // Split Screen View Comparison Toggle Button (Hidden in KNN Mode)
        if (!isKnnMode) ...[
          const SizedBox(height: 12),
          _buildFloatingCircleButton(
            icon: _isSplitScreenView ? Icons.compare_rounded : Icons.splitscreen_rounded,
            isActive: _isSplitScreenView,
            onTap: () {
              setState(() {
                _isSplitScreenView = !_isSplitScreenView;
              });
              VisionLensScreen.isFullScreenNotifier.value = _isSplitScreenView;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSplitScreenView
                        ? 'Split Screen View & Full Screen enabled (Original vs Daltonized)'
                        : 'Standard View restored',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            bgColor: bgColor,
            activeBgColor: colors.primary,
            iconColor: _isSplitScreenView ? Colors.white : iconColor,
            tooltip: 'Split Screen Comparison',
          ),
        ],
        // On-Demand Audio Narration Speak Button (Hidden in Daltonization Mode)
        if (isKnnMode) ...[
          const SizedBox(height: 12),
          _buildFloatingCircleButton(
            icon: Icons.volume_up_rounded,
            isActive: false,
            onTap: () {
              AuditoryFeedbackService.instance.speakIdentification(
                colorName: _currentIdentifiedColor,
                objectLabel: _currentIdentifiedObject,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _currentIdentifiedObject != null && _currentIdentifiedObject!.isNotEmpty
                        ? 'Speaking: $_currentIdentifiedColor $_currentIdentifiedObject'
                        : 'Speaking: $_currentIdentifiedColor',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            bgColor: bgColor,
            activeBgColor: colors.primary,
            iconColor: iconColor,
            tooltip: 'Speak Color & Object',
          ),
        ],
      ],
    );
  }

  Widget _buildFloatingCircleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color bgColor,
    required Color activeBgColor,
    required Color iconColor,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: isActive ? activeBgColor : bgColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Tooltip(
                message: tooltip,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSliderOverlay(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.90);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.zoom_in_rounded, size: 18, color: colors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Camera Zoom',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showZoomSlider = false;
                          });
                        },
                        child: Icon(Icons.close, size: 18, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _currentZoomLevel.clamp(_minZoom, _maxZoom),
                min: _minZoom,
                max: _maxZoom,
                divisions: 8, // 0.5x steps from 1.0x to 5.0x
                activeColor: colors.primary,
                inactiveColor: colors.onSurfaceVariant.withValues(alpha: 0.25),
                onChanged: (val) {
                  _setZoomLevel(val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitScreenViewport(BuildContext context, ColorScheme colors) {
    Widget leftOriginal;
    Widget rightFiltered;

    if (_isDisplayingUploadedImage && _uploadedUiImage != null) {
      leftOriginal = RawImage(image: _uploadedUiImage, fit: BoxFit.cover);
      rightFiltered = DaltonizationShaderWidget(
        customType: _getEffectiveShaderType(),
        intensity: _getEffectiveShaderIntensity(),
        image: _uploadedUiImage!,
      );
    } else if (_isCameraPermissionGranted) {
      leftOriginal = _buildCameraPreviewWidget(colors);
      rightFiltered = ColorFiltered(
        colorFilter: ColorFilter.matrix(
          _buildCameraColorMatrix(
            _getEffectiveShaderType(),
            _getEffectiveShaderIntensity(),
          ),
        ),
        child: _buildCameraPreviewWidget(colors),
      );
    } else {
      leftOriginal = InkWell(
        onTap: _requestCameraPermission,
        child: Container(
          color: colors.surfaceContainerHighest,
          child: Center(
            child: Icon(Icons.camera_alt_outlined, size: 48, color: colors.primary),
          ),
        ),
      );
      rightFiltered = leftOriginal;
    }

    return Stack(
      children: [
        Row(
          children: [
            // Left Half: Original Un-filtered View
            Expanded(
              child: ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 1000,
                      height: 1000,
                      child: leftOriginal,
                    ),
                  ),
                ),
              ),
            ),
            // Right Half: Daltonized Color-Remapped View
            Expanded(
              child: ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 1000,
                      height: 1000,
                      child: rightFiltered,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Center Accent Split Line
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 3.0,
              color: colors.primary.withValues(alpha: 0.85),
            ),
          ),
        ),
        // Center Divider Compare Icon Handle
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        // Left Label Badge: Original
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: const Text(
              'Original',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Right Label Badge: Daltonized
        Positioned(
          top: 20,
          right: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: const Text(
              'Daltonized',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that draws the interactive crosshair overlay on the
/// freeze-frame captured image.
///
/// The crosshair position is given as normalised coordinates in [0, 1] × [0, 1]
/// image-space. The painter converts this to screen-space by applying the same
/// BoxFit.contain letterbox/pillarbox offset math used in
/// [_VisionLensScreenState._screenTouchToNormalisedImageCoord].
class FreezeFrameCrosshairPainter extends CustomPainter {
  final Offset normPosition;       // Normalised position [0,1]x[0,1] in image space
  final Size imageSize;            // Actual pixel dimensions of the captured image
  final Size containerSize;        // Rendered size of the widget container
  final KnnIsolateResult? colorResult; // Latest classification result (may be null while sampling)
  final Color accentColor;         // Theme primary color for crosshair ring

  FreezeFrameCrosshairPainter({
    required this.normPosition,
    required this.imageSize,
    required this.containerSize,
    required this.colorResult,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.isEmpty || containerSize.isEmpty) return;

    // ── Step 1: Compute the rendered image rect (BoxFit.contain) ──────────
    // Mirror the same math as _screenTouchToNormalisedImageCoord so the
    // crosshair is always pixel-accurate relative to what the user sees.
    final double cW = containerSize.width;
    final double cH = containerSize.height;
    final double iW = imageSize.width;
    final double iH = imageSize.height;

    final double scale = (cW / iW) < (cH / iH) ? (cW / iW) : (cH / iH);
    final double renderedW = iW * scale;
    final double renderedH = iH * scale;
    final double offsetX = (cW - renderedW) / 2.0;
    final double offsetY = (cH - renderedH) / 2.0;

    // Convert normalised image-space position to screen-space canvas position.
    final double cx = offsetX + normPosition.dx * renderedW;
    final double cy = offsetY + normPosition.dy * renderedH;
    final Offset centre = Offset(cx, cy);

    // ── Step 2: Draw crosshair elements ───────────────────────────────
    const double ringRadius = 20.0; // outer ring radius (px)
    const double dotRadius  = 4.0;  // centre dot radius
    const double tickGap    = 6.0;  // gap between ring edge and tick start
    const double tickLen    = 14.0; // tick line length

    final Paint ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final Paint shadowPaint = Paint()
      ..color = const Color(0x55000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint tickPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Drop-shadow ring for legibility on light backgrounds.
    canvas.drawCircle(centre, ringRadius, shadowPaint);
    // Accent-coloured outer ring.
    canvas.drawCircle(centre, ringRadius, ringPaint);
    // White centre dot.
    canvas.drawCircle(centre, dotRadius, dotPaint);

    // Four directional ticks extending outward from the ring.
    final double tickStart = ringRadius + tickGap;
    final double tickEnd   = tickStart + tickLen;

    // Top tick
    canvas.drawLine(
      Offset(cx, cy - tickStart), Offset(cx, cy - tickEnd), tickPaint);
    // Bottom tick
    canvas.drawLine(
      Offset(cx, cy + tickStart), Offset(cx, cy + tickEnd), tickPaint);
    // Left tick
    canvas.drawLine(
      Offset(cx - tickStart, cy), Offset(cx - tickEnd, cy), tickPaint);
    // Right tick
    canvas.drawLine(
      Offset(cx + tickStart, cy), Offset(cx + tickEnd, cy), tickPaint);

    // ── Step 3: Draw colour readout badge ──────────────────────────────
    if (colorResult == null) return;

    final String label = colorResult!.colorName;
    final String hexStr = colorResult!.hexColor.toUpperCase();
    final int intensityPercent = (colorResult!.averageV * 100).round();

    // Parse hex colour for the swatch (e.g. '#FF6600' → Color(0xFFFF6600)).
    Color swatchColor = accentColor;
    try {
      final String cleaned = hexStr.replaceAll('#', '');
      if (cleaned.length == 6) {
        swatchColor = Color(int.parse('FF$cleaned', radix: 16));
      }
    } catch (_) {/* keep accentColor as fallback */}

    // Badge layout constants.
    const double swatchSize  = 18.0;
    const double badgePadH   = 12.0;
    const double badgePadV   = 8.0;
    const double badgeRadius = 14.0;
    const double swatchTextGap = 10.0;
    const double badgeGap    = ringRadius + tickGap + tickLen + 10.0; // vertical offset from centre

    final TextPainter tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          TextSpan(
            text: '\n$hexStr  •  $intensityPercent% Intensity',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // Badge total width: swatch + gap + text + 2 * horizontal padding.
    final double badgeW = swatchSize + swatchTextGap + tp.width + badgePadH * 2;
    final double badgeH = tp.height + badgePadV * 2;

    // Position badge centred relative to crosshair; flip above crosshair if near bottom dock.
    double badgeLeft = cx - badgeW / 2;
    double badgeTop = (cy + badgeGap + badgeH > size.height - 85.0)
        ? (cy - badgeGap - badgeH)
        : (cy + badgeGap);
    badgeLeft = badgeLeft.clamp(8.0, size.width  - badgeW - 8.0);
    badgeTop  = badgeTop .clamp(8.0, size.height - badgeH - 8.0);

    final RRect badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeLeft, badgeTop, badgeW, badgeH),
      const Radius.circular(badgeRadius),
    );

    // Subtle drop shadow for badge readability.
    canvas.drawRRect(
      badgeRRect.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Dark sleek badge background.
    canvas.drawRRect(
      badgeRRect,
      Paint()..color = const Color(0xE610141D),
    );
    // Badge border in brand primary accent.
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Colour swatch circle centered vertically in the badge.
    final double swatchCenterY = badgeTop + badgeH / 2;
    final double swatchCenterX = badgeLeft + badgePadH + swatchSize / 2;

    canvas.drawCircle(
      Offset(swatchCenterX, swatchCenterY),
      swatchSize / 2,
      Paint()..color = swatchColor,
    );
    // Swatch border ring.
    canvas.drawCircle(
      Offset(swatchCenterX, swatchCenterY),
      swatchSize / 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Text label (color name, hex, intensity).
    tp.paint(
      canvas,
      Offset(
        badgeLeft + badgePadH + swatchSize + swatchTextGap,
        badgeTop + badgePadV,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FreezeFrameCrosshairPainter old) {
    return old.normPosition != normPosition ||
        old.colorResult != colorResult ||
        old.accentColor != accentColor ||
        old.containerSize != containerSize;
  }
}

class OpenTrianglePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  OpenTrianglePainter({
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OpenTrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
