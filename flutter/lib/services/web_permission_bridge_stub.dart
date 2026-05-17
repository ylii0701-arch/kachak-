Future<bool> requestWebCameraPermission() async => true;

Future<bool> requestWebNotificationPermission() async => false;

Future<bool> showWebNotification({
  required String title,
  required String body,
}) async =>
    false;
