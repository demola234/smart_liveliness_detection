import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class CosmosPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  CosmosPainter({
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

    // SUPERNOVA FLARE IMPACT
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final double flareRadius = w * 0.7 * pressValue;
      final flarePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(activeX, h / 2),
          flareRadius,
          [
            (customColors['impactAccentColor'] ?? Colors.white).withValues(
              alpha: (0.8 * (1.0 - pressValue)).clamp(0.0, 1.0),
            ),
            (customColors['impactColor'] ?? theme.accentColor).withValues(
              alpha: (0.4 * (1.0 - pressValue)).clamp(0.0, 1.0),
            ),
            Colors.transparent,
          ],
          [0.0, 0.4, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(activeX, h / 2), flareRadius, flarePaint);
    }

    // 1. DEEP SPACE VOID
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(24),
      ),
      Paint()
        ..color = (customColors['backgroundColor'] ?? const Color(0xFF02040D)),
    );

    // 2. PARALLAX STARFIELD (Layer 1 - Far)
    if (effectToggles['showStars'] ?? true) {
      _drawStars(
        canvas,
        size,
        0.05,
        0.8,
        100,
        color: customColors['starColor'] ?? Colors.white,
      );
    }

    // 3. VOLUMETRIC NEBULA
    if (effectToggles['showNebula'] ?? true) {
      final nebulaBase = customColors['nebulaColor'] ?? theme.accentColor;
      final nebulaAccent =
          customColors['nebulaAccentColor'] ?? const Color(0xFF7B26F7);
      final nebulaPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(activeX, h / 2),
          itemWidth * 1.5,
          [
            nebulaBase.withValues(alpha: 0.12),
            nebulaAccent.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          [0.0, 0.6, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(Offset(activeX, h / 2), itemWidth * 1.5, nebulaPaint);
    }

    // 4. PARALLAX STARFIELD (Layer 2 - Near)
    if (effectToggles['showStars'] ?? true) {
      _drawStars(
        canvas,
        size,
        0.15,
        1.2,
        40,
        color: customColors['starColor'] ?? Colors.white,
      );
    }

    // 5. SHOOTING STARS (Random trails)
    if ((effectToggles['showShootingStars'] ?? true) &&
        math.sin(idleTime * 0.5) > 0.95) {
      final double starY = (idleTime * 100) % h;
      final double starX = (idleTime * 200) % w;
      canvas.drawLine(
        Offset(starX, starY),
        Offset(starX - 20, starY - 5),
        Paint()
          ..color = (customColors['starColor'] ?? Colors.white).withValues(
            alpha: 0.4,
          )
          ..strokeWidth = 1.0,
      );
    }

    // 6. THE COSMO-POD (Glowing Core)
    if (effectToggles['showCore'] ?? true) {
      final double pulse = 1.0 + math.sin(idleTime * 2) * 0.1;
      final coreColor = customColors['coreColor'] ?? Colors.white;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        20 * pulse,
        Paint()
          ..color = coreColor.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        Offset(activeX, h / 2),
        2 * pulse,
        Paint()..color = coreColor,
      );
    }
  }

  void _drawStars(
    Canvas canvas,
    Size size,
    double parallax,
    double sizeScale,
    int starCount, {
    Color color = Colors.white,
  }) {
    final starPaint = Paint()..color = color;
    for (int i = 0; i < starCount; i++) {
      final double x =
          (math.Random(i).nextDouble() * size.width -
              (animationValue * size.width * parallax)) %
          size.width;
      final double y = math.Random(i + 1).nextDouble() * size.height;
      final double starSize = math.Random(i + 2).nextDouble() * sizeScale;
      final double opacity = math.Random(i + 3).nextDouble() * 0.6;
      canvas.drawCircle(
        Offset(x, y),
        starSize,
        starPaint..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CosmosPainter oldDelegate) => true;
}
