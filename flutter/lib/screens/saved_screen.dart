import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x1A2F855A), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.favorite, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved Species', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accent)),
                    Text('${list.length} species', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('No favorite species yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text(
                      'Start exploring and save species you are interested in photographing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onExplore ?? () {},
                      child: const Text('Explore Species'),
                    ),
                  ],
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
    );
  }

  Widget _savedCard(BuildContext context, Species s, SavedSpeciesProvider saved) {
    return Card(
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
              onPressed: () => saved.toggleSaved(s.id),
              icon: const Icon(Icons.favorite),
              label: const Text('Remove from Saved'),
            ),
          ),
        ],
      ),
    );
  }
}
