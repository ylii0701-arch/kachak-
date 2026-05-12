// ignore_for_file: depend_on_referenced_packages — `image` is declared in pubspec.yaml; analyzer sometimes mis-resolves.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Port of the `imageTest` Android demo: sharpness, exposure, contrast, and
/// edge-based subject framing — runs off the UI thread via [compute].
const int _kAnalysisMaxSize = 640;

const double _staticSharpnessWeight = 0.45;
const double _staticExposureWeight = 0.30;
const double _staticContrastWeight = 0.25;

const double _goodScoreThreshold = 80;
const double _acceptableScoreThreshold = 65;

class QualityResult {
  const QualityResult({
    required this.totalScore,
    required this.sharpness,
    required this.exposure,
    required this.contrast,
    required this.subject,
    required this.mainIssue,
    required this.statusText,
  });

  final double totalScore;
  final double sharpness;
  final double exposure;
  final double contrast;
  final SubjectResult subject;
  final String mainIssue;
  final String statusText;
}

class SubjectResult {
  const SubjectResult({
    required this.score,
    required this.isDetected,
    required this.centerX,
    required this.centerY,
    required this.sizeRatio,
    required this.message,
  });

  final double score;
  final bool isDetected;
  final double centerX;
  final double centerY;
  final double sizeRatio;
  final String message;
}

class _LumaFrame {
  _LumaFrame({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;
  final Uint8List pixels;
}

Future<QualityResult> analyzePhotoQuality(Uint8List bytes) async {
  return compute(_analyzeInIsolate, bytes);
}

QualityResult _analyzeInIsolate(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return const QualityResult(
      totalScore: 0,
      sharpness: 0,
      exposure: 0,
      contrast: 0,
      subject: SubjectResult(
        score: 0,
        isDetected: false,
        centerX: 0.5,
        centerY: 0.5,
        sizeRatio: 0,
        message: 'Image could not be decoded.',
      ),
      mainIssue: 'Image could not be decoded.',
      statusText: 'Image could not be decoded.',
    );
  }

  final frame = _toLumaFrame(decoded, maxSize: _kAnalysisMaxSize);
  return _calculate(frame);
}

_LumaFrame _toLumaFrame(img.Image image, {required int maxSize}) {
  final sourceWidth = image.width;
  final sourceHeight = image.height;
  final longest = math.max(sourceWidth, sourceHeight);
  final sampleStep = math.max(1, longest ~/ maxSize);

  final sampledWidth = sourceWidth ~/ sampleStep;
  final sampledHeight = sourceHeight ~/ sampleStep;

  if (sampledWidth <= 0 || sampledHeight <= 0) {
    return _LumaFrame(width: 0, height: 0, pixels: Uint8List(0));
  }

  final pixels = Uint8List(sampledWidth * sampledHeight);
  var dst = 0;
  for (var y = 0; y < sampledHeight; y++) {
    final sy = y * sampleStep;
    for (var x = 0; x < sampledWidth; x++) {
      final sx = x * sampleStep;
      final pixel = image.getPixel(sx, sy);
      final luma =
          (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      pixels[dst++] = luma.clamp(0, 255);
    }
  }

  return _LumaFrame(
    width: sampledWidth,
    height: sampledHeight,
    pixels: pixels,
  );
}

QualityResult _calculate(_LumaFrame frame) {
  final sharpness = _sharpnessScore(frame);
  final exposure = _exposureScore(frame);
  final contrast = _contrastScore(frame);
  final subject = _subjectPosition(frame);

  final total =
      (_staticSharpnessWeight * sharpness +
              _staticExposureWeight * exposure +
              _staticContrastWeight * contrast)
          .clamp(0, 100)
          .toDouble();

  final issue = _findMainIssue(
    sharpness: sharpness,
    exposure: exposure,
    contrast: contrast,
  );

  return QualityResult(
    totalScore: total,
    sharpness: sharpness,
    exposure: exposure,
    contrast: contrast,
    subject: subject,
    mainIssue: issue,
    statusText: _statusText(total, issue),
  );
}

double _sharpnessScore(_LumaFrame frame) {
  final w = frame.width;
  final h = frame.height;
  final p = frame.pixels;
  if (w < 3 || h < 3) return 0;

  var sum = 0.0;
  var sumSq = 0.0;
  var count = 0;
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final i = y * w + x;
      final laplacian =
          4 * p[i] - p[i - 1] - p[i + 1] - p[i - w] - p[i + w];
      sum += laplacian;
      sumSq += laplacian * laplacian;
      count++;
    }
  }
  if (count == 0) return 0;
  final mean = sum / count;
  final variance = sumSq / count - mean * mean;
  return _normalize(variance, bad: 20, good: 500);
}

double _exposureScore(_LumaFrame frame) {
  final p = frame.pixels;
  if (p.isEmpty) return 0;

  var sum = 0.0;
  var tooDark = 0;
  var tooBright = 0;
  for (final value in p) {
    sum += value;
    if (value < 20) tooDark++;
    if (value > 235) tooBright++;
  }
  final mean = sum / p.length;
  final darkRatio = tooDark / p.length;
  final brightRatio = tooBright / p.length;
  final meanScore = 100.0 - (mean - 128).abs() / 128 * 100;
  final clipping = (darkRatio + brightRatio) * 120;
  return (meanScore - clipping).clamp(0, 100).toDouble();
}

double _contrastScore(_LumaFrame frame) {
  final p = frame.pixels;
  if (p.isEmpty) return 0;

  var sum = 0.0;
  for (final value in p) {
    sum += value;
  }
  final mean = sum / p.length;
  var varianceSum = 0.0;
  for (final value in p) {
    final diff = value - mean;
    varianceSum += diff * diff;
  }
  final stdDev = math.sqrt(varianceSum / p.length);
  return _normalize(stdDev, bad: 15, good: 70);
}

