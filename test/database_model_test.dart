import 'package:flutter_test/flutter_test.dart';
import 'package:gabeye/data/models/accessibility_preferences.dart';
import 'package:gabeye/data/models/adaptive_ui_settings.dart';
import 'package:gabeye/data/models/diagnostic_data.dart';
import 'package:gabeye/data/models/user_profile.dart';

void main() {
  group('Database Models Serialization Tests', () {
    test('UserProfile toMap and fromMap serialization', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 1,
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap();
      expect(map['_id'], 1);
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());

      final fromMap = UserProfile.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.createdAt.toIso8601String(), now.toIso8601String());
      expect(fromMap.updatedAt.toIso8601String(), now.toIso8601String());
    });

    test('DiagnosticData toMap and fromMap serialization', () {
      final now = DateTime.now();
      final data = DiagnosticData(
        userId: 1,
        hasTakenTest: true,
        cvdType: 'Deutan',
        severity: 'Moderate',
        testDate: now,
      );

      final map = data.toMap();
      expect(map['user_id'], 1);
      expect(map['has_taken_test'], 1);
      expect(map['cvd_type'], 'Deutan');
      expect(map['severity'], 'Moderate');
      expect(map['test_date'], now.toIso8601String());

      final fromMap = DiagnosticData.fromMap(map);
      expect(fromMap.userId, 1);
      expect(fromMap.hasTakenTest, isTrue);
      expect(fromMap.cvdType, 'Deutan');
      expect(fromMap.severity, 'Moderate');
      expect(fromMap.testDate?.toIso8601String(), now.toIso8601String());
    });

    test('AdaptiveUiSettings toMap and fromMap serialization', () {
      const settings = AdaptiveUiSettings(
        userId: 1,
        appliedTheme: 'Red-Green Safe',
        colorAgnosticMode: true,
      );

      final map = settings.toMap();
      expect(map['user_id'], 1);
      expect(map['applied_theme'], 'Red-Green Safe');
      expect(map['color_agnostic_mode'], 1);

      final fromMap = AdaptiveUiSettings.fromMap(map);
      expect(fromMap.userId, 1);
      expect(fromMap.appliedTheme, 'Red-Green Safe');
      expect(fromMap.colorAgnosticMode, isTrue);
    });

    test('AccessibilityPreferences toMap and fromMap serialization', () {
      const prefs = AccessibilityPreferences(
        userId: 1,
        ttsEnabled: true,
        ttsSpeechRate: 0.75,
      );

      final map = prefs.toMap();
      expect(map['user_id'], 1);
      expect(map['tts_enabled'], 1);
      expect(map['tts_speech_rate'], 0.75);

      final fromMap = AccessibilityPreferences.fromMap(map);
      expect(fromMap.userId, 1);
      expect(fromMap.ttsEnabled, isTrue);
      expect(fromMap.ttsSpeechRate, 0.75);
    });
  });
}
