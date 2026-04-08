import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'prediction_screen.dart';
import 'saved_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellController>();
    return Scaffold(
      body: IndexedStack(
        index: shell.index,
        children: [
          const HomeScreen(),
          const PredictionScreen(),
          const MapScreen(),
          SavedScreen(
            onExplore: () => context.read<AppShellController>().selectTab(0),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.index,
        onDestinationSelected: (i) => context.read<AppShellController>().selectTab(i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Predict',
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
        ],
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
