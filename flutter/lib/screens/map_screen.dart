import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/map_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final photographyMarkers = <Marker>[];
    for (final spot in photographySpots) {
      photographyMarkers.add(
        Marker(
          point: LatLng(spot.lat, spot.lng),
          width: 36,
          height: 36,
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
              child: const Center(child: Text('📷', style: TextStyle(fontSize: 16))),
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
          width: 44,
          height: 44,
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
              child: const Center(child: Text('🦁', style: TextStyle(fontSize: 18))),
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
          width: 28,
          height: 28,
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
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                ...photographyMarkers,
                ...speciesMarkers,
                ...userMarkers,
              ],
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.44),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.62), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Wildlife Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
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
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
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
        Positioned(
          right: 12,
          bottom: 12,
          child: SafeArea(
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
}
