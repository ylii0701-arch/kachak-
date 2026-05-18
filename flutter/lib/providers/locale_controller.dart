import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Timer? _debounce;

  void _load() {
    final saved = _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      _locale = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_key, locale.languageCode);

    // Debounce the rebuild to avoid heavy tree rebuilds during rapid switches
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
