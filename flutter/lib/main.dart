import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/saved_species_provider.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SavedSpeciesProvider(prefs),
      child: const KachakApp(),
    ),
  );
}

class KachakApp extends StatelessWidget {
  const KachakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kachak',
      theme: buildKachakTheme(),
      home: const MainShell(),
    );
  }
}
