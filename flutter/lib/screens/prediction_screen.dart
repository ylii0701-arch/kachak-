import 'package:flutter/material.dart';

import '../data/malaysia_cities.dart';
import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/species_network_image.dart';
import 'species_prediction_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  /// Selected Malaysian city (display name).
  String _selectedCity = 'Kuala Lumpur';

  Region get _predictionRegion => predictionRegionForCityName(_selectedCity);

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
    final predictions = locationPredictions[_predictionRegion] ?? [];

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                borderRadius: 26,
                fillAlpha: 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: AppColors.primary, size: 34),
                        const SizedBox(width: 12),
                        Text(
                          'Predictions',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Discover which species are most likely to appear in your area',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassPanel(
                padding: const EdgeInsets.all(16),
                borderRadius: 22,
                fillAlpha: 0.38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text('Select Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openCityPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            suffixIcon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Tap to search all cities',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Top Predictions for $_selectedCity',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final pred = predictions[index - 1];
                final species = speciesById(pred.speciesId);
                if (species == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SpeciesPredictionScreen(speciesId: species.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 96,
                                height: 96,
                                child: SpeciesNetworkImage(url: species.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    species.commonName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    species.scientificName,
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _probabilityColors(pred.probability),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.trending_up, size: 16, color: _probabilityOnColor(pred.probability)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${pred.probabilityPercent}% ${pred.probability}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _probabilityOnColor(pred.probability),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('⏰ ', style: TextStyle(fontSize: 14)),
                                      Expanded(child: Text(pred.bestTime, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                                      Text(_weatherEmoji(pred.bestWeather)),
                                      const SizedBox(width: 4),
                                      Text(pred.bestWeather, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
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
              },
              childCount: predictions.length + 1,
            ),
          ),
        ),
      ],
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
    final q = _search.text;
    setState(() {
      _visible = _sorted.where((c) => cityMatchesQuery(c, q)).toList();
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
                    child: Text('Select city', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        selectedTileColor: AppColors.primary.withValues(alpha: 0.12),
                        title: Text(c.name),
                        subtitle: Text(c.state),
                        trailing: sel ? const Icon(Icons.check, color: AppColors.primary) : null,
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
