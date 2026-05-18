/// Non-web stub for camera permission API.
Future<bool> requestWebCameraPermission() async => true;

/// Non-web stub for notification permission API.
Future<bool> requestWebNotificationPermission() async => false;

/// Non-web stub for browser notification API.
Future<bool> showWebNotification({
  required String title,
  required String body,
}) async =>
    false;
