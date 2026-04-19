/// Configuration for the 3D depth detection anti-spoofing feature (iOS only).
///
/// Uses the TrueDepth camera (iPhone X and later) via ARKit to measure the
/// three-dimensional structure of the face. A printed photo or video replay
/// has near-zero depth variance; a real face has significant Z-axis spread
/// across the facial mesh.
class DepthDetectionConfig {
  /// Whether depth detection is active for this session.
  final bool enabled;

  /// Minimum standard deviation (in metres) of ARKit face-mesh vertices along
  /// the Z-axis for the face to be considered three-dimensional.
  ///
  /// A real face typically yields 0.008–0.020 m. Flat surfaces (photos, screens)
  /// yield less than 0.003 m. Default: `0.004`.
  final double depthThreshold;

  /// When `true` and TrueDepth hardware is unavailable, the session fails
  /// immediately with an error. When `false` (default) the check is silently
  /// skipped and [DepthDetectionResult.isTrueDepthAvailable] is set to `false`.
  final bool requireTrueDepth;

  /// When `true`, a failing depth check ends the session and sets
  /// [isVerificationSuccessful] to `false`. When `false` (default) the result
  /// is only recorded in the anti-spoofing metadata.
  final bool failSessionOnSpoofing;

  /// Minimum number of depth frames that must be collected before the result
  /// is considered reliable. Default: `5`.
  final int minFramesRequired;

  const DepthDetectionConfig({
    this.enabled = true,
    this.depthThreshold = 0.004,
    this.requireTrueDepth = false,
    this.failSessionOnSpoofing = false,
    this.minFramesRequired = 5,
  });
}
