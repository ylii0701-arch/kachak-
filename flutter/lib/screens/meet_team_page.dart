import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';

class MeetTeamPage extends StatelessWidget {
  const MeetTeamPage({super.key});

  static const _members = <_TeamMember>[
    _TeamMember(
      name: 'Lim Wen Yuan',
      role: 'Backend & Data\nDeveloper',
      age: 24,
      education: 'MAI',
      imageAsset: 'assets/images/wenyuan.png',
    ),
    _TeamMember(
      name: 'Lin Chia Tai\n(Patrick)',
      role: 'Backend & Data\nDeveloper',
      age: 22,
      education: 'MAI',
      imageAsset: 'assets/images/tailin.png',
    ),
    _TeamMember(
      name: 'Calvin Chua\nKee Wee',
      role: 'Lead Frontend\nDeveloper',
      age: 24,
      education: 'MDS',
      imageAsset: 'assets/images/calvin.png',
    ),
    _TeamMember(
      name: 'Zhenyu Zhou',
      role: 'Frontend &\nInteraction Support',
      age: 24,
      education: 'MAI',
      imageAsset: 'assets/images/zhenyu.png',
    ),
    _TeamMember(
      name: 'Yueyufei Ma',
      role: 'UX &\nDocumentation Lead',
      age: 25,
      education: 'MDS',
      imageAsset: 'assets/images/yueyufei.png',
    ),
    _TeamMember(
      name: 'Yumeng Li',
      role: 'Project\nManager',
      age: 25,
      education: 'MBIS',
      imageAsset: 'assets/images/yumeng.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Scaffold(
      backgroundColor: AppColors.detailBackdrop,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'MEET THE TEAM',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            letterSpacing: 0.7,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16 * s, 8 * s, 16 * s, 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24 * s),
              child: Image.asset(
                'assets/images/team.png',
                height: Adaptive.clamp(context, 242, min: 220, max: 260),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    height: Adaptive.clamp(context, 242, min: 220, max: 260),
                    color: AppColors.lightSage,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.groups_2_outlined,
                      color: AppColors.accent.withValues(alpha: 0.65),
                      size: 44 * s,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12 * s),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14 * s,
                mainAxisSpacing: 14 * s,
                childAspectRatio: 1.14,
              ),
              itemBuilder: (context, index) => _TeamMemberCard(member: _members[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.role,
    required this.age,
    required this.education,
    required this.imageAsset,
  });

  final String name;
  final String role;
  final int age;
  final String education;
  final String imageAsset;
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member});

  final _TeamMember member;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Container(
      padding: EdgeInsets.all(11 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7EF),
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MemberAvatar(imageAsset: member.imageAsset),
              SizedBox(width: 8 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: Adaptive.clamp(context, 13.8, min: 11.5, max: 15),
                        height: 1.16,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      member.role,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textBodyOnFrost,
                        fontWeight: FontWeight.w500,
                        fontSize: Adaptive.clamp(context, 11.4, min: 9.8, max: 12.2),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * s),
          Divider(color: AppColors.divider.withValues(alpha: 0.82), height: 1),
          SizedBox(height: 6 * s),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 14 * s, color: AppColors.textBodyOnFrost),
              SizedBox(width: 6 * s),
              Text(
                '${member.age}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textBodyOnFrost,
                  fontWeight: FontWeight.w600,
                  fontSize: Adaptive.clamp(context, 11.8, min: 10, max: 12.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          Row(
            children: [
              Icon(Icons.school_outlined, size: 14 * s, color: AppColors.textBodyOnFrost),
              SizedBox(width: 6 * s),
              Text(
                member.education,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textBodyOnFrost,
                  fontWeight: FontWeight.w600,
                  fontSize: Adaptive.clamp(context, 11.8, min: 10, max: 12.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return ClipOval(
      child: Image.asset(
        imageAsset,
        width: 70 * s,
        height: 70 * s,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 70 * s,
            height: 70 * s,
            color: AppColors.lightSage,
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              color: AppColors.accent.withValues(alpha: 0.58),
              size: 30 * s,
            ),
          );
        },
      ),
    );
  }
}
