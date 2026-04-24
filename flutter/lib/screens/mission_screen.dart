import 'package:flutter/material.dart';

import '../data/photography_assistant_data.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _step = 0;
  String? _gear;
  String? _difficulty;
  String? _subject;
  MissionRecommendation? _mission;

  void _resetAndSelect(String value) {
    if (_step == 0) {
      setState(() {
        _gear = value;
        _step = 1;
      });
      return;
    }
    if (_step == 1) {
      setState(() {
        _difficulty = value;
        _step = 2;
      });
      return;
    }
    setState(() {
      _subject = value;
      _mission = buildMissionRecommendation(
        gear: _gear ?? 'Smartphone',
        difficulty: _difficulty ?? 'Casual',
        subject: _subject ?? 'Insects',
      );
      _step = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 24 * s, 16 * s, 8 * s),
              child: GlassPanel(
                padding: EdgeInsets.all(16 * s),
                borderRadius: 22 * s,
                fillAlpha: 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo Mission',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find your perfect challenge',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
                            height: 8,
                            decoration: BoxDecoration(
                              color: i <= _step ? AppColors.primary : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 100 * s),
            sliver: SliverToBoxAdapter(
              child: _contentByStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentByStep() {
    if (_step == 0) {
      return _questionBlock(
        title: 'What gear do you have?',
        subtitle: 'Select your camera equipment',
        items: [
          _Option(
            title: 'Smartphone',
            subtitle: 'iPhone, Android, or any mobile device',
            icon: Icons.phone_android_outlined,
            value: 'Smartphone',
          ),
          _Option(
            title: 'DSLR / Mirrorless',
            subtitle: 'Dedicated camera with interchangeable lenses',
            icon: Icons.camera_alt_outlined,
            value: 'DSLR/Mirrorless',
          ),
        ],
      );
    }
    if (_step == 1) {
      return _questionBlock(
        title: 'Choose difficulty level',
        subtitle: 'How challenging do you want this to be?',
        items: [
          _Option(
            title: 'Casual',
            subtitle: 'Relaxed pace, beginner-friendly',
            icon: Icons.bolt_outlined,
            value: 'Casual',
          ),
          _Option(
            title: 'Standard',
            subtitle: 'Moderate challenge, some experience needed',
            icon: Icons.navigation_outlined,
            value: 'Standard',
          ),
          _Option(
            title: 'Challenging',
            subtitle: 'Advanced skills, demanding conditions',
            icon: Icons.landscape_outlined,
            value: 'Challenging',
          ),
        ],
        backLabel: 'Back to gear selection',
        onBack: () => setState(() => _step = 0),
      );
    }
    if (_step == 2) {
      return _questionBlock(
        title: 'What do you want to photograph?',
        subtitle: 'Choose your subject category',
        items: [
          _Option(
            title: 'Insects',
            subtitle: 'Butterflies, beetles, dragonflies',
            icon: Icons.bug_report_outlined,
            value: 'Insects',
          ),
          _Option(
            title: 'Mammals',
            subtitle: 'Squirrels, deer, monkeys, cats',
            icon: Icons.pets_outlined,
            value: 'Mammals',
          ),
          _Option(
            title: 'Birds',
            subtitle: 'Songbirds, raptors, waterbirds',
            icon: Icons.flutter_dash_outlined,
            value: 'Birds',
          ),
        ],
        backLabel: 'Back to difficulty',
        onBack: () => setState(() => _step = 1),
      );
    }

    final mission = _mission;
    if (mission == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Photography Mission', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(mission.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text('Location hint: ${mission.locationHint}'),
          const SizedBox(height: 8),
          Text('Task: ${mission.task}'),
          const SizedBox(height: 8),
          Text('Why this matches: ${mission.explanation}'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Change subject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _step = 0;
                      _gear = null;
                      _difficulty = null;
                      _subject = null;
                      _mission = null;
                    });
                  },
                  child: const Text('Start over'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _questionBlock({
    required String title,
    required String subtitle,
    required List<_Option> items,
    String? backLabel,
    VoidCallback? onBack,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 34 / 1.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _optionCard(item),
          ),
        ),
        if (backLabel != null && onBack != null)
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: Text(backLabel),
          ),
      ],
    );
  }

  Widget _optionCard(_Option option) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _resetAndSelect(option.value),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: const TextStyle(fontSize: 22 / 1.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(option.subtitle, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option {
  const _Option({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
}
