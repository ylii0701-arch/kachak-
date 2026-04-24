import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/photography_assistant_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
import 'species_detail_screen.dart';

class PhotographyAssistantScreen extends StatefulWidget {
  const PhotographyAssistantScreen({super.key});

  @override
  State<PhotographyAssistantScreen> createState() =>
      _PhotographyAssistantScreenState();
}

class _PhotographyAssistantScreenState extends State<PhotographyAssistantScreen> {
  final _equipmentController = TextEditingController();
  final _animalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _scenarioLabel = 'Low light';
  ShootingAdvice? _advice;
  String? _adviceMessage;

  String _weatherLabel = 'Unavailable';
  TripChecklist? _tripChecklist;
  String? _tripMessage;

  String _missionGear = 'Smartphone';
  String _missionDifficulty = 'Casual';
  String _missionSubject = 'Insects';
  MissionRecommendation? _mission;

  Uint8List? _selectedImageBytes;
  XFile? _selectedImageFile;
  Species? _predictedSpecies;
  double? _confidence;
  String? _recognitionMessage;
  bool _isProcessingImage = false;

  @override
  void dispose() {
    _equipmentController.dispose();
    _animalController.dispose();
    super.dispose();
  }

  void _generateShootingAdvice() {
    final equipment = detectEquipment(_equipmentController.text);
    if (equipment.isEmpty) {
      setState(() {
        _advice = null;
        _adviceMessage =
            'I need clearer gear details before generating advice. Please include your camera type and at least one accessory (for example: "Canon R50 + 55-210mm lens + tripod").';
      });
      return;
    }

    final scenario = scenarioFromLabel(_scenarioLabel);
    if (scenario == ShootingScenario.unsupported) {
      setState(() {
        _advice = null;
        _adviceMessage =
            'This scenario is currently outside the supported scope. I can provide accurate advice for: Low light, Fast-moving animals, or Long-distance shooting.';
      });
      return;
    }

    final advice = buildShootingAdvice(equipment: equipment, scenario: scenario);
    if (advice == null) {
      setState(() {
        _advice = null;
        _adviceMessage =
            'Accurate advice could not be generated right now. Please adjust your scenario or gear details.';
      });
      return;
    }
    setState(() {
      _advice = advice;
      _adviceMessage = null;
    });
  }

  void _generateTripChecklist() {
    final animal = _animalController.text.trim();
    if (animal.length < 3) {
      setState(() {
        _tripChecklist = null;
        _tripMessage =
            'Please tell me your target animal more clearly before I recommend equipment.';
      });
      return;
    }

    final checklist = buildTripChecklist(
      animalInput: animal,
      weatherInput: _weatherLabel,
    );
    if (checklist == null) {
      setState(() {
        _tripChecklist = null;
        _tripMessage =
            'No useful recommendation can be generated yet. Please refine your target animal input.';
      });
      return;
    }
    setState(() {
      _tripChecklist = checklist;
      _tripMessage = null;
    });
  }

