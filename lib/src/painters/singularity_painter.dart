import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class SingularityPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  SingularityPainter({
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

    // IMPACT SHOCKWAVE (Gravitational Wave)
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final double waveRadius = pressValue * w * 0.8;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        waveRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - pressValue)
          ..color = (customColors['impactColor'] ?? theme.accentColor)
              .withValues(alpha: (0.4 * (1.0 - pressValue)).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    // 1. SPACE-TIME GRID (Warped)
    if (effectToggles['showGrid'] ?? true) {
      final gridColor = customColors['gridColor'] ?? theme.accentColor;
      final gridPaint = Paint()
        ..color = gridColor.withValues(
          alpha: (0.08 + pressValue * 0.1).clamp(0.0, 1.0),
        )
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      const double step = 20.0;
      for (double x = 0; x <= w; x += step) {
        final path = Path();
        path.moveTo(x, 0);
        for (double y = 0; y <= h; y += 5) {
          final Offset p = _warpPoint(
            Offset(x, y),
            Offset(activeX, h / 2),
            impact: pressValue,
          );
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, gridPaint);
      }
      for (double y = 0; y <= h; y += step) {
        final path = Path();
        path.moveTo(0, y);
        for (double x = 0; x <= w; x += 5) {
          final Offset p = _warpPoint(
            Offset(x, y),
            Offset(activeX, h / 2),
            impact: pressValue,
          );
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, gridPaint);
      }
    }

    // 2. THE SINGULARITY (Black Hole)
    if (effectToggles['showHole'] ?? true) {
      final double nucleusRadius = 24.0 + math.sin(idleTime * 4) * 2.0;
      final diskBaseColor = customColors['diskColor'] ?? theme.accentColor;

      // Accretion Disk (Iridescent)
      final diskPaint = Paint()
        ..shader =
            SweepGradient(
              center: Alignment.center,
              colors: [
                diskBaseColor.withValues(alpha: 0.0),
                diskBaseColor.withValues(alpha: 0.6),
                (customColors['diskAccentColor'] ?? Colors.purpleAccent)
                    .withValues(alpha: 0.4),
                diskBaseColor.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.4, 0.6, 1.0],
              transform: GradientRotation(idleTime * 2),
            ).createShader(
              Rect.fromCircle(center: Offset(activeX, h / 2), radius: 45),
            )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.save();
      canvas.translate(activeX, h / 2);
      canvas.drawCircle(Offset.zero, 40, diskPaint);
      canvas.restore();

      // Event Horizon (Deep Black Hole)
      canvas.drawCircle(
        Offset(activeX, h / 2),
        nucleusRadius,
        Paint()
          ..color = customColors['holeColor'] ?? Colors.black
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5),
      );

      // Photon Ring (Bright highlight)
      canvas.drawCircle(
        Offset(activeX, h / 2),
        nucleusRadius + 1,
        Paint()
          ..color = (customColors['photonRingColor'] ?? Colors.white)
              .withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // 3. GRAVITATIONAL LENSING (Aura)
    if (effectToggles['showAura'] ?? true) {
      final auraColor = customColors['auraColor'] ?? theme.accentColor;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        60,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(activeX, h / 2),
            80,
            [auraColor.withValues(alpha: 0.1), Colors.transparent],
            [0.0, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }
  }

  Offset _warpPoint(Offset p, Offset hole, {double impact = 0.0}) {
    final double dx = p.dx - hole.dx;
    final double dy = p.dy - hole.dy;
    final double dist = math.sqrt(dx * dx + dy * dy);

    if (dist < 10) return hole; // Swallowed

    // Gravitational warping formula
    // Increase strength on impact
    final double strength = (1500.0 + impact * 3000.0) / (dist + 50.0);
    final double pullX = (dx / dist) * strength;
    final double pullY = (dy / dist) * strength;

    return Offset(p.dx - pullX, p.dy - pullY);
  }

  @override
  bool shouldRepaint(covariant SingularityPainter oldDelegate) => true;
}
