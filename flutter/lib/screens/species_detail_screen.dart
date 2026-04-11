import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/map_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/app_shell_controller.dart';
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
                        Text(
                            species.commonName.trim().isNotEmpty ? species.commonName : 'Unknown Species',
                            style: Theme.of(context).textTheme.headlineSmall
                        ),
                        Text(
                          species.scientificName.trim().isNotEmpty ? species.scientificName : 'Scientific name unavailable',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(species.category.trim().isNotEmpty ? species.category : 'Category N/A')),
                            Chip(label: Text(species.activityPattern.trim().isNotEmpty ? species.activityPattern : 'Activity N/A')),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: species.conservationStatus.trim().isNotEmpty
                                    ? statusBackgroundColor(species.conservationStatus)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                species.conservationStatus.trim().isNotEmpty ? species.conservationStatus : 'Status Unavailable',
                                style: TextStyle(
                                  color: species.conservationStatus.trim().isNotEmpty
                                      ? statusForegroundColor(species.conservationStatus)
                                      : Colors.black54,
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
                  onPressed: () async {
                    try {
                      await saved.toggleSaved(species.id);
                    } catch (e) {
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
                _habitatLocationsSection(context, species),
                _sectionCard(
                  context,
                  title: 'Behavior & Habits',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(species.behaviorNotes),
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

                                // Check if the list has items, otherwise show the fallback text
                                species.bestSeasons.isNotEmpty
                                    ? Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: species.bestSeasons.map((e) {
                                    return Chip(
                                      label: Text(e),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                      side: BorderSide.none,
                                      labelStyle: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    );
                                  }).toList(),
                                )
                                    : Text(
                                  'Best seasons currently unknown',
                                  style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _habitatLocationsSection(BuildContext context, Species species) {
    final locs = speciesLocationsForSpecies(species.id);
    final spots = photographySpotsForSpeciesId(species.id);
    if (locs.isEmpty && spots.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    var n = 0;
    for (final loc in locs) {
      n++;
      rows.add(
        _locationMapRow(
          context,
          index: n,
          title: 'Recorded observation',
          subtitle:
          'Last seen ${loc.lastSeen} · ${loc.lat.toStringAsFixed(4)}°, ${loc.lng.toStringAsFixed(4)}°',
          point: LatLng(loc.lat, loc.lng),
        ),
      );
    }
    for (final spot in spots) {
      n++;
      rows.add(
        _locationMapRow(
          context,
          index: n,
          title: spot.name,
          subtitle: '${spot.habitatType} · ${spot.accessibility}',
          point: LatLng(spot.lat, spot.lng),
        ),
      );
    }

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
                  Icon(Icons.map_outlined, size: 22, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Habitat & Locations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a row to open the map centered on that pin.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationMapRow(
      BuildContext context, {
        required int index,
        required String title,
        required String subtitle,
        required LatLng point,
      }) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<AppShellController>().openMapAt(point, zoom: 15);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text('$index', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.35)),
                  ],
                ),
              ),
              Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
  Widget _sectionCard(
      BuildContext context, {
        required String title,
        IconData? icon,
        required Widget child,
      }) {
    Widget content = child;

    // Intercept empty text descriptions
    if (child is Text && (child.data == null || child.data!.trim().isEmpty)) {
      content = Text(
        'Information currently unavailable',
        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      );
    }
    // Intercept empty lists (like recommended gear)
    else if (child is Column && child.children.isEmpty) {
      content = Text(
        'No recommendations currently available',
        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      );
    }

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
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}