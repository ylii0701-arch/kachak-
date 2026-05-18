// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

/// Requests browser camera permission using `getUserMedia`.
Future<bool> requestWebCameraPermission() async {
  if (html.window.isSecureContext != true) return false;
  final mediaDevices = html.window.navigator.mediaDevices;
  if (mediaDevices == null) return false;
  try {
    final stream = await mediaDevices.getUserMedia(
      <String, dynamic>{'video': true, 'audio': false},
    );
    for (final track in stream.getTracks()) {
      track.stop();
    }
    return true;
  } catch (_) {
    return false;
  }
}

/// Requests browser notification permission.
Future<bool> requestWebNotificationPermission() async {
  if (!html.Notification.supported) return false;
  final permission = await html.Notification.requestPermission();
  return permission == 'granted';
}

/// Shows a foreground browser notification when permission is granted.
Future<bool> showWebNotification({
  required String title,
  required String body,
}) async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission != 'granted') return false;
  html.Notification(title, body: body);
  return true;
}
