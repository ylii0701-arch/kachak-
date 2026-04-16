import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/map_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/app_shell_controller.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/glass.dart';
import '../widgets/species_network_image.dart';

class SpeciesDetailScreen extends StatelessWidget {
  const SpeciesDetailScreen({super.key, required this.speciesId});

  final String speciesId;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final species = speciesById(speciesId);
    if (species == null) {
      return Scaffold(
        backgroundColor: AppColors.detailBackdrop,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Species Not Found',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
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
    final isNotified = saved.isNotified(species.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MistBackdrop(backgroundBlurSigma: 5),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: Adaptive.clamp(
                  context,
                  280,
                  min: 220,
                  max: 360,
                ),
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.88),
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20 * s,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 8 * s),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (!isFav) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please save this species to your favorites first to enable notifications'),
                            ),
                          );
                          return;
                        }

                        final success = await saved.toggleNotification(species.id);

                        if (context.mounted) {
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alert could not be enabled. Please allow notifications in settings.'),
                              ),
                            );
                          } else {
                            final nowOn = saved.isNotified(species.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  nowOn
                                      ? 'High probability alerts enabled for ${species.commonName}'
                                      : 'Notifications disabled for ${species.commonName}',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: Container(
                        padding: EdgeInsets.all(8 * s),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNotified
                              ? Icons.notifications_active
                              : Icons.notifications_off_outlined,
                          color: isNotified
                              ? Colors.amber.shade400
                              : Colors.white,
                          size: 20 * s,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      SpeciesNetworkImage(
                        url: species.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.45, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16 * s),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GlassPanel(
                      padding: EdgeInsets.all(20 * s),
                      borderRadius: 20 * s,
                      blurSigma: 14,
                      fillAlpha: 0.62,
                      verticalFrostGradient: true,
                      child: _innerInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              species.commonName,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textBodyOnFrost,
                                fontWeight: FontWeight.w800,
                                fontSize: Adaptive.clamp(
                                  context,
                                  26,
                                  min: 20,
                                  max: 32,
                                ),
                                height: 1.15,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 6 * s),
                            Text(
                              species.scientificName,
                              style: GoogleFonts.plusJakartaSans(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSubtitleOnFrost,
                                fontSize: Adaptive.clamp(
                                  context,
                                  16,
                                  min: 13,
                                  max: 20,
                                ),
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(height: 12 * s),
                            Wrap(
                              spacing: 8 * s,
                              runSpacing: 8 * s,
                              children: [
                                Chip(
                                  label: Text(
                                    species.category,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textBodyOnFrost,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Adaptive.clamp(
                                        context,
                                        13,
                                        min: 11,
                                        max: 16,
                                      ),
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4 * s,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    species.activityPattern,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textBodyOnFrost,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Adaptive.clamp(
                                        context,
                                        13,
                                        min: 11,
                                        max: 16,
                                      ),
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4 * s,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * s,
                                    vertical: 8 * s,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackgroundColor(
                                      species.conservationStatus,
                                    ),
                                    borderRadius: BorderRadius.circular(20 * s),
                                  ),
                                  child: Text(
                                    species.conservationStatus,
                                    style: TextStyle(
                                      color: statusForegroundColor(
                                        species.conservationStatus,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * s),
                            Row(
                              children: [
                                Text(
                                  'Shooting difficulty',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSubtitleOnFrost,
                                    fontWeight: FontWeight.w700,
                                    fontSize: Adaptive.clamp(
                                      context,
                                      14,
                                      min: 12,
                                      max: 17,
                                    ),
                                    letterSpacing: 0.08,
                                  ),
                                ),
                                SizedBox(width: 8 * s),
                                DifficultyStars(level: species.difficultyLevel),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    GlassPanel(
                      padding: EdgeInsets.all(8 * s),
                      borderRadius: 20 * s,
                      blurSigma: 14,
                      fillAlpha: 0.62,
                      verticalFrostGradient: true,
                      child: GlassCtaPill(
                        emphasized: isFav,
                        onPressed: () async {
                          try {
                            await saved.toggleSaved(species.id);
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                            ),
                            SizedBox(width: 10 * s),
                            Text(
                              isFav
                                  ? 'Saved to Favorites'
                                  : 'Save to Favorites',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * s),
                    _sectionCard(
                      context,
                      title: 'About',
                      icon: Icons.info_outline,
                      child: Text(species.description),
                    ),
                    _sectionCard(
                      context,
                      title: 'Habitat',
                      icon: Icons.place_outlined,
                      child: Text(species.habitat),
                    ),
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
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Best Seasons:',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textSubtitleOnFrost,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    species.bestSeasons.isNotEmpty
                                        ? Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: species.bestSeasons.map((
                                          e,
                                          ) {
                                        return Chip(
                                          label: Text(e),
                                          visualDensity:
                                          VisualDensity.compact,
                                          backgroundColor: AppColors
                                              .primary
                                              .withValues(alpha: 0.12),
                                          side: BorderSide.none,
                                          labelStyle:
                                          GoogleFonts.plusJakartaSans(
                                            color: AppColors.primary,
                                            fontWeight:
                                            FontWeight.w700,
                                            fontSize: 13,
                                            letterSpacing: 0.05,
                                          ),
                                        );
                                      }).toList(),
                                    )
                                        : Text(
                                      'Best seasons currently unknown',
                                      style: GoogleFonts.plusJakartaSans(
                                        color:
                                        AppColors.textSubtitleOnFrost,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
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
                        children: species.recommendedGear.asMap().entries.map((
                            e,
                            ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textBodyOnFrost,
                                      fontSize: 16,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 32 * s),
                  ]),
                ),
              ),
            ],
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
          speciesId: species.id,
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
          speciesId: species.id,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        blurSigma: 14,
        fillAlpha: 0.62,
        verticalFrostGradient: true,
        child: _innerInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 22,
                    color: AppColors.iconSectionOnFrost,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Habitat & Locations',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.textBodyOnFrost,
                      letterSpacing: -0.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a row to open the map centered on that pin.',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSubtitleOnFrost,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.02,
                ),
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
        required String speciesId,
      }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.84),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<AppShellController>().openMapAt(
            point,
            zoom: 15,
            speciesId: speciesId,
          );
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
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        fontSize: 14,
                        color: AppColors.textBodyOnFrost,
                        letterSpacing: 0.02,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSubtitleOnFrost,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.map_outlined,
                size: 20,
                color: AppColors.iconSectionOnFrost,
              ),
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
    if (child is Text && (child.data == null || child.data!.trim().isEmpty)) {
      content = Text(
        'Information currently unavailable',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textSubtitleOnFrost,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      );
    } else if (child is Column && child.children.isEmpty) {
      content = Text(
        'No recommendations currently available',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textSubtitleOnFrost,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        blurSigma: 14,
        fillAlpha: 0.62,
        verticalFrostGradient: true,
        child: _innerInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: AppColors.iconSectionOnFrost),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.textBodyOnFrost,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DefaultTextStyle.merge(
                style: GoogleFonts.plusJakartaSans(
                  height: 1.55,
                  fontSize: 16,
                  color: AppColors.textBodyOnFrost,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.08,
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _innerInfoCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: child,
    );
  }
}