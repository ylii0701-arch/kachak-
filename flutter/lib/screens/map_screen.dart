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
  final TextEditingController _speciesSearchController =
      TextEditingController();
  String _speciesQuery = '';
  Species? _selectedSpecies;
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
    _speciesSearchController.dispose();
    _shell?.removeListener(_applyShellMapJump);
    _mapController.dispose();
    super.dispose();
  }

  bool _matchesSpeciesQuery(Species species, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    return species.commonName.toLowerCase().contains(q) ||
        species.scientificName.toLowerCase().contains(q);
  }

  List<Species> _matchingSpeciesSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return speciesData
        .where((species) => _matchesSpeciesQuery(species, q))
        .take(6)
        .toList(growable: false);
  }

  void _onSpeciesQueryChanged(String value) {
    final q = value.trim().toLowerCase();
    setState(() {
      _speciesQuery = value;
      if (_selectedSpecies != null) {
        final selected = _selectedSpecies!;
        final common = selected.commonName.trim().toLowerCase();
        final scientific = selected.scientificName.trim().toLowerCase();
        if (q != common && q != scientific) {
          _selectedSpecies = null;
        }
      }
    });
  }

  void _clearSpeciesSearch() {
    _speciesSearchController.clear();
    setState(() {
      _speciesQuery = '';
      _selectedSpecies = null;
    });
  }

  void _selectSpeciesSuggestion(Species species) {
    final text = species.commonName.trim().isEmpty
        ? species.scientificName
        : species.commonName;
    _speciesSearchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {
      _speciesQuery = text;
      _selectedSpecies = species;
    });
    for (final loc in speciesLocations) {
      if (loc.speciesId == species.id) {
        _mapController.move(LatLng(loc.lat, loc.lng), 11.8);
        break;
      }
    }
    FocusScope.of(context).unfocus();
  }

  Widget _buildGlassCard({
    required Widget child,
    required double scale,
    double radius = 16,
    double blur = 16,
    double alpha = 0.44,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(radius * scale),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.62),
              width: 1.1 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
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
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
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
          _locationToast =
              'Unable to detect your location. Using Kuala Lumpur.';
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
        if (mounted) setState(() => _locationToast = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final q = _speciesQuery.trim().toLowerCase();
    final suggestions = _matchingSpeciesSuggestions(_speciesQuery);
    final showSuggestionList =
        q.isNotEmpty && _selectedSpecies == null && suggestions.isNotEmpty;
    final showSpeciesMarkers = q.isNotEmpty || _selectedSpecies != null;
    final cityWeatherMarkers = <Marker>[];
    if (_showCityWeatherMarkers) {
      for (final city in kMalaysianCities) {
        cityWeatherMarkers.add(
          Marker(
            point: LatLng(city.lat, city.lng),
            width: Adaptive.clamp(context, 68, min: 56, max: 84),
            height: Adaptive.clamp(context, 68, min: 56, max: 84),
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
                    _loadingCityWeather &&
                    !_cityWeatherByName.containsKey(city.name),
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
                boxShadow: const [
                  BoxShadow(blurRadius: 6, color: Colors.black26),
                ],
              ),
              child: Center(
                child: Text(
                  '📷',
                  style: TextStyle(
                    fontSize: Adaptive.clamp(context, 16, min: 13, max: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final speciesMarkers = <Marker>[];
    if (showSpeciesMarkers) {
      for (final loc in speciesLocations) {
        final species = speciesById(loc.speciesId);
        if (species == null) continue;
        if (_selectedSpecies != null && species.id != _selectedSpecies!.id) {
          continue;
        }
        if (_selectedSpecies == null && !_matchesSpeciesQuery(species, q)) {
          continue;
        }
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
                    BoxShadow(blurRadius: 6, color: Colors.black26),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🦁',
                    style: TextStyle(
                      fontSize: Adaptive.clamp(context, 18, min: 14, max: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
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
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Color(0x992F855A)),
                ],
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
            IgnorePointer(child: PolygonLayer(polygons: polygons)),
            IgnorePointer(child: CircleLayer(circles: circles)),
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
            padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: Adaptive.clamp(context, 126, min: 106, max: 150),
                      child: _buildGlassCard(
                        scale: s,
                        radius: 18,
                        child: SizedBox(
                          height: Adaptive.clamp(context, 52, min: 46, max: 60),
                          child: Center(
                            child: Text(
                              'Wildlife Map',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: Adaptive.clamp(
                                  context,
                                  18,
                                  min: 15,
                                  max: 22,
                                ),
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: _buildGlassCard(
                        scale: s,
                        radius: 18,
                        child: SizedBox(
                          height: Adaptive.clamp(context, 52, min: 46, max: 60),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44 * s,
                                child: Icon(
                                  Icons.search,
                                  color: AppColors.accent.withValues(alpha: 0.86),
                                  size: Adaptive.clamp(context, 20, min: 17, max: 23),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _speciesSearchController,
                                  onChanged: _onSpeciesQueryChanged,
                                  textInputAction: TextInputAction.search,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: Adaptive.clamp(
                                      context,
                                      15,
                                      min: 13,
                                      max: 18,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search species',
                                    hintStyle: TextStyle(
                                      color: AppColors.accent.withValues(alpha: 0.84),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6 * s,
                                      vertical: 10 * s,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 44 * s,
                                child: q.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: AppColors.accent.withValues(
                                            alpha: 0.86,
                                          ),
                                        ),
                                        onPressed: _clearSpeciesSearch,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showSuggestionList) ...[
                  SizedBox(height: 8 * s),
                  Row(
                    children: [
                      SizedBox(
                        width: Adaptive.clamp(context, 160, min: 138, max: 200),
                      ),
                      Expanded(
                        child: _buildGlassCard(
                          scale: s,
                          radius: 16,
                          alpha: 0.86,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: Adaptive.clamp(
                                context,
                                230,
                                min: 180,
                                max: 260,
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 6 * s),
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              itemBuilder: (context, index) {
                                final species = suggestions[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.pets,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    species.commonName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Adaptive.clamp(
                                        context,
                                        14,
                                        min: 12,
                                        max: 16,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    species.scientificName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontSize: Adaptive.clamp(
                                        context,
                                        12,
                                        min: 10,
                                        max: 14,
                                      ),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onTap: () =>
                                      _selectSpeciesSuggestion(species),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 22 * s,
                    ),
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
                          ? Icons.cloud_rounded
                          : Icons.cloud_off_rounded,
                      color: AppColors.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                  IconButton(
                    tooltip: 'Show species & photo spots',
                    onPressed: _fitWildlifeHotspots,
                    icon: const Icon(
                      Icons.filter_center_focus,
                      color: AppColors.primary,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (_user != null)
                    IconButton(
                      tooltip: 'My location',
                      onPressed: _goToMyLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
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
                  species.scientificName,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
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
                  title: Text(
                    '${weather.temperature}°C • ${weather.condition}',
                  ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: Adaptive.clamp(context, 46, min: 38, max: 56),
                        height: Adaptive.clamp(context, 46, min: 38, max: 56),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: Adaptive.clamp(
                              context,
                              40,
                              min: 32,
                              max: 48,
                            ),
                            height: Adaptive.clamp(
                              context,
                              40,
                              min: 32,
                              max: 48,
                            ),
                            child: Image.network(
                              'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Icon(
                                  Icons.cloud_queue,
                                  color: AppColors.primary,
                                );
                              },
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.cloud_queue,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Adaptive.of(context, 10)),
                      Expanded(
                        child: Text(
                          city.name,
                          style: TextStyle(
                            fontSize: Adaptive.clamp(
                              context,
                              18,
                              min: 15,
                              max: 22,
                            ),
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
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: Adaptive.clamp(context, 14, min: 12, max: 17),
                    ),
                  ),
                  SizedBox(height: Adaptive.of(context, 8)),
                  Text(
                    'Humidity ${weather.humidity}% · Wind ${weather.windSpeed.toStringAsFixed(1)} m/s',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: Adaptive.clamp(context, 13, min: 11, max: 16),
                    ),
                  ),
                  SizedBox(height: Adaptive.of(context, 8)),
                  Text(
                    'Prediction region: ${predictionRegionForCityName(city.name)}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: Adaptive.clamp(context, 13, min: 11, max: 16),
                    ),
                  ),
                  SizedBox(height: Adaptive.of(context, 14)),
                  Text(
                    'Next 3-hour forecast',
                    style: TextStyle(
                      fontSize: Adaptive.clamp(context, 14, min: 12, max: 17),
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: Adaptive.of(context, 8)),
                  if (weather.forecast.isEmpty)
                    Text(
                      'Forecast is not available right now.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: Adaptive.clamp(context, 12, min: 11, max: 14),
                      ),
                    )
                  else
                    SizedBox(
                      height: Adaptive.clamp(context, 124, min: 108, max: 148),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: weather.forecast.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(width: Adaptive.of(context, 8)),
                        itemBuilder: (context, index) {
                          final slot = weather.forecast[index];
                          return _ForecastMiniCard(slot: slot);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForecastMiniCard extends StatelessWidget {
  const _ForecastMiniCard({required this.slot});

  final CityForecastEntry slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Adaptive.clamp(context, 112, min: 98, max: 130),
      padding: EdgeInsets.all(Adaptive.of(context, 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _slotLabel(slot.timestamp),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: Adaptive.clamp(context, 11, min: 10, max: 13),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: Adaptive.clamp(context, 28, min: 24, max: 34),
                height: Adaptive.clamp(context, 28, min: 24, max: 34),
                child: Image.network(
                  'https://openweathermap.org/img/wn/${slot.iconCode}.png',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Icon(
                      Icons.cloud_queue,
                      color: AppColors.primary,
                    );
                  },
                  errorBuilder: (_, _, _) => const Icon(Icons.cloud),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${slot.temperature.toStringAsFixed(0)}°C',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: Adaptive.clamp(context, 12, min: 11, max: 14),
                  ),
                ),
              ),
            ],
          ),
          Text(
            slot.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: Adaptive.clamp(context, 10, min: 9, max: 12),
            ),
          ),
          Text(
            'H ${slot.humidity}% · W ${slot.windSpeed.toStringAsFixed(1)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: Adaptive.clamp(context, 9, min: 8, max: 11),
            ),
          ),
        ],
      ),
    );
  }
}

String _slotLabel(DateTime dt) {
  final local = dt.toLocal();
  final day = _weekdayShort(local.weekday);
  final hour = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$day $hour:$min';
}

String _weekdayShort(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final iconSize = (maxH * 0.34).clamp(16.0, 26.0);
        final tempSize = (maxH * 0.19).clamp(10.0, 13.0);
        final citySize = (maxH * 0.145).clamp(8.0, 11.0);
        final paddingH = (maxW * 0.09).clamp(4.0, 7.0);
        final paddingV = (maxH * 0.08).clamp(3.0, 6.0);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular((maxW * 0.18).clamp(8.0, 14.0)),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black38)],
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: (iconSize * 0.1).clamp(1.6, 2.4),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (weather != null)
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: Image.network(
                              'https://openweathermap.org/img/wn/${weather!.iconCode}@2x.png',
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Icon(
                                  Icons.cloud_queue,
                                  color: AppColors.primary,
                                  size: iconSize * 0.8,
                                );
                              },
                              errorBuilder: (_, _, _) => Icon(
                                Icons.cloud_queue,
                                color: AppColors.primary,
                                size: iconSize * 0.8,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.cloud_off,
                            color: Colors.grey.shade600,
                            size: iconSize * 0.8,
                          ),
                        SizedBox(height: (maxH * 0.03).clamp(1.0, 3.0)),
                        Text(
                          weather != null
                              ? '${weather!.temperature.toStringAsFixed(0)}°'
                              : '--',
                          style: TextStyle(
                            fontSize: tempSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(
                          width: maxW * 0.8,
                          child: Text(
                            cityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: citySize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
