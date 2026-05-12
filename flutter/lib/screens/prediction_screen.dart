import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/malaysia_cities.dart';
import '../data/predictions_data.dart'; // Retained for biological habits (timeOfDay)
import '../data/site_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../services/prediction_manager.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/species_network_image.dart';
import 'species_prediction_screen.dart';

/// Region-first prediction browser grouped by nearby photography sites.
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String _selectedCity = 'Kuala Lumpur';

  // Helper: Convert decimal probability to UI text label
  String _getProbLabel(double p) {
    if (p >= 0.7) return 'High';
    if (p >= 0.4) return 'Medium';
    return 'Low';
  }

  Color _probabilityColors(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFAED9B2);
      case 'Medium':
        return const Color(0xFFE7C85E);
      case 'Low':
        return const Color(0xFFE9B8AF);
      default:
        return const Color(0xFFE7E0D4);
    }
  }

  Color _probabilityOnColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFF1F4B36);
      case 'Medium':
      case 'Low':
      default:
        return const Color(0xFF4F4330);
    }
  }

  IconData _weatherIcon(String weather) {
    final w = weather.toLowerCase();
    if (w.contains('sun') || w.contains('clear')) return Icons.wb_sunny_outlined;
    if (w.contains('cloud')) return Icons.cloud_outlined;
    if (w.contains('rain')) return Icons.umbrella_outlined;
    return Icons.wb_sunny_outlined;
  }

  IconData _timeOfDayIcon(String timeOfDay) {
    final value = timeOfDay.toLowerCase();
    if (value.contains('night')) return Icons.dark_mode_outlined;
    if (value.contains('morning')) return Icons.wb_twilight_outlined;
    if (value.contains('afternoon')) return Icons.wb_sunny_outlined;
    if (value.contains('evening') || value.contains('dusk')) return Icons.nights_stay_outlined;
    return Icons.schedule_outlined;
  }

  Color _timeOfDayIconColor(String timeOfDay) {
    final value = timeOfDay.toLowerCase();
    if (value.contains('night')) return const Color(0xFF5A4B3B);
    if (value.contains('morning')) return const Color(0xFFB08A2C);
    if (value.contains('afternoon')) return const Color(0xFFD2A33B);
    if (value.contains('evening') || value.contains('dusk')) return const Color(0xFF7C6650);
    return AppColors.badgeText;
  }

  Future<void> _openCityPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    final saved = context.watch<SavedSpeciesProvider>();

    // Retrieve all sites associated with the selected city
    final citySites =
    siteData.where((site) => site.cityName == _selectedCity).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return ListenableBuilder(
        listenable: PredictionManager.instance,
        builder: (context, _) {
          final isCalculating = PredictionManager.instance.isCalculating;

          final slivers = <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18 * s, 44 * s, 18 * s, 8 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predictions',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: Adaptive.clamp(context, 38, min: 30, max: 42),
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Malaysian Wildlife Explorer',
                          style: GoogleFonts.inter(
                            color: AppColors.textSubtitleOnFrost,
                            fontSize: Adaptive.clamp(context, 17, min: 15, max: 19),
                          ),
                        ),
                        if (isCalculating) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
                          )
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 12 * s),
                child: Container(
                  padding: EdgeInsets.all(16 * s),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22 * s),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.calmShadow,
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40 * s,
                            height: 40 * s,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Text(
                            'Select Region',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * s),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openCityPicker,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * s,
                              vertical: 14 * s,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
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
                                        style: GoogleFonts.inter(
                                          fontSize: Adaptive.clamp(
                                            context,
                                            16,
                                            min: 14,
                                            max: 18,
                                          ),
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      Text(
                                        'Tap to search all cities',
                                        style: GoogleFonts.inter(
                                          fontSize: Adaptive.clamp(
                                            context,
                                            12,
                                            min: 10,
                                            max: 14,
                                          ),
                                          color: AppColors.textSubtitleOnFrost,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 24 * s,
                                  color: AppColors.iconSectionOnFrost,
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

          // If this city has no registered sites, display an empty state
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
            // Display the main section header
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * s, 10 * s, 16 * s, 6 * s),
                  child: Text(
                    'Top Predictions by Site',
                    style: GoogleFonts.libreBaskerville(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      fontSize: Adaptive.clamp(context, 22, min: 18, max: 26),
                    ),
                  ),
                ),
              ),
            );

            // Iterate through ALL sites in the selected city
            for (final site in citySites) {
              // Render the site name pill
              slivers.add(
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 8 * s),
                    child: _sitePill(siteName: site.name, s: s),
                  ),
                ),
              );

              // Filter and sort the supported species by their calculated probability
              final speciesList = site.supportedSpeciesIds
                  .map((id) => speciesById(id))
                  .whereType<Species>()
                  .toList()
                ..sort((a, b) {
                  final pA = PredictionManager.instance.latestPredictions[site.id]?[a.id] ?? 0.0;
                  final pB = PredictionManager.instance.latestPredictions[site.id]?[b.id] ?? 0.0;
                  return pB.compareTo(pA); // Highest probability first
                });

              if (speciesList.isEmpty) continue;

              // Render the list of species cards for this specific site
              slivers.add(
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final species = speciesList[index];

                      final forecasts = PredictionManager.instance.getSevenDayForecastForUI(site.id, species.id);
                      if (forecasts.isEmpty) return const SizedBox.shrink();

                      final today = forecasts.first;
                      final probPercent = (today.probability * 100).round();
                      final probLabel = _getProbLabel(today.probability);

                      // Retrieve the biological best time from the existing database
                      final bestTime = speciesPredictions[species.id]?.forecast.first.timeOfDay ?? 'Night';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 12 * s),
                        child: _predictionCard(
                          context: context,
                          s: s,
                          species: species,
                          saved: saved,
                          siteId: site.id, // Pass the correct Site ID
                          siteName: site.name,
                          probPercent: probPercent,
                          probLabel: probLabel,
                          weather: today.weatherDescription,
                          bestTime: bestTime,
                        ),
                      );
                    }, childCount: speciesList.length),
                  ),
                ),
              );
            }
          }

          slivers.add(SliverToBoxAdapter(child: SizedBox(height: 100 * s)));

          return Material(
            color: Colors.transparent,
            child: CustomScrollView(slivers: slivers),
          );
        }
    );
  }

  Widget _sitePill({
    required String siteName,
    required double s,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_rounded,
              color: AppColors.iconSectionOnFrost,
              size: 18 * s,
            ),
            SizedBox(width: 8 * s),
            Text(
              siteName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionCard({
    required BuildContext context,
    required double s,
    required Species species,
    required SavedSpeciesProvider saved,
    required String siteId,
    required String siteName,
    required int probPercent,
    required String probLabel,
    required String weather,
    required String bestTime,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpeciesPredictionScreen(
                speciesId: species.id,
                siteId: siteId,
                siteName: siteName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.all(10 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14 * s),
                child: SizedBox(
                  width: Adaptive.clamp(context, 126, min: 102, max: 150),
                  height: Adaptive.clamp(context, 110, min: 92, max: 128),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            species.commonName,
                            style: GoogleFonts.libreBaskerville(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                              fontSize: Adaptive.clamp(
                                context,
                                17,
                                min: 14,
                                max: 19,
                              ),
                              height: 1.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6 * s),
                        GestureDetector(
                          onTap: () async {
                            try {
                              await saved.toggleSaved(species.id);
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to update saved species. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Icon(
                            saved.isSaved(species.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: AppColors.iconSectionOnFrost,
                            size: 22 * s,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      species.scientificName,
                      style: GoogleFonts.inter(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSubtitleOnFrost,
                        fontSize: Adaptive.clamp(context, 13, min: 11, max: 14),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8 * s),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9 * s,
                                vertical: 5 * s,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F0E4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pets_rounded,
                                    size: 13 * s,
                                    color: AppColors.badgeText,
                                  ),
                                  SizedBox(width: 4 * s),
                                  Text(
                                    species.category,
                                    style: GoogleFonts.inter(
                                      color: AppColors.badgeText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6 * s),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10 * s,
                                vertical: 5 * s,
                              ),
                              decoration: BoxDecoration(
                                color: _probabilityColors(probLabel),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    size: 14 * s,
                                    color: _probabilityOnColor(probLabel),
                                  ),
                                  SizedBox(width: 3 * s),
                                  Text(
                                    '$probPercent% $probLabel',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: _probabilityOnColor(probLabel),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Row(
                      children: [
                        Icon(
                          _timeOfDayIcon(bestTime),
                          size: 16 * s,
                          color: _timeOfDayIconColor(bestTime),
                        ),
                        SizedBox(width: 4 * s),
                        Expanded(
                          child: Text(
                            bestTime,
                            style: GoogleFonts.inter(
                              color: AppColors.badgeText,
                              fontSize: Adaptive.clamp(
                                context,
                                12,
                                min: 10,
                                max: 14,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          _weatherIcon(weather),
                          size: 16 * s,
                          color: AppColors.statusYellow,
                        ),
                        SizedBox(width: 4 * s),
                        Flexible(
                          child: Text(
                            weather,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.badgeText,
                              fontSize: Adaptive.clamp(
                                context,
                                12,
                                min: 10,
                                max: 14,
                              ),
                            ),
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
      _visible = _sorted
          .where(
            (c) =>
        c.name.toLowerCase().contains(q) ||
            c.state.toLowerCase().contains(q),
      )
          .toList();
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