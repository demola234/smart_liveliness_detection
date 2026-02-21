import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';
import '../utils/math_utils.dart';

/// The main liquid metal container with complex deformation
class LiquidMetalPainter extends CustomPainter {
  final double progress; // continuous index of active item
  final int totalItems;
  final double squash; // press animation
  final FuturisticTheme theme;
  final double? dragOffset; // if dragging, the x coordinate
  final int? hoverIndex;
  final bool useLiquidPath;
  final Map<String, Color> customColors;
  final Map<String, bool> effectToggles;

  LiquidMetalPainter({
    required this.progress,
    required this.totalItems,
    required this.squash,
    required this.theme,
    this.dragOffset,
    this.hoverIndex,
    this.useLiquidPath = true,
    this.customColors = const {},
    this.effectToggles = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalItems == 0) return;

    final double w = size.width;
    final double h = size.height;
    final double itemWidth = w / totalItems;

    // Determine active center (consider drag)
    double activeX;
    if (dragOffset != null && hoverIndex != null) {
      // during drag, highlight hovered item
      activeX = hoverIndex! * itemWidth + itemWidth / 2;
    } else {
      // normal animation
      int fromIdx = progress.floor().clamp(0, totalItems - 1);
      int toIdx = (fromIdx + 1).clamp(0, totalItems - 1);
      double t = progress - progress.floor();
      double fromX = fromIdx * itemWidth + itemWidth / 2;
      double toX = toIdx * itemWidth + itemWidth / 2;
      activeX = lerpDouble(fromX, toX, t);
    }

    // Deformation parameters
    final double wringIntensity =
        1.0 -
        (2.0 * (0.5 - (progress - progress.floor())).abs()).clamp(0.0, 1.0);
    final double travelDir = (progress - progress.floor() < 0.5) ? 1.0 : -1.0;

    // Build complex path with multiple control points for "pizza cheese" effect
    const double cornerRadius = 28.0;
    const double topY = 6.0;
    final double bottomY = h - 6.0;

    Path path = Path();

    // Helper to compute vertical offset at given x due to deformation
    double edgeOffset(double x, {bool isTop = true}) {
      if (!useLiquidPath) return 0.0;
      double distToActive = (x - activeX).abs() / (itemWidth * 1.8);
      double proximity = math
          .pow(1.0 - distToActive.clamp(0.0, 1.0), 2.2)
          .toDouble();

      // Bulge (mass accumulation) - drastically reduced
      double bulge =
          proximity * 6.0 * (isTop ? -1.0 : 1.0) * (1.0 + wringIntensity * 0.5);

      // Stretch (elasticity) - reduced
      double stretch =
          ((x - activeX) / (itemWidth * 2.0)).clamp(-1.0, 1.0) *
          travelDir *
          wringIntensity *
          proximity *
          5.0 *
          (isTop ? -1.0 : 1.0);

      // Pinch (thinning) - reduced
      double pinch =
          -math.sin(math.pi * wringIntensity) *
          proximity *
          2.0 *
          (isTop ? -1.0 : 1.0);

      // Squash from press - subtler
      double press = proximity * squash * 4.0 * (isTop ? -1.0 : 1.0);

      double totalDeformation = bulge + stretch + pinch + press;

      // Mask deformation near corners to prevent sharp artifacts
      // We want to be 0 at x <= cornerRadius and x >= w - cornerRadius
      if (x < cornerRadius) {
        totalDeformation *= (x / cornerRadius).clamp(0.0, 1.0);
      } else if (x > w - cornerRadius) {
        totalDeformation *= ((w - x) / cornerRadius).clamp(0.0, 1.0);
      }

      return totalDeformation;
    }

    // Top edge from left to right
    path.moveTo(cornerRadius, topY); // Start perfectly flat
    const int steps = 80;

    // Scan across the top edge
    for (int i = 0; i <= steps; i++) {
      double x = cornerRadius + (w - 2 * cornerRadius) * (i / steps);
      double y = topY + edgeOffset(x, isTop: true);
      path.lineTo(x, y);
    }

    // Top-right corner
    // We arrive at (w - cornerRadius, topY + offset~0)
    // Draw arc to (w, topY + cornerRadius)
    path.arcToPoint(
      Offset(w, topY + cornerRadius),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Right edge down
    path.lineTo(w, bottomY - cornerRadius);
    path.arcToPoint(
      Offset(w - cornerRadius, bottomY),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Bottom edge from right to left
    for (int i = 0; i <= steps; i++) {
      // i=0 -> right end, i=steps -> left end
      double x = w - cornerRadius - (w - 2 * cornerRadius) * (i / steps);
      double y = bottomY + edgeOffset(x, isTop: false);
      path.lineTo(x, y);
    }

    // Bottom-left corner
    path.arcToPoint(
      Offset(0, bottomY - cornerRadius),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Left edge up
    path.lineTo(0, topY + cornerRadius);
    path.arcToPoint(
      const Offset(cornerRadius, topY),
      radius: const Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.close();

    // Fill with dark glass gradient
    final rect = Rect.fromLTWH(0, 0, w, h);
    final baseColor = customColors['baseColor'] ?? theme.baseColor;
    final backgroundColor =
        customColors['backgroundColor'] ?? theme.backgroundColor;

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.95),
            backgroundColor.withValues(alpha: 0.98),
            baseColor.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // Inner glow
    if (effectToggles['showInnerGlow'] ?? true) {
      final glowColor = customColors['glowColor'] ?? theme.accentColor;
      canvas.drawPath(
        path,
        Paint()
          ..shader = RadialGradient(
            center: Alignment(((activeX / w) * 2) - 1.0, -0.3),
            radius: 0.6 + wringIntensity * 0.2,
            colors: [
              glowColor.withValues(alpha: 0.3 + wringIntensity * 0.2),
              (customColors['glowAccentColor'] ?? theme.glowGradient.colors[1])
                  .withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.overlay,
      );
    }

    // Border with moving gradient
    if (effectToggles['showBorder'] ?? true) {
      final borderColor = customColors['borderColor'] ?? theme.accentColor;
      canvas.drawPath(
        path,
        Paint()
          ..shader = SweepGradient(
            center: Alignment(((activeX / w) * 2) - 1.0, 0.0),
            colors: [
              Colors.white.withValues(alpha: 0.1),
              borderColor.withValues(alpha: 0.6),
              (customColors['borderAccentColor'] ??
                      theme.glowGradient.colors[1])
                  .withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    // Additional highlights
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 5. CHROME SHINE (Metallic Glint)
    if (effectToggles['showChromeShine'] ?? true) {
      final shinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            (customColors['shineColor'] ?? Colors.white).withValues(alpha: 0.2),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen;

      canvas.drawPath(path, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LiquidMetalPainter oldDelegate) => true;
}
