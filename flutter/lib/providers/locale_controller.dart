import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale selection and persistence.
class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  /// Current app locale used by [MaterialApp.locale].
  Locale get locale => _locale;

  Timer? _debounce;

  /// Loads the persisted language code from shared preferences.
  void _load() {
    final saved = _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) {
      _locale = Locale(saved);
    }
  }

  /// Updates locale, persists it, and debounces listener notifications.
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
  /// Cancels pending debounce work before disposal.
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
