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
