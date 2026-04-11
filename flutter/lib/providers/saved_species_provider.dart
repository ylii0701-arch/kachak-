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

  bool isSaved(String speciesId) => _ids.contains(speciesId);

  Future<void> toggleSaved(String speciesId) async {
    final wasSaved = _ids.contains(speciesId);

    // 1. Optimistically update the list in memory and UI
    if (wasSaved) {
      _ids.remove(speciesId);
    } else {
      _ids.add(speciesId);
    }
    notifyListeners();

    // 2. Try to save to device storage (setString returns false if it fails)
    final success = await _prefs.setString(_storageKey, jsonEncode(_ids.toList()));

    // 3. If storage fails, revert the memory state and throw an error
    if (!success) {
      if (wasSaved) {
        _ids.add(speciesId); // Put it back
      } else {
        _ids.remove(speciesId); // Remove it again
      }
      notifyListeners();
      throw Exception('Storage full or unavailable.');
    }
  }
}