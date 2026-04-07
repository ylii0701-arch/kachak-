import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/predictions_data.dart';
import '../data/species_data.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

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
        appBar: AppBar(),
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: topInset + 88,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                onPressed: () => saved.toggleSaved(species.id),
                icon: Icon(
                  saved.isSaved(species.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: saved.isSaved(species.id)
                      ? Colors.red.shade300
                      : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF276749)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, topInset, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72,
                        height: 72,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            species.commonName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species.scientificName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${prediction.locationName} • ${prediction.distance}km away',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              // Space below green header — avoid overlapping the app bar.
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
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
                                  const Text(
                                    '🌿 Key Factors',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
                                                          : Colors
                                                                .grey
                                                                .shade200,
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
                                                          : null,
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
                                                      color: primary
                                                          ? Colors.white
                                                          : Colors
                                                                .grey
                                                                .shade700,
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
                          Container(width: 1, color: Colors.grey.shade200),
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
                                        : Colors.grey.shade300,
                                    foregroundColor: _notificationOn
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  _notificationOn ? 'Alert On' : 'Alert Off',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
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
                      const Icon(Icons.trending_up, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        '7-Day Occurrence Forecast',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...prediction.forecast.asMap().entries.map((e) {
                    final day = e.value;
                    final first = e.key == 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: first
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: first ? 2 : 1,
                        ),
                      ),
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
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(day.date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _probFg(day.probability),
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
                    );
                  }),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              SpeciesDetailScreen(speciesId: species.id),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('View Full Species Details'),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
