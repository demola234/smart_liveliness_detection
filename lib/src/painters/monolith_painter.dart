import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class MonolithPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  MonolithPainter({
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

    // MONOLITHIC AURA EXPANSION ON IMPACT
    if (pressValue > 0.01) {
      final double auraRadius = 40.0 + pressValue * 100.0;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        auraRadius,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(activeX, h / 2),
            auraRadius,
            [
              theme.accentColor.withValues(
                alpha: (0.2 * (1.0 - pressValue)).clamp(0.0, 1.0),
              ),
              Colors.transparent,
            ],
            [0.0, 1.0],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    final RRect barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );

    // 1. ARCHITECTURAL MATTE BASE (Deep shadow depth)
    canvas.drawRRect(
      barRect,
      Paint()
        ..color = const Color(0xFF0F0F13)
        ..style = PaintingStyle.fill,
    );

    // Inner shadow for "carved" look
    final Path path = Path()..addRRect(barRect);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 2. THE LIGHT SLIT (Vertical Razor Thin Indicator)
    final Paint slitPaint = Paint()
      ..color = theme.accentColor
      ..strokeWidth = 1.2;

    // Slit Glow
    canvas.drawLine(
      Offset(activeX, 10),
      Offset(activeX, h - 10),
      slitPaint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = theme.accentColor.withValues(alpha: 0.6),
    );
    // Sharp Slit
    canvas.drawLine(
      Offset(activeX, 12),
      Offset(activeX, h - 12),
      slitPaint
        ..maskFilter = null
        ..color = Colors.white,
    );

    // 3. SURFACE TEXTURE (Subtle geometric lines)
    final geoPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.8;

    for (int i = 0; i < count; i++) {
      final double x = (i + 1) * itemWidth;
      canvas.drawLine(Offset(x, 15), Offset(x, h - 15), geoPaint);
    }

    // 4. DEPTH AMBIENT OCCLUSION (Focus on bottom edge)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, h - 2, w - 20, 2),
        const Radius.circular(1),
      ),
      Paint()
        ..color = theme.accentColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 5. THE ACTIVE NUCLEATIVE GLOW (Subsurface)
    canvas.drawCircle(
      Offset(activeX, h / 2),
      20,
      Paint()
        ..shader = ui.Gradient.radial(Offset(activeX, h / 2), 30, [
          theme.accentColor.withValues(alpha: 0.08),
          Colors.transparent,
        ])
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant MonolithPainter oldDelegate) => true;
}
