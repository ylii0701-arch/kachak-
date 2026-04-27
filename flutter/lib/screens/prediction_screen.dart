import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/malaysia_cities.dart';
import '../data/map_data.dart';
import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
import '../widgets/species_network_image.dart';
import 'species_prediction_screen.dart';
import '../data/site_data.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  /// Selected Malaysian city (display name).
  String _selectedCity = 'Kuala Lumpur';

  Color _probabilityColors(String p) {
    switch (p) {
      case 'High':
        return Colors.green.shade100;
      case 'Medium':
        return Colors.amber.shade100;
      case 'Low':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _probabilityOnColor(String p) {
    switch (p) {
      case 'High':
        return Colors.green.shade900;
      case 'Medium':
        return Colors.amber.shade900;
      case 'Low':
        return Colors.red.shade900;
      default:
        return Colors.black87;
    }
  }

  String _weatherEmoji(String w) {
    switch (w) {
      case 'Sunny':
        return '☀️';
      case 'Partly Cloudy':
        return '⛅';
      case 'Cloudy':
        return '☁️';
      case 'Rainy':
        return '🌧️';
      default:
        return '☁️';
    }
  }

  Future<void> _openCityPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _CitySearchSheet(initialCity: _selectedCity),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedCity = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);

    // 1. Get all sites for the selected city
    final citySites = siteData.where((site) => site.cityName == _selectedCity).toList();
    citySites.sort((a, b) => a.name.compareTo(b.name));

    // 2. Build the slivers dynamically
    List<Widget> slivers = [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 42 * s, 16 * s, 10 * s),
          child: GlassPanel(
            padding: EdgeInsets.fromLTRB(20 * s, 22 * s, 20 * s, 22 * s),
            borderRadius: 26 * s,
            fillAlpha: 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predictions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: Adaptive.clamp(context, 28, min: 22, max: 34),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1.05,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Discover which species are most likely to appear in your area',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: Adaptive.clamp(context, 15, min: 13, max: 18),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * s),
          child: GlassPanel(
            padding: EdgeInsets.all(16 * s),
            borderRadius: 22 * s,
            fillAlpha: 0.38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place, color: AppColors.primary),
                    SizedBox(width: 8 * s),
                    const Text(
                      'Select Region',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openCityPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16 * s,
                          vertical: 14 * s,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 28 * s,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedCity,
                                  style: TextStyle(
                                    fontSize: Adaptive.clamp(
                                      context,
                                      16,
                                      min: 14,
                                      max: 19,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Tap to search all cities',
                                  style: TextStyle(
                                    fontSize: Adaptive.clamp(
                                      context,
                                      12,
                                      min: 10,
                                      max: 14,
                                    ),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    if (citySites.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40 * s),
            child: Center(
              child: Text(
                'No tracked sites or photography spots currently available in $_selectedCity.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16 * s),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 4 * s),
            child: Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 22 * s)),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Text(
                    'Top Predictions by Site',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Adaptive.clamp(context, 18, min: 15, max: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Loop through each site and dynamically build the sorted species list
      for (final site in citySites) {
        // Find all valid species for this site
        final speciesList = site.supportedSpeciesIds
            .map((id) => speciesById(id))
            .whereType<Species>()
            .toList();

        // Sort species descending by their probability
        speciesList.sort((a, b) {
          final pA = speciesPredictions[a.id]?.forecast.first.probabilityPercent ?? 0;
          final pB = speciesPredictions[b.id]?.forecast.first.probabilityPercent ?? 0;
          return pB.compareTo(pA);
        });

        // Add Site Header
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 8 * s),
              child: Row(
                children: [
                  Icon(Icons.park, color: AppColors.primary, size: 20 * s),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Text(
                      site.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: Adaptive.clamp(context, 16, min: 14, max: 18),
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Add the sorted Species Cards
        slivers.add(
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final species = speciesList[index];
                final pred = speciesPredictions[species.id];
                if (pred == null) return const SizedBox.shrink();

                final todayForecast = pred.forecast.first;

                return Padding(
                  padding: EdgeInsets.only(bottom: 10 * s),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SpeciesPredictionScreen(
                              speciesId: species.id,
                              siteName: site.name, // <--- PASS THE SITE NAME HERE
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16 * s),
                      child: Padding(
                        padding: EdgeInsets.all(12 * s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12 * s),
                              child: SizedBox(
                                width: Adaptive.clamp(
                                  context,
                                  96,
                                  min: 76,
                                  max: 124,
                                ),
                                height: Adaptive.clamp(
                                  context,
                                  96,
                                  min: 76,
                                  max: 124,
                                ),
                                child: SpeciesNetworkImage(
                                  url: species.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    species.commonName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    species.scientificName,
                                    style: TextStyle(
                                      fontSize: Adaptive.clamp(
                                        context,
                                        12,
                                        min: 10,
                                        max: 14,
                                      ),
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6 * s),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * s,
                                      vertical: 6 * s,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _probabilityColors(
                                        todayForecast.probability,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        10 * s,
                                      ),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: Adaptive.clamp(
                                            context,
                                            16,
                                            min: 13,
                                            max: 20,
                                          ),
                                          color: _probabilityOnColor(
                                            todayForecast.probability,
                                          ),
                                        ),
                                        SizedBox(width: 4 * s),
                                        Text(
                                          '${todayForecast.probabilityPercent}% ${todayForecast.probability}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _probabilityOnColor(
                                              todayForecast.probability,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8 * s),
                                  Row(
                                    children: [
                                      Text(
                                        '⏰ ',
                                        style: TextStyle(fontSize: 14 * s),
                                      ),
                                      Expanded(
                                        child: Text(
                                          todayForecast.timeOfDay,
                                          style: TextStyle(
                                            fontSize: Adaptive.clamp(
                                              context,
                                              12,
                                              min: 10,
                                              max: 14,
                                            ),
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Text(_weatherEmoji(todayForecast.weather)),
                                      SizedBox(width: 4 * s),
                                      Text(
                                        todayForecast.weather,
                                        style: TextStyle(
                                          fontSize: Adaptive.clamp(
                                            context,
                                            12,
                                            min: 10,
                                            max: 14,
                                          ),
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: speciesList.length),
            ),
          ),
        );
      }
    }

    // Bottom padding for scrolling
    slivers.add(SliverToBoxAdapter(child: SizedBox(height: 100 * s)));

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(slivers: slivers),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet({required this.initialCity});

  final String initialCity;

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final TextEditingController _search = TextEditingController();
  late List<MalaysianCity> _sorted;
  List<MalaysianCity> _visible = [];

  @override
  void initState() {
    super.initState();
    _sorted = List<MalaysianCity>.from(kMalaysianCities)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _visible = List<MalaysianCity>.of(_sorted);
    _search.addListener(_filter);
  }

  void _filter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _visible = _sorted.where((c) =>
      c.name.toLowerCase().contains(q) || c.state.toLowerCase().contains(q)
      ).toList();
    });
  }

  @override
  void dispose() {
    _search.removeListener(_filter);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.88;
    return SizedBox(
      height: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Select city',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search city or state…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? Center(
              child: Text(
                'No cities match your search',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (_, i) {
                final c = _visible[i];
                final sel = c.name == widget.initialCity;
                return ListTile(
                  selected: sel,
                  selectedTileColor: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.state),
                  trailing: sel
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, c.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}