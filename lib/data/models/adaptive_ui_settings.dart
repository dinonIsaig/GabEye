/// Represents UI customization preferences in the Adaptive_UI_Settings table.
class AdaptiveUiSettings {
  final int userId;
  final String appliedTheme;
  final bool colorAgnosticMode;

  const AdaptiveUiSettings({
    required this.userId,
    this.appliedTheme = 'Default',
    this.colorAgnosticMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'applied_theme': appliedTheme,
      'color_agnostic_mode': colorAgnosticMode ? 1 : 0,
    };
  }

  factory AdaptiveUiSettings.fromMap(Map<String, dynamic> map) {
    return AdaptiveUiSettings(
      userId: map['user_id'] as int,
      appliedTheme: (map['applied_theme'] as String?) ?? 'Default',
      colorAgnosticMode: (map['color_agnostic_mode'] as int?) == 1,
    );
  }

  AdaptiveUiSettings copyWith({
    int? userId,
    String? appliedTheme,
    bool? colorAgnosticMode,
  }) {
    return AdaptiveUiSettings(
      userId: userId ?? this.userId,
      appliedTheme: appliedTheme ?? this.appliedTheme,
      colorAgnosticMode: colorAgnosticMode ?? this.colorAgnosticMode,
    );
  }

  @override
  String toString() =>
      'AdaptiveUiSettings(user_id: $userId, applied_theme: $appliedTheme, color_agnostic_mode: $colorAgnosticMode)';
}
