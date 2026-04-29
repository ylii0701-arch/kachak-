import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _started = false;
  int _step = 0;
  String? _gear;
  String? _difficulty;
  String? _subject;
  String? _timePeriod;
  MissionRecommendation? _mission;

  void _startQuiz() {
    setState(() {
      _started = true;
      _step = 0;
    });
  }

  void _goBackStep() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _startOver() {
    setState(() {
      _started = false;
      _step = 0;
      _gear = null;
      _difficulty = null;
      _subject = null;
      _timePeriod = null;
      _mission = null;
    });
  }

  void _selectAnswer(String value) {
    setState(() {
      if (_step == 0) {
        _gear = value;
        _step = 1;
        return;
      }
      if (_step == 1) {
        _difficulty = value;
        _step = 2;
        return;
      }
      if (_step == 2) {
        _subject = value;
        _step = 3;
        return;
      }

      _timePeriod = value;
      _mission = buildMissionRecommendation(
        gear: _gear ?? 'Smartphone',
        difficulty: _difficulty ?? 'Casual',
        subject: _subject ?? 'Insects',
      );
      _step = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final navBarHeight = bottomInset > 0
        ? bottomInset + (2 * s) + 64 * s
        : 6 * s + 64 * s;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16 * s, 42 * s, 16 * s, navBarHeight + 12 * s),
        child: Column(
          children: [
            if (_started) ...[
              _headerCard(context, s),
              SizedBox(height: 10 * s),
            ],
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _contentByStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context, double s) {
    return GlassPanel(
      padding: EdgeInsets.all(16 * s),
      borderRadius: 22 * s,
      fillAlpha: 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Mission',
            style: GoogleFonts.plusJakartaSans(
              fontSize: Adaptive.clamp(context, 28, min: 22, max: 34),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.05,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _started
                ? 'Personalised challenge builder'
                : 'Personalise and find your perfect challenge today!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.35,
              height: 1.35,
              color: const Color(0xFF5C6B63),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                  height: 8,
                  decoration: BoxDecoration(
                    color: _started && i <= _step
                        ? AppColors.primary
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentByStep() {
    if (!_started) {
      return _introBlock();
    }

    if (_step == 0) {
      return _quizBlock(
        questionTitle: 'What gear do you have?',
        questionSubtitle: 'Select your camera setup',
        choices: const [
          _QuizChoice(
            label: 'Smartphone',
            subtitle: 'iPhone, Android, or any mobile device',
          ),
          _QuizChoice(
            label: 'Digicam',
            subtitle: 'Older simple digital point-and-shoot camera',
          ),
          _QuizChoice(
            label: 'Fixed Lens Compact',
            subtitle: 'Modern compact camera with built-in non-removable lens',
          ),
          _QuizChoice(
            label: 'DSLR / Mirrorless',
            subtitle: 'Dedicated camera with interchangeable lenses',
          ),
        ],
      );
    }
    if (_step == 1) {
      return _quizBlock(
        questionTitle: 'Choose your challenge level',
        questionSubtitle: 'How difficult should this mission be?',
        choices: const [
          _QuizChoice(
            label: 'Casual',
            subtitle: 'Relaxed pace, beginner-friendly mission',
          ),
          _QuizChoice(
            label: 'Standard',
            subtitle: 'Moderate challenge with mixed situations',
          ),
          _QuizChoice(
            label: 'Challenging',
            subtitle: 'Advanced mission with tougher conditions',
          ),
        ],
      );
    }
    if (_step == 2) {
      return _quizBlock(
        questionTitle: 'What subject do you prefer?',
        questionSubtitle: 'Select wildlife category',
        choices: const [
          _QuizChoice(
            label: 'Birds',
            subtitle: 'Examples: hornbills, kingfishers, broadbills',
          ),
          _QuizChoice(
            label: 'Mammals',
            subtitle: 'Examples: sun bears, tapirs, macaques',
          ),
          _QuizChoice(
            label: 'Insects',
            subtitle: 'Examples: butterflies, mantis, dragonflies',
          ),
          _QuizChoice(
            label: 'Reptiles',
            subtitle: 'Examples: pythons, monitor lizards, geckos',
          ),
          _QuizChoice(
            label: 'Amphibians',
            subtitle: 'Examples: tree frogs and forest toads',
          ),
        ],
      );
    }
    if (_step == 3) {
      final includeMidnight = (_difficulty ?? 'Casual') == 'Challenging';
      return _quizBlock(
        questionTitle: 'Preferred shoot time?',
        questionSubtitle: 'Pick your ideal session window',
        choices: [
          const _QuizChoice(
            label: 'Morning',
            subtitle: 'Soft light, active birds, easier visibility',
          ),
          const _QuizChoice(
            label: 'Afternoon',
            subtitle: 'Brighter conditions, best for clear habitat shots',
          ),
          const _QuizChoice(
            label: 'Evening',
            subtitle: 'Golden-hour tones and calm wildlife movement',
          ),
          const _QuizChoice(
            label: 'Night',
            subtitle: 'Useful for nocturnal species with proper light',
          ),
          if (includeMidnight)
            const _QuizChoice(
              label: 'Midnight',
              subtitle:
                  'More challenging: low visibility, safety and access limits',
              caution: true,
            ),
        ],
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Photography Mission',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            mission.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text('Location hint: ${mission.locationHint}'),
          const SizedBox(height: 8),
          if (_timePeriod != null) ...[
            Text('Preferred time: $_timePeriod'),
            const SizedBox(height: 8),
          ],
          Text('Task: ${mission.task}'),
          const SizedBox(height: 8),
          Text('Why this matches: ${mission.explanation}'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _startOver,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Mission',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalise and find your perfect challenge today!',
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.35,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Image.asset(
              'assets/images/kachak_logo_green.png',
              height: Adaptive.clamp(context, 132, min: 110, max: 160),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _startQuiz,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Let\'s Begin!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizBlock({
    required String questionTitle,
    required String questionSubtitle,
    required List<_QuizChoice> choices,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.26),
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_step + 1} out of 4',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSubtitleOnFrost,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            questionTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: Adaptive.clamp(context, 27 / 1.5, min: 16, max: 22),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            questionSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSubtitleOnFrost,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...choices.map(
            (choice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _selectAnswer(choice.label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: choice.caution
                            ? Colors.orange.shade200
                            : Colors.green.shade100,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      choice.label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (choice.caution)
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                      color: Colors.orange.shade700,
                                    ),
                                ],
                              ),
                              if (choice.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  choice.subtitle!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_step > 0) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _goBackStep,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textSubtitleOnFrost,
              ),
              label: Text(
                'Previous question',
                style: TextStyle(color: AppColors.textSubtitleOnFrost),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizChoice {
  const _QuizChoice({required this.label, this.subtitle, this.caution = false});

  final String label;
  final String? subtitle;
  final bool caution;
}
