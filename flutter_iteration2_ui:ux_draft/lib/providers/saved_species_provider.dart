import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

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

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _ids
          ..clear()
          ..addAll(list.cast<String>());
      } catch (_) {}
    }

    final rawNotif = _prefs.getString(_notifKey);
    if (rawNotif != null && rawNotif.isNotEmpty) {
      try {
        final list = jsonDecode(rawNotif) as List<dynamic>;
        _notifiedIds
          ..clear()
          ..addAll(list.cast<String>());
      } catch (_) {}
    }
  }

  bool isSaved(String speciesId) => _ids.contains(speciesId);

  bool isNotified(String speciesId) => _notifiedIds.contains(speciesId);

  Future<void> toggleSaved(String speciesId) async {
    final wasSaved = _ids.contains(speciesId);
    final wasNotified = _notifiedIds.contains(speciesId);

    // Optimistically update local state first.
    if (wasSaved) {
      _ids.remove(speciesId);
      // Extra 1: Automatically turn off notifications if no longer a favorite.
      if (wasNotified) {
        _notifiedIds.remove(speciesId);
        await localNotifs.cancel(speciesId.hashCode);
        await _prefs.setString(_notifKey, jsonEncode(_notifiedIds.toList()));
      }
    } else {
      _ids.add(speciesId);
    }
    notifyListeners();

    // Persist; rollback if storage fails.
    final success = await _prefs.setString(_storageKey, jsonEncode(_ids.toList()));
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

  Future<bool> toggleNotification(String speciesId) async {
    if (!_ids.contains(speciesId)) return false;

    final wasNotified = _notifiedIds.contains(speciesId);

    if (!wasNotified) {
      // Prompt OS notification permission.
      final status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        return false;
      }

      _notifiedIds.add(speciesId);
      // Simulate backend engine detecting high probability conditions.
      await _scheduleLocalAlert(speciesId);
    } else {
      _notifiedIds.remove(speciesId);
      await localNotifs.cancel(speciesId.hashCode);
    }

    notifyListeners();
    await _prefs.setString(_notifKey, jsonEncode(_notifiedIds.toList()));
    return true;
  }

  Future<void> _scheduleLocalAlert(String speciesId) async {
    const androidDetails = AndroidNotificationDetails(
      'high_prob_channel',
      'High Probability Alerts',
      channelDescription: 'Alerts for optimal photography conditions',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    // Simulation: Firing the alert 10 seconds after toggle for verification.
    Future.delayed(const Duration(seconds: 10), () {
      if (_notifiedIds.contains(speciesId)) {
        localNotifs.show(
          speciesId.hashCode,
          'Optimal Conditions Detected!',
          'High activity expected tomorrow morning in your area.',
          notifDetails,
          payload: 'Clear skies tomorrow morning. Best time: 06:00 AM. Location: Selangor, Malaysia',
        );
      }
    });
  }
}