import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing one-time tutorial persistence across Vision Lens features.
class TutorialPreferencesService {
  static const String _toolbarTutorialKey = 'has_seen_vision_lens_toolbar_tutorial';

  TutorialPreferencesService._();

  /// Returns true if the user has already seen/completed the floating toolbar tutorial.
  static Future<bool> hasSeenToolbarTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_toolbarTutorialKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marks the floating toolbar tutorial as completed so it won't show automatically again.
  static Future<void> markToolbarTutorialAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_toolbarTutorialKey, true);
    } catch (_) {}
  }

  /// Resets the tutorial status allowing manual re-plays.
  static Future<void> resetToolbarTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_toolbarTutorialKey);
    } catch (_) {}
  }
}
