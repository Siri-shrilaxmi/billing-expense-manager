import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  ThemeController._();

  static final ThemeController instance =
      ThemeController._();

  static const String _themeKey =
      "theme_mode";

  // ============================================================
  // CURRENT THEME
  // ============================================================

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  // ============================================================
  // LOAD SAVED THEME
  // ============================================================

  Future<void> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedTheme =
        prefs.getString(
      _themeKey,
    );

    switch (savedTheme) {
      case "light":
        themeMode.value =
            ThemeMode.light;
        break;

      case "dark":
        themeMode.value =
            ThemeMode.dark;
        break;

      case "system":
      default:
        themeMode.value =
            ThemeMode.system;
        break;
    }
  }

  // ============================================================
  // SET THEME
  // ============================================================

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    // ----------------------------------------------------------
    // Change UI immediately.
    // ----------------------------------------------------------

    themeMode.value = mode;

    // ----------------------------------------------------------
    // Persist choice.
    // ----------------------------------------------------------

    final prefs =
        await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(
          _themeKey,
          "light",
        );
        break;

      case ThemeMode.dark:
        await prefs.setString(
          _themeKey,
          "dark",
        );
        break;

      case ThemeMode.system:
        await prefs.setString(
          _themeKey,
          "system",
        );
        break;
    }
  }
}