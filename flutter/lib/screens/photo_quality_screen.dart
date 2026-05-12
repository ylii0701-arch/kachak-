import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/photo_quality_analyzer.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';

/// Standalone screen for on-device photo quality scoring.
/// Opened only from the side menu — does not alter other app flows.
class PhotoQualityScreen extends StatefulWidget {
  const PhotoQualityScreen({super.key});

  @override
  State<PhotoQualityScreen> createState() => _PhotoQualityScreenState();
}

class _PhotoQualityScreenState extends State<PhotoQualityScreen> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imagePath;
  bool _isAnalyzing = false;
  QualityResult? _result;
  String? _errorMessage;

  Future<void> _pick(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 92,
    );
    if (file == null) return;

    setState(() {
      _isAnalyzing = true;
      _imagePath = file.path;
      _imageBytes = null;
      _result = null;
      _errorMessage = null;
    });

    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
      final result = await analyzePhotoQuality(bytes);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Failed to analyze image. Please try again.';
      });
    }
  }

  void _clear() {
    setState(() {
      _imageBytes = null;
      _imagePath = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DetailPageBackdrop(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 0),
                    child: Row(
                      children: [
                        Material(
                          color: AppColors.surface.withValues(alpha: 0.94),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Back',
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.accent,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 8 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo quality',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: Adaptive.clamp(
                              context,
                              34,
                              min: 26,
                              max: 40,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Text(
                          'Score sharpness, exposure, contrast and subject framing.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: AppColors.textSubtitleOnFrost,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 32 * s),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _actionCard(
                        title: 'Capture photo',
                        subtitle: 'Use your camera',
                        icon: Icons.photo_camera_outlined,
                        highlighted: false,
                        onTap: _isAnalyzing
                            ? null
                            : () => _pick(ImageSource.camera),
                      ),
                      SizedBox(height: 12 * s),
                      _actionCard(
                        title: 'Upload photo',
                        subtitle: 'Pick from gallery',
                        icon: Icons.upload_rounded,
                        highlighted: true,
                        onTap: _isAnalyzing
                            ? null
                            : () => _pick(ImageSource.gallery),
                      ),
                      if (_isAnalyzing) ...[
                        SizedBox(height: 12 * s),
                        _loadingCard(),
                      ],
                      if (_imageBytes != null) ...[
                        SizedBox(height: 12 * s),
                        _previewCard(),
                      ],
                      if (_result != null) ...[
                        SizedBox(height: 12 * s),
                        _resultCard(_result!),
                      ],
                      if (_errorMessage != null) ...[
                        SizedBox(height: 12 * s),
                        _errorCard(_errorMessage!),
                      ],
                    ]),
                  ),
                ),
              ],
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
    required VoidCallback? onTap,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.lightSage.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 38),
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
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.iconSectionOnFrost,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Analyzing…',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
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

  Widget _resultCard(QualityResult r) {
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
          _scoreRow('Sharpness', r.sharpness),
          const SizedBox(height: 10),
          _scoreRow('Exposure', r.exposure),
          const SizedBox(height: 10),
          _scoreRow('Contrast', r.contrast),
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clear,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Try another',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, double value) {
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
      ],
    );
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

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB14A3A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
