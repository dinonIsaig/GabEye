import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

/// Service responsible for saving captured & Daltonized images to the device gallery / pictures directory.
class GalleryService {
  GalleryService._();

  /// Applies the Machado 4x5 [ColorFilter] matrix to raw image bytes (PNG/JPEG)
  /// and returns encoded PNG image bytes with the color filter applied.
  static Future<Uint8List> applyColorMatrixToImageBytes(
    Uint8List originalBytes,
    List<double> colorMatrix,
  ) async {
    try {
      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..colorFilter = ColorFilter.matrix(colorMatrix);

      canvas.drawImage(image, Offset.zero, paint);

      final picture = recorder.endRecording();
      final filteredImage = await picture.toImage(image.width, image.height);
      final byteData = await filteredImage.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();
      filteredImage.dispose();

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('Error applying color matrix to image bytes: $e');
    }
    return originalBytes;
  }

  /// Applies the native GLSL Daltonization Fragment Shader offscreen to raw image bytes,
  /// matching the exact visual output of [DaltonizationShaderWidget].
  static Future<Uint8List> applyDaltonizationShaderToImageBytes(
    Uint8List originalBytes, {
    required double shaderType,
    required double intensity,
    List<double>? fallbackMatrix,
  }) async {
    if (shaderType >= 2.5 || intensity <= 0.01) {
      return originalBytes;
    }
    try {
      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final program = await ui.FragmentProgram.fromAsset('assets/shaders/daltonization.frag');
      final shader = program.fragmentShader();

      shader.setFloat(0, image.width.toDouble());  // uResolution.x
      shader.setFloat(1, image.height.toDouble()); // uResolution.y
      shader.setFloat(2, 1.0);                    // uDpr
      shader.setFloat(3, shaderType);             // uType
      shader.setFloat(4, intensity);              // uIntensity
      shader.setImageSampler(0, image);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..shader = shader;

      final rect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      canvas.drawRect(rect, paint);

      final picture = recorder.endRecording();
      final filteredImage = await picture.toImage(image.width, image.height);
      final byteData = await filteredImage.toByteData(format: ui.ImageByteFormat.png);

      image.dispose();
      filteredImage.dispose();

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('Fragment shader offscreen rendering unavailable, applying color matrix: $e');
      if (fallbackMatrix != null) {
        return applyColorMatrixToImageBytes(originalBytes, fallbackMatrix);
      }
    }
    return originalBytes;
  }

  /// Saves raw or filtered image bytes directly to the device's Pictures / Gallery directory (iOS Photos & Android MediaStore).
  static Future<bool> saveImageToGallery(
    Uint8List bytes, {
    String? filename,
  }) async {
    try {
      final name = filename != null && filename.isNotEmpty
          ? (filename.endsWith('.png') || filename.endsWith('.jpg')
              ? filename
              : '$filename.png')
          : 'GabEye_Daltonized_${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        return true;
      }

      // Try native iOS Photos & Android Gallery via gal package
      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }
        await Gal.putImageBytes(bytes, name: name);
        debugPrint('Saved photo via Gal to device Gallery: $name');
        return true;
      } catch (galError) {
        debugPrint('Gal save fallback triggered: $galError');
      }

      // Fallback to local pictures directory
      Directory? picturesDir;
      if (Platform.isAndroid) {
        picturesDir = Directory('/storage/emulated/0/Pictures/GabEye');
        if (!await picturesDir.exists()) {
          await picturesDir.create(recursive: true);
        }
      } else {
        final tempDir = Directory.systemTemp;
        picturesDir = Directory('${tempDir.path}/GabEye');
        if (!await picturesDir.exists()) {
          await picturesDir.create(recursive: true);
        }
      }

      final file = File('${picturesDir.path}/$name');
      await file.writeAsBytes(bytes);
      debugPrint('Saved photo to file: ${file.path}');
      return true;
    } catch (e) {
      debugPrint('GalleryService error: $e');
      return false;
    }
  }
}

