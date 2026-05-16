import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tour identifiers persisted independently so that completing one tour
/// (e.g. Home) does not skip another.
enum OnboardingTour { welcome, home, saved, identify, mission, map, speciesDetail }

/// Tracks which onboarding flows the user has already seen.
///
/// State is persisted in [SharedPreferences] so that returning users do not
/// see the same hints again. Users can reset the flow from the side menu.
class OnboardingService extends ChangeNotifier {
  OnboardingService(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'kachak-onboarding-';

  /// Returns true when the user has dismissed [tour] at least once.
  bool hasSeen(OnboardingTour tour) =>
      _prefs.getBool('$_prefix${tour.name}') ?? false;

  /// Marks [tour] as completed for the current user. Safe to call multiple
  /// times.
  Future<void> markSeen(OnboardingTour tour) async {
    if (hasSeen(tour)) return;
    await _prefs.setBool('$_prefix${tour.name}', true);
    notifyListeners();
  }

  /// Clears every tour flag so that the entire tutorial replays.
  Future<void> resetAll() async {
    for (final tour in OnboardingTour.values) {
      await _prefs.remove('$_prefix${tour.name}');
    }
    notifyListeners();
  }
}
