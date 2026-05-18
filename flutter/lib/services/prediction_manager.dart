import 'dart:async';
import 'dart:ui'; // NEW: Required for Locale
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier and debugPrint
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/map_keys.dart';
import '../data/malaysia_cities.dart';
import '../data/site_data.dart';
import '../data/species_data.dart';
import '../config/site_weather_defaults.dart';
import '../models/species.dart';
import '../main.dart';
import '../providers/saved_species_provider.dart';
import '../l10n/app_localizations.dart'; // NEW: Required for translated push notifications
import 'openweather_service.dart';
import 'onnx_prediction_service.dart';
import 'web_permission_bridge.dart' as web_notif;

/// Represents a prediction result and environmental data for a specific point in time
class TimeSeriesPrediction {
  final DateTime timestamp;
  final double probability;
  final double temperature;
  final double humidity;
  final String weatherDescription;
  final String iconCode;

  TimeSeriesPrediction({
    required this.timestamp,
    required this.probability,
    required this.temperature,
    required this.humidity,
    required this.weatherDescription,
    required this.iconCode,
  });
}

class AlertCandidate {
  final String speciesId;
  final String siteId;
  final double probability;
  final double distanceToUser;

  AlertCandidate({
    required this.speciesId,
    required this.siteId,
    required this.probability,
    required this.distanceToUser,
  });
}

class PredictionManager extends ChangeNotifier {
  // Singleton pattern for global access
  static final PredictionManager instance = PredictionManager._internal();
  PredictionManager._internal();

  final OpenWeatherService _weatherService = const OpenWeatherService(apiKey: openWeatherApiKey);

  /// Stores full time-series predictions (for the 7-Day Forecast UI).
  final Map<String, Map<String, List<TimeSeriesPrediction>>> forecastPredictions = {};

  /// Stores ONLY the latest prediction (for quick access by Map Markers).
  final Map<String, Map<String, double>> latestPredictions = {};

