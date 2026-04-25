import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/assistant_overlay_layer.dart';
import '../widgets/glass.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final scale = Adaptive.scale(context);
    final saved = context.watch<SavedSpeciesProvider>();
    final list = speciesData.where((sp) => saved.isSaved(sp.id)).toList();

    return AssistantOverlayLayer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MistBackdrop(backgroundBlurSigma: 9),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16 * scale,
                      28 * scale,
                      16 * scale,
                      12 * scale,
                    ),
                    child: GlassPanel(
                      padding: EdgeInsets.fromLTRB(
                        18 * scale,
                        18 * scale,
                        18 * scale,
                        18 * scale,
                      ),
                      borderRadius: 26 * scale,
                      fillAlpha: 0.42,
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.38),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20 * scale,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Container(
                            padding: EdgeInsets.all(12 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.primary,
                              size: 28 * scale,
                            ),
                          ),
                          SizedBox(width: 14 * scale),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved Species',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: AppColors.accent),
                              ),
                              Text(
                                '${list.length} species',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
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
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          0,
                          20 * scale,
                          24 * scale,
                        ),
                        child: GlassPanel(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24 * scale,
                            vertical: 32 * scale,
                          ),
                          borderRadius: 24 * scale,
                          fillAlpha: 0.5,
                          blurSigma: 22,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_outline_rounded,
                                size: 56 * scale,
                                color: AppColors.primary.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              SizedBox(height: 20 * scale),
                              Text(
                                'No favorite species yet',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(height: 12 * scale),
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
                              SizedBox(height: 28 * scale),
                              FilledButton(
                                onPressed: onExplore ?? () {},
                                style: FilledButton.styleFrom(
                                  minimumSize: Size.fromHeight(48 * scale),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 28 * scale,
                                  ),
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
                    padding: EdgeInsets.fromLTRB(
                      16 * scale,
                      8 * scale,
                      16 * scale,
                      100 * scale,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final species = list[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12 * scale),
                          child: _savedCard(context, species, saved),
                        );
                      }, childCount: list.length),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedCard(
    BuildContext context,
    Species s,
    SavedSpeciesProvider saved,
  ) {
    final scale = Adaptive.scale(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SpeciesDetailScreen(speciesId: s.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: Adaptive.clamp(context, 180, min: 140, max: 240),
                  child: SpeciesNetworkImage(
                    url: s.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.commonName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        s.scientificName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(s.category),
                            visualDensity: VisualDensity.compact,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * scale,
                              vertical: 6 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackgroundColor(
                                s.conservationStatus,
                              ),
                              borderRadius: BorderRadius.circular(20 * scale),
                            ),
                            child: Text(
                              s.conservationStatus,
                              style: TextStyle(
                                color: statusForegroundColor(
                                  s.conservationStatus,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scale),
                      Row(
                        children: [
                          Text(
                            'Difficulty:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          DifficultyStars(
                            level: s.difficultyLevel,
                            size: Adaptive.clamp(context, 16, min: 13, max: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 16 * scale),
            child: FilledButton.icon(
              onPressed: () async {
                try {
                  await saved.toggleSaved(s.id);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to update saved species. Please try again.',
                        ),
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
