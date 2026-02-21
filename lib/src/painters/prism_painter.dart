import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class PrismPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  PrismPainter({
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

    // CHROMATIC SHOCKWAVE ON IMPACT
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final double waveScale = 1.0 + pressValue * 0.2;
      final double waveAlpha = 0.4 * (1.0 - pressValue);

      canvas.save();
      canvas.translate(w / 2, h / 2);
      canvas.scale(waveScale);
      canvas.translate(-w / 2, -h / 2);

      final shockRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(20),
      );

      final redShiftColor = customColors['redShiftColor'] ?? Colors.red;
      final greenShiftColor = customColors['greenShiftColor'] ?? Colors.green;
      final blueShiftColor = customColors['blueShiftColor'] ?? Colors.blue;

      // Red shift
      canvas.drawRRect(
        shockRRect,
        Paint()
          ..color = redShiftColor.withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // Green shift
      canvas.drawRRect(
        shockRRect.shift(const Offset(2, 0)),
        Paint()
          ..color = greenShiftColor.withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // Blue shift
      canvas.drawRRect(
        shockRRect.shift(const Offset(-2, 0)),
        Paint()
          ..color = blueShiftColor.withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      canvas.restore();
    }

    final RRect barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(20),
    );

    // 1. CRYSTAL BASE
    canvas.drawRRect(
      barRect,
      Paint()
        ..color = (customColors['baseColor'] ?? Colors.white).withValues(
          alpha: 0.05,
        ),
    );

    // 2. CHROMATIC DISPERSION (Rainbow edges)
    if (effectToggles['showRainbow'] ?? true) {
      final cyanColor = customColors['cyanShiftColor'] ?? Colors.cyan;
      final magentaColor =
          customColors['magentaShiftColor'] ?? Colors.purpleAccent;

      // Cyan shift
      canvas.drawRRect(
        barRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = cyanColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              cyanColor.withValues(alpha: 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment((activeX / w - 1).clamp(-1.0, 1.0), 0),
            end: Alignment((activeX / w).clamp(-1.0, 1.0), 0),
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );

      // Magenta shift
      canvas.drawRRect(
        barRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = magentaColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // 3. INTERNAL REFRACTION RAYS
    if (effectToggles['showGlow'] ?? true) {
      final rayColor = customColors['rayColor'] ?? Colors.white;
      final rayPaint = Paint()
        ..color = rayColor.withValues(alpha: 0.2)
        ..strokeWidth = 1.0;

      final Offset center = Offset(activeX, h / 2);
      for (int i = 0; i < 5; i++) {
        final double angle = (idleTime * 20 + i * 40) * math.pi / 180;
        final double dx = math.cos(angle) * 30;
        final double dy = math.sin(angle) * 15;
        canvas.drawLine(
          center,
          center + Offset(dx, dy),
          rayPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    // 4. SHARP FACET HIGHLIGHTS
    if (effectToggles['showHighlights'] ?? true) {
      final highlightColor = customColors['highlightColor'] ?? Colors.white;
      final facetPaint = Paint()
        ..color = highlightColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(activeX - 25, 5),
        Offset(activeX + 25, 5),
        facetPaint,
      );
      canvas.drawLine(
        Offset(activeX - 25, h - 5),
        Offset(activeX + 25, h - 5),
        facetPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PrismPainter oldDelegate) => true;
}
