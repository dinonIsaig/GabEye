import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A widget that applies real-time GLSL Machado (2009) dichromacy simulation
/// shaders over a pre-decoded [dart:ui.Image] (e.g. an uploaded photo).
class CvdSimulationShaderWidget extends StatefulWidget {
  /// The decoded image to simulate.
  final ui.Image image;

  /// uType (0.0=Protan, 1.0=Deutan, 2.0=Tritan, 3.0=Normal).
  final double shaderType;

  /// Simulation intensity / calibration (0.0 to 1.0)
  final double intensity;

  const CvdSimulationShaderWidget({
    super.key,
    required this.image,
    required this.shaderType,
    this.intensity = 1.0,
  });

  @override
  State<CvdSimulationShaderWidget> createState() =>
      _CvdSimulationShaderWidgetState();
}

class _CvdSimulationShaderWidgetState extends State<CvdSimulationShaderWidget> {
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
          await ui.FragmentProgram.fromAsset('assets/shaders/cvd_simulation.frag');
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
    if (_program == null || _loadFailed) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomPaint(
      painter: _CvdSimulationPainter(
        program: _program!,
        image: widget.image,
        shaderType: widget.shaderType,
        intensity: widget.intensity,
        dpr: MediaQuery.of(context).devicePixelRatio,
      ),
      size: Size(
        widget.image.width.toDouble(),
        widget.image.height.toDouble(),
      ),
    );
  }
}

class _CvdSimulationPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image image;
  final double shaderType;
  final double intensity;
  final double dpr;

  _CvdSimulationPainter({
    required this.program,
    required this.image,
    required this.shaderType,
    required this.intensity,
    required this.dpr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // Uniforms match declaration order in cvd_simulation.frag:
    //   uResolution (vec2), uDpr, uType, uIntensity
    shader.setFloat(0, size.width);   // uResolution.x
    shader.setFloat(1, size.height);  // uResolution.y
    shader.setFloat(2, dpr);          // uDpr
    shader.setFloat(3, shaderType);   // uType
    shader.setFloat(4, intensity);    // uIntensity

    shader.setImageSampler(0, image);

    final dst = Offset.zero & size;
    canvas.drawRect(
      dst,
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_CvdSimulationPainter old) {
    return old.shaderType != shaderType ||
        old.intensity != intensity ||
        old.dpr != dpr ||
        old.image != image;
  }
}
