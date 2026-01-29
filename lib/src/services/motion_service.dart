import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:smart_liveliness_detection/src/config/app_config.dart';

/// Service for motion tracking and spoofing detection
class MotionService {
  /// Accelerometer readings
  final List<AccelerometerEvent> _accelerometerReadings = [];

  /// Subscription to accelerometer events
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  /// Gyroscope readings
  final List<GyroscopeEvent> _gyroscopeReadings = [];

  /// Subscription to gyroscope events
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  /// Configuration for liveness detection
  LivenessConfig _config;

  /// Constructor with optional configuration
  MotionService({
    LivenessConfig? config,
  }) : _config = config ?? const LivenessConfig();

  /// Start tracking device motion
  void startAccelerometerTracking() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      _accelerometerReadings.add(event);
      if (_accelerometerReadings.length > _config.maxMotionReadings) {
        _accelerometerReadings.removeAt(0);
      }
    });

    if (_config.enableGyroscopeCheck) {
      _gyroscopeSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
        _gyroscopeReadings.add(event);
        if (_gyroscopeReadings.length > _config.maxMotionReadings) {
          _gyroscopeReadings.removeAt(0);
        }
      });
    }
  }

  /// Update configuration
  void updateConfig(LivenessConfig config) {
    _config = config;

    // Trim readings if the max count was reduced
    if (_accelerometerReadings.length > _config.maxMotionReadings) {
      _accelerometerReadings.removeRange(
          0, _accelerometerReadings.length - _config.maxMotionReadings);
    }
    if (_gyroscopeReadings.length > _config.maxMotionReadings) {
      _gyroscopeReadings.removeRange(
          0, _gyroscopeReadings.length - _config.maxMotionReadings);
    }
  }

  /// Calculates the standard deviation of a list of values.
  double _calculateStandardDeviation(List<double> values) {
    if (values.length < 2) {
      return 0.0;
    }
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = values.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  /// Check if head motion correlates with device motion (anti-spoofing).
  /// This version uses standard deviation for both head and device movement to be more robust.
  bool verifyMotionCorrelation(List<Offset> headAngleReadings) {
    // Fail-safe: if not enough data is available, we cannot prove it is a spoof.
    // Giving the benefit of the doubt to the user to avoid false positives on fast sessions.
    if (headAngleReadings.length < 10 || _accelerometerReadings.length < 10) {
      debugPrint('Not enough motion data to verify correlation, passing check (benefit of doubt).');
      return true;
    }

    // Calculate the standard deviation of head movement for both X and Y axes.
    final headAnglesX = headAngleReadings.map((o) => o.dx).toList();
    final headAnglesY = headAngleReadings.map((o) => o.dy).toList();
    double headAngleStdDevX = _calculateStandardDeviation(headAnglesX);
    double headAngleStdDevY = _calculateStandardDeviation(headAnglesY);

    // Calculate the standard deviation of device motion for each axis independently.
    // Using magnitude is flawed because rotation can change components without changing magnitude significantly.
    final deviceAccX = _accelerometerReadings.map((e) => e.x).toList();
    final deviceAccY = _accelerometerReadings.map((e) => e.y).toList();
    final deviceAccZ = _accelerometerReadings.map((e) => e.z).toList();

    double deviceStdDevX = _calculateStandardDeviation(deviceAccX);
    double deviceStdDevY = _calculateStandardDeviation(deviceAccY);
    double deviceStdDevZ = _calculateStandardDeviation(deviceAccZ);

    // We consider the "device motion" as the maximum deviation observed in any axis.
    double maxDeviceMotionStdDev = [deviceStdDevX, deviceStdDevY, deviceStdDevZ].reduce(math.max);

    debugPrint(
        'Head StdDev(X:${headAngleStdDevX.toStringAsFixed(2)}, Y:${headAngleStdDevY.toStringAsFixed(2)}) | Device StdDev(Max:${maxDeviceMotionStdDev.toStringAsFixed(2)})');

    // A significant head movement is detected if the standard deviation in either axis is above the threshold.
    bool significantHeadMovement = headAngleStdDevX > _config.significantHeadMovementStdDev ||
        headAngleStdDevY > _config.significantHeadMovementStdDev;

    // An insignificant device movement is detected if the MAX device deviation is below the threshold.
    // If Gyroscope check is enabled, we also check if the rotational movement is insignificant.
    bool insignificantDeviceMovement = maxDeviceMotionStdDev < _config.minDeviceMovementThreshold;

    if (_config.enableGyroscopeCheck && _gyroscopeReadings.length >= 10) {
      final deviceGyroX = _gyroscopeReadings.map((e) => e.x).toList();
      final deviceGyroY = _gyroscopeReadings.map((e) => e.y).toList();
      final deviceGyroZ = _gyroscopeReadings.map((e) => e.z).toList();

      double deviceGyroStdDevX = _calculateStandardDeviation(deviceGyroX);
      double deviceGyroStdDevY = _calculateStandardDeviation(deviceGyroY);
      double deviceGyroStdDevZ = _calculateStandardDeviation(deviceGyroZ);

      double maxDeviceGyroStdDev = [deviceGyroStdDevX, deviceGyroStdDevY, deviceGyroStdDevZ].reduce(math.max);
      
      debugPrint('Device Gyro StdDev(Max:${maxDeviceGyroStdDev.toStringAsFixed(2)})');

      bool insignificantGyroMovement = maxDeviceGyroStdDev < _config.minGyroscopeMovementThreshold;

      // To be considered a spoof with gyro enabled, BOTH accelerometer AND gyroscope must show minimal movement.
      insignificantDeviceMovement = insignificantDeviceMovement && insignificantGyroMovement;
    }

    // Spoofing is suspected if the head moved significantly, but the device did not.
    bool isSpoofingAttempt = significantHeadMovement && insignificantDeviceMovement;

    if (isSpoofingAttempt) {
      debugPrint('Potential spoofing detected: Significant head motion (StdDev) with minimal device motion.');
    }

    // The check is valid if no spoofing is detected.
    return !isSpoofingAttempt;
  }

  /// Reset all motion tracking
  void resetTracking() {
    _accelerometerReadings.clear();
    _gyroscopeReadings.clear();
  }

  /// Clean up resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  /// Get raw accelerometer readings
  List<AccelerometerEvent> get accelerometerReadings =>
      List<AccelerometerEvent>.unmodifiable(_accelerometerReadings);
      
  /// Get raw gyroscope readings
  List<GyroscopeEvent> get gyroscopeReadings =>
      List<GyroscopeEvent>.unmodifiable(_gyroscopeReadings);
}
