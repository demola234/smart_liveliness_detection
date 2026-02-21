import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class KineticPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  KineticPainter({
    required this.animationValue,
    required this.count,
    required this.idleTime,
    required this.theme,
    this.pressValue = 0.0,
    this.customColors = const {},
    this.effectToggles = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count == 0) return;

    final double w = size.width;
    final double h = size.height;
    final double itemWidth = w / count;
    final double activeX = (animationValue + 0.5) * itemWidth;

    // IMPACT SHOCKWAVE (Physical Pulse)
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final double waveRadius = w * 0.5 * pressValue;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        waveRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * (1.0 - pressValue)
          ..color = (customColors['impactColor'] ?? theme.accentColor)
              .withValues(alpha: (0.3 * (1.0 - pressValue)).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // 1. TECH BASE
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(24),
      ),
      Paint()
        ..color = (customColors['backgroundColor'] ?? const Color(0xFF12121A)),
    );

    // 2. KINETIC TILES (Grid of shingles)
    if (effectToggles['showTiles'] ?? true) {
      const double tileSize = 12.0;
      final tilePaint = Paint()..style = PaintingStyle.fill;

      for (double x = 0; x < w; x += tileSize + 2) {
        for (double y = 0; y < h; y += tileSize + 2) {
          final double distToActive = math.sqrt(
            math.pow(x - activeX, 2) + math.pow(y - h / 2, 2),
          );
          final double proximity = (1.0 - (distToActive / 150.0)).clamp(
            0.0,
            1.0,
          );

          // Impact proximity
          final double impactProximity = (1.0 - (distToActive / (w * 0.4)))
              .clamp(0.0, 1.0);

          // MOMENTUM PHYSICS
          final double impactOffset = impactProximity * pressValue * 35.0;
          final double horizontalShuffle =
              math.sin(x * 0.1 + idleTime * 5) * pressValue * 5.0;

          final double baseTilt = math.sin(proximity * math.pi) * 0.8;
          final double impactTilt = impactProximity * pressValue * math.pi;
          final double secondaryWobble =
              math.sin(idleTime * 15 + x) * pressValue * 0.1;

          final double tilt = baseTilt + impactTilt + secondaryWobble;

          canvas.save();
          canvas.translate(
            x + tileSize / 2 + horizontalShuffle,
            y + tileSize / 2 - impactOffset,
          );
          canvas.rotate(tilt);

          canvas.scale(1.0 + (impactProximity * pressValue * 0.6));

          // Tile color overrides
          final baseTileColor =
              customColors['tileBaseColor'] ?? const Color(0xFF1E1E2A);
          final activeTileColor =
              customColors['tileActiveColor'] ?? theme.accentColor;

          tilePaint.color = Color.lerp(
            baseTileColor,
            activeTileColor.withValues(alpha: 0.8),
            proximity.clamp(0.0, 1.0),
          )!;

          if (impactProximity > 0.1) {
            tilePaint.color = Color.lerp(
              tilePaint.color,
              customColors['tileImpactColor'] ?? Colors.white,
              (impactProximity * pressValue).clamp(0.0, 0.4),
            )!;
          }

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: tileSize,
                height: tileSize,
              ),
              const Radius.circular(2),
            ),
            tilePaint,
          );

          if (proximity > 0.5 || impactProximity > 0.5) {
            canvas.drawRect(
              const Rect.fromLTWH(-tileSize / 2, -tileSize / 2, tileSize, 1),
              Paint()
                ..color = Colors.white.withValues(
                  alpha: 0.3 * math.max(proximity, pressValue),
                ),
            );
          }
          canvas.restore();
        }
      }
    }

    // 3. FLUID ARC CONDUIT — paint defines the arc's shape
    if (effectToggles['showConduit'] ?? true) {
      final accentColor = customColors['conduitColor'] ?? theme.accentColor;

      final double phaseA = idleTime * 2.8;
      final double phaseB = idleTime * 4.5 + math.pi * 0.6;
      final double breathe = 0.7 + 0.3 * math.sin(idleTime * 1.8);
      const double ampA = 9.0;      // primary wave amplitude (px)
      const double ampB = 3.5;      // secondary wave amplitude
      const double wavesA = 2.5;    // primary cycles across width
      const double wavesB = 5.0;    // secondary cycles
      const double ribbonHalf = 5.0; // max half-thickness of the ribbon
      const double step = 2.0;

      // Gaussian intensity: 1.0 at activeX, falls to ~0 at the edges.
      // Both the wave amplitude AND the ribbon thickness are scaled by this,
      // so the arc literally grows out of the paint and shrinks back into it.
      double intensity(double x) {
        final double d = (x - activeX) / w;
        return math.exp(-d * d * 22.0);
      }

      // Wave centre-line y at position x
      double waveY(double x) {
        final double t = x / w;
        return h / 2
            + math.sin(t * math.pi * 2 * wavesA + phaseA) * ampA * breathe
            + math.sin(t * math.pi * 2 * wavesB + phaseB) * ampB;
      }

      // Build closed ribbon: top edge L→R, bottom edge R→L
      final ribbon = Path();
      for (double x = 0; x <= w; x += step) {
        final double g = intensity(x);
        final double cy = waveY(x) * g + h / 2 * (1.0 - g); // flatten when faint
        final double half = ribbonHalf * g;
        if (x == 0) {
          ribbon.moveTo(x, cy - half);
        } else {
          ribbon.lineTo(x, cy - half);
        }
      }
      for (double x = w; x >= 0; x -= step) {
        final double g = intensity(x);
        final double cy = waveY(x) * g + h / 2 * (1.0 - g);
        final double half = ribbonHalf * g;
        ribbon.lineTo(x, cy + half);
      }
      ribbon.close();

      // ── Fill 1: sharp core — gradient fills the ribbon's exact shape ──────
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(activeX - w * 0.35, 0),
            Offset(activeX + w * 0.35, 0),
            [
              accentColor.withValues(alpha: 0.0),
              accentColor.withValues(alpha: 0.85),
              accentColor.withValues(alpha: 1.0),
              accentColor.withValues(alpha: 0.85),
              accentColor.withValues(alpha: 0.0),
            ],
            const [0.0, 0.25, 0.5, 0.75, 1.0],
          )
          ..style = PaintingStyle.fill,
      );

      // ── Fill 2: soft bloom — same ribbon, blurred wider ───────────────────
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(activeX - w * 0.4, 0),
            Offset(activeX + w * 0.4, 0),
            [
              Colors.transparent,
              accentColor.withValues(alpha: 0.35),
              accentColor.withValues(alpha: 0.55),
              accentColor.withValues(alpha: 0.35),
              Colors.transparent,
            ],
            const [0.0, 0.25, 0.5, 0.75, 1.0],
          )
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );

      // Radial glow at active node
      canvas.drawCircle(
        Offset(activeX, h / 2),
        28,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(activeX, h / 2),
            28,
            [accentColor.withValues(alpha: 0.22), Colors.transparent],
            [0.0, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant KineticPainter oldDelegate) => true;
}
