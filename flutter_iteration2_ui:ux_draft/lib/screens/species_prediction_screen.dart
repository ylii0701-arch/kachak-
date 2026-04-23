import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

const _predictionHeroShadows = <Shadow>[
  Shadow(blurRadius: 14, offset: Offset(0, 1), color: Color(0x8C000000)),
  Shadow(blurRadius: 4, offset: Offset(0, 2), color: Color(0xB3000000)),
];

class SpeciesPredictionScreen extends StatefulWidget {
  const SpeciesPredictionScreen({super.key, required this.speciesId});

  final String speciesId;

  @override
  State<SpeciesPredictionScreen> createState() =>
      _SpeciesPredictionScreenState();
}

class _SpeciesPredictionScreenState extends State<SpeciesPredictionScreen> {
  Future<void> _toggleNotif(
    BuildContext context,
    SavedSpeciesProvider saved,
    String commonName,
  ) async {
    if (!saved.isSaved(widget.speciesId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please save this species to your favorites first to enable notifications',
          ),
        ),
      );
      return;
    }

    // Call the provider logic
    final success = await saved.toggleNotification(widget.speciesId);

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alert could not be enabled. Please allow notifications in settings.',
          ),
        ),
      );
      return;
    }

    final isNowNotified = saved.isNotified(widget.speciesId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowNotified
              ? 'High probability alerts enabled for $commonName'
              : 'Notifications disabled for $commonName',
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${_weekday(date.weekday)}, ${date.month}/${date.day}';
  }

  String _weekday(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1).clamp(0, 6)];
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

  Color _probBg(String p) {
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

  Color _probFg(String p) {
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

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final species = speciesById(widget.speciesId);
    final prediction = speciesPredictions[widget.speciesId];
    final saved = context.watch<SavedSpeciesProvider>();

    if (species == null || prediction == null) {
      return Scaffold(
        backgroundColor: AppColors.detailBackdrop,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Species prediction not found'),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Predictions'),
              ),
            ],
          ),
        ),
      );
    }

    final topInset =
        MediaQuery.paddingOf(context).top + kToolbarHeight + (6 * s);
    final bottomPad = MediaQuery.paddingOf(context).bottom + (20 * s);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    final heroExpandedHeight =
        topInset +
        Adaptive.clamp(context, 170, min: 150, max: 220) +
        ((textScale - 1.0) * 40);
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
                expandedHeight: heroExpandedHeight,
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
                    padding: EdgeInsets.only(right: 4 * s),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await saved.toggleSaved(species.id);
                      },
                      icon: Container(
                        padding: EdgeInsets.all(8 * s),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          saved.isSaved(species.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: saved.isSaved(species.id)
                              ? Colors.red.shade200
                              : Colors.white,
                          size: 20 * s,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
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
                              stops: const [0.0, 0.4, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.52),
                                Colors.black.withValues(alpha: 0.18),
                                Colors.black.withValues(alpha: 0.62),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * s,
                          topInset,
                          16 * s,
                          18 * s,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        species.commonName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Adaptive.clamp(
                                            context,
                                            22,
                                            min: 17,
                                            max: 28,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          height: 1.15,
                                          shadows: _predictionHeroShadows,
                                        ),
                                      ),
                                      SizedBox(height: 4 * s),
                                      Text(
                                        species.scientificName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.94,
                                          ),
                                          fontStyle: FontStyle.italic,
                                          fontSize: Adaptive.clamp(
                                            context,
                                            14,
                                            min: 11,
                                            max: 18,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          height: 1.25,
                                          shadows: _predictionHeroShadows,
                                        ),
                                      ),
                                      SizedBox(height: 8 * s),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.place_rounded,
                                            color: Colors.white.withValues(
                                              alpha: 0.92,
                                            ),
                                            size: 17 * s,
                                            shadows: _predictionHeroShadows,
                                          ),
                                          SizedBox(width: 5 * s),
                                          Expanded(
                                            child: Text(
                                              '${prediction.locationName} • ${prediction.distance}km away',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.92,
                                                ),
                                                fontSize: Adaptive.clamp(
                                                  context,
                                                  13,
                                                  min: 11,
                                                  max: 16,
                                                ),
                                                fontWeight: FontWeight.w500,
                                                height: 1.35,
                                                shadows: _predictionHeroShadows,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
              SliverToBoxAdapter(
                child: Padding(
                  // Space below hero — avoid overlapping the app bar.
                  padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassPanel(
                        padding: EdgeInsets.zero,
                        borderRadius: 18 * s,
                        blurSigma: 14,
                        fillAlpha: 0.58,
                        verticalFrostGradient: true,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(16 * s),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🌿 Key Factors',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: Adaptive.clamp(
                                            context,
                                            17,
                                            min: 14,
                                            max: 21,
                                          ),
                                          color: AppColors.textBodyOnFrost,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      SizedBox(height: 10 * s),
                                      Row(
                                        children:
                                            [
                                              'Time',
                                              'Weather',
                                              'Humidity',
                                              'Temperature',
                                            ].map((factor) {
                                              final primary =
                                                  factor ==
                                                  prediction.primaryFactor;
                                              return Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2 * s,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.all(
                                                          8 * s,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: primary
                                                              ? AppColors
                                                                    .primary
                                                              : Colors.white
                                                                    .withValues(
                                                                      alpha:
                                                                          0.38,
                                                                    ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10 * s,
                                                              ),
                                                          border: primary
                                                              ? Border.all(
                                                                  color: AppColors
                                                                      .primary,
                                                                  width: 2,
                                                                )
                                                              : Border.all(
                                                                  color: Colors
                                                                      .white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.55,
                                                                      ),
                                                                  width: 1,
                                                                ),
                                                        ),
                                                        child: Icon(
                                                          factor == 'Time'
                                                              ? Icons.schedule
                                                              : factor ==
                                                                    'Weather'
                                                              ? Icons
                                                                    .cloud_outlined
                                                              : factor ==
                                                                    'Humidity'
                                                              ? Icons
                                                                    .water_drop_outlined
                                                              : Icons
                                                                    .thermostat,
                                                          size: 18 * s,
                                                          color: primary
                                                              ? Colors.white
                                                              : AppColors
                                                                    .textSubtitleOnFrost,
                                                        ),
                                                      ),
                                                      if (primary)
                                                        const Text(
                                                          '⭐',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                              SizedBox(
                                width: Adaptive.clamp(
                                  context,
                                  100,
                                  min: 80,
                                  max: 128,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton.filled(
                                      onPressed: () => _toggleNotif(
                                        context,
                                        saved,
                                        species.commonName,
                                      ),
                                      icon: Icon(
                                        isNotified
                                            ? Icons.notifications_active
                                            : Icons.notifications_off_outlined,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: isNotified
                                            ? AppColors.primary
                                            : Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                        foregroundColor: isNotified
                                            ? Colors.white
                                            : AppColors.textBodyOnFrost,
                                      ),
                                    ),
                                    Text(
                                      isNotified ? 'Alert On' : 'Alert Off',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: Adaptive.clamp(
                                          context,
                                          11,
                                          min: 10,
                                          max: 13,
                                        ),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textBodyOnFrost,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * s),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 12 * s, 12 * s),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.iconSectionOnFrost,
                            size: 22 * s,
                          ),
                          SizedBox(width: 8 * s),
                          Text(
                            '7-Day Occurrence Forecast',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: Adaptive.clamp(
                                context,
                                17,
                                min: 14,
                                max: 21,
                              ),
                              color: AppColors.textBodyOnFrost,
                              height: 1.2,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * s),
                      ...prediction.forecast.asMap().entries.map((e) {
                        final day = e.value;
                        final first = e.key == 0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8 * s),
                          child: GlassPanel(
                            padding: EdgeInsets.zero,
                            borderRadius: 16 * s,
                            blurSigma: 14,
                            fillAlpha: 0.56,
                            verticalFrostGradient: true,
                            outlineColor: first ? AppColors.primary : null,
                            outlineWidth: first ? 2 : 1.1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10 * s,
                                    vertical: 8 * s,
                                  ),
                                  decoration: BoxDecoration(
                                    color: first
                                        ? AppColors.primary.withValues(
                                            alpha: 0.12,
                                          )
                                        : Colors.white.withValues(alpha: 0.42),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(14 * s),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(day.date),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: Adaptive.clamp(
                                            context,
                                            15,
                                            min: 12,
                                            max: 19,
                                          ),
                                          color: AppColors.textBodyOnFrost,
                                          letterSpacing: -0.05,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10 * s,
                                          vertical: 4 * s,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _probBg(day.probability),
                                          borderRadius: BorderRadius.circular(
                                            20 * s,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        child: Text(
                                          '${day.probability} Chance',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: Adaptive.clamp(
                                              context,
                                              11,
                                              min: 10,
                                              max: 13,
                                            ),
                                            fontWeight: FontWeight.w800,
                                            color: _probFg(day.probability),
                                            letterSpacing: 0.05,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10 * s),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _forecastCell(
                                              icon: Icons.schedule,
                                              label: 'Best Time',
                                              value: day.timeOfDay,
                                              iconColor: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _forecastCell(
                                              label: 'Weather',
                                              value: day.weather,
                                              emoji: _weatherEmoji(day.weather),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10 * s),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _forecastCell(
                                              icon: Icons.thermostat,
                                              label: 'Temperature',
                                              value: '${day.temperature}°C',
                                              iconColor: Colors.orange.shade700,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _forecastCell(
                                              icon: Icons.water_drop,
                                              label: 'Humidity',
                                              value: '${day.humidity}%',
                                              iconColor: Colors.cyan.shade700,
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
                        );
                      }),
                      GlassCtaPill(
                        emphasized: true,
                        minHeight: 48 * s,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  SpeciesDetailScreen(speciesId: species.id),
                            ),
                          );
                        },
                        child: const Text('View Full Species Details'),
                      ),
                      SizedBox(height: bottomPad),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _forecastCell({
    IconData? icon,
    required String label,
    required String value,
    Color? iconColor,
    String? emoji,
  }) {
    final tint = iconColor ?? AppColors.primary;
    final emojiChar = emoji;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: emojiChar != null
              ? Center(
                  child: Text(emojiChar, style: const TextStyle(fontSize: 18)),
                )
              : Icon(icon, color: tint, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSubtitleOnFrost,
                  height: 1.2,
                  letterSpacing: 0.15,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textBodyOnFrost,
                  height: 1.25,
                  letterSpacing: 0.02,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
