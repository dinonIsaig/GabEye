import 'dart:convert';
import 'package:flutter/services.dart';

/// Data model representing a single ISCC-NBS 267 color system record.
class IsccNbsColorEntry {
  final int id;
  final String name;
  final double hue; // 0.0 to 360.0
  final double saturation; // 0.0 to 1.0
  final double value; // 0.0 to 1.0
  final String hex;

  const IsccNbsColorEntry({
    required this.id,
    required this.name,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.hex,
  });

  factory IsccNbsColorEntry.fromJson(Map<String, dynamic> json) {
    return IsccNbsColorEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      hue: (json['h'] as num).toDouble(),
      saturation: (json['s'] as num).toDouble(),
      value: (json['v'] as num).toDouble(),
      hex: json['hex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'h': hue,
      's': saturation,
      'v': value,
      'hex': hex,
    };
  }
}

/// Helper service to load and cache the ISCC-NBS 267 color entries from JSON assets.
class IsccNbsColorDataset {
  static List<IsccNbsColorEntry>? _cachedEntries;

  static Future<List<IsccNbsColorEntry>> loadDataset() async {
    if (_cachedEntries != null) return _cachedEntries!;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/iscc_nbs_colors.json');
      final List<dynamic> rawList = json.decode(jsonStr);
      _cachedEntries = rawList.map((e) => IsccNbsColorEntry.fromJson(e)).toList();
      return _cachedEntries!;
    } catch (_) {
      // Fallback built-in core colors if asset loading fails
      _cachedEntries = _fallbackDataset();
      return _cachedEntries!;
    }
  }

  static List<IsccNbsColorEntry> _fallbackDataset() {
    return const [
      IsccNbsColorEntry(id: 11, name: 'Vivid Red', hue: 0, saturation: 0.95, value: 0.90, hex: '#E60000'),
      IsccNbsColorEntry(id: 27, name: 'Vivid Orange', hue: 25, saturation: 0.95, value: 0.95, hex: '#FF6600'),
      IsccNbsColorEntry(id: 48, name: 'Vivid Yellow', hue: 52, saturation: 0.95, value: 0.98, hex: '#FFE600'),
      IsccNbsColorEntry(id: 77, name: 'Vivid Green', hue: 130, saturation: 0.95, value: 0.80, hex: '#00CC44'),
      IsccNbsColorEntry(id: 100, name: 'Vivid Blue', hue: 210, saturation: 0.95, value: 0.90, hex: '#0077FF'),
      IsccNbsColorEntry(id: 121, name: 'Vivid Purple', hue: 285, saturation: 0.95, value: 0.85, hex: '#D400FF'),
      IsccNbsColorEntry(id: 134, name: 'White', hue: 0, saturation: 0.0, value: 0.98, hex: '#FFFFFF'),
      IsccNbsColorEntry(id: 136, name: 'Medium Gray', hue: 0, saturation: 0.0, value: 0.50, hex: '#808080'),
      IsccNbsColorEntry(id: 138, name: 'Black', hue: 0, saturation: 0.0, value: 0.05, hex: '#101010'),
    ];
  }
}
