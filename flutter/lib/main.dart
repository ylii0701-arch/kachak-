import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/app_shell_controller.dart';
import 'providers/saved_species_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class KachakApp extends StatelessWidget {
  const KachakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KACHAK',
      debugShowCheckedModeBanner: false,
      theme: buildKachakTheme(),
      home: const SplashScreen(),
    );
  }
}
