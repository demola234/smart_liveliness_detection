/// Result of the screen-flash anti-spoofing test.
class ScreenFlashResult {
  /// Whether the test passed (face responded to screen illumination).
  final bool passed;

  /// Per-color luminance delta vs baseline (keys: 'red', 'green', 'blue').
  final Map<String, double> colorDeltas;

  /// Average face luminance captured before any flash.
  final double baselineLuminance;

  /// Confidence that the response is genuine (0.0–1.0).
  final double confidence;

  const ScreenFlashResult({
    required this.passed,
    required this.colorDeltas,
    required this.baselineLuminance,
    required this.confidence,
  });

  @override
  String toString() =>
      'ScreenFlashResult(passed: $passed, confidence: ${confidence.toStringAsFixed(2)}, deltas: $colorDeltas)';
}
