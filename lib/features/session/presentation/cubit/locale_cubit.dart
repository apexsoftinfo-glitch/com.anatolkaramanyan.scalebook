import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const String _localeKey = 'selected_locale';

  LocaleCubit(this._prefs) : super(_loadInitialLocale(_prefs));

  static Locale _loadInitialLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    // Fallback to system locale or Polish as default for this app
    return const Locale('pl');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  void toggleLocale() {
    if (state.languageCode == 'pl') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('pl'));
    }
  }
}
