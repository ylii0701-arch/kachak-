import 'package:flutter/material.dart';

class DifficultyStars extends StatelessWidget {
  const DifficultyStars({
    super.key,
    required this.level,
    this.size = 16,
  });

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < level;
        return Icon(
          Icons.star,
          size: size,
          color: filled ? const Color(0xFFFBBF24) : Colors.grey.shade300,
        );
      }),
    );
  }
}
