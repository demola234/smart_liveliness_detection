import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class ChronosPainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  ChronosPainter({
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

    // MECHANICAL FLARE ON IMPACT
    if (pressValue > 0.01) {
      final flarePaint = Paint()
        ..color = theme.accentColor.withValues(
          alpha: (0.3 * (1.0 - pressValue)).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final double flareSize = 30.0 + pressValue * 50.0;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        flareSize,
        flarePaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    final RRect barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(24),
    );

    // 1. BRUSHED METAL BASE
    canvas.drawRRect(
      barRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(w, h),
          [
            const Color(0xFF1A1A1A),
            const Color(0xFF333333),
            const Color(0xFF1A1A1A),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // 2. PRECISION TICK MARKS (The "Ticking" Animation)
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 10) {
      final double tickH = (x % 50 == 0) ? 8.0 : 4.0;
      canvas.drawLine(Offset(x, 0), Offset(x, tickH), tickPaint);
      canvas.drawLine(Offset(x, h), Offset(x, h - tickH), tickPaint);
    }

    // 3. MECHANICAL GEARS (Subtle background rotation)
    _drawGears(canvas, size, activeX);

    // 4. THE CHRONO-POD (Active Indicator)
    final Paint activePaint = Paint()
      ..color = theme.accentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(activeX, h / 2);

    // Precision Circle
    canvas.drawCircle(
      center,
      22,
      activePaint..color = theme.accentColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      center,
      24,
      activePaint
        ..strokeWidth = 1.0
        ..color = theme.accentColor.withValues(alpha: 0.5),
    );

    // Dial Hand (Small ticking needle)
    final double tickAngle = (idleTime * 2 * math.pi) % (2 * math.pi);
    // snap to seconds for "mechanical" feel
    final double snappedAngle =
        (tickAngle * 5).floorToDouble() * (math.pi / 2.5);

    canvas.drawLine(
      center,
      center + Offset(math.cos(snappedAngle) * 15, math.sin(snappedAngle) * 15),
      activePaint
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );

    // 5. MEASUREMENT COORDINATES (Small technical text simulated)
    final textPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(activeX - 25, h - 8), 1, textPaint);
    canvas.drawCircle(Offset(activeX + 25, h - 8), 1, textPaint);
  }

  void _drawGears(Canvas canvas, Size size, double activeX) {
    final gearPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.save();
    canvas.translate(activeX, size.height / 2);
    canvas.rotate(idleTime * 0.5 + pressValue * 5.0);

    for (int i = 0; i < 8; i++) {
      final double angle = i * (math.pi / 4);
      canvas.drawLine(
        Offset(math.cos(angle) * 30, math.sin(angle) * 30),
        Offset(math.cos(angle) * 45, math.sin(angle) * 45),
        gearPaint,
      );
    }
    canvas.drawCircle(Offset.zero, 30, gearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ChronosPainter oldDelegate) => true;
}
