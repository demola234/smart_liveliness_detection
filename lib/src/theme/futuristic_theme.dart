import 'package:flutter/material.dart';

/// Theme configuration for futuristic painter effects used in liveness UI.
///
/// Pass a [FuturisticTheme] to any painter to control its color palette.
/// Use one of the built-in presets or construct a fully custom theme.
class FuturisticTheme {
  /// Primary accent / highlight color (glow, indicator, active element).
  final Color accentColor;

  /// Base fill color of the bar/container.
  final Color baseColor;

  /// Outer background color (used in gradients and deep fills).
  final Color backgroundColor;

  /// Gradient used for secondary glow layers. Must contain at least 2 colors.
  final LinearGradient glowGradient;

  const FuturisticTheme({
    required this.accentColor,
    required this.baseColor,
    required this.backgroundColor,
    required this.glowGradient,
  });

  FuturisticTheme copyWith({
    Color? accentColor,
    Color? baseColor,
    Color? backgroundColor,
    LinearGradient? glowGradient,
  }) {
    return FuturisticTheme(
      accentColor: accentColor ?? this.accentColor,
      baseColor: baseColor ?? this.baseColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      glowGradient: glowGradient ?? this.glowGradient,
    );
  }

  // ─── Built-in presets ────────────────────────────────────────────────────

  /// Quantum: electric cyan + deep violet. Pairs with QuantumPainter.
  static const quantum = FuturisticTheme(
    accentColor: Color(0xFF00D4FF),
    baseColor: Color(0xFF0D1117),
    backgroundColor: Color(0xFF060A0F),
    glowGradient: LinearGradient(
      colors: [Color(0xFF00D4FF), Color(0xFF7B26F7)],
    ),
  );

  /// Cosmos: deep-space blue + nebula purple. Pairs with CosmosPainter.
  static const cosmos = FuturisticTheme(
    accentColor: Color(0xFF5B8CFF),
    baseColor: Color(0xFF02040D),
    backgroundColor: Color(0xFF010208),
    glowGradient: LinearGradient(
      colors: [Color(0xFF5B8CFF), Color(0xFF7B26F7)],
    ),
  );

  /// Hologram: iridescent cyan. Pairs with HologramPainter.
  static const hologram = FuturisticTheme(
    accentColor: Color(0xFF00FFFF),
    baseColor: Color(0xFF050D15),
    backgroundColor: Color(0xFF020810),
    glowGradient: LinearGradient(
      colors: [Color(0xFF00FFFF), Color(0xFFAA00FF)],
    ),
  );

  /// Singularity: gravitational gold on void black. Pairs with SingularityPainter.
  static const singularity = FuturisticTheme(
    accentColor: Color(0xFFFFC400),
    baseColor: Color(0xFF050505),
    backgroundColor: Color(0xFF000000),
    glowGradient: LinearGradient(
      colors: [Color(0xFFFFC400), Color(0xFFFF6D00)],
    ),
  );

  /// Synapse: bio-electric green. Pairs with SynapsePainter.
  static const synapse = FuturisticTheme(
    accentColor: Color(0xFF00FF88),
    baseColor: Color(0xFF020408),
    backgroundColor: Color(0xFF010204),
    glowGradient: LinearGradient(
      colors: [Color(0xFF00FF88), Color(0xFF00B4D8)],
    ),
  );

  /// Kinetic: electric orange on near-black. Pairs with KineticPainter.
  static const kinetic = FuturisticTheme(
    accentColor: Color(0xFFFF6B35),
    baseColor: Color(0xFF12121A),
    backgroundColor: Color(0xFF0A0A10),
    glowGradient: LinearGradient(
      colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
    ),
  );

  /// Liquid Metal: chrome silver with cyan shimmer. Pairs with LiquidMetalPainter.
  static const liquidMetal = FuturisticTheme(
    accentColor: Color(0xFFB0C4DE),
    baseColor: Color(0xFF1C1C1C),
    backgroundColor: Color(0xFF111111),
    glowGradient: LinearGradient(
      colors: [Color(0xFFB0C4DE), Color(0xFF00D4FF)],
    ),
  );

  /// Prism: white crystal clarity. Pairs with PrismPainter.
  static const prism = FuturisticTheme(
    accentColor: Color(0xFFFFFFFF),
    baseColor: Color(0xFF1A1A2E),
    backgroundColor: Color(0xFF0F0F1A),
    glowGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFF7B26F7)],
    ),
  );

  /// Sumi: ink-on-paper Japanese aesthetic. Pairs with SumiPainter.
  static const sumi = FuturisticTheme(
    accentColor: Color(0xFF1A1A1A),
    baseColor: Color(0xFFF5F5F0),
    backgroundColor: Color(0xFFEEEEE8),
    glowGradient: LinearGradient(
      colors: [Color(0xFF1A1A1A), Color(0xFFB22222)],
    ),
  );

  /// Monolith: razor white light on matte black. Pairs with MonolithPainter.
  static const monolith = FuturisticTheme(
    accentColor: Color(0xFFFFFFFF),
    baseColor: Color(0xFF0F0F13),
    backgroundColor: Color(0xFF080808),
    glowGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFF888888)],
    ),
  );

  /// Obsidian: violet glow on pure obsidian. Pairs with ObsidianPainter.
  static const obsidian = FuturisticTheme(
    accentColor: Color(0xFF9B59B6),
    baseColor: Color(0xFF0A0A0A),
    backgroundColor: Color(0xFF050505),
    glowGradient: LinearGradient(
      colors: [Color(0xFF9B59B6), Color(0xFF3498DB)],
    ),
  );

  /// Chronos: amber mechanical. Pairs with ChronosPainter.
  static const chronos = FuturisticTheme(
    accentColor: Color(0xFFFFB300),
    baseColor: Color(0xFF1A1A1A),
    backgroundColor: Color(0xFF0D0D0D),
    glowGradient: LinearGradient(
      colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
    ),
  );

  /// Floating: frosted glass on soft dark. Pairs with FloatingPainter.
  static const floating = FuturisticTheme(
    accentColor: Color(0xFF64B5F6),
    baseColor: Color(0xFF1E2A3A),
    backgroundColor: Color(0xFF0F1620),
    glowGradient: LinearGradient(
      colors: [Color(0xFF64B5F6), Color(0xFF7E57C2)],
    ),
  );
}
