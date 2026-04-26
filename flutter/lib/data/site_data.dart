/// Model representing a physical location where species can be found.
class Site {
  const Site({
    required this.id,
    required this.name,
    required this.cityName,
    required this.type,
    required this.isCaptive,
    required this.lat,
    required this.lng,
    required this.accessibility,
    required this.description,
    required this.supportedSpeciesIds,
  });

  final String id;
  final String name;
  final String cityName;
  final String type;
  final bool isCaptive;
  final double lat;
  final double lng;
  final String accessibility; // 'Easy', 'Moderate', 'Difficult'
  final String description;
  final List<String> supportedSpeciesIds;
}

/// The master list of all tracking sites, mapped to the first 50 species.
const List<Site> siteData = [
  // ==========================================
  // PENINSULAR MALAYSIA: WILD SITES
  // ==========================================
  Site(
    id: 's_taman_negara',
    name: 'Taman Negara National Park',
    cityName: 'Kuala Lumpur',
    type: 'National Park',
    isCaptive: false,
    lat: 4.3800,
    lng: 102.4000,
    accessibility: 'Difficult',
    description: 'Ancient primary rainforest. Requires a guide for deep forest access.',
    supportedSpeciesIds: ['1', '3', '5', '6', '7', '8', '10', '11', '12', '13', '15', '16', '18', '20', '21', '22', '24', '25', '27', '28', '29', '31', '32', '33', '35', '36', '37', '41', '43', '48', '49', '50'],
  ),
  Site(
    id: 's_royal_belum',
    name: 'Royal Belum State Park',
    cityName: 'Ipoh',
    type: 'State Park',
    isCaptive: false,
    lat: 5.5400,
    lng: 101.4400,
    accessibility: 'Moderate',
    description: 'Pristine forest known for hornbills and large mammals. Boat access required.',
    supportedSpeciesIds: ['1', '3', '5', '6', '12', '13', '20', '24', '25', '36', '37'],
  ),
  Site(
    id: 's_frim',
    name: 'FRIM (Forest Research Institute)',
    cityName: 'Petaling Jaya',
    type: 'Forest Reserve',
    isCaptive: false,
    lat: 3.2350,
    lng: 101.6350,
    accessibility: 'Easy',
    description: 'Popular research forest with a canopy walkway. Entry permit required.',
    supportedSpeciesIds: ['8', '10', '16', '19', '21', '28', '42', '44', '45', '47', '49'],
  ),
  Site(
    id: 's_kuala_selangor',
    name: 'Kuala Selangor Nature Park',
    cityName: 'Shah Alam',
    type: 'Mangrove / Coastal',
    isCaptive: false,
    lat: 3.3390,
    lng: 101.2450,
    accessibility: 'Easy',
    description: 'Excellent coastal trails and boardwalks. Great for wetland birds and monitors.',
    supportedSpeciesIds: ['26', '30', '38', '44'],
  ),
  Site(
    id: 's_gombak',
    name: 'Ulu Gombak Forest',
    cityName: 'Kuala Lumpur',
    type: 'Forest Edge',
    isCaptive: false,
    lat: 3.3190,
    lng: 101.7590,
    accessibility: 'Moderate',
    description: 'Dense forest edge habitat rich in insect and amphibian life.',
    supportedSpeciesIds: ['8', '17', '21', '37', '40', '48'],
  ),

  // ==========================================
  // BORNEO (SABAH & SARAWAK): WILD SITES
  // ==========================================
  Site(
    id: 's_kinabatangan',
    name: 'Kinabatangan Wildlife Sanctuary',
    cityName: 'Kota Kinabalu',
    type: 'Wildlife Sanctuary',
    isCaptive: false,
    lat: 5.5100,
    lng: 118.2500,
    accessibility: 'Easy',
    description: 'World-class river safaris. Prime spotting for endemic Borneo species.',
    supportedSpeciesIds: ['2', '3', '4', '8', '23', '25', '30', '35', '38', '39'],
  ),
  Site(
    id: 's_deramakot',
    name: 'Deramakot Forest Reserve',
    cityName: 'Kota Kinabalu',
    type: 'Forest Reserve',
    isCaptive: false,
    lat: 5.3830,
    lng: 117.0830,
    accessibility: 'Difficult',
    description: 'Highly regulated commercial forest reserve known for night safaris and wild cats.',
    supportedSpeciesIds: ['1', '2', '14', '18', '23', '35'],
  ),
  Site(
    id: 's_bako',
    name: 'Bako National Park',
    cityName: 'Kuching',
    type: 'National Park',
    isCaptive: false,
    lat: 1.7100,
    lng: 110.4400,
    accessibility: 'Moderate',
    description: 'Coastal rainforest accessed via boat. Famous for Proboscis monkeys and pit vipers.',
    supportedSpeciesIds: ['4', '11', '38', '40', '42'],
  ),
  Site(
    id: 's_rdc',
    name: 'Rainforest Discovery Centre (RDC)',
    cityName: 'Kota Kinabalu',
    type: 'Education Centre',
    isCaptive: false,
    lat: 5.8700,
    lng: 117.9400,
    accessibility: 'Easy',
    description: 'Features a massive steel canopy walkway ideal for birdwatching.',
    supportedSpeciesIds: ['10', '34', '41', '46', '48', '49'],
  ),
  Site(
    id: 's_sipadan',
    name: 'Sipadan Marine Park',
    cityName: 'Kota Kinabalu',
    type: 'Marine Park',
    isCaptive: false,
    lat: 4.1100,
    lng: 118.6200,
    accessibility: 'Moderate',
    description: 'World-renowned diving site for marine turtles and pelagics.',
    supportedSpeciesIds: ['9'],
  ),

  // ==========================================
  // CAPTIVE / URBAN SITES
  // ==========================================
  Site(
    id: 's_zoo_negara',
    name: 'Zoo Negara',
    cityName: 'Kuala Lumpur',
    type: 'Zoo',
    isCaptive: true,
    lat: 3.2080,
    lng: 101.7560,
    accessibility: 'Easy',
    description: 'National zoo featuring expansive enclosures for local and exotic species.',
    supportedSpeciesIds: ['1', '2', '4', '5', '6', '8', '12', '20', '37', '38', '39'],
  ),
  Site(
    id: 's_kl_bird_park',
    name: 'KL Bird Park',
    cityName: 'Kuala Lumpur',
    type: 'Bird Park',
    isCaptive: true,
    lat: 3.1430,
    lng: 101.6880,
    accessibility: 'Easy',
    description: 'World\'s largest free-flight walk-in aviary.',
    supportedSpeciesIds: ['3', '24', '25', '26', '28', '30'],
  ),
  Site(
    id: 's_sepilok',
    name: 'Sepilok Rehabilitation Centre',
    cityName: 'Kota Kinabalu',
    type: 'Sanctuary',
    isCaptive: true,
    lat: 5.8650,
    lng: 117.9500,
    accessibility: 'Easy',
    description: 'Dedicated to the rescue and rehabilitation of orphaned orangutans and sun bears.',
    supportedSpeciesIds: ['1', '2'],
  ),
  Site(
    id: 's_entopia',
    name: 'Entopia Butterfly Farm',
    cityName: 'George Town',
    type: 'Insectarium',
    isCaptive: true,
    lat: 5.4450,
    lng: 100.2150,
    accessibility: 'Easy',
    description: 'Massive glasshouse habitat showcasing butterflies and bizarre insects.',
    supportedSpeciesIds: ['17', '46', '47', '48'],
  ),
  Site(
    id: 's_subang_parks',
    name: 'Subang Jaya Urban Parks',
    cityName: 'Subang Jaya',
    type: 'Urban Park',
    isCaptive: false,
    lat: 3.0480,
    lng: 101.5880,
    accessibility: 'Easy',
    description: 'Recreational city parks bordering residential zones. Good for common wildlife.',
    supportedSpeciesIds: ['26', '38', '44', '45'],
  ),
];

// ==========================================
// HELPER FUNCTIONS FOR PREDICTION UI
// ==========================================

List<Site> getSitesForSpecies(String speciesId) {
  return siteData.where((site) => site.supportedSpeciesIds.contains(speciesId)).toList();
}

List<String> getUniqueCitiesFromSites(List<Site> sites) {
  final cities = sites.map((s) => s.cityName).toSet().toList();
  cities.sort();
  return cities;
}

List<Site> getSitesForSpeciesAndCity(String speciesId, String cityName) {
  return siteData.where((site) => site.cityName == cityName && site.supportedSpeciesIds.contains(speciesId)).toList();
}