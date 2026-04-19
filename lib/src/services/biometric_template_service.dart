import 'dart:convert';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../config/template_config.dart';
import '../models/biometric_template.dart';

/// Extracts a biometric feature vector from an ML Kit [Face] and serialises it
/// into a [BiometricTemplate].
///
/// The vector is composed of normalised geometric ratios derived from
/// face landmarks — no raw pixel data or identifiable image is stored.
class BiometricTemplateService {
  /// Generates a [BiometricTemplate] from [face] detected during a session.
  ///
  /// Returns `null` when insufficient landmarks are available.
  BiometricTemplate? generate(
    Face face,
    String sessionId,
    TemplateConfig config,
  ) {
    final features = _extractFeatures(face);
    if (features == null) return null;

    final bytes = _toBytes(features);
    final obfuscated = config.obfuscationKey != null
        ? _xor(bytes, config.obfuscationKey!)
        : bytes;

    return BiometricTemplate(
      encodedVector: base64Encode(obfuscated),
      rawVector: config.obfuscationKey == null ? features : null,
      algorithm: config.algorithm,
      sessionId: sessionId,
      createdAt: DateTime.now().toUtc(),
      featureCount: features.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Feature extraction
  // ---------------------------------------------------------------------------

  Float32List? _extractFeatures(Face face) {
    final box = face.boundingBox;
    final fw = box.width;
    final fh = box.height;
    if (fw <= 0 || fh <= 0) return null;

    // Helper: return normalised (x, y) relative to the bounding box origin,
    // or (0, 0) if the landmark is absent.
    (double, double) lm(FaceLandmarkType type) {
      final pt = face.landmarks[type]?.position;
      if (pt == null) return (0.0, 0.0);
      return ((pt.x - box.left) / fw, (pt.y - box.top) / fh);
    }

    final (lex, ley) = lm(FaceLandmarkType.leftEye);
    final (rex, rey) = lm(FaceLandmarkType.rightEye);
    final (nx, ny) = lm(FaceLandmarkType.noseBase);
    final (bx, by) = lm(FaceLandmarkType.bottomMouth);
    final (lcx, lcy) = lm(FaceLandmarkType.leftCheek);
    final (rcx, rcy) = lm(FaceLandmarkType.rightCheek);
    final (lex2, ley2) = lm(FaceLandmarkType.leftEar);
    final (rex2, rey2) = lm(FaceLandmarkType.rightEar);

    // Derived geometric ratios:
    final eyeSpanX = (rex - lex).abs();
    final eyeSpanY = (rey - ley).abs();
    final eyeToNoseY = (ny - (ley + rey) / 2).abs();
    final noseToMouthY = (by - ny).abs();
    final cheekSpanX = (rcx - lcx).abs();
    final earSpanX = (rex2 - lex2).abs();
    final faceAspect = fw / (fh == 0 ? 1 : fh);

    final vector = Float32List.fromList([
      // Landmark positions (normalised)
      lex.toDouble(), ley.toDouble(),
      rex.toDouble(), rey.toDouble(),
      nx.toDouble(), ny.toDouble(),
      bx.toDouble(), by.toDouble(),
      lcx.toDouble(), lcy.toDouble(),
      rcx.toDouble(), rcy.toDouble(),
      lex2.toDouble(), ley2.toDouble(),
      rex2.toDouble(), rey2.toDouble(),
      // Derived ratios
      eyeSpanX.toDouble(),
      eyeSpanY.toDouble(),
      eyeToNoseY.toDouble(),
      noseToMouthY.toDouble(),
      cheekSpanX.toDouble(),
      earSpanX.toDouble(),
      faceAspect.toDouble(),
      // Soft-biometric hints (0 when unavailable)
      face.leftEyeOpenProbability?.toDouble() ?? 0.0,
      face.rightEyeOpenProbability?.toDouble() ?? 0.0,
      face.smilingProbability?.toDouble() ?? 0.0,
    ]);

    // Skip if most landmark positions are absent (all zeros beyond ratios)
    final nonZero = vector.take(16).where((v) => v != 0.0).length;
    if (nonZero < 4) return null;

    return vector;
  }

  // ---------------------------------------------------------------------------
  // Serialisation helpers
  // ---------------------------------------------------------------------------

  Uint8List _toBytes(Float32List floats) {
    final bd = ByteData(floats.length * 4);
    for (var i = 0; i < floats.length; i++) {
      bd.setFloat32(i * 4, floats[i], Endian.little);
    }
    return bd.buffer.asUint8List();
  }

  Uint8List _xor(Uint8List data, Uint8List key) {
    final out = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      out[i] = data[i] ^ key[i % key.length];
    }
    return out;
  }
}
