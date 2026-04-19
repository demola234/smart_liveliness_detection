import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../config/screen_flash_config.dart';
import '../models/screen_flash_result.dart';

enum ScreenFlashPhase { idle, baseline, flashRed, flashGreen, flashBlue, done }

/// Manages the screen-flash anti-spoofing test state machine.
///
/// Call [start] once to begin, then pass every face-detected camera frame to
/// [processFrame]. When the test is complete, [processFrame] returns a
/// [ScreenFlashResult]; until then it returns `null`.
///
/// Expose [activeFlashColor] to the UI so the correct colored overlay is shown
/// on screen during each phase.
class ScreenFlashService {
  final ScreenFlashConfig config;

  ScreenFlashPhase _phase = ScreenFlashPhase.idle;

  /// Warmup frames skipped at the start of each color phase
  int _warmupCounter = 0;

  final List<double> _baselineReadings = [];
  final Map<String, List<double>> _flashReadings = {
    'red': [],
    'green': [],
    'blue': [],
  };

  ScreenFlashService({required this.config});

  ScreenFlashPhase get phase => _phase;

  /// Color that should be shown as a full-screen overlay right now.
  /// `null` means no overlay (baseline or idle phase).
  Color? get activeFlashColor {
    switch (_phase) {
      case ScreenFlashPhase.flashRed:
        return const Color(0xFFFF0000);
      case ScreenFlashPhase.flashGreen:
        return const Color(0xFF00FF00);
      case ScreenFlashPhase.flashBlue:
        return const Color(0xFF0000FF);
      default:
        return null;
    }
  }

  bool get isRunning =>
      _phase != ScreenFlashPhase.idle && _phase != ScreenFlashPhase.done;

  void start() {
    _phase = ScreenFlashPhase.baseline;
    _warmupCounter = 0;
    _baselineReadings.clear();
    _flashReadings.forEach((_, list) => list.clear());
  }

  void reset() {
    _phase = ScreenFlashPhase.idle;
    _warmupCounter = 0;
    _baselineReadings.clear();
    _flashReadings.forEach((_, list) => list.clear());
  }

  /// Process one camera frame. Returns [ScreenFlashResult] when all phases
  /// are complete, otherwise `null`.
  ScreenFlashResult? processFrame(Face face, CameraImage image) {
    if (_phase == ScreenFlashPhase.idle || _phase == ScreenFlashPhase.done) {
      return null;
    }

    final lum = _sampleFaceLuminance(image, face.boundingBox);

    switch (_phase) {
      case ScreenFlashPhase.baseline:
        _baselineReadings.add(lum);
        if (_baselineReadings.length >= config.baselineFrames) {
          _phase = ScreenFlashPhase.flashRed;
        }

      case ScreenFlashPhase.flashRed:
        if (_warmupCounter < config.warmupFramesPerColor) {
          _warmupCounter++;
          break;
        }
        _flashReadings['red']!.add(lum);
        if (_flashReadings['red']!.length >= config.framesPerColor) {
          _phase = ScreenFlashPhase.flashGreen;
          _warmupCounter = 0;
        }

      case ScreenFlashPhase.flashGreen:
        if (_warmupCounter < config.warmupFramesPerColor) {
          _warmupCounter++;
          break;
        }
        _flashReadings['green']!.add(lum);
        if (_flashReadings['green']!.length >= config.framesPerColor) {
          _phase = ScreenFlashPhase.flashBlue;
          _warmupCounter = 0;
        }

      case ScreenFlashPhase.flashBlue:
        if (_warmupCounter < config.warmupFramesPerColor) {
          _warmupCounter++;
          break;
        }
        _flashReadings['blue']!.add(lum);
        if (_flashReadings['blue']!.length >= config.framesPerColor) {
          _phase = ScreenFlashPhase.done;
          return _buildResult();
        }

      default:
        break;
    }
    return null;
  }

  ScreenFlashResult _buildResult() {
    final baseline = _mean(_baselineReadings);
    final deltas = <String, double>{};
    _flashReadings.forEach((color, readings) {
      deltas[color] = _mean(readings) - baseline;
    });

    // Pass if ≥ 2 colors show a positive delta above threshold
    final passingColors =
        deltas.values.where((d) => d >= config.reflectionThreshold).length;
    final passed = passingColors >= 2;

    // Confidence: average positive delta normalised to an expected max of 50
    final avgPositiveDelta =
        deltas.values.fold(0.0, (acc, d) => acc + d.clamp(0.0, 50.0)) / 3;
    final confidence = (avgPositiveDelta / 50.0).clamp(0.0, 1.0);

    return ScreenFlashResult(
      passed: passed,
      colorDeltas: deltas,
      baselineLuminance: baseline,
      confidence: confidence,
    );
  }

  double _mean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _sampleFaceLuminance(CameraImage image, Rect faceRect) {
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
      const step = 6;

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
      return count > 0 ? sum / count : 0;
    } catch (_) {
      return 0;
    }
  }
}
