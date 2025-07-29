// lib/theme/theme_notifier.dart

import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);
  ThemeMode get getThemeMode => _themeMode;

  void toggleTheme() {
    // Se o tema atual for escuro, muda para claro, e vice-versa.
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}