import 'package:flutter/material.dart';

/// Registry of global keys used to anchor spotlight tour targets.
class TourAnchors {
  TourAnchors._();

  static final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  /// Returns a stable key for the provided target id.
  static GlobalKey key(String id) => _keys.putIfAbsent(id, GlobalKey.new);
}

/// Wraps a widget with a stable key used by spotlight tour overlays.
class TourAnchor extends StatelessWidget {
  const TourAnchor({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  /// Binds [child] to a stable key so the spotlight can locate it.
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: TourAnchors.key(id),
      child: child,
    );
  }
}

