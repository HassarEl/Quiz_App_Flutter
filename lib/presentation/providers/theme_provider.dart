import 'package:flutter/material.dart';
import '../../core/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  Future<void> loadTheme() async {
    final v = LocalStorageService.prefs.getString(LocalStorageService.kThemeMode);
    themeMode = switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> toggle() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await LocalStorageService.prefs.setString(
      LocalStorageService.kThemeMode,
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }
}
