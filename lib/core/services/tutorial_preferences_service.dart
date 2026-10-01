import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing mode-specific one-time tutorial persistence across Vision Lens features.
class TutorialPreferencesService {
  static const String _remapTutorialKey = 'has_seen_remap_toolbar_tutorial';
  static const String _knnTutorialKey = 'has_seen_knn_toolbar_tutorial';

  TutorialPreferencesService._();

  /// Returns true if the user has already seen the Remap mode floating toolbar tutorial.
  static Future<bool> hasSeenRemapTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_remapTutorialKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the user has already seen the KNN mode floating toolbar tutorial.
  static Future<bool> hasSeenKnnTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_knnTutorialKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marks the Remap mode toolbar tutorial as completed.
  static Future<void> markRemapTutorialAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_remapTutorialKey, true);
    } catch (_) {}
  }

  /// Marks the KNN mode toolbar tutorial as completed.
  static Future<void> markKnnTutorialAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_knnTutorialKey, true);
    } catch (_) {}
  }

  /// Resets all tutorial statuses allowing manual re-plays.
  static Future<void> resetAllTutorials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_remapTutorialKey);
      await prefs.remove(_knnTutorialKey);
    } catch (_) {}
  }
}
