const String mapboxAccessToken = 'YOUR_MAPBOX_TOKEN_HERE';

const String mapboxStyleOwner = 'mapbox';
const String mapboxStyleId = 'streets-v12';

String get mapboxStaticTilesUrlTemplate =>
    'https://api.mapbox.com/styles/v1/$mapboxStyleOwner/$mapboxStyleId/tiles/512/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken';

const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE';