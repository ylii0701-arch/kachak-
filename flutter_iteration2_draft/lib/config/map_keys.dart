const String mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue: '',
);

const String mapboxStyleOwner = 'mapbox';
const String mapboxStyleId = 'streets-v12';

String get mapboxStaticTilesUrlTemplate =>
    'https://api.mapbox.com/styles/v1/$mapboxStyleOwner/$mapboxStyleId/tiles/512/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken';

const String openWeatherApiKey = String.fromEnvironment(
  'OPENWEATHER_API_KEY',
  defaultValue: '',
);
