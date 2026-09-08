import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

/// Service responsible for saving captured & Daltonized images to the device gallery / pictures directory.
class GalleryService {
  GalleryService._();

  /// Saves raw image bytes directly to the device's Pictures / Gallery directory (iOS Photos & Android MediaStore).
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
