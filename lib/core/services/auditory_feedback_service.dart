import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gabeye/data/local/database_helper.dart';
import 'package:gabeye/data/models/accessibility_preferences.dart';

/// Service interfacing with flutter_tts for on-demand offline spoken narration feedback.
class AuditoryFeedbackService {
  AuditoryFeedbackService._();
  static final AuditoryFeedbackService instance = AuditoryFeedbackService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _ttsEnabled = true;
  double _ttsSpeechRate = 0.48;

  bool get ttsEnabled => _ttsEnabled;
  double get ttsSpeechRate => _ttsSpeechRate;

  /// Hydrate TTS preferences from SQLite database.
  Future<void> loadFromDatabase() async {
    try {
      final prefs = await DatabaseHelper.instance.getAccessibilityPreferences(1);
      if (prefs != null) {
        _ttsEnabled = prefs.ttsEnabled;
        _ttsSpeechRate = prefs.ttsSpeechRate;
        if (_isInitialized) {
          await _flutterTts.setSpeechRate(_ttsSpeechRate);
        }
      }
    } catch (_) {}
  }

  /// Enable or disable TTS audio narration and persist to SQLite.
  Future<void> setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    if (!_ttsEnabled && _isSpeaking) {
      await stop();
    }
    await DatabaseHelper.instance.saveAccessibilityPreferences(
      AccessibilityPreferences(
        userId: 1,
        ttsEnabled: _ttsEnabled,
        ttsSpeechRate: _ttsSpeechRate,
      ),
    );
  }

  /// Update TTS speech rate and persist to SQLite.
  Future<void> setTtsSpeechRate(double rate) async {
    _ttsSpeechRate = rate;
    if (_isInitialized) {
      await _flutterTts.setSpeechRate(_ttsSpeechRate);
    }
    await DatabaseHelper.instance.saveAccessibilityPreferences(
      AccessibilityPreferences(
        userId: 1,
        ttsEnabled: _ttsEnabled,
        ttsSpeechRate: _ttsSpeechRate,
      ),
    );
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(_ttsSpeechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // On iOS, configure audio session to ambient with mixWithOthers so TTS
      // does not interrupt, pause, or invalidate the active AVCaptureSession (camera).
      if (Platform.isIOS) {
        try {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.ambient,
            [
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.duckOthers,
            ],
            IosTextToSpeechAudioMode.defaultMode,
          );
        } catch (_) {}
      }

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
    if (!_ttsEnabled) return;

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

  /// Speaks arbitrary text (e.g. for Object Labeling narration).
  Future<void> speakText(String text) async {
    if (!_ttsEnabled) return;

    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    _isSpeaking = true;
    try {
      await _flutterTts.speak(text);
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
