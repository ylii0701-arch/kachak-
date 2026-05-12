import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import 'glass.dart';

/// Shared chrome for long-form “editorial” info pages (About, Nature First).
class EditorialReadingShell extends StatelessWidget {
  const EditorialReadingShell({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.menu_book_outlined,
    required this.slivers,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DetailPageBackdrop(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12 * s, 6 * s, 12 * s, 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Row(
                          children: [
                            Material(
                              color: AppColors.surface.withValues(alpha: 0.96),
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Back',
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.accent,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 0),
                        child: _HeroPanel(
                          title: title,
                          subtitle: subtitle,
                          icon: leadingIcon,
                        ),
                      ),
                    ),
                  ),
                ),
                ...slivers,
                SliverToBoxAdapter(child: SizedBox(height: 36 * s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorialCard extends StatelessWidget {
  const EditorialCard({
    super.key,
    this.icon,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 20),
  });

  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 14 * s),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.calmShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: padding,
              child: icon == null
                  ? child
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.lightSage.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 24),
                        ),
                        SizedBox(width: 14 * s),
                        Expanded(child: child),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialSectionLabel extends StatelessWidget {
  const EditorialSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          letterSpacing: 0.02,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class EditorialBodyText extends StatelessWidget {
  const EditorialBodyText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.62,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.01,
        color: AppColors.textBodyOnFrost,
      ),
    );
  }
}

class EditorialNumberedPrinciple extends StatelessWidget {
  const EditorialNumberedPrinciple({
    super.key,
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              '$index',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.58,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.01,
                color: AppColors.textBodyOnFrost,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.title,
    this.subtitle,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.withValues(alpha: 0.98),
            AppColors.lightSage.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.calmShadow,
            blurRadius: 18,
            offset: Offset(0, 6 * s),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18 * s, 20 * s, 18 * s, 20 * s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52 * s,
              height: 52 * s,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16 * s),
              ),
              child: Icon(icon, color: AppColors.accent, size: 28 * s),
            ),
            SizedBox(width: 16 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: Adaptive.clamp(context, 24, min: 20, max: 28),
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                      letterSpacing: -0.35,
                      color: AppColors.accent,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 8 * s),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
