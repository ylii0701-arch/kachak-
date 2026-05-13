import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CityForecastEntry {
  const CityForecastEntry({
    required this.timestamp,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
  });

  final DateTime timestamp;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double rainfall;
}

class CityWeatherBundle {
  const CityWeatherBundle({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.forecast,
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double rainfall;
  final List<CityForecastEntry> forecast;
}

class OpenWeatherService {
  const OpenWeatherService({required this.apiKey});

  final String apiKey;

  Future<CityWeatherBundle> fetchCityWeather({
    required String cityName,
    required double lat,
    required double lon,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('OpenWeather API key is missing.');
    }

    final currentUri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
          '?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );
    final forecastUri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast'
          '?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    // Initialize SharedPreferences and define cache keys for this specific city
    final prefs = await SharedPreferences.getInstance();
    final currentCacheKey = 'weather_current_$cityName';
    final forecastCacheKey = 'weather_forecast_$cityName';

    try {
      // Attempt to fetch the latest weather data from the network
      final responses = await Future.wait([
        http.get(currentUri),
        http.get(forecastUri),
      ]);

      final currentResponse = responses[0];
      final forecastResponse = responses[1];

      if (currentResponse.statusCode != 200) {
        throw Exception(
          'OpenWeather current weather failed for $cityName (${currentResponse.statusCode})',
        );
      }
      if (forecastResponse.statusCode != 200) {
        throw Exception(
          'OpenWeather forecast failed for $cityName (${forecastResponse.statusCode})',
        );
      }

      // Fetch successful. Overwrite the local cache with the latest raw JSON strings.
      await prefs.setString(currentCacheKey, currentResponse.body);
      await prefs.setString(forecastCacheKey, forecastResponse.body);

      return _parseWeatherBundle(
        cityName: cityName,
        currentBody: currentResponse.body,
        forecastBody: forecastResponse.body,
      );
    } catch (e) {
      // If network request fails or an Exception occurs, attempt to read from local cache
      final cachedCurrent = prefs.getString(currentCacheKey);
      final cachedForecast = prefs.getString(forecastCacheKey);

      if (cachedCurrent != null && cachedForecast != null) {
        debugPrint('⚠️ Network failed. Using offline cached weather data for $cityName');
        return _parseWeatherBundle(
          cityName: cityName,
          currentBody: cachedCurrent,
          forecastBody: cachedForecast,
        );
      }

      // If no cache is available, rethrow the error to be handled by the UI (e.g., show Toast)
      rethrow;
    }
  }

  /// Extracted JSON parsing logic to be shared between fresh API data and cached offline data.
  CityWeatherBundle _parseWeatherBundle({
    required String cityName,
    required String currentBody,
    required String forecastBody,
  }) {
    final Map<String, dynamic> jsonMap =
    json.decode(currentBody) as Map<String, dynamic>;
    final main = jsonMap['main'] as Map<String, dynamic>? ?? {};
    final weatherList = jsonMap['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = jsonMap['wind'] as Map<String, dynamic>? ?? {};

    // Parse current rainfall (OpenWeather usually provides it under 'rain' -> '1h')
    final rain = jsonMap['rain'] as Map<String, dynamic>? ?? {};
    final rainfall = (rain['1h'] as num?)?.toDouble() ?? 0.0;

    final forecastMap =
    json.decode(forecastBody) as Map<String, dynamic>;
    final forecastList = forecastMap['list'] as List<dynamic>? ?? const [];
    final forecast = forecastList
        .map((raw) => raw as Map<String, dynamic>)
        .map(_toForecastEntry)
        .whereType<CityForecastEntry>()
        .take(8) // Retain original logic: limit to 8 entries (24 hours) for UI display
        .toList(growable: false);

    return CityWeatherBundle(
      cityName: cityName,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Unknown',
      iconCode: weather['icon']?.toString() ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      rainfall: rainfall,
      forecast: forecast,
    );
  }

  CityForecastEntry? _toForecastEntry(Map<String, dynamic> jsonMap) {
    final timestampSeconds = jsonMap['dt'] as num?;
    if (timestampSeconds == null) return null;

    final main = jsonMap['main'] as Map<String, dynamic>? ?? {};
    final weatherList = jsonMap['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = jsonMap['wind'] as Map<String, dynamic>? ?? {};

    // Parse forecast rainfall (OpenWeather usually provides it under 'rain' -> '3h')
    final rain = jsonMap['rain'] as Map<String, dynamic>? ?? {};
    final rainfall = (rain['3h'] as num?)?.toDouble() ?? 0.0;

    return CityForecastEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestampSeconds.toInt() * 1000,
      ),
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Unknown',
      iconCode: weather['icon']?.toString() ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      rainfall: rainfall, // Added: Rainfall data
    );
  }
}