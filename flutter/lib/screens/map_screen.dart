import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../config/map_keys.dart';
import '../data/malaysia_cities.dart';
import '../data/map_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/app_shell_controller.dart';
import '../services/openweather_service.dart';
import '../theme/app_theme.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _kDefaultCenter = LatLng(4.2105, 101.9758);

  static LatLngBounds get _mapBounds {
    final points = <LatLng>[
      for (final city in kMalaysianCities) LatLng(city.lat, city.lng),
      for (final loc in speciesLocations) LatLng(loc.lat, loc.lng),
      for (final spot in photographySpots) LatLng(spot.lat, spot.lng),
    ];
    return LatLngBounds.fromPoints(points);
  }

  final MapController _mapController = MapController();
  late final MapOptions _mapOptions;
  AppShellController? _shell;

  LatLng? _user;
  String? _locationToast;
  bool _loadingLocation = true;
  bool _loadingCityWeather = true;
  bool _showCityWeatherMarkers = true;
  bool _showWildlifeMarkers = true;
  bool _showPhotoSpots = true;

  final Map<String, CityWeatherBundle> _cityWeatherByName = {};
  final OpenWeatherService _weatherService =
      const OpenWeatherService(apiKey: openWeatherApiKey);

  static const double _minZoom = 4;
  static const double _maxZoom = 18;

  @override
  void initState() {
    super.initState();

    _mapOptions = MapOptions(
      initialCenter: _kDefaultCenter,
      initialZoom: 5.3,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
      keepAlive: true,
      initialCameraFit: CameraFit.bounds(
        bounds: _mapBounds,
        padding: const EdgeInsets.fromLTRB(28, 96, 28, 120),
        maxZoom: 6.5,
        minZoom: _minZoom,
      ),
    );

    _initLocation();
    _loadCityWeather();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shell = context.read<AppShellController>();
      _shell!.addListener(_applyShellMapJump);
      _applyShellMapJump();
    });
  }

  void _applyShellMapJump() {
    if (!mounted) return;
    final shell = _shell ?? context.read<AppShellController>();
    if (shell.index != 2) return;

    final jump = shell.consumeMapJump();
    if (jump != null) {
      _mapController.move(jump.point, jump.zoom);
    }
  }

  @override
  void dispose() {
    _shell?.removeListener(_applyShellMapJump);
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadCityWeather() async {
    setState(() => _loadingCityWeather = true);

    final Map<String, CityWeatherBundle> loaded = {};

    try {
      for (final city in kMalaysianCities) {
        final weather = await _weatherService.fetchCityWeather(
          cityName: city.name,
          lat: city.lat,
          lon: city.lng,
        );
        loaded[city.name] = weather;
      }

      if (!mounted) return;
      setState(() {
        _cityWeatherByName
          ..clear()
          ..addAll(loaded);
        _loadingCityWeather = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCityWeather = false;
        _locationToast =
            'Weather data could not be loaded right now. Map is still available.';
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _locationToast = null);
        }
      });
    }
  }

  void _zoomBy(double delta) {
    final cam = _mapController.camera;
    final z = (cam.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(cam.center, z);
  }

  void _fitMalaysia() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _mapBounds,
        padding: const EdgeInsets.fromLTRB(28, 96, 28, 120),
        maxZoom: 6.5,
        minZoom: _minZoom,
      ),
    );
  }

  void _fitWildlifeHotspots() {
    final points = <LatLng>[
      for (final loc in speciesLocations) LatLng(loc.lat, loc.lng),
      for (final spot in photographySpots) LatLng(spot.lat, spot.lng),
    ];

    if (points.isEmpty) {
      _fitMalaysia();
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(32, 96, 32, 120),
        maxZoom: 10,
        minZoom: _minZoom,
      ),
    );
  }

  void _goToMyLocation() {
    final u = _user;
    if (u == null) return;
    _mapController.move(u, 10);
  }

  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationToast = 'Location permission denied. Using Malaysia view.';
            _loadingLocation = false;
          });

          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() => _locationToast = null);
            }
          });
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _user = LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _locationToast = 'Unable to detect your location. Using Malaysia view.';
        _loadingLocation = false;
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _locationToast = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final protectedPolygons = <Polygon>[
      for (final z in restrictedZones)
        Polygon(
          points: z.coordinates,
          color: Colors.red.withValues(alpha: 0.14),
          borderColor: Colors.red.shade700,
          borderStrokeWidth: 2,
        ),
      for (final a in protectedAreas)
        Polygon(
          points: a.coordinates,
          color: Colors.green.withValues(alpha: 0.12),
          borderColor: AppColors.primary,
          borderStrokeWidth: 2,
        ),
    ];

    final circles = <CircleMarker>[
      if (_user != null)
        CircleMarker(
          point: _user!,
          radius: 10000,
          useRadiusInMeter: true,
          color: const Color(0xFF6FCF97).withValues(alpha: 0.08),
          borderColor: const Color(0xFF6FCF97),
          borderStrokeWidth: 2,
        ),
    ];

    final photographyMarkers = <Marker>[
      if (_showPhotoSpots)
        for (final spot in photographySpots)
          Marker(
            point: LatLng(spot.lat, spot.lng),
            width: 38,
            height: 38,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showPhotographySpotSheet(context, spot),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📷', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
    ];

    final speciesMarkers = <Marker>[
      if (_showWildlifeMarkers)
        for (final loc in speciesLocations)
          if (speciesById(loc.speciesId) != null)
            _buildSpeciesMarker(context, speciesById(loc.speciesId)!, loc),
    ];

    final userMarkers = <Marker>[
      if (_user != null)
        Marker(
          point: _user!,
          width: 28,
          height: 28,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6FCF97),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Color(0x992F855A),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];

    final cityWeatherMarkers = <Marker>[
      if (_showCityWeatherMarkers)
        for (final city in kMalaysianCities)
          Marker(
            point: LatLng(city.lat, city.lng),
            width: 88,
            height: 88,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final weather = _cityWeatherByName[city.name];
                if (weather != null) {
                  _showCityWeatherSheet(context, city, weather);
                }
              },
              child: _CityWeatherMarker(
                cityName: city.name,
                weather: _cityWeatherByName[city.name],
                loading: _loadingCityWeather &&
                    !_cityWeatherByName.containsKey(city.name),
              ),
            ),
          ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: _mapOptions,
          children: [
            TileLayer(
              urlTemplate: mapboxStaticTilesUrlTemplate,
            ),
            IgnorePointer(
              child: PolygonLayer(polygons: protectedPolygons),
            ),
            IgnorePointer(
              child: CircleLayer(circles: circles),
            ),
            MarkerLayer(
              markers: [
                ...cityWeatherMarkers,
                ...photographyMarkers,
                ...speciesMarkers,
                ...userMarkers,
              ],
            ),
          ],
        ),
        if (_locationToast != null)
          Positioned(
            top: 84,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_locationToast!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _locationToast = null),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_loadingLocation)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        _buildMapControls(),
      ],
    );
  }

  Marker _buildSpeciesMarker(
    BuildContext context,
    Species species,
    SpeciesLocation loc,
  ) {
    final weather = closestWeather(loc.lat, loc.lng);
    final spot = photographySpotForSpecies(species.id);
    final protected = protectedAreaAt(loc.lat, loc.lng);
    final danger = isInDangerZone(loc.lat, loc.lng);

    return Marker(
      point: LatLng(loc.lat, loc.lng),
      width: 44,
      height: 44,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showSpeciesSheet(
          context,
          species,
          loc,
          weather,
          spot,
          protected,
          danger,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black26,
              ),
            ],
          ),
          child: const Center(
            child: Text('🦁', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 12,
      bottom: 12,
      child: SafeArea(
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.96),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Refresh weather',
                onPressed: _loadCityWeather,
                icon: Icon(
                  _loadingCityWeather ? Icons.sync : Icons.refresh,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: _showCityWeatherMarkers
                    ? 'Hide city weather'
                    : 'Show city weather',
                onPressed: () {
                  setState(() {
                    _showCityWeatherMarkers = !_showCityWeatherMarkers;
                  });
                },
                icon: Icon(
                  _showCityWeatherMarkers
                      ? Icons.location_city
                      : Icons.location_city_outlined,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: _showWildlifeMarkers
                    ? 'Hide wildlife markers'
                    : 'Show wildlife markers',
                onPressed: () {
                  setState(() {
                    _showWildlifeMarkers = !_showWildlifeMarkers;
                  });
                },
                icon: Icon(
                  _showWildlifeMarkers
                      ? Icons.pets
                      : Icons.pets_outlined,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: _showPhotoSpots
                    ? 'Hide photo spots'
                    : 'Show photo spots',
                onPressed: () {
                  setState(() {
                    _showPhotoSpots = !_showPhotoSpots;
                  });
                },
                icon: Icon(
                  _showPhotoSpots
                      ? Icons.camera_alt
                      : Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: 'Fit Malaysia',
                onPressed: _fitMalaysia,
                icon: const Icon(Icons.public, color: AppColors.primary),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: 'Show wildlife hotspots',
                onPressed: _fitWildlifeHotspots,
                icon: const Icon(
                  Icons.filter_center_focus,
                  color: AppColors.primary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              if (_user != null) ...[
                Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                IconButton(
                  tooltip: 'My location',
                  onPressed: _goToMyLocation,
                  icon: const Icon(Icons.my_location, color: AppColors.primary),
                  visualDensity: VisualDensity.compact,
                ),
              ],
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: 'Zoom in',
                onPressed: () => _zoomBy(1),
                icon: const Icon(Icons.add, color: AppColors.primary),
                visualDensity: VisualDensity.compact,
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              IconButton(
                tooltip: 'Zoom out',
                onPressed: () => _zoomBy(-1),
                icon: const Icon(Icons.remove, color: AppColors.primary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotographySpotSheet(BuildContext context, PhotographySpot place) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📷', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${place.habitatType} · ${place.accessibility}${place.publicAccess ? '' : ' · Restricted'}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  place.description,
                  style: TextStyle(color: Colors.grey.shade800, height: 1.45),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpeciesSheet(
    BuildContext context,
    Species species,
    SpeciesLocation loc,
    WeatherData weather,
    PhotographySpot? spot,
    ProtectedArea? protected,
    bool danger,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, scroll) {
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 140,
                  child: SpeciesNetworkImage(
                    url: species.imageUrl,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(label: Text('${species.difficultyLevel}★')),
                ),
                Text(
                  species.commonName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Last seen: ${loc.lastSeen}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (protected != null)
                  ListTile(
                    leading: const Text('🛡️', style: TextStyle(fontSize: 22)),
                    title: Text(
                      protected.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )
                else if (danger)
                  ListTile(
                    leading: Icon(Icons.warning, color: Colors.red.shade700),
                    title: Text(
                      'Danger Zone - Not Recommended',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade800,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )
                else
                  ListTile(
                    leading: Icon(
                      Icons.warning_amber,
                      color: Colors.amber.shade800,
                    ),
                    title: Text(
                      'Outside Protected Area',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (spot != null)
                  ListTile(
                    leading: const Text('📷'),
                    title: Text(
                      spot.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ListTile(
                  leading: Text(weatherEmoji(weather.condition)),
                  title: Text('${weather.temperature}°C • ${weather.condition}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SpeciesDetailScreen(speciesId: species.id),
                      ),
                    );
                  },
                  child: const Text('View More Details'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCityWeatherSheet(
    BuildContext context,
    MalaysianCity city,
    CityWeatherBundle weather,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      openWeatherIconUrl(weather.iconCode),
                      width: 52,
                      height: 52,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.cloud,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${city.state} • ${weather.temperature.toStringAsFixed(0)}°C • ${weather.description}',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: 'Humidity ${weather.humidity}%'),
                    _InfoChip(
                      label: 'Wind ${weather.windSpeed.toStringAsFixed(1)} m/s',
                    ),
                    _InfoChip(
                      label:
                          'Updated ${weather.fetchedAt.hour.toString().padLeft(2, '0')}:${weather.fetchedAt.minute.toString().padLeft(2, '0')}',
                    ),
                    _InfoChip(
                      label:
                          'Prediction Region: ${predictionRegionForCity(city)}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Next Forecast Slots',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: weather.forecast.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final point = weather.forecast[index];
                      return Container(
                        width: 112,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${point.time.hour.toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Image.network(
                              openWeatherIconUrl(point.iconCode),
                              width: 34,
                              height: 34,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.cloud_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${point.temperature.toStringAsFixed(0)}°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This city weather marker gives a quick overview for that area. Wildlife markers remain separate for animal-specific details.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CityWeatherMarker extends StatelessWidget {
  const _CityWeatherMarker({
    required this.cityName,
    required this.weather,
    required this.loading,
  });

  final String cityName;
  final CityWeatherBundle? weather;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _glassShell(
        child: const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    if (weather == null) {
      return _glassShell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud_off, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'No data',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return _glassShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Image.network(
              openWeatherIconUrl(weather!.iconCode),
              errorBuilder: (_, _, _) => const Icon(
                Icons.cloud,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            weather!.temperature.toStringAsFixed(0),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.accent,
            ),
          ),
          Text(
            cityName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassShell({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}