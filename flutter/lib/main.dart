import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'providers/app_shell_controller.dart';
import 'providers/locale_controller.dart';
import 'providers/saved_species_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/species_detail_screen.dart';
import 'services/onboarding_service.dart';
import 'theme/app_theme.dart';
import 'utils/adaptive.dart';
import 'services/onnx_prediction_service.dart';
import 'services/prediction_manager.dart';

/// App entrypoint and root composition for Kachak.
///
/// Responsibilities:
/// - bootstraps shared services and providers
/// - configures localization and theme
/// - initializes local notifications on native platforms
/// - defers heavy prediction startup on mobile web for stability

/// Root navigator key used by notification deep-link handling.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton notification plugin instance for native local alerts.
final FlutterLocalNotificationsPlugin localNotifs = FlutterLocalNotificationsPlugin();

/// Initializes app services, providers, and launches the widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isMobileWeb =
      kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);

  final prefs = await SharedPreferences.getInstance();
  final savedSpeciesProvider = SavedSpeciesProvider(prefs);
  PredictionManager.instance.setAlertProvider(savedSpeciesProvider);
  // Heavy inference bootstrap can crash mobile browsers. Defer there.
  if (!isMobileWeb) {
    await OnnxPredictionService.initModel();
    PredictionManager.instance.startEngine();
  } else {
    debugPrint('⚠️ Mobile web detected: deferred ONNX/prediction startup.');
  }

  // Initialize Local Notifications
  if (!kIsWeb) {
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
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: savedSpeciesProvider),
        ChangeNotifierProvider(create: (_) => AppShellController()),
        ChangeNotifierProvider(create: (_) => OnboardingService(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
      ],
      child: const KachakApp(),
    ),
  );

  // On mobile web, predictions are computed on-demand (per-species) to avoid
  // overwhelming the browser. The full engine starts lazily if ever needed.
}

/// Opens species detail when a notification payload is tapped.
void _showNotificationDetails(String payload) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SpeciesDetailScreen(speciesId: payload),
    ),
  );
}

class KachakApp extends StatelessWidget {
  const KachakApp({super.key});

  /// Builds the localized [MaterialApp] with adaptive text scaling.
  @override
  Widget build(BuildContext context) {
    final localeCtrl = context.watch<LocaleController>();
    return MaterialApp(
      title: 'KACHAK',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildKachakTheme(),
      locale: localeCtrl.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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