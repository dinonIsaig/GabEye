import 'package:flutter_tts/flutter_tts.dart';

/// Service interfacing with flutter_tts for on-demand offline spoken narration feedback.
class AuditoryFeedbackService {
  AuditoryFeedbackService._();
  static final AuditoryFeedbackService instance = AuditoryFeedbackService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  /// Speaks out the aggregated color + object description phrase when requested by the user.
  Future<void> speakIdentification({
    required String colorName,
    String? objectLabel,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    String phrase;
    if (objectLabel != null && objectLabel.isNotEmpty && objectLabel != 'Object') {
      phrase = '$colorName $objectLabel';
    } else {
      phrase = colorName;
    }

    _isSpeaking = true;
    try {
      await _flutterTts.speak(phrase);
    } catch (_) {
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (_) {}
  }
}
