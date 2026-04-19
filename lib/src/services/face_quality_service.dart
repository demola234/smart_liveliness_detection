import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/face_quality_result.dart';

/// Analyzes face image quality and returns a scored result with issues and
/// recommendations.
class FaceQualityService {
  FaceQualityResult analyze(Face face, CameraImage image) {
    final issues = <String>[];
    final recommendations = <String>[];
    final metrics = <String, double>{};

    final brightness = _computeBrightness(image, face.boundingBox);
    final brightnessScore = _scoreBrightness(brightness);
    metrics['brightness'] = brightnessScore;
    if (brightnessScore < 40) {
      if (brightness < 80) {
        issues.add('Poor lighting');
        recommendations.add('Move to a brighter area');
      } else {
        issues.add('Overexposed');
        recommendations.add('Move away from direct light');
      }
    }

    final sharpness = _computeSharpness(image, face.boundingBox);
    final sharpnessScore = _scoreSharpness(sharpness);
    metrics['sharpness'] = sharpnessScore;
    if (sharpnessScore < 40) {
      issues.add('Image blurry');
      recommendations.add('Hold the device steady');
    }

    final poseScore = _scoreHeadPose(face);
    metrics['headPose'] = poseScore;
    if (poseScore < 50) {
      issues.add('Head not facing forward');
      recommendations.add('Look directly at the camera');
    }

    final sizeScore = _scoreFaceSize(face, image);
    metrics['faceSize'] = sizeScore;
    if (sizeScore < 40) {
      issues.add('Face too far or too close');
      recommendations.add('Adjust your distance from the camera');
    }

    final eyeScore = _scoreEyeOpenness(face);
    metrics['eyeOpenness'] = eyeScore;
    if (eyeScore < 40) {
      issues.add('Eyes not clearly visible');
      recommendations.add('Open your eyes wider and face the camera');
    }

    final score = (brightnessScore * 0.25 +
            sharpnessScore * 0.25 +
            poseScore * 0.25 +
            sizeScore * 0.15 +
            eyeScore * 0.10)
        .clamp(0.0, 100.0);

    return FaceQualityResult(
      score: score,
      issues: issues,
      recommendations: recommendations,
      metrics: metrics,
    );
  }

  double _computeBrightness(CameraImage image, Rect faceRect) {
    try {
      final x0 = faceRect.left.toInt().clamp(0, image.width - 1);
      final y0 = faceRect.top.toInt().clamp(0, image.height - 1);
      final x1 = faceRect.right.toInt().clamp(0, image.width);
      final y1 = faceRect.bottom.toInt().clamp(0, image.height);
      if (x1 <= x0 || y1 <= y0) return 128;

      final plane = image.planes[0];
      final bytes = plane.bytes;
      final bpr = plane.bytesPerRow;
      final isBGRA = image.format.group == ImageFormatGroup.bgra8888;
      const step = 8;

      double sum = 0;
      int count = 0;

      for (int y = y0; y < y1; y += step) {
        for (int x = x0; x < x1; x += step) {
          if (isBGRA) {
            final idx = y * bpr + x * 4;
            if (idx + 2 < bytes.length) {
              sum += 0.299 * bytes[idx + 2] +
                  0.587 * bytes[idx + 1] +
                  0.114 * bytes[idx];
              count++;
            }
          } else {
            final idx = y * bpr + x;
            if (idx < bytes.length) {
              sum += bytes[idx];
              count++;
            }
          }
        }
      }
      return count > 0 ? sum / count : 128;
    } catch (e) {
      debugPrint('FaceQualityService brightness error: $e');
      return 128;
    }
  }

  double _computeSharpness(CameraImage image, Rect faceRect) {
    try {
      final x0 = faceRect.left.toInt().clamp(0, image.width - 1);
      final y0 = faceRect.top.toInt().clamp(0, image.height - 1);
      final x1 = faceRect.right.toInt().clamp(0, image.width);
      final y1 = faceRect.bottom.toInt().clamp(0, image.height);
      if (x1 <= x0 || y1 <= y0) return 0;

      final plane = image.planes[0];
      final bytes = plane.bytes;
      final bpr = plane.bytesPerRow;
      final isBGRA = image.format.group == ImageFormatGroup.bgra8888;
      const step = 8;

      double sum = 0;
      double sumSq = 0;
      int count = 0;

      for (int y = y0; y < y1; y += step) {
        for (int x = x0; x < x1; x += step) {
          double lum;
          if (isBGRA) {
            final idx = y * bpr + x * 4;
            if (idx + 2 >= bytes.length) continue;
            lum = 0.299 * bytes[idx + 2] +
                0.587 * bytes[idx + 1] +
                0.114 * bytes[idx];
          } else {
            final idx = y * bpr + x;
            if (idx >= bytes.length) continue;
            lum = bytes[idx].toDouble();
          }
          sum += lum;
          sumSq += lum * lum;
          count++;
        }
      }

      if (count == 0) return 0;
      final mean = sum / count;
      final variance = (sumSq / count) - (mean * mean);
      return math.sqrt(variance.abs());
    } catch (e) {
      debugPrint('FaceQualityService sharpness error: $e');
      return 30;
    }
  }

  double _scoreHeadPose(Face face) {
    final rotX = (face.headEulerAngleX ?? 0).abs();
    final rotY = (face.headEulerAngleY ?? 0).abs();
    final rotZ = (face.headEulerAngleZ ?? 0).abs();
    final xScore = (1 - (rotX / 30).clamp(0.0, 1.0)) * 100;
    final yScore = (1 - (rotY / 30).clamp(0.0, 1.0)) * 100;
    final zScore = (1 - (rotZ / 30).clamp(0.0, 1.0)) * 100;
    return (xScore + yScore + zScore) / 3;
  }

  double _scoreFaceSize(Face face, CameraImage image) {
    final faceMax =
        math.max(face.boundingBox.width, face.boundingBox.height);
    final imgMin = math.min(image.width, image.height).toDouble();
    final ratio = faceMax / imgMin;

    if (ratio < 0.10) return 0;
    if (ratio < 0.25) return ((ratio - 0.10) / 0.15) * 60;
    if (ratio <= 0.65) return 100;
    if (ratio <= 0.90) return ((0.90 - ratio) / 0.25) * 60;
    return 0;
  }

  double _scoreEyeOpenness(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null && right == null) return 60;
    final avg = ((left ?? right)! + (right ?? left)!) / 2;
    return (avg * 100).clamp(0.0, 100.0);
  }

  double _scoreBrightness(double brightness) {
    if (brightness < 30) return 0;
    if (brightness < 80) return ((brightness - 30) / 50) * 60;
    if (brightness <= 200) return 100;
    if (brightness <= 240) return ((240 - brightness) / 40) * 60;
    return 0;
  }

  double _scoreSharpness(double stdDev) {
    if (stdDev < 5) return 0;
    if (stdDev < 20) return (stdDev / 20) * 60;
    if (stdDev < 60) return 60 + ((stdDev - 20) / 40) * 40;
    return 100;
  }
}