SubjectResult _subjectPosition(_LumaFrame frame) {
  final w = frame.width;
  final h = frame.height;
  final p = frame.pixels;
  if (w < 3 || h < 3) {
    return const SubjectResult(
      score: 0,
      isDetected: false,
      centerX: 0.5,
      centerY: 0.5,
      sizeRatio: 0,
      message: 'No clear subject detected.',
    );
  }

  var gradientSum = 0.0;
  var gradientCount = 0;
  for (var y = 1; y < h - 1; y += 2) {
    for (var x = 1; x < w - 1; x += 2) {
      gradientSum += _localGradient(p, w, x, y);
      gradientCount++;
    }
  }
  if (gradientCount == 0) {
    return const SubjectResult(
      score: 0,
      isDetected: false,
      centerX: 0.5,
      centerY: 0.5,
      sizeRatio: 0,
      message: 'No clear subject detected.',
    );
  }

  final meanGradient = gradientSum / gradientCount;
  final threshold = math.max(18.0, meanGradient * 1.8);

  var minX = w;
  var maxX = -1;
  var minY = h;
  var maxY = -1;

  var strongEdges = 0;
  var weightSum = 0.0;
  var weightedX = 0.0;
  var weightedY = 0.0;

  for (var y = 1; y < h - 1; y += 2) {
    for (var x = 1; x < w - 1; x += 2) {
      final g = _localGradient(p, w, x, y);
      if (g > threshold) {
        strongEdges++;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        weightSum += g;
        weightedX += x * g;
        weightedY += y * g;
      }
    }
  }

  final minEdgesNeeded = (w * h * 0.002).toInt();
  if (strongEdges < minEdgesNeeded || weightSum <= 0) {
    return const SubjectResult(
      score: 0,
      isDetected: false,
      centerX: 0.5,
      centerY: 0.5,
      sizeRatio: 0,
      message:
          'No clear subject detected. Try moving closer or choosing a cleaner background.',
    );
  }

  final centerX = (weightedX / weightSum) / w;
  final centerY = (weightedY / weightSum) / h;
  final boxWidth = maxX - minX + 1;
  final boxHeight = maxY - minY + 1;
  final sizeRatio = (boxWidth * boxHeight) / (w * h);

  final centerScore = _centerScore(centerX, centerY);
  final sizeScore = _subjectSizeScore(sizeRatio);
  final finalScore = (0.7 * centerScore + 0.3 * sizeScore).clamp(0, 100).toDouble();

  return SubjectResult(
    score: finalScore,
    isDetected: true,
    centerX: centerX,
    centerY: centerY,
    sizeRatio: sizeRatio,
    message: _subjectMessage(centerX, centerY, sizeRatio, finalScore),
  );
}

double _localGradient(Uint8List pixels, int width, int x, int y) {
  final i = y * width + x;
  final center = pixels[i];
  return (center - pixels[i - 1]).abs() +
      (center - pixels[i + 1]).abs() +
      (center - pixels[i - width]).abs() +
      (center - pixels[i + width]).abs().toDouble();
}

double _centerScore(double cx, double cy) {
  final dx = cx - 0.5;
  final dy = cy - 0.5;
  final distance = math.sqrt(dx * dx + dy * dy);
  final normalized = distance / 0.7071;
  return (100 - normalized * 100).clamp(0, 100).toDouble();
}

double _subjectSizeScore(double sizeRatio) {
  if (sizeRatio < 0.04) {
    return _normalize(sizeRatio, bad: 0, good: 0.04);
  }
  if (sizeRatio > 0.75) {
    return (100 - ((sizeRatio - 0.75) / 0.25 * 60)).clamp(40, 100).toDouble();
  }
  return 100;
}

String _subjectMessage(
  double cx,
  double cy,
  double sizeRatio,
  double score,
) {
  if (sizeRatio < 0.04) {
    return 'Subject may be too small. Move closer before capturing.';
  }
  if (sizeRatio > 0.75) {
    return 'Subject may be too close. Move back slightly.';
  }
  if (cx < 0.35) {
    return 'Subject is too far left. Re-center it before capturing.';
  }
  if (cx > 0.65) {
    return 'Subject is too far right. Re-center it before capturing.';
  }
  if (cy < 0.30) {
    return 'Subject is near the top. Re-center it vertically.';
  }
  if (cy > 0.70) {
    return 'Subject is near the bottom. Re-center it vertically.';
  }
  if (score >= 75) {
    return 'Subject appears reasonably centered.';
  }
  return 'Subject position is acceptable, but it could be more centered.';
}

String _findMainIssue({
  required double sharpness,
  required double exposure,
  required double contrast,
}) {
  if (sharpness < 45) {
    return 'Image looks blurry. Move closer or keep steady.';
  }
  if (exposure < 45) {
    return 'Lighting is poor. The image may be too dark or too bright.';
  }
  if (contrast < 45) {
    return 'Low contrast. The image may look flat.';
  }
  return 'Image quality is moderate.';
}

String _statusText(double total, String mainIssue) {
  if (total >= _goodScoreThreshold) {
    return 'Good image quality. Ready to capture.';
  }
  if (total >= _acceptableScoreThreshold) {
    return 'Image quality is acceptable. Keep steady.';
  }
  return mainIssue;
}

double _normalize(double value, {required double bad, required double good}) {
  if (good == bad) return 0;
  return ((value - bad) / (good - bad) * 100).clamp(0, 100).toDouble();
}
