import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
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
  bool _notificationOn = false;

  @override
  void initState() {
    super.initState();
    _loadNotif();
  }

  Future<void> _loadNotif() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _notificationOn =
          prefs.getBool('notification_${widget.speciesId}') ?? false,
    );
  }

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
    final prefs = await SharedPreferences.getInstance();
    final next = !_notificationOn;
    await prefs.setBool('notification_${widget.speciesId}', next);
    if (!context.mounted) return;
    setState(() => _notificationOn = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next
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
    final species = speciesById(widget.speciesId);
    final prediction = speciesPredictions[widget.speciesId];
    final saved = context.watch<SavedSpeciesProvider>();

    if (species == null || prediction == null) {
      return Scaffold(
        backgroundColor: AppColors.detailBackdrop,
        appBar: AppBar(backgroundColor: Colors.white.withValues(alpha: 0.92), surfaceTintColor: Colors.transparent),
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

    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight + 6;

    final bottomPad = MediaQuery.paddingOf(context).bottom + 20;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MistBackdrop(backgroundBlurSigma: 5),
          CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: topInset + 88,
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.88),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => saved.toggleSaved(species.id),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      saved.isSaved(species.id) ? Icons.favorite : Icons.favorite_border,
                      color: saved.isSaved(species.id) ? Colors.red.shade200 : Colors.white,
                      size: 20,
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
                  SpeciesNetworkImage(url: species.imageUrl, fit: BoxFit.cover),
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
                      padding: EdgeInsets.fromLTRB(16, topInset, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 68,
                                  height: 68,
                                  child: SpeciesNetworkImage(
                                    url: species.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      species.commonName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                        shadows: _predictionHeroShadows,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      species.scientificName,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.94),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.25,
                                        shadows: _predictionHeroShadows,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.place_rounded,
                                          color: Colors.white.withValues(alpha: 0.92),
                                          size: 17,
                                          shadows: _predictionHeroShadows,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            '${prediction.locationName} • ${prediction.distance}km away',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.92),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              height: 1.35,
                                              shadows: _predictionHeroShadows,
                                            ),
                                            maxLines: 2,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassPanel(
                    padding: EdgeInsets.zero,
                    borderRadius: 18,
                    blurSigma: 14,
                    fillAlpha: 0.58,
                    verticalFrostGradient: true,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🌿 Key Factors',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: AppColors.textBodyOnFrost,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: primary
                                                          ? AppColors.primary
                                                          : Colors.white.withValues(alpha: 0.38),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: primary
                                                          ? Border.all(
                                                              color: AppColors
                                                                  .primary,
                                                              width: 2,
                                                            )
                                                          : Border.all(
                                                              color: Colors.white.withValues(alpha: 0.55),
                                                              width: 1,
                                                            ),
                                                    ),
                                                    child: Icon(
                                                      factor == 'Time'
                                                          ? Icons.schedule
                                                          : factor == 'Weather'
                                                          ? Icons.cloud_outlined
                                                          : factor == 'Humidity'
                                                          ? Icons
                                                                .water_drop_outlined
                                                          : Icons.thermostat,
                                                      size: 18,
                                                      color: primary ? Colors.white : AppColors.textSubtitleOnFrost,
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
                          Container(width: 1, color: Colors.white.withValues(alpha: 0.45)),
                          SizedBox(
                            width: 100,
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
                                    _notificationOn
                                        ? Icons.notifications_active
                                        : Icons.notifications_off_outlined,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _notificationOn
                                        ? AppColors.primary
                                        : Colors.white.withValues(alpha: 0.4),
                                    foregroundColor: _notificationOn
                                        ? Colors.white
                                        : AppColors.textBodyOnFrost,
                                  ),
                                ),
                                Text(
                                  _notificationOn ? 'Alert On' : 'Alert Off',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.iconSectionOnFrost, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '7-Day Occurrence Forecast',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: AppColors.textBodyOnFrost,
                          height: 1.2,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...prediction.forecast.asMap().entries.map((e) {
                    final day = e.value;
                    final first = e.key == 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        borderRadius: 16,
                        blurSigma: 14,
                        fillAlpha: 0.56,
                        verticalFrostGradient: true,
                        outlineColor: first ? AppColors.primary : null,
                        outlineWidth: first ? 2 : 1.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: first
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.42),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(day.date),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.textBodyOnFrost,
                                      letterSpacing: -0.05,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _probBg(day.probability),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Text(
                                      '${day.probability} Chance',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
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
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    minHeight: 48,
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
