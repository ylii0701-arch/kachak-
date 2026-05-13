import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

class OnnxPredictionService {
  static OrtSession? _session;
  static const String _inputName = 'float_input';

  static Future<void> initModel() async {
    if (_session != null) return;

    try {
      OrtEnv.instance.init();
      final rawAssetFile = await rootBundle.load('assets/models/prediction_model.onnx');
      final bytes = rawAssetFile.buffer.asUint8List();
      _session = OrtSession.fromBuffer(bytes, OrtSessionOptions());
      debugPrint('ONNX model loaded successfully.');
    } catch (e) {
      debugPrint('Failed to load ONNX model: $e');
    }
  }

  static void release() {
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
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
    if (_session == null) {
      debugPrint('ONNX model is not initialized yet.');
      return null;
    }

    final double latBin = (lat * 2).roundToDouble();
    final double lonBin = (lon * 2).roundToDouble();
    final double occ30dLog = math.log(1 + occ30d);

    double isAmphibia = 0.0;
    double isAves = 0.0;
    double isMammalia = 0.0;
    double isReptilia = 0.0;
    double isInsecta = 0.0;

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
        isMammalia = 1.0;
    }

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
      isInsecta,
    ];

    try {
      final float32Inputs = Float32List.fromList(inputFeatures);
      final inputOrtValue = OrtValueTensor.createTensorWithDataList(
        float32Inputs,
        [1, inputFeatures.length],
      );

      final runOptions = OrtRunOptions();
      final inputs = {_inputName: inputOrtValue};
      final List<OrtValue?> outputs = _session!.run(runOptions, inputs);

      inputOrtValue.release();
      runOptions.release();

      double? finalProbability;

      if (outputs.length > 1) {
        final probTensor = outputs[1]?.value;

        if (probTensor is List && probTensor.isNotEmpty) {
          final firstElement = probTensor[0];

          if (firstElement is List) {
            if (firstElement.length > 1) {
              finalProbability = (firstElement[1] as num?)?.toDouble();
            } else if (firstElement.isNotEmpty) {
              finalProbability = (firstElement[0] as num?)?.toDouble();
            }
          } else if (firstElement is Map) {
            finalProbability = (firstElement[1] ??
                        firstElement[1.0] ??
                        firstElement['1'] as num?)
                    ?.toDouble();
          } else if (firstElement is num) {
            if (probTensor.length > 1) {
              finalProbability = (probTensor[1] as num).toDouble();
            } else {
              finalProbability = firstElement.toDouble();
            }
          }
        }
      }

      for (final element in outputs) {
        element?.release();
      }

      return finalProbability;
    } catch (e) {
      debugPrint('ONNX inference error: $e');
      return null;
    }
  }
}
