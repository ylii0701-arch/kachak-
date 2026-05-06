import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import 'species_detail_screen.dart';
import '../utils/image_validator.dart';
import '../services/gemini_recognition_service.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({
    super.key,
    this.expectedCategory,
    this.allowMissionProofReturn = false,
  });

  final String? expectedCategory;
  final bool allowMissionProofReturn;

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

  // --- DEBUG TOGGLE ---
  // Set to true to test internet images. ALWAYS set to false for production!
  final bool _bypassExifCheck = true;

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
    setState(() {
      _imageBytes = bytes;
    });

    try {
      // 1. EXIF Validation (Respects Debug Toggle, mobile only)
      if (!_bypassExifCheck && !kIsWeb) {
        final imageFile = File(file.path);
        final isValid = await validateLocalPhoto(imageFile);
        if (!isValid) {
          setState(() {
            _message =
                'Please capture a real photo using your device camera within Malaysia.';
            _isLoading = false;
          });
          return;
        }
      }

      // 2. Call Gemini
      final result = kIsWeb
          ? await identifySpeciesFromBytes(bytes)
          : await identifySpecies(File(file.path));

      if (!mounted) return;

      if (result['status'] == "ERROR") {
        final errorMessage = result['message']?.toString().trim();
        setState(() {
          _message = (errorMessage != null && errorMessage.isNotEmpty)
              ? errorMessage
              : "Failed to connect to AI. Please try again.";
          _isLoading = false;
        });
        return;
      }

      // 3. Handle the 3 specific cases
      setState(() {
        _isLoading = false;

        // Case 3: Not an animal
        if (result['status'] == "NOT_ANIMAL") {
          _message =
              "Please do not upload unrelated images. Please upload a clear photo of an animal.";
        }
        // Case 2: Blurry or uncertain
        else if (result['status'] == "UNCLEAR") {
          _message =
              "Cannot identify the exact species due to blur or low quality. Please provide a better quality photo.";
        }
        // Successful AI identification, now check local DB
        else if (result['status'] == "SUCCESS") {
          final geminiCommonName =
              result['commonName']?.toString().toLowerCase() ?? '';

          Species? matchedSpecies;
          try {
            matchedSpecies = speciesData.firstWhere(
              (s) => s.commonName.toLowerCase() == geminiCommonName,
            );
          } catch (e) {
            matchedSpecies = null;
          }

          if (matchedSpecies != null) {
            final expectedCategory = widget.expectedCategory;
            if (expectedCategory != null &&
                matchedSpecies.category.toLowerCase() !=
                    expectedCategory.toLowerCase()) {
              _message =
                  'This looks like ${matchedSpecies.category}, but your mission requires $expectedCategory. Please upload a matching species photo.';
              return;
            }
            _predicted = matchedSpecies;
            _confidence = 0.95;
            _message = 'Identification completed successfully.';
          } else {
            // Case 1: Identified, but not in our database
            _message =
                "Sorry, I cannot identify this as a supported wildlife species in our database. Please try a different photo.";
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message =
            'Recognition failed unexpectedly. Please retry with another image.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final canPop = Navigator.of(context).canPop();
    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 42 * s, 16 * s, 8 * s),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canPop)
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      if (canPop) SizedBox(height: 4 * s),
                      Text(
                        'Species\nRecognition',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: Adaptive.clamp(context, 34, min: 24, max: 40),
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Identify wildlife from photos',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: AppColors.textSubtitleOnFrost,
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * s,
                          vertical: 14 * s,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Upload a clear photo of an animal for AI-powered species identification.\nWell-lit, focused images work best.',
                        ),
                      ),
                    ],
                  ),
                ],
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

                // NEW: Clear Loading Card
                if (_isLoading) ...[SizedBox(height: 12 * s), _loadingCard()],

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
                                ? Image.file(
                                    File(_imageFile!.path),
                                    fit: BoxFit.cover,
                                  )
                                : const ColoredBox(color: Colors.black12)),
                    ),
                  ),
                ],

                // NEW: Show rejection/error messages when prediction fails
                if (!_isLoading && _message != null && _predicted == null) ...[
                  SizedBox(height: 12 * s),
                  _statusCard(),
                ],

                // SUCCESS: Show the recognized species
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
      color: AppColors.surface.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? AppColors.primary.withValues(alpha: 0.34)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.lightSage.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 42),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade700,
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
      ),
    );
  }

  // --- NEW WIDGET: Replaces the subtle LinearProgressIndicator ---
  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Analyzing image with KaChak AI...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW WIDGET: Shows Rejections and Errors ---
  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message ?? 'An error occurred.',
              style: TextStyle(
                color: Colors.red.shade900,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.95,
                  child: Image.asset(
                    'assets/images/identify_tips_right.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tips for best results',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _tipRow(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Use good lighting',
                    subtitle: 'Natural light works best.',
                  ),
                  const SizedBox(height: 12),
                  _tipRow(
                    icon: Icons.center_focus_strong_rounded,
                    title: 'Keep the animal centered',
                    subtitle: 'Make sure it\'s clearly visible.',
                  ),
                  const SizedBox(height: 12),
                  _tipRow(
                    icon: Icons.blur_off_rounded,
                    title: 'Avoid blurry photos',
                    subtitle: 'Steady hands or zoom in gently.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lightSage.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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
        border: Border.all(
          color: uncertain ? Colors.orange.shade300 : Colors.green.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prediction',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _predicted!.commonName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            _predicted!.scientificName,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(_predicted!.description),

          if (_message != null) ...[const SizedBox(height: 8), Text(_message!)],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      SpeciesDetailScreen(speciesId: _predicted!.id),
                ),
              );
            },
            child: const Text('Open species details'),
          ),
          if (widget.allowMissionProofReturn) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(_predicted),
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Use as mission proof'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
