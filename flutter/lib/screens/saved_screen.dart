import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedSpeciesProvider>();
    final list = speciesData.where((s) => saved.isSaved(s.id)).toList();

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: GlassPanel(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                borderRadius: 26,
                fillAlpha: 0.42,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.favorite, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved Species', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accent)),
                        Text('${list.length} species', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (list.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  borderRadius: 24,
                  fillAlpha: 0.5,
                  blurSigma: 22,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_outline_rounded, size: 56, color: AppColors.primary.withValues(alpha: 0.85)),
                      const SizedBox(height: 20),
                      Text(
                        'No favorite species yet',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start exploring and save species you want to photograph.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF3D4D45),
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: onExplore ?? () {},
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                        ),
                        child: const Text('Explore species'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = list[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _savedCard(context, s, saved),
                  );
                },
                childCount: list.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _savedCard(BuildContext context, Species s, SavedSpeciesProvider saved) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => SpeciesDetailScreen(speciesId: s.id)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 180,
                  child: SpeciesNetworkImage(url: s.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.commonName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      Text(
                        s.scientificName,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(s.category), visualDensity: VisualDensity.compact),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBackgroundColor(s.conservationStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.conservationStatus,
                              style: TextStyle(
                                color: statusForegroundColor(s.conservationStatus),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Difficulty:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(width: 6),
                          DifficultyStars(level: s.difficultyLevel, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton.icon(
              onPressed: () async {
                try {
                  await saved.toggleSaved(s.id);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update saved species. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Remove from Saved'),
            ),
          ),
        ],
      ),
    );
  }
}
