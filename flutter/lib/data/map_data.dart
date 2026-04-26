import 'package:latlong2/latlong.dart';
import 'site_data.dart';

class SpeciesLocation {
  const SpeciesLocation({
    required this.id,
    required this.speciesId,
    required this.lat,
    required this.lng,
    required this.lastSeen,
  });

  final String id;
  final String speciesId;
  final double lat;
  final double lng;
  final String lastSeen;
}

class PhotographySpot {
  const PhotographySpot({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.habitatType,
    required this.accessibility,
    required this.publicAccess,
    required this.speciesIds,
    required this.description,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String habitatType;
  final String accessibility;
  final bool publicAccess;
  final List<String> speciesIds;
  final String description;
}

class RestrictedZone {
  const RestrictedZone({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.type,
    required this.reason,
    required this.description,
  });

  final String id;
  final String name;
  final List<LatLng> coordinates;
  final String type;
  final String reason;
  final String description;
}

class ProtectedArea {
  const ProtectedArea({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.type,
    required this.description,
    required this.established,
  });

  final String id;
  final String name;
  final List<LatLng> coordinates;
  final String type;
  final String description;
  final String established;
}

class WeatherData {
  const WeatherData({
    required this.lat,
    required this.lng,
    required this.temperature,
    required this.humidity,
    required this.condition,
  });

  final double lat;
  final double lng;
  final int temperature;
  final int humidity;
  final String condition;
}

const List<SpeciesLocation> speciesLocations = [
  SpeciesLocation(id: 'loc1', speciesId: '1', lat: 3.2050, lng: 101.7290, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc2', speciesId: '1', lat: 3.1850, lng: 101.7050, lastSeen: '2026-03-30'),
  SpeciesLocation(id: 'loc3', speciesId: '2', lat: 3.1690, lng: 101.6950, lastSeen: '2026-03-28'),
  SpeciesLocation(id: 'loc4', speciesId: '3', lat: 3.2150, lng: 101.7150, lastSeen: '2026-04-02'),
  SpeciesLocation(id: 'loc5', speciesId: '3', lat: 3.1750, lng: 101.7250, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc6', speciesId: '3', lat: 3.1550, lng: 101.6750, lastSeen: '2026-03-31'),
  SpeciesLocation(id: 'loc7', speciesId: '4', lat: 3.1990, lng: 101.7190, lastSeen: '2026-03-29'),
  SpeciesLocation(id: 'loc8', speciesId: '5', lat: 3.1450, lng: 101.6850, lastSeen: '2026-04-02'),
  SpeciesLocation(id: 'loc9', speciesId: '5', lat: 3.1650, lng: 101.6950, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc10', speciesId: '6', lat: 3.1890, lng: 101.7090, lastSeen: '2026-03-30'),
  SpeciesLocation(id: 'loc11', speciesId: '7', lat: 3.2250, lng: 101.7350, lastSeen: '2026-04-02'),
  SpeciesLocation(id: 'loc12', speciesId: '7', lat: 3.1950, lng: 101.7250, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc13', speciesId: '8', lat: 3.1590, lng: 101.6890, lastSeen: '2026-04-03'),
  SpeciesLocation(id: 'loc14', speciesId: '8', lat: 3.1790, lng: 101.7090, lastSeen: '2026-04-02'),
  SpeciesLocation(id: 'loc15', speciesId: '8', lat: 3.1490, lng: 101.6790, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc16', speciesId: '9', lat: 3.1690, lng: 101.6990, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc17', speciesId: '10', lat: 3.1290, lng: 101.6690, lastSeen: '2026-03-30'),
  SpeciesLocation(id: 'loc18', speciesId: '11', lat: 3.1990, lng: 101.7190, lastSeen: '2026-04-02'),
  SpeciesLocation(id: 'loc19', speciesId: '11', lat: 3.1790, lng: 101.7090, lastSeen: '2026-04-01'),
  SpeciesLocation(id: 'loc20', speciesId: '12', lat: 3.2090, lng: 101.7290, lastSeen: '2026-03-28'),
  SpeciesLocation(id: 'loc21', speciesId: '13', lat: 3.1980, lng: 101.7120, lastSeen: '2026-03-25'),
  SpeciesLocation(id: 'loc22', speciesId: '14', lat: 5.3820, lng: 117.0810, lastSeen: '2026-03-22'),
  SpeciesLocation(id: 'loc23', speciesId: '15', lat: 2.0150, lng: 103.4420, lastSeen: '2026-03-30'),
  SpeciesLocation(id: 'loc24', speciesId: '17', lat: 4.0480, lng: 114.8800, lastSeen: '2026-04-02'),
];

// Dynamically generate map markers directly from siteData
// This ensures the map and the prediction engine share the exact same locations
final List<PhotographySpot> photographySpots = siteData.map((site) {
  return PhotographySpot(
    id: site.id,
    name: site.name,
    lat: site.lat,
    lng: site.lng,
    habitatType: site.type,
    accessibility: site.accessibility,
    publicAccess: !site.isCaptive, // Captive sites (Zoos) require tickets, treated as non-public access here
    speciesIds: site.supportedSpeciesIds,
    description: site.description,
  );
}).toList();

List<LatLng> _ring(List<List<double>> pairs) =>
    pairs.map((p) => LatLng(p[0], p[1])).toList();

final List<RestrictedZone> restrictedZones = [
  RestrictedZone(
    id: 'zone1',
    name: 'Military Training Area',
    coordinates: _ring([
      [3.2450, 101.7650],
      [3.2550, 101.7650],
      [3.2550, 101.7850],
      [3.2450, 101.7850],
    ]),
    type: 'Restricted',
    reason: 'Military Training Zone',
    description: 'Restricted military area. No public access allowed.',
  ),
  RestrictedZone(
    id: 'zone2',
    name: 'Water Catchment Reserve',
    coordinates: _ring([
      [3.2850, 101.6950],
      [3.2950, 101.6950],
      [3.2950, 101.7150],
      [3.2850, 101.7150],
    ]),
    type: 'Restricted',
    reason: 'Permit Required',
    description: 'Water catchment area. Special permit required for entry.',
  ),
  RestrictedZone(
    id: 'zone3',
    name: 'Landslide Risk Zone',
    coordinates: _ring([
      [3.1350, 101.7350],
      [3.1450, 101.7350],
      [3.1450, 101.7550],
      [3.1350, 101.7550],
    ]),
    type: 'Unsafe',
    reason: 'Landslide Risk',
    description:
    'High landslide risk area, especially during rainy season. Entry not recommended.',
  ),
  RestrictedZone(
    id: 'zone4',
    name: 'Steep Cliff Area',
    coordinates: _ring([
      [3.1750, 101.7450],
      [3.1850, 101.7450],
      [3.1850, 101.7650],
      [3.1750, 101.7650],
    ]),
    type: 'Unsafe',
    reason: 'Steep Terrain',
    description: 'Dangerous cliff area with unstable ground. Avoid during wet conditions.',
  ),
];

final List<ProtectedArea> protectedAreas = [
  ProtectedArea(
    id: 'protected1',
    name: 'Taman Negara National Park',
    coordinates: _ring([
      [3.1950, 101.7150],
      [3.2150, 101.7150],
      [3.2150, 101.7450],
      [3.1950, 101.7450],
    ]),
    type: 'National Park',
    description:
    'One of the oldest rainforests in the world. Home to diverse wildlife including elephants, tigers, and hornbills.',
    established: '1938',
  ),
  ProtectedArea(
    id: 'protected2',
    name: 'Bukit Nanas Forest Reserve',
    coordinates: _ring([
      [3.1490, 101.6890],
      [3.1690, 101.6890],
      [3.1690, 101.7090],
      [3.1490, 101.7090],
    ]),
    type: 'Forest Reserve',
    description:
    'Urban forest reserve in the heart of Kuala Lumpur. Excellent for birdwatching and small mammals.',
    established: '1906',
  ),
  ProtectedArea(
    id: 'protected3',
    name: 'FRIM Wildlife Reserve',
    coordinates: _ring([
      [3.2250, 101.6250],
      [3.2450, 101.6250],
      [3.2450, 101.6450],
      [3.2250, 101.6450],
    ]),
    type: 'Wildlife Reserve',
    description:
    'Research forest with canopy walkway. Important habitat for hornbills and primates.',
    established: '1929',
  ),
  ProtectedArea(
    id: 'protected4',
    name: 'Sungai Congkak Forest Reserve',
    coordinates: _ring([
      [3.2550, 101.8350],
      [3.2750, 101.8350],
      [3.2750, 101.8550],
      [3.2550, 101.8550],
    ]),
    type: 'Forest Reserve',
    description:
    'Riverine forest with recreational facilities. Popular for eco-tourism and wildlife observation.',
    established: '1964',
  ),
];

List<SpeciesLocation> speciesLocationsForSpecies(String speciesId) =>
    speciesLocations.where((l) => l.speciesId == speciesId).toList();

List<PhotographySpot> photographySpotsForSpeciesId(String speciesId) =>
    photographySpots.where((s) => s.speciesIds.contains(speciesId)).toList();

const List<WeatherData> mockWeatherData = [
  WeatherData(lat: 3.1390, lng: 101.6869, temperature: 32, humidity: 75, condition: 'Partly Cloudy'),
  WeatherData(lat: 3.2050, lng: 101.7290, temperature: 28, humidity: 85, condition: 'Cloudy'),
  WeatherData(lat: 3.1590, lng: 101.6990, temperature: 30, humidity: 80, condition: 'Sunny'),
  WeatherData(lat: 3.2350, lng: 101.6350, temperature: 27, humidity: 82, condition: 'Partly Cloudy'),
  WeatherData(lat: 3.1290, lng: 101.6690, temperature: 31, humidity: 78, condition: 'Sunny'),
];

bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  final lat = point.latitude;
  final lng = point.longitude;
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final lat1 = polygon[i].latitude;
    final lng1 = polygon[i].longitude;
    final lat2 = polygon[j].latitude;
    final lng2 = polygon[j].longitude;
    final intersect =
        ((lng1 > lng) != (lng2 > lng)) && (lat < (lat2 - lat1) * (lng - lng1) / (lng2 - lng1) + lat1);
    if (intersect) inside = !inside;
  }
  return inside;
}

WeatherData closestWeather(double lat, double lng) {
  WeatherData closest = mockWeatherData.first;
  var minD = double.infinity;
  for (final w in mockWeatherData) {
    final d = (w.lat - lat) * (w.lat - lat) + (w.lng - lng) * (w.lng - lng);
    if (d < minD) {
      minD = d;
      closest = w;
    }
  }
  return closest;
}

PhotographySpot? photographySpotForSpecies(String speciesId) {
  for (final s in photographySpots) {
    if (s.speciesIds.contains(speciesId)) return s;
  }
  return null;
}

ProtectedArea? protectedAreaAt(double lat, double lng) {
  final p = LatLng(lat, lng);
  for (final area in protectedAreas) {
    if (isPointInPolygon(p, area.coordinates)) return area;
  }
  return null;
}

bool isInDangerZone(double lat, double lng) {
  final p = LatLng(lat, lng);
  for (final z in restrictedZones) {
    if (isPointInPolygon(p, z.coordinates)) return true;
  }
  return false;
}

String weatherEmoji(String condition) {
  switch (condition) {
    case 'Sunny':
      return '☀️';
    case 'Partly Cloudy':
      return '⛅';
    case 'Cloudy':
      return '☁️';
    case 'Rainy':
      return '🌧️';
    case 'Stormy':
      return '⛈️';
    default:
      return '☁️';
  }
}