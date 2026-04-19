import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:smart_liveliness_detection/src/models/depth_detection_result.dart';

/// Communicates with the native ARKit depth plugin (iOS TrueDepth camera).
///
/// On Android or unsupported devices all methods no-op gracefully and
/// [checkAvailability] returns `false`.
class DepthDetectionService {
  static const _method =
      MethodChannel('smart_liveliness_detection/depth');
  static const _events =
      EventChannel('smart_liveliness_detection/depth/events');

  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<DepthDetectionResult>.broadcast();

  bool _isAvailable = false;
  bool _isRunning = false;

  /// Whether the current device has a TrueDepth camera.
  bool get isAvailable => _isAvailable;

  /// Checks hardware availability. Must be called before [startSession].
  Future<bool> checkAvailability() async {
    if (!Platform.isIOS) {
      _isAvailable = false;
      return false;
    }
    try {
      final result = await _method.invokeMapMethod<String, dynamic>(
          'checkAvailability');
      _isAvailable = (result?['available'] as bool?) ?? false;
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  /// Starts an ARKit face-tracking session and begins streaming depth results.
  Future<void> startSession() async {
    if (!_isAvailable || _isRunning) return;
    try {
      await _method.invokeMethod<void>('startSession');
      _isRunning = true;
      _subscription = _events.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is! Map) return;
          final map = Map<String, dynamic>.from(event);
          _controller.add(DepthDetectionResult(
            passed: !(map['isFlat'] as bool? ?? true),
            depthStdDev: (map['depthStdDev'] as num?)?.toDouble() ?? 0,
            depthVariance: (map['depthVariance'] as num?)?.toDouble() ?? 0,
            confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
            vertexCount: (map['vertexCount'] as int?) ?? 0,
            isTrueDepthAvailable: true,
          ));
        },
        onError: (_) {},
      );
    } catch (_) {
      _isRunning = false;
    }
  }

  /// Stops the ARKit session.
  Future<void> stopSession() async {
    if (!_isRunning) return;
    _subscription?.cancel();
    _subscription = null;
    _isRunning = false;
    try {
      await _method.invokeMethod<void>('stopSession');
    } catch (_) {}
  }

  /// Stream of depth results from ARKit. Empty on unsupported devices.
  Stream<DepthDetectionResult> get results => _controller.stream;

  void dispose() {
    stopSession();
    _controller.close();
  }
}
