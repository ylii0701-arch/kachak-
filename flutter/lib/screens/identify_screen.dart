import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
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
      color: AppColors.detailBackdrop,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 42 * s, 16 * s, 8 * s),
              child: GlassPanel(
                padding: EdgeInsets.all(16 * s),
                borderRadius: 22 * s,
                fillAlpha: 0.45,
                child: Column(
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
                      'Species Recognition',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Adaptive.clamp(context, 28, min: 22, max: 34),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1.05,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 4 * s),
                    Text(
                      'Identify wildlife from photos',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.35,
                        height: 1.35,
                        color: const Color(0xFF5C6B63),
                      ),
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
                style: const TextStyle(
                  fontSize: 30 / 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tips for Best Results',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
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
