import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../utils/adaptive.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _kDefaultCenter = LatLng(3.1390, 101.6869);

  /// All observation data is in Peninsular Malaysia; the map must frame this
  /// region. Auto-panning to the device's GPS (e.g. North America) would move
  /// the viewport away from every marker (they are culled when off-screen).
  static LatLngBounds get _wildlifeBounds {
    final points = <LatLng>[
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
  bool _loadingCityWeather = false;
  bool _showCityWeatherMarkers = true;
  final Map<String, CityWeatherBundle> _cityWeatherByName = {};
  final OpenWeatherService _weatherService = const OpenWeatherService(
    apiKey: openWeatherApiKey,
  );

  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  @override
  void initState() {
    super.initState();
    _mapOptions = MapOptions(
      initialCenter: _kDefaultCenter,
      initialZoom: 12,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
      keepAlive: true,
      initialCameraFit: CameraFit.bounds(
        bounds: _wildlifeBounds,
        padding: const EdgeInsets.fromLTRB(32, 88, 32, 120),
        maxZoom: 13,
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

  void _zoomBy(double delta) {
    final cam = _mapController.camera;
    final z = (cam.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(cam.center, z);
  }

  void _fitWildlifeHotspots() {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _wildlifeBounds,
        padding: const EdgeInsets.fromLTRB(32, 88, 32, 120),
        maxZoom: 13,
        minZoom: _minZoom,
      ),
    );
  }

  void _goToMyLocation() {
    final u = _user;
    if (u == null) return;
    _mapController.move(u, 12);
  }

  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationToast = 'Location permission denied. Using Kuala Lumpur.';
            _loadingLocation = false;
          });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) setState(() => _locationToast = null);
          });
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        final here = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _user = here;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationToast = 'Unable to detect your location. Using Kuala Lumpur.';
          _loadingLocation = false;
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _locationToast = null);
        });
      }
    }
  }

  Future<void> _loadCityWeather() async {
    setState(() => _loadingCityWeather = true);

    try {
      final loaded = <String, CityWeatherBundle>{};
      for (final city in _mapWeatherCities) {
        final coords = _weatherCityCoordinates[city.name];
        if (coords == null) continue;
        final weather = await _weatherService.fetchCityWeather(
          cityName: city.name,
          lat: coords.latitude,
          lon: coords.longitude,
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
        if (mounted) setState(() => _locationToast = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final cityWeatherMarkers = <Marker>[];
    if (_showCityWeatherMarkers) {
      for (final city in _mapWeatherCities) {
        final coords = _weatherCityCoordinates[city.name];
        if (coords == null) continue;
        cityWeatherMarkers.add(
          Marker(
            point: coords,
            width: Adaptive.clamp(context, 64, min: 52, max: 78),
            height: Adaptive.clamp(context, 64, min: 52, max: 78),
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
                loading:
                    _loadingCityWeather && !_cityWeatherByName.containsKey(city.name),
              ),
            ),
          ),
        );
      }
    }

    final photographyMarkers = <Marker>[];
    for (final spot in photographySpots) {
      photographyMarkers.add(
        Marker(
          point: LatLng(spot.lat, spot.lng),
          width: Adaptive.clamp(context, 36, min: 30, max: 44),
          height: Adaptive.clamp(context, 36, min: 30, max: 44),
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
              ),
              child: Center(
                child: Text(
                  '📷',
                  style: TextStyle(fontSize: Adaptive.clamp(context, 16, min: 13, max: 20)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final speciesMarkers = <Marker>[];
    for (final loc in speciesLocations) {
      final species = speciesById(loc.speciesId);
      if (species == null) continue;
      final weather = closestWeather(loc.lat, loc.lng);
      final spot = photographySpotForSpecies(species.id);
      final protected = protectedAreaAt(loc.lat, loc.lng);
      final danger = isInDangerZone(loc.lat, loc.lng);

      speciesMarkers.add(
        Marker(
          point: LatLng(loc.lat, loc.lng),
          width: Adaptive.clamp(context, 44, min: 36, max: 52),
          height: Adaptive.clamp(context, 44, min: 36, max: 52),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showSpeciesSheet(context, species, loc, weather, spot, protected, danger),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
              ),
              child: Center(
                child: Text(
                  '🦁',
                  style: TextStyle(fontSize: Adaptive.clamp(context, 18, min: 14, max: 22)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final userMarkers = <Marker>[];
    if (_user != null) {
      userMarkers.add(
        Marker(
          point: _user!,
          width: Adaptive.clamp(context, 28, min: 24, max: 34),
          height: Adaptive.clamp(context, 28, min: 24, max: 34),
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6FCF97),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x992F855A))],
              ),
            ),
          ),
        ),
      );
    }

    final polygons = <Polygon>[];
    for (final z in restrictedZones) {
      polygons.add(
        Polygon(
          points: z.coordinates,
          color: Colors.red.withValues(alpha: 0.15),
          borderColor: Colors.red.shade700,
          borderStrokeWidth: 2,
        ),
      );
    }
    for (final a in protectedAreas) {
      polygons.add(
        Polygon(
          points: a.coordinates,
          color: Colors.green.withValues(alpha: 0.12),
          borderColor: AppColors.primary,
          borderStrokeWidth: 2,
        ),
      );
    }

    final circles = <CircleMarker>[];
    if (_user != null) {
      circles.add(
        CircleMarker(
          point: _user!,
          radius: 10000,
          useRadiusInMeter: true,
          color: const Color(0xFF6FCF97).withValues(alpha: 0.08),
          borderColor: const Color(0xFF6FCF97),
          borderStrokeWidth: 2,
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: _mapOptions,
          children: [
            TileLayer(
              urlTemplate: mapboxStaticTilesUrlTemplate,
              userAgentPackageName: 'com.kachak.kachak_tracker',
            ),
            IgnorePointer(
              child: PolygonLayer(polygons: polygons),
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
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16 * s),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20 * s),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.44),
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.62), width: 1.1 * s),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
                    child: Text(
                      'Wildlife Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Adaptive.clamp(context, 18, min: 15, max: 22),
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_locationToast != null)
          Positioned(
            top: 72,
            left: 16 * s,
            right: 16 * s,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16 * s),
              child: Padding(
                padding: EdgeInsets.all(12 * s),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 22 * s),
                    SizedBox(width: 10 * s),
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
        Positioned(
          right: 12 * s,
          bottom: 12 * s,
          child: SafeArea(
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12 * s),
              color: Colors.white,
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
                    tooltip: 'Show species & photo spots',
                    onPressed: _fitWildlifeHotspots,
                    icon: const Icon(Icons.filter_center_focus, color: AppColors.primary),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (_user != null)
                    IconButton(
                      tooltip: 'My location',
                      onPressed: _goToMyLocation,
                      icon: const Icon(Icons.my_location, color: AppColors.primary),
                      visualDensity: VisualDensity.compact,
                    ),
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
        ),
      ],
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
            padding: Adaptive.insets(
              context,
              horizontal: 20,
              vertical: 16,
            ).copyWith(bottom: Adaptive.of(context, 24)),
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
                Text(place.description, style: TextStyle(color: Colors.grey.shade800, height: 1.45)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                Text(species.commonName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('Last seen: ${loc.lastSeen}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 12),
                if (protected != null)
                  ListTile(
                    leading: const Text('🛡️', style: TextStyle(fontSize: 22)),
                    title: Text(protected.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )
                else if (danger)
                  ListTile(
                    leading: Icon(Icons.warning, color: Colors.red.shade700),
                    title: Text('Danger Zone - Not Recommended', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade800)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )
                else
                  ListTile(
                    leading: Icon(Icons.warning_amber, color: Colors.amber.shade800),
                    title: Text('Outside Protected Area', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade900)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (spot != null)
                  ListTile(
                    leading: const Text('📷'),
                    title: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                      MaterialPageRoute<void>(builder: (_) => SpeciesDetailScreen(speciesId: species.id)),
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
                  children: [
                    SizedBox(
                      width: Adaptive.clamp(context, 42, min: 34, max: 52),
                      height: Adaptive.clamp(context, 42, min: 34, max: 52),
                      child: Image.network(
                        'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.cloud,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: Adaptive.of(context, 10)),
                    Expanded(
                      child: Text(
                        city.name,
                        style: TextStyle(
                          fontSize: Adaptive.clamp(context, 18, min: 15, max: 22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Adaptive.of(context, 10)),
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C · ${weather.description}',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: Adaptive.clamp(context, 14, min: 12, max: 17),
                  ),
                ),
                SizedBox(height: Adaptive.of(context, 8)),
                Text(
                  'Humidity ${weather.humidity}% · Wind ${weather.windSpeed.toStringAsFixed(1)} m/s',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: Adaptive.clamp(context, 13, min: 11, max: 16),
                  ),
                ),
                SizedBox(height: Adaptive.of(context, 8)),
                Text(
                  'Prediction region: ${predictionRegionForCityName(city.name)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: Adaptive.clamp(context, 13, min: 11, max: 16),
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
    final s = Adaptive.scale(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white, width: 1.3 * s),
        boxShadow: [BoxShadow(blurRadius: 6 * s, color: Colors.black26)],
      ),
      child: loading
          ? SizedBox(
              width: Adaptive.clamp(context, 20, min: 16, max: 24),
              height: Adaptive.clamp(context, 20, min: 16, max: 24),
              child: CircularProgressIndicator(strokeWidth: 2 * s),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (weather != null)
                  SizedBox(
                    width: Adaptive.clamp(context, 18, min: 14, max: 22),
                    height: Adaptive.clamp(context, 18, min: 14, max: 22),
                    child: Image.network(
                      'https://openweathermap.org/img/wn/${weather!.iconCode}.png',
                      errorBuilder: (_, _, _) => Icon(
                        Icons.cloud,
                        size: Adaptive.clamp(context, 14, min: 12, max: 17),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.cloud_off,
                    size: Adaptive.clamp(context, 14, min: 12, max: 17),
                  ),
                Text(
                  weather != null ? '${weather!.temperature.toStringAsFixed(0)}°' : '--',
                  style: TextStyle(
                    fontSize: Adaptive.clamp(context, 11, min: 10, max: 13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(
                  width: Adaptive.clamp(context, 48, min: 38, max: 58),
                  child: Text(
                    cityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Adaptive.clamp(context, 9, min: 8, max: 11),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

const List<MalaysianCity> _mapWeatherCities = [
  MalaysianCity('Kuala Lumpur', 'Kuala Lumpur'),
  MalaysianCity('Ipoh', 'Perak'),
  MalaysianCity('Kuching', 'Sarawak'),
  MalaysianCity('Kota Kinabalu', 'Sabah'),
  MalaysianCity('Johor Bahru', 'Johor'),
  MalaysianCity('George Town', 'Pulau Pinang'),
  MalaysianCity('Shah Alam', 'Selangor'),
  MalaysianCity('Melaka', 'Melaka'),
  MalaysianCity('Alor Setar', 'Kedah'),
  MalaysianCity('Miri', 'Sarawak'),
  MalaysianCity('Kuantan', 'Pahang'),
  MalaysianCity('Kuala Terengganu', 'Terengganu'),
  MalaysianCity('Seremban', 'Negeri Sembilan'),
];

const Map<String, LatLng> _weatherCityCoordinates = {
  'Kuala Lumpur': LatLng(3.1390, 101.6869),
  'Ipoh': LatLng(4.5975, 101.0901),
  'Kuching': LatLng(1.5533, 110.3592),
  'Kota Kinabalu': LatLng(5.9804, 116.0735),
  'Johor Bahru': LatLng(1.4927, 103.7414),
  'George Town': LatLng(5.4141, 100.3288),
  'Shah Alam': LatLng(3.0738, 101.5183),
  'Melaka': LatLng(2.1896, 102.2501),
  'Alor Setar': LatLng(6.1248, 100.3678),
  'Miri': LatLng(4.3995, 113.9914),
  'Kuantan': LatLng(3.8077, 103.3260),
  'Kuala Terengganu': LatLng(5.3302, 103.1408),
  'Seremban': LatLng(2.7297, 101.9381),
};
