import 'dart:async';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier and debugPrint

import '../config/map_keys.dart';
import '../data/malaysia_cities.dart';
import '../data/site_data.dart';
import '../data/species_data.dart';
import '../config/site_weather_defaults.dart';
import '../models/species.dart';
import 'openweather_service.dart';
import 'onnx_prediction_service.dart';

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

class PredictionManager extends ChangeNotifier {
  // Singleton pattern for global access
  static final PredictionManager instance = PredictionManager._internal();
  PredictionManager._internal();

  final OpenWeatherService _weatherService = const OpenWeatherService(apiKey: openWeatherApiKey);

  /// Stores full time-series predictions (for the 7-Day Forecast UI).
  /// Structure: { 'siteId': { 'speciesId': [TimeSeriesPrediction, ...] } }
  final Map<String, Map<String, List<TimeSeriesPrediction>>> forecastPredictions = {};

  /// Stores ONLY the latest prediction (for quick access by Map Markers).
  /// Structure: { 'siteId': { 'speciesId': 0.85 } }
  final Map<String, Map<String, double>> latestPredictions = {};

  Timer? _hourlyTimer;
  bool isCalculating = false;
  DateTime? _lastCalculationTime;
  bool _engineStarted = false;
  bool _engineStarting = false;
  final bool _isMobileWeb =
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// 1. Start the background engine
  Future<void> startEngine() async {
    if (_engineStarted || _engineStarting) return;
    _engineStarting = true;
    try {
      await fetchAndCalculate();
      _scheduleNextHourlyFetch();
      _engineStarted = true;
    } finally {
      _engineStarting = false;
    }
  }

  /// 2. Core calculation logic (with 10-minute cooldown)
  Future<void> fetchAndCalculate() async {
    if (isCalculating) return;

    // --- Cooldown Check ---
    if (_lastCalculationTime != null) {
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

            // --- A. Calculate CURRENT prediction for the Map ---
            double currentTemp = weatherBundle?.temperature ?? fallback.temp;
            double currentRain = weatherBundle?.rainfall ?? fallback.rainfall;
            double currentHumid = weatherBundle?.humidity.toDouble() ?? fallback.humidity;
            double currentWind = weatherBundle?.windSpeed ?? fallback.windSpeed;

            double currentProb = await _runInference(
                site, targetCategory, currentTemp, currentRain, currentHumid, currentWind
            ) ?? 0.0;

            latestPredictions[site.id]![speciesId] = currentProb;

            // --- B. Calculate FORECAST predictions (Time-Series) ---
            List<TimeSeriesPrediction> timeSeries = [];

            // Add "Right Now" as the first entry
            timeSeries.add(TimeSeriesPrediction(
              timestamp: DateTime.now().toLocal(),
              probability: currentProb,
              temperature: currentTemp,
              humidity: currentHumid,
              weatherDescription: weatherBundle?.description ?? 'Unknown',
              iconCode: weatherBundle?.iconCode ?? '01d',
            ));

            // Add the 3-hourly forecasts from OpenWeather
            if (weatherBundle != null) {
              for (final entry in weatherBundle.forecast) {
                double? prob = await _runInference(
                    site, targetCategory, entry.temperature, entry.rainfall,
                    entry.humidity.toDouble(), entry.windSpeed
                );

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
              }
            }
            forecastPredictions[site.id]![speciesId] = timeSeries;
            processedSpecies += 1;
            if (_isMobileWeb && processedSpecies % 3 == 0) {
              await Future<void>.delayed(const Duration(milliseconds: 1));
            } else if (kIsWeb && processedSpecies % 8 == 0) {
              await Future<void>.delayed(Duration.zero);
            }
          }
        }
        if (_isMobileWeb) {
          await Future<void>.delayed(const Duration(milliseconds: 2));
        } else if (kIsWeb) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      _lastCalculationTime = DateTime.now();
      debugPrint('✅ Prediction Engine: Time-series updated successfully at $_lastCalculationTime');

    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  /// Helper method for ONNX Inference
  Future<double?> _runInference(dynamic site, String category, double temp, double rain, double humid, double wind) async {
    const int mockOcc30d = 3; // Placeholder until occurrence data source is integrated.
    return await OnnxPredictionService.getPrediction(
      lat: site.lat, lon: site.lng, temperature: temp, rainfall: rain,
      humidity: humid, windSpeed: wind, occ30d: mockOcc30d, animalClass: category,
    );
  }

  /// 3. Provide UI with perfectly formatted 7-Day data
  List<TimeSeriesPrediction> getSevenDayForecastForUI(String siteId, String speciesId) {
    final rawList = forecastPredictions[siteId]?[speciesId];
    if (rawList == null || rawList.isEmpty) return [];

    // Group by Local Date (YYYY-MM-DD) and keep the highest probability entry for each day
    Map<String, TimeSeriesPrediction> dailyBest = {};
    for (var entry in rawList) {
      // Ensure we use the local timezone to avoid matching errors across midnight
      final localTime = entry.timestamp.toLocal();
      String dateKey = "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}";
      if (!dailyBest.containsKey(dateKey) || entry.probability > dailyBest[dateKey]!.probability) {
        dailyBest[dateKey] = entry;
      }
    }

    List<TimeSeriesPrediction> sortedDaily = dailyBest.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Ensure we return exactly 7 days
    List<TimeSeriesPrediction> sevenDayList = [];
    DateTime baseDate = DateTime.now().toLocal();

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = baseDate.add(Duration(days: i));

      // Accurately match Year, Month, and Day
      var match = sortedDaily.where((e) {
        final eLocal = e.timestamp.toLocal();
        return eLocal.year == targetDate.year &&
            eLocal.month == targetDate.month &&
            eLocal.day == targetDate.day;
      }).firstOrNull;

      if (match != null) {
        sevenDayList.add(match);
      } else {
        // If API data runs out (e.g., Day 6 & 7), clone the last available day's environment data
        var lastValid = sevenDayList.isNotEmpty ? sevenDayList.last : sortedDaily.last;
        sevenDayList.add(
            TimeSeriesPrediction(
              timestamp: targetDate, // Update to the correct future date
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
      await fetchAndCalculate();
      _scheduleNextHourlyFetch();
    });
  }

  /// 5. Manual refresh
  Future<void> refreshManually() async {
    debugPrint('👆 Prediction Engine: Manual refresh triggered.');
    await fetchAndCalculate();
  }
} ///end