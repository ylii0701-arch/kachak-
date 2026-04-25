import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import 'assistant_panel.dart';

/// Shared singleton that holds the FAB position so every
/// [AssistantOverlayLayer] instance stays in sync.
class _FabPosition extends ChangeNotifier {
  _FabPosition._();
  static final instance = _FabPosition._();

  double? y;
  bool onRight = true;

  void update({double? newY, bool? newOnRight}) {
    var changed = false;
    if (newY != null && newY != y) {
      y = newY;
      changed = true;
    }
    if (newOnRight != null && newOnRight != onRight) {
      onRight = newOnRight;
      changed = true;
    }
    if (changed) notifyListeners();
  }
}

/// Reusable AI chat launcher + overlay layer for any screen.
///
/// - FAB can be dragged freely.
/// - FAB always snaps to nearest left/right edge on release.
/// - Chat panel opens as a full-height overlay above [child].
class AssistantOverlayLayer extends StatefulWidget {
  const AssistantOverlayLayer({
    super.key,
    required this.child,
    this.reservedBottom = 0,
  });

  final Widget child;

  /// Space to keep clear at bottom (e.g. bottom nav height).
  final double reservedBottom;

  @override
  State<AssistantOverlayLayer> createState() => _AssistantOverlayLayerState();
}

class _AssistantOverlayLayerState extends State<AssistantOverlayLayer>
    with SingleTickerProviderStateMixin {
  bool _assistantVisible = false;

  final _fab = _FabPosition.instance;

  late final AnimationController _fabSnapController;
  double _fabSnapFrom = 0;
  double _fabSnapTo = 0;

  static const double _fabSize = 62;
  static const double _fabEdgeMargin = 18;
  double? _fabDragX;

  @override
  void initState() {
    super.initState();
    _fab.addListener(_onFabPositionChanged);
    _fabSnapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          setState(() {});
        });
  }

  @override
  void dispose() {
    _fab.removeListener(_onFabPositionChanged);
    _fabSnapController.dispose();
    super.dispose();
  }

  void _onFabPositionChanged() {
    if (mounted) setState(() {});
  }

  void _toggleAssistant() {
    setState(() {
      _assistantVisible = !_assistantVisible;
    });
  }

  void _closeAssistant() {
    setState(() {
      _assistantVisible = false;
    });
  }

  double _fabX(double viewportWidth, double s) {
    if (_fabSnapController.isAnimating) {
      final t = Curves.easeOutCubic.transform(_fabSnapController.value);
      return _fabSnapFrom + (_fabSnapTo - _fabSnapFrom) * t;
    }
    return _fab.onRight
        ? viewportWidth - _fabSize * s - _fabEdgeMargin * s
        : _fabEdgeMargin * s;
  }

  void _onFabDragUpdate(
    DragUpdateDetails d,
    Size viewport,
    EdgeInsets safe,
    double s,
  ) {
    final currentY =
        _fab.y ??
        viewport.height -
            safe.bottom -
            widget.reservedBottom -
            _fabSize * s -
            8;
    _fab.update(
      newY: (currentY + d.delta.dy).clamp(
        safe.top + 10,
        viewport.height -
            safe.bottom -
            widget.reservedBottom -
            _fabSize * s -
            8,
      ),
    );

    setState(() {
      _fabDragX = (_fabDragX ?? _fabX(viewport.width, s)) + d.delta.dx;
      _fabDragX = _fabDragX!.clamp(
        _fabEdgeMargin * s,
        viewport.width - _fabSize * s - _fabEdgeMargin * s,
      );
    });
  }

  void _onFabDragEnd(double viewportWidth, double s) {
    final currentX = _fabDragX ?? _fabX(viewportWidth, s);
    final center = currentX + _fabSize * s / 2;
    final goRight = center >= viewportWidth / 2;

    final targetX = goRight
        ? viewportWidth - _fabSize * s - _fabEdgeMargin * s
        : _fabEdgeMargin * s;

    _fabSnapFrom = currentX;
    _fabSnapTo = targetX;
    _fab.update(newOnRight: goRight);
    _fabDragX = null;
    _fabSnapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = media.size;
    final safe = media.padding;
    final s = Adaptive.scale(context);
    final fabY =
        _fab.y ??
        viewport.height -
            safe.bottom -
            widget.reservedBottom -
            _fabSize * s -
            8;
    final fabX = _fabDragX ?? _fabX(viewport.width, s);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_assistantVisible)
          Positioned(
            left: fabX,
            top: fabY,
            child: GestureDetector(
              onPanUpdate: (d) => _onFabDragUpdate(d, viewport, safe, s),
              onPanEnd: (_) => _onFabDragEnd(viewport.width, s),
              child: Semantics(
                label: 'Open assistant chat',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _toggleAssistant,
                    child: Container(
                      width: _fabSize * s,
                      height: _fabSize * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 28 * s,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (_assistantVisible) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeAssistant,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
          Positioned(
            left: 10 * s,
            right: 10 * s,
            top: safe.top + 8,
            bottom: safe.bottom + widget.reservedBottom + 4,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              elevation: 16,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              clipBehavior: Clip.antiAlias,
              child: AssistantPanel(onClose: _closeAssistant),
            ),
          ),
        ],
      ],
    );
  }
}
