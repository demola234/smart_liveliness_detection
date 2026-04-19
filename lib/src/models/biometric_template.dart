import 'dart:typed_data';

import 'package:smart_liveliness_detection/src/config/template_config.dart';

/// A compact, privacy-preserving biometric template derived from a liveness
/// session. Contains a feature vector that represents the geometric structure
/// of the detected face — it cannot be reversed into a face image.
class BiometricTemplate {
  /// Base64-encoded (and optionally obfuscated) feature-vector bytes.
  final String encodedVector;

  /// Raw float features before encoding (only populated when
  /// [TemplateConfig.obfuscationKey] is null).
  final Float32List? rawVector;

  /// Algorithm that produced this template.
  final BiometricAlgorithm algorithm;

  /// Session ID from the liveness session that produced this template.
  final String sessionId;

  /// UTC timestamp when the template was generated.
  final DateTime createdAt;

  /// Number of float features in the vector.
  final int featureCount;

  const BiometricTemplate({
    required this.encodedVector,
    required this.algorithm,
    required this.sessionId,
    required this.createdAt,
    required this.featureCount,
    this.rawVector,
  });

  Map<String, dynamic> toMap() => {
        'encodedVector': encodedVector,
        'algorithm': algorithm.name,
        'sessionId': sessionId,
        'createdAt': createdAt.toIso8601String(),
        'featureCount': featureCount,
      };
}
