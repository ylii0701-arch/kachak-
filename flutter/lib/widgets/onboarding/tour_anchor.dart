import 'package:flutter/material.dart';

class TourAnchors {
  TourAnchors._();

  static final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  static GlobalKey key(String id) => _keys.putIfAbsent(id, GlobalKey.new);
}

class TourAnchor extends StatelessWidget {
  const TourAnchor({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: TourAnchors.key(id),
      child: child,
    );
  }
}

