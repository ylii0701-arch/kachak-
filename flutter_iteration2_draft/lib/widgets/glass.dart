import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Misty forest photo (full bleed). Optional [backgroundBlurSigma] blurs **only** the
/// photo (e.g. main shell); scrim stays sharp. Use `0` on splash for a crisp image.
class MistBackdrop extends StatelessWidget {
  const MistBackdrop({super.key, this.backgroundBlurSigma = 0});

  /// Gaussian blur on the JPEG only; `0` = no blur (splash).
  final double backgroundBlurSigma;

  @override
  Widget build(BuildContext context) {
    Widget photo = Image.asset(
      'assets/images/forest_mist_backdrop.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
    );

    if (backgroundBlurSigma > 0) {
      photo = ClipRect(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: backgroundBlurSigma,
            sigmaY: backgroundBlurSigma,
          ),
          child: photo,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: photo),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.035),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
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
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.pageMist),
      child: SizedBox.expand(),
    );
  }
}

/// Frosted glass panel (backdrop blur + translucent fill + hairline border).
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.blurSigma = 22,
    this.fillAlpha = 0.38,
    /// Top slightly clearer, bottom a bit milkier (matches splash slider rail).
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
    final topA = (fillAlpha * 0.72).clamp(0.0, 0.55);
    final botA = (fillAlpha * 1.12).clamp(0.0, 0.58);
    final borderA = outlineColor == null
        ? (fillAlpha < 0.34 ? 0.82 : fillAlpha < 0.42 ? 0.74 : 0.58)
        : null;
    final shadowA = fillAlpha < 0.38 ? 0.05 : 0.08;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: verticalFrostGradient ? null : Colors.white.withValues(alpha: fillAlpha),
            gradient: verticalFrostGradient
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: topA),
                      Colors.white.withValues(alpha: botA),
                    ],
                  )
                : null,
            border: Border.all(
              width: outlineWidth,
              color: outlineColor ?? Colors.white.withValues(alpha: borderA ?? 0.58),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: shadowA),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Full-width frosted pill (e.g. Save / primary actions on detail routes).
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
  /// Stronger green-tinted frost when true (e.g. saved state).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: emphasized
                  ? [
                      AppColors.primary.withValues(alpha: 0.34),
                      AppColors.primary.withValues(alpha: 0.5),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.36),
                      Colors.white.withValues(alpha: 0.5),
                    ],
            ),
            border: Border.all(
              color: emphasized
                  ? AppColors.primary.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.72),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: emphasized ? 0.14 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  widthFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: emphasized ? Colors.white : AppColors.textOnGlass,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    child: IconTheme.merge(
                      data: IconThemeData(
                        color: emphasized ? Colors.white : AppColors.textOnGlass,
                        size: 22,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: child,
                      ),
                    ),
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
