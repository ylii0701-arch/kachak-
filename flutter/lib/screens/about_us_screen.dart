import 'package:flutter/material.dart';

import 'meet_team_page.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';

/// About KaChak and team 60MT — opened from the side menu only.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _missionBody =
      'Making wildlife conservation accessible through technology.';
  static const _teamBody =
      'Students and nature lovers building tools for wildlife.';
  static const _promiseBody =
      'Responsible tech that protects sensitive ecological data.';

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final horizontal = 20.0 * s;
    final gap = 16.0 * s;

    return Scaffold(
      backgroundColor: AppColors.detailBackdrop,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroAboutCard(scale: s),
              SizedBox(height: 26 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Text(
                  'ABOUT US',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(height: 14 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AboutInfoCard(
                            icon: Icons.eco_outlined,
                            title: 'Our Mission',
                            body: _missionBody,
                            minHeight: Adaptive.clamp(context, 170, min: 158, max: 186),
                            bodyMaxLines: 4,
                            showLeaf: true,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _AboutInfoCard(
                            icon: Icons.groups_2_outlined,
                            title: 'Our Team',
                            body: _teamBody,
                            minHeight: Adaptive.clamp(context, 186, min: 172, max: 204),
                            bodyMaxLines: 4,
                            trailingButton: const _TeamButton(),
                            showLeaf: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gap),
                    _AboutInfoCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Our Promise',
                      body: _promiseBody,
                      minHeight: Adaptive.clamp(context, 146, min: 134, max: 164),
                      bodyMaxLines: 3,
                    ),
                    SizedBox(height: gap),
                    _WhatWeDoCard(
                      minHeight: Adaptive.clamp(context, 154, min: 146, max: 178),
                    ),
                    SizedBox(height: 18 * s),
                    const _ConnectCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAboutCard extends StatelessWidget {
  const _HeroAboutCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final imageHeight = Adaptive.clamp(context, 346, min: 330, max: 360);
    final topInset = MediaQuery.paddingOf(context).top;
    final quoteWidth = Adaptive.clamp(context, 178, min: 170, max: 186);
    final quoteHeight = Adaptive.clamp(context, 130, min: 122, max: 136);
    final quoteOverlap = Adaptive.clamp(context, 20, min: 16, max: 24);
    final heroBottomPadding = 14 * scale;

    return SizedBox(
      height: imageHeight + quoteOverlap + heroBottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(28 * scale),
                bottomRight: Radius.circular(28 * scale),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/malayantiger.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.22, -0.28),
                    errorBuilder: (_, _, _) {
                      return Image.asset(
                        'assets/images/forest_mist_backdrop.jpg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.22, -0.28),
                      );
                    },
                  ),
                  Positioned(
                    left: 18 * scale,
                    top: topInset + (10 * scale),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: EdgeInsets.all(8 * scale),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20 * scale,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: -quoteOverlap,
            child: Container(
              width: quoteWidth,
              height: quoteHeight,
              padding: EdgeInsets.all(18 * scale),
              decoration: BoxDecoration(
                color: AppColors.detailBackdrop.withValues(alpha: 0.98),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40 * scale),
                  topRight: Radius.circular(2 * scale),
                  bottomLeft: Radius.circular(24 * scale),
                  bottomRight: Radius.circular(2 * scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24 * scale,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Every sighting.\nEvery photo.\nEvery action counts.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      height: 1.22,
                      fontSize: Adaptive.clamp(context, 15.5, min: 15, max: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutInfoCard extends StatelessWidget {
  const _AboutInfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.minHeight,
    this.trailingButton,
    this.showLeaf = false,
    this.bodyMaxLines,
  });

  final IconData icon;
  final String title;
  final String body;
  final double minHeight;
  final Widget? trailingButton;
  final bool showLeaf;
  final int? bodyMaxLines;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.all(15 * s),
      decoration: _bentoDecoration(),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: icon),
              SizedBox(height: 10 * s),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: Adaptive.clamp(context, 20.5, min: 16, max: 22),
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                body,
                maxLines: bodyMaxLines,
                overflow: bodyMaxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBodyOnFrost,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  fontSize: Adaptive.clamp(context, 12.6, min: 11, max: 13.2),
                ),
              ),
              if (trailingButton != null) ...[
                SizedBox(height: 10 * s),
                trailingButton!,
              ],
            ],
          ),
          if (showLeaf)
            Positioned(
              right: -8 * s,
              bottom: -8 * s,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.26,
                  child: Icon(
                    Icons.spa_outlined,
                    size: 86 * s,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WhatWeDoCard extends StatelessWidget {
  const _WhatWeDoCard({
    required this.minHeight,
  });

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final items = <({String title, String body, IconData icon})>[
      (
        title: 'Discover',
        body: 'Explore species',
        icon: Icons.explore_outlined,
      ),
      (
        title: 'Document',
        body: 'Record sightings',
        icon: Icons.camera_alt_outlined,
      ),
      (
        title: 'Learn',
        body: 'Identify with AI',
        icon: Icons.psychology_alt_outlined,
      ),
      (
        title: 'Conserve',
        body: 'Protect biodiversity',
        icon: Icons.volunteer_activism_outlined,
      ),
    ];

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.all(15 * s),
      decoration: _bentoDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: Icons.photo_camera_outlined),
          SizedBox(height: 10 * s),
          Text(
            'What We Do',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: Adaptive.clamp(context, 20.5, min: 16, max: 22),
            ),
          ),
          SizedBox(height: 12 * s),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoByTwo = constraints.maxWidth < 420;
              final crossAxisCount = useTwoByTwo ? 2 : 4;
              final itemGap = 8.0 * s;
              final tileWidth =
                  (constraints.maxWidth - (itemGap * (crossAxisCount - 1))) / crossAxisCount;
              return Wrap(
                spacing: itemGap,
                runSpacing: itemGap,
                children: items.map((item) {
                  return SizedBox(
                    width: tileWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          size: Adaptive.clamp(context, 18, min: 15, max: 20),
                          color: AppColors.iconSectionOnFrost,
                        ),
                        SizedBox(height: 6 * s),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            fontSize: Adaptive.clamp(context, 12.4, min: 10.5, max: 13),
                          ),
                        ),
                        SizedBox(height: 2 * s),
                        Text(
                          item.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textBodyOnFrost,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                            fontSize: Adaptive.clamp(context, 10.8, min: 9.6, max: 11.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConnectCard extends StatelessWidget {
  const _ConnectCard();

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: Adaptive.clamp(context, 66, min: 58, max: 72),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(22 * s),
        image: const DecorationImage(
          image: AssetImage('assets/images/leaf_branch.png'),
          alignment: Alignment.bottomRight,
          fit: BoxFit.cover,
          opacity: 0.16,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connect With Us',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: Adaptive.clamp(context, 16.5, min: 14, max: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * s),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _SocialPill(icon: Icons.camera_alt_outlined),
              _SocialPill(icon: Icons.mail_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Padding(
      padding: EdgeInsets.only(left: 5 * s),
      child: Container(
        width: 28 * s,
        height: 28 * s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 14 * s,
        ),
      ),
    );
  }
}

class _TeamButton extends StatelessWidget {
  const _TeamButton();

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return InkWell(
      borderRadius: BorderRadius.circular(22 * s),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const MeetTeamPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11 * s, vertical: 7 * s),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(22 * s),
        ),
        child: Text(
          'Meet the Team  →',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: Adaptive.clamp(context, 11.4, min: 9.8, max: 12.4),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Container(
      width: 39 * s,
      height: 39 * s,
      decoration: BoxDecoration(
        color: AppColors.lightSage,
        borderRadius: BorderRadius.circular(10 * s),
      ),
      child: Icon(icon, color: AppColors.iconSectionOnFrost, size: 18.5 * s),
    );
  }
}

BoxDecoration _bentoDecoration() {
  return BoxDecoration(
    color: const Color(0xFFF9F7EF),
    borderRadius: BorderRadius.circular(23),
    border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
