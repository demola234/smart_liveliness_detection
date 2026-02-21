import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class QuantumPainter extends CustomPainter {
  final double progress;
  final int totalItems;
  final double idleTime;
  final FuturisticTheme theme;

  final double pressValue;

  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  QuantumPainter({
    required this.progress,
    required this.totalItems,
    required this.idleTime,
    required this.theme,
    this.pressValue = 0.0,
    this.customColors = const {},
    this.effectToggles = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalItems == 0) return;

    final double w = size.width;
    final double h = size.height;
    final double itemWidth = w / totalItems;
    final double activeX = (progress + 0.5) * itemWidth;

    // 0. INITIAL TRANSFORMATION (Lateral Stretch/Inertia)
    final double tLin = progress - progress.floor();
    final double wring = (1.0 - (2.0 * (0.5 - tLin).abs())).clamp(0.0, 1.0);
    final double stretchX = 1.0 + (wring * 0.04);
    final double skewX = (progress - progress.roundToDouble()) * -0.05 * wring;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(stretchX, 1.0);
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(skewX);
    canvas.transform(transform.storage);
    canvas.translate(-w / 2, -h / 2);

    // 1. AURA GLOW
    if (effectToggles['showAura'] ?? true) {
      canvas.save();
      canvas.translate(activeX, h / 2);
      canvas.drawCircle(
        Offset.zero,
        65,
        Paint()
          ..shader = RadialGradient(
            colors: [
              (customColors['auraColor'] ?? theme.accentColor).withValues(
                alpha: 0.12,
              ),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 65))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35),
      );
      canvas.restore();
    }

    // 2. MAGNETIC DEFORMATION
    final double stretchPower = math.pow(wring, 0.8).toDouble();

    double edgeOffset(double x, double edgeSign) {
      final double dist = (x - activeX).abs() / (itemWidth * 1.5);
      final double proximity = math
          .pow(1.0 - dist.clamp(0.0, 1.0), 3.0)
          .toDouble();
      // Increase pull on impact
      final double pull =
          proximity *
          (8.0 + stretchPower * 12.0 + pressValue * 20.0) *
          edgeSign;
      final double wobble = math.sin(idleTime * 2 + x * 0.05) * 1.5;
      return pull + wobble;
    }

    final path = Path();
    const double r = 24.0;
    const int segments = 80;

    path.moveTo(r, 0 + edgeOffset(r, 1.0));
    for (int i = 1; i <= segments; i++) {
      double x = r + (w - 2 * r) * (i / segments);
      path.lineTo(x, 0 + edgeOffset(x, 1.0));
    }
    path.arcToPoint(
      Offset(w, r + edgeOffset(w, 1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(w, h - r + edgeOffset(w, -1.0));
    path.arcToPoint(
      Offset(w - r, h + edgeOffset(w - r, -1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    for (int i = segments; i >= 0; i--) {
      double x = r + (w - 2 * r) * (i / segments);
      path.lineTo(x, h + edgeOffset(x, -1.0));
    }
    path.arcToPoint(
      Offset(0, h - r + edgeOffset(0, -1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(0, r + edgeOffset(0, 1.0));
    path.arcToPoint(
      Offset(r, 0 + edgeOffset(r, 1.0)),
      radius: const Radius.circular(r),
      clockwise: true,
    );
    path.close();

    // 2. DEEP GLASS BASE
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            (customColors['baseColor'] ?? theme.baseColor).withValues(
              alpha: 0.96,
            ),
            (customColors['baseAccentColor'] ?? const Color(0xFF101020))
                .withValues(alpha: 0.9),
            (customColors['baseColor'] ?? theme.baseColor).withValues(
              alpha: 0.96,
            ),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(path.getBounds()),
    );

    // 3. NEON SCANNING BORDER
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = SweepGradient(
          center: Alignment(((activeX / w) * 2) - 1.0, 0.0),
          colors: [
            Colors.white.withValues(alpha: 0.02),
            (customColors['accentColor'] ?? theme.accentColor).withValues(
              alpha: 0.4,
            ),
            (customColors['secondaryAccentColor'] ?? const Color(0xFF7B26F7)),
            (customColors['accentColor'] ?? theme.accentColor).withValues(
              alpha: 0.4,
            ),
            Colors.white.withValues(alpha: 0.02),
          ],
          stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
          transform: GradientRotation(idleTime * 0.4),
        ).createShader(path.getBounds()),
    );

    // 4. QUANTUM "GHOST" TRAILS
    if (effectToggles['showGhosts'] ?? true) {
      _drawQuantumGhosts(
        canvas,
        activeX,
        h,
        theme,
        idleTime,
        customColors: customColors,
        effectToggles: effectToggles,
      );
    }

    // 5. THE ACTIVE NUCLEUS
    if (effectToggles['showNucleus'] ?? true) {
      final nucleusRect = Rect.fromCenter(
        center: Offset(activeX, h / 2),
        width: 55,
        height: 48,
      );
      final nucleusBase = customColors['nucleusColor'] ?? theme.accentColor;
      final nucleusAccent =
          customColors['nucleusAccentColor'] ?? const Color(0xFF7B26F7);

      canvas.drawRRect(
        RRect.fromRectAndRadius(nucleusRect, const Radius.circular(18)),
        Paint()
          ..shader = RadialGradient(
            colors: [
              nucleusBase.withValues(alpha: 0.18),
              nucleusAccent.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(nucleusRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    canvas.restore();
  }

  void _drawQuantumGhosts(
    Canvas canvas,
    double x,
    double h,
    FuturisticTheme theme,
    double time, {
    Map<String, Color> customColors = const {},
    Map<String, bool> effectToggles = const {},
  }) {
    const ghostSize = Size(45, 40);
    final paint = Paint()..blendMode = BlendMode.screen;

    // Smooth energy echoes instead of sharp ghosts
    for (int i = 0; i < 3; i++) {
      final double offset = math.sin(time * 4 + i) * 6;
      final double opacity = (0.1 / (i + 1)).clamp(0.0, 1.0);
      final ghostColor = customColors['ghostColor'] ?? theme.accentColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + offset, h / 2),
            width: ghostSize.width + i * 4,
            height: ghostSize.height + i * 2,
          ),
          Radius.circular(14 + i * 2),
        ),
        paint
          ..color = ghostColor.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 + i * 2),
      );
    }

    // Energy Scan Line
    if (effectToggles['showScanLine'] ?? true) {
      final double scanX = (x - 60 + (time * 120) % 120);
      if (scanX > x - 50 && scanX < x + 50) {
        canvas.drawLine(
          Offset(scanX, h / 2 - 20),
          Offset(scanX, h / 2 + 20),
          Paint()
            ..color = (customColors['scanLineColor'] ?? Colors.white)
                .withValues(alpha: 0.1)
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
