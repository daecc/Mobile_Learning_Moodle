import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel para la gestión reactiva del tema (Modo Claro / Modo Oscuro)
/// persistido localmente mediante SharedPreferences (Laboratorio 06).
class ThemeViewModel extends ChangeNotifier {
  static const String prefKeyThemeMode = 'app_theme_is_dark';

  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeViewModel({SharedPreferences? preferences}) {
    if (preferences != null) {
      _prefs = preferences;
      _applySavedPreference();
    } else {
      _initAndLoad();
    }
  }

  Future<void> _initAndLoad() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _applySavedPreference();
    } catch (_) {
      // Si ocurre un error o se ejecuta en entorno de pruebas sin mock,
      // se preserva el tema inicial por defecto sin interrumpir la ejecución.
    }
  }

  void _applySavedPreference() {
    final isDark = _prefs?.getBool(prefKeyThemeMode);
    if (isDark != null) {
      final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (_themeMode != newMode) {
        _themeMode = newMode;
        notifyListeners();
      }
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _persistCurrentTheme();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _persistCurrentTheme();
  }

  Future<void> _persistCurrentTheme() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool(prefKeyThemeMode, isDarkMode);
    } catch (_) {
      // Ignorar de forma segura en tests o plataformas no compatibles
    }
  }
}
