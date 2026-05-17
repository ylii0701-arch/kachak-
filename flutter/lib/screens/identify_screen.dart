import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../services/gemini_recognition_service.dart';
import '../services/photo_quality_analyzer.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../utils/image_validator.dart';
import 'species_detail_screen.dart';

enum _RecognitionTool { species, quality }

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({
    super.key,
    this.expectedCategory,
    this.allowMissionProofReturn = false,
    this.startInQualityMode = false,
  });

  final String? expectedCategory;
  final bool allowMissionProofReturn;
  final bool startInQualityMode;

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen>
    with SingleTickerProviderStateMixin {
  static const double _speciesCardMinHeight = 236;

  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;
  Uint8List? _imageBytes;
  String? _imagePath;

  Species? _predicted;
  double? _confidence;
  QualityResult? _qualityResult;
  String? _message;
  bool _isLoading = false;
  DateTime? _loadingStartedAt;

  // Set to true only for dev testing internet images.
  final bool _bypassExifCheck = true;

  late _RecognitionTool _tool;
  bool _slideForward = true;
  late final AnimationController _skeletonController;
  Timer? _progressTimer;
  double _perceivedProgress = 0;

  bool get _isMissionMode =>
      widget.expectedCategory != null || widget.allowMissionProofReturn;

  @override
  void initState() {
    super.initState();
    _tool = (widget.startInQualityMode && !_isMissionMode)
        ? _RecognitionTool.quality
        : _RecognitionTool.species;
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _skeletonController.dispose();
    super.dispose();
  }

  Future<void> _chooseImageSource() async {
    if (_isLoading) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Upload from gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) return;
    await _pick(source);
  }

  Future<void> _pick(ImageSource source) async {
    final granted = await _ensurePermissionForSource(source);
    if (!granted) return;

    final file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file == null) return;

    _progressTimer?.cancel();

    setState(() {
      _imageFile = file;
      _imagePath = file.path;
      _imageBytes = null;
      _predicted = null;
      _confidence = null;
      _qualityResult = null;
      _message = null;
      _isLoading = false;
    });

    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Failed to load image. Please try another one.';
      });
    }
  }

  Future<void> _scanNow() async {
    if (_isLoading) return;
    if (_imageFile == null || _imageBytes == null) {
      setState(() {
        _message = 'Please upload or capture a photo first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _perceivedProgress = 0.02;
      _loadingStartedAt = DateTime.now();
      _predicted = null;
      _confidence = null;
      _qualityResult = null;
      _message = null;
    });
    _startPerceivedProgress();

    if (_tool == _RecognitionTool.species) {
      await _runSpeciesRecognition();
    } else {
      await _runQualityAnalysis();
    }
  }

  Future<void> _runQualityAnalysis() async {
    try {
      final bytes = _imageBytes;
      if (bytes == null) {
        await _endLoading(() {
          _message = 'Please upload or capture a photo first.';
        });
        return;
      }
      final result = await analyzePhotoQuality(bytes);
      if (!mounted) return;
      await _endLoading(
        () {
        _qualityResult = result;
        },
        minVisible: const Duration(milliseconds: 1200),
      );
    } catch (_) {
      if (!mounted) return;
      await _endLoading(
        () {
        _message = 'Failed to analyze image. Please try again.';
        },
        minVisible: const Duration(milliseconds: 1200),
      );
    }
  }

  Future<void> _runSpeciesRecognition() async {
    final file = _imageFile;
    final bytes = _imageBytes;
    if (file == null || bytes == null) {
      setState(() {
        _isLoading = false;
        _message = 'Please upload or capture a photo first.';
      });
      return;
    }

    try {
      if (!_bypassExifCheck && !kIsWeb) {
        final imageFile = File(file.path);
        final isValid = await validateLocalPhoto(imageFile);
        if (!isValid) {
          if (!mounted) return;
          await _endLoading(() {
            _message =
                'Please capture a real photo using your device camera within Malaysia.';
          });
          return;
        }
      }

      final result = kIsWeb
          ? await identifySpeciesFromBytes(bytes)
          : await identifySpecies(File(file.path));

      if (!mounted) return;

      if (result['status'] == 'ERROR') {
        final errorMessage = result['message']?.toString().trim();
        await _endLoading(() {
          _message = (errorMessage != null && errorMessage.isNotEmpty)
              ? errorMessage
              : 'Failed to connect to AI. Please try again.';
        });
        return;
      }

      await _endLoading(() {
        if (result['status'] == 'NOT_ANIMAL') {
          _message =
              'Please do not upload unrelated images. Please upload a clear photo of an animal.';
        } else if (result['status'] == 'UNCLEAR') {
          _message =
              'Cannot identify the exact species due to blur or low quality. Please provide a better quality photo.';
        } else if (result['status'] == 'SUCCESS') {
          final geminiCommonName =
              result['commonName']?.toString().toLowerCase() ?? '';

          Species? matchedSpecies;
          try {
            matchedSpecies = speciesData.firstWhere(
              (s) => s.commonName.toLowerCase() == geminiCommonName,
            );
          } catch (_) {
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
            _message =
                'Sorry, I cannot identify this as a supported wildlife species in our database. Please try a different photo.';
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      await _endLoading(() {
        _message = 'Recognition failed unexpectedly. Please retry with another image.';
      });
    }
  }

  void _switchTool(_RecognitionTool tool) {
    if (_tool == tool) return;
    final oldIndex = _toolIndex(_tool);
    final newIndex = _toolIndex(tool);
    setState(() {
      _progressTimer?.cancel();
      _perceivedProgress = 0;
      _slideForward = newIndex >= oldIndex;
      _tool = tool;
      _predicted = null;
      _confidence = null;
      _qualityResult = null;
      _message = null;
      _isLoading = false;
    });
  }

  int _toolIndex(_RecognitionTool tool) {
    switch (tool) {
      case _RecognitionTool.species:
        return 0;
      case _RecognitionTool.quality:
        return 1;
    }
  }

  void _clearAll() {
    setState(() {
      _progressTimer?.cancel();
      _perceivedProgress = 0;
      _imageFile = null;
      _imageBytes = null;
      _imagePath = null;
      _predicted = null;
      _confidence = null;
      _qualityResult = null;
      _message = null;
      _isLoading = false;
    });
  }

  Future<void> _endLoading(
    VoidCallback updateState, {
    Duration minVisible = Duration.zero,
  }) async {
    final startedAt = _loadingStartedAt;
    if (startedAt != null && minVisible > Duration.zero) {
      final elapsed = DateTime.now().difference(startedAt);
      final remaining = minVisible - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }
    }
    await _finishPerceivedProgress();
    if (!mounted) return;
    setState(() {
      updateState();
      _isLoading = false;
      _loadingStartedAt = null;
    });
  }

  void _startPerceivedProgress() {
    _progressTimer?.cancel();
    final startAt = DateTime.now();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted || !_isLoading) {
        timer.cancel();
        return;
      }
      final elapsedMs = DateTime.now().difference(startAt).inMilliseconds;
      final eased = _progressByPeakEndRule(elapsedMs);
      if (eased <= _perceivedProgress) return;
      setState(() {
        _perceivedProgress = eased;
      });
    });
  }

  Future<void> _finishPerceivedProgress() async {
    _progressTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _perceivedProgress = 1.0;
    });
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  double _progressByPeakEndRule(int elapsedMs) {
    final t = elapsedMs / 3200.0;
    if (t <= 0.35) {
      return 0.02 + (t / 0.35) * 0.72; // Fast start to ~74%
    }
    if (t <= 1.0) {
      return 0.74 + ((t - 0.35) / 0.65) * 0.21; // Slow tail to ~95%
    }
    return 0.95;
  }

  Future<bool> _ensurePermissionForSource(ImageSource source) async {
    // On web, image_picker uses the browser's native file input / camera
    // capture attribute. It handles its own permission flow — no need for
    // getUserMedia or permission_handler pre-checks.
    if (kIsWeb) return true;

    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (status.isGranted) return true;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied || status.isRestricted) {
        _showPermissionMessage(
          'Camera permission is permanently denied. Please enable it in settings.',
        );
      } else {
        _showPermissionMessage('Camera permission denied.');
      }
      return false;
    }

    PermissionStatus photosStatus = await Permission.photos.status;
    PermissionStatus storageStatus = PermissionStatus.denied;
    if (defaultTargetPlatform == TargetPlatform.android) {
      storageStatus = await Permission.storage.status;
    }

    if (photosStatus.isGranted || storageStatus.isGranted) return true;

    if (photosStatus.isDenied) {
      photosStatus = await Permission.photos.request();
    }
    if (defaultTargetPlatform == TargetPlatform.android &&
        storageStatus.isDenied) {
      storageStatus = await Permission.storage.request();
    }

    if (photosStatus.isGranted || storageStatus.isGranted) return true;

    final isPermanent = photosStatus.isPermanentlyDenied ||
        photosStatus.isRestricted ||
        storageStatus.isPermanentlyDenied ||
        storageStatus.isRestricted;

    if (isPermanent) {
      _showPermissionMessage(
        'Photo permission is permanently denied. Please enable it in settings.',
      );
    } else {
      _showPermissionMessage('Photo permission denied.');
    }
    return false;
  }

  void _showPermissionMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final canPop = Navigator.of(context).canPop();
    final title = _isMissionMode ? 'Species Recognition' : 'Image Recognition';
    final subtitle = _tool == _RecognitionTool.species
        ? 'Scan a wildlife photo with AI species identification.'
        : 'Scan your photo and get image quality scoring.';
    final rightMenuAllowance = canPop ? 0.0 : (56 * s);

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16 * s, 50 * s, 16 * s, 8 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canPop) ...[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(height: 2 * s),
                  ],
                  Padding(
                    padding: EdgeInsets.only(
                      left: 6 * s,
                      right: rightMenuAllowance,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.libreBaskerville(
                        fontSize: Adaptive.clamp(context, 29, min: 21, max: 32),
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * s),
                  if (!_isMissionMode) _toolToggle(context),
                  if (!_isMissionMode) SizedBox(height: 12 * s),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: Text(
                        subtitle,
                        key: ValueKey(_tool),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: AppColors.textSubtitleOnFrost,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 100 * s),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: _slideForward
                          ? const Offset(0.12, 0)
                          : const Offset(-0.12, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _modeContent(context, s),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolToggle(BuildContext context) {
    final selected = _tool;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              selected: selected == _RecognitionTool.species,
              label: 'Species',
              onTap: () => _switchTool(_RecognitionTool.species),
            ),
          ),
          Expanded(
            child: _toggleButton(
              selected: selected == _RecognitionTool.quality,
              label: 'Image Quality',
              onTap: () => _switchTool(_RecognitionTool.quality),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeContent(BuildContext context, double s) {
    return Column(
      key: ValueKey(_tool),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _pickerCard(),
        if (_imageBytes != null) ...[
          SizedBox(height: 12 * s),
          _previewCard(),
        ],
        SizedBox(height: 12 * s),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (_imageBytes != null && !_isLoading) ? _scanNow : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(
              _tool == _RecognitionTool.species ? 'Scan Now' : 'Score Now',
            ),
          ),
        ),
        if (_isLoading) ...[
          SizedBox(height: 12 * s),
          _loadingFeedbackCard(),
          SizedBox(height: 12 * s),
          _tool == _RecognitionTool.species
              ? _speciesResultSkeletonCard(context)
              : _qualityResultSkeletonCard(),
        ],
        if (!_isLoading &&
            _message != null &&
            _predicted == null &&
            _qualityResult == null) ...[
          SizedBox(height: 12 * s),
          _statusCard(),
        ],
        if (_tool == _RecognitionTool.species &&
            _predicted != null &&
            _confidence != null) ...[
          SizedBox(height: 12 * s),
          _speciesResultCard(context),
        ],
        if (_tool == _RecognitionTool.quality && _qualityResult != null) ...[
          SizedBox(height: 12 * s),
          _qualityResultCard(_qualityResult!),
        ],
        if (_tool == _RecognitionTool.species) ...[
          SizedBox(height: 12 * s),
          _speciesTipsCard(),
        ],
        if (_imageBytes != null && !_isLoading) ...[
          SizedBox(height: 8 * s),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try another photo'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _toggleButton({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.accent : AppColors.textSubtitleOnFrost,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerCard() {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _chooseImageSource,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 48,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to take photo or upload from gallery',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSubtitleOnFrost,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewCard() {
    final bytes = _imageBytes;
    if (bytes == null) return const SizedBox.shrink();
    final canShowFile = !kIsWeb && _imagePath != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: canShowFile
            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
            : Image.memory(bytes, fit: BoxFit.cover),
      ),
    );
  }

  Widget _loadingFeedbackCard() {
    final loadingText = _tool == _RecognitionTool.species
        ? 'Scanning species...'
        : 'Scoring photo quality...';
    final progressPct = (_perceivedProgress * 100).clamp(1, 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loadingText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              Text(
                '$progressPct%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _perceivedProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.lightSage.withValues(alpha: 0.38),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _speciesResultSkeletonCard(BuildContext context) {
    return _skeletonCard(
      minHeight: _speciesCardMinHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonLine(width: 90, height: 14),
          const SizedBox(height: 8),
          _skeletonLine(width: 170, height: 18),
          const SizedBox(height: 6),
          _skeletonLine(width: 150, height: 14),
          const SizedBox(height: 10),
          _skeletonLine(height: 12),
          const SizedBox(height: 6),
          _skeletonLine(width: MediaQuery.of(context).size.width * 0.6, height: 12),
          const SizedBox(height: 14),
          _skeletonLine(width: 160, height: 40, radius: 10),
        ],
      ),
    );
  }

  Widget _qualityResultSkeletonCard() {
    return _skeletonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonLine(width: 72, height: 12),
                    const SizedBox(height: 7),
                    _skeletonLine(width: 115, height: 40),
                  ],
                ),
              ),
              _skeletonLine(width: 54, height: 26, radius: 99),
            ],
          ),
          const SizedBox(height: 12),
          _skeletonLine(width: 230, height: 14),
          const SizedBox(height: 14),
          _metricSkeletonRow(),
          const SizedBox(height: 10),
          _metricSkeletonRow(),
          const SizedBox(height: 10),
          _metricSkeletonRow(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pageMist,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _skeletonLine(width: 24, height: 16, radius: 6),
                    const SizedBox(width: 8),
                    _skeletonLine(width: 130, height: 14),
                    const Spacer(),
                    _skeletonLine(width: 58, height: 14),
                  ],
                ),
                const SizedBox(height: 8),
                _skeletonLine(height: 12),
                const SizedBox(height: 6),
                _skeletonLine(width: 210, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricSkeletonRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _skeletonLine(width: 88, height: 13),
            const Spacer(),
            _skeletonLine(width: 24, height: 13),
          ],
        ),
        const SizedBox(height: 6),
        _skeletonLine(height: 7, radius: 99),
        const SizedBox(height: 5),
        _skeletonLine(width: 250, height: 12),
      ],
    );
  }

  Widget _skeletonCard({
    required Widget child,
    double? minHeight,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9DE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _skeletonLine({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _skeletonController,
      builder: (context, _) {
        final color = Color.lerp(
          const Color(0xFFD8E4D4),
          const Color(0xFFBFD0BC),
          _skeletonController.value,
        )!;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

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

  Widget _speciesTipsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tips for best species scan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            _tipRow(
              icon: Icons.wb_sunny_outlined,
              title: 'Use good lighting',
              subtitle: 'Natural light gives better identification.',
            ),
            const SizedBox(height: 10),
            _tipRow(
              icon: Icons.center_focus_strong_rounded,
              title: 'Keep animal centered',
              subtitle: 'Avoid cutting the animal out of frame.',
            ),
            const SizedBox(height: 10),
            _tipRow(
              icon: Icons.blur_off_rounded,
              title: 'Avoid blur',
              subtitle: 'Hold steady or tap to focus before shooting.',
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.lightSage.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _speciesResultCard(BuildContext context) {
    final uncertain = (_confidence ?? 0) < 0.6;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(minHeight: _speciesCardMinHeight),
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
          if (_message != null) ...[
            const SizedBox(height: 8),
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

  Widget _qualityResultCard(QualityResult r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.calmShadow,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total score',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          r.totalScore.toStringAsFixed(0),
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: _scoreColor(r.totalScore),
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ 100',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSubtitleOnFrost,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _scoreBadge(r.totalScore),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.statusText,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          _scoreRow('Sharpness', r.sharpness, _improveSharpnessText(r.sharpness)),
          const SizedBox(height: 10),
          _scoreRow('Exposure', r.exposure, _improveExposureText(r.exposure)),
          const SizedBox(height: 10),
          _scoreRow('Contrast', r.contrast, _improveContrastText(r.contrast)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pageMist,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.center_focus_weak_outlined,
                      size: 18,
                      color: AppColors.iconSectionOnFrost,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Subject framing',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      r.subject.isDetected
                          ? '${r.subject.score.toStringAsFixed(0)} / 100'
                          : 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.subject.message,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.textBodyOnFrost,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _improvementCard(r),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, double value, String helperText) {
    final v = value.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
            Text(
              v.toStringAsFixed(0),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: v / 100,
            minHeight: 7,
            backgroundColor: AppColors.lightSage.withValues(alpha: 0.55),
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(v)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          helperText,
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.35,
            color: AppColors.textSubtitleOnFrost,
          ),
        ),
      ],
    );
  }

  Widget _improvementCard(QualityResult r) {
    final tips = _qualityImprovementTips(r);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageMist,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to improve this photo',
            style: GoogleFonts.libreBaskerville(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          for (final tip in tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.iconSectionOnFrost,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textBodyOnFrost,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  List<String> _qualityImprovementTips(QualityResult r) {
    final tips = <String>[];
    if (r.sharpness < 65) {
      tips.add('Increase sharpness by tapping focus, keeping steady, and moving slightly closer.');
    }
    if (r.exposure < 65) {
      tips.add('Improve exposure by adding more light or avoiding strong backlight behind the subject.');
    }
    if (r.contrast < 65) {
      tips.add('Improve contrast by separating subject from background and avoiding foggy/flat lighting.');
    }
    if (!r.subject.isDetected || r.subject.score < 65) {
      tips.add('Center the subject better and let it occupy more of the frame.');
    }
    if (tips.isEmpty) {
      tips.add('Great capture. For even better results, keep the subject larger and use natural light.');
    }
    return tips.take(4).toList();
  }

  String _improveSharpnessText(double score) {
    if (score >= 80) return 'Good sharpness. Keep this steady shooting style.';
    if (score >= 65) return 'Almost there. Tap focus and reduce hand movement.';
    return 'Low sharpness. Hold steady, clean lens, and move closer to subject.';
  }

  String _improveExposureText(double score) {
    if (score >= 80) return 'Exposure is balanced for clear details.';
    if (score >= 65) return 'Slightly off. Try brighter natural light.';
    return 'Poor exposure. Avoid backlight and shoot in more even lighting.';
  }

  String _improveContrastText(double score) {
    if (score >= 80) return 'Contrast is strong and details stand out.';
    if (score >= 65) return 'Acceptable contrast. Try cleaner background separation.';
    return 'Low contrast. Change angle or background to make subject stand out.';
  }

  Widget _scoreBadge(double total) {
    final label = total >= 80
        ? 'Good'
        : total >= 65
            ? 'OK'
            : 'Low';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _scoreColor(total).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _scoreColor(total).withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: _scoreColor(total),
        ),
      ),
    );
  }

  Color _scoreColor(double v) {
    if (v >= 80) return AppColors.primary;
    if (v >= 65) return const Color(0xFFB8862E);
    return const Color(0xFFB14A3A);
  }
}
