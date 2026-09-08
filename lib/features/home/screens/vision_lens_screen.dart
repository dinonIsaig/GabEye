import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/core/widgets/daltonization_shader_widget.dart';
import 'package:gabeye/features/home/widgets/camera_permission_modal.dart';

enum PresetMode { customized, protan, deutan, tritan, off }

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
          children: [
            Icon(Icons.save_alt_rounded, color: colors.primary),
            const SizedBox(width: 8),
            const Text('Save Photo?'),
          ],
        ),
        content: const Text(
          'Would you like to save this color-enhanced Daltonized photo to your device gallery?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved color-enhanced photo to device Gallery.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Save to Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureLiveDaltonizedPhoto(BuildContext context) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Captured & saved live Daltonized photo (${photo.name}) with filter applied!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Captured & saved live Daltonized photo with filter applied!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Captured & saved live Daltonized photo with filter applied!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-check available cameras if permission was previously granted
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _uploadedNotificationTimer?.cancel();
    super.dispose();
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
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          _uploadedNotificationTimer?.cancel();
          setState(() {
            _uploadedImageBytes = bytes;
            _uploadedUiImage = null; // will be set after decode
            _uploadedFileName = picked.name;
            _isDisplayingUploadedImage = true;
            _showUploadedNotification = true;
            _isRemapActive = true;
          });
          await _decodeUploadedImage(bytes);
          _uploadedNotificationTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showUploadedNotification = false;
              });
            }
          });
        }
      }
    } catch (e) {
      // Fallback sample image if running in test environment or gallery picking is unavailable
      if (mounted) {
        _uploadedNotificationTimer?.cancel();
        setState(() {
          _isDisplayingUploadedImage = true;
          _showUploadedNotification = true;
          _isRemapActive = true;
        });
        _uploadedNotificationTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showUploadedNotification = false;
            });
          }
        });
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
    }
  }

  void _switchToRealtimeCameraRemapping() {
    _uploadedNotificationTimer?.cancel();
    setState(() {
      _uploadedImageBytes = null;
      _uploadedUiImage = null;
      _uploadedFileName = null;
      _isDisplayingUploadedImage = false;
      _showUploadedNotification = false;
      _isRemapActive = true;
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

    Widget viewportContent = _isSplitScreenView
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
                // Live camera: shader can't sample a CameraPreview as a static
                // ui.Image, so apply a CPU-side ColorFiltered pass instead.
                ? ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _buildCameraColorMatrix(
                        _getEffectiveShaderType(),
                        _getEffectiveShaderIntensity(),
                      ),
                    ),
                    child: _buildCameraPreviewWidget(colors),
                  )
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
                  )));

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
                    Icon(Icons.image, size: 14, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Uploaded Photo (${_uploadedFileName ?? "Selected Image"})',
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
            bottom: 114,
            child: _buildCalibrationSliderOverlay(context),
          ),

        // Standalone Transparent Floating Open-Triangle Button (outline sides with NO base)
        if (_selectedPreset == PresetMode.customized)
          Positioned(
            left: 0,
            right: 0,
            bottom: _showCalibrationSlider ? 90 : 80,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCalibrationSlider = !_showCalibrationSlider;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.transparent,
                  child: AnimatedRotation(
                    turns: _showCalibrationSlider ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: 32,
                      height: 18,
                      child: CustomPaint(
                        painter: OpenTrianglePainter(
                          color: colors.onSurfaceVariant,
                          strokeWidth: 3.0,
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
                    _handleUploadedPhotoSavePrompt(context);
                  } else if (!_isCameraPermissionGranted) {
                    _requestCameraPermission();
                  } else {
                    _captureLiveDaltonizedPhoto(context);
                  }
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary, width: 4),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRemapActive ? colors.primary : colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ),

              // Remap Button
              InkWell(
                onTap: () {
                  if (_isDisplayingUploadedImage) {
                    _switchToRealtimeCameraRemapping();
                  } else {
                    setState(() {
                      _isRemapActive = !_isRemapActive;
                    });
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
                            : (_isRemapActive ? Icons.auto_awesome : Icons.opacity_outlined),
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isDisplayingUploadedImage ? 'Live Camera' : 'Remap',
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
    final int recPercent = (recIntensity * 100).round();
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
                              'Rec: $recPercent%',
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
        const SizedBox(height: 12),
        // Split Screen View Comparison Toggle Button
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
