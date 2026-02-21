import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

/// Background glow that moves and pulses with active item
class BackgroundGlowPainter extends CustomPainter {
  final double activeX;
  final int totalItems;
  final FuturisticTheme theme;
  final double pulse;
  final double rotation;

  BackgroundGlowPainter({
    required this.activeX,
    required this.totalItems,
    required this.theme,
    required this.pulse,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalItems == 0) return;

    final centerY = size.height / 2;
    final itemWidth = size.width / totalItems;
    final glowRadius = itemWidth * (1.2 + 0.3 * math.sin(pulse * 2 * math.pi));

    // Main glow
    final gradient =
        RadialGradient(
          colors: [
            theme.accentColor.withValues(alpha: 0.25 + 0.1 * pulse),
            theme.glowGradient.colors[1].withValues(alpha: 0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(activeX, centerY), radius: glowRadius),
        );

    canvas.drawCircle(
      Offset(activeX, centerY),
      glowRadius,
      Paint()
        ..shader = gradient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    );

    // Secondary swirling glow (rotating)
    canvas.save();
    canvas.translate(activeX, centerY);
    canvas.rotate(rotation);
    for (int i = 0; i < 3; i++) {
      final offset = 15.0 + i * 10;
      final opacity = (0.1 - i * 0.03).clamp(0.0, 0.1);
      canvas.drawCircle(
        Offset(offset, 0),
        glowRadius * 0.5,
        Paint()
          ..color = theme.glowGradient.colors[i % 2].withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
      canvas.drawCircle(
        Offset(-offset, 0),
        glowRadius * 0.5,
        Paint()
          ..color = theme.glowGradient.colors[(i + 1) % 2].withValues(
            alpha: opacity,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BackgroundGlowPainter oldDelegate) =>
      oldDelegate.activeX != activeX ||
      oldDelegate.pulse != pulse ||
      oldDelegate.rotation != rotation;
}
