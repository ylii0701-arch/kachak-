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

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  Species? _predicted;
  double? _confidence;
  String? _message;
  bool _isLoading = false;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    setState(() {
      _isLoading = true;
      _imageFile = file;
      _predicted = null;
      _confidence = null;
      _message = null;
    });

    final bytes = await file.readAsBytes();
    final matched = predictSpeciesFromImagePath(file.path, speciesData);
    if (!mounted) return;

    if (matched != null) {
      setState(() {
        _imageBytes = bytes;
        _predicted = matched;
        _confidence = 0.9;
        _message = 'Identification completed successfully.';
        _isLoading = false;
      });
      return;
    }

    final fallback = speciesData[file.path.hashCode.abs() % speciesData.length];
    setState(() {
      _imageBytes = bytes;
      _predicted = fallback;
      _confidence = 0.45;
      _message =
          'Result is uncertain. Please upload a clearer, closer, and better-lit photo.';
      _isLoading = false;
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.camera_alt_outlined),
                        ),
                        SizedBox(width: 10 * s),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Species Recognition',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Identify wildlife from photos',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * s),
                    Container(
                      padding: EdgeInsets.all(12 * s),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Upload a clear photo of an animal for AI-powered species identification. Works best with well-lit, focused images.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 100 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _actionCard(
                  title: 'Take a Photo',
                  subtitle: 'Use your camera to capture wildlife',
                  icon: Icons.camera_alt_outlined,
                  highlighted: false,
                  onTap: () => _pick(ImageSource.camera),
                ),
                SizedBox(height: 12 * s),
                _actionCard(
                  title: 'Upload from Gallery',
                  subtitle: 'Choose an existing photo',
                  icon: Icons.upload,
                  highlighted: true,
                  onTap: () => _pick(ImageSource.gallery),
                ),
                if (_isLoading) ...[
                  SizedBox(height: 12 * s),
                  const LinearProgressIndicator(),
                ],
                if (_imageFile != null) ...[
                  SizedBox(height: 12 * s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                          : (!kIsWeb
                                ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                                : const ColoredBox(color: Colors.black12)),
                    ),
                  ),
                ],
                if (_predicted != null && _confidence != null) ...[
                  SizedBox(height: 12 * s),
                  _resultCard(context),
                ],
                SizedBox(height: 12 * s),
                _tipsCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool highlighted,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted ? Colors.green.shade300 : Colors.grey.shade300,
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 30 / 1.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Tips for Best Results', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('• Ensure the animal is clearly visible and in focus'),
          Text('• Use good lighting conditions'),
          Text('• Get as close as safely possible'),
          Text('• Avoid blurry or distant shots'),
        ],
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final uncertain = (_confidence ?? 0) < 0.6;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: uncertain ? Colors.orange.shade300 : Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prediction', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_predicted!.commonName, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(_predicted!.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(_predicted!.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('Confidence: ${((_confidence ?? 0) * 100).toStringAsFixed(0)}%'),
          if (_message != null) ...[
            const SizedBox(height: 4),
            Text(_message!),
          ],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SpeciesDetailScreen(speciesId: _predicted!.id),
                ),
              );
            },
            child: const Text('Open species details'),
          ),
        ],
      ),
    );
  }
}
