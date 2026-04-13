import 'dart:convert';

import 'package:http/http.dart' as http;

class CityWeatherForecastPoint {
  const CityWeatherForecastPoint({
    required this.time,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  final DateTime time;
  final double temperature;
  final String description;
  final String iconCode;
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
    required this.fetchedAt,
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final List<CityWeatherForecastPoint> forecast;
  final DateTime fetchedAt;
}

class OpenWeatherService {
  const OpenWeatherService({required this.apiKey});

  final String apiKey;

  Future<CityWeatherBundle> fetchCityWeather({
    required String cityName,
    required double lat,
    required double lon,
  }) async {
    if (apiKey == 'PASTE_OPENWEATHER_API_KEY_HERE' || apiKey.isEmpty) {
      throw Exception('OpenWeather API key is missing.');
    }

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast'
      '?lat=$lat&lon=$lon&appid=$apiKey&units=metric&cnt=6',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'OpenWeather request failed for $cityName (${response.statusCode})',
      );
    }

    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;

    final List<dynamic> list = (jsonMap['list'] as List<dynamic>? ?? []);
    if (list.isEmpty) {
      throw Exception('No forecast returned for $cityName');
    }

    final first = list.first as Map<String, dynamic>;
    final firstMain = first['main'] as Map<String, dynamic>? ?? {};
    final firstWeatherList = first['weather'] as List<dynamic>? ?? const [];
    final firstWeather = firstWeatherList.isNotEmpty
        ? firstWeatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final firstWind = first['wind'] as Map<String, dynamic>? ?? {};

    final forecastPoints = list.map((item) {
      final entry = item as Map<String, dynamic>;
      final main = entry['main'] as Map<String, dynamic>? ?? {};
      final weatherList = entry['weather'] as List<dynamic>? ?? const [];
      final weather = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : <String, dynamic>{};

      return CityWeatherForecastPoint(
        time: DateTime.tryParse(entry['dt_txt']?.toString() ?? '') ??
            DateTime.now(),
        temperature: (main['temp'] as num?)?.toDouble() ?? 0,
        description: weather['description']?.toString() ?? 'Unknown',
        iconCode: weather['icon']?.toString() ?? '01d',
      );
    }).toList();

    return CityWeatherBundle(
      cityName: cityName,
      temperature: (firstMain['temp'] as num?)?.toDouble() ?? 0,
      description: firstWeather['description']?.toString() ?? 'Unknown',
      iconCode: firstWeather['icon']?.toString() ?? '01d',
      humidity: (firstMain['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (firstWind['speed'] as num?)?.toDouble() ?? 0,
      forecast: forecastPoints,
      fetchedAt: DateTime.now(),
    );
  }
}

String openWeatherIconUrl(String iconCode) =>
    'https://openweathermap.org/img/wn/$iconCode@2x.png';