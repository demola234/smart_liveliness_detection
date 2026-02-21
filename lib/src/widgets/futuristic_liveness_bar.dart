import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/liveness_controller.dart';
import '../painters/background_glow_painter.dart';
import '../painters/chronos_painter.dart';
import '../painters/cosmos_painter.dart';
import '../painters/floating_painter.dart';
import '../painters/hologram_painter.dart';
import '../painters/kinetic_painter.dart';
import '../painters/liquid_metal_painter.dart';
import '../painters/liveness_ui_style.dart';
import '../painters/monolith_painter.dart';
import '../painters/obsidian_painter.dart';
import '../painters/prism_painter.dart';
import '../painters/quantum_painter.dart';
import '../painters/singularity_painter.dart';
import '../painters/sumi_painter.dart';
import '../painters/synapse_painter.dart';
import '../theme/futuristic_theme.dart';
import '../utils/enums.dart';

/// Maps a [ChallengeType] to a short display emoji/text.
String _challengeIcon(ChallengeType type) => switch (type) {
      ChallengeType.blink => '👁',
      ChallengeType.turnLeft => '←',
      ChallengeType.turnRight => '→',
      ChallengeType.smile => '😊',
      ChallengeType.nod => '↕',
      ChallengeType.tiltUp => '↑',
      ChallengeType.tiltDown => '↓',
      ChallengeType.normal => '😐',
      ChallengeType.zoom => '🔍',
    };

