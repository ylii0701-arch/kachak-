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

/// The master list of all tracking sites, mapped realistically to all 100 species.
const List<Site> siteData = [
  // ==========================================
  // PENINSULAR MALAYSIA: WILD SITES
  // ==========================================
  Site(
    id: 'site01',
    name: 'Taman Negara National Park',
    cityName: 'Kuala Lumpur',
    type: 'National Park',
    isCaptive: false,
    lat: 4.3800,
    lng: 102.4000,
    accessibility: 'Difficult',
    description: 'Ancient primary rainforest. Requires a guide for deep forest access.',
    supportedSpeciesIds: ['1', '3', '5', '6', '8', '11', '12', '13', '15', '16', '17', '18', '19', '20', '21', '22', '24', '25', '27', '28', '31', '32', '33', '35', '36', '37', '43', '49', '50', '52', '61', '62', '63', '64', '77', '78', '86', '87', '96', '97', '99', '100'],
  ),
  Site(
    id: 'site02',
    name: 'Royal Belum State Park',
    cityName: 'Ipoh',
    type: 'State Park',
    isCaptive: false,
    lat: 5.5400,
    lng: 101.4400,
    accessibility: 'Moderate',
    description: 'Pristine forest known for hornbills and large mammals. Boat access required.',
    supportedSpeciesIds: ['1', '3', '5', '6', '8', '12', '13', '18', '19', '20', '21', '24', '25', '35', '36', '37', '38', '52', '61', '62', '63', '64', '78', '86'],
  ),
  Site(
    id: 'site03',
    name: 'FRIM (Forest Research Institute)',
    cityName: 'Petaling Jaya',
    type: 'Forest Reserve',
    isCaptive: false,
    lat: 3.2350,
    lng: 101.6350,
    accessibility: 'Easy',
    description: 'Popular research forest with a canopy walkway. Entry permit required.',
    supportedSpeciesIds: ['19', '21', '38', '44', '45', '49', '50', '51', '62', '63', '84', '88', '91', '92'],
  ),
  Site(
    id: 'site04',
    name: 'Kuala Selangor Nature Park',
    cityName: 'Shah Alam',
    type: 'Mangrove / Coastal',
    isCaptive: false,
    lat: 3.3390,
    lng: 101.2450,
    accessibility: 'Easy',
    description: 'Excellent coastal trails and boardwalks. Great for wetland birds and monitors.',
    supportedSpeciesIds: ['26', '30', '38', '54', '59', '63', '65', '66', '67', '69', '83'],
  ),
  Site(
    id: 'site05',
    name: 'Ulu Gombak Forest',
    cityName: 'Kuala Lumpur',
    type: 'Forest Edge',
    isCaptive: false,
    lat: 3.3190,
    lng: 101.7590,
    accessibility: 'Moderate',
    description: 'Dense forest edge habitat rich in insect and amphibian life.',
    supportedSpeciesIds: ['16', '17', '19', '20', '21', '40', '43', '44', '45', '49', '50', '62', '63', '80', '84'],
  ),
  Site(
    id: 'site06',
    name: 'Penang National Park',
    cityName: 'George Town',
    type: 'National Park',
    isCaptive: false,
    lat: 5.4542,
    lng: 100.2014,
    accessibility: 'Moderate',
    description: 'Malaysia\'s smallest national park. Great for coastal raptors, primates, and unique beach habitats.',
    supportedSpeciesIds: ['9', '19', '26', '38', '51', '54', '63', '65', '66', '88'],
  ),
  Site(
    id: 'site07',
    name: 'Kilim Karst Geoforest Park',
    cityName: 'Alor Setar',
    type: 'Geoforest Park',
    isCaptive: false,
    lat: 6.4026,
    lng: 99.8569,
    accessibility: 'Easy',
    description: 'Boat-accessed mangrove park in Langkawi. Perfect for eagles, kingfishers, and mangrove snakes.',
    supportedSpeciesIds: ['8', '26', '38', '63', '65', '66', '83', '88'],
  ),
  Site(
    id: 'site08',
    name: 'Kinta Nature Park',
    cityName: 'Ipoh',
    type: 'Nature Park',
    isCaptive: false,
    lat: 4.4166,
    lng: 101.1166,
    accessibility: 'Easy',
    description: 'The largest heronry in Malaysia, right outside Ipoh. A haven for waterbirds and migratory species.',
    supportedSpeciesIds: ['26', '38', '45', '54', '68', '69'],
  ),
  Site(
    id: 'site09',
    name: 'Ayer Keroh Botanical Garden',
    cityName: 'Melaka City',
    type: 'Botanical Garden',
    isCaptive: false,
    lat: 2.2798,
    lng: 102.2985,
    accessibility: 'Easy',
    description: 'A very accessible park in Melaka offering excellent opportunities to practice shooting common urban wildlife.',
    supportedSpeciesIds: ['38', '44', '45', '62', '63', '84', '91'],
  ),
  Site(
    id: 'site10',
    name: 'Kenaboi State Park',
    cityName: 'Seremban',
    type: 'State Park',
    isCaptive: false,
    lat: 3.1956,
    lng: 102.0461,
    accessibility: 'Moderate',
    description: 'A hidden gem in Negeri Sembilan. Dense, dark trails excellent for macro photography and forest floor species.',
    supportedSpeciesIds: ['15', '16', '17', '40', '49', '50', '100'],
  ),
  Site(
    id: 'site11',
    name: 'Endau-Rompin National Park',
    cityName: 'Johor Bahru',
    type: 'National Park',
    isCaptive: false,
    lat: 2.5312,
    lng: 103.2505,
    accessibility: 'Difficult',
    description: 'Rugged terrain protecting the southern stronghold of Malaysia\'s large terrestrial mammals.',
    supportedSpeciesIds: ['1', '3', '5', '6', '8', '11', '12', '15', '38', '52', '61', '64', '96'],
  ),
  Site(
    id: 'site12',
    name: 'Pulai River Mangrove Forest',
    cityName: 'Iskandar Puteri',
    type: 'Mangrove Forest',
    isCaptive: false,
    lat: 1.3858,
    lng: 103.5456,
    accessibility: 'Moderate',
    description: 'Crucial wetland habitat in southern Johor. Explored via boat, excellent for mangrove specialists.',
    supportedSpeciesIds: ['26', '30', '38', '39', '54', '63', '66', '67', '83'],
  ),
  Site(
    id: 'site13',
    name: 'Kenyir Lake',
    cityName: 'Kuala Terengganu',
    type: 'Lake',
    isCaptive: false,
    lat: 5.0685,
    lng: 102.7845,
    accessibility: 'Moderate',
    description: 'Southeast Asia\'s largest man-made lake. Houseboat trips are the best way to spot lakeside wildlife.',
    supportedSpeciesIds: ['3', '6', '25', '26', '38', '53', '54', '79'],
  ),
  Site(
    id: 'site14',
    name: 'Gunung Stong State Park',
    cityName: 'Kota Bharu',
    type: 'State Park',
    isCaptive: false,
    lat: 5.3400,
    lng: 101.9700,
    accessibility: 'Difficult',
    description: 'Famous for its massive waterfall and steep treks. Holds unique upland species and vibrant insect life.',
    supportedSpeciesIds: ['17', '62', '63', '70', '71', '72'],
  ),
  Site(
    id: 'site15',
    name: 'Fraser\'s Hill',
    cityName: 'Kuala Lumpur',
    type: 'Hill Station',
    isCaptive: false,
    lat: 3.7145,
    lng: 101.7345,
    accessibility: 'Easy',
    description: 'The bird-watching capital of Peninsular Malaysia. Cool weather and extremely accessible roadside photography.',
    supportedSpeciesIds: ['16', '20', '28', '29', '70', '71', '72', '80', '93'],
  ),

  // ==========================================
  // BORNEO (SABAH & SARAWAK): WILD SITES
  // ==========================================
  Site(
    id: 'site16',
    name: 'Kinabatangan Wildlife Sanctuary',
    cityName: 'Kota Kinabalu',
    type: 'Wildlife Sanctuary',
    isCaptive: false,
    lat: 5.5100,
    lng: 118.2500,
    accessibility: 'Easy',
    description: 'World-class river safaris. Prime spotting for endemic Borneo species.',
    supportedSpeciesIds: ['2', '3', '4', '7', '8', '23', '30', '34', '38', '39', '55', '58', '59', '63', '65', '75', '76', '78', '79', '83'],
  ),
  Site(
    id: 'site17',
    name: 'Deramakot Forest Reserve',
    cityName: 'Kota Kinabalu',
    type: 'Forest Reserve',
    isCaptive: false,
    lat: 5.3830,
    lng: 117.0830,
    accessibility: 'Difficult',
    description: 'Highly regulated commercial forest reserve known for night safaris and wild cats.',
    supportedSpeciesIds: ['1', '2', '10', '14', '18', '21', '23', '55', '56', '57', '58', '61', '64'],
  ),
  Site(
    id: 'site18',
    name: 'Bako National Park',
    cityName: 'Kuching',
    type: 'National Park',
    isCaptive: false,
    lat: 1.7100,
    lng: 110.4400,
    accessibility: 'Moderate',
    description: 'Coastal rainforest accessed via boat. Famous for Proboscis monkeys and pit vipers.',
    supportedSpeciesIds: ['4', '38', '39', '40', '59', '63', '78', '82'],
  ),
  Site(
    id: 'site19',
    name: 'Rainforest Discovery Centre (RDC)',
    cityName: 'Kota Kinabalu',
    type: 'Education Centre',
    isCaptive: false,
    lat: 5.8700,
    lng: 117.9400,
    accessibility: 'Easy',
    description: 'Features a massive steel canopy walkway ideal for birdwatching.',
    supportedSpeciesIds: ['2', '3', '10', '34', '65', '78', '81'],
  ),
  Site(
    id: 'site20',
    name: 'Sipadan Marine Park',
    cityName: 'Kota Kinabalu',
    type: 'Marine Park',
    isCaptive: false,
    lat: 4.1100,
    lng: 118.6200,
    accessibility: 'Moderate',
    description: 'World-renowned diving site for marine turtles and pelagics.',
    supportedSpeciesIds: ['9', '66'],
  ),
  Site(
    id: 'site21',
    name: 'Kinabalu Park',
    cityName: 'Kota Kinabalu',
    type: 'National Park',
    isCaptive: false,
    lat: 6.0044,
    lng: 116.5441,
    accessibility: 'Moderate',
    description: 'UNESCO World Heritage site. The higher altitudes are home to Borneo\'s most famous endemic birds and amphibians.',
    supportedSpeciesIds: ['29', '73', '74', '95', '98'],
  ),
  Site(
    id: 'site22',
    name: 'Danum Valley Conservation Area',
    cityName: 'Kota Kinabalu',
    type: 'Conservation Area',
    isCaptive: false,
    lat: 4.9654,
    lng: 117.8041,
    accessibility: 'Moderate',
    description: 'Pristine, untouched Borneo jungle. One of the highest biodiversity densities on the planet.',
    supportedSpeciesIds: ['1', '2', '3', '10', '11', '14', '23', '34', '36', '41', '42', '56', '57', '81', '94'],
  ),
  Site(
    id: 'site23',
    name: 'Niah National Park',
    cityName: 'Miri',
    type: 'National Park',
    isCaptive: false,
    lat: 3.8202,
    lng: 113.7635,
    accessibility: 'Moderate',
    description: 'Famous for massive caves. The surrounding forest holds highly specialized limestone-dwelling species.',
    supportedSpeciesIds: ['38', '49', '50', '60', '63', '85'],
  ),

  // ==========================================
  // CAPTIVE / URBAN SITES
  // ==========================================
  Site(
    id: 'site24',
    name: 'Zoo Negara',
    cityName: 'Kuala Lumpur',
    type: 'Zoo',
    isCaptive: true,
    lat: 3.2080,
    lng: 101.7560,
    accessibility: 'Easy',
    description: 'National zoo featuring expansive enclosures for local and exotic species.',
    // Corrected: Removed impossible Bornean endemics (Proboscis Monkey, Pygmy Elephant).
    // Kept Orangutan, Sun Bear, and Peninsular/Malayan species.
    supportedSpeciesIds: [
      '1', '2', '5', '6', '8', '12', '13', '18', '20',
      '21', '22', '37', '38', '39', '51', '52', '53', '54',
      '61', '62', '63', '79', '87', '88'
    ],
  ),
  Site(
    id: 'site25',
    name: 'KL Bird Park',
    cityName: 'Kuala Lumpur',
    type: 'Bird Park',
    isCaptive: true,
    lat: 3.1430,
    lng: 101.6880,
    accessibility: 'Easy',
    description: 'World\'s largest free-flight walk-in aviary.',
    // Corrected: Removed ultra-rare Bornean endemics. Focused on realistic captive birds and urban intruders.
    supportedSpeciesIds: [
      '3', '24', '25', '26', '38', '63', '65', '68', '69', '76'
    ],
  ),
  Site(
    id: 'site26',
    name: 'Sepilok Rehabilitation Centre',
    cityName: 'Kota Kinabalu',
    type: 'Sanctuary',
    isCaptive: true,
    lat: 5.8650,
    lng: 117.9500,
    accessibility: 'Easy',
    description: 'Dedicated to the rescue and rehabilitation of orphaned orangutans and sun bears.',
    // Specialized sanctuary (not a general zoo), kept strictly to local rescued fauna and local intruders
    supportedSpeciesIds: ['1', '2', '62', '63'],
  ),
  Site(
    id: 'site27',
    name: 'Entopia Butterfly Farm',
    cityName: 'George Town',
    type: 'Insectarium',
    isCaptive: true,
    lat: 5.4450,
    lng: 100.2150,
    accessibility: 'Easy',
    description: 'Massive glasshouse habitat showcasing butterflies and bizarre insects.',
    // Exclusively invertebrates
    supportedSpeciesIds: ['17', '46', '47', '48', '49', '50', '97', '98', '99', '100'],
  ),
  Site(
    id: 'site28',
    name: 'Subang Jaya Urban Parks',
    cityName: 'Subang Jaya',
    type: 'Urban Park',
    isCaptive: false,
    lat: 3.0480,
    lng: 101.5880,
    accessibility: 'Easy',
    description: 'Recreational city parks bordering residential zones. Good for common wildlife.',
    // Highly adaptable suburban wildlife
    supportedSpeciesIds: ['8', '26', '38', '44', '45', '63', '84', '88', '90', '91', '92'],
  ),
  Site(
    id: 'site29',
    name: 'Kuala Lumpur Butterfly Park',
    cityName: 'Kuala Lumpur',
    type: 'Insectarium',
    isCaptive: true,
    lat: 3.1433,
    lng: 101.6892,
    accessibility: 'Easy',
    description: 'A beautiful landscaped garden housing thousands of butterflies and a gallery of exotic insects.',
    // Captive butterflies/insects + realistic wild intruders (tree frogs, garden lizards, macaques)
    supportedSpeciesIds: [
      '17', '44', '46', '47', '48', '49', '50', '63', '84', '91', '97', '98', '99', '100'
    ],
  ),
];

// ==========================================
// HELPER FUNCTIONS FOR UI
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