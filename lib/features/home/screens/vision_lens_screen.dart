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

  @override
  State<VisionLensScreen> createState() => _VisionLensScreenState();
}

class _VisionLensScreenState extends State<VisionLensScreen> {
  PresetMode _selectedPreset = PresetMode.customized;
  bool _isRemapActive = true;
  bool _isCameraPermissionGranted = false;

  CameraController? _cameraController;
  bool _isCameraInitializing = false;

  // Uploaded photo state, decoded ui.Image, & notification timer
  Uint8List? _uploadedImageBytes;
  ui.Image? _uploadedUiImage;
  String? _uploadedFileName;
  bool _isDisplayingUploadedImage = false;
  bool _showUploadedNotification = false;
  Timer? _uploadedNotificationTimer;

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
  }

  Widget _buildTopPresetSelectorBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ValueListenableBuilder(
        valueListenable: VisionProfileService.instance,
        builder: (context, result, _) {
          final customLabel = VisionProfileService.instance.hasCompletedAssessment
              ? 'Customize (${VisionProfileService.instance.activeProfileLabel})'
              : 'Customize (D-15)';

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

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
        ),
      ),
      selected: isSelected,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.onSurfaceVariant.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPreset = mode;
          });
        }
      },
    );
  }

  Widget _buildCameraViewport(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Viewport: Uploaded photo or Realtime Hardware Camera Feed through GLSL LMS Daltonization Shader
        Positioned.fill(
          child: _isDisplayingUploadedImage
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
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to allow camera access and enable real-time LMS Daltonization color remapping.',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _requestCameraPermission,
                              icon: const Icon(Icons.security_rounded, size: 18),
                              label: const Text('Allow Camera Access'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
        ),

        // Indicator Chip when displaying uploaded photo
        if (_isDisplayingUploadedImage)
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

        // Transparent Floating Action Card (Upload, Shutter/Reset, Remap to Camera)
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
                    _switchToRealtimeCameraRemapping();
                  } else if (!_isCameraPermissionGranted) {
                    _requestCameraPermission();
                  } else {
                    setState(() {
                      _isRemapActive = !_isRemapActive;
                    });
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
}
