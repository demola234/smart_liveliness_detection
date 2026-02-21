import 'package:flutter/material.dart';
import 'package:smart_liveliness_detection/src/theme/futuristic_theme.dart';

/// Selects which futuristic painter is used for the liveness progress bar.
enum LivenessUiStyle {
  quantum,
  cosmos,
  hologram,
  singularity,
  synapse,
  kinetic,
  liquidMetal,
  prism,
  obsidian,
  monolith,
  chronos,
  floating,
  sumi,
}

extension LivenessUiStyleX on LivenessUiStyle {
  /// Human-readable display name.
  String get displayName => switch (this) {
        LivenessUiStyle.quantum => 'Quantum',
        LivenessUiStyle.cosmos => 'Cosmos',
        LivenessUiStyle.hologram => 'Hologram',
        LivenessUiStyle.singularity => 'Singularity',
        LivenessUiStyle.synapse => 'Synapse',
        LivenessUiStyle.kinetic => 'Kinetic',
        LivenessUiStyle.liquidMetal => 'Liquid Metal',
        LivenessUiStyle.prism => 'Prism',
        LivenessUiStyle.obsidian => 'Obsidian',
        LivenessUiStyle.monolith => 'Monolith',
        LivenessUiStyle.chronos => 'Chronos',
        LivenessUiStyle.floating => 'Floating',
        LivenessUiStyle.sumi => 'Sumi',
      };

  /// Short one-line description shown in the style picker.
  String get description => switch (this) {
        LivenessUiStyle.quantum => 'Magnetic deformation & neon pulse',
        LivenessUiStyle.cosmos => 'Deep space nebula & parallax stars',
        LivenessUiStyle.hologram => 'Iridescent scanline hologram',
        LivenessUiStyle.singularity => 'Warped spacetime & black hole',
        LivenessUiStyle.synapse => 'Neural network & bio-electric pulse',
        LivenessUiStyle.kinetic => 'Kinetic tile shingle physics',
        LivenessUiStyle.liquidMetal => 'Liquid chrome morphing',
        LivenessUiStyle.prism => 'Crystal chromatic dispersion',
        LivenessUiStyle.obsidian => 'Obsidian glow & dark matter',
        LivenessUiStyle.monolith => 'Minimal razor-slit light',
        LivenessUiStyle.chronos => 'Mechanical gear precision',
        LivenessUiStyle.floating => 'Frosted glass levitation',
        LivenessUiStyle.sumi => 'Japanese ink-wash paper',
      };

  /// Emoji icon used in the style picker card.
  String get icon => switch (this) {
        LivenessUiStyle.quantum => '⚛️',
        LivenessUiStyle.cosmos => '🌌',
        LivenessUiStyle.hologram => '🔮',
        LivenessUiStyle.singularity => '🕳️',
        LivenessUiStyle.synapse => '🧠',
        LivenessUiStyle.kinetic => '⚡',
        LivenessUiStyle.liquidMetal => '🪞',
        LivenessUiStyle.prism => '🔷',
        LivenessUiStyle.obsidian => '🖤',
        LivenessUiStyle.monolith => '▮',
        LivenessUiStyle.chronos => '⚙️',
        LivenessUiStyle.floating => '🫧',
        LivenessUiStyle.sumi => '🖌️',
      };

  /// The [FuturisticTheme] that pairs with this style.
  FuturisticTheme get theme => switch (this) {
        LivenessUiStyle.quantum => FuturisticTheme.quantum,
        LivenessUiStyle.cosmos => FuturisticTheme.cosmos,
        LivenessUiStyle.hologram => FuturisticTheme.hologram,
        LivenessUiStyle.singularity => FuturisticTheme.singularity,
        LivenessUiStyle.synapse => FuturisticTheme.synapse,
        LivenessUiStyle.kinetic => FuturisticTheme.kinetic,
        LivenessUiStyle.liquidMetal => FuturisticTheme.liquidMetal,
        LivenessUiStyle.prism => FuturisticTheme.prism,
        LivenessUiStyle.obsidian => FuturisticTheme.obsidian,
        LivenessUiStyle.monolith => FuturisticTheme.monolith,
        LivenessUiStyle.chronos => FuturisticTheme.chronos,
        LivenessUiStyle.floating => FuturisticTheme.floating,
        LivenessUiStyle.sumi => FuturisticTheme.sumi,
      };

  /// The accent color used for oval-guide & status tinting on this style.
  Color get accentColor => theme.accentColor;

  /// Whether this style uses a light background (affects text/icon contrast).
  bool get isLightBackground => this == LivenessUiStyle.sumi;
}
