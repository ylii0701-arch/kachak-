import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kachak_tracker/providers/saved_species_provider.dart';
import 'package:kachak_tracker/screens/home_screen.dart';
import 'package:kachak_tracker/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Kachak home header renders', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SavedSpeciesProvider(prefs),
        child: MaterialApp(
          theme: buildKachakTheme(),
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    // Avoid pumpAndSettle: network images in the list retry under test HttpClient (400).
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kachak'), findsOneWidget);
  });
}
