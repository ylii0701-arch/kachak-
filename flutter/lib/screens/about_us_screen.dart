import 'package:flutter/material.dart';

import '../widgets/editorial_reading_layout.dart';

/// About KaChak and team 60MT — opened from the side menu only.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _mission =
      'KaChak was born from a simple idea: to enable photography enthusiasts to discover and document the beauty of rare life forms in Malaysia in the most environmentally friendly way. We believe that artificial intelligence should not only bridge the gap between humans and the wild but also act as a shield for the voiceless. Our mission is to empower photography beginners to discover the breathtaking biodiversity of Malaysia while fostering a deep-rooted culture of ethical observation and conservation.';

  static const _team =
      'We are a diverse group of IT students of Monash University. As team 60MT, we have combined our technical expertise in Machine Learning, full-stack development, and UI/UX design to create a tool that serves both the community and the environment.\n\n'
      'Design-First Approach: We believe in thoughtful engineering, from the first ERD diagram to the final pixel.\n\n'
      'Social Impact: Our project aligns with SDG 15 (Life on Land), focusing on the protection of endangered species in Malaysia.';

  static const _promise =
      'Transparency and ethics are at the heart of KaChak. We are committed to protecting sensitive ecological data and ensuring that our AI tools are used responsibly to support conservation efforts, not compromise them.';

  static const _connect =
      'We are constantly learning and evolving. If you have any suggestions or would like to join us in our journey of tech-driven conservation, please feel free to reach out.';

  @override
  Widget build(BuildContext context) {
    return EditorialReadingShell(
      title: 'About Us & KaChak',
      subtitle:
          'Mission, team, and our promise to wildlife and photographers.',
      leadingIcon: Icons.park_outlined,
      slivers: [
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.flag_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                EditorialSectionLabel(text: 'Our Mission'),
                EditorialBodyText(text: _mission),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.groups_2_outlined,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialSectionLabel(text: 'Our Team: 60MT'),
                EditorialBodyText(text: _team),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.verified_user_outlined,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialSectionLabel(text: 'Our Promise'),
                EditorialBodyText(text: _promise),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: EditorialCard(
            icon: Icons.mail_outline_rounded,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialSectionLabel(text: 'Connect With Us'),
                EditorialBodyText(text: _connect),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
