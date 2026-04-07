import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedSpeciesProvider extends ChangeNotifier {
  SavedSpeciesProvider(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _storageKey = 'kachak-saved-species';

  final Set<String> _ids = {};

  Set<String> get savedIds => Set.unmodifiable(_ids);

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _ids
        ..clear()
        ..addAll(list.cast<String>());
    } catch (_) {}
  }

  Future<void> _persist() async {
    await _prefs.setString(_storageKey, jsonEncode(_ids.toList()));
  }

  bool isSaved(String speciesId) => _ids.contains(speciesId);

  Future<void> toggleSaved(String speciesId) async {
    if (_ids.contains(speciesId)) {
      _ids.remove(speciesId);
    } else {
      _ids.add(speciesId);
    }
    await _persist();
    notifyListeners();
  }
}
