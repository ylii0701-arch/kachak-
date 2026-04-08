import 'predictions_data.dart';

/// Major Malaysian cities & towns with state (for prediction bucket mapping).
class MalaysianCity {
  const MalaysianCity(this.name, this.state);
  final String name;
  final String state;
}

/// Alphabetically sorted; covers state capitals, district seats & common towns.
const List<MalaysianCity> kMalaysianCities = [
  MalaysianCity('Alor Gajah', 'Melaka'),
  MalaysianCity('Alor Setar', 'Kedah'),
  MalaysianCity('Ampang', 'Selangor'),
  MalaysianCity('Arau', 'Perlis'),
  MalaysianCity('Balakong', 'Selangor'),
  MalaysianCity('Baling', 'Kedah'),
  MalaysianCity('Bandar Baru Bangi', 'Selangor'),
  MalaysianCity('Bandar Baru Uda', 'Johor'),
  MalaysianCity('Bandar Tun Razak', 'Kuala Lumpur'),
  MalaysianCity('Batang Berjuntai', 'Selangor'),
  MalaysianCity('Batu Arang', 'Selangor'),
  MalaysianCity('Batu Ferringhi', 'Pulau Pinang'),
  MalaysianCity('Batu Gajah', 'Perak'),
  MalaysianCity('Batu Pahat', 'Johor'),
  MalaysianCity('Bau', 'Sarawak'),
  MalaysianCity('Beaufort', 'Sabah'),
  MalaysianCity('Beluran', 'Sabah'),
  MalaysianCity('Bentong', 'Pahang'),
  MalaysianCity('Besut', 'Terengganu'),
  MalaysianCity('Bidor', 'Perak'),
  MalaysianCity('Bintulu', 'Sarawak'),
  MalaysianCity('Brickfields', 'Kuala Lumpur'),
  MalaysianCity('Bukit Baru', 'Melaka'),
  MalaysianCity('Bukit Gambir', 'Johor'),
  MalaysianCity('Bukit Kayu Hitam', 'Kedah'),
  MalaysianCity('Bukit Mertajam', 'Pulau Pinang'),
  MalaysianCity('Butterworth', 'Pulau Pinang'),
  MalaysianCity('Cameron Highlands', 'Pahang'),
  MalaysianCity('Cheras', 'Kuala Lumpur'),
  MalaysianCity('Chukai', 'Terengganu'),
  MalaysianCity('Cyberjaya', 'Selangor'),
  MalaysianCity('Dungun', 'Terengganu'),
  MalaysianCity('George Town', 'Pulau Pinang'),
  MalaysianCity('Gerik', 'Perak'),
  MalaysianCity('Gombak', 'Selangor'),
  MalaysianCity('Gua Musang', 'Kelantan'),
  MalaysianCity('Hulu Langat', 'Selangor'),
  MalaysianCity('Hulu Selangor', 'Selangor'),
  MalaysianCity('Ipoh', 'Perak'),
  MalaysianCity('Jasin', 'Melaka'),
  MalaysianCity('Jeli', 'Kelantan'),
  MalaysianCity('Jerteh', 'Terengganu'),
  MalaysianCity('Jitra', 'Kedah'),
  MalaysianCity('Johor Bahru', 'Johor'),
  MalaysianCity('Kajang', 'Selangor'),
  MalaysianCity('Kampar', 'Perak'),
  MalaysianCity('Kangar', 'Perlis'),
  MalaysianCity('Kanowit', 'Sarawak'),
  MalaysianCity('Kapit', 'Sarawak'),
  MalaysianCity('Kemaman', 'Terengganu'),
  MalaysianCity('Keningau', 'Sabah'),
  MalaysianCity('Kepong', 'Kuala Lumpur'),
  MalaysianCity('Kerian', 'Perak'),
  MalaysianCity('Klang', 'Selangor'),
  MalaysianCity('Kluang', 'Johor'),
  MalaysianCity('Kota Belud', 'Sabah'),
  MalaysianCity('Kota Bharu', 'Kelantan'),
  MalaysianCity('Kota Kinabalu', 'Sabah'),
  MalaysianCity('Kota Marudu', 'Sabah'),
  MalaysianCity('Kota Tinggi', 'Johor'),
  MalaysianCity('Kuala Kangsar', 'Perak'),
  MalaysianCity('Kuala Kubu Bharu', 'Selangor'),
  MalaysianCity('Kuala Lipis', 'Pahang'),
  MalaysianCity('Kuala Lumpur', 'Kuala Lumpur'),
  MalaysianCity('Kuala Nerang', 'Kedah'),
  MalaysianCity('Kuala Penyu', 'Sabah'),
  MalaysianCity('Kuala Pilah', 'Negeri Sembilan'),
  MalaysianCity('Kuala Selangor', 'Selangor'),
  MalaysianCity('Kuala Terengganu', 'Terengganu'),
  MalaysianCity('Kuah', 'Kedah'),
  MalaysianCity('Kuantan', 'Pahang'),
  MalaysianCity('Kuching', 'Sarawak'),
  MalaysianCity('Kulai', 'Johor'),
  MalaysianCity('Kulim', 'Kedah'),
  MalaysianCity('Labuan', 'Labuan'),
  MalaysianCity('Lahad Datu', 'Sabah'),
  MalaysianCity('Langkawi', 'Kedah'),
  MalaysianCity('Lawas', 'Sarawak'),
  MalaysianCity('Limbang', 'Sarawak'),
  MalaysianCity('Lumut', 'Perak'),
  MalaysianCity('Machang', 'Kelantan'),
  MalaysianCity('Maran', 'Pahang'),
  MalaysianCity('Marudi', 'Sarawak'),
  MalaysianCity('Masjid Tanah', 'Melaka'),
  MalaysianCity('Melaka', 'Melaka'),
  MalaysianCity('Mersing', 'Johor'),
  MalaysianCity('Miri', 'Sarawak'),
  MalaysianCity('Muar', 'Johor'),
  MalaysianCity('Mukah', 'Sarawak'),
  MalaysianCity('Nilai', 'Negeri Sembilan'),
  MalaysianCity('Nibong Tebal', 'Pulau Pinang'),
  MalaysianCity('Padang Besar', 'Perlis'),
  MalaysianCity('Papar', 'Sabah'),
  MalaysianCity('Parit Buntar', 'Perak'),
  MalaysianCity('Pasir Gudang', 'Johor'),
  MalaysianCity('Pasir Mas', 'Kelantan'),
  MalaysianCity('Pasir Puteh', 'Kelantan'),
  MalaysianCity('Pekan', 'Pahang'),
  MalaysianCity('Penampang', 'Sabah'),
  MalaysianCity('Petaling Jaya', 'Selangor'),
  MalaysianCity('Pontian', 'Johor'),
  MalaysianCity('Port Dickson', 'Negeri Sembilan'),
  MalaysianCity('Puchong', 'Selangor'),
  MalaysianCity('Putatan', 'Sabah'),
  MalaysianCity('Putrajaya', 'Putrajaya'),
  MalaysianCity('Raub', 'Pahang'),
  MalaysianCity('Rawang', 'Selangor'),
  MalaysianCity('Ranau', 'Sabah'),
  MalaysianCity('Rantau Panjang', 'Kelantan'),
  MalaysianCity('Rompin', 'Pahang'),
  MalaysianCity('Sabak', 'Selangor'),
  MalaysianCity('Sandakan', 'Sabah'),
  MalaysianCity('Sarikei', 'Sarawak'),
  MalaysianCity('Seberang Jaya', 'Pulau Pinang'),
  MalaysianCity('Segamat', 'Johor'),
  MalaysianCity('Semenyih', 'Selangor'),
  MalaysianCity('Sepang', 'Selangor'),
  MalaysianCity('Seremban', 'Negeri Sembilan'),
  MalaysianCity('Serian', 'Sarawak'),
  MalaysianCity('Setapak', 'Kuala Lumpur'),
  MalaysianCity('Setiawangsa', 'Kuala Lumpur'),
  MalaysianCity('Shah Alam', 'Selangor'),
  MalaysianCity('Sibu', 'Sarawak'),
  MalaysianCity('Simpang Ampat', 'Pulau Pinang'),
  MalaysianCity('Simpang Renggam', 'Johor'),
  MalaysianCity('Sitiawan', 'Perak'),
  MalaysianCity('Sri Aman', 'Sarawak'),
  MalaysianCity('Subang Jaya', 'Selangor'),
  MalaysianCity('Sungai Besar', 'Selangor'),
  MalaysianCity('Sungai Petani', 'Kedah'),
  MalaysianCity('Tampin', 'Negeri Sembilan'),
  MalaysianCity('Tanah Merah', 'Kelantan'),
  MalaysianCity('Tangkak', 'Johor'),
  MalaysianCity('Tanjung Malim', 'Perak'),
  MalaysianCity('Tanah Rata', 'Pahang'),
  MalaysianCity('Tapah', 'Perak'),
  MalaysianCity('Taiping', 'Perak'),
  MalaysianCity('Teluk Intan', 'Perak'),
  MalaysianCity('Temerloh', 'Pahang'),
  MalaysianCity('Tawau', 'Sabah'),
  MalaysianCity('Telupid', 'Sabah'),
  MalaysianCity('Tenom', 'Sabah'),
  MalaysianCity('Tumpat', 'Kelantan'),
  MalaysianCity('Tuaran', 'Sabah'),
  MalaysianCity('Yan', 'Kedah'),
  MalaysianCity('Yong Peng', 'Johor'),
];

/// Maps selected city to existing [locationPredictions] key (demo data buckets).
Region predictionRegionForCity(MalaysianCity city) {
  switch (city.state) {
    case 'Johor':
    case 'Melaka':
      return 'Johor';
    case 'Sabah':
    case 'Sarawak':
    case 'Labuan':
      return 'Sabah & Sarawak';
    case 'Pulau Pinang':
    case 'Kedah':
    case 'Perlis':
    case 'Perak':
      return 'Penang';
    default:
      return 'Kuala Lumpur';
  }
}

Region predictionRegionForCityName(String cityName) {
  for (final c in kMalaysianCities) {
    if (c.name == cityName) return predictionRegionForCity(c);
  }
  return 'Kuala Lumpur';
}

bool cityMatchesQuery(MalaysianCity city, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return city.name.toLowerCase().contains(q) || city.state.toLowerCase().contains(q);
}
