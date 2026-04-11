// Generated from src/app/data/predictions.ts

class DailyPrediction {
  const DailyPrediction({
    required this.date,
    required this.probability,
    required this.probabilityPercent,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.timeOfDay,
  });
  final String date;
  final String probability;
  final int probabilityPercent;
  final String weather;
  final int temperature;
  final int humidity;
  final String timeOfDay;
}

class SpeciesPrediction {
  const SpeciesPrediction({
    required this.speciesId,
    required this.locationName,
    required this.distance,
    required this.lat,
    required this.lng,
    required this.primaryFactor,
    required this.forecast,
  });
  final String speciesId;
  final String locationName;
  final double distance;
  final double lat;
  final double lng;
  final String primaryFactor;
  final List<DailyPrediction> forecast;
}

class LocationPredictionCard {
  const LocationPredictionCard({
    required this.speciesId,
    required this.probabilityPercent,
    required this.probability,
    required this.bestTime,
    required this.bestWeather,
  });
  final String speciesId;
  final int probabilityPercent;
  final String probability;
  final String bestTime;
  final String bestWeather;
}

typedef Region = String;

const Map<String, SpeciesPrediction> speciesPredictions = {
  '1': SpeciesPrediction(
    speciesId: '1',
    locationName: 'Taman Negara National Park',
    distance: 18.5,
    lat: 3.205,
    lng: 101.729,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 82, weather: 'Sunny', temperature: 30, humidity: 75, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-06', probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 27, humidity: 85, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 78, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 60, weather: 'Rainy', temperature: 26, humidity: 90, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 35, weather: 'Rainy', temperature: 25, humidity: 92, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 55, weather: 'Cloudy', temperature: 27, humidity: 87, timeOfDay: 'Morning'),
    ],
  ),
  '2': SpeciesPrediction(
    speciesId: '2',
    locationName: 'FRIM Wildlife Reserve',
    distance: 12.3,
    lat: 3.235,
    lng: 101.635,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 60, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 75, weather: 'Sunny', temperature: 31, humidity: 72, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 80, weather: 'Sunny', temperature: 30, humidity: 70, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 68, weather: 'Partly Cloudy', temperature: 29, humidity: 75, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'Low', probabilityPercent: 40, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 30, weather: 'Rainy', temperature: 25, humidity: 92, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 50, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Afternoon'),
    ],
  ),
  '3': SpeciesPrediction(
    speciesId: '3',
    locationName: 'Bukit Nanas Forest Reserve',
    distance: 8.7,
    lat: 3.159,
    lng: 101.699,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 88, weather: 'Sunny', temperature: 30, humidity: 75, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 90, weather: 'Sunny', temperature: 31, humidity: 73, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 29, humidity: 76, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 82, weather: 'Partly Cloudy', temperature: 28, humidity: 78, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 55, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 75, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Dawn'),
    ],
  ),
  '4': SpeciesPrediction(
    speciesId: '4',
    locationName: 'Taman Negara National Park',
    distance: 19.2,
    lat: 3.199,
    lng: 101.719,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Low', probabilityPercent: 25, weather: 'Sunny', temperature: 30, humidity: 72, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-05', probability: 'Low', probabilityPercent: 30, weather: 'Partly Cloudy', temperature: 29, humidity: 75, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-06', probability: 'Medium', probabilityPercent: 45, weather: 'Cloudy', temperature: 27, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 55, weather: 'Partly Cloudy', temperature: 28, humidity: 78, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 50, weather: 'Cloudy', temperature: 26, humidity: 85, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-09', probability: 'High', probabilityPercent: 70, weather: 'Rainy', temperature: 25, humidity: 90, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 60, weather: 'Cloudy', temperature: 27, humidity: 87, timeOfDay: 'Dusk'),
    ],
  ),
  '5': SpeciesPrediction(
    speciesId: '5',
    locationName: 'Sungai Congkak Forest Reserve',
    distance: 25.4,
    lat: 3.265,
    lng: 101.845,
    primaryFactor: 'Humidity',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 58, weather: 'Partly Cloudy', temperature: 29, humidity: 82, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-05', probability: 'Low', probabilityPercent: 40, weather: 'Sunny', temperature: 32, humidity: 68, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-06', probability: 'Low', probabilityPercent: 35, weather: 'Sunny', temperature: 31, humidity: 70, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 60, weather: 'Cloudy', temperature: 28, humidity: 85, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'High', probabilityPercent: 85, weather: 'Rainy', temperature: 26, humidity: 92, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-09', probability: 'High', probabilityPercent: 88, weather: 'Rainy', temperature: 25, humidity: 95, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 27, humidity: 88, timeOfDay: 'Morning'),
    ],
  ),
  '6': SpeciesPrediction(
    speciesId: '6',
    locationName: 'Taman Negara National Park',
    distance: 17.8,
    lat: 3.189,
    lng: 101.709,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 55, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-05', probability: 'Medium', probabilityPercent: 60, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 72, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 75, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-08', probability: 'High', probabilityPercent: 78, weather: 'Cloudy', temperature: 26, humidity: 88, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 65, weather: 'Rainy', temperature: 25, humidity: 90, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 70, weather: 'Cloudy', temperature: 27, humidity: 85, timeOfDay: 'Dusk'),
    ],
  ),
  '7': SpeciesPrediction(
    speciesId: '7',
    locationName: 'Taman Negara National Park',
    distance: 21.3,
    lat: 3.225,
    lng: 101.735,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 80, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 85, weather: 'Sunny', temperature: 30, humidity: 75, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-06', probability: 'Medium', probabilityPercent: 68, weather: 'Cloudy', temperature: 28, humidity: 82, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 75, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 60, weather: 'Rainy', temperature: 27, humidity: 88, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 45, weather: 'Rainy', temperature: 26, humidity: 90, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 28, humidity: 85, timeOfDay: 'Afternoon'),
    ],
  ),
  '8': SpeciesPrediction(
    speciesId: '8',
    locationName: 'Bukit Nanas Forest Reserve',
    distance: 9.1,
    lat: 3.159,
    lng: 101.689,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 90, weather: 'Sunny', temperature: 30, humidity: 75, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 92, weather: 'Sunny', temperature: 31, humidity: 72, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 88, weather: 'Partly Cloudy', temperature: 29, humidity: 76, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 70, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 60, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 78, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Dawn'),
    ],
  ),
  '9': SpeciesPrediction(
    speciesId: '9',
    locationName: 'Sungai Congkak Forest Reserve',
    distance: 26.8,
    lat: 3.169,
    lng: 101.699,
    primaryFactor: 'Temperature',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 55, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 75, weather: 'Sunny', temperature: 32, humidity: 70, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 78, weather: 'Sunny', temperature: 31, humidity: 72, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 65, weather: 'Partly Cloudy', temperature: 30, humidity: 75, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-08', probability: 'Low', probabilityPercent: 35, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 30, weather: 'Rainy', temperature: 25, humidity: 90, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 50, weather: 'Cloudy', temperature: 28, humidity: 82, timeOfDay: 'Afternoon'),
    ],
  ),
  '10': SpeciesPrediction(
    speciesId: '10',
    locationName: 'Kuala Selangor Nature Park',
    distance: 45.2,
    lat: 3.339,
    lng: 101.245,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 82, weather: 'Sunny', temperature: 30, humidity: 80, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 85, weather: 'Sunny', temperature: 31, humidity: 78, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 80, weather: 'Partly Cloudy', temperature: 30, humidity: 82, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 78, weather: 'Sunny', temperature: 31, humidity: 80, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 60, weather: 'Cloudy', temperature: 28, humidity: 85, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 40, weather: 'Rainy', temperature: 27, humidity: 88, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 65, weather: 'Partly Cloudy', temperature: 29, humidity: 83, timeOfDay: 'Afternoon'),
    ],
  ),
  '11': SpeciesPrediction(
    speciesId: '11',
    locationName: 'Taman Negara National Park',
    distance: 18.9,
    lat: 3.199,
    lng: 101.719,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 28, humidity: 78, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 88, weather: 'Sunny', temperature: 29, humidity: 75, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 90, weather: 'Partly Cloudy', temperature: 28, humidity: 76, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 82, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 70, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 65, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 75, weather: 'Cloudy', temperature: 27, humidity: 85, timeOfDay: 'Dusk'),
    ],
  ),
  '12': SpeciesPrediction(
    speciesId: '12',
    locationName: 'Taman Negara National Park',
    distance: 19.5,
    lat: 3.209,
    lng: 101.729,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 60, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-05', probability: 'Medium', probabilityPercent: 65, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 72, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 75, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-08', probability: 'High', probabilityPercent: 78, weather: 'Cloudy', temperature: 26, humidity: 85, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 68, weather: 'Rainy', temperature: 25, humidity: 90, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 70, weather: 'Cloudy', temperature: 27, humidity: 88, timeOfDay: 'Night'),
    ],
  ),
  '13': SpeciesPrediction(
    speciesId: '13',
    locationName: 'Royal Belum State Park',
    distance: 210.0,
    lat: 5.717,
    lng: 101.450,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Low', probabilityPercent: 25, weather: 'Partly Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-05', probability: 'Low', probabilityPercent: 28, weather: 'Cloudy', temperature: 27, humidity: 84, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-06', probability: 'Medium', probabilityPercent: 42, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 48, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-08', probability: 'Low', probabilityPercent: 32, weather: 'Rainy', temperature: 25, humidity: 90, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 30, weather: 'Rainy', temperature: 25, humidity: 91, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 40, weather: 'Cloudy', temperature: 27, humidity: 86, timeOfDay: 'Night'),
    ],
  ),
  '14': SpeciesPrediction(
    speciesId: '14',
    locationName: 'Deramakot Forest Reserve',
    distance: 1650.0,
    lat: 5.383,
    lng: 117.083,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 55, weather: 'Partly Cloudy', temperature: 28, humidity: 82, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 68, weather: 'Cloudy', temperature: 27, humidity: 84, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 72, weather: 'Rainy', temperature: 26, humidity: 88, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-07', probability: 'High', probabilityPercent: 70, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 58, weather: 'Rainy', temperature: 26, humidity: 89, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-09', probability: 'Medium', probabilityPercent: 52, weather: 'Cloudy', temperature: 27, humidity: 86, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 65, weather: 'Partly Cloudy', temperature: 28, humidity: 81, timeOfDay: 'Night'),
    ],
  ),
  '15': SpeciesPrediction(
    speciesId: '15',
    locationName: 'Panti Forest Reserve',
    distance: 320.0,
    lat: 1.850,
    lng: 103.883,
    primaryFactor: 'Time',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'Medium', probabilityPercent: 50, weather: 'Partly Cloudy', temperature: 29, humidity: 78, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 62, weather: 'Sunny', temperature: 30, humidity: 76, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 65, weather: 'Partly Cloudy', temperature: 29, humidity: 80, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 55, weather: 'Cloudy', temperature: 28, humidity: 84, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-08', probability: 'Low', probabilityPercent: 38, weather: 'Rainy', temperature: 27, humidity: 90, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-09', probability: 'Low', probabilityPercent: 35, weather: 'Rainy', temperature: 26, humidity: 92, timeOfDay: 'Dawn'),
      DailyPrediction(date: '2026-04-10', probability: 'Medium', probabilityPercent: 48, weather: 'Cloudy', temperature: 28, humidity: 85, timeOfDay: 'Morning'),
    ],
  ),
  '16': SpeciesPrediction(
    speciesId: '16',
    locationName: 'Fraser\'s Hill',
    distance: 95.0,
    lat: 3.712,
    lng: 101.737,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 72, weather: 'Cloudy', temperature: 20, humidity: 88, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 75, weather: 'Rainy', temperature: 19, humidity: 90, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 78, weather: 'Rainy', temperature: 19, humidity: 91, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 60, weather: 'Partly Cloudy', temperature: 21, humidity: 84, timeOfDay: 'Dusk'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 58, weather: 'Cloudy', temperature: 20, humidity: 87, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-09', probability: 'High', probabilityPercent: 70, weather: 'Rainy', temperature: 19, humidity: 92, timeOfDay: 'Night'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 74, weather: 'Rainy', temperature: 19, humidity: 90, timeOfDay: 'Night'),
    ],
  ),
  '17': SpeciesPrediction(
    speciesId: '17',
    locationName: 'Mulu National Park vicinity',
    distance: 1420.0,
    lat: 4.050,
    lng: 114.883,
    primaryFactor: 'Weather',
    forecast: [
      DailyPrediction(date: '2026-04-04', probability: 'High', probabilityPercent: 80, weather: 'Sunny', temperature: 31, humidity: 76, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-05', probability: 'High', probabilityPercent: 82, weather: 'Partly Cloudy', temperature: 30, humidity: 78, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-06', probability: 'High', probabilityPercent: 78, weather: 'Sunny', temperature: 31, humidity: 74, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-07', probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 29, humidity: 82, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-08', probability: 'Medium', probabilityPercent: 58, weather: 'Rainy', temperature: 28, humidity: 86, timeOfDay: 'Afternoon'),
      DailyPrediction(date: '2026-04-09', probability: 'High', probabilityPercent: 72, weather: 'Partly Cloudy', temperature: 30, humidity: 80, timeOfDay: 'Morning'),
      DailyPrediction(date: '2026-04-10', probability: 'High', probabilityPercent: 76, weather: 'Sunny', temperature: 31, humidity: 77, timeOfDay: 'Morning'),
    ],
  ),
};

