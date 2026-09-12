import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gabeye/core/services/vision_profile_service.dart';

/// A widget that applies real-time GLSL Daltonization shaders over a
/// pre-decoded [dart:ui.Image] (e.g. an uploaded photo).
///
/// Shows a [CircularProgressIndicator] fallback until the shader program is
/// ready.  Listens to [VisionProfileService.instance] for the active
/// assessment result.
class DaltonizationShaderWidget extends StatefulWidget {
  /// The decoded image to daltonize.
  final ui.Image image;

  /// Manual override for uType (0.0=Protan, 1.0=Deutan, 2.0=Tritan, 3.0=Normal).
  /// If null, uses the active D-15 assessment result from [VisionProfileService].
  final double? customType;

  /// Filter shift intensity (0.0 to 1.0)
  final double intensity;

  const DaltonizationShaderWidget({
    super.key,
    required this.image,
    this.customType,
    this.intensity = 1.0,
  });

  @override
  State<DaltonizationShaderWidget> createState() =>
      _DaltonizationShaderWidgetState();
}

class _DaltonizationShaderWidgetState extends State<DaltonizationShaderWidget> {
  ui.FragmentProgram? _program;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program =
          await ui.FragmentProgram.fromAsset('assets/shaders/daltonization.frag');
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VisionProfileService.instance,
      builder: (context, assessmentResult, _) {
        // Show fallback until shader is compiled/loaded.
        if (_program == null || _loadFailed) {
          return const Center(child: CircularProgressIndicator());
        }

        final shaderType =
            widget.customType ?? VisionProfileService.instance.shaderType;

        return CustomPaint(
          painter: _DaltonizationPainter(
            program: _program!,
            image: widget.image,
            shaderType: shaderType,
            intensity: widget.intensity,
            dpr: MediaQuery.of(context).devicePixelRatio,
          ),
          size: Size(
            widget.image.width.toDouble(),
            widget.image.height.toDouble(),
          ),
        );
      },
    );
  }
}

class _DaltonizationPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final double shaderType;
  final double intensity;
  final double dpr;

  _DaltonizationPainter({
    required this.program,
    required this.image,
    required this.shaderType,
    required this.intensity,
    required this.dpr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // Uniforms match the declaration order in daltonization.frag:
    //   uResolution (vec2), uDpr, uType, uIntensity
    shader.setFloat(0, size.width);   // uResolution.x
    shader.setFloat(1, size.height);  // uResolution.y
    shader.setFloat(2, dpr);          // uDpr
    shader.setFloat(3, shaderType);   // uType
    shader.setFloat(4, intensity);    // uIntensity

    // Bind the decoded image to sampler slot 0 (uTexture in the shader).
    shader.setImageSampler(0, image);

    final dst = Offset.zero & size;
    canvas.drawRect(
      dst,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_DaltonizationPainter old) {
    return old.shaderType != shaderType ||
        old.intensity != intensity ||
        old.dpr != dpr ||
        old.image != image;
  }
}
