import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/editorial_reading_layout.dart';

/// Nature First–inspired ethical photography principles.
class NatureFirstPrincipleScreen extends StatelessWidget {
  const NatureFirstPrincipleScreen({super.key});

  static final _referenceUri = Uri.parse(
    'https://naturefirst.org/en/principles/',
  );

  static const _intro1 =
      'The Earth belongs to every living soul that calls it home. As we use technology to bridge the gap between humans and the wild, we must remember that we are merely guests in their sanctuary. The beauty of nature lies in its untamed spirit, and our greatest contribution is to observe without disturbing. By following these principles, we want to ensure that the wonders of biodiversity remain protected for generations to come.';

  static const _thanks =
      'Special thanks to Nature First for inspiring our ethical photography principles.';

  static const _p1 =
      'Prioritize Nature: The safety and health of animals and their habitats always come before any photograph. If an animal changes its behavior because of your presence, you are too close.';
  static const _p2 =
      'Educate Yourself Before: Learn about the species and ecosystems you are visiting. In fragile environments like rainforests or wetlands, stay on marked trails to avoid damaging rare flora or nesting sites.';
  static const _p3 =
      'Minimize Your Footprint: Avoid altering the environment for a "better shot." Do not prune branches, move rocks, or use artificial lures and baits that could disrupt natural feeding and breeding patterns.';
  static const _p4 =
      'Share With Discretion: While we celebrate discovery, the exact GPS coordinates of endangered species can lead to overcrowding or poaching. Blur or hide precise location data when sharing your sightings.';
  static const _p5 =
      'Follow Local Regulations: Respect the rules of National Parks and nature reserves. Always obtain necessary permits and follow the guidance of local rangers and conservationists.';
  static const _p6 =
      'Leave No Trace Plus: Carry out all trash, including organic waste, and leave the environment better than you found it. Lead by example and encourage others to practice ethical photography.';
  static const _p7 =
      'Promote and Educate: Encourage others to practice ethical photography. By sharing these principles alongside your stories, you help build a community that values conservation as much as the art of photography.';

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
    return EditorialReadingShell(
      title: 'Nature First Principle',
      subtitle:
          'Ethical field photography — observe without disturbing.',
      leadingIcon: Icons.forest_outlined,
      slivers: [
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.eco_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditorialBodyText(text: _intro1),
                SizedBox(height: 16 * s),
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
            icon: Icons.format_list_numbered_rounded,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialSectionLabel(text: 'Principles'),
                EditorialNumberedPrinciple(index: 1, text: _p1),
                EditorialNumberedPrinciple(index: 2, text: _p2),
                EditorialNumberedPrinciple(index: 3, text: _p3),
                EditorialNumberedPrinciple(index: 4, text: _p4),
                EditorialNumberedPrinciple(index: 5, text: _p5),
                EditorialNumberedPrinciple(index: 6, text: _p6),
                EditorialNumberedPrinciple(index: 7, text: _p7),
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
