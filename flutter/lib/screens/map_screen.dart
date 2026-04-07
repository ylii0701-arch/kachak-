import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/map_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(3.1390, 101.6869);
  LatLng? _user;
  String? _locationToast;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
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
        setState(() {
          _user = LatLng(pos.latitude, pos.longitude);
          _center = _user!;
          _loadingLocation = false;
        });
        _mapController.move(_center, 12);
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
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6FCF97),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x992F855A))],
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
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 12,
            minZoom: 3,
            maxZoom: 18,
            onPositionChanged: (pos, _) {
              _center = pos.center;
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kachak.kachak_tracker',
            ),
            PolygonLayer(polygons: polygons),
            CircleLayer(circles: circles),
            MarkerLayer(markers: [...speciesMarkers, ...userMarkers]),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Wildlife Map',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.5))],
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
      ],
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
