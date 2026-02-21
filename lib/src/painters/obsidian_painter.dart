import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class ObsidianPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final FuturisticTheme theme;
  final double glowStrength;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  ObsidianPainter({
    required this.animationValue,
    required this.count,
    required this.theme,
    this.glowStrength = 1.0,
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

    // IMPACT GLOW PULSE
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h),
          const Radius.circular(24),
        ),
        Paint()
          ..color = (customColors['impactColor'] ?? theme.accentColor)
              .withValues(alpha: (0.2 * (1.0 - pressValue)).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    final RRect barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(24),
    );

    // 1. MATTE OBSIDIAN BASE
    canvas.drawRRect(
      barRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(w, h),
          [
            customColors['baseColor'] ?? const Color(0xFF0A0A0A),
            customColors['baseAccentColor'] ?? const Color(0xFF141414),
            customColors['baseColor'] ?? const Color(0xFF0A0A0A),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // 2. MICRO-GRID TEXTURE
    if (effectToggles['showGrid'] ?? true) {
      final Paint gridPaint = Paint()
        ..color = (customColors['gridColor'] ?? Colors.white).withValues(
          alpha: 0.02,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      for (double x = 0; x < w; x += 15) {
        canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
      }
    }

    // 3. SOPHISTICATED BEAM (The Obsidian Glow)
    if (effectToggles['showGlow'] ?? true) {
      final Offset center = Offset(activeX, h / 2);
      final Paint beamPaint = Paint()
        ..shader = ui.Gradient.radial(center, h * 1.2, [
          (customColors['glowColor'] ?? theme.accentColor).withValues(
            alpha: 0.15 * glowStrength,
          ),
          Colors.transparent,
        ])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawRRect(barRect, beamPaint);
    }

    // 4. THE INDICATOR POD
    if (effectToggles['showIndicator'] ?? true) {
      final Offset center = Offset(activeX, h / 2);
      final RRect podRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 45, height: 45),
        const Radius.circular(14),
      );

      // Soft pod shadow
      canvas.drawRRect(
        podRect,
        Paint()
          ..color = (customColors['podShadowColor'] ?? Colors.black).withValues(
            alpha: 0.8,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Pod stroke
      canvas.drawRRect(
        podRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = (customColors['podBorderColor'] ?? Colors.white).withValues(
            alpha: 0.05,
          ),
      );

      // 5. TECHNICAL ACCENT
      final Paint accentPaint = Paint()
        ..color = (customColors['accentColor'] ?? theme.accentColor).withValues(
          alpha: 0.8,
        )
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Small vertical marker
      canvas.drawLine(
        Offset(activeX, h - 8),
        Offset(activeX, h - 4),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ObsidianPainter oldDelegate) => true;
}
