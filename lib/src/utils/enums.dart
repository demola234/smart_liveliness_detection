enum ChallengeType { blink, turnLeft, turnRight, smile, nod, tiltUp, tiltDown, normal, zoom }

enum LivenessState {
  initial,
  centeringFace,
  screenFlashTest,
  performingChallenges,
  completed
}

enum ChallengeHintPosition {
  topCenter,
  bottomCenter,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Visual container style for the challenge hint GIF guide.
enum ChallengeHintStyle {
  /// White card with subtle drop shadow — clean, neutral (default).
  plain,

  /// Dark semi-transparent panel with a white border — blends with camera feed.
  glass,

  /// Dark background with a coloured glowing border — matches futuristic themes.
  futuristic,

  /// Circular frame with no background, just a thin accent ring — minimal.
  minimal,

  /// Dark background with a bright outer neon glow — high-contrast, vivid.
  neon,
}

/// Entrance/exit animation style for the challenge hint widget.
enum ChallengeHintAnimation {
  /// Scale up with a slight overshoot, fade in (default).
  scaleIn,

  /// Slide up from below while fading in.
  slideUp,

  /// Elastic bounce scale — snappy spring feel.
  bounceIn,

  /// Horizontal flip reveal — card-flip effect.
  flipIn,
}
