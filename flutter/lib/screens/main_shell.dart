import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
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
    final s = Adaptive.scale(context);
    final radius = 22 * s;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
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
            padding: EdgeInsets.fromLTRB(6 * s, 11 * s, 6 * s, 7 * s),
            child: Row(
              children: [
                _item(context, 0, Icons.home_outlined, Icons.home, 'Home'),
                _item(context, 1, Icons.trending_up_outlined, Icons.trending_up, 'Predict'),
                _item(context, 2, Icons.map_outlined, Icons.map, 'Map'),
                _item(context, 3, Icons.favorite_border, Icons.favorite, 'Saved'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
  ) {
    final selected = selectedIndex == index;
    final s = Adaptive.scale(context);
    final iconSize = (22 * s).clamp(18.0, 24.0);
    final labelSize = (11 * s).clamp(10.0, 13.0);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(index),
          borderRadius: BorderRadius.circular(20 * s),
          splashColor: AppColors.primary.withValues(alpha: 0.18),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 5 * s),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  selected ? iconFilled : iconOutlined,
                  size: iconSize,
                  color: selected ? Colors.white : _inactive,
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: labelSize,
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
    final s = Adaptive.scale(context);

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
        padding: EdgeInsets.fromLTRB(
          8 * s,
          0,
          8 * s,
          bottom > 0 ? bottom + (2 * s) : 6 * s,
        ),
        child: _GlassBottomNav(
          selectedIndex: shell.index,
          onSelect: (i) => context.read<AppShellController>().selectTab(i),
        ),
      ),
    );
  }
}