/// Builds the correct [CustomPainter] for a given [LivenessUiStyle].
CustomPainter buildStylePainter({
  required LivenessUiStyle style,
  required int count,
  required double animationValue,
  required double idleTime,
  required double pressValue,
  FuturisticTheme? themeOverride,
  Map<String, Color> customColors = const {},
  Map<String, bool> effectToggles = const {},
}) {
  final t = themeOverride ?? style.theme;
  return switch (style) {
    LivenessUiStyle.quantum => QuantumPainter(
        progress: animationValue,
        totalItems: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.liquidMetal => LiquidMetalPainter(
        progress: animationValue,
        totalItems: count,
        squash: pressValue,
        theme: t,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.cosmos => CosmosPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.hologram => HologramPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.singularity => SingularityPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.synapse => SynapsePainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.kinetic => KineticPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.prism => PrismPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.obsidian => ObsidianPainter(
        animationValue: animationValue,
        count: count,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.monolith => MonolithPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.chronos => ChronosPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.floating => FloatingPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
    LivenessUiStyle.sumi => SumiPainter(
        animationValue: animationValue,
        count: count,
        idleTime: idleTime,
        theme: t,
        pressValue: pressValue,
        customColors: customColors,
        effectToggles: effectToggles,
      ),
  };
}

// ─────────────────────────────────────────────────────────────────────────────

/// An animated challenge-progress bar driven by a [LivenessController] from
/// the ambient Provider context.
///
/// Place this widget anywhere *inside* the [Provider] tree that
/// [LivenessDetectionScreen] sets up — typically near the bottom of the stack.
///
/// ```dart
/// FuturisticLivenessBar(
///   style: LivenessUiStyle.quantum,
///   showChallengeLabels: true,
/// )
/// ```
class FuturisticLivenessBar extends StatefulWidget {
  /// Which painter to use.
  final LivenessUiStyle style;

  /// Height of the painted bar area.
  final double height;

  /// Horizontal padding applied around the bar.
  final EdgeInsets padding;

  /// Override the auto-selected [FuturisticTheme] for the chosen style.
  final FuturisticTheme? themeOverride;

  /// When `true`, draws a row of challenge-type icons above the bar,
  /// one per slot, greyed out for future challenges, bright for the active
  /// slot and ticked for completed ones.
  final bool showChallengeLabels;

  const FuturisticLivenessBar({
    super.key,
    required this.style,
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.themeOverride,
    this.showChallengeLabels = true,
  });

  @override
  State<FuturisticLivenessBar> createState() => _FuturisticLivenessBarState();
}

class _FuturisticLivenessBarState extends State<FuturisticLivenessBar>
    with TickerProviderStateMixin {
  // Slide from challenge index → next, e.g. 0.0 → 1.0 → 2.0
  late final AnimationController _moveCtrl;

  // Continuously ticking idle time (used by painters for loops/drift)
  late final AnimationController _idleCtrl;

  // One-shot burst played when a challenge completes
  late final AnimationController _pressCtrl;

  // The interpolated move value (challenge index as float)
  late Animation<double> _moveAnim;

  LivenessController? _bound;
  int _lastIndex = 0;

  // Display state — updated imperatively by the listener so that build()
  // never needs to call context.watch (which would rebuild on every camera frame).
  List<dynamic> _challenges = [];
  int _completedIdx = 0;

  @override
  void initState() {
    super.initState();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _moveAnim = Tween<double>(begin: 0.0, end: 0.0).animate(_moveCtrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = Provider.of<LivenessController>(context, listen: false);
    if (_bound != ctrl) {
      _bound?.removeListener(_onControllerUpdate);
      _bound = ctrl;
      _bound!.addListener(_onControllerUpdate);

      // Sync immediately to current state (e.g. after a screen resume)
      _lastIndex = ctrl.session.currentChallengeIndex;
      _challenges = ctrl.session.challenges;
      _completedIdx = _lastIndex;
      _moveAnim = Tween<double>(
        begin: _lastIndex.toDouble(),
        end: _lastIndex.toDouble(),
      ).animate(_moveCtrl);
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _bound == null) return;
    final idx = _bound!.session.currentChallengeIndex;
    if (idx != _lastIndex) {
      final from = _moveAnim.value;
      _moveAnim = Tween<double>(begin: from, end: idx.toDouble()).animate(
        CurvedAnimation(parent: _moveCtrl, curve: Curves.easeInOutCubic),
      );
      _moveCtrl
        ..reset()
        ..forward();
      _pressCtrl
        ..reset()
        ..forward();
      _lastIndex = idx;
      // Single rebuild to update the challenge-label row — NOT triggered by
      // every camera frame, only when the challenge index advances.
      setState(() {
        _completedIdx = idx;
        _challenges = _bound!.session.challenges;
      });
    }
  }

  @override
  void dispose() {
    _bound?.removeListener(_onControllerUpdate);
    _moveCtrl.dispose();
    _idleCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No context.watch — display state is cached in _challenges / _completedIdx
    // and refreshed only when a challenge completes, keeping rebuild cost minimal.
    final count = math.max(1, _challenges.length);

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Challenge label row ──────────────────────────────────────────
          if (widget.showChallengeLabels && _challenges.isNotEmpty)
            _ChallengeLabels(
              challenges: _challenges,
              completedIndex: _completedIdx,
              accentColor: (widget.themeOverride ?? widget.style.theme).accentColor,
            ),

          const SizedBox(height: 6),

          // ── Futuristic painted bar ───────────────────────────────────────
          // RepaintBoundary isolates the 60 fps CustomPainter repaints so they
          // don't trigger repaints of any ancestor widget.
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_moveCtrl, _idleCtrl, _pressCtrl]),
              builder: (_, __) {
                final press = CurvedAnimation(
                  parent: _pressCtrl,
                  curve: Curves.easeOut,
                ).value;
                return SizedBox(
                  height: widget.height,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: buildStylePainter(
                      style: widget.style,
                      count: count,
                      animationValue: _moveAnim.value,
                      idleTime: _idleCtrl.value * 60.0,
                      pressValue: press,
                      themeOverride: widget.themeOverride,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Row of challenge-type icons sitting above the bar.
class _ChallengeLabels extends StatelessWidget {
  final List challenges; // List<Challenge>
  final int completedIndex;
  final Color accentColor;

  const _ChallengeLabels({
    required this.challenges,
    required this.completedIndex,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(challenges.length, (i) {
        final isCompleted = i < completedIndex;
        final isActive = i == completedIndex;

        final icon = _challengeIcon(challenges[i].type as ChallengeType);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isCompleted || isActive ? 1.0 : 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isActive ? 18 : 14,
                ),
                child: Text(icon),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 6 : 4,
                height: isActive ? 6 : 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isActive
                          ? accentColor
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// A standalone preview-only bar — no Provider needed.
///
/// Useful for displaying a static/animated sample of a style in the
/// [LivenessStylePicker].
class FuturisticBarPreview extends StatefulWidget {
  final LivenessUiStyle style;
  final double height;
  final double idleTime;

  const FuturisticBarPreview({
    super.key,
    required this.style,
    this.height = 56,
    this.idleTime = 0,
  });

  @override
  State<FuturisticBarPreview> createState() => _FuturisticBarPreviewState();
}

class _FuturisticBarPreviewState extends State<FuturisticBarPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _idle,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: buildStylePainter(
            style: widget.style,
            count: 3,
            animationValue: 1.0, // center item active
            idleTime: _idle.value * 60.0 + widget.idleTime,
            pressValue: 0.0,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// An ambient glow layer that can sit *behind* the camera preview, reacting
/// to which challenge is currently active.
///
/// Uses [BackgroundGlowPainter] to fill the full widget area with a soft,
/// pulsing radial glow centred on the active challenge slot.
class FuturisticAmbientGlow extends StatefulWidget {
  final LivenessUiStyle style;

  const FuturisticAmbientGlow({super.key, required this.style});

  @override
  State<FuturisticAmbientGlow> createState() => _FuturisticAmbientGlowState();
}

class _FuturisticAmbientGlowState extends State<FuturisticAmbientGlow>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _move;
  late Animation<double> _moveAnim;
  LivenessController? _bound;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _move = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _moveAnim = Tween<double>(begin: 0.0, end: 0.0).animate(_move);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = Provider.of<LivenessController>(context, listen: false);
    if (_bound != ctrl) {
      _bound?.removeListener(_onUpdate);
      _bound = ctrl;
      _bound!.addListener(_onUpdate);
      _lastIndex = ctrl.session.currentChallengeIndex;
      _moveAnim = Tween<double>(
        begin: _lastIndex.toDouble(),
        end: _lastIndex.toDouble(),
      ).animate(_move);
    }
  }

  void _onUpdate() {
    if (!mounted || _bound == null) return;
    final idx = _bound!.session.currentChallengeIndex;
    if (idx != _lastIndex) {
      final from = _moveAnim.value;
      _moveAnim = Tween<double>(begin: from, end: idx.toDouble()).animate(
        CurvedAnimation(parent: _move, curve: Curves.easeInOut),
      );
      _move
        ..reset()
        ..forward();
      _lastIndex = idx;
    }
  }

  @override
  void dispose() {
    _bound?.removeListener(_onUpdate);
    _idle.dispose();
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use listen:false — count only changes when the challenge list changes,
    // which is handled by the imperative listener already set up in
    // didChangeDependencies. Avoids rebuilds on every camera frame.
    final ctrl = Provider.of<LivenessController>(context, listen: false);
    final count = math.max(1, ctrl.session.challenges.length);
    final theme = widget.style.theme;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / count;
          return AnimatedBuilder(
            animation: Listenable.merge([_idle, _move]),
            builder: (_, __) {
              final activeX = (_moveAnim.value + 0.5) * itemWidth;
              return CustomPaint(
                size: Size.infinite,
                painter: BackgroundGlowPainter(
                  activeX: activeX,
                  totalItems: count,
                  theme: theme,
                  pulse: _idle.value,
                  rotation: _idle.value * 2 * math.pi * 60,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
