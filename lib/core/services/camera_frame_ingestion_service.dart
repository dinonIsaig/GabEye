import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import 'package:gabeye/features/knn/services/knn_isolate_worker.dart';

/// Service responsible for managing camera frame stream ingestion,
/// dynamic downscaling, throttling to 2-3 FPS, and extracting ROI buffers.
class CameraFrameIngestionService {
  CameraFrameIngestionService._();
  static final CameraFrameIngestionService instance = CameraFrameIngestionService._();

  bool _isProcessingFrame = false;
  DateTime _lastFrameTimestamp = DateTime.now();

  // Throttle interval (350 ms ~ 2.8 FPS to prevent CPU/GPU thermal load)
  static const Duration _throttleInterval = Duration(milliseconds: 350);

  /// Processes an incoming raw camera frame plane and returns KNN Isolate classification result.
  Future<KnnIsolateResult?> processCameraFrame({
    required CameraImage image,
    required List<IsccNbsColorEntry> dataset,
  }) async {
    final now = DateTime.now();
    if (_isProcessingFrame || now.difference(_lastFrameTimestamp) < _throttleInterval) {
      return null;
    }

    _isProcessingFrame = true;
    _lastFrameTimestamp = now;

    try {
      // Extract center ROI RGB bytes via YUV420/BGRA8888 plane decoding
      final Uint8List roiBytes = _extractCenterRoiRgbBytes(image);

      final rawDatasetJson = dataset.map((e) => e.toJson()).toList();

      final request = KnnIsolateRequest(
        pixelBuffer: roiBytes,
        width: 24,
        height: 24,
        rawDatasetJson: rawDatasetJson,
      );

      final result = await KnnIsolateWorker.processRoiInIsolate(request);
      _isProcessingFrame = false;
      return result;
    } catch (_) {
      _isProcessingFrame = false;
      return null;
    }
  }

  Uint8List _extractCenterRoiRgbBytes(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int centerX = width ~/ 2;
    final int centerY = height ~/ 2;
    const int roiRadius = 12; // 24x24 pixel center area

    final int startX = (centerX - roiRadius).clamp(0, width - 1);
    final int endX = (centerX + roiRadius).clamp(startX + 1, width);
    final int startY = (centerY - roiRadius).clamp(0, height - 1);
    final int endY = (centerY + roiRadius).clamp(startY + 1, height);

    final int roiW = endX - startX;
    final int roiH = endY - startY;
    final Uint8List rgbBytes = Uint8List(roiW * roiH * 3);
    int outIdx = 0;

    if (image.format.group == ImageFormatGroup.yuv420 && image.planes.length >= 3) {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final yBytes = yPlane.bytes;
      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;

      final yRowStride = yPlane.bytesPerRow;
      final uRowStride = uPlane.bytesPerRow;
      final vRowStride = vPlane.bytesPerRow;

      final int uPixelStride = uPlane.bytesPerPixel ?? 1;
      final int vPixelStride = vPlane.bytesPerPixel ?? 1;

      for (int y = startY; y < endY; y++) {
        for (int x = startX; x < endX; x++) {
          final int yIdx = y * yRowStride + x;
          final int uvY = y ~/ 2;
          final int uvX = x ~/ 2;
          final int uIdx = uvY * uRowStride + uvX * uPixelStride;
          final int vIdx = uvY * vRowStride + uvX * vPixelStride;

          if (yIdx < yBytes.length && uIdx < uBytes.length && vIdx < vBytes.length) {
            final int yVal = yBytes[yIdx];
            final int uVal = uBytes[uIdx] - 128;
            final int vVal = vBytes[vIdx] - 128;

            int r = (yVal + 1.402 * vVal).round().clamp(0, 255);
            int g = (yVal - 0.344136 * uVal - 0.714136 * vVal).round().clamp(0, 255);
            int b = (yVal + 1.772 * uVal).round().clamp(0, 255);

            rgbBytes[outIdx++] = r;
            rgbBytes[outIdx++] = g;
            rgbBytes[outIdx++] = b;
          }
        }
      }
    } else if (image.format.group == ImageFormatGroup.bgra8888 && image.planes.isNotEmpty) {
      final plane = image.planes.first;
      final bytes = plane.bytes;
      final rowStride = plane.bytesPerRow;

      for (int y = startY; y < endY; y++) {
        for (int x = startX; x < endX; x++) {
          final int idx = y * rowStride + x * 4;
          if (idx + 2 < bytes.length) {
            final int b = bytes[idx];
            final int g = bytes[idx + 1];
            final int r = bytes[idx + 2];
            rgbBytes[outIdx++] = r;
            rgbBytes[outIdx++] = g;
            rgbBytes[outIdx++] = b;
          }
        }
      }
    } else {
      final plane = image.planes.first;
      final bytes = plane.bytes;
      for (int i = 0; i < rgbBytes.length; i++) {
        rgbBytes[i] = bytes[i % bytes.length];
      }
    }

    return rgbBytes;
  }
}
