import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tour_anchor.dart';

/// Known spotlight anchor ids used across in-app guided tours.
class TourTargetIds {
  TourTargetIds._();

  static const homeSearch = 'tour.home.search';
  static const homeFilterButton = 'tour.home.filter.button';
  static const homeFilterPanel = 'tour.home.filter.panel';
  static const homeFilterTabs = 'tour.home.filter.tabs';
  static const homeSortButton = 'tour.home.sort.button';
  static const homeLayoutButton = 'tour.home.layout.button';
  static const homeSpeciesCard = 'tour.home.species.card';
  static const homeSaveButton = 'tour.home.save.button';
  static const homeNavMap = 'tour.home.nav.map';
  static const homeNavIdentify = 'tour.home.nav.identify';
  static const homeNavMission = 'tour.home.nav.mission';
  static const homeNavSaved = 'tour.home.nav.saved';
  static const homeAiChat = 'tour.home.ai.chat';

  static const mapSearch = 'tour.map.search';
  static const mapWeatherMarker = 'tour.map.weather.marker';
  static const mapPhotoMarker = 'tour.map.photo.marker';
  static const mapAnimalMarker = 'tour.map.animal.marker';
  static const mapToolRefresh = 'tour.map.tool.refresh';
  static const mapToolWeather = 'tour.map.tool.weather';
  static const mapToolFocus = 'tour.map.tool.focus';
  static const mapToolMyLocation = 'tour.map.tool.my.location';
  static const mapToolZoomIn = 'tour.map.tool.zoom.in';
  static const mapToolZoomOut = 'tour.map.tool.zoom.out';
  static const mapSpeciesViewMore = 'tour.map.species.view.more';

  static const detailSaveFavorite = 'tour.detail.save.favorite';
  static const detailNotification = 'tour.detail.notification';
  static const detailPredictionCard = 'tour.detail.prediction.card';
  static const detailHabitatLocations = 'tour.detail.habitat.locations';
  static const detailFirstObservation = 'tour.detail.first.observation';
  static const detailFirstObservationMapButton =
      'tour.detail.first.observation.map.button';
}

/// Simple command bus for triggering runtime actions during tour steps.
class TourRuntimeCommand {
  TourRuntimeCommand._();

  static final ValueNotifier<String?> command = ValueNotifier<String?>(null);

  static void send(String? value) {
    // Force listeners to run even when the same command repeats across steps.
    if (value != null && command.value == value) {
      command.value = null;
    }
    command.value = value;
  }
}

/// Immutable definition for a single spotlight tour step.
class SpotlightStep {
  const SpotlightStep({
    required this.targetId,
    required this.title,
    required this.body,
    this.onEnterCommand,
    this.cardPlacement = SpotlightCardPlacement.auto,
  });

  final String targetId;
  final String title;
  final String body;
  final String? onEnterCommand;
  final SpotlightCardPlacement cardPlacement;
}

enum SpotlightCardPlacement { auto, above, below }

/// Overlay entry helper that launches a full spotlight walkthrough.
class SpotlightTour {
  SpotlightTour._();

  static Future<void> show(
    BuildContext context, {
    required List<SpotlightStep> steps,
    required Future<void> Function() onComplete,
  }) async {
    if (steps.isEmpty) {
      await onComplete();
      return;
    }
    final completer = Completer<void>();
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SpotlightTourOverlay(
        steps: steps,
        onFinish: () async {
          entry.remove();
          await onComplete();
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    overlay.insert(entry);
    await completer.future;
  }
}

class _SpotlightTourOverlay extends StatefulWidget {
  const _SpotlightTourOverlay({
    required this.steps,
    required this.onFinish,
  });

  final List<SpotlightStep> steps;
  final Future<void> Function() onFinish;

  @override
  State<_SpotlightTourOverlay> createState() => _SpotlightTourOverlayState();
}

class _SpotlightTourOverlayState extends State<_SpotlightTourOverlay> {
  int _index = 0;
  Rect? _targetRect;
  int _resolveTicket = 0;

  SpotlightStep get _step => widget.steps[_index];

  @override
  void initState() {
    super.initState();
    TourRuntimeCommand.send(_step.onEnterCommand);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveTargetWithRetries());
  }

  @override
  void dispose() => super.dispose();

  void _refreshTarget() {
    final key = TourAnchors.key(_step.targetId);
    final context = key.currentContext;
    if (context == null) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final media = MediaQuery.of(context);
    final safe = media.padding;
    final screen = media.size;
    final globalRect = MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
    Rect inflated = globalRect.inflate(8);

    // Web can occasionally report a button anchor as a very wide strip.
    // For target ids meant to be buttons, clamp width to a reasonable span.
    final looksLikeButton = _step.targetId.endsWith('.button');
    if (looksLikeButton && inflated.width > (screen.width * 0.78)) {
      final preferredWidth = math.min(
        math.max(inflated.height * 3.4, 88.0),
        220.0,
      );
      inflated = Rect.fromLTWH(
        inflated.left,
        inflated.top,
        preferredWidth,
        inflated.height,
      );
    }

    final rect = Rect.fromLTRB(
      inflated.left.clamp(8.0, screen.width - 8.0),
      inflated.top.clamp(safe.top + 8.0, screen.height - safe.bottom - 12.0),
      inflated.right.clamp(8.0, screen.width - 8.0),
      inflated.bottom.clamp(safe.top + 8.0, screen.height - safe.bottom - 12.0),
    );
    if (_targetRect != rect && mounted) {
      setState(() => _targetRect = rect);
    }
  }

  Future<void> _next() async {
    if (_index >= widget.steps.length - 1) {
      TourRuntimeCommand.send(null);
      await widget.onFinish();
      return;
    }
    setState(() {
      _index += 1;
      _targetRect = null;
    });
    TourRuntimeCommand.send(_step.onEnterCommand);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveTargetWithRetries());
  }

