// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

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

Future<bool> requestWebNotificationPermission() async {
  if (!html.Notification.supported) return false;
  final permission = await html.Notification.requestPermission();
  return permission == 'granted';
}

Future<bool> showWebNotification({
  required String title,
  required String body,
}) async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission != 'granted') return false;
  html.Notification(title, body: body);
  return true;
}
