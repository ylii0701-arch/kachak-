import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/l10n_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/photography_assistant_data.dart';
import '../data/map_data.dart';
import '../data/predictions_data.dart';
import '../data/site_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/app_shell_controller.dart';
import '../providers/saved_species_provider.dart';
import '../services/onboarding_service.dart';
import '../services/prediction_manager.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/assistant_overlay_layer.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/glass.dart';
import '../widgets/onboarding/spotlight_tour.dart';
import '../widgets/onboarding/tour_anchor.dart';
import '../widgets/species_network_image.dart';
import 'species_prediction_screen.dart';

class SpeciesDetailScreen extends StatefulWidget {
  // 🟢 Updated to receive filters from HomeScreen
  const SpeciesDetailScreen({
    super.key,
    required this.speciesId,
    this.selectedCity,
    this.selectedSiteId,
  });

  final String speciesId;
  final String? selectedCity;
  final String? selectedSiteId;

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _didCheckTour = false;
  bool _showAllLocationRows = false;
  int _scrollCommandToken = 0;

  @override
  void initState() {
    super.initState();
    TourRuntimeCommand.command.addListener(_onTourCommandChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowSpeciesDetailTour());
    _ensurePredictionsForMobileWeb();
  }

  void _ensurePredictionsForMobileWeb() {
    final isMobileWeb = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (!isMobileWeb) return;
    PredictionManager.instance.fetchForSpecies(widget.speciesId);
  }

