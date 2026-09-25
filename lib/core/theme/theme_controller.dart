import 'package:flutter/material.dart';

/// The single source of truth for GabEye's runtime theme selection.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  bool get isDarkMode => value == ThemeMode.dark;

  void setDarkMode(bool enabled) {
    value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}

final ThemeController themeController = ThemeController();
