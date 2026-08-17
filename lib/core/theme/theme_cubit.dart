import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedString = prefs.getString(_prefKey);
      if (savedString != null) {
        if (savedString == 'dark') {
          emit(ThemeMode.dark);
        } else if (savedString == 'light') {
          emit(ThemeMode.light);
        } else {
          emit(ThemeMode.system);
        }
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (_) {}
  }
}
