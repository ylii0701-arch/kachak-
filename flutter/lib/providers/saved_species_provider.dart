import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../services/prediction_manager.dart';
import '../services/web_permission_bridge.dart' as web_notif;

/// Stores favorite species and local alert preferences in SharedPreferences.
class SavedSpeciesProvider extends ChangeNotifier {
  SavedSpeciesProvider(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _storageKey = 'kachak-saved-species';
  static const _notifKey = 'kachak-notified-species';

  final Set<String> _ids = {};
  final Set<String> _notifiedIds = {};

  Set<String> get savedIds => Set.unmodifiable(_ids);

  /// Hydrates provider state from local storage on startup.
  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _ids
          ..clear()
          ..addAll(list.cast<String>());
      } catch (_) {
        // Ignore malformed data and fall back to empty set.
      }
    }

    final rawNotif = _prefs.getString(_notifKey);
    if (rawNotif != null && rawNotif.isNotEmpty) {
      try {
        final list = jsonDecode(rawNotif) as List<dynamic>;
        _notifiedIds
          ..clear()
          ..addAll(list.cast<String>());
      } catch (_) {
        // Ignore malformed data and fall back to empty set.
      }
    }
  }

  bool isSaved(String speciesId) => _ids.contains(speciesId);

  bool isNotified(String speciesId) => _notifiedIds.contains(speciesId);

  /// Adds/removes a species from saved list and persists the update.
  Future<void> toggleSaved(String speciesId) async {
    final wasSaved = _ids.contains(speciesId);
    final wasNotified = _notifiedIds.contains(speciesId);

    // Optimistically update local state first.
    if (wasSaved) {
      _ids.remove(speciesId);
      // Extra 1: Automatically turn off notifications if no longer a favorite.
      if (wasNotified) {
        _notifiedIds.remove(speciesId);
        if (!kIsWeb) {
          await localNotifs.cancel(speciesId.hashCode);
        }
        await _prefs.setString(_notifKey, jsonEncode(_notifiedIds.toList()));
      }
    } else {
      _ids.add(speciesId);
    }
    notifyListeners();

    // Persist; rollback if storage fails.
    final success = await _prefs.setString(
      _storageKey,
      jsonEncode(_ids.toList()),
    );
    if (!success) {
      if (wasSaved) {
        _ids.add(speciesId);
        if (wasNotified) {
          _notifiedIds.add(speciesId);
          await _prefs.setString(_notifKey, jsonEncode(_notifiedIds.toList()));
        }
      } else {
        _ids.remove(speciesId);
      }
      notifyListeners();
      throw Exception('Storage full or unavailable.');
    }
  }

  /// Enables/disables local notifications for a saved species.
  /// On web, alerts are handled in-app (no browser notification needed).
  /// On native, uses permission_handler + flutter_local_notifications.
  Future<bool> toggleNotification(String speciesId) async {
    if (!_ids.contains(speciesId)) return false;

    final wasNotified = _notifiedIds.contains(speciesId);

    if (!wasNotified) {
      if (kIsWeb) {
        final granted = await web_notif.requestWebNotificationPermission();
        if (!granted) {
          debugPrint('⚠️ Web notification permission denied or unsupported.');
        }
      } else {
        final status = await Permission.notification.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          return false;
        }
      }

      _notifiedIds.add(speciesId);

      // Trigger the prediction manager to check alerts after 5 seconds
      PredictionManager.instance.triggerDelayedAlertCheck();

    } else {
      _notifiedIds.remove(speciesId);
      if (!kIsWeb) {
        await localNotifs.cancel(speciesId.hashCode);
      }
    }

    notifyListeners();
    await _prefs.setString(_notifKey, jsonEncode(_notifiedIds.toList()));
    return true;
  }
}