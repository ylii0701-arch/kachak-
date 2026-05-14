import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // 🟢 Import debugPrint
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

class OnnxPredictionService {
  static OrtSession? _session;

  // The input node name defined during Python conversion (usually 'float_input')
  static const String _inputName = 'float_input';

  /// 1. Initialize the ONNX runtime and load the model.
  /// This should ideally be called once during app startup (in main.dart).
  static Future<void> initModel() async {
    if (_session != null) return;

    try {
      // Initialize the ONNX environment
      OrtEnv.instance.init();

      // Load the model file from local assets
      // Note: Ensure 'assets/models/prediction_model.onnx' matches your pubspec.yaml exactly
      final rawAssetFile = await rootBundle.load('assets/models/prediction_model.onnx');
      final bytes = rawAssetFile.buffer.asUint8List();

      // Create the execution session
      _session = OrtSession.fromBuffer(bytes, OrtSessionOptions());
      debugPrint("✅ ONNX Model loaded successfully!");
    } catch (e) {
      debugPrint("❌ Failed to load ONNX Model: $e");
    }
  }

  /// 2. Release resources when the app is terminated.
  static void release() {
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
  }

  /// 3. Execute local inference using the ONNX model.
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
    if (_session == null) {
      debugPrint("⚠️ ONNX Model is not initialized yet.");
      return null;
    }

    // --- Spatial & Temporal Preprocessing ---
    double latBin = (lat * 2).roundToDouble();
    double lonBin = (lon * 2).roundToDouble();
    // np.log1p(x) equivalent in Dart
    double occ30dLog = math.log(1 + occ30d);

    // --- One-Hot Encoding for Species Classes ---
    // Initialize all to 0.0
    double isAmphibia = 0.0;
    double isAves = 0.0;
    double isMammalia = 0.0;
    double isReptilia = 0.0;
    double isInsecta = 0.0;

    // Match the exact 5 classes used in the Colab training script
    switch (animalClass.toLowerCase()) {
      case 'amphibians':
      case 'amphibia':
        isAmphibia = 1.0;
        break;
      case 'birds':
      case 'aves':
        isAves = 1.0;
        break;
      case 'mammals':
      case 'mammalia':
        isMammalia = 1.0;
        break;
      case 'reptiles':
      case 'reptilia':
        isReptilia = 1.0;
        break;
      case 'insects':
      case 'insecta':
        isInsecta = 1.0;
        break;
      default:
      // Safe fallback if an unknown class is passed
        isMammalia = 1.0;
    }

    // --- Construct the Feature Array ---
    // CRITICAL: The order MUST perfectly match the DataFrame columns in Python:
    // ["lat_bin", "lon_bin", "temperature", "rainfall", "humidity", "wind_speed", "occ_30d",
    //  "animal_class_Amphibia", "animal_class_Aves", "animal_class_Mammalia", "animal_class_Reptilia", "animal_class_Insecta"]
    final List<double> inputFeatures = [
      latBin,
      lonBin,
      temperature,
      rainfall,
      humidity,
      windSpeed,
      occ30dLog,
      isAmphibia,
      isAves,
      isMammalia,
      isReptilia,
      isInsecta
    ];

    try {
      // Force convert Dart's default 64-bit double to a 32-bit float array
      final float32Inputs = Float32List.fromList(inputFeatures);

      // Create an input tensor (Shape: [1, 12] - 1 row, 12 features)
      final inputOrtValue = OrtValueTensor.createTensorWithDataList(
        float32Inputs, // Pass the converted 32-bit array
        [1, inputFeatures.length],
      );

      final runOptions = OrtRunOptions();
      final inputs = {_inputName: inputOrtValue};

      // ---------------------------------------------------------
      // Changed return type to List<OrtValue?> to match onnxruntime ^1.4.1
      // ---------------------------------------------------------
      final List<OrtValue?> outputs = _session!.run(runOptions, inputs);

      // Clean up input memory immediately
      inputOrtValue.release();
      runOptions.release();

      double? finalProbability;

      // 🟢 Universal Parser: Extract the predicted probability from ONNX output
      if (outputs.length > 1) {
        final probTensor = outputs[1]?.value;

        if (probTensor is List && probTensor.isNotEmpty) {
          final firstElement = probTensor[0];

          if (firstElement is List) {
            // Case A: Nested list received (e.g., [[0.2, 0.85]])
            if (firstElement.length > 1) {
              finalProbability = (firstElement[1] as num?)?.toDouble();
            } else if (firstElement.isNotEmpty) {
              finalProbability = (firstElement[0] as num?)?.toDouble();
            }
          } else if (firstElement is Map) {
            // Case B: Dictionary/Map received (e.g., [{0: 0.2, 1: 0.85}])
            finalProbability = (firstElement[1] ?? firstElement[1.0] ?? firstElement['1'] as num?)?.toDouble();
          } else if (firstElement is num) {
            // Case C: 1D List received (e.g., [0.2, 0.85])
            if (probTensor.length > 1) {
              finalProbability = (probTensor[1] as num).toDouble();
            } else {
              finalProbability = firstElement.toDouble();
            }
          }
        }
      }

      // CRITICAL: Release output tensors to prevent memory leaks in mobile apps
      for (var element in outputs) {
        element?.release();
      }

      return finalProbability;

    } catch (e) {
      debugPrint("❌ ONNX Inference Error: $e");
      return null;
    }
  }
}
