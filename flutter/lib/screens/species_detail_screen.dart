import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/species_network_image.dart';

class SpeciesDetailScreen extends StatelessWidget {
  const SpeciesDetailScreen({super.key, required this.speciesId});

  final String speciesId;

  @override
  Widget build(BuildContext context) {
    final species = speciesById(speciesId);
    if (species == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text('Species Not Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final saved = context.watch<SavedSpeciesProvider>();
    final isFav = saved.isSaved(species.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SpeciesNetworkImage(url: species.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(species.commonName, style: Theme.of(context).textTheme.headlineSmall),
                        Text(
                          species.scientificName,
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(species.category)),
                            Chip(label: Text(species.activityPattern)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: statusBackgroundColor(species.conservationStatus),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                species.conservationStatus,
                                style: TextStyle(
                                  color: statusForegroundColor(species.conservationStatus),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Shooting Difficulty Level:', style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(width: 8),
                            DifficultyStars(level: species.difficultyLevel),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => saved.toggleSaved(species.id),
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  label: Text(isFav ? 'Saved to Favorites' : 'Save to Favorites'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: isFav ? AppColors.primary : Colors.white,
                    foregroundColor: isFav ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _sectionCard(context, title: 'About', icon: Icons.info_outline, child: Text(species.description)),
                _sectionCard(context, title: 'Habitat', icon: Icons.place_outlined, child: Text(species.habitat)),
                _sectionCard(
                  context,
                  title: 'Behavior & Habits',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(species.behaviorNotes),
                      if (species.bestSeasons.isNotEmpty) ...[
                        const Divider(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Best Seasons:', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: species.bestSeasons
                                        .map((e) => Chip(label: Text(e), visualDensity: VisualDensity.compact))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _sectionCard(
                  context,
                  title: 'Photography Tips',
                  icon: Icons.camera_alt_outlined,
                  child: Text(species.photographyConditions),
                ),
                _sectionCard(
                  context,
                  title: 'Recommended Gear',
                  icon: Icons.inventory_2_outlined,
                  child: Column(
                    children: species.recommendedGear.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(e.value)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: AppColors.primary),
                    const SizedBox(width: 8),
                  ],
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              DefaultTextStyle.merge(
                style: const TextStyle(height: 1.45),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
