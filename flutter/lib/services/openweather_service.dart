import 'dart:convert';

import 'package:http/http.dart' as http;

class CityWeatherBundle {
  const CityWeatherBundle({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
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

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'OpenWeather request failed for $cityName (${response.statusCode})',
      );
    }

    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    final main = jsonMap['main'] as Map<String, dynamic>? ?? {};
    final weatherList = jsonMap['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = jsonMap['wind'] as Map<String, dynamic>? ?? {};

    return CityWeatherBundle(
      cityName: cityName,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather['description']?.toString() ?? 'Unknown',
      iconCode: weather['icon']?.toString() ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }
}
