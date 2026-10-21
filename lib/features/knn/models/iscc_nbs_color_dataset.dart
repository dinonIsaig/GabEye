import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_entry.dart';
import 'package:gabeye/features/encyclopedia/data/iscc_nbs_data.dart';

export 'package:gabeye/features/knn/models/iscc_nbs_color_entry.dart';

/// Helper service to load and cache the ISCC-NBS 267 color entries from JSON assets.
class IsccNbsColorDataset {
  static List<IsccNbsColorEntry>? _cachedEntries;

  /// Synchronously returns all 260 ISCC-NBS colors with 0ms delay.
  static List<IsccNbsColorEntry> getAllColorsSync() {
    return _cachedEntries ?? kAllIsccNbsColors;
  }

  static Future<List<IsccNbsColorEntry>> loadDataset() async {
    if (_cachedEntries != null && _cachedEntries!.isNotEmpty) {
      return _cachedEntries!;
    }
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/iscc_nbs_colors.json');
      final List<dynamic> rawList = json.decode(jsonStr);
      _cachedEntries = rawList
          .map((e) =>
              IsccNbsColorEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return _cachedEntries!;
    } catch (_) {
      try {
        final jsonStr =
            await rootBundle.loadString('data/iscc_nbs_colors.json');
        final List<dynamic> rawList = json.decode(jsonStr);
        _cachedEntries = rawList
            .map((e) =>
                IsccNbsColorEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return _cachedEntries!;
      } catch (_) {
        _cachedEntries = kAllIsccNbsColors;
        return _cachedEntries!;
      }
    }
  }
}
