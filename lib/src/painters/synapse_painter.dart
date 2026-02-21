import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class SynapsePainter extends CustomPainter {
  final double animationValue;
  final int count;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  SynapsePainter({
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

    // NEURAL BURST ON IMPACT
    if (pressValue > 0.01 && (effectToggles['showImpact'] ?? true)) {
      final burstColor = customColors['burstColor'] ?? theme.accentColor;
      final burstPaint = Paint()
        ..color = burstColor.withValues(
          alpha: (0.4 * (1.0 - pressValue)).clamp(0.0, 1.0),
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final double burstRadius = itemWidth * 1.5 * pressValue;
      canvas.drawCircle(Offset(activeX, h / 2), burstRadius, burstPaint);

      // Electrical Spikes
      final spikePaint = Paint()
        ..color = (customColors['spikeColor'] ?? Colors.white).withValues(
          alpha: (0.6 * (1.0 - pressValue)).clamp(0.0, 1.0),
        )
        ..strokeWidth = 1.0;

      for (int i = 0; i < 8; i++) {
        final double angle = i * (math.pi / 4) + idleTime;
        const double r1 = 15.0;
        final double r2 = 15.0 + 40.0 * pressValue;
        canvas.drawLine(
          Offset(activeX + math.cos(angle) * r1, h / 2 + math.sin(angle) * r1),
          Offset(activeX + math.cos(angle) * r2, h / 2 + math.sin(angle) * r2),
          spikePaint,
        );
      }
    }

    // 1. NEURAL VOID (Deep dark base)
    final bgColor = customColors['backgroundColor'] ?? const Color(0xFF020408);
    if (pressValue < 0.01) {
      final RRect barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(24),
      );
      canvas.drawRRect(barRect, Paint()..color = bgColor);
    } else {
      // DEFORMED PATH ON IMPACT (Organic Neural Jitter)
      final path = Path();
      const double r = 24.0;
      final random = math.Random((pressValue * 10).toInt());

      double getDeform(double x, double side) {
        final double wave1 = math.sin(x * 0.1 + idleTime * 10) * 4.0;
        final double wave2 = math.cos(x * 0.05 - idleTime * 5) * 2.0;
        final double crisp = (random.nextDouble() - 0.5) * 2.0;
        return (wave1 + wave2 + crisp) * pressValue;
      }

      path.moveTo(r, getDeform(r, 0));
      for (double x = r; x <= w - r; x += 5) {
        path.lineTo(x, getDeform(x, 0));
      }
      path.arcToPoint(Offset(w, r), radius: const Radius.circular(r));
      path.lineTo(w, h - r);
      path.arcToPoint(Offset(w - r, h), radius: const Radius.circular(r));
      for (double x = w - r; x >= r; x -= 5) {
        path.lineTo(x, h + getDeform(x, h));
      }
      path.arcToPoint(Offset(0, h - r), radius: const Radius.circular(r));
      path.lineTo(0, r);
      path.arcToPoint(const Offset(r, 0), radius: const Radius.circular(r));
      path.close();

      canvas.drawPath(path, Paint()..color = bgColor);

      canvas.drawPath(
        path,
        Paint()
          ..color = (customColors['glitchColor'] ?? theme.accentColor)
              .withValues(alpha: (0.4 * pressValue).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // 2. DATA FILAMENTS (Flowing background lines)
    if (effectToggles['showFilaments'] ?? true) {
      final filamentPaint = Paint()
        ..color = (customColors['filamentColor'] ?? theme.accentColor)
            .withValues(alpha: 0.05)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 5; i++) {
        final path = Path();
        final double baseY = h / 2 + (i - 2) * 10;
        path.moveTo(0, baseY);
        for (double x = 0; x < w; x += 20) {
          path.lineTo(x, baseY + math.sin(idleTime + x * 0.05 + i) * 8);
        }
        canvas.drawPath(path, filamentPaint);
      }
    }

    // 3. THE SYNAPSE NODES (Item locations)
    if (effectToggles['showNodes'] ?? true) {
      final baseNodeColor = customColors['nodeColor'] ?? theme.accentColor;
      final activeNodeColor =
          customColors['activeNodeColor'] ?? theme.accentColor;

      for (int i = 0; i < count; i++) {
        final double nodeX = (i + 0.5) * itemWidth;
        final double distToActive = (nodeX - activeX).abs() / itemWidth;
        final double activation = (1.0 - distToActive.clamp(0.0, 1.0))
            .toDouble();

        canvas.drawCircle(
          Offset(nodeX, h / 2),
          4 + 2 * activation,
          Paint()
            ..color = baseNodeColor.withValues(alpha: 0.1 + 0.4 * activation),
        );

        if (activation > 0.1) {
          final bridgePaint = Paint()
            ..shader = ui.Gradient.linear(
              Offset(activeX, h / 2),
              Offset(nodeX, h / 2),
              [activeNodeColor, activeNodeColor.withValues(alpha: 0.0)],
            )
            ..strokeWidth = 1.5 * activation;
          canvas.drawLine(
            Offset(activeX, h / 2),
            Offset(nodeX, h / 2),
            bridgePaint,
          );
        }
      }
    }

    // 4. THE NEURAL NUCLEUS (Pulsing Center)
    if (effectToggles['showNucleus'] ?? true) {
      final double pulse = 0.8 + math.sin(idleTime * 3) * 0.2;
      canvas.drawCircle(
        Offset(activeX, h / 2),
        25 * pulse,
        Paint()
          ..shader = ui.Gradient.radial(Offset(activeX, h / 2), 40 * pulse, [
            (customColors['nucleusColor'] ?? theme.accentColor).withValues(
              alpha: 0.15,
            ),
            Colors.transparent,
          ])
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
    }

    // 5. FLOATING DATA NODES
    if (effectToggles['showFloatingNodes'] ?? true) {
      for (int i = 0; i < 10; i++) {
        final double x = (idleTime * 40 + i * 100) % w;
        final double y = (math.sin(idleTime + i) * 10) + h / 2;
        canvas.drawCircle(
          Offset(x, y),
          1,
          Paint()
            ..color = (customColors['floatingNodeColor'] ?? Colors.white)
                .withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SynapsePainter oldDelegate) => true;
}
