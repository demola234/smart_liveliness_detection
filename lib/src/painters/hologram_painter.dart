import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class HologramPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  HologramPainter({
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

    // DIGITAL GLITCH BURST ON IMPACT
    if (pressValue > 0.01) {
      final glitchPaint = Paint()
        ..color = theme.accentColor.withValues(
          alpha: (0.3 * (1.0 - pressValue)).clamp(0.0, 1.0),
        );
      final random = math.Random((pressValue * 100).toInt());

      for (int i = 0; i < 5; i++) {
        final double gx = random.nextDouble() * w;
        final double gy = random.nextDouble() * h;
        final double gw = 20.0 + random.nextDouble() * 50.0;
        final double gh = 2.0 + random.nextDouble() * 4.0;

        canvas.drawRect(
          Rect.fromLTWH(gx - gw / 2, gy - gh / 2, gw, gh),
          glitchPaint,
        );
      }

      // Screen Flash
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          const Radius.circular(20),
        ),
        Paint()
          ..color = Colors.white.withValues(
            alpha: (0.15 * (1.0 - pressValue)).clamp(0.0, 1.0),
          ),
      );
    }

    final RRect barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(20),
    );

    // 1. BASE GLASS (With subtle "flicker")
    final double flicker = 0.95 + math.sin(idleTime * 20) * 0.05;
    canvas.drawRRect(
      barRect,
      Paint()..color = theme.baseColor.withValues(alpha: 0.1 * flicker),
    );

    // 2. IRIDESCENT SHIMMER
    final Paint iriPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(activeX - itemWidth, 0),
        Offset(activeX + itemWidth, h),
        [
          Colors.cyan.withValues(alpha: 0.0),
          Colors.purpleAccent.withValues(alpha: 0.2 * flicker),
          Colors.cyan.withValues(alpha: 0.3 * flicker),
          Colors.greenAccent.withValues(alpha: 0.2 * flicker),
          Colors.cyan.withValues(alpha: 0.0),
        ],
        [0.0, 0.3, 0.5, 0.7, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(barRect, iriPaint);

    // 3. HORIZONTAL SCANLINES
    final scanlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double y = 0; y < h; y += 4) {
      final double offset = (math.sin(idleTime * 2 + y * 0.1) * 2);
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(w, y + offset),
        scanlinePaint,
      );
    }

    // 4. THE LIGHT-FIELD POD
    final RRect podRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(activeX, h / 2), width: 50, height: 40),
      const Radius.circular(12),
    );

    // Glow
    canvas.drawRRect(
      podRect,
      Paint()
        ..color = theme.accentColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Holographic Glitch lines
    final glitchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.0;

    if (math.sin(idleTime * 15) > 0.8) {
      canvas.drawLine(
        Offset(activeX - 30, h / 2 - 5),
        Offset(activeX + 30, h / 2 - 5),
        glitchPaint..color = Colors.cyan.withValues(alpha: 0.5),
      );
    }

    // 5. VERTICAL BEAM
    canvas.drawLine(
      Offset(activeX, 0),
      Offset(activeX, h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(activeX, 0),
          Offset(activeX, h),
          [
            Colors.transparent,
            theme.accentColor.withValues(alpha: 0.3),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant HologramPainter oldDelegate) => true;
}
