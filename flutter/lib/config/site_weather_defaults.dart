class FallbackWeather {
  final double temp;
  final double humidity;
  final double windSpeed;
  final double rainfall;

  const FallbackWeather({
    required this.temp,
    required this.humidity,
    required this.windSpeed,
    this.rainfall = 0.0, // Default rainfall is universally set to 0.0
  });
}

/// Fallback weather values for the 29 locations in site_data.dart,
/// configured based on their geographical characteristics (altitude, vegetation, coast, urban).
final Map<String, FallbackWeather> siteWeatherDefaults = {
  // === Peninsular Malaysia: Wild Sites ===
  'site01': const FallbackWeather(temp: 27.0, humidity: 88.0, windSpeed: 1.5), // Taman Negara (Primary rainforest)
  'site02': const FallbackWeather(temp: 27.5, humidity: 85.0, windSpeed: 1.5), // Royal Belum (Rainforest / Lake)
  'site03': const FallbackWeather(temp: 28.0, humidity: 80.0, windSpeed: 1.0), // FRIM (Secondary / Protected forest)
  'site04': const FallbackWeather(temp: 29.0, humidity: 80.0, windSpeed: 4.0), // Kuala Selangor (Mangrove / Coast)
  'site05': const FallbackWeather(temp: 27.0, humidity: 85.0, windSpeed: 1.5), // Ulu Gombak (Forest edge)
  'site06': const FallbackWeather(temp: 29.0, humidity: 78.0, windSpeed: 3.5), // Penang NP (Coastal forest)
  'site07': const FallbackWeather(temp: 29.0, humidity: 78.0, windSpeed: 3.0), // Kilim Karst (Mangrove / Limestone karst)
  'site08': const FallbackWeather(temp: 28.5, humidity: 75.0, windSpeed: 2.0), // Kinta Nature Park (Wetlands)
  'site09': const FallbackWeather(temp: 29.0, humidity: 75.0, windSpeed: 2.0), // Ayer Keroh (Botanical garden)
  'site10': const FallbackWeather(temp: 26.5, humidity: 88.0, windSpeed: 1.5), // Kenaboi (Dense dark forest)
  'site11': const FallbackWeather(temp: 27.0, humidity: 85.0, windSpeed: 1.5), // Endau-Rompin (Rugged rainforest)
  'site12': const FallbackWeather(temp: 29.0, humidity: 80.0, windSpeed: 3.5), // Pulai River (Mangrove forest)
  'site13': const FallbackWeather(temp: 28.0, humidity: 82.0, windSpeed: 2.5), // Kenyir Lake (Large man-made lake)
  'site14': const FallbackWeather(temp: 25.0, humidity: 88.0, windSpeed: 2.0), // Gunung Stong (Mountain waterfall area)
  'site15': const FallbackWeather(temp: 21.0, humidity: 90.0, windSpeed: 3.0), // Fraser's Hill (Highland hill station)

  // === Borneo (Sabah & Sarawak): Wild Sites ===
  'site16': const FallbackWeather(temp: 28.0, humidity: 88.0, windSpeed: 2.0), // Kinabatangan (River valley)
  'site17': const FallbackWeather(temp: 27.5, humidity: 90.0, windSpeed: 1.5), // Deramakot (Protected forest reserve)
  'site18': const FallbackWeather(temp: 28.5, humidity: 82.0, windSpeed: 3.5), // Bako NP (Coastal rainforest)
  'site19': const FallbackWeather(temp: 28.0, humidity: 85.0, windSpeed: 1.5), // RDC (Rainforest canopy)
  'site20': const FallbackWeather(temp: 30.0, humidity: 75.0, windSpeed: 5.0), // Sipadan (Marine / Diving site)
  'site21': const FallbackWeather(temp: 18.0, humidity: 92.0, windSpeed: 2.5), // Kinabalu Park (High altitude mountain)
  'site22': const FallbackWeather(temp: 27.0, humidity: 92.0, windSpeed: 1.0), // Danum Valley (Ancient deep rainforest)
  'site23': const FallbackWeather(temp: 28.0, humidity: 88.0, windSpeed: 1.5), // Niah NP (Caves and surrounding forest)

  // === Captive / Urban Sites ===
  'site24': const FallbackWeather(temp: 30.0, humidity: 70.0, windSpeed: 1.5), // Zoo Negara (Urban zoo)
  'site25': const FallbackWeather(temp: 30.0, humidity: 75.0, windSpeed: 1.0), // KL Bird Park (Urban walk-in aviary)
  'site26': const FallbackWeather(temp: 28.5, humidity: 85.0, windSpeed: 1.5), // Sepilok (Conservation center / Secondary forest)
  'site27': const FallbackWeather(temp: 29.0, humidity: 80.0, windSpeed: 2.0), // Entopia (Large glasshouse)
  'site28': const FallbackWeather(temp: 31.0, humidity: 70.0, windSpeed: 1.5), // Subang Jaya (Residential / Urban park)
  'site29': const FallbackWeather(temp: 30.0, humidity: 75.0, windSpeed: 1.0), // KL Butterfly Park (Urban landscaped garden)
};