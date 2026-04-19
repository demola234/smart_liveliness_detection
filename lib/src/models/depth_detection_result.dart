/// Result from a single ARKit depth analysis frame.
class DepthDetectionResult {
  /// `true` when the face passes the depth test (appears three-dimensional).
  final bool passed;

  /// Standard deviation of face-mesh vertex Z-coordinates (metres).
  final double depthStdDev;

  /// Variance of face-mesh vertex Z-coordinates (metres²).
  final double depthVariance;

  /// Confidence score 0.0–1.0 based on how far [depthStdDev] exceeds the threshold.
  final double confidence;

  /// Number of ARKit face-mesh vertices used in the calculation (~1 220).
  final int vertexCount;

  /// Whether the device has a TrueDepth camera.
  final bool isTrueDepthAvailable;

  const DepthDetectionResult({
    required this.passed,
    required this.depthStdDev,
    required this.depthVariance,
    required this.confidence,
    required this.vertexCount,
    required this.isTrueDepthAvailable,
  });

  /// Convenience: `true` when the face looks flat (possible photo/video replay).
  bool get isFlat => !passed;

  /// Unavailable placeholder returned when TrueDepth is not supported.
  static const DepthDetectionResult unavailable = DepthDetectionResult(
    passed: true,
    depthStdDev: 0,
    depthVariance: 0,
    confidence: 0,
    vertexCount: 0,
    isTrueDepthAvailable: false,
  );
}
