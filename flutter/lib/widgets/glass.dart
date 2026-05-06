import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Warm watercolor-style backdrop with subtle botanical decorations.
class MistBackdrop extends StatelessWidget {
  const MistBackdrop({super.key, this.backgroundBlurSigma = 0});

  /// Kept for compatibility with existing callers.
  final double backgroundBlurSigma;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.pageMist),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/home_editorial_bg.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }
}

/// Solid pale white–green — only on pushed detail routes (species / prediction drill-in).
class DetailPageBackdrop extends StatelessWidget {
  const DetailPageBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.pageMist),
          child: SizedBox.expand(),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/home_editorial_bg.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ],
    );
  }
}

/// Editorial card panel used across all pages.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.blurSigma = 22,
    this.fillAlpha = 0.38,

    /// Kept for compatibility with existing callers.
    this.verticalFrostGradient = false,
    this.outlineColor,
    this.outlineWidth = 1.1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final double fillAlpha;
  final bool verticalFrostGradient;
  final Color? outlineColor;
  final double outlineWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColors.surface,
          border: Border.all(
            width: outlineWidth,
            color: outlineColor ?? AppColors.primary.withValues(alpha: 0.12),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14253D2A),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Editorial action pill used for high emphasis actions.
class GlassCtaPill extends StatelessWidget {
  const GlassCtaPill({
    super.key,
    required this.onPressed,
    required this.child,
    this.minHeight = 52,
    this.emphasized = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double minHeight;

  /// Stronger green styling when true.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final bg = emphasized ? AppColors.primary : Colors.white;
    final fg = emphasized ? Colors.white : AppColors.accent;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: bg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0x14253D2A,
            ).withValues(alpha: emphasized ? 1 : 0.65),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              widthFactor: 1,
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: fg, size: 22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