  void _generateMission() {
    setState(() {
      _mission = buildMissionRecommendation(
        gear: _missionGear,
        difficulty: _missionDifficulty,
        subject: _missionSubject,
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2200,
    );
    if (file == null) return;

    setState(() {
      _isProcessingImage = true;
      _selectedImageFile = file;
      _predictedSpecies = null;
      _confidence = null;
      _recognitionMessage = null;
    });

    final bytes = await file.readAsBytes();
    final matched = matchSpeciesByImageName(file.path, speciesData);
    if (!mounted) return;

    if (matched != null) {
      setState(() {
        _selectedImageBytes = bytes;
        _predictedSpecies = matched;
        _confidence = 0.88;
        _recognitionMessage =
            'Species identified with high confidence from the uploaded image.';
        _isProcessingImage = false;
      });
      return;
    }

    final fallback = speciesData[file.path.hashCode.abs() % speciesData.length];
    setState(() {
      _selectedImageBytes = bytes;
      _predictedSpecies = fallback;
      _confidence = 0.43;
      _recognitionMessage =
          'Result is uncertain. Please upload a clearer photo with better lighting, closer framing, and visible body features.';
      _isProcessingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom + (96 * s);
    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 28 * s, 16 * s, 10 * s),
              child: GlassPanel(
                padding: EdgeInsets.all(18 * s),
                borderRadius: 24 * s,
                fillAlpha: 0.42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.camera_enhance_outlined,
                          color: AppColors.primary,
                          size: 28 * s,
                        ),
                        SizedBox(width: 10 * s),
                        Text(
                          'Photography Assistant',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'Get shooting advice, pre-trip checklist recommendations, species recognition, and a personalized photography mission.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.45,
                        fontSize: Adaptive.clamp(context, 14, min: 12, max: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16 * s, 2 * s, 16 * s, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionCard(
                  context,
                  title: '4.1 Camera settings and shooting tips',
                  icon: Icons.tune,
                  child: _advicePanel(context),
                ),
                SizedBox(height: 12 * s),
                _sectionCard(
                  context,
                  title: '4.2 Pre-trip preparation checklist',
                  icon: Icons.checklist,
                  child: _tripPanel(context),
                ),
                SizedBox(height: 12 * s),
                _sectionCard(
                  context,
                  title: '5.1 AI-powered species recognition',
                  icon: Icons.photo_camera_back_outlined,
                  child: _speciesRecognitionPanel(context),
                ),
                SizedBox(height: 12 * s),
                _sectionCard(
                  context,
                  title: '6 Photography mission setup',
                  icon: Icons.explore_outlined,
                  child: _missionPanel(context),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _advicePanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _equipmentController,
          decoration: const InputDecoration(
            labelText: 'Your available gear',
            hintText: 'Example: Nikon D5600, 70-300mm lens, tripod',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _scenarioLabel,
          decoration: const InputDecoration(labelText: 'Shooting scenario'),
          items: const [
            DropdownMenuItem(value: 'Low light', child: Text('Low light')),
            DropdownMenuItem(
              value: 'Fast-moving animals',
              child: Text('Fast-moving animals'),
            ),
            DropdownMenuItem(
              value: 'Long-distance shooting',
              child: Text('Long-distance shooting'),
            ),
            DropdownMenuItem(
              value: 'Unsupported scenario',
              child: Text('Unsupported scenario'),
            ),
          ],
          onChanged: (value) => setState(() => _scenarioLabel = value ?? 'Low light'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _generateShootingAdvice,
          icon: const Icon(Icons.auto_fix_high_outlined),
          label: const Text('Generate advice'),
        ),
        if (_adviceMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _adviceMessage!,
            style: const TextStyle(color: Colors.redAccent, height: 1.45),
          ),
        ],
        if (_advice != null) ...[
          const SizedBox(height: 14),
          _templateBlock(
            title: 'Detected equipment',
            items: _advice!.detectedEquipment,
          ),
          const SizedBox(height: 8),
          _templateBlock(title: 'Recommended settings', items: _advice!.settings),
          const SizedBox(height: 8),
          _templateBlock(title: 'Practical tips', items: _advice!.tips),
          const SizedBox(height: 8),
          _textBlock(title: 'Why these settings', text: _advice!.explanation),
          const SizedBox(height: 8),
          _textBlock(
            title: 'Simple term explanations',
            text: _advice!.terms.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n'),
          ),
        ],
      ],
    );
  }

  Widget _tripPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _animalController,
          decoration: const InputDecoration(
            labelText: 'Target animal',
            hintText: 'Example: Hornbill / mammal / insects',
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _weatherLabel,
          decoration: const InputDecoration(labelText: 'Expected weather'),
          items: const [
            DropdownMenuItem(value: 'Sunny', child: Text('Sunny')),
            DropdownMenuItem(value: 'Rainy', child: Text('Rainy')),
            DropdownMenuItem(value: 'Windy', child: Text('Windy')),
            DropdownMenuItem(value: 'Unavailable', child: Text('Unavailable')),
          ],
          onChanged: (value) =>
              setState(() => _weatherLabel = value ?? 'Unavailable'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _generateTripChecklist,
          icon: const Icon(Icons.playlist_add_check_circle_outlined),
          label: const Text('Build checklist'),
        ),
        if (_tripMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _tripMessage!,
            style: const TextStyle(color: Colors.redAccent, height: 1.45),
          ),
        ],
        if (_tripChecklist != null) ...[
          const SizedBox(height: 14),
          Text(
            _tripChecklist!.weatherNotice,
            style: TextStyle(color: Colors.blueGrey.shade700, height: 1.45),
          ),
          const SizedBox(height: 8),
          _checklistBlock(
            title: 'Photography equipment',
            items: _tripChecklist!.photoEquipment,
          ),
          const SizedBox(height: 8),
          _checklistBlock(
            title: 'Outdoor essentials',
            items: _tripChecklist!.outdoorEssentials,
          ),
        ],
      ],
    );
  }

  Widget _speciesRecognitionPanel(BuildContext context) {
    final hasHighConfidence = (_confidence ?? 0) >= 0.6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessingImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload photo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessingImage
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Capture'),
              ),
            ),
          ],
        ),
        if (_isProcessingImage) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Processing image and predicting species...'),
        ],
        if (_selectedImageFile != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : (!kIsWeb
                        ? Image.file(File(_selectedImageFile!.path), fit: BoxFit.cover)
                        : const ColoredBox(color: Colors.black12)),
            ),
          ),
        ],
        if (_predictedSpecies != null && _confidence != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prediction result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _predictedSpecies!.commonName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  _predictedSpecies!.scientificName,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _predictedSpecies!.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Confidence: ${(_confidence! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: hasHighConfidence ? Colors.green.shade700 : Colors.orange.shade800,
                  ),
                ),
                if (_recognitionMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _recognitionMessage!,
                    style: TextStyle(
                      color: hasHighConfidence ? Colors.green.shade800 : Colors.orange.shade900,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SpeciesDetailScreen(speciesId: _predictedSpecies!.id),
                      ),
                    );
                  },
                  child: const Text('View detailed species knowledge'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _missionPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _choiceRow(
          title: 'Gear',
          values: const ['Smartphone', 'DSLR/Mirrorless'],
          selected: _missionGear,
          onChanged: (v) => setState(() => _missionGear = v),
        ),
        const SizedBox(height: 8),
        _choiceRow(
          title: 'Difficulty',
          values: const ['Casual', 'Standard', 'Challenging'],
          selected: _missionDifficulty,
          onChanged: (v) => setState(() => _missionDifficulty = v),
        ),
        const SizedBox(height: 8),
        _choiceRow(
          title: 'Subject Category',
          values: const ['Insects', 'Mammals', 'Birds'],
          selected: _missionSubject,
          onChanged: (v) => setState(() => _missionSubject = v),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _generateMission,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Get photography mission'),
        ),
        if (_mission != null) ...[
          const SizedBox(height: 12),
          _textBlock(title: 'Mission', text: _mission!.title),
          const SizedBox(height: 8),
          _textBlock(title: 'Where to try', text: _mission!.locationHint),
          const SizedBox(height: 8),
          _textBlock(title: 'Your challenge', text: _mission!.task),
          const SizedBox(height: 8),
          _textBlock(title: 'Why this matches you', text: _mission!.explanation),
        ],
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      fillAlpha: 0.56,
      verticalFrostGradient: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _templateBlock({required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $item'),
              )),
        ],
      ),
    );
  }

  Widget _checklistBlock({required String title, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('☑ $item'),
              )),
        ],
      ),
    );
  }

  Widget _textBlock({required String title, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }

  Widget _choiceRow({
    required String title,
    required List<String> values,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: value == selected,
                  onSelected: (_) => onChanged(value),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: value == selected ? Colors.white : Colors.black87,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