  @override
  void dispose() {
    TourRuntimeCommand.command.removeListener(_onTourCommandChanged);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToTarget(
      String targetId, {
        required int token,
        double alignment = 0.16,
      }) async {
    const attempts = <Duration>[
      Duration.zero,
      Duration(milliseconds: 24),
      Duration(milliseconds: 80),
      Duration(milliseconds: 160),
      Duration(milliseconds: 240),
    ];
    for (final delay in attempts) {
      if (!mounted) return;
      if (token != _scrollCommandToken) return;
      if (delay != Duration.zero) {
        await Future<void>.delayed(delay);
      }
      if (token != _scrollCommandToken) return;
      final targetContext = TourAnchors.key(targetId).currentContext;
      if (targetContext == null) continue;
      if (!targetContext.mounted) continue;
      await Scrollable.ensureVisible(
        targetContext,
        duration: Duration.zero,
        curve: Curves.linear,
        alignment: alignment,
      );
      await Future<void>.delayed(const Duration(milliseconds: 16));
      return;
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _onTourCommandChanged() {
    final cmd = TourRuntimeCommand.command.value;
    if (!mounted || cmd == null) return;
    final token = ++_scrollCommandToken;
    if (cmd == 'speciesDetail.focusAlert') {
      _scrollToTarget(
        TourTargetIds.detailNotification,
        token: token,
        alignment: 0.08,
      );
    } else if (cmd == 'speciesDetail.scrollPrediction') {
      _scrollToTarget(
        TourTargetIds.detailPredictionCard,
        token: token,
        alignment: 0.12,
      );
    } else if (cmd == 'speciesDetail.scrollHabitat') {
      _scrollToTarget(
        TourTargetIds.detailHabitatLocations,
        token: token,
        alignment: 0.12,
      );
    } else if (cmd == 'speciesDetail.scrollMapButton') {
      _scrollToTarget(
        TourTargetIds.detailFirstObservation,
        token: token,
        alignment: 0.18,
      );
    }
  }

  Future<void> _maybeShowSpeciesDetailTour() async {
    if (!mounted || _didCheckTour) return;
    _didCheckTour = true;
    final species = speciesById(widget.speciesId);
    if (species == null) return;

    final onboarding = context.read<OnboardingService>();
    if (onboarding.hasSeen(OnboardingTour.speciesDetail)) return;
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;

    final dl = AppLocalizations.of(context);
    final steps = <SpotlightStep>[
      SpotlightStep(
        targetId: TourTargetIds.detailNotification,
        title: dl?.spotlightDetailAlertTitle ?? 'Enable alerts',
        body: dl?.spotlightDetailAlertBody ??
            'After saving, tap this icon to enable species notifications for higher-probability sightings.',
        onEnterCommand: 'speciesDetail.focusAlert',
      ),
      SpotlightStep(
        targetId: TourTargetIds.detailPredictionCard,
        title: dl?.spotlightDetailPredictionTitle ?? 'Current prediction',
        body: dl?.spotlightDetailPredictionBody ??
            'This card shows the best site and current weather-based probability for spotting this species.',
        onEnterCommand: 'speciesDetail.scrollPrediction',
      ),
      SpotlightStep(
        targetId: TourTargetIds.detailHabitatLocations,
        title: dl?.spotlightDetailObservationTitle ?? 'Recorded observation',
        body: dl?.spotlightDetailObservationBody ??
            'This first recorded observation row includes the latest sighting and coordinates.',
        onEnterCommand: 'speciesDetail.scrollHabitat',
      ),
      SpotlightStep(
        targetId: TourTargetIds.detailFirstObservation,
        title: dl?.spotlightDetailMapTitle ?? 'Open on map',
        body: dl?.spotlightDetailMapBody ??
            'Tap this map button to view the animal last occurrence directly on the map.',
        onEnterCommand: 'speciesDetail.scrollMapButton',
      ),
    ];

    await SpotlightTour.show(
      context,
      steps: steps,
      onComplete: () async {
        await _scrollToTop();
      },
    );

    if (!mounted) return;
    await onboarding.markSeen(OnboardingTour.speciesDetail);
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final species = speciesById(widget.speciesId);

    if (species == null) {
      return AssistantOverlayLayer(
        child: Scaffold(
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
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
        ),
      );
    }

    final saved = context.watch<SavedSpeciesProvider>();
    final isFav = saved.isSaved(species.id);
    final isNotified = saved.isNotified(species.id);

    return AssistantOverlayLayer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListenableBuilder(
            listenable: PredictionManager.instance,
            builder: (context, _) {
              final l = AppLocalizations.of(context);

              // 🟢 Using variables passed from HomeScreen directly
              final String cleanCity = (widget.selectedCity ?? 'All').trim().toLowerCase();
              final String cleanSite = (widget.selectedSiteId ?? 'All').trim().toLowerCase();

              String? bestSiteId;
              double maxProb = -1.0;

              final bool isAllCities = cleanCity.isEmpty || cleanCity.startsWith('all');
              final bool isAllSites = cleanSite.isEmpty || cleanSite.startsWith('all');

              if (!isAllSites) {
                try {
                  final targetSite = siteData.firstWhere(
                        (s) => s.id.toLowerCase() == cleanSite || s.name.trim().toLowerCase() == cleanSite,
                  );
                  if (isAllCities || targetSite.cityName.trim().toLowerCase() == cleanCity) {
                    bestSiteId = targetSite.id;
                    maxProb = PredictionManager.instance.latestPredictions[bestSiteId]?[species.id] ?? -1.0;
                  }
                } catch (e) {
                  // Fall through to all sites
                }
              }

              if (bestSiteId == null) {
                PredictionManager.instance.latestPredictions.forEach((sId, spMap) {
                  final site = siteData.where((s) => s.id == sId).firstOrNull;
                  if (site == null) return;

                  final bool matchesCity = isAllCities || site.cityName.trim().toLowerCase() == cleanCity;

                  if (matchesCity) {
                    final p = spMap[species.id];
                    if (p != null && p > maxProb) {
                      maxProb = p;
                      bestSiteId = sId;
                    }
                  }
                });
              }

              List<TimeSeriesPrediction> bestForecasts = [];
              dynamic bestSite;

              if (bestSiteId != null && maxProb != -1.0) {
                bestForecasts = PredictionManager.instance.getSevenDayForecastForUI(bestSiteId!, species.id);
                bestSite = siteData.where((site) => site.id == bestSiteId).firstOrNull;
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  const MistBackdrop(backgroundBlurSigma: 5),
                  CustomScrollView(
                    controller: _scrollController,
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
                            child: TourAnchor(
                              id: TourTargetIds.detailNotification,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  if (!isFav) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please save this species to your favorites first to enable notifications',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final success = await saved.toggleNotification(
                                    species.id,
                                  );

                                  if (context.mounted) {
                                    if (!success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Alert could not be enabled. Please allow notifications in settings.',
                                          ),
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
                                            localizedCategory(l, species.category),
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
                                            color: Colors.white.withValues(
                                              alpha: 0.84,
                                            ),
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
                                            color: Colors.white.withValues(
                                              alpha: 0.84,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              20 * s,
                                            ),
                                          ),
                                          child: Text(
                                            localizedStatus(l, species.conservationStatus),
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
                                          l?.shootingDifficulty ?? 'Shooting difficulty',
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
                                        DifficultyStars(
                                          level: species.difficultyLevel,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12 * s),
                            TourAnchor(
                              id: TourTargetIds.detailSaveFavorite,
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
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
                                  icon: Icon(
                                    isFav
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: AppColors.accent,
                                  ),
                                  label: Text(
                                    isFav
                                        ? (l?.speciesDetailSavedToFav ?? 'Saved to Favorites')
                                        : (l?.speciesDetailSaveToFav ?? 'Save to Favorites'),
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accent,
                                    backgroundColor: AppColors.surface.withValues(alpha: 0.92),
                                    side: BorderSide(
                                      color: AppColors.primary.withValues(alpha: 0.22),
                                    ),
                                    minimumSize: Size.fromHeight(56 * s),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28 * s),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12 * s),
                            _sectionCard(
                              context,
                              title: l?.speciesDetailAbout ?? 'About',
                              icon: Icons.info_outline,
                              child: Text(species.description),
                            ),

                            TourAnchor(
                              id: TourTargetIds.detailPredictionCard,
                              child: (bestSite != null && bestForecasts.isNotEmpty)
                                  ? _predictionSnapshotCard(
                                      context,
                                      species: species,
                                      site: bestSite,
                                      forecasts: bestForecasts,
                                    )
                                  : _predictionPendingCard(context),
                            ),

                            _sectionCard(
                              context,
                              title: l?.speciesDetailHabitat ?? 'Habitat',
                              icon: Icons.place_outlined,
                              child: Text(species.habitat),
                            ),

                            // 🟢 RESTORED FULL HABITAT LOCATIONS
                            _habitatLocationsSection(context, species),

                            // 🟢 RESTORED FULL BEHAVIOR & HABITS
                            _sectionCard(
                              context,
                              title: l?.speciesDetailBehavior ?? 'Behavior & Habits',
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
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l?.speciesDetailBestSeasons ?? 'Best Seasons:',
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
                                                    color:
                                                    AppColors.primary,
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
                                              style:
                                              GoogleFonts.plusJakartaSans(
                                                color: AppColors
                                                    .textSubtitleOnFrost,
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

                            // 🟢 RESTORED FULL DIET
                            _sectionCard(
                              context,
                              title: l?.speciesDetailDiet ?? 'Diet',
                              icon: Icons.restaurant_menu_outlined,
                              child: Text(
                                speciesDietData[species.id] ??
                                    'Diet information is currently unavailable for this species.',
                              ),
                            ),

                            // 🟢 RESTORED FULL PHOTOGRAPHY TIPS
                            _sectionCard(
                              context,
                              title: l?.speciesDetailPhotography ?? 'Photography Tips',
                              icon: Icons.camera_alt_outlined,
                              child: Text(species.photographyConditions),
                            ),

                            // 🟢 RESTORED FULL RECOMMENDED GEAR
                            _sectionCard(
                              context,
                              title: l?.speciesDetailGear ?? 'Recommended Gear',
                              icon: Icons.inventory_2_outlined,
                              child: Column(
                                children: species.recommendedGear.asMap().entries.map(
                                      (e) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.2),
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
                                  },
                                ).toList(),
                              ),
                            ),
                            SizedBox(height: 32 * s),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  // 🟢 RESTORED HABITAT LOCATIONS FUNCTION
  Widget _habitatLocationsSection(BuildContext context, Species species) {
    final l = AppLocalizations.of(context);
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
          title: l?.detailRecordedObservation ?? 'Recorded observation',
          subtitle:
          '${l?.detailLastSeen ?? 'Last seen'} ${loc.lastSeen} · ${loc.lat.toStringAsFixed(4)}°, ${loc.lng.toStringAsFixed(4)}°',
          point: LatLng(loc.lat, loc.lng),
          speciesId: species.id,
          tourAnchorId: n == 1 ? TourTargetIds.detailFirstObservation : null,
          mapIconTourAnchorId: n == 1
              ? TourTargetIds.detailFirstObservationMapButton
              : null,
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

    final visibleRows = _showAllLocationRows || rows.length <= 3
        ? rows
        : rows.take(3).toList(growable: false);

    return TourAnchor(
      id: TourTargetIds.detailHabitatLocations,
      child: Padding(
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
                      l?.speciesDetailHabitatLocations ?? 'Habitat & Locations',
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
                  l?.detailTapRowHint ?? 'Tap a row to open the map centered on that pin.',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSubtitleOnFrost,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.02,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < visibleRows.length; i++) ...[
                  visibleRows[i],
                  if (i < visibleRows.length - 1) const SizedBox(height: 8),
                ],
                if (rows.length > 3) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _showAllLocationRows = !_showAllLocationRows);
                      },
                      icon: Icon(
                        _showAllLocationRows
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                      label: Text(_showAllLocationRows ? (l?.detailShowLess ?? 'Show less') : (l?.detailShowMore ?? 'Show more')),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🟢 RESTORED LOCATION ROW WIDGET
  Widget _locationMapRow(
      BuildContext context, {
        required int index,
        required String title,
        required String subtitle,
        required LatLng point,
        required String speciesId,
        String? tourAnchorId,
        String? mapIconTourAnchorId,
      }) {
    final row = Material(
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
              Builder(
                builder: (_) {
                  final icon = Icon(
                    Icons.map_outlined,
                    size: 20,
                    color: AppColors.iconSectionOnFrost,
                  );
                  if (mapIconTourAnchorId != null) {
                    return TourAnchor(id: mapIconTourAnchorId, child: icon);
                  }
                  return icon;
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (tourAnchorId != null) {
      return TourAnchor(id: tourAnchorId, child: row);
    }
    return row;
  }

  Widget _sectionCard(BuildContext context, {required String title, IconData? icon, required Widget child}) {
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
                  if (icon != null) ...[Icon(icon, size: 22, color: AppColors.iconSectionOnFrost), const SizedBox(width: 8)],
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textBodyOnFrost)),
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

  Color _probabilityBg(String probability) {
    if (probability == 'High') return Colors.green.shade100;
    if (probability == 'Medium') return Colors.amber.shade100;
    return Colors.red.shade100;
  }

  Color _probabilityFg(String probability) {
    if (probability == 'High') return Colors.green.shade900;
    if (probability == 'Medium') return Colors.amber.shade900;
    return Colors.red.shade900;
  }

  IconData _weatherIcon(String weather) {
    final w = weather.toLowerCase();
    if (w.contains('sun') || w.contains('clear')) return Icons.wb_sunny_rounded;
    if (w.contains('partly') || w.contains('cloud')) return Icons.wb_cloudy_rounded;
    if (w.contains('rain')) return Icons.umbrella_rounded;
    return Icons.wb_cloudy_rounded;
  }

  Widget _predictionPendingCard(BuildContext context) {
    final s = Adaptive.scale(context);
    final l = AppLocalizations.of(context);
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
                    Icons.trending_up_rounded,
                    size: 22 * s,
                    color: AppColors.iconSectionOnFrost,
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Text(
                      l?.speciesDetailPrediction ?? 'Current Prediction',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: Adaptive.clamp(context, 17, min: 14, max: 21),
                        color: AppColors.textBodyOnFrost,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * s),
              Text(
                'Loading weather-based prediction data...',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSubtitleOnFrost,
                  fontSize: Adaptive.clamp(context, 13, min: 11, max: 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12 * s),
              const LinearProgressIndicator(minHeight: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _predictionSnapshotCard(
      BuildContext context, {
        required Species species,
        required dynamic site,
        required List<TimeSeriesPrediction> forecasts,
      }) {
    final s = Adaptive.scale(context);
    final l = AppLocalizations.of(context);
    final currentForecast = forecasts.isNotEmpty ? forecasts.first : null;
    if (currentForecast == null) return const SizedBox.shrink();

    String probLabel = 'Low';
    if (currentForecast.probability >= 0.7) {
      probLabel = 'High';
    } else if (currentForecast.probability >= 0.4) {
      probLabel = 'Medium';
    }
    final String localizedProbLabel;
    if (probLabel == 'High') {
      localizedProbLabel = l?.identifyHigh ?? 'High';
    } else if (probLabel == 'Medium') {
      localizedProbLabel = l?.identifyMedium ?? 'Medium';
    } else {
      localizedProbLabel = l?.identifyLow ?? 'Low';
    }
    final probPercent = (currentForecast.probability * 100).round();

    final fixedBestTime = speciesPredictions[species.id]?.forecast.first.timeOfDay ?? 'Night';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up_rounded, size: 22 * s, color: AppColors.iconSectionOnFrost),
                            SizedBox(width: 8 * s),
                            Expanded(child: Text(l?.speciesDetailPrediction ?? 'Current Prediction', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: Adaptive.clamp(context, 17, min: 14, max: 21), color: AppColors.textBodyOnFrost, letterSpacing: -0.1))),
                          ],
                        ),
                        SizedBox(height: 6 * s),
                        Text(l?.predictionBestSite(site.name) ?? 'Best Site: ${site.name}', style: GoogleFonts.plusJakartaSans(color: AppColors.textSubtitleOnFrost, fontSize: Adaptive.clamp(context, 13, min: 11, max: 15), fontWeight: FontWeight.w600, letterSpacing: 0.05)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
                    decoration: BoxDecoration(color: _probabilityBg(probLabel), borderRadius: BorderRadius.circular(20 * s), border: Border.all(color: Colors.grey.shade400)),
                    child: Text('$probPercent% $localizedProbLabel', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: Adaptive.clamp(context, 12, min: 10, max: 14), color: _probabilityFg(probLabel), letterSpacing: 0.05)),
                  ),
                ],
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  Expanded(child: _predictionMiniFact(context, icon: Icons.schedule_rounded, iconColor: AppColors.primary, label: l?.speciesDetailBestTime ?? 'Best Time', value: fixedBestTime)),
                  SizedBox(width: 8 * s),
                  Expanded(child: _predictionMiniFact(context, icon: _weatherIcon(currentForecast.weatherDescription), iconColor: Colors.orange.shade700, label: l?.speciesDetailWeather ?? 'Weather', value: currentForecast.weatherDescription == 'Unknown' ? (l?.predictionUnknown ?? 'Unknown') : currentForecast.weatherDescription)),
                ],
              ),
              SizedBox(height: 8 * s),
              Row(
                children: [
                  Expanded(child: _predictionMiniFact(context, icon: Icons.thermostat_rounded, iconColor: Colors.deepOrange.shade700, label: l?.speciesDetailTemp ?? 'Temp', value: '${currentForecast.temperature.round()}°C')),
                  SizedBox(width: 8 * s),
                  Expanded(child: _predictionMiniFact(context, icon: Icons.water_drop_rounded, iconColor: Colors.cyan.shade700, label: l?.speciesDetailHumidity ?? 'Humidity', value: '${currentForecast.humidity.round()}%')),
                ],
              ),
              SizedBox(height: 12 * s),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SpeciesPredictionScreen(speciesId: species.id, siteId: site.id, siteName: site.name),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.88), foregroundColor: Colors.white, minimumSize: Size.fromHeight(46 * s), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * s)), elevation: 0, shadowColor: Colors.transparent),
                  child: Text(l?.speciesDetailSeeMorePrediction ?? 'See more prediction details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _predictionMiniFact(BuildContext context, {required IconData icon, required Color iconColor, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.82))),
      child: Row(
        children: [
          Container(width: 30, height: 30, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(color: AppColors.textSubtitleOnFrost, fontSize: Adaptive.clamp(context, 11, min: 10, max: 13), fontWeight: FontWeight.w700, height: 1.2)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(color: AppColors.textBodyOnFrost, fontSize: Adaptive.clamp(context, 13, min: 11, max: 15), fontWeight: FontWeight.w800, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _innerInfoCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.8))),
      child: child,
    );
  }
}