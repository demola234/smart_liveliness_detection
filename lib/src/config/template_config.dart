import 'dart:typed_data';

/// Algorithm used to produce the biometric feature vector.
enum BiometricAlgorithm {
  /// Geometric facial ratios derived from ML Kit face landmarks.
  /// Lightweight, no ML model required.
  geometricRatios,
}

/// Configuration for biometric template generation.
class TemplateConfig {
  /// Algorithm to use when extracting the feature vector.
  final BiometricAlgorithm algorithm;

  /// When non-null, the serialised template bytes are XOR-obfuscated with this
  /// key before being returned to the caller.
  ///
  /// This is lightweight obfuscation, not cryptographic encryption. For
  /// production storage, wrap the output in AES or another cipher externally.
  final Uint8List? obfuscationKey;

  const TemplateConfig({
    this.algorithm = BiometricAlgorithm.geometricRatios,
    this.obfuscationKey,
  });
}
