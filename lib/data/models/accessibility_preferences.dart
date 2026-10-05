/// Represents accessibility and text-to-speech preferences in the Accessibility_Preferences table.
class AccessibilityPreferences {
  final int userId;
  final bool ttsEnabled;
  final double ttsSpeechRate;

  const AccessibilityPreferences({
    required this.userId,
    this.ttsEnabled = false,
    this.ttsSpeechRate = 0.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'tts_enabled': ttsEnabled ? 1 : 0,
      'tts_speech_rate': ttsSpeechRate,
    };
  }

  factory AccessibilityPreferences.fromMap(Map<String, dynamic> map) {
    return AccessibilityPreferences(
      userId: map['user_id'] as int,
      ttsEnabled: (map['tts_enabled'] as int?) == 1,
      ttsSpeechRate: (map['tts_speech_rate'] as num?)?.toDouble() ?? 0.5,
    );
  }

  AccessibilityPreferences copyWith({
    int? userId,
    bool? ttsEnabled,
    double? ttsSpeechRate,
  }) {
    return AccessibilityPreferences(
      userId: userId ?? this.userId,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsSpeechRate: ttsSpeechRate ?? this.ttsSpeechRate,
    );
  }

  @override
  String toString() =>
      'AccessibilityPreferences(user_id: $userId, tts_enabled: $ttsEnabled, tts_speech_rate: $ttsSpeechRate)';
}
