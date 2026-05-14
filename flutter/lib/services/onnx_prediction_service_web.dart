import 'package:flutter/foundation.dart';

class OnnxPredictionService {
  static Future<void> initModel() async {
    debugPrint('Web build detected. ONNX runtime is disabled on web.');
  }

  static void release() {
    // No native resources to release on web.
  }

  static Future<double?> getPrediction({
    required double lat,
    required double lon,
    required double temperature,
    required double rainfall,
    required double humidity,
    required double windSpeed,
    required int occ30d,
    required String animalClass,
  }) async {
    // Web fallback: ONNX FFI is unavailable in JS builds.
    return null;
  }
}
