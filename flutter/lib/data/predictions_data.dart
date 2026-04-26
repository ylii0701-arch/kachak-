import 'package:intl/intl.dart';

/// Represents a single day's forecast within a prediction sequence.
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

/// Core prediction model linking a species to a specific site and its forecast.
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

/// Lightweight model used for rendering prediction summary cards in lists.
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

/// Helper to generate dynamic dates formatted as YYYY-MM-DD.
/// Allows forecast data to always begin from the current device date.
String _getDynamicDate(int daysOffset) {
  final dt = DateTime.now().add(Duration(days: daysOffset));
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Baseline 7-day pattern for diurnal (day-active) species.
List<DailyPrediction> get _dayPattern => [
  DailyPrediction(date: _getDynamicDate(0), probability: 'High', probabilityPercent: 88, weather: 'Sunny', temperature: 29, humidity: 75, timeOfDay: 'Morning'),
  DailyPrediction(date: _getDynamicDate(1), probability: 'High', probabilityPercent: 92, weather: 'Sunny', temperature: 30, humidity: 72, timeOfDay: 'Dawn'),
  DailyPrediction(date: _getDynamicDate(2), probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 28, humidity: 78, timeOfDay: 'Morning'),
  DailyPrediction(date: _getDynamicDate(3), probability: 'Medium', probabilityPercent: 65, weather: 'Cloudy', temperature: 27, humidity: 82, timeOfDay: 'Morning'),
  DailyPrediction(date: _getDynamicDate(4), probability: 'Low', probabilityPercent: 35, weather: 'Rainy', temperature: 26, humidity: 90, timeOfDay: 'Morning'),
  DailyPrediction(date: _getDynamicDate(5), probability: 'Medium', probabilityPercent: 55, weather: 'Partly Cloudy', temperature: 28, humidity: 80, timeOfDay: 'Dawn'),
  DailyPrediction(date: _getDynamicDate(6), probability: 'High', probabilityPercent: 78, weather: 'Sunny', temperature: 29, humidity: 76, timeOfDay: 'Morning'),
];

/// Baseline 7-day pattern for nocturnal (night-active) species.
List<DailyPrediction> get _nightPattern => [
  DailyPrediction(date: _getDynamicDate(0), probability: 'High', probabilityPercent: 90, weather: 'Sunny', temperature: 26, humidity: 80, timeOfDay: 'Night'),
  DailyPrediction(date: _getDynamicDate(1), probability: 'High', probabilityPercent: 85, weather: 'Partly Cloudy', temperature: 25, humidity: 82, timeOfDay: 'Night'),
  DailyPrediction(date: _getDynamicDate(2), probability: 'High', probabilityPercent: 82, weather: 'Sunny', temperature: 26, humidity: 80, timeOfDay: 'Dusk'),
  DailyPrediction(date: _getDynamicDate(3), probability: 'Medium', probabilityPercent: 60, weather: 'Cloudy', temperature: 24, humidity: 85, timeOfDay: 'Night'),
  DailyPrediction(date: _getDynamicDate(4), probability: 'Medium', probabilityPercent: 55, weather: 'Rainy', temperature: 23, humidity: 90, timeOfDay: 'Night'),
  DailyPrediction(date: _getDynamicDate(5), probability: 'Low', probabilityPercent: 30, weather: 'Rainy', temperature: 22, humidity: 92, timeOfDay: 'Night'),
  DailyPrediction(date: _getDynamicDate(6), probability: 'High', probabilityPercent: 72, weather: 'Partly Cloudy', temperature: 25, humidity: 84, timeOfDay: 'Night'),
];

/// Map of species IDs to their primary prediction profiles.
/// Uses getters for patterns to ensure dates are generated at access time.
Map<String, SpeciesPrediction> get speciesPredictions => {
  // Mammals
  '1': SpeciesPrediction(speciesId: '1', locationName: 'Taman Negara', distance: 18.5, lat: 3.205, lng: 101.729, primaryFactor: 'Time', forecast: _dayPattern),
  '2': SpeciesPrediction(speciesId: '2', locationName: 'Sepilok Center', distance: 12.3, lat: 5.865, lng: 117.950, primaryFactor: 'Weather', forecast: _dayPattern),
  '3': SpeciesPrediction(speciesId: '3', locationName: 'Bukit Nanas', distance: 8.7, lat: 3.159, lng: 101.699, primaryFactor: 'Time', forecast: _dayPattern),
  '4': SpeciesPrediction(speciesId: '4', locationName: 'Kinabatangan River', distance: 25.2, lat: 5.510, lng: 118.250, primaryFactor: 'Time', forecast: _dayPattern),
  '5': SpeciesPrediction(speciesId: '5', locationName: 'Sungai Congkak', distance: 25.4, lat: 3.265, lng: 101.845, primaryFactor: 'Humidity', forecast: _nightPattern),
  '6': SpeciesPrediction(speciesId: '6', locationName: 'Royal Belum', distance: 17.8, lat: 5.717, lng: 101.450, primaryFactor: 'Time', forecast: _dayPattern),
  '10': SpeciesPrediction(speciesId: '10', locationName: 'Kuala Selangor', distance: 45.2, lat: 3.339, lng: 101.245, primaryFactor: 'Weather', forecast: _nightPattern),
  '11': SpeciesPrediction(speciesId: '11', locationName: 'Taman Negara', distance: 18.9, lat: 3.199, lng: 101.719, primaryFactor: 'Time', forecast: _nightPattern),
  '12': SpeciesPrediction(speciesId: '12', locationName: 'Taman Negara Pahang', distance: 19.5, lat: 3.209, lng: 101.729, primaryFactor: 'Time', forecast: _nightPattern),
  '13': SpeciesPrediction(speciesId: '13', locationName: 'Royal Belum', distance: 210.0, lat: 5.717, lng: 101.450, primaryFactor: 'Time', forecast: _nightPattern),
  '14': SpeciesPrediction(speciesId: '14', locationName: 'Deramakot Reserve', distance: 1650.0, lat: 5.383, lng: 117.083, primaryFactor: 'Weather', forecast: _nightPattern),
  '18': SpeciesPrediction(speciesId: '18', locationName: 'Taman Negara', distance: 20.0, lat: 3.20, lng: 101.72, primaryFactor: 'Weather', forecast: _nightPattern),
  '19': SpeciesPrediction(speciesId: '19', locationName: 'Lake Gardens KL', distance: 2.0, lat: 3.14, lng: 101.68, primaryFactor: 'Time', forecast: _nightPattern),
  '20': SpeciesPrediction(speciesId: '20', locationName: 'Fraser\'s Hill', distance: 95.0, lat: 3.71, lng: 101.73, primaryFactor: 'Time', forecast: _dayPattern),
  '21': SpeciesPrediction(speciesId: '21', locationName: 'FRIM', distance: 9.5, lat: 3.23, lng: 101.63, primaryFactor: 'Humidity', forecast: _nightPattern),
  '22': SpeciesPrediction(speciesId: '22', locationName: 'Kuala Selangor', distance: 46.0, lat: 3.34, lng: 101.25, primaryFactor: 'Time', forecast: _nightPattern),
  '23': SpeciesPrediction(speciesId: '23', locationName: 'Kinabatangan River', distance: 25.0, lat: 5.51, lng: 118.25, primaryFactor: 'Weather', forecast: _dayPattern),
  '100': SpeciesPrediction(speciesId: '100', locationName: 'Subang Jaya (Under a Rock)', distance: 0.1, lat: 3.048, lng: 101.585, primaryFactor: 'Time', forecast: _dayPattern),

  // Birds, Reptiles, Amphibians, Insects
  '7': SpeciesPrediction(speciesId: '7', locationName: 'Panti Forest', distance: 21.3, lat: 1.850, lng: 103.883, primaryFactor: 'Weather', forecast: _dayPattern),
  '8': SpeciesPrediction(speciesId: '8', locationName: 'FRIM', distance: 9.1, lat: 3.235, lng: 101.635, primaryFactor: 'Time', forecast: _nightPattern),
  '9': SpeciesPrediction(speciesId: '9', locationName: 'Lankayan Island', distance: 45.8, lat: 6.502, lng: 117.917, primaryFactor: 'Temperature', forecast: _dayPattern),
  '15': SpeciesPrediction(speciesId: '15', locationName: 'Panti Forest', distance: 320.0, lat: 1.850, lng: 103.883, primaryFactor: 'Time', forecast: _dayPattern),
  '16': SpeciesPrediction(speciesId: '16', locationName: 'Fraser\'s Hill', distance: 95.0, lat: 3.712, lng: 101.737, primaryFactor: 'Weather', forecast: _nightPattern),
  '17': SpeciesPrediction(speciesId: '17', locationName: 'Genting Highlands', distance: 45.0, lat: 3.424, lng: 101.767, primaryFactor: 'Weather', forecast: _dayPattern),
  '24': SpeciesPrediction(speciesId: '24', locationName: 'Taman Negara', distance: 19.0, lat: 3.19, lng: 101.71, primaryFactor: 'Time', forecast: _dayPattern),
  '25': SpeciesPrediction(speciesId: '25', locationName: 'Belum Forest', distance: 212.0, lat: 5.72, lng: 101.45, primaryFactor: 'Weather', forecast: _dayPattern),
  '26': SpeciesPrediction(speciesId: '26', locationName: 'Klang Estuary', distance: 30.0, lat: 3.00, lng: 101.35, primaryFactor: 'Weather', forecast: _dayPattern),
  '27': SpeciesPrediction(speciesId: '27', locationName: 'Endau-Rompin', distance: 280.0, lat: 2.44, lng: 103.27, primaryFactor: 'Humidity', forecast: _dayPattern),
  '28': SpeciesPrediction(speciesId: '28', locationName: 'Bukit Fraser', distance: 96.0, lat: 3.72, lng: 101.74, primaryFactor: 'Time', forecast: _dayPattern),
  '29': SpeciesPrediction(speciesId: '29', locationName: 'Maxwell Hill', distance: 250.0, lat: 4.86, lng: 100.76, primaryFactor: 'Time', forecast: _dayPattern),
  '30': SpeciesPrediction(speciesId: '30', locationName: 'Kuala Gula', distance: 270.0, lat: 4.93, lng: 100.47, primaryFactor: 'Weather', forecast: _dayPattern),
  '31': SpeciesPrediction(speciesId: '31', locationName: 'Pasoh Forest', distance: 120.0, lat: 2.97, lng: 102.31, primaryFactor: 'Time', forecast: _dayPattern),
  '32': SpeciesPrediction(speciesId: '32', locationName: 'Sungai Enam', distance: 15.0, lat: 5.80, lng: 101.50, primaryFactor: 'Time', forecast: _dayPattern),
  '33': SpeciesPrediction(speciesId: '33', locationName: 'Panti Forest', distance: 22.0, lat: 1.86, lng: 103.89, primaryFactor: 'Time', forecast: _dayPattern),
  '34': SpeciesPrediction(speciesId: '34', locationName: 'RDC Sandakan', distance: 15.0, lat: 5.87, lng: 117.94, primaryFactor: 'Weather', forecast: _dayPattern),
  '35': SpeciesPrediction(speciesId: '35', locationName: 'Tabin Wildlife', distance: 40.0, lat: 5.18, lng: 118.86, primaryFactor: 'Time', forecast: _dayPattern),
  '36': SpeciesPrediction(speciesId: '36', locationName: 'Royal Belum', distance: 215.0, lat: 5.75, lng: 101.50, primaryFactor: 'Weather', forecast: _dayPattern),
  '37': SpeciesPrediction(speciesId: '37', locationName: 'Ulu Gombak', distance: 22.0, lat: 3.32, lng: 101.77, primaryFactor: 'Weather', forecast: _dayPattern),
  '38': SpeciesPrediction(speciesId: '38', locationName: 'Lake Titiwangsa', distance: 4.0, lat: 3.17, lng: 101.70, primaryFactor: 'Time', forecast: _dayPattern),
  '39': SpeciesPrediction(speciesId: '39', locationName: 'Kinabatangan River', distance: 25.0, lat: 5.51, lng: 118.25, primaryFactor: 'Weather', forecast: _dayPattern),
  '40': SpeciesPrediction(speciesId: '40', locationName: 'Bako National Park', distance: 20.0, lat: 1.71, lng: 110.44, primaryFactor: 'Time', forecast: _nightPattern),
  '41': SpeciesPrediction(speciesId: '41', locationName: 'Gunung Mulu', distance: 50.0, lat: 4.04, lng: 114.81, primaryFactor: 'Humidity', forecast: _nightPattern),
  '42': SpeciesPrediction(speciesId: '42', locationName: 'Kubah National Park', distance: 22.0, lat: 1.60, lng: 110.19, primaryFactor: 'Weather', forecast: _nightPattern),
  '43': SpeciesPrediction(speciesId: '43', locationName: 'Endau-Rompin', distance: 285.0, lat: 2.45, lng: 103.28, primaryFactor: 'Time', forecast: _nightPattern),
  '44': SpeciesPrediction(speciesId: '44', locationName: 'Backyard Gardens', distance: 0.5, lat: 3.07, lng: 101.58, primaryFactor: 'Time', forecast: _nightPattern),
  '45': SpeciesPrediction(speciesId: '45', locationName: 'City Parks', distance: 3.0, lat: 3.15, lng: 101.69, primaryFactor: 'Time', forecast: _nightPattern),
  '46': SpeciesPrediction(speciesId: '46', locationName: 'Cameron Highlands', distance: 200.0, lat: 4.47, lng: 101.38, primaryFactor: 'Weather', forecast: _dayPattern),
  '47': SpeciesPrediction(speciesId: '47', locationName: 'Genting Highlands', distance: 48.0, lat: 3.43, lng: 101.77, primaryFactor: 'Time', forecast: _nightPattern),
  '48': SpeciesPrediction(speciesId: '48', locationName: 'Templer Park', distance: 20.0, lat: 3.29, lng: 101.65, primaryFactor: 'Weather', forecast: _dayPattern),
  '49': SpeciesPrediction(speciesId: '49', locationName: 'Ulu Yam', distance: 35.0, lat: 3.44, lng: 101.66, primaryFactor: 'Weather', forecast: _nightPattern),
  '50': SpeciesPrediction(speciesId: '50', locationName: 'Ampang Forest', distance: 12.0, lat: 3.16, lng: 101.78, primaryFactor: 'Time', forecast: _dayPattern),
};

/// Curated prediction summaries organized strictly by recognized MalaysianCity names.
/// Decoupled from aggregate region buckets to support precise city filtering.
const Map<Region, List<LocationPredictionCard>> locationPredictions = {
  // --- CENTRAL REGION ---
  'Kuala Lumpur': [
    LocationPredictionCard(speciesId: '1', probabilityPercent: 85, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '3', probabilityPercent: 88, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '19', probabilityPercent: 85, probability: 'High', bestTime: 'Dusk', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '38', probabilityPercent: 95, probability: 'High', bestTime: 'Afternoon', bestWeather: 'Sunny'),
  ],
  'Subang Jaya': [
    LocationPredictionCard(speciesId: '44', probabilityPercent: 98, probability: 'High', bestTime: 'Night', bestWeather: 'Rainy'),
    LocationPredictionCard(speciesId: '45', probabilityPercent: 98, probability: 'High', bestTime: 'Night', bestWeather: 'Rainy'),
    LocationPredictionCard(speciesId: '100', probabilityPercent: 100, probability: 'High', bestTime: 'Nap-time', bestWeather: 'Wet'),
  ],
  'Petaling Jaya': [
    LocationPredictionCard(speciesId: '5', probabilityPercent: 58, probability: 'Medium', bestTime: 'Morning', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '21', probabilityPercent: 75, probability: 'High', bestTime: 'Night', bestWeather: 'Humid'),
  ],
  'Shah Alam': [
    LocationPredictionCard(speciesId: '8', probabilityPercent: 90, probability: 'High', bestTime: 'Night', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '10', probabilityPercent: 82, probability: 'High', bestTime: 'Night', bestWeather: 'Sunny'),
  ],
  'Klang': [
    LocationPredictionCard(speciesId: '26', probabilityPercent: 92, probability: 'High', bestTime: 'Mid-day', bestWeather: 'Sunny'),
  ],

  // --- NORTHERN REGION ---
  'George Town': [
    LocationPredictionCard(speciesId: '3', probabilityPercent: 88, probability: 'High', bestTime: 'Dawn', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '29', probabilityPercent: 85, probability: 'High', bestTime: 'Morning', bestWeather: 'Clear'),
  ],
  'Seberang Perai': [
    LocationPredictionCard(speciesId: '30', probabilityPercent: 80, probability: 'High', bestTime: 'Dawn', bestWeather: 'Overcast'),
  ],
  'Ipoh': [
    LocationPredictionCard(speciesId: '8', probabilityPercent: 88, probability: 'High', bestTime: 'Night', bestWeather: 'Partly Cloudy'),
  ],
  'Alor Setar': [
    LocationPredictionCard(speciesId: '44', probabilityPercent: 98, probability: 'High', bestTime: 'Night', bestWeather: 'Rainy'),
  ],

  // --- SOUTHERN REGION ---
  'Johor Bahru': [
    LocationPredictionCard(speciesId: '1', probabilityPercent: 80, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '7', probabilityPercent: 85, probability: 'High', bestTime: 'Morning', bestWeather: 'Partly Cloudy'),
  ],
  'Iskandar Puteri': [
    LocationPredictionCard(speciesId: '12', probabilityPercent: 70, probability: 'High', bestTime: 'Night', bestWeather: 'Cloudy'),
  ],
  'Pasir Gudang': [
    LocationPredictionCard(speciesId: '15', probabilityPercent: 75, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
  ],
  'Melaka City': [
    LocationPredictionCard(speciesId: '5', probabilityPercent: 60, probability: 'Medium', bestTime: 'Morning', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '13', probabilityPercent: 65, probability: 'High', bestTime: 'Dusk', bestWeather: 'Cloudy'),
  ],
  'Seremban': [
    LocationPredictionCard(speciesId: '27', probabilityPercent: 82, probability: 'High', bestTime: 'Morning', bestWeather: 'Humid'),
  ],

  // --- EAST COAST REGION ---
  'Kuantan': [
    LocationPredictionCard(speciesId: '11', probabilityPercent: 85, probability: 'High', bestTime: 'Night', bestWeather: 'Partly Cloudy'),
  ],
  'Kuala Terengganu': [
    LocationPredictionCard(speciesId: '17', probabilityPercent: 88, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
  ],
  'Kota Bharu': [
    LocationPredictionCard(speciesId: '50', probabilityPercent: 90, probability: 'High', bestTime: 'Day', bestWeather: 'Sunny'),
  ],

  // --- BORNEO (EAST MALAYSIA) ---
  'Kota Kinabalu': [
    LocationPredictionCard(speciesId: '2', probabilityPercent: 88, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '4', probabilityPercent: 85, probability: 'High', bestTime: 'Dusk', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '23', probabilityPercent: 90, probability: 'High', bestTime: 'Afternoon', bestWeather: 'Sunny'),
  ],
  'Kuching': [
    LocationPredictionCard(speciesId: '1', probabilityPercent: 80, probability: 'High', bestTime: 'Dawn', bestWeather: 'Partly Cloudy'),
    LocationPredictionCard(speciesId: '40', probabilityPercent: 72, probability: 'High', bestTime: 'Night', bestWeather: 'Rainy'),
    LocationPredictionCard(speciesId: '42', probabilityPercent: 88, probability: 'High', bestTime: 'Night', bestWeather: 'Rainy'),
  ],
  'Miri': [
    LocationPredictionCard(speciesId: '9', probabilityPercent: 82, probability: 'High', bestTime: 'Morning', bestWeather: 'Sunny'),
    LocationPredictionCard(speciesId: '14', probabilityPercent: 68, probability: 'High', bestTime: 'Night', bestWeather: 'Cloudy'),
    LocationPredictionCard(speciesId: '34', probabilityPercent: 60, probability: 'Medium', bestTime: 'Morning', bestWeather: 'Clear'),
    LocationPredictionCard(speciesId: '41', probabilityPercent: 65, probability: 'Medium', bestTime: 'Night', bestWeather: 'Mist'),
  ],
};