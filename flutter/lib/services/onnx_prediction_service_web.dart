@JS()

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

// ------------------------------------------------------------------
// 🟢 JS Interop Bindings: Connecting Dart to the Web ONNX Runtime
// ------------------------------------------------------------------

@JS('ort.Tensor')
extension type OrtTensor._(JSObject _) implements JSObject {
  external factory OrtTensor(JSString type, JSAny data, JSArray<JSNumber> dims);
}

@JS('ort.InferenceSession')
extension type OrtSession._(JSObject _) implements JSObject {
  external static JSPromise create(JSUint8Array buffer);
  external JSPromise run(JSObject feeds);
}

class OnnxPredictionService {
  static OrtSession? _session;
  static const String _inputName = 'float_input';

  /// 1. Initialize the ONNX runtime on the Web
  static Future<void> initModel() async {
    if (_session != null) return;

    try {
      _configureWebRuntimeForStability();

      // Load the model file from local assets
      final rawAssetFile = await rootBundle.load('assets/models/prediction_model.onnx');
      final bytes = rawAssetFile.buffer.asUint8List();

      // Convert Dart Uint8List to JavaScript Uint8Array
      final jsBytes = bytes.toJS;

      // Call JavaScript: ort.InferenceSession.create(bytes)
      final promise = OrtSession.create(jsBytes);
      _session = (await promise.toDart) as OrtSession;

      debugPrint("✅ Web ONNX Model loaded successfully via WebAssembly!");
    } catch (e) {
      debugPrint("❌ Failed to load Web ONNX Model: $e");
    }
  }

  static void _configureWebRuntimeForStability() {
    try {
      final ort = globalContext['ort'];
      if (ort == null || !ort.isA<JSObject>()) return;
      final ortObj = ort as JSObject;
      final env = ortObj['env'];
      if (env == null || !env.isA<JSObject>()) return;
      final envObj = env as JSObject;
      final wasm = envObj['wasm'];
      if (wasm == null || !wasm.isA<JSObject>()) return;
      final wasmObj = wasm as JSObject;

      // iOS WebKit is sensitive to heavy WASM threading/proxy modes.
      wasmObj['numThreads'] = 1.toJS;
      wasmObj['proxy'] = false.toJS;
      wasmObj['simd'] = false.toJS;
    } catch (_) {
      // Best-effort runtime tuning only; ignore if unavailable.
    }
  }

  /// 2. Release resources
  static void release() {
    // JavaScript's Garbage Collector handles memory on the web,
    // so we just nullify the session reference.
    _session = null;
  }

  /// 3. Execute inference using the WebAssembly ONNX Runtime
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
      await initModel();
      if (_session == null) {
        debugPrint("⚠️ Web ONNX Model is not initialized yet.");
        return null;
      }
    }

    // --- Spatial & Temporal Preprocessing ---
    double latBin = (lat * 2).roundToDouble();
    double lonBin = (lon * 2).roundToDouble();
    double occ30dLog = math.log(1 + occ30d);

    // --- One-Hot Encoding ---
    double isAmphibia = 0.0, isAves = 0.0, isMammalia = 0.0, isReptilia = 0.0, isInsecta = 0.0;

    switch (animalClass.toLowerCase()) {
      case 'amphibians': case 'amphibia': isAmphibia = 1.0; break;
      case 'birds': case 'aves': isAves = 1.0; break;
      case 'mammals': case 'mammalia': isMammalia = 1.0; break;
      case 'reptiles': case 'reptilia': isReptilia = 1.0; break;
      case 'insects': case 'insecta': isInsecta = 1.0; break;
      default: isMammalia = 1.0;
    }

    final List<double> inputFeatures = [
      latBin, lonBin, temperature, rainfall, humidity, windSpeed, occ30dLog,
      isAmphibia, isAves, isMammalia, isReptilia, isInsecta
    ];

    try {
      // Force convert to 32-bit float array and bridge to JavaScript
      final float32Inputs = Float32List.fromList(inputFeatures);
      final jsFloat32Array = float32Inputs.toJS;
      final dims = [1.toJS, 12.toJS].toJS;

      // Create JS Tensor: new ort.Tensor('float32', data, [1, 12])
      final tensor = OrtTensor('float32'.toJS, jsFloat32Array, dims);

      // Construct feeds JS object: { 'float_input': tensor }
      final feeds = JSObject();
      feeds[_inputName] = tensor;

      // Run inference
      final runPromise = _session!.run(feeds);
      final results = (await runPromise.toDart) as JSObject;

      double? finalProbability;

      // 🟢 Extract outputs dynamically using Object.values(results)
      final jsObject = globalContext['Object'] as JSObject;
      final valuesArray = jsObject.callMethod('values'.toJS, results) as JSArray;
      final tensors = valuesArray.toDart;

      // 🟢 Web Universal Parser: Map JavaScript TypedArrays back to Dart
      if (tensors.length > 1) {
        final probTensor = tensors[1] as JSObject;
        final probData = probTensor['data'];

        if (probData != null) {
          if (probData.isA<JSFloat32Array>()) {
            final list = (probData as JSFloat32Array).toDart;
            if (list.length > 1) {
              finalProbability = list[1].toDouble();
            } else if (list.isNotEmpty) {
              finalProbability = list[0].toDouble();
            }
          } else if (probData.isA<JSFloat64Array>()) {
            final list = (probData as JSFloat64Array).toDart;
            if (list.length > 1) {
              finalProbability = list[1].toDouble();
            } else if (list.isNotEmpty) {
              finalProbability = list[0].toDouble();
            }
          } else if (probData.isA<JSArray>()) {
            final list = (probData as JSArray).toDart;
            if (list.isNotEmpty) {
              final first = list[0];
              if (first.isA<JSObject>()) {
                // Array of Map/Dict format
                final dict = first as JSObject;
                final prob1 = dict['1'] ?? dict['1.0'];
                if (prob1 != null && prob1.isA<JSNumber>()) {
                  finalProbability = (prob1 as JSNumber).toDartDouble;
                }
              } else if (first.isA<JSNumber>()) {
                if (list.length > 1) {
                  finalProbability = (list[1] as JSNumber).toDartDouble;
                } else {
                  finalProbability = (first as JSNumber).toDartDouble;
                }
              }
            }
          }
        }
      }

      return finalProbability;

    } catch (e) {
      debugPrint("❌ Web ONNX Inference Error: $e");
      return null;
    }
  }
}