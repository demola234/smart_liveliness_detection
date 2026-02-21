import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../painters/liveness_ui_style.dart';
import 'futuristic_liveness_bar.dart';

/// A full-screen overlay that draws a futuristic HUD-style oval face frame
/// driven by the active [LivenessUiStyle].
///
/// Every style gets a custom oval border that matches its visual character:
///   • Cosmos   – twinkling star sparkles orbiting the oval
///   • Quantum  – segmented arc with glowing diamond nodes
///   • Hologram – multi-layer scanline projection rings
///   • Synapse  – neural nodes with a traveling bio-pulse
///   • Kinetic  – animated chevron tiles that appear to rotate
///   • Chronos  – gear-precision tick marks (minor/major/cardinal)
///   • Prism    – full-spectrum rainbow hue sweep
///   • LiquidMetal – triple-stroke chrome with specular highlight
///   • Obsidian – sharp V-notch cuts into the border
///   • Singularity – concentric expansion rings (gravitational lensing)
///   • Monolith – minimal razor-thin line with slit highlights
///   • Floating – soft bubbly circles orbiting gently
///   • Sumi     – varied-width ink-brush strokes
///
/// The progress ring uses the style's [CustomPainter] art clipped to an
/// annular-sector around the oval that grows clockwise with [progress].
class FuturisticOvalOverlay extends StatefulWidget {
  final bool isFaceDetected;
  final LivenessConfig config;
  final LivenessTheme theme;

  /// Overall verification progress (0.0 – 1.0).
  final double progress;

  /// Active futuristic style — drives accent colour and painter art.
  final LivenessUiStyle style;

  /// Current camera zoom factor (mirrors [LivenessController.zoomFactor]).
  final double zoomFactor;

  const FuturisticOvalOverlay({
    super.key,
    required this.isFaceDetected,
    required this.config,
    required this.theme,
    required this.progress,
    required this.style,
    this.zoomFactor = 1.0,
  });

  @override
  State<FuturisticOvalOverlay> createState() => _FuturisticOvalOverlayState();
}

class _FuturisticOvalOverlayState extends State<FuturisticOvalOverlay>
    with TickerProviderStateMixin {
  // Border-glow pulse (2.4 s, reverse-repeating → smooth 0↔1 oscillation)
  late final AnimationController _pulse;

  // Scan-line sweep (3 s, forward-repeating → linear 0→1 per cycle)
  late final AnimationController _scan;

  // Continuously ticking idle time (drives the style painter's animations)
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _scan.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.style.theme.accentColor;
    final bg = widget.style.theme.backgroundColor;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _scan, _idle]),
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _FuturisticOvalPainter(
            isFaceDetected: widget.isFaceDetected,
            config: widget.config,
            progress: widget.progress,
            style: widget.style,
            accentColor: accent,
            backgroundColor: bg,
            pulse: _pulse.value,
            scanValue: _scan.value,
            idleTime: _idle.value * 60.0,
            zoomFactor: widget.zoomFactor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FuturisticOvalPainter extends CustomPainter {
  final bool isFaceDetected;
  final LivenessConfig config;
  final double progress;
  final LivenessUiStyle style;
  final Color accentColor;
  final Color backgroundColor;
  final double pulse;       // 0.0 – 1.0, smooth oscillation
  final double scanValue;   // 0.0 – 1.0, linear sweep
  final double idleTime;    // 0.0 – 60.0, for style painter loops
  final double zoomFactor;

  _FuturisticOvalPainter({
    required this.isFaceDetected,
    required this.config,
    required this.progress,
    required this.style,
    required this.accentColor,
    required this.backgroundColor,
    required this.pulse,
    required this.scanValue,
    required this.idleTime,
    required this.zoomFactor,
  });

  // ── Geometry ──────────────────────────────────────────────────────────────

  Rect _ovalRect(Size size) {
    final center = Offset(size.width / 2, size.height / 2 - size.height * 0.05);
    final ovalHeight = size.height * config.ovalHeightRatio;
    final ovalWidth = ovalHeight * config.ovalWidthRatio;
    const double initialScale = 0.7;
    final double currentScale = initialScale + (1.0 - initialScale) * zoomFactor;
    return Rect.fromCenter(
      center: center,
      width: ovalWidth * currentScale,
      height: ovalHeight * currentScale,
    );
  }

  /// Point on an ellipse at [angle].
  Offset _ovalPoint(Rect oval, double angle) => Offset(
        oval.center.dx + (oval.width / 2) * math.cos(angle),
        oval.center.dy + (oval.height / 2) * math.sin(angle),
      );

  // ── Paint ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final oval = _ovalRect(size);

    _drawOverlay(canvas, size, oval);
    _drawGlowRing(canvas, oval);
    _drawStyledBorder(canvas, oval);
    _drawCornerBrackets(canvas, oval);
    if (progress > 0) _drawProgressPainter(canvas, size, oval);
    if (isFaceDetected) _drawScanLine(canvas, oval);
  }

  // ── 1. Dark themed overlay with an oval hole ──────────────────────────────

  void _drawOverlay(Canvas canvas, Size size, Rect oval) {
    final paint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(oval)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  // ── 2. Soft outer glow ring ───────────────────────────────────────────────

  void _drawGlowRing(Canvas canvas, Rect oval) {
    final alpha = 0.28 + 0.18 * pulse;
    // Glow radius varies by style character
    final blurRadius = switch (style) {
      LivenessUiStyle.singularity => 22.0,
      LivenessUiStyle.liquidMetal => 6.0,
      LivenessUiStyle.monolith    => 4.0,
      LivenessUiStyle.cosmos      => 18.0,
      _                           => 14.0,
    };
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
    );
  }

  // ── 3. Style-specific oval border ────────────────────────────────────────

  void _drawStyledBorder(Canvas canvas, Rect oval) {
    switch (style) {
      case LivenessUiStyle.cosmos:
        _drawCosmosBorder(canvas, oval);
      case LivenessUiStyle.quantum:
        _drawQuantumBorder(canvas, oval);
      case LivenessUiStyle.hologram:
        _drawHologramBorder(canvas, oval);
      case LivenessUiStyle.synapse:
        _drawSynapseBorder(canvas, oval);
      case LivenessUiStyle.kinetic:
        _drawKineticBorder(canvas, oval);
      case LivenessUiStyle.chronos:
        _drawChronosBorder(canvas, oval);
      case LivenessUiStyle.prism:
        _drawPrismBorder(canvas, oval);
      case LivenessUiStyle.liquidMetal:
        _drawLiquidMetalBorder(canvas, oval);
      case LivenessUiStyle.obsidian:
        _drawObsidianBorder(canvas, oval);
      case LivenessUiStyle.singularity:
        _drawSingularityBorder(canvas, oval);
      case LivenessUiStyle.monolith:
        _drawMonolithBorder(canvas, oval);
      case LivenessUiStyle.floating:
        _drawFloatingBorder(canvas, oval);
      case LivenessUiStyle.sumi:
        _drawSumiBorder(canvas, oval);
    }
  }

  // ── Cosmos: twinkling star sparkles orbiting the oval ─────────────────────

  void _drawCosmosBorder(Canvas canvas, Rect oval) {
    // Faint base oval
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.45 + 0.2 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 14 star sparkles at staggered angles around the oval
    final rng = math.Random(42);
    for (var i = 0; i < 14; i++) {
      final baseAngle = (i / 14) * 2 * math.pi;
      final jitter = (rng.nextDouble() - 0.5) * 0.3;
      final angle = baseAngle + jitter;

      // Each star orbits slightly outside the oval
      final orbitR = 1.0 + rng.nextDouble() * 0.12;
      final pt = Offset(
        oval.center.dx + (oval.width / 2 * orbitR) * math.cos(angle),
        oval.center.dy + (oval.height / 2 * orbitR) * math.sin(angle),
      );

      // Independent twinkle phase per star
      final twinkle = (math.sin(pulse * math.pi * 2 + i * 1.37) + 1) / 2;
      final size = 1.8 + twinkle * 2.8;
      final alpha = 0.35 + twinkle * 0.65;

      _drawStar4(canvas, pt, size, Paint()
        ..color = accentColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill);
    }
  }

  void _drawStar4(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final outerA = i * math.pi / 2 - math.pi / 4;
      final innerA = outerA + math.pi / 4;
      final op = c + Offset(math.cos(outerA) * r, math.sin(outerA) * r);
      final ip = c + Offset(math.cos(innerA) * r * 0.38, math.sin(innerA) * r * 0.38);
      if (i == 0) {
        path.moveTo(op.dx, op.dy);
      } else {
        path.lineTo(op.dx, op.dy);
      }
      path.lineTo(ip.dx, ip.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── Quantum: segmented arc with glowing diamond nodes ─────────────────────

  void _drawQuantumBorder(Canvas canvas, Rect oval) {
    const segments = 20;
    const gapFraction = 0.18;
    const segAngle = 2 * math.pi / segments;
    const drawAngle = segAngle * (1 - gapFraction);

    // Phase slowly rotates the segment grid
    final phase = pulse * segAngle * 0.5;

    for (var i = 0; i < segments; i++) {
      final startA = phase + i * segAngle;
      final brightness = i.isEven ? 0.9 : 0.55;
      canvas.drawArc(
        oval,
        startA,
        drawAngle,
        false,
        Paint()
          ..color = accentColor.withValues(alpha: brightness * (0.65 + 0.3 * pulse))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Glowing diamond nodes at 8 cardinal + intercardinal points
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + phase;
      final pt = _ovalPoint(oval, angle);
      final wave = (math.sin(pulse * math.pi * 2 + i * 0.8) + 1) / 2;
      final alpha = 0.6 + 0.4 * wave;
      final size = 3.5 + 2.5 * wave;

      // Glow
      canvas.drawCircle(
        pt,
        size + 4,
        Paint()
          ..color = accentColor.withValues(alpha: alpha * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Diamond
      final diamond = Path()
        ..moveTo(pt.dx, pt.dy - size)
        ..lineTo(pt.dx + size * 0.6, pt.dy)
        ..lineTo(pt.dx, pt.dy + size)
        ..lineTo(pt.dx - size * 0.6, pt.dy)
        ..close();
      canvas.drawPath(diamond, Paint()
        ..color = accentColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill);
    }
  }

  // ── Hologram: multi-layer scanline projection rings ───────────────────────

  void _drawHologramBorder(Canvas canvas, Rect oval) {
    // Three concentric offset rings (holographic depth)
    for (var layer = 0; layer < 3; layer++) {
      final offset = (layer - 1) * 4.0;
      final alpha = layer == 1 ? 0.75 : 0.18 + 0.1 * pulse;
      canvas.drawOval(
        oval.inflate(offset),
        Paint()
          ..color = accentColor.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer == 1 ? 1.5 : 0.8,
      );
    }

    // Scanline dashes running around the main oval
    const dashCount = 42;
    const dashAngle = (2 * math.pi / dashCount) * 0.62;
    const gapAngle = (2 * math.pi / dashCount) * 0.38;

    for (var i = 0; i < dashCount; i++) {
      final startA = i * (dashAngle + gapAngle);
      final shimmer = (math.sin(pulse * math.pi * 5 + i * 0.45) + 1) / 2;
      canvas.drawArc(
        oval.inflate(4),
        startA,
        dashAngle,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08 + shimmer * 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  // ── Synapse: neural nodes with a traveling bio-pulse wave ─────────────────

  void _drawSynapseBorder(Canvas canvas, Rect oval) {
    const nodeCount = 18;
    final angles = List.generate(nodeCount, (i) => i * 2 * math.pi / nodeCount);
    final points = angles.map((a) => _ovalPoint(oval, a)).toList();

    // Thin connecting arcs between adjacent nodes
    for (var i = 0; i < nodeCount; i++) {
      final next = (i + 1) % nodeCount;
      final alpha = 0.2 + 0.15 * math.sin(pulse * math.pi * 2 + i * 0.4).abs();
      final startA = angles[i];
      final sweepA = angles[next] - angles[i];
      canvas.drawArc(
        oval,
        startA,
        sweepA,
        false,
        Paint()
          ..color = accentColor.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
      final _ = points[i]; // reference to suppress unused warning
    }

    // Traveling pulse wave (brightest node sweeps around)
    final wavePos = pulse * nodeCount;

    for (var i = 0; i < nodeCount; i++) {
      final dist = ((i - wavePos) % nodeCount + nodeCount) % nodeCount;
      final wave = math.max(0.0, 1.0 - (dist < nodeCount / 2 ? dist : nodeCount - dist) / 3.0);
      final alpha = 0.25 + 0.75 * wave;
      final radius = 2.5 + 3.0 * wave;

      if (wave > 0.2) {
        // Glow halo behind the node
        canvas.drawCircle(
          points[i],
          radius + 5,
          Paint()
            ..color = accentColor.withValues(alpha: alpha * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawCircle(
        points[i],
        radius,
        Paint()
          ..color = accentColor.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ── Kinetic: fluid oval border with radial ripple + rotating sweep gradient ─

  void _drawKineticBorder(Canvas canvas, Rect oval) {
    // ── Build fluid oval path ────────────────────────────────────────────────
    // Each point on the oval is nudged radially by two overlapping sine waves
    // whose phases advance with idleTime, making the border continuously ripple.
    const int steps = 200;
    const double ampA = 4.5;    // primary ripple amplitude (px)
    const double ampB = 2.0;    // secondary ripple amplitude
    const double wavesA = 6.0;  // primary cycles around the oval
    const double wavesB = 13.0; // secondary cycles

    final double phaseA = idleTime * 2.2;
    final double phaseB = idleTime * 3.8 + math.pi * 0.4;
    final double breathe = 0.7 + 0.3 * math.sin(idleTime * 1.6);

    final fluidPath = Path();
    for (var i = 0; i <= steps; i++) {
      final double angle = i / steps * 2 * math.pi;
      final double ripple =
          math.sin(angle * wavesA + phaseA) * ampA * breathe +
          math.sin(angle * wavesB + phaseB) * ampB;
      final double x = oval.center.dx + (oval.width / 2 + ripple) * math.cos(angle);
      final double y = oval.center.dy + (oval.height / 2 + ripple) * math.sin(angle);
      if (i == 0) { fluidPath.moveTo(x, y); } else { fluidPath.lineTo(x, y); }
    }
    fluidPath.close();

    // ── Gradient paint: sweep rotates with pulse ─────────────────────────────
    final double sweepStart = pulse * 2 * math.pi;

    // Sharp stroke — glow peak sweeps around the oval
    canvas.drawPath(
      fluidPath,
      Paint()
        ..shader = ui.Gradient.sweep(
          oval.center,
          [
            accentColor.withValues(alpha: 0.0),
            accentColor.withValues(alpha: 0.95),
            accentColor.withValues(alpha: 0.55),
            accentColor.withValues(alpha: 0.95),
            accentColor.withValues(alpha: 0.0),
          ],
          [0.0, 0.25, 0.5, 0.75, 1.0],
          TileMode.clamp,
          sweepStart,
          sweepStart + 2 * math.pi,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    // Soft bloom layer — wider stroke, heavier blur
    canvas.drawPath(
      fluidPath,
      Paint()
        ..shader = ui.Gradient.sweep(
          oval.center,
          [
            Colors.transparent,
            accentColor.withValues(alpha: 0.28),
            accentColor.withValues(alpha: 0.14),
            accentColor.withValues(alpha: 0.28),
            Colors.transparent,
          ],
          [0.0, 0.25, 0.5, 0.75, 1.0],
          TileMode.clamp,
          sweepStart,
          sweepStart + 2 * math.pi,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  // ── Chronos: gear-precision tick marks (minor/major/cardinal) ─────────────

  void _drawChronosBorder(Canvas canvas, Rect oval) {
    const ticks = 60;

    // Base oval ring
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.35 + 0.2 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    final innerScales = [0.96, 0.92, 0.87]; // minor, major, cardinal

    for (var i = 0; i < ticks; i++) {
      final angle = i * 2 * math.pi / ticks;
      final isCardinal = i % 15 == 0;
      final isMajor = !isCardinal && i % 5 == 0;

      final innerScale = isCardinal
          ? innerScales[2]
          : isMajor
              ? innerScales[1]
              : innerScales[0];

      final outerPt = _ovalPoint(oval, angle);
      final innerPt = _ovalPoint(
        Rect.fromCenter(center: oval.center, width: oval.width * innerScale, height: oval.height * innerScale),
        angle,
      );

      final alpha = isCardinal ? 1.0 : isMajor ? 0.72 : 0.32;
      final strokeW = isCardinal ? 2.2 : isMajor ? 1.5 : 0.8;

      canvas.drawLine(
        outerPt,
        innerPt,
        Paint()
          ..color = accentColor.withValues(alpha: alpha * (0.8 + 0.2 * pulse))
          ..strokeWidth = strokeW,
      );
    }
  }

  // ── Prism: full-spectrum rainbow hue sweep ────────────────────────────────

  void _drawPrismBorder(Canvas canvas, Rect oval) {
    const segments = 60;
    const segAngle = 2 * math.pi / segments;

    for (var i = 0; i < segments; i++) {
      final startA = i * segAngle;
      // Hue cycles around the oval, offset animates with pulse for rotation
      final hue = ((i / segments + pulse * 0.25) % 1.0) * 360.0;
      final color = HSVColor.fromAHSV(1.0, hue, 0.95, 1.0).toColor();

      canvas.drawArc(
        oval,
        startA,
        segAngle * 0.94,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.butt,
      );
    }

    // White shimmer overlay
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08 + 0.06 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  // ── LiquidMetal: triple-stroke chrome with specular highlight ─────────────

  void _drawLiquidMetalBorder(Canvas canvas, Rect oval) {
    // Outer soft glow layer
    canvas.drawOval(
      oval.inflate(4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06 + 0.04 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    // Main metallic ring
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    // Inner thin highlight line
    canvas.drawOval(
      oval.deflate(2.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18 + 0.1 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    // Specular arc at the top (~180° sweep, fading at edges)
    canvas.drawArc(
      oval,
      -math.pi * 0.88,
      math.pi * 0.76,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32 + 0.18 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // ── Obsidian: sharp V-notch cuts into the border ──────────────────────────

  void _drawObsidianBorder(Canvas canvas, Rect oval) {
    // Solid base border
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    const notchCount = 12;
    final innerOval = Rect.fromCenter(
      center: oval.center,
      width: oval.width * 0.93,
      height: oval.height * 0.93,
    );

    for (var i = 0; i < notchCount; i++) {
      final angle = i * 2 * math.pi / notchCount;
      final outerPt = _ovalPoint(oval, angle);
      final innerPt = _ovalPoint(innerOval, angle);

      // Perpendicular to the oval tangent at this angle
      final perpAngle = angle + math.pi / 2;
      const notchHalfW = 4.5;

      final leftPt = outerPt + Offset(math.cos(perpAngle) * notchHalfW, math.sin(perpAngle) * notchHalfW);
      final rightPt = outerPt - Offset(math.cos(perpAngle) * notchHalfW, math.sin(perpAngle) * notchHalfW);

      final notchPath = Path()
        ..moveTo(leftPt.dx, leftPt.dy)
        ..lineTo(innerPt.dx, innerPt.dy)
        ..lineTo(rightPt.dx, rightPt.dy);

      canvas.drawPath(
        notchPath,
        Paint()
          ..color = accentColor.withValues(alpha: 0.7 + 0.3 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  // ── Singularity: concentric expansion rings (gravitational lensing) ────────

  void _drawSingularityBorder(Canvas canvas, Rect oval) {
    // Outer expansion rings (animate outward with pulse)
    for (var ring = 3; ring >= 0; ring--) {
      final expansion = ring * 9.0 + pulse * 6.0;
      final alpha = (1.0 - ring * 0.22) * (0.3 + 0.2 * pulse);
      canvas.drawOval(
        oval.inflate(expansion),
        Paint()
          ..color = accentColor.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.5, 1.5 - ring * 0.3),
      );
    }

    // Bright core border
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  // ── Monolith: minimal razor-thin line with slit edge highlights ───────────

  void _drawMonolithBorder(Canvas canvas, Rect oval) {
    // Single clean border
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.88 + 0.12 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Razor slit markers at left and right extremes
    final leftPt = Offset(oval.left, oval.center.dy);
    final rightPt = Offset(oval.right, oval.center.dy);
    const slitLen = 10.0;

    for (final pt in [leftPt, rightPt]) {
      canvas.drawLine(
        pt + const Offset(0, -slitLen),
        pt + const Offset(0, slitLen),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6 + 0.3 * pulse)
          ..strokeWidth = 1.5,
      );
    }

    // Top and bottom single-pixel marks
    canvas.drawLine(
      Offset(oval.center.dx - 6, oval.top),
      Offset(oval.center.dx + 6, oval.top),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(oval.center.dx - 6, oval.bottom),
      Offset(oval.center.dx + 6, oval.bottom),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.5,
    );
  }

  // ── Floating: soft bubbly circles orbiting the oval ──────────────────────

  void _drawFloatingBorder(Canvas canvas, Rect oval) {
    // Soft main border with slight blur (frosted-glass feel)
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.45 + 0.2 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    final rng = math.Random(99);
    const bubbleCount = 14;

    for (var i = 0; i < bubbleCount; i++) {
      // Each bubble orbits slightly outside the oval with a unique drift phase
      final baseAngle = i * 2 * math.pi / bubbleCount;
      final drift = math.sin(pulse * math.pi * 2 + i * 0.9) * 0.06;
      final orbitR = 1.06 + drift;
      final pt = Offset(
        oval.center.dx + (oval.width / 2 * orbitR) * math.cos(baseAngle),
        oval.center.dy + (oval.height / 2 * orbitR) * math.sin(baseAngle),
      );

      final bubbleR = 2.0 + rng.nextDouble() * 3.0;
      final alpha = 0.25 + 0.5 * math.sin(pulse * math.pi * 2 + i * 1.1).abs();

      // Bubble fill (very transparent)
      canvas.drawCircle(
        pt, bubbleR,
        Paint()
          ..color = accentColor.withValues(alpha: alpha * 0.25)
          ..style = PaintingStyle.fill,
      );
      // Bubble rim
      canvas.drawCircle(
        pt, bubbleR,
        Paint()
          ..color = accentColor.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }
  }

  // ── Sumi: varied-width ink-brush stroke segments ──────────────────────────

  void _drawSumiBorder(Canvas canvas, Rect oval) {
    const strokeCount = 20;
    final rng = math.Random(77);

    for (var i = 0; i < strokeCount; i++) {
      // Random arc start and length to mimic brush stroke placement
      final startFrac = i / strokeCount;
      final lengthFrac = 0.03 + rng.nextDouble() * 0.035;
      final startA = startFrac * 2 * math.pi;
      final sweepA = lengthFrac * 2 * math.pi;

      // Ink opacity varies; some strokes are heavier
      final baseAlpha = 0.35 + rng.nextDouble() * 0.55;
      final alpha = (baseAlpha * (0.65 + 0.35 * pulse)).clamp(0.0, 1.0);
      // Stroke width simulates brush pressure variation
      final width = 1.2 + rng.nextDouble() * 4.5;
      // Ink color shifts slightly toward black (sumi-e ink)
      final inkColor = Color.lerp(accentColor, Colors.black87, rng.nextDouble() * 0.4)!;

      canvas.drawArc(
        oval,
        startA,
        sweepA,
        false,
        Paint()
          ..color = inkColor.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    // Soft accent halo (ink glow / paper sheen)
    canvas.drawOval(
      oval,
      Paint()
        ..color = accentColor.withValues(alpha: 0.18 + 0.08 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ── 4. HUD corner brackets ────────────────────────────────────────────────
  // Shown on "tech" styles; softened for organic/artistic ones.

  void _drawCornerBrackets(Canvas canvas, Rect oval) {
    // Organic styles get small dot markers instead of hard L-brackets
    final isOrganic = style == LivenessUiStyle.cosmos ||
        style == LivenessUiStyle.sumi ||
        style == LivenessUiStyle.floating;

    if (isOrganic) {
      // Four soft corner dots
      const alpha = 0.65;
      final corners = [oval.topLeft, oval.topRight, oval.bottomLeft, oval.bottomRight];
      for (final c in corners) {
        canvas.drawCircle(
          c,
          3.5 + 1.5 * pulse,
          Paint()
            ..color = accentColor.withValues(alpha: alpha * (0.7 + 0.3 * pulse))
            ..style = PaintingStyle.fill,
        );
      }
      return;
    }

    // Standard HUD L-brackets
    final len = oval.shortestSide * 0.11;
    final alpha = 0.8 + 0.2 * pulse;
    final paint = Paint()
      ..color = accentColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;

    final tl = oval.topLeft;
    final tr = oval.topRight;
    final bl = oval.bottomLeft;
    final br = oval.bottomRight;

    void bracket(Offset corner, double hSign, double vSign) {
      canvas.drawLine(corner, corner + Offset(hSign * len, 0), paint);
      canvas.drawLine(corner, corner + Offset(0, vSign * len), paint);
    }

    bracket(tl, 1, 1);
    bracket(tr, -1, 1);
    bracket(bl, 1, -1);
    bracket(br, -1, -1);
  }

  // ── 5. Style painter clipped to the progress ring ─────────────────────────
  //
  // The active [LivenessUiStyle]'s painter is rendered on the full canvas and
  // then clipped to an annular-arc band wrapping clockwise from 12 o'clock.
  // As progress rises 0 → 1, the band grows to a complete ring.

  void _drawProgressPainter(Canvas canvas, Size size, Rect oval) {
    const startAngle = -math.pi / 2; // 12 o'clock
    final sweepAngle = progress * 2 * math.pi;
    const ringWidth = 36.0;

    final outerRect = oval.inflate(ringWidth);
    final innerRect = oval;

    // Annular sector: outer arc (CW) → inner arc (CCW) → closed
    final clipPath = Path();
    clipPath.arcTo(outerRect, startAngle, sweepAngle, true);
    clipPath.arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false);
    clipPath.close();

    canvas.save();
    canvas.clipPath(clipPath);

    buildStylePainter(
      style: style,
      count: 1,
      animationValue: progress,
      idleTime: idleTime,
      pressValue: 0.0,
    ).paint(canvas, size);

    canvas.restore();

    // Crisp accent stroke along the outer arc edge
    canvas.drawArc(
      outerRect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = accentColor.withValues(alpha: 0.55 + 0.25 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // Glowing leading-tip dot
    if (sweepAngle > 0.05) {
      final tipAngle = startAngle + sweepAngle;
      final tipX = outerRect.center.dx + (outerRect.width / 2) * math.cos(tipAngle);
      final tipY = outerRect.center.dy + (outerRect.height / 2) * math.sin(tipAngle);
      canvas.drawCircle(
        Offset(tipX, tipY),
        6,
        Paint()
          ..color = accentColor.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawCircle(
        Offset(tipX, tipY),
        2.8,
        Paint()..color = accentColor,
      );
    }
  }

  // ── 6. Horizontal scan line ───────────────────────────────────────────────

  void _drawScanLine(Canvas canvas, Rect oval) {
    final scanY = oval.top + oval.height * scanValue;
    if (scanY < oval.top || scanY > oval.bottom) return;

    final yCentered = scanY - oval.center.dy;
    final halfH = oval.height / 2;
    final halfW = oval.width / 2;
    final ratio = (yCentered / halfH).clamp(-1.0, 1.0);
    final xExtent = halfW * math.sqrt(1.0 - ratio * ratio);

    final left = oval.center.dx - xExtent;
    final right = oval.center.dx + xExtent;

    final shader = LinearGradient(
      colors: [
        accentColor.withValues(alpha: 0.0),
        accentColor.withValues(alpha: 0.55),
        accentColor.withValues(alpha: 0.55),
        accentColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.2, 0.8, 1.0],
    ).createShader(Rect.fromLTRB(left, scanY - 1, right, scanY + 1));

    canvas.drawLine(
      Offset(left, scanY),
      Offset(right, scanY),
      Paint()
        ..shader = shader
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  // ── shouldRepaint ─────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(covariant _FuturisticOvalPainter old) =>
      old.isFaceDetected != isFaceDetected ||
      old.progress != progress ||
      old.style != style ||
      old.pulse != pulse ||
      old.scanValue != scanValue ||
      old.idleTime != idleTime ||
      old.zoomFactor != zoomFactor;
}
