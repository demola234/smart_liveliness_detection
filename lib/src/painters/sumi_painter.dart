import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class SumiPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  SumiPainter({
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

    // BLOOMING INK SPLASH ON IMPACT
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final double splashRadius = itemWidth * 1.2 * pressValue;
      final splashColor =
          customColors['impactColor'] ?? const Color(0xFF000000);
      final splashPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(activeX, h / 2),
          splashRadius,
          [
            splashColor.withValues(
              alpha: (0.4 * (1.0 - pressValue)).clamp(0.0, 1.0),
            ),
            Colors.transparent,
          ],
          [0.0, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(activeX, h / 2), splashRadius, splashPaint);

      // Secondary droplets
      for (int i = 0; i < 5; i++) {
        final double angle = math.Random(i).nextDouble() * 2 * math.pi;
        final double dist = splashRadius * 0.7;
        canvas.drawCircle(
          Offset(
            activeX + math.cos(angle) * dist,
            h / 2 + math.sin(angle) * dist,
          ),
          5 * (1.0 - pressValue),
          Paint()
            ..color = splashColor.withValues(
              alpha: (0.3 * (1.0 - pressValue)).clamp(0.0, 1.0),
            ),
        );
      }
    }

    // 1. PAPER TEXTURE (Handmade feel)
    if (effectToggles['showPaperTexture'] ?? true) {
      final paperPaint = Paint()
        ..color = (customColors['paperColor'] ?? const Color(0xFFF5F5F0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          const Radius.circular(24),
        ),
        paperPaint,
      );

      // Subtle grain
      final grainPaint = Paint()..color = Colors.black.withValues(alpha: 0.02);
      for (int i = 0; i < 100; i++) {
        final double rx = math.Random(i).nextDouble() * w;
        final double ry = math.Random(i + 1).nextDouble() * h;
        canvas.drawCircle(Offset(rx, ry), 1, grainPaint);
      }
    }

    // 2. THE INK WASH (Large soft sweep)
    final inkColor = customColors['inkColor'] ?? const Color(0xFF1A1A1A);
    final washPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(activeX, h / 2),
        itemWidth * 1.5,
        [inkColor.withValues(alpha: 0.15), inkColor.withValues(alpha: 0.0)],
        [0.0, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(activeX, h / 2), itemWidth, washPaint);

    // 3. ORGANIC INK BLEED (The "Impact" marks)
    if (effectToggles['showInkSplatter'] ?? true) {
      _drawInkBleed(
        canvas,
        Offset(activeX, h / 2),
        itemWidth * 0.6,
        color: inkColor,
      );
    }

    // 4. CALLIGRAPHIC STROKE (The indicator line)
    final strokePaint = Paint()
      ..color = inkColor.withValues(alpha: 0.9)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(activeX - 25, h - 15);
    path.quadraticBezierTo(
      activeX,
      h - 20 + math.sin(idleTime * 2) * 2,
      activeX + 25,
      h - 15,
    );
    canvas.drawPath(path, strokePaint);

    // 5. RED SEAL (Traditional stamp)
    if (effectToggles['showSeal'] ?? true) {
      final double sealX = w - 40;
      const double sealY = 20;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(sealX, sealY), width: 15, height: 15),
        Paint()
          ..color = (customColors['sealColor'] ?? const Color(0xFFB22222))
              .withValues(alpha: 0.8),
      );
      canvas.drawCircle(
        Offset(sealX, sealY),
        3,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  void _drawInkBleed(
    Canvas canvas,
    Offset center,
    double radius, {
    Color color = const Color(0xFF000000),
  }) {
    final inkPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    const int fragments = 12;
    for (int i = 0; i < fragments; i++) {
      final double angle = i * (2 * math.pi / fragments);
      final double r = radius * (0.8 + 0.4 * math.sin(idleTime * 5 + i * 2));
      final double x = center.dx + math.cos(angle) * r;
      final double y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, inkPaint);
  }

  @override
  bool shouldRepaint(covariant SumiPainter oldDelegate) => true;
}
