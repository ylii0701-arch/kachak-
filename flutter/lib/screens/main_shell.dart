import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'prediction_screen.dart';
import 'saved_screen.dart';

/// Glass pill with balanced vertical padding (Material [NavigationBar] leaves excess space below labels when height is reduced).
class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _inactive = Color(0xFF25312C);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.78),
                Colors.white.withValues(alpha: 0.88),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.94), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 11, 6, 7),
            child: Row(
              children: [
                _item(0, Icons.home_outlined, Icons.home, 'Home'),
                _item(1, Icons.trending_up_outlined, Icons.trending_up, 'Predict'),
                _item(2, Icons.map_outlined, Icons.map, 'Map'),
                _item(3, Icons.favorite_border, Icons.favorite, 'Saved'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData iconOutlined, IconData iconFilled, String label) {
    final selected = selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withValues(alpha: 0.18),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  selected ? iconFilled : iconOutlined,
                  size: 22,
                  color: selected ? Colors.white : _inactive,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.textBodyOnFrost : _inactive,
                  height: 1.1,
                  letterSpacing: selected ? -0.15 : -0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellController>();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MistBackdrop(backgroundBlurSigma: 9),
          IndexedStack(
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
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottom > 0 ? bottom + 2 : 6),
        child: _GlassBottomNav(
          selectedIndex: shell.index,
          onSelect: (i) => context.read<AppShellController>().selectTab(i),
        ),
      ),
    );
  }
}
