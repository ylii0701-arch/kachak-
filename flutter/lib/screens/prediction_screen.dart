import 'package:flutter/material.dart';

import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../theme/app_theme.dart';
import '../widgets/species_network_image.dart';
import 'species_prediction_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  Region _region = 'Kuala Lumpur';

  static const _regions = ['Kuala Lumpur', 'Sabah & Sarawak', 'Penang', 'Johor'];

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

  @override
  Widget build(BuildContext context) {
    final predictions = locationPredictions[_region] ?? [];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF276749)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Text('Predictions', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover which species are most likely to appear in your area',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _regions.length,
                  itemBuilder: (_, i) {
                    final r = _regions[i];
                    final sel = _region == r;
                    return OutlinedButton(
                      onPressed: () => setState(() => _region = r),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sel ? AppColors.primary : null,
                        foregroundColor: sel ? Colors.white : null,
                        side: BorderSide(color: sel ? AppColors.primary : Colors.grey.shade300, width: 2),
                      ),
                      child: Text(r, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                    );
                  },
                ),
              ],
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
                            'Top Predictions for $_region',
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
    );
  }
}
