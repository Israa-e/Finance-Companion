import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _prefKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs)
      : super(
          Locale(_prefs.getString(_prefKey) ?? 'en'),
        );

  Future<void> setLocale(String languageCode) async {
    await _prefs.setString(_prefKey, languageCode);
    emit(Locale(languageCode));
  }
}
