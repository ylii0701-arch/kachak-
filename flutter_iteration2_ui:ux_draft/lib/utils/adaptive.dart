import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight adaptive sizing helpers for phones/tablets.
class Adaptive {
  static double scale(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    if (shortest <= 320) return 0.85;
    if (shortest <= 360) return 0.92;
    if (shortest <= 400) return 0.97;
    if (shortest <= 600) return 1.0;
    if (shortest <= 900) return 1.08;
    return 1.16;
  }

  static double of(BuildContext context, double value) => value * scale(context);

  static double clamp(
    BuildContext context,
    double value, {
    required double min,
    required double max,
  }) {
    return of(context, value).clamp(min, max);
  }

  static EdgeInsets insets(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    final s = scale(context);
    return EdgeInsets.symmetric(horizontal: horizontal * s, vertical: vertical * s);
  }

  static int adaptiveGridCount(
    BuildContext context, {
    double minTileWidth = 180,
    int min = 1,
    int max = 4,
    double horizontalPadding = 32,
    double spacing = 12,
  }) {
    final width = MediaQuery.sizeOf(context).width - horizontalPadding;
    final raw = ((width + spacing) / (minTileWidth + spacing)).floor();
    return math.max(min, math.min(max, raw));
  }
}
