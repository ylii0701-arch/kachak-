import 'package:flutter/material.dart';

import '../utils/adaptive.dart';
import 'assistant_panel.dart';
import 'onboarding/tour_anchor.dart';

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
    this.tourAnchorId,
    this.showFab = true,
  });

  final Widget child;

  /// Space to keep clear at bottom (e.g. bottom nav height).
  final double reservedBottom;
  final String? tourAnchorId;
  final bool showFab;

  @override
  State<AssistantOverlayLayer> createState() => _AssistantOverlayLayerState();
}

class _AssistantOverlayLayerState extends State<AssistantOverlayLayer>
    with SingleTickerProviderStateMixin {
  bool _assistantVisible = false;
  bool _fabPressed = false;
  bool _fabDragging = false;

  final _fab = _FabPosition.instance;

  late final AnimationController _fabSnapController;
  double _fabSnapFrom = 0;
  double _fabSnapTo = 0;

  static const double _fabSize = 62;
  static const double _fabEdgeMargin = 18;
  static const Duration _fabPressAnimDuration = Duration(milliseconds: 120);
  static const Duration _overlayAnimDuration = Duration(milliseconds: 420);
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

  @override
  void didUpdateWidget(covariant AssistantOverlayLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showFab && _assistantVisible) {
      _closeAssistant();
    }
  }

  void _onFabPositionChanged() {
    if (mounted) setState(() {});
  }

  void _toggleAssistant() {
    setState(() {
      _fabPressed = false;
      _fabDragging = false;
      _assistantVisible = !_assistantVisible;
    });
  }

  void _closeAssistant() {
    setState(() {
      _fabPressed = false;
      _fabDragging = false;
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
    _fabDragging = false;
    _fabPressed = false;
    _fabSnapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = media.size;
    final safe = media.padding;
    final keyboardInset = media.viewInsets.bottom;
    final fullLogicalHeight =
        View.of(context).physicalSize.height / View.of(context).devicePixelRatio;
    final alreadyResizedByKeyboard =
        keyboardInset > 0 && (fullLogicalHeight - viewport.height) > (keyboardInset * 0.6);
    final overlayKeyboardOffset =
        (keyboardInset > 0 && !alreadyResizedByKeyboard) ? keyboardInset : 0.0;
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
        if (widget.showFab && !_assistantVisible)
          Positioned(
            left: fabX,
            top: fabY,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _fabDragging = true;
                  _fabPressed = true;
                });
              },
              onPanUpdate: (d) => _onFabDragUpdate(d, viewport, safe, s),
              onPanEnd: (_) => _onFabDragEnd(viewport.width, s),
              onPanCancel: () {
                setState(() {
                  _fabDragging = false;
                  _fabPressed = false;
                });
              },
              child: Builder(
                builder: (context) {
                  Widget fabButton = Semantics(
                    label: 'Open assistant chat',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTapDown: (_) => setState(() => _fabPressed = true),
                        onTapCancel: () => setState(() => _fabPressed = false),
                        onTap: _toggleAssistant,
                        child: AnimatedScale(
                          duration: _fabPressAnimDuration,
                          curve: Curves.easeOutCubic,
                          scale: _fabDragging ? 0.9 : (_fabPressed ? 0.94 : 1),
                          child: AnimatedContainer(
                            duration: _fabPressAnimDuration,
                            curve: Curves.easeOutCubic,
                            width: _fabSize * s,
                            height: _fabSize * s,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: _fabPressed ? 0.14 : 0.18,
                                  ),
                                  blurRadius: (_fabPressed ? 12 : 18) * s,
                                  offset: Offset(0, (_fabPressed ? 4 : 8) * s),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Center(
                                    child: Transform.scale(
                                      scale: 1.88,
                                      child: Image.asset(
                                        'assets/images/ai_chatbot_icon.png',
                                        fit: BoxFit.cover,
                                        alignment: const Alignment(0, 0.34),
                                      ),
                                    ),
                                  ),
                                  IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  if (widget.tourAnchorId != null) {
                    fabButton = TourAnchor(
                      id: widget.tourAnchorId!,
                      child: fabButton,
                    );
                  }
                  return fabButton;
                },
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_assistantVisible,
            child: AnimatedOpacity(
              duration: _overlayAnimDuration,
              curve: Curves.easeOutQuart,
              opacity: _assistantVisible ? 1 : 0,
              child: GestureDetector(
                onTap: _closeAssistant,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          left: 10 * s,
          right: 10 * s,
          top: safe.top + 8,
          bottom: safe.bottom + widget.reservedBottom + 4 + overlayKeyboardOffset,
          child: IgnorePointer(
            ignoring: !_assistantVisible,
            child: AnimatedSlide(
              duration: _overlayAnimDuration,
              curve: Curves.easeOutQuart,
              offset: _assistantVisible ? Offset.zero : const Offset(0, 0.15),
              child: AnimatedScale(
                duration: _overlayAnimDuration,
                curve: Curves.easeOutBack,
                scale: _assistantVisible ? 1 : 0.92,
                child: AnimatedOpacity(
                  duration: _overlayAnimDuration,
                  curve: Curves.easeOutQuart,
                  opacity: _assistantVisible ? 1 : 0,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 16,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    clipBehavior: Clip.antiAlias,
                    child: AssistantPanel(onClose: _closeAssistant),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
