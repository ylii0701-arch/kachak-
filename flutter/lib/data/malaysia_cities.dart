import 'predictions_data.dart';

/// Malaysian city model used by map + prediction mapping.
class MalaysianCity {
  const MalaysianCity({
    required this.name,
    required this.state,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String state;
  final double lat;
  final double lng;
}

/// Official major city list used for map weather markers.
const List<MalaysianCity> kMalaysianCities = [
  MalaysianCity(
    name: 'Kuala Lumpur',
    state: 'Kuala Lumpur',
    lat: 3.1390,
    lng: 101.6869,
  ),
  MalaysianCity(
    name: 'Ipoh',
    state: 'Perak',
    lat: 4.5975,
    lng: 101.0901,
  ),
  MalaysianCity(
    name: 'Kuching',
    state: 'Sarawak',
    lat: 1.5533,
    lng: 110.3592,
  ),
  MalaysianCity(
    name: 'Kota Kinabalu',
    state: 'Sabah',
    lat: 5.9804,
    lng: 116.0735,
  ),
  MalaysianCity(
    name: 'Johor Bahru',
    state: 'Johor',
    lat: 1.4927,
    lng: 103.7414,
  ),
  MalaysianCity(
    name: 'George Town',
    state: 'Pulau Pinang',
    lat: 5.4141,
    lng: 100.3288,
  ),
  MalaysianCity(
    name: 'Shah Alam',
    state: 'Selangor',
    lat: 3.0738,
    lng: 101.5183,
  ),
  MalaysianCity(
    name: 'Melaka City',
    state: 'Melaka',
    lat: 2.1896,
    lng: 102.2501,
  ),
  MalaysianCity(
    name: 'Alor Setar',
    state: 'Kedah',
    lat: 6.1248,
    lng: 100.3678,
  ),
  MalaysianCity(
    name: 'Miri',
    state: 'Sarawak',
    lat: 4.3995,
    lng: 113.9914,
  ),
  MalaysianCity(
    name: 'Petaling Jaya',
    state: 'Selangor',
    lat: 3.1073,
    lng: 101.6067,
  ),
  MalaysianCity(
    name: 'Kuala Terengganu',
    state: 'Terengganu',
    lat: 5.3302,
    lng: 103.1408,
  ),
  MalaysianCity(
    name: 'Iskandar Puteri',
    state: 'Johor',
    lat: 1.4145,
    lng: 103.6318,
  ),
  MalaysianCity(
    name: 'Seberang Perai',
    state: 'Pulau Pinang',
    lat: 5.3848,
    lng: 100.4265,
  ),
  MalaysianCity(
    name: 'Seremban',
    state: 'Negeri Sembilan',
    lat: 2.7297,
    lng: 101.9381,
  ),
  MalaysianCity(
    name: 'Subang Jaya',
    state: 'Selangor',
    lat: 3.0438,
    lng: 101.5884,
  ),
  MalaysianCity(
    name: 'Pasir Gudang',
    state: 'Johor',
    lat: 1.4556,
    lng: 103.9020,
  ),
  MalaysianCity(
    name: 'Kuantan',
    state: 'Pahang',
    lat: 3.8077,
    lng: 103.3260,
  ),
  MalaysianCity(
    name: 'Kota Bharu',
    state: 'Kelantan',
    lat: 6.1254,
    lng: 102.2381,
  ),
  MalaysianCity(
    name: 'Klang',
    state: 'Selangor',
    lat: 3.0449,
    lng: 101.4456,
  ),
];

/// Maps selected city directly to its own name.
Region predictionRegionForCity(MalaysianCity city) {
  return city.name;
}

Region predictionRegionForCityName(String cityName) {
  for (final c in kMalaysianCities) {
    if (c.name == cityName) return c.name;
  }
  return 'Kuala Lumpur'; // Fallback
}

bool cityMatchesQuery(MalaysianCity city, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return city.name.toLowerCase().contains(q) || city.state.toLowerCase().contains(q);
}