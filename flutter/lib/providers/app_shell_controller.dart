import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Drives bottom navigation and one-shot "open map here" jumps from other screens.
class AppShellController extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  LatLng? _mapJump;
  double _mapJumpZoom = 14;
  String? _mapJumpSpeciesId;

  void selectTab(int i) {
    if (_index == i) return;
    _index = i;
    notifyListeners();
  }

  /// Switches to the Map tab and queues a camera move for [MapScreen] to consume.
  void openMapAt(LatLng point, {double zoom = 15, String? speciesId}) {
    _mapJump = point;
    _mapJumpZoom = zoom;
    _mapJumpSpeciesId = speciesId;
    _index = 4;
    notifyListeners();
  }

  /// Returns a pending map target if any, then clears it. Only [MapScreen] should call this.
  ({LatLng point, double zoom, String? speciesId})? consumeMapJump() {
    final p = _mapJump;
    if (p == null) return null;
    _mapJump = null;
    final z = _mapJumpZoom;
    final speciesId = _mapJumpSpeciesId;
    _mapJumpSpeciesId = null;
    return (point: p, zoom: z, speciesId: speciesId);
  }
}
