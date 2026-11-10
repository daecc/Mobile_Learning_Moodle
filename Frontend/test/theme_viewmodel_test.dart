import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumbo_app/viewmodels/theme_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeViewModel initializes with default light mode when no preference stored', () {
    final vm = ThemeViewModel();
    expect(vm.themeMode, equals(ThemeMode.light));
    expect(vm.isDarkMode, isFalse);
  });

  test('ThemeViewModel loads dark mode when stored in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      ThemeViewModel.prefKeyThemeMode: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final vm = ThemeViewModel(preferences: prefs);

    expect(vm.themeMode, equals(ThemeMode.dark));
    expect(vm.isDarkMode, isTrue);
  });

  test('toggleTheme toggles state and persists value to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final vm = ThemeViewModel(preferences: prefs);

    expect(vm.isDarkMode, isFalse);

    bool notified = false;
    vm.addListener(() => notified = true);

    await vm.toggleTheme();

    expect(vm.isDarkMode, isTrue);
    expect(vm.themeMode, equals(ThemeMode.dark));
    expect(notified, isTrue);
    expect(prefs.getBool(ThemeViewModel.prefKeyThemeMode), isTrue);

    // Toggle back to light
    await vm.toggleTheme();
    expect(vm.isDarkMode, isFalse);
    expect(vm.themeMode, equals(ThemeMode.light));
    expect(prefs.getBool(ThemeViewModel.prefKeyThemeMode), isFalse);
  });

  test('setThemeMode sets specific mode and persists to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final vm = ThemeViewModel(preferences: prefs);

    await vm.setThemeMode(ThemeMode.dark);
    expect(vm.isDarkMode, isTrue);
    expect(prefs.getBool(ThemeViewModel.prefKeyThemeMode), isTrue);

    await vm.setThemeMode(ThemeMode.light);
    expect(vm.isDarkMode, isFalse);
    expect(prefs.getBool(ThemeViewModel.prefKeyThemeMode), isFalse);
  });
}
