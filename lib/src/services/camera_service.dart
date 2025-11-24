import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_liveliness_detection/src/config/app_config.dart';

/// Service for camera-related operations in liveness detection
class CameraService {
  /// Camera controller
  CameraController? _controller;

  /// Whether the camera is initialized
  bool _isInitialized = false;

  /// Current lighting value (0.0-1.0)
  double _lightingValue = 0.0;

  /// Whether lighting conditions are good
  bool _isLightingGood = true;

  /// Configuration for liveness detection
  LivenessConfig _config;

  /// Stream subscription for camera disposal tracking
  bool _isDisposing = false;

  /// Constructor with optional configuration
  CameraService({
    LivenessConfig? config,
  }) : _config = config ?? const LivenessConfig();

  /// Initialize the camera with improved error handling
  Future<CameraController> initialize(List<CameraDescription> cameras) async {
    if (_isInitialized && _controller != null && !_isDisposing) {
      return _controller!;
    }

    await dispose(); // Clean up any existing controller

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      // WARNING: Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      // TODO: What is the best option, high OR medium? It need to be tested!
      ResolutionPreset.medium,
      enableAudio: false,
      // WARNING: According to google_ml_kit_flutter, It only supports nv21 format for Android and bgra8888 for iOS
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888, // Explicitly set format
    );

    try {
      await _controller!.initialize();

      // Wait a bit longer for camera to stabilize
      await Future.delayed(const Duration(milliseconds: 500));

      if (_controller!.value.isInitialized && !_isDisposing) {
        try {
          // Set zoom level if supported
          final maxZoom = await _controller!.getMaxZoomLevel();
          if (maxZoom > 1.0) {
            double targetZoom = math.min(_config.cameraZoomLevel, maxZoom);
            await _controller!.setZoomLevel(targetZoom);
          }

          // Set focus mode to auto
          await _controller!.setFocusMode(FocusMode.auto);

          // Set flash mode to off (for front camera)
          await _controller!.setFlashMode(FlashMode.off);

        } catch (e) {
          debugPrint('Camera settings not supported: $e');
          // Continue even if some settings fail
        }
      }

      _isInitialized = true;
      _isDisposing = false;

      debugPrint('Camera initialized successfully');
      return _controller!;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      await dispose();
      rethrow;
    }
  }

  /// Start image stream with error handling
  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!_isInitialized || _controller == null || _isDisposing) {
      debugPrint('Cannot start image stream: camera not initialized');
      return;
    }

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await _controller!.startImageStream(onImage);
      debugPrint('Image stream started successfully');
    } catch (e) {
      debugPrint('Error starting image stream: $e');
      // Try to restart the camera after a brief delay
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!_isDisposing) {
          await _restartCamera();
        }
      });
    }
  }

  /// Stop image stream safely
  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      try {
        await _controller!.stopImageStream();
        debugPrint('Image stream stopped');
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
    }
  }

  /// Restart camera after error
  Future<void> _restartCamera() async {
    if (_isDisposing) return;

    debugPrint('Restarting camera...');
    try {
      final cameras = await availableCameras();
      await initialize(cameras);
    } catch (e) {
      debugPrint('Failed to restart camera: $e');
    }
  }

  /// Calculate lighting conditions from camera image with error handling
  void calculateLightingCondition(CameraImage image) {
    try {
      if (image.planes.isEmpty || image.planes[0].bytes.isEmpty) {
        debugPrint('Invalid image data for lighting calculation');
        return;
      }

      final Uint8List yPlane = image.planes[0].bytes;

      // Sample only a portion of pixels for performance
      const int sampleRate = 10; // Sample every 10th pixel
      int totalBrightness = 0;
      int sampledPixels = 0;

      for (int i = 0; i < yPlane.length; i += sampleRate) {
        totalBrightness += yPlane[i];
        sampledPixels++;
      }

      if (sampledPixels > 0) {
        final double avgBrightness = totalBrightness / sampledPixels;
        _lightingValue = avgBrightness / 255;
        _isLightingGood = _lightingValue > _config.minLightingThreshold;
      }
    } catch (e) {
      debugPrint('Error calculating lighting: $e');
      // Use default values on error
      _lightingValue = 0.5;
      _isLightingGood = true;
    }
  }

  /// Detect potential screen glare (anti-spoofing) with a dynamic threshold.
  bool detectScreenGlare(CameraImage image) {
    try {
      if (image.planes.isEmpty || image.planes[0].bytes.isEmpty) {
        return false;
      }

      final yPlane = image.planes[0].bytes;
      int totalPixels = yPlane.length;

      // Sample for average brightness
      const int sampleRate = 20;
      int sampledPixels = 0;
      int totalBrightness = 0;

      for (int i = 0; i < totalPixels; i += sampleRate) {
        totalBrightness += yPlane[i];
        sampledPixels++;
      }

      if (sampledPixels == 0) return false;

      final double avgBrightness = totalBrightness / sampledPixels;

      // Dynamic threshold based on average brightness
      final double glareThreshold = avgBrightness * _config.glareBrightnessFactor;

      int brightPixels = 0;
      for (int i = 0; i < totalPixels; i += sampleRate) {
        if (yPlane[i] > glareThreshold) {
          brightPixels++;
        }
      }

      double brightPercent = brightPixels / sampledPixels;

      return brightPercent > _config.minBrightPercentage &&
          brightPercent < _config.maxBrightPercentage;
    } catch (e) {
      debugPrint('Error detecting screen glare: $e');
      return false;
    }
  }

  /// Whether the camera is initialized
  bool get isInitialized => _isInitialized && _controller != null && !_isDisposing;

  /// Whether lighting conditions are good
  bool get isLightingGood => _isLightingGood;

  /// Current lighting value (0.0-1.0)
  double get lightingValue => _lightingValue;

  /// Camera controller
  CameraController? get controller => _controller;

  /// Update configuration
  void updateConfig(LivenessConfig config) async {
    _config = config;

    // Only update zoom if camera is initialized and zoom level changed
    if (_isInitialized &&
        _controller != null &&
        !_isDisposing &&
        _config.cameraZoomLevel != config.cameraZoomLevel) {
      try {
        final maxZoom = await _controller!.getMaxZoomLevel();
        if (maxZoom > 1.0) {
          double targetZoom = math.min(config.cameraZoomLevel, maxZoom);
          await _controller!.setZoomLevel(targetZoom);
        }
      } catch (e) {
        debugPrint('Zoom control not supported: $e');
      }
    }
  }

  /// Clean up resources with improved disposal
  Future<void> dispose() async {
    if (_isDisposing) return;
    _isDisposing = true;

    debugPrint('Disposing camera service...');

    try {
      if (_controller != null) {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    } finally {
      _controller = null;
      _isInitialized = false;
      debugPrint('Camera service disposed');
    }
  }
}
