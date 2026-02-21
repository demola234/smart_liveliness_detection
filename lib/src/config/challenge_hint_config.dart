import 'package:flutter/material.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';

class ChallengeHintConfig {
  final bool enabled;

  final String? assetPath;

  final ChallengeHintPosition position;

  final double size;

  final Duration displayDuration;

  final bool animateEntrance;

  final bool isLottie;

  /// Visual container style for the hint guide.
  final ChallengeHintStyle hintStyle;

  /// Entrance / exit animation for the hint guide.
  final ChallengeHintAnimation hintAnimation;

  /// Accent colour used by [ChallengeHintStyle.futuristic] and
  /// [ChallengeHintStyle.neon] borders / glows.
  /// Falls back to cyan (`0xFF00D4FF`) when not provided.
  final Color? accentColor;

  const ChallengeHintConfig({
    this.enabled = true,
    this.assetPath,
    this.position = ChallengeHintPosition.topCenter,
    this.size = 100.0,
    this.displayDuration = const Duration(seconds: 2),
    this.animateEntrance = true,
    this.isLottie = false,
    this.hintStyle = ChallengeHintStyle.plain,
    this.hintAnimation = ChallengeHintAnimation.scaleIn,
    this.accentColor,
  });

  ChallengeHintConfig copyWith({
    bool? enabled,
    String? assetPath,
    ChallengeHintPosition? position,
    double? size,
    Duration? displayDuration,
    bool? animateEntrance,
    bool? isLottie,
    ChallengeHintStyle? hintStyle,
    ChallengeHintAnimation? hintAnimation,
    Color? accentColor,
  }) {
    return ChallengeHintConfig(
      enabled: enabled ?? this.enabled,
      assetPath: assetPath ?? this.assetPath,
      position: position ?? this.position,
      size: size ?? this.size,
      displayDuration: displayDuration ?? this.displayDuration,
      animateEntrance: animateEntrance ?? this.animateEntrance,
      isLottie: isLottie ?? this.isLottie,
      hintStyle: hintStyle ?? this.hintStyle,
      hintAnimation: hintAnimation ?? this.hintAnimation,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  factory ChallengeHintConfig.disabled() {
    return const ChallengeHintConfig(enabled: false);
  }

  static Map<ChallengeType, String> get defaultAssetPaths => {
        ChallengeType.blink: 'assets/gif/blink.gif',
        ChallengeType.smile: 'assets/gif/smile.gif',
        ChallengeType.nod: 'assets/gif/nod.gif',
        ChallengeType.turnLeft: 'assets/gif/rotate_left.gif',
        ChallengeType.turnRight: 'assets/gif/rotate_right.gif',
      };
}
