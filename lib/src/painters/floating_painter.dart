import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class FloatingPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  FloatingPainter({
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

    // GRAVITY JUMP ON IMPACT
    final double impactJump = pressValue * -15.0; // Jump up
    final double floatY = math.sin(idleTime) * 3.0 + impactJump;
    final RRect podRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, floatY, w, h),
      const Radius.circular(40),
    );

    // Deep Shadow (moves inverse to float)
    if (effectToggles['showShadow'] ?? true) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(5, h + 10 - floatY, w - 10, 10),
          const Radius.circular(20),
        ),
        Paint()
          ..color = (customColors['shadowColor'] ?? Colors.black).withValues(
            alpha: 0.2,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }

    // Pod Fill (Frosted Glass)
    canvas.drawRRect(
      podRect,
      Paint()
        ..color = (customColors['baseColor'] ?? theme.baseColor).withValues(
          alpha: 0.9,
        )
        ..style = PaintingStyle.fill,
    );

    // 2. INTERNAL GLOW TRACKER
    if (effectToggles['showGlow'] ?? true) {
      final Paint glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(activeX, h / 2 + floatY),
          itemWidth * 0.8,
          [
            (customColors['glowColor'] ?? theme.accentColor).withValues(
              alpha: 0.2,
            ),
            Colors.transparent,
          ],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(podRect, glowPaint);
    }

    // 3. SOPHISTICATED BORDER
    if (effectToggles['showBorder'] ?? true) {
      final Paint borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = ui.Gradient.linear(
          Offset(0, floatY),
          Offset(w, h + floatY),
          [
            (customColors['borderColor'] ?? Colors.white).withValues(
              alpha: 0.3,
            ),
            (customColors['borderColor'] ?? Colors.white).withValues(
              alpha: 0.05,
            ),
            (customColors['borderColor'] ?? Colors.white).withValues(
              alpha: 0.3,
            ),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRRect(podRect, borderPaint);
    }

    // 4. MICRO-INDICATOR (The "Hover Pod")
    if (effectToggles['showIndicator'] ?? true) {
      final Rect indicatorRect = Rect.fromCenter(
        center: Offset(activeX, h / 2 + floatY),
        width: 50,
        height: 50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(indicatorRect, const Radius.circular(20)),
        Paint()
          ..color = (customColors['indicatorColor'] ?? Colors.white).withValues(
            alpha: 0.05,
          )
          ..style = PaintingStyle.fill,
      );

      // Tiny top highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(activeX - 10, floatY + 5, 20, 2),
          const Radius.circular(1),
        ),
        Paint()
          ..color =
              (customColors['indicatorHighlightColor'] ?? theme.accentColor)
                  .withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloatingPainter oldDelegate) => true;
}
