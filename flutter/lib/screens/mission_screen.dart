import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/photography_assistant_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import 'identify_screen.dart';
import 'species_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/species_network_image.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  /// Quiz flow state:
  /// - _started controls intro vs quiz flow
  /// - _step controls current quiz/result/task screen
  bool _started = false;
  int _step = 0;
  String? _gear;
  String? _difficulty;
  String? _subject;
  String? _timePeriod;
  MissionRecommendation? _mission;
  Species? _proofSpecies;
  final List<_MissionProof> _proofSubmissions = [];
  List<_TaskCardData> _missionTasks = const [];
  final Map<String, String> _lastTaskFingerprintByProfile = {};

  /// Starts the mission quiz from intro page.
  void _startQuiz() {
    setState(() {
      _started = true;
      _step = 0;
    });
  }

  /// Moves one step back in quiz flow.
  void _goBackStep() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  /// Resets all mission selections, generated tasks, and proof progress.
  void _startOver() {
    setState(() {
      _started = false;
      _step = 0;
      _gear = null;
      _difficulty = null;
      _subject = null;
      _timePeriod = null;
      _mission = null;
      _proofSpecies = null;
      _proofSubmissions.clear();
      _missionTasks = const [];
    });
  }

  /// Handles quiz answer selection and advances step-by-step.
  /// Once all answers are available, generates mission summary + checklist.
  void _selectAnswer(String value) {
    setState(() {
      _proofSpecies = null;
      _proofSubmissions.clear();
      // Step 0: gear selection.
      if (_step == 0) {
        _gear = value;
        _step = 1;
        return;
      }
      // Step 1: difficulty selection.
      if (_step == 1) {
        _difficulty = value;
        _step = 2;
        return;
      }
      // Step 2: subject/category selection.
      if (_step == 2) {
        _subject = value;
        _step = 3;
        return;
      }

      // Step 3: preferred time selected -> finalize mission payload.
      _timePeriod = value;
      _mission = buildMissionRecommendation(
        gear: _gear ?? 'Smartphone',
        difficulty: _difficulty ?? 'Casual',
        subject: _subject ?? 'Insects',
      );
      _missionTasks = _generateTaskChecklist(
        subject: _subject ?? 'Insects',
        difficulty: _difficulty ?? 'Casual',
        gear: _gear ?? 'Smartphone',
        preferredTime: _timePeriod ?? 'Morning',
      );
      _step = 4;
    });
  }

  /// Opens identify flow and returns a verified species as mission proof.
  Future<void> _uploadMissionProof() async {
    final expectedCategory = _subject;
    if (expectedCategory == null) return;
    final result = await Navigator.of(context).push<Species>(
      MaterialPageRoute<Species>(
        builder: (_) => IdentifyScreen(
          expectedCategory: expectedCategory,
          allowMissionProofReturn: true,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _proofSpecies = result;
      _proofSubmissions.add(
        _MissionProof(species: result, submittedAt: DateTime.now()),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proof submitted with ${result.commonName}. Great work!'),
      ),
    );
  }

  /// Confirms destructive reset from the task list screen.
  Future<void> _confirmResetFromTaskList() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset choices?'),
          content: const Text(
            'This will clear your current mission setup and uploaded proof.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (shouldReset == true && mounted) {
      _startOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16 * s,
          topInset + 8 * s,
          16 * s,
          12 * s,
        ),
        child: Column(
          children: [
            _headerCard(context, s),
            SizedBox(height: 10 * s),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final content = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: _contentByStep(),
                    ),
                  );

                  // Keep outer scroll for intro/quiz/recommendation, but lock it for
                  // task list so rounded panel corners are never clipped by viewport.
                  if (_step >= 5) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: content,
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 4 * s),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: content,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4 * s, 2 * s, 4 * s, 2 * s),
      color: Colors.transparent,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photo Mission',
                style: GoogleFonts.libreBaskerville(
                  fontSize: Adaptive.clamp(context, 34, min: 26, max: 40),
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Malaysian Wildlife Explorer',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: AppColors.textSubtitleOnFrost,
                ),
              ),
              if (_started) ...[
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                        height: 8,
                        decoration: BoxDecoration(
                          color: i <= _step ? AppColors.primary : AppColors.lightSage,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _contentByStep() {
    // Step router for intro, quiz screens, recommendation, and task list.
    if (!_started) {
      return _landingContent();
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
    if (mission == null && _step >= 4) {
      return const SizedBox.shrink();
    }
    if (_step == 4 && mission != null) {
      return _missionSummaryCard(mission);
    }
    if (_step >= 5) {
      return _taskListCard();
    }

    return const SizedBox.shrink();
  }

  Widget _landingContent() {
    final s = Adaptive.scale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.calmShadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personalise and find\nyour perfect challenge\ntoday!',
                              style: GoogleFonts.libreBaskerville(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                height: 1.26,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Choose your preferences and\nwe\'ll create missions just for you.',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade700,
                                fontSize: 13.5,
                                height: 1.48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12 * s),
                      SizedBox(
                        width: Adaptive.clamp(context, 168, min: 140, max: 188),
                        child: Image.asset(
                          'assets/images/kachak_logo_green.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startQuiz,
                      icon: const Icon(Icons.camera_alt_outlined),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      label: const Text('Let\'s Begin!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16 * s),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mission Ideas for You',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 34 / 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    'Quick inspiration to get started',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * s),
        SizedBox(
          height: 216,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ideaCard(
                icon: Icons.eco_outlined,
                title: 'Beginner\nfriendly',
                subtitle: 'Perfect for new\nwildlife explorers.',
                badge: 'Easy',
              ),
              SizedBox(width: 10 * s),
              _ideaCard(
                icon: Icons.schedule,
                title: '1-hour\nwalk',
                subtitle: 'Short on time?\nWe\'ve got you.',
                badge: '~1 hour',
              ),
              SizedBox(width: 10 * s),
              _ideaCard(
                icon: Icons.flutter_dash_outlined,
                title: 'Birds',
                subtitle: 'Spot and capture\nbeautiful birds.',
                badge: 'Popular',
              ),
              SizedBox(width: 10 * s),
              _ideaCard(
                icon: Icons.forest_outlined,
                title: 'Forest\ntrail',
                subtitle: 'Explore lush trails\nand hidden gems.',
                badge: 'Scenic',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ideaCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightSage.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.libreBaskerville(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              fontSize: 16,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11.5,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: AppColors.badgeText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionSummaryCard(MissionRecommendation mission) {
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
            style: GoogleFonts.libreBaskerville(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text('Location hint: ${mission.locationHint}'),
          const SizedBox(height: 8),
          if (_timePeriod != null) ...[
            Text('Preferred time: $_timePeriod'),
            const SizedBox(height: 8),
          ],
          Text(
            _missionTasks.isNotEmpty
                ? 'Task preview: ${_missionTasks.first.title}'
                : 'Task: ${mission.task}',
          ),
          const SizedBox(height: 8),
          Text('Why this matches: ${mission.explanation}'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() => _step = 5),
              child: const Text('Move on to Task List'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: _startOver,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Reset Choices'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskListCard() {
    // Weekly task panel keeps fixed rounded shape; inner content scrolls.
    final s = Adaptive.scale(context);
    final panelHeight = (MediaQuery.sizeOf(context).height * 0.72).clamp(
      440.0,
      760.0,
    );
    final subject = _subject ?? 'Insects';
    final difficulty = _difficulty ?? 'Casual';
    final stars = _difficultyStars(difficulty);
    final speciesTargets = _recommendedSpeciesForSubject(
      subject: subject,
      difficulty: difficulty,
    );
    final taskItems = _missionTasks;

    return SizedBox(
      height: panelHeight,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Task',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mission: ${_mission?.title ?? '$subject Challenge'}',
                    style: GoogleFonts.libreBaskerville(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Difficulty  ',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      ...List.generate(
                        stars,
                        (_) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 12 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    // Horizontal target-species strip for quick discovery.
                    if (speciesTargets.isNotEmpty) ...[
                      Text(
                        'Target species suggestions',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 208,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: speciesTargets.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (_, i) =>
                              _speciesTaskCard(speciesTargets[i]),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Weekly tasks',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Render generated task cards with rule-based progress.
                    ...taskItems.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _taskProgressCard(task),
                      ),
                    ),
                    if (_proofSpecies != null) ...[
                      // Lightweight feedback that latest proof was accepted.
                      const SizedBox(height: 2),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Proof uploaded: ${_proofSpecies!.commonName}',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else
                      const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _uploadMissionProof,
                        icon: const Icon(Icons.upload_rounded),
                        label: Text(
                          _proofSpecies == null
                              ? 'Upload proof photo'
                              : 'Upload another proof photo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: _confirmResetFromTaskList,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Reset Choices'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskProgressCard(_TaskCardData task) {
    final current = _taskProgressCount(task);
    final target = task.targetCount;
    final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            task.detail,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.green.shade50,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$current/$target',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _speciesTaskCard(Species sp) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpeciesDetailScreen(speciesId: sp.id),
            ),
          );
        },
        child: Ink(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 96,
                  child: SpeciesNetworkImage(
                    url: sp.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sp.commonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        sp.scientificName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              sp.category,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackgroundColor(
                                sp.conservationStatus,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusAbbreviation(sp.conservationStatus),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusForegroundColor(
                                  sp.conservationStatus,
                                ),
                              ),
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
    );
  }

  int _difficultyStars(String difficulty) {
    switch (difficulty) {
      case 'Challenging':
        return 5;
      case 'Standard':
        return 3;
      default:
        return 2;
    }
  }

  /// Creates varied, verifiable tasks from the selected profile.
  /// Includes anti-repeat behavior per profile combination.
  List<_TaskCardData> _generateTaskChecklist({
    required String subject,
    required String difficulty,
    required String gear,
    required String preferredTime,
  }) {
    // Species shortlist affects specific/rarity task availability.
    final speciesTargets = _recommendedSpeciesForSubject(
      subject: subject,
      difficulty: difficulty,
    );
    // Difficulty controls number of cards shown in final checklist.
    final maxTasks = switch (difficulty) {
      'Challenging' => 3,
      'Standard' => 2,
      _ => 1,
    };
    final profileKey = '$subject|$difficulty|$gear|$preferredTime';
    final baseSeed =
        DateTime.now().microsecondsSinceEpoch ^
        profileKey.hashCode ^
        speciesTargets.length;
    List<_TaskCardData> generated = const [];
    // Retry generation with shifted seed to reduce repeated output per profile.
    for (var attempt = 0; attempt < 6; attempt++) {
      generated = _buildTaskSet(
        subject: subject,
        difficulty: difficulty,
        gear: gear,
        preferredTime: preferredTime,
        speciesTargets: speciesTargets,
        maxTasks: maxTasks,
        rng: Random(baseSeed + (attempt * 977)),
      );
      final fingerprint = generated.map((t) => t.title).join('|');
      final previous = _lastTaskFingerprintByProfile[profileKey];
      if (fingerprint != previous || attempt == 5) {
        // Persist last set so the next generation can avoid immediate repeats.
        _lastTaskFingerprintByProfile[profileKey] = fingerprint;
        break;
      }
    }
    return generated;
  }

  /// Builds one candidate task set using weighted templates.
  List<_TaskCardData> _buildTaskSet({
    required String subject,
    required String difficulty,
    required String gear,
    required String preferredTime,
    required List<Species> speciesTargets,
    required int maxTasks,
    required Random rng,
  }) {
    final subjectLower = subject.toLowerCase();
    final singular = _subjectSingular(subject);
    // Core detection/count objective (always present).
    final categoryTargetCount = _categoryCountTarget(
      difficulty: difficulty,
      gear: gear,
      rng: rng,
    );
    final primaryTaskCandidates = <_TaskCardData>[
      _TaskCardData(
        title:
            'Capture $categoryTargetCount $subjectLower photo${categoryTargetCount > 1 ? 's' : ''}',
        detail: 'Detection and count objective',
        targetCount: categoryTargetCount,
        ruleType: _TaskRuleType.categoryCount,
      ),
      _TaskCardData(
        title:
            'Document $categoryTargetCount $subjectLower sighting${categoryTargetCount > 1 ? 's' : ''}',
        detail: 'Species detection objective',
        targetCount: categoryTargetCount,
        ruleType: _TaskRuleType.categoryCount,
      ),
    ];
    final selected = <_TaskCardData>[
      primaryTaskCandidates[rng.nextInt(primaryTaskCandidates.length)],
    ];

    // Optional pool from which we sample based on difficulty/gear/context.
    final optional = <_TaskCardData>[];

    final preferredWindow = _timeWindowForLabel(preferredTime);
    optional.add(
      _TaskCardData(
        title: 'Capture 1 $singular during $preferredTime',
        detail: 'Time-based objective',
        targetCount: 1,
        ruleType: _TaskRuleType.timeWindow,
        timeWindow: preferredWindow,
      ),
    );

    if (difficulty == 'Challenging' || gear == 'DSLR / Mirrorless') {
      // Harder setups prioritize higher unique-species targets.
      optional.add(
        _TaskCardData(
          title:
              'Capture ${difficulty == 'Challenging' ? 3 : 2} different $subjectLower species',
          detail: 'Variety objective',
          targetCount: difficulty == 'Challenging' ? 3 : 2,
          ruleType: _TaskRuleType.uniqueSpeciesCount,
        ),
      );
    } else {
      optional.add(
        _TaskCardData(
          title: 'Capture 2 different $subjectLower species',
          detail: 'Variety objective',
          targetCount: 2,
          ruleType: _TaskRuleType.uniqueSpeciesCount,
        ),
      );
    }

    if (gear == 'Smartphone') {
      // Beginner-safe fallback for smartphone users.
      optional.add(
        _TaskCardData(
          title: 'Capture 1 $singular during daytime',
          detail: 'Beginner-friendly time objective',
          targetCount: 1,
          ruleType: _TaskRuleType.timeWindow,
          timeWindow: const _TaskTimeWindow(startHour: 6, endHour: 18),
        ),
      );
    } else if (gear == 'DSLR / Mirrorless') {
      optional.add(
        _TaskCardData(
          title: 'Capture 1 vulnerable-or-higher $singular',
          detail: 'Conservation objective',
          targetCount: 1,
          ruleType: _TaskRuleType.conservationRank,
          minConservationRank: 2,
        ),
      );
    }

    if (speciesTargets.isNotEmpty) {
      // Add concrete species targets for clearer "what to hunt" direction.
      final shuffledTargets = List<Species>.from(speciesTargets)..shuffle(rng);
      for (final pick in shuffledTargets.take(2)) {
        optional.add(
          _TaskCardData(
            title: 'Capture 1 ${pick.commonName} photo',
            detail: 'Target species objective',
            targetCount: 1,
            ruleType: _TaskRuleType.specificSpecies,
            requiredSpeciesId: pick.id,
          ),
        );
      }
    }

    final hasVulnerable = speciesTargets.any(
      (s) => conservationStatusRank(s.conservationStatus) >= 2,
    );
    if (hasVulnerable && (difficulty != 'Casual' || rng.nextBool())) {
      // Rarity task appears when the shortlist supports conservation validation.
      optional.add(
        _TaskCardData(
          title: 'Capture 1 vulnerable-or-higher $singular',
          detail: 'Conservation objective',
          targetCount: 1,
          ruleType: _TaskRuleType.conservationRank,
          minConservationRank: 2,
        ),
      );
    }

    if (speciesTargets.any(
      (s) => conservationStatusRank(s.conservationStatus) >= 3,
    )) {
      optional.add(
        _TaskCardData(
          title: 'Capture 1 endangered-or-higher $singular',
          detail: 'High-priority conservation objective',
          targetCount: 1,
          ruleType: _TaskRuleType.conservationRank,
          minConservationRank: 3,
        ),
      );
    }

    optional.shuffle(rng);
    for (final candidate in optional) {
      if (selected.length >= maxTasks) break;
      if (selected.any((t) => t.title == candidate.title)) continue;
      selected.add(candidate);
    }

    // Ensure non-casual missions include at least one time or variety challenge.
    if (difficulty != 'Casual' &&
        !selected.any(
          (t) =>
              t.ruleType == _TaskRuleType.timeWindow ||
              t.ruleType == _TaskRuleType.uniqueSpeciesCount,
        )) {
      final inject = _TaskCardData(
        title: 'Capture 1 $singular during $preferredTime',
        detail: 'Time-based objective',
        targetCount: 1,
        ruleType: _TaskRuleType.timeWindow,
        timeWindow: preferredWindow,
      );
      if (selected.length < maxTasks) {
        selected.add(inject);
      } else {
        selected[max(1, selected.length - 1)] = inject;
      }
    }

    return selected;
  }

  /// Tunes category count target using difficulty + gear.
  int _categoryCountTarget({
    required String difficulty,
    required String gear,
    required Random rng,
  }) {
    final base = switch (difficulty) {
      'Challenging' => 3,
      'Standard' => 2,
      _ => 1,
    };
    final gearDelta = switch (gear) {
      'Smartphone' => difficulty == 'Casual' ? 0 : -1,
      'DSLR / Mirrorless' => 1,
      _ => 0,
    };
    final variation = difficulty == 'Casual' ? 0 : rng.nextInt(2); // 0..1
    return (base + gearDelta + variation).clamp(1, 4);
  }

  /// Evaluates current progress for a task from uploaded proof history.
  int _taskProgressCount(_TaskCardData task) {
    final submissions = _proofSubmissions;
    switch (task.ruleType) {
      case _TaskRuleType.categoryCount:
        // Any verified proof contributes.
        return submissions.length.clamp(0, task.targetCount);
      case _TaskRuleType.uniqueSpeciesCount:
        // Only distinct species IDs contribute.
        return submissions
            .map((p) => p.species.id)
            .toSet()
            .length
            .clamp(0, task.targetCount);
      case _TaskRuleType.timeWindow:
        // Count proofs whose submission timestamp matches required window.
        final window = task.timeWindow;
        if (window == null) return 0;
        return submissions
            .where((p) => window.contains(p.submittedAt))
            .length
            .clamp(0, task.targetCount);
      case _TaskRuleType.specificSpecies:
        // Count only exact species matches.
        final speciesId = task.requiredSpeciesId;
        if (speciesId == null) return 0;
        return submissions
            .where((p) => p.species.id == speciesId)
            .length
            .clamp(0, task.targetCount);
      case _TaskRuleType.conservationRank:
        // Count species meeting minimum conservation urgency.
        final minRank = task.minConservationRank ?? 2;
        return submissions
            .where(
              (p) =>
                  conservationStatusRank(p.species.conservationStatus) >=
                  minRank,
            )
            .length
            .clamp(0, task.targetCount);
    }
  }

  /// Maps plural quiz label to singular noun for task text.
  String _subjectSingular(String subject) {
    return switch (subject) {
      'Birds' => 'bird',
      'Mammals' => 'mammal',
      'Reptiles' => 'reptile',
      'Amphibians' => 'amphibian',
      _ => 'insect',
    };
  }

  /// Converts user-selected time label into a verifiable hour window.
  _TaskTimeWindow _timeWindowForLabel(String label) {
    return switch (label) {
      'Morning' => const _TaskTimeWindow(startHour: 6, endHour: 10),
      'Afternoon' => const _TaskTimeWindow(startHour: 12, endHour: 17),
      'Evening' => const _TaskTimeWindow(startHour: 17, endHour: 20),
      'Night' => const _TaskTimeWindow(startHour: 20, endHour: 24),
      'Midnight' => const _TaskTimeWindow(startHour: 0, endHour: 5),
      _ => const _TaskTimeWindow(startHour: 6, endHour: 24),
    };
  }

  /// Suggests nearby target species filtered by category and difficulty.
  List<Species> _recommendedSpeciesForSubject({
    required String subject,
    required String difficulty,
  }) {
    final category = switch (subject) {
      'Birds' => Species.birds,
      'Mammals' => Species.mammals,
      'Reptiles' => Species.reptiles,
      'Amphibians' => Species.amphibians,
      _ => Species.insects,
    };
    final inCategory = speciesData
        .where((s) => s.category == category)
        .toList();
    bool matchesDifficulty(Species s) {
      switch (difficulty) {
        case 'Challenging':
          return s.difficultyLevel >= 4 && s.difficultyLevel <= 5;
        case 'Standard':
          return s.difficultyLevel == 3;
        default:
          return s.difficultyLevel >= 1 && s.difficultyLevel <= 2;
      }
    }

    final filtered = inCategory.where(matchesDifficulty).toList()
      ..sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));

    // If no strict match in a category, gracefully fall back to nearest levels.
    final fallback = List<Species>.from(inCategory)
      ..sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
    final source = filtered.isNotEmpty ? filtered : fallback;
    // Keep the carousel focused and not excessively long.
    return source.take(6).toList();
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
            style: GoogleFonts.libreBaskerville(
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

class _TaskCardData {
  const _TaskCardData({
    required this.title,
    required this.detail,
    required this.targetCount,
    required this.ruleType,
    this.requiredSpeciesId,
    this.timeWindow,
    this.minConservationRank,
  });

  final String title;
  final String detail;
  final int targetCount;
  final _TaskRuleType ruleType;
  final String? requiredSpeciesId;
  final _TaskTimeWindow? timeWindow;
  final int? minConservationRank;
}

enum _TaskRuleType {
  categoryCount,
  uniqueSpeciesCount,
  timeWindow,
  specificSpecies,
  conservationRank,
}

class _MissionProof {
  const _MissionProof({required this.species, required this.submittedAt});

  final Species species;
  final DateTime submittedAt;
}

class _TaskTimeWindow {
  const _TaskTimeWindow({required this.startHour, required this.endHour});

  final int startHour;
  final int endHour;

  bool contains(DateTime time) {
    final hour = time.hour;
    if (startHour < endHour) {
      return hour >= startHour && hour < endHour;
    }
    return hour >= startHour || hour < endHour;
  }
}
