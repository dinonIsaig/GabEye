import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Service responsible for saving captured & Daltonized images to the device gallery / pictures directory.
class GalleryService {
  GalleryService._();

  /// Saves raw image bytes directly to the device's Pictures / Gallery directory.
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
      debugPrint('Saved photo successfully to: ${file.path}');
      return true;
    } catch (e) {
      debugPrint('GalleryService error: $e');
      return false;
    }
  }
}
