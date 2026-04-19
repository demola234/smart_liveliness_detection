/// Result of a face quality analysis.
class FaceQualityResult {
  final double score;
  final List<String> issues;
  final List<String> recommendations;
  final Map<String, double> metrics; 
  const FaceQualityResult({
    required this.score,
    required this.issues,
    required this.recommendations,
    required this.metrics,
  });

  bool get isAcceptable => score >= 60.0;

  @override
  String toString() =>
      'FaceQualityResult(score: ${score.toStringAsFixed(1)}, issues: $issues)';
}
