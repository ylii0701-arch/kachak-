import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/editorial_reading_layout.dart';

/// Nature First–inspired ethical photography principles.
class NatureFirstPrincipleScreen extends StatefulWidget {
  const NatureFirstPrincipleScreen({super.key});

  @override
  State<NatureFirstPrincipleScreen> createState() =>
      _NatureFirstPrincipleScreenState();
}

class _NatureFirstPrincipleScreenState extends State<NatureFirstPrincipleScreen> {

  static final _referenceUri = Uri.parse(
    'https://naturefirst.org/en/principles/',
  );

  static const _intro1 = 'Wildlife photography should never harm wildlife. '
      'Use these quick principles before, during, and after every outing.';

  static const _thanks =
      'Special thanks to Nature First for inspiring our ethical photography principles.';

  static const _principles = <_PrincipleItem>[
    _PrincipleItem(
      title: 'Prioritize Nature',
      summary: 'Animal welfare comes before any photo.',
      detail:
          'If an animal changes behavior because of your presence, you are too close. Step back immediately and stop shooting.',
      icon: Icons.favorite_border_rounded,
    ),
    _PrincipleItem(
      title: 'Educate Yourself Before',
      summary: 'Know species and habitat before entering.',
      detail:
          'Research the ecosystem and species habits in advance. In fragile areas like wetlands or rainforest, stay on marked trails.',
      icon: Icons.menu_book_rounded,
    ),
    _PrincipleItem(
      title: 'Minimize Your Footprint',
      summary: 'Do not alter nature for a better shot.',
      detail:
          'Avoid pruning, moving objects, baiting, or using artificial lures. Keep the environment exactly as you found it.',
      icon: Icons.directions_walk_rounded,
    ),
    _PrincipleItem(
      title: 'Share With Discretion',
      summary: 'Protect sensitive location information.',
      detail:
          'Avoid posting precise GPS coordinates for endangered species. Blur metadata or hide exact location in public posts.',
      icon: Icons.location_off_outlined,
    ),
    _PrincipleItem(
      title: 'Follow Local Regulations',
      summary: 'Respect park rules and permits.',
      detail:
          'Always follow reserve rules, obtain permits, and listen to local rangers and conservation officers.',
      icon: Icons.gavel_rounded,
    ),
    _PrincipleItem(
      title: 'Leave No Trace Plus',
      summary: 'Leave the place better than you found it.',
      detail:
          'Carry out all trash, including organic waste. Model good behavior and encourage others to do the same.',
      icon: Icons.delete_outline_rounded,
    ),
    _PrincipleItem(
      title: 'Promote and Educate',
      summary: 'Share ethical practice with your community.',
      detail:
          'When sharing your work, include ethical context so others learn conservation-friendly field behavior.',
      icon: Icons.campaign_outlined,
    ),
  ];

  int? _expandedIndex = 0;

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  Future<void> _openReference(BuildContext context) async {
    final ok = await launchUrl(
      _referenceUri,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    final rowCount = (_principles.length / 2).ceil();
    final selectedRow = _expandedIndex == null ? -1 : (_expandedIndex! ~/ 2);
    return EditorialReadingShell(
      title: 'Nature First Principle',
      subtitle:
          'Tap each principle to reveal practical guidance.',
      leadingIcon: Icons.forest_outlined,
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 12 * s)),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditorialBodyText(text: _intro1),
                SizedBox(height: 12 * s),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.lightSage.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 12 * s),
                    child: const EditorialBodyText(text: _thanks),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditorialSectionLabel(text: 'Principles'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8 * s),
                      Expanded(
                        child: Text(
                          'Tap a card to expand or collapse details.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10 * s),
                for (var row = 0; row < rowCount; row++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var col = 0; col < 2; col++) ...[
                        if (col == 1) SizedBox(width: 10 * s),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final index = (row * 2) + col;
                              if (index >= _principles.length) {
                                return const SizedBox.shrink();
                              }
                              final item = _principles[index];
                              return _PrincipleCompactTile(
                                index: index + 1,
                                item: item,
                                isExpanded: _expandedIndex == index,
                                onTap: () => _toggle(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (selectedRow == row)
                    Padding(
                      padding: EdgeInsets.only(top: 10 * s),
                      child: _PrincipleDetailCard(
                        index: (_expandedIndex ?? 0) + 1,
                        item: _principles[_expandedIndex ?? 0],
                      ),
                    ),
                  if (row < rowCount - 1) SizedBox(height: 10 * s),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.link_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditorialSectionLabel(text: 'Reference'),
                Material(
                  color: AppColors.lightSage.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => _openReference(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * s,
                        vertical: 12 * s,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Text(
                              'https://naturefirst.org/en/principles/',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrincipleItem {
  const _PrincipleItem({
    required this.title,
    required this.summary,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String summary;
  final String detail;
  final IconData icon;
}

class _PrincipleCompactTile extends StatelessWidget {
  const _PrincipleCompactTile({
    required this.index,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  final int index;
  final _PrincipleItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Material(
      color: AppColors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(10 * s, 9 * s, 10 * s, 9 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.34)
                  : AppColors.border.withValues(alpha: 0.85),
            ),
            color: isExpanded
                ? AppColors.lightSage.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$index',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.4,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            height: 1.22,
                          ),
                        ),
                        SizedBox(height: 1.5 * s),
                        Text(
                          item.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubtitleOnFrost,
                            height: 1.22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6 * s),
                  Column(
                    children: [
                      Icon(item.icon, size: 16, color: AppColors.iconSectionOnFrost),
                      SizedBox(height: 4 * s),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrincipleDetailCard extends StatelessWidget {
  const _PrincipleDetailCard({
    required this.index,
    required this.item,
  });

  final int index;
  final _PrincipleItem item;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Container(
      padding: EdgeInsets.fromLTRB(12 * s, 11 * s, 12 * s, 11 * s),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 9 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    Icon(
                      item.icon,
                      size: 16,
                      color: AppColors.iconSectionOnFrost,
                    ),
                  ],
                ),
                SizedBox(height: 5 * s),
                Text(
                  item.detail,
                  style: GoogleFonts.inter(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBodyOnFrost,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
