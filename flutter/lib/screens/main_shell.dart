import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_shell_controller.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/assistant_overlay_layer.dart';
import '../widgets/glass.dart';
import '../widgets/onboarding/onboarding_content.dart';
import '../widgets/onboarding/page_intro_sheet.dart';
import '../widgets/onboarding/welcome_carousel.dart';
import 'home_screen.dart';
import 'identify_screen.dart';
import 'map_screen.dart';
import 'mission_screen.dart';
import 'prediction_screen.dart';
import 'saved_screen.dart';

/// Editorial bottom navigation with calm, consistent styling.
class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _inactive = Color(0xFF25312C);

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4 * s, 8 * s, 4 * s, 8 * s),
        child: Row(
          children: [
            _standardItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
            _standardItem(
              context,
              1,
              Icons.trending_up_outlined,
              Icons.trending_up,
              'Predict',
            ),
            _standardItem(
              context,
              2,
              Icons.center_focus_weak_outlined,
              Icons.center_focus_strong,
              'Identify',
            ),
            _standardItem(
              context,
              3,
              Icons.adjust_outlined,
              Icons.adjust,
              'Mission',
            ),
            _standardItem(context, 4, Icons.map_outlined, Icons.map, 'Map'),
          ],
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
    final isIdentify = index == 2;
    final s = Adaptive.scale(context);
    final iconSize = isIdentify
        ? (24 * s).clamp(19.0, 26.0)
        : (22 * s).clamp(18.0, 24.0);
    final labelSize = (11 * s).clamp(10.0, 13.0);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelect(index),
          borderRadius: BorderRadius.circular(20 * s),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isIdentify ? 34 * s : null,
                height: isIdentify ? 34 * s : null,
                decoration: isIdentify
                    ? BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.16)
                            : AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      )
                    : null,
                alignment: Alignment.center,
                child: Icon(
                  selected ? iconFilled : iconOutlined,
                  size: iconSize,
                  color: isIdentify
                      ? (selected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.85))
                      : (selected ? AppColors.primary : _inactive),
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: labelSize,
                  fontWeight: selected
                      ? (isIdentify ? FontWeight.w800 : FontWeight.w700)
                      : FontWeight.w500,
                  color: selected ? AppColors.primary : _inactive,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 4 * s),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: selected ? 20 * s : 0,
                height: 3 * s,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Root shell hosting tab navigation, overlay assistant, and side menu.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _menuOpen = false;

  /// Tracks the last tab index we evaluated for an onboarding tour, so we
  /// only show a tour once per tab visit.
  int? _lastEvaluatedTabIndex;

  /// True while a tour bottom sheet / welcome carousel is on screen, so we
  /// do not stack multiple onboarding overlays.
  bool _tourInProgress = false;

  AppShellController? _shellListenerTarget;

  @override
  void initState() {
    super.initState();
    final shell = context.read<AppShellController>();
    shell.addListener(_handleShellChange);
    _shellListenerTarget = shell;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runInitialOnboarding();
    });
  }

  @override
  void dispose() {
    _shellListenerTarget?.removeListener(_handleShellChange);
    super.dispose();
  }

  /// Handles tab changes from [AppShellController] and fires the tour for the
  /// newly active tab if the user has not seen it yet.
  void _handleShellChange() {
    if (!mounted) return;
    final idx = context.read<AppShellController>().index;
    if (_lastEvaluatedTabIndex == idx) return;
    _lastEvaluatedTabIndex = idx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowTourFor(idx);
    });
  }

  /// Maps a bottom-navigation index to the matching [OnboardingTour].
  OnboardingTour? _tourForTab(int idx) {
    switch (idx) {
      case 0:
        return OnboardingTour.home;
      case 1:
        return OnboardingTour.predict;
      case 2:
        return OnboardingTour.identify;
      case 3:
        return OnboardingTour.mission;
      case 4:
        return OnboardingTour.map;
    }
    return null;
  }

  /// Runs the welcome carousel + initial tab tour for first-time users.
  Future<void> _runInitialOnboarding() async {
    final onboarding = context.read<OnboardingService>();
    if (!onboarding.hasSeen(OnboardingTour.welcome)) {
      _tourInProgress = true;
      await WelcomeCarousel.show(context);
      if (!mounted) {
        _tourInProgress = false;
        return;
      }
      await onboarding.markSeen(OnboardingTour.welcome);
      _tourInProgress = false;
    }
    if (!mounted) return;
    final idx = context.read<AppShellController>().index;
    _lastEvaluatedTabIndex = idx;
    await _maybeShowTourFor(idx);
  }

  /// Shows the per-tab tour bottom sheet if the user has not seen it yet.
  Future<void> _maybeShowTourFor(int idx) async {
    if (_tourInProgress) return;
    final tour = _tourForTab(idx);
    if (tour == null) return;
    final content = kOnboardingContent[tour];
    if (content == null) return;
    final onboarding = context.read<OnboardingService>();
    if (onboarding.hasSeen(tour)) return;
    _tourInProgress = true;
    try {
      await PageIntroSheet.show(context, content);
      if (!mounted) return;
      await onboarding.markSeen(tour);
    } finally {
      _tourInProgress = false;
    }
  }

  /// Resets all tour flags and replays the welcome + current tab tour.
  Future<void> _restartTutorial() async {
    _closeMenu();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    final onboarding = context.read<OnboardingService>();
    await onboarding.resetAll();
    _lastEvaluatedTabIndex = null;
    await _runInitialOnboarding();
  }

  /// Toggles right-side quick menu panel.
  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
    });
  }

  /// Closes menu panel if currently open.
  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() {
      _menuOpen = false;
    });
  }

  /// Opens Saved screen from side menu and jumps back to Home on explore CTA.
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
                style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
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

    final navBarHeight = bottom + (64 * s);
    final panelWidth = (screenWidth * 0.74).clamp(240.0, 320.0);

    // Main page surface (tabs + bottom nav) that slides when menu opens.
    final pageSurface = AssistantOverlayLayer(
      reservedBottom: navBarHeight,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MistBackdrop(backgroundBlurSigma: 9),
            // Keep tab states alive while switching bottom navigation.
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
            // Dim backdrop captures taps to close menu.
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
        bottomNavigationBar: SafeArea(
          top: false,
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

    // Right-side menu layer behind sliding page surface.
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
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
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
                          icon: Icons.school_outlined,
                          label: 'Show tutorial',
                          onTap: _restartTutorial,
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
