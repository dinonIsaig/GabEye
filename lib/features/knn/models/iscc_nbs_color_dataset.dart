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
  final int? r;
  final int? g;
  final int? b;

  const IsccNbsColorEntry({
    required this.id,
    required this.name,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.hex,
    this.r,
    this.g,
    this.b,
  });

  factory IsccNbsColorEntry.fromJson(Map<String, dynamic> json) {
    return IsccNbsColorEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      hue: (json['h'] as num).toDouble(),
      saturation: (json['s'] as num).toDouble(),
      value: (json['v'] as num).toDouble(),
      hex: json['hex'] as String,
      r: json['r'] as int?,
      g: json['g'] as int?,
      b: json['b'] as int?,
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
      if (r != null) 'r': r,
      if (g != null) 'g': g,
      if (b != null) 'b': b,
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
      IsccNbsColorEntry(id: 11, name: 'Vivid Red', r: 213, g: 28, b: 60, hue: 350, saturation: 0.87, value: 0.84, hex: '#D51C3C'),
      IsccNbsColorEntry(id: 48, name: 'Vivid Orange', r: 247, g: 118, b: 11, hue: 27, saturation: 0.96, value: 0.97, hex: '#F7760B'),
      IsccNbsColorEntry(id: 82, name: 'Vivid Yellow', r: 241, g: 191, b: 21, hue: 46, saturation: 0.91, value: 0.95, hex: '#F1BF15'),
      IsccNbsColorEntry(id: 139, name: 'Vivid Green', r: 35, g: 234, b: 165, hue: 159, saturation: 0.85, value: 0.92, hex: '#23EAA5'),
      IsccNbsColorEntry(id: 176, name: 'Vivid Blue', r: 27, g: 92, b: 215, hue: 219, saturation: 0.87, value: 0.84, hex: '#1B5CD7'),
      IsccNbsColorEntry(id: 216, name: 'Vivid Purple', r: 185, g: 53, b: 213, hue: 290, saturation: 0.75, value: 0.84, hex: '#B935D5'),
      IsccNbsColorEntry(id: 263, name: 'White', r: 231, g: 225, b: 233, hue: 285, saturation: 0.03, value: 0.91, hex: '#E7E1E9'),
      IsccNbsColorEntry(id: 265, name: 'Medium Gray', r: 138, g: 132, b: 137, hue: 310, saturation: 0.04, value: 0.54, hex: '#8A8489'),
      IsccNbsColorEntry(id: 267, name: 'Black', r: 43, g: 41, b: 43, hue: 300, saturation: 0.05, value: 0.17, hex: '#2B292B'),
    ];
  }
}