const Map<Region, List<LocationPredictionCard>> locationPredictions = {
  'Kuala Lumpur': [
    LocationPredictionCard(speciesId: '8', probabilityPercent: 90, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '3', probabilityPercent: 85, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '7', probabilityPercent: 80, probability: 'High', bestTime: 'Morning', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '11', probabilityPercent: 85, probability: 'High', bestTime: 'Dusk', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '1', probabilityPercent: 82, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '2', probabilityPercent: 75, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
  ],
  'Sabah & Sarawak': [
    LocationPredictionCard(speciesId: '5', probabilityPercent: 88, probability: 'High', bestTime: 'Morning', bestWeather: 'Rainy'),
    LocationPredictionCard(speciesId: '2', probabilityPercent: 85, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '4', probabilityPercent: 70, probability: 'Medium', bestTime: 'Night', bestWeather: 'Rainy'),
    LocationPredictionCard(speciesId: '6', probabilityPercent: 75, probability: 'High', bestTime: 'Dusk', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '1', probabilityPercent: 80, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '12', probabilityPercent: 72, probability: 'High', bestTime: 'Night', bestWeather: 'Cloudy'),
  ],
  'Penang': [
    LocationPredictionCard(speciesId: '3', probabilityPercent: 88, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '8', probabilityPercent: 85, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '10', probabilityPercent: 82, probability: 'High', bestTime: 'Afternoon', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '9', probabilityPercent: 75, probability: 'High', bestTime: 'Afternoon', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '11', probabilityPercent: 78, probability: 'High', bestTime: 'Dusk', bestWeather: 'Partly Cloudy'),
  ],
  'Johor': [
    LocationPredictionCard(speciesId: '7', probabilityPercent: 85, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '6', probabilityPercent: 78, probability: 'High', bestTime: 'Dusk', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '9', probabilityPercent: 75, probability: 'High', bestTime: 'Afternoon', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '1', probabilityPercent: 80, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '12', probabilityPercent: 70, probability: 'High', bestTime: 'Night', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '4', probabilityPercent: 65, probability: 'Medium', bestTime: 'Night', bestWeather: 'Rainy'),
  ],
};
