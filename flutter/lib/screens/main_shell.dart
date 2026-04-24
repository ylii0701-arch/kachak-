import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
import 'assistant_screen.dart';
import 'home_screen.dart';
import 'identify_screen.dart';
import 'map_screen.dart';
import 'mission_screen.dart';
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
                _item(
                  context,
                  2,
                  Icons.center_focus_weak_outlined,
                  Icons.center_focus_strong,
                  'Identify',
                ),
                _item(context, 3, Icons.adjust_outlined, Icons.adjust, 'Mission'),
                _item(context, 4, Icons.map_outlined, Icons.map, 'Map'),
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

  Future<void> _openAssistant(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AssistantScreen()));
  }

  Future<void> _openSaved(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SavedScreen(
          onExplore: () {
            context.read<AppShellController>().selectTab(0);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellController>();
    final bottom = MediaQuery.paddingOf(context).bottom;
    final s = Adaptive.scale(context);
    final topPad = MediaQuery.paddingOf(context).top;

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
              const IdentifyScreen(),
              const MissionScreen(),
              const MapScreen(),
            ],
          ),
          Positioned(
            top: topPad + (10 * s),
            right: 14 * s,
            child: PopupMenuButton<String>(
              tooltip: 'Menu',
              onSelected: (value) {
                if (value == 'saved') {
                  _openSaved(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(
                  value: 'saved',
                  child: Row(
                    children: [
                      Icon(Icons.favorite_border),
                      SizedBox(width: 8),
                      Text('Saved'),
                    ],
                  ),
                ),
              ],
              child: Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.94)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.menu_rounded, color: AppColors.accent, size: 24 * s),
              ),
            ),
          ),
          Positioned(
            right: 18 * s,
            bottom: bottom + (84 * s),
            child: Semantics(
              label: 'Open assistant chat',
              button: true,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _openAssistant(context),
                  child: Container(
                    width: 62 * s,
                    height: 62 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.95),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 28 * s,
                    ),
                  ),
                ),
              ),
            ),
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
