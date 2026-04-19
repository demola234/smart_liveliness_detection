import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../models/biometric_template.dart';

/// Compares two [BiometricTemplate]s and returns a similarity score.
class BiometricMatcher {
  BiometricMatcher._();

  /// Compares [template1] against [template2] and returns a cosine similarity
  /// score in the range `0.0` (no similarity) to `1.0` (identical).
  ///
  /// [obfuscationKey] must be supplied if the templates were produced with an
  /// obfuscation key, so the vectors can be decoded before comparison.
  ///
  /// [threshold] is not enforced here — use it to decide a pass/fail yourself.
  static double compare(
    BiometricTemplate template1,
    BiometricTemplate template2, {
    Uint8List? obfuscationKey,
  }) {
    if (template1.algorithm != template2.algorithm) return 0.0;

    final v1 = _decode(template1, obfuscationKey);
    final v2 = _decode(template2, obfuscationKey);

    if (v1 == null || v2 == null || v1.length != v2.length) return 0.0;
    return _cosineSimilarity(v1, v2);
  }

  /// Checks whether [template1] and [template2] refer to the same person.
  ///
  /// Equivalent to `compare(...) >= threshold`.
  static bool isMatch(
    BiometricTemplate template1,
    BiometricTemplate template2, {
    double threshold = 0.80,
    Uint8List? obfuscationKey,
  }) =>
      compare(template1, template2, obfuscationKey: obfuscationKey) >= threshold;

  // ---------------------------------------------------------------------------

  static Float32List? _decode(
      BiometricTemplate template, Uint8List? obfuscationKey) {
    // If the raw vector is still attached (no obfuscation), use it directly.
    if (template.rawVector != null) return template.rawVector;

    try {
      var bytes = base64Decode(template.encodedVector);
      if (obfuscationKey != null) {
        final out = Uint8List(bytes.length);
        for (var i = 0; i < bytes.length; i++) {
          out[i] = bytes[i] ^ obfuscationKey[i % obfuscationKey.length];
        }
        bytes = out;
      }
      final bd = ByteData.sublistView(bytes);
      final count = bytes.length ~/ 4;
      final vec = Float32List(count);
      for (var i = 0; i < count; i++) {
        vec[i] = bd.getFloat32(i * 4, Endian.little);
      }
      return vec;
    } catch (_) {
      return null;
    }
  }

  static double _cosineSimilarity(Float32List a, Float32List b) {
    double dot = 0, normA = 0, normB = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom == 0) return 0.0;
    // Clamp to [-1, 1] before shifting to [0, 1]
    final cosine = (dot / denom).clamp(-1.0, 1.0);
    return (cosine + 1.0) / 2.0;
  }
}
