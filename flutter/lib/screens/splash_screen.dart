import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  GlassPanel(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                    borderRadius: 28,
                    fillAlpha: 0.34,
                    blurSigma: 28,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/kachak_logo_green.png',
                          height: 168,
                          fit: BoxFit.contain,
                          semanticLabel: 'Kachak logo',
                        ),
                        const SizedBox(height: 22),
                        Text(
                          "Discover Malaysia's Wildlife\n& Conservation",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: headlineColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                            letterSpacing: -0.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Authoritative species insights, ethical wildlife photography, and protected-area context — built for Malaysian field exploration.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: bodyColor,
                            fontSize: 14,
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
                  SizedBox(height: bottomInset + 6),
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
  static const double _trackW = 92;
  static const double _trackH = 196;
  static const double _knobSize = 56;
  static const double _knobInset = (_trackW - _knobSize) / 2;
  /// Resting position: knob sits near bottom of pill.
  static const double _knobBottomMin = 10;
  /// Upper limit: knob stays below chevrons / label (no overlap).
  static const double _knobBottomMax = 74;
  static const double _knobTrigger = 66;
  static const double _flingVelocity = -720;

  double _knobBottom = _knobBottomMin;
  late AnimationController _snapCtrl;
  Animation<double>? _snapAnim;

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
    _snapCtrl.stop();
    _snapAnim = Tween<double>(begin: _knobBottom, end: _knobBottomMin).animate(
      CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic),
    );
    _snapCtrl.forward(from: 0);
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    final reachedTop = _knobBottom >= _knobTrigger;
    final mid = (_knobBottomMin + _knobBottomMax) / 2;
    final flingUp = v < _flingVelocity && _knobBottom > mid;
    if (reachedTop || flingUp) {
      widget.onGo();
      return;
    }
    _snapBack();
  }

  void _onDragCancel() {
    if (_knobBottom >= _knobTrigger) {
      widget.onGo();
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Drag the Go button up to the top to enter, or tap Go',
      child: SizedBox(
        width: _trackW,
        height: _trackH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_trackW / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_trackW / 2),
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
                    left: _knobInset,
                    right: _knobInset,
                    bottom: _knobBottom,
                    height: _knobSize,
                    child: GestureDetector(
                      onVerticalDragStart: (_) => _snapCtrl.stop(),
                      onVerticalDragUpdate: (d) {
                        setState(() {
                          // Finger moves up → delta.dy negative → increase bottom → knob rises.
                          _knobBottom = (_knobBottom - d.delta.dy).clamp(_knobBottomMin, _knobBottomMax);
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
