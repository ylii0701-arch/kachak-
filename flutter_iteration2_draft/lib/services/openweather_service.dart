import 'dart:convert';

import 'package:http/http.dart' as http;

class CityForecastEntry {
  const CityForecastEntry({
    required this.timestamp,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  final DateTime timestamp;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
}

class CityWeatherBundle {
  const CityWeatherBundle({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.forecast,
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
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

    final Map<String, dynamic> jsonMap =
        json.decode(currentResponse.body) as Map<String, dynamic>;
    final main = jsonMap['main'] as Map<String, dynamic>? ?? {};
    final weatherList = jsonMap['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = jsonMap['wind'] as Map<String, dynamic>? ?? {};
    final forecastMap =
        json.decode(forecastResponse.body) as Map<String, dynamic>;
    final forecastList = forecastMap['list'] as List<dynamic>? ?? const [];
    final forecast = forecastList
        .map((raw) => raw as Map<String, dynamic>)
        .map(_toForecastEntry)
        .whereType<CityForecastEntry>()
        .take(8)
        .toList(growable: false);

    return CityWeatherBundle(
      cityName: cityName,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Unknown',
      iconCode: weather['icon']?.toString() ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
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

    return CityForecastEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestampSeconds.toInt() * 1000,
      ),
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Unknown',
      iconCode: weather['icon']?.toString() ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }
}