  SavedSpeciesProvider? _savedSpeciesProvider;
  Timer? _hourlyTimer;
  bool isCalculating = false;
  DateTime? _lastCalculationTime;
  bool _engineStarted = false;
  bool _engineStarting = false;
  final bool _isMobileWeb =
      kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);

  // Setter to pass the provider without breaking existing startEngine calls
  void setAlertProvider(SavedSpeciesProvider provider) {
    _savedSpeciesProvider = provider;
  }

  /// Triggers a 5-second delayed evaluation of alerts (called when user toggles a bell)
  void triggerDelayedAlertCheck() {
    if (_savedSpeciesProvider == null) return;

    Future.delayed(const Duration(seconds: 5), () async {
      debugPrint('⏱️ 5-second delay finished. Evaluating alerts...');
      await _evaluateAndTriggerDailyAlert(_savedSpeciesProvider!, ignoreDailyLimit: false);
    });
  }

  /// 1. Start the background engine
  Future<void> startEngine() async {
    if (_engineStarted || _engineStarting) return;
    _engineStarting = true;
    try {
      await OnnxPredictionService.initModel();
      // App Boot: Pass isInitialLoad to bypass cooldown AND daily limit
      await fetchAndCalculate(isInitialLoad: true);
      _scheduleNextHourlyFetch();
      _engineStarted = true;
    } finally {
      _engineStarting = false;
    }
  }

  /// 2. Core calculation logic
  Future<void> fetchAndCalculate({bool isInitialLoad = false}) async {
    if (isCalculating) return;

    // --- Cooldown Check (Bypassed if this is the initial load) ---
    if (!isInitialLoad && _lastCalculationTime != null) {
      final difference = DateTime.now().difference(_lastCalculationTime!);
      if (difference.inMinutes < 10) {
        debugPrint('⏳ Prediction Engine: Cooldown active. Last updated ${difference.inMinutes} mins ago.');
        return;
      }
    }

    isCalculating = true;
    notifyListeners();

    debugPrint('🔄 Prediction Engine: Starting full time-series calculations...');

    try {
      var processedSpecies = 0;
      var inferenceCount = 0;
      for (final city in kMalaysianCities) {
        CityWeatherBundle? weatherBundle;

        try {
          weatherBundle = await _weatherService.fetchCityWeather(
            cityName: city.name,
            lat: city.lat,
            lon: city.lng,
          );
        } catch (e) {
          debugPrint('⚠️ Weather unavailable for ${city.name}. Using FallbackWeather.');
        }

        if (_isMobileWeb) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }

        final citySites = siteData.where((s) => s.cityName == city.name);

        for (final site in citySites) {
          forecastPredictions[site.id] ??= {};
          latestPredictions[site.id] ??= {};
          final fallback = siteWeatherDefaults[site.id] ?? siteWeatherDefaults['default']!;

          for (final speciesId in site.supportedSpeciesIds) {
            final species = speciesById(speciesId);
            if (species == null) continue;

            String targetCategory = species.category;
            if (targetCategory == Species.insects || targetCategory == Species.reptiles) {
              targetCategory = Species.amphibians;
            }

            double currentTemp = weatherBundle?.temperature ?? fallback.temp;
            double currentRain = weatherBundle?.rainfall ?? fallback.rainfall;
            double currentHumid = weatherBundle?.humidity.toDouble() ?? fallback.humidity;
            double currentWind = weatherBundle?.windSpeed ?? fallback.windSpeed;

            double currentProb = await _runInference(
                site, targetCategory, currentTemp, currentRain, currentHumid, currentWind
            ) ?? 0.0;
            inferenceCount++;

            latestPredictions[site.id]![speciesId] = currentProb;

            List<TimeSeriesPrediction> timeSeries = [];

            timeSeries.add(TimeSeriesPrediction(
              timestamp: DateTime.now().toLocal(),
              probability: currentProb,
              temperature: currentTemp,
              humidity: currentHumid,
              weatherDescription: weatherBundle?.description ?? 'Unknown',
              iconCode: weatherBundle?.iconCode ?? '01d',
            ));

            if (weatherBundle != null) {
              final forecastEntries = _isMobileWeb
                  ? weatherBundle.forecast.take(16)
                  : weatherBundle.forecast;
              for (final entry in forecastEntries) {
                double? prob = await _runInference(
                    site, targetCategory, entry.temperature, entry.rainfall,
                    entry.humidity.toDouble(), entry.windSpeed
                );
                inferenceCount++;

                if (prob != null) {
                  timeSeries.add(TimeSeriesPrediction(
                    timestamp: entry.timestamp.toLocal(),
                    probability: prob,
                    temperature: entry.temperature,
                    humidity: entry.humidity.toDouble(),
                    weatherDescription: entry.description,
                    iconCode: entry.iconCode,
                  ));
                }

                if (_isMobileWeb && inferenceCount % 2 == 0) {
                  await Future<void>.delayed(const Duration(milliseconds: 16));
                }
              }
            }
            forecastPredictions[site.id]![speciesId] = timeSeries;
            processedSpecies += 1;

            if (_isMobileWeb) {
              await Future<void>.delayed(const Duration(milliseconds: 16));
            } else if (kIsWeb && processedSpecies % 5 == 0) {
              await Future<void>.delayed(Duration.zero);
            }
          }
        }
        if (_isMobileWeb) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        } else if (kIsWeb) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      _lastCalculationTime = DateTime.now();
      debugPrint('✅ Prediction Engine: Time-series updated successfully at $_lastCalculationTime');

      // The Notification block runs at the BOTTOM so it has the freshly downloaded data
      if (_savedSpeciesProvider != null) {
        await _evaluateAndTriggerDailyAlert(_savedSpeciesProvider!, ignoreDailyLimit: isInitialLoad);
      }

    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  /// Helper method for ONNX Inference
  Future<double?> _runInference(dynamic site, String category, double temp, double rain, double humid, double wind) async {
    const int mockOcc30d = 3;
    return await OnnxPredictionService.getPrediction(
      lat: site.lat, lon: site.lng, temperature: temp, rainfall: rain,
      humidity: humid, windSpeed: wind, occ30d: mockOcc30d, animalClass: category,
    );
  }

  /// 3. Provide UI with perfectly formatted 7-Day data
  List<TimeSeriesPrediction> getSevenDayForecastForUI(String siteId, String speciesId) {
    final rawList = forecastPredictions[siteId]?[speciesId];
    if (rawList == null || rawList.isEmpty) return [];

    Map<String, TimeSeriesPrediction> dailyBest = {};
    for (var entry in rawList) {
      final localTime = entry.timestamp.toLocal();
      String dateKey = "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}";
      if (!dailyBest.containsKey(dateKey) || entry.probability > dailyBest[dateKey]!.probability) {
        dailyBest[dateKey] = entry;
      }
    }

    List<TimeSeriesPrediction> sortedDaily = dailyBest.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    List<TimeSeriesPrediction> sevenDayList = [];
    DateTime baseDate = DateTime.now().toLocal();

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = baseDate.add(Duration(days: i));

      var match = sortedDaily.where((e) {
        final eLocal = e.timestamp.toLocal();
        return eLocal.year == targetDate.year &&
            eLocal.month == targetDate.month &&
            eLocal.day == targetDate.day;
      }).firstOrNull;

      if (match != null) {
        sevenDayList.add(match);
      } else {
        var lastValid = sevenDayList.isNotEmpty ? sevenDayList.last : sortedDaily.last;
        sevenDayList.add(
            TimeSeriesPrediction(
              timestamp: targetDate,
              probability: lastValid.probability,
              temperature: lastValid.temperature,
              humidity: lastValid.humidity,
              weatherDescription: lastValid.weatherDescription,
              iconCode: lastValid.iconCode,
            )
        );
      }
    }
    return sevenDayList;
  }

  /// 4. Schedule next automatic update
  void _scheduleNextHourlyFetch() {
    _hourlyTimer?.cancel();
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    _hourlyTimer = Timer(nextHour.difference(now), () async {
      await fetchAndCalculate(isInitialLoad: false);
      _scheduleNextHourlyFetch();
    });
  }

  /// 5. Manual refresh
  Future<void> refreshManually() async {
    debugPrint('👆 Prediction Engine: Manual refresh triggered.');
    await fetchAndCalculate(isInitialLoad: false);
  }

  // ------------------------------------------------------------------
  // On-demand per-species prediction
  // ------------------------------------------------------------------

  final Set<String> _computedSpeciesSites = {};

  Future<void> fetchForSpecies(String speciesId) async {
    final species = speciesById(speciesId);
    if (species == null) return;

    final sites = siteData.where(
          (s) => s.supportedSpeciesIds.contains(speciesId),
    );

    String targetCategory = species.category;
    if (targetCategory == Species.insects || targetCategory == Species.reptiles) {
      targetCategory = Species.amphibians;
    }

    for (final site in sites) {
      final key = '${site.id}:$speciesId';
      if (_computedSpeciesSites.contains(key)) continue;

      forecastPredictions[site.id] ??= {};
      latestPredictions[site.id] ??= {};

      CityWeatherBundle? weatherBundle;
      final city = kMalaysianCities.where((c) => c.name == site.cityName).firstOrNull;
      if (city != null) {
        try {
          weatherBundle = await _weatherService.fetchCityWeather(
            cityName: city.name, lat: city.lat, lon: city.lng,
          );
        } catch (_) {}
      }

      final fallback = siteWeatherDefaults[site.id] ?? siteWeatherDefaults['default']!;

      double currentTemp = weatherBundle?.temperature ?? fallback.temp;
      double currentRain = weatherBundle?.rainfall ?? fallback.rainfall;
      double currentHumid = weatherBundle?.humidity.toDouble() ?? fallback.humidity;
      double currentWind = weatherBundle?.windSpeed ?? fallback.windSpeed;

      double currentProb = await _runInference(
        site, targetCategory, currentTemp, currentRain, currentHumid, currentWind,
      ) ?? 0.0;

      latestPredictions[site.id]![speciesId] = currentProb;

      List<TimeSeriesPrediction> timeSeries = [
        TimeSeriesPrediction(
          timestamp: DateTime.now().toLocal(),
          probability: currentProb,
          temperature: currentTemp,
          humidity: currentHumid,
          weatherDescription: weatherBundle?.description ?? 'Unknown',
          iconCode: weatherBundle?.iconCode ?? '01d',
        ),
      ];

      if (weatherBundle != null) {
        var fcIdx = 0;
        for (final entry in weatherBundle.forecast) {
          double? prob = await _runInference(
            site, targetCategory, entry.temperature, entry.rainfall,
            entry.humidity.toDouble(), entry.windSpeed,
          );
          fcIdx++;
          if (prob != null) {
            timeSeries.add(TimeSeriesPrediction(
              timestamp: entry.timestamp.toLocal(),
              probability: prob,
              temperature: entry.temperature,
              humidity: entry.humidity.toDouble(),
              weatherDescription: entry.description,
              iconCode: entry.iconCode,
            ));
          }
          if (_isMobileWeb && fcIdx % 3 == 0) {
            await Future<void>.delayed(const Duration(milliseconds: 8));
          }
        }
      }

      forecastPredictions[site.id]![speciesId] = timeSeries;
      _computedSpeciesSites.add(key);

      if (_isMobileWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
    }

    notifyListeners();
  }

  /// The Daily Alert Notification Algorithm (Now with Dynamic Localization)
  Future<void> _evaluateAndTriggerDailyAlert(SavedSpeciesProvider savedProvider, {bool ignoreDailyLimit = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastAlertDateStr = prefs.getString('last_daily_alert_date');

    if (!ignoreDailyLimit && lastAlertDateStr == todayStr) {
      debugPrint('🚫 Daily alert already sent today. Skipping.');
      return;
    }

    final savedIds = savedProvider.savedIds;
    if (savedIds.isEmpty) return;

    Position userLocation;
    try {
      userLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      userLocation = Position(
        latitude: 3.1390, longitude: 101.6869, timestamp: now,
        accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0,
      );
    }

    List<AlertCandidate> candidates = [];
    Set<String> animalsMeetingCriteria = {};

    for (final siteId in forecastPredictions.keys) {
      final site = siteData.firstWhere((s) => s.id == siteId);
      final distance = Geolocator.distanceBetween(
        userLocation.latitude, userLocation.longitude, site.lat, site.lng,
      );
      final sitePredictions = forecastPredictions[siteId]!;

      for (final speciesId in sitePredictions.keys) {
        if (!savedIds.contains(speciesId)) continue;
        if (!savedProvider.isNotified(speciesId)) continue;

        final timeSeries = sitePredictions[speciesId]!;
        double maxProbToday = 0.0;

        for (final pred in timeSeries) {
          if (pred.timestamp.day == now.day && pred.timestamp.month == now.month && pred.timestamp.year == now.year) {
            if (pred.probability > maxProbToday) {
              maxProbToday = pred.probability;
            }
          }
        }

        if (maxProbToday >= 0.8) {
          animalsMeetingCriteria.add(speciesId);
          candidates.add(AlertCandidate(
            speciesId: speciesId, siteId: siteId,
            probability: maxProbToday, distanceToUser: distance,
          ));
        }
      }
    }

    if (candidates.isEmpty) return;

    candidates.sort((a, b) {
      int probComparison = b.probability.compareTo(a.probability);
      if (probComparison != 0) return probComparison;

      int distanceComparison = a.distanceToUser.compareTo(b.distanceToUser);
      if (distanceComparison != 0) return distanceComparison;

      return a.speciesId.compareTo(b.speciesId);
    });

    final topCandidate = candidates.first;

    // --- LOAD DYNAMIC LANGUAGE FOR NOTIFICATIONS ---
    final localeStr = prefs.getString('app_locale') ?? 'en';
    final l10n = await AppLocalizations.delegate.load(Locale(localeStr));

    final title = l10n.notificationHighProbTitle;
    final body = l10n.notificationHighProbBody(animalsMeetingCriteria.length);

    if (kIsWeb) {
      // Use browser Notification API on web
      await web_notif.showWebNotification(title: title, body: body);
    } else {
      const androidDetails = AndroidNotificationDetails(
        'high_prob_channel', 'High Probability Alerts',
        importance: Importance.max, priority: Priority.high,
      );
      await localNotifs.show(
        0, title, body,
        const NotificationDetails(android: androidDetails),
        payload: topCandidate.speciesId,
      );
    }

    // Update SharedPreferences to log that we fired the alert today
    await prefs.setString('last_daily_alert_date', todayStr);
  }
} ///end