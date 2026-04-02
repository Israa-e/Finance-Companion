import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefKey = 'dark_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
    : super(
        _prefs.getBool(_prefKey) != false ? ThemeMode.dark : ThemeMode.light,
      );

  Future<void> toggleTheme(bool enabled) async {
    await _prefs.setBool(_prefKey, enabled);
    emit(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