  Future<void> _resolveTargetWithRetries() async {
    _resolveTicket += 1;
    final ticket = _resolveTicket;
    const attempts = <Duration>[
      Duration.zero,
      Duration(milliseconds: 16),
      Duration(milliseconds: 48),
      Duration(milliseconds: 96),
      Duration(milliseconds: 160),
      Duration(milliseconds: 240),
    ];
    for (final delay in attempts) {
      if (!mounted || ticket != _resolveTicket) return;
      if (delay != Duration.zero) {
        await Future<void>.delayed(delay);
      }
      _refreshTarget();
      if (_targetRect != null) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final hasResolvedTarget = _targetRect != null;
    final rect =
        _targetRect ??
        Rect.fromLTWH(
          size.width * 0.2,
          safeTop + 80,
          size.width * 0.6,
          56,
        );

    const cardHeight = 170.0;
    final showAbove = switch (_step.cardPlacement) {
      SpotlightCardPlacement.above => true,
      SpotlightCardPlacement.below => false,
      SpotlightCardPlacement.auto => rect.center.dy > (size.height * 0.62),
    };
    final cardTop = showAbove
        ? math.max(safeTop + 12, rect.top - cardHeight - 12)
        : math.min(size.height - safeBottom - cardHeight - 10, rect.bottom + 12);
    final dimColor = Colors.black.withValues(alpha: 0.58);

    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            if (hasResolvedTarget) ...[
              Positioned.fill(
                child: ClipPath(
                  clipper: _SpotlightDimClipper(cutout: rect),
                  child: ColoredBox(color: dimColor),
                ),
              ),
              Positioned.fromRect(
                rect: rect,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE3F2D6),
                        width: 2.2,
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              Positioned.fill(
                child: ColoredBox(color: dimColor),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: 14,
              right: 14,
              top: cardTop,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _TooltipCard(
                    key: ValueKey<int>(_index),
                    index: _index,
                    total: widget.steps.length,
                    step: _step,
                    onNext: _next,
                    onSkip: () async {
                      TourRuntimeCommand.send(null);
                      await widget.onFinish();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    super.key,
    required this.index,
    required this.total,
    required this.step,
    required this.onNext,
    required this.onSkip,
  });

  final int index;
  final int total;
  final SpotlightStep step;
  final Future<void> Function() onNext;
  final Future<void> Function() onSkip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLast = index == total - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E1D5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF194E47),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.body,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(l?.onboardingSkip ?? 'Skip'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(total, (i) {
                        final active = i == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF7BAA73)
                                : const Color(0xFFD8E4D4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              FilledButton(
                onPressed: onNext,
                child: Text(isLast ? 'Done' : (l?.onboardingNext ?? 'Next')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightDimClipper extends CustomClipper<Path> {
  const _SpotlightDimClipper({required this.cutout});

  final Rect cutout;

  @override
  Path getClip(Size size) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(cutout, const Radius.circular(16)),
      );
  }

  @override
  bool shouldReclip(covariant _SpotlightDimClipper oldClipper) =>
      oldClipper.cutout != cutout;
}

