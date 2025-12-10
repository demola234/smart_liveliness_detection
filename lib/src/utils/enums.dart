enum ChallengeType { blink, turnLeft, turnRight, smile, nod, tiltUp, tiltDown, normal, zoom }

enum LivenessState {
  initial,
  centeringFace,
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
