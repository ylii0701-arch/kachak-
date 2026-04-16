import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'providers/app_shell_controller.dart';
import 'providers/saved_species_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/adaptive.dart';

// Global keys and instances for notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin localNotifs = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await localNotifs.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle when the user taps the notification
      if (response.payload != null) {
        _showNotificationDetails(response.payload!);
      }
    },
  );

  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavedSpeciesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AppShellController()),
      ],
      child: const KachakApp(),
    ),
  );
}

// Shows a dialog when a notification is tapped
void _showNotificationDetails(String payload) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('High Probability Alert!'),
      content: Text(payload), // Displays the conditions
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
    ),
  );
}

class KachakApp extends StatelessWidget {
  const KachakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KACHAK',
      navigatorKey: navigatorKey, // Required for showing the dialog from background
      debugShowCheckedModeBanner: false,
      theme: buildKachakTheme(),
      builder: (context, child) {
        final base = Theme.of(context);
        final textScale = Adaptive.clamp(context, 1, min: 0.9, max: 1.12);
        final themed = base.copyWith(
          textTheme: base.textTheme.apply(fontSizeFactor: textScale),
        );
        return Theme(data: themed, child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}