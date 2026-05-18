// Platform-aware export for ONNX prediction service.
// Uses web implementation in browser builds and native implementation
// for mobile/desktop IO targets.
export 'onnx_prediction_service_web.dart'
    if (dart.library.io) 'onnx_prediction_service_native.dart';