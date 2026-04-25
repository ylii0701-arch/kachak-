import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/assistant_overlay_layer.dart';
import '../widgets/glass.dart';
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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        ClipRRect(
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.94),
                  width: 1.2,
                ),
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
                    _standardItem(
                      context,
                      0,
                      Icons.home_outlined,
                      Icons.home,
                      'Home',
                    ),
                    _standardItem(
                      context,
                      1,
                      Icons.trending_up_outlined,
                      Icons.trending_up,
                      'Predict',
                    ),
                    _centerIdentifyLabel(context),
                    _standardItem(
                      context,
                      3,
                      Icons.adjust_outlined,
                      Icons.adjust,
                      'Mission',
                    ),
                    _standardItem(
                      context,
                      4,
                      Icons.map_outlined,
                      Icons.map,
                      'Map',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(top: -16 * s, child: _identifyCenterButton(context)),
      ],
    );
  }

  Widget _centerIdentifyLabel(BuildContext context) {
    final s = Adaptive.scale(context);
    final selected = selectedIndex == 2;
    final labelSize = (11 * s).clamp(10.0, 13.0);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(2),
          borderRadius: BorderRadius.circular(18 * s),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 35 * s),
              Text(
                'Identify',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: labelSize,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.primary : _inactive,
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

  Widget _standardItem(
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
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * s,
                  vertical: 5 * s,
                ),
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

  Widget _identifyCenterButton(BuildContext context) {
    final s = Adaptive.scale(context);
    final selected = selectedIndex == 2;
    final size = 62 * s;
    return Semantics(
      label: 'Identify tab',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(2),
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Container(
            width: size,
            height: size,
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
              selected
                  ? Icons.center_focus_strong
                  : Icons.center_focus_weak_outlined,
              color: Colors.white,
              size: 28 * s,
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _menuOpen = false;

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
    });
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() {
      _menuOpen = false;
    });
  }

  Future<void> _openSaved() async {
    _closeMenu();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
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

  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool secondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: secondary ? 18 : 22,
                color: secondary
                    ? AppColors.accent.withValues(alpha: 0.68)
                    : AppColors.accent,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: secondary ? 13 : 16,
                  fontWeight: secondary ? FontWeight.w600 : FontWeight.w700,
                  color: secondary
                      ? AppColors.accent.withValues(alpha: 0.7)
                      : AppColors.accent,
                ),
              ),
              if (secondary) ...[
                const SizedBox(width: 8),
                Text(
                  'soon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<AppShellController>();
    final media = MediaQuery.of(context);
    final bottom = media.padding.bottom;
    final s = Adaptive.scale(context);
    final topPad = media.padding.top;
    final screenWidth = media.size.width;

    final navBarHeight = bottom > 0
        ? bottom + (2 * s) + 64 * s
        : 6 * s + 64 * s;
    final panelWidth = (screenWidth * 0.74).clamp(240.0, 320.0);

    final pageSurface = AssistantOverlayLayer(
      reservedBottom: navBarHeight,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MistBackdrop(backgroundBlurSigma: 9),
            IndexedStack(
              index: shell.index,
              children: const [
                HomeScreen(),
                PredictionScreen(),
                IdentifyScreen(),
                MissionScreen(),
                MapScreen(),
              ],
            ),
            if (_menuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeMenu,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.24),
                  ),
                ),
              ),
            Positioned(
              top: topPad + (10 * s),
              right: 14 * s,
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  width: 44 * s,
                  height: 44 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.94),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
                    color: AppColors.accent,
                    size: 24 * s,
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
            onSelect: (i) {
              _closeMenu();
              context.read<AppShellController>().selectTab(i);
            },
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: IgnorePointer(
            ignoring: !_menuOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _menuOpen ? 1 : 0,
              child: Container(
                width: panelWidth,
                color: Colors.white.withValues(alpha: 0.97),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      14 * s,
                      16 * s,
                      14 * s,
                      16 * s,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(height: 12 * s),
                        _menuTile(
                          icon: Icons.favorite_border_rounded,
                          label: 'Saved',
                          onTap: _openSaved,
                        ),
                        _menuTile(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () {},
                          secondary: true,
                        ),
                        _menuTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Help Center',
                          onTap: () {},
                          secondary: true,
                        ),
                        SizedBox(height: 14 * s),
                        Divider(color: Colors.grey.shade200, thickness: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: Offset(_menuOpen ? -panelWidth / screenWidth : 0, 0),
          child: pageSurface,
        ),
      ],
    );
  }
}
