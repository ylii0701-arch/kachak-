import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
import 'main_shell.dart';

/// Glass-style splash over mist backdrop; [Go] enters [MainShell].
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _go(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const headlineColor = Color(0xFF1A3D2E);
    const bodyColor = Color(0xFF4A5C52);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MistBackdrop(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 8 * s),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  GlassPanel(
                    padding: EdgeInsets.fromLTRB(22 * s, 28 * s, 22 * s, 28 * s),
                    borderRadius: 28 * s,
                    fillAlpha: 0.34,
                    blurSigma: 28,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/kachak_logo_green.png',
                          height: Adaptive.clamp(context, 168, min: 120, max: 220),
                          fit: BoxFit.contain,
                          semanticLabel: 'Kachak logo',
                        ),
                        SizedBox(height: 22 * s),
                        Text(
                          "Discover Malaysia's Wildlife\n& Conservation",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: headlineColor,
                            fontSize: Adaptive.clamp(context, 22, min: 18, max: 28),
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                            letterSpacing: -0.15,
                          ),
                        ),
                        SizedBox(height: 10 * s),
                        Text(
                          'Authoritative species insights, ethical wildlife photography, and protected-area context — built for Malaysian field exploration.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: bodyColor,
                            fontSize: Adaptive.clamp(context, 14, min: 12, max: 17),
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            letterSpacing: 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  _SplashGoRail(onGo: () => _go(context)),
                  SizedBox(height: bottomInset + (6 * s)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashGoRail extends StatefulWidget {
  const _SplashGoRail({required this.onGo});

  final VoidCallback onGo;

  @override
  State<_SplashGoRail> createState() => _SplashGoRailState();
}

class _SplashGoRailState extends State<_SplashGoRail> with SingleTickerProviderStateMixin {
  static const double _flingVelocity = -720;

  double _knobBottom = 10;
  late AnimationController _snapCtrl;
  Animation<double>? _snapAnim;

  double _knobBottomMinFor(BuildContext context) =>
      Adaptive.clamp(context, 10, min: 8, max: 14);
  double _knobBottomMaxFor(BuildContext context) =>
      Adaptive.clamp(context, 74, min: 56, max: 94);
  double _knobTriggerFor(BuildContext context) =>
      Adaptive.clamp(context, 66, min: 50, max: 84);

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _snapCtrl.addListener(_onSnapTick);
  }

  void _onSnapTick() {
    final a = _snapAnim;
    if (a == null || !mounted) return;
    setState(() => _knobBottom = a.value);
  }

  @override
  void dispose() {
    _snapCtrl.removeListener(_onSnapTick);
    _snapCtrl.dispose();
    super.dispose();
  }

  void _snapBack() {
    final min = _knobBottomMinFor(context);
    _snapCtrl.stop();
    _snapAnim = Tween<double>(begin: _knobBottom, end: min).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic),
    );
    _snapCtrl.forward(from: 0);
  }

  void _onDragEnd(DragEndDetails d) {
    final min = _knobBottomMinFor(context);
    final max = _knobBottomMaxFor(context);
    final trigger = _knobTriggerFor(context);
    final v = d.primaryVelocity ?? 0;
    final reachedTop = _knobBottom >= trigger;
    final mid = (min + max) / 2;
    final flingUp = v < _flingVelocity && _knobBottom > mid;
    if (reachedTop || flingUp) {
      widget.onGo();
      return;
    }
    _snapBack();
  }

  void _onDragCancel() {
    if (_knobBottom >= _knobTriggerFor(context)) {
      widget.onGo();
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final railW = Adaptive.clamp(context, 92, min: 72, max: 108);
    final railH = Adaptive.clamp(context, 196, min: 156, max: 240);
    final knobSize = Adaptive.clamp(context, 56, min: 44, max: 66);
    final knobInset = (railW - knobSize) / 2;
    final knobBottomMin = _knobBottomMinFor(context);
    final knobBottomMax = _knobBottomMaxFor(context);
    final knobBottom = _knobBottom.clamp(knobBottomMin, knobBottomMax);
    return Semantics(
      label: 'Drag the Go button up to the top to enter, or tap Go',
      child: SizedBox(
        width: railW,
        height: railH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(railW / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(railW / 2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.30),
                    Colors.white.withValues(alpha: 0.46),
                  ],
                  stops: const [0.0, 0.32, 0.68, 1.0],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.48), width: 1.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 12,
                    left: 6,
                    right: 6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          color: Colors.white,
                          size: 30,
                          shadows: const [Shadow(blurRadius: 6, color: Colors.black26)],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Swipe up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: knobInset,
                    right: knobInset,
                    bottom: knobBottom,
                    height: knobSize,
                    child: GestureDetector(
                      onVerticalDragStart: (_) => _snapCtrl.stop(),
                      onVerticalDragUpdate: (d) {
                        setState(() {
                          // Finger moves up → delta.dy negative → increase bottom → knob rises.
                          _knobBottom = (_knobBottom - d.delta.dy).clamp(knobBottomMin, knobBottomMax);
                        });
                      },
                      onVerticalDragEnd: _onDragEnd,
                      onVerticalDragCancel: _onDragCancel,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 5,
                        shadowColor: Colors.black38,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onGo,
                          child: const Center(
                            child: Text(
                              'Go',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
