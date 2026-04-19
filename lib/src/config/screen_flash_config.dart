import 'package:flutter/material.dart';

/// Configuration for the Screen Flash anti-spoofing test.
///
/// When enabled, the screen briefly flashes red, green, and blue after the
/// face is centred. A real face reflects the light; a printed photo or
/// video replay does not respond with the expected brightness change.
class ScreenFlashConfig {
  /// Whether the screen-flash test is active.
  final bool enabled;

  /// Colors cycled during the flash test (in order).
  final List<Color> flashColors;

  /// Camera frames to capture per flash color (more = stabler reading).
  final int framesPerColor;

  /// Camera frames sampled before any flash (establishes baseline luminance).
  final int baselineFrames;

  /// Frames to skip at the start of each flash color phase while the camera
  /// and UI settle before sampling begins. Prevents reading AEC-transitioning
  /// frames that haven't stabilised yet.
  final int warmupFramesPerColor;

  /// Minimum luminance delta (0–255 scale) required per color to pass.
  /// Kept intentionally low because AEC partially offsets the flash; the test
  /// looks for any positive response, not the full flash magnitude.
  final double reflectionThreshold;

  /// When `true`, a failed flash test marks the session as spoofing detected.
  /// When `false`, the result is reported via callback but the session continues.
  final bool failSessionOnSpoofing;

  const ScreenFlashConfig({
    this.enabled = false,
    this.flashColors = const [
      Color(0xFFFF0000),
      Color(0xFF00FF00),
      Color(0xFF0000FF),
    ],
    this.framesPerColor = 5,
    this.baselineFrames = 3,
    this.warmupFramesPerColor = 2,
    this.reflectionThreshold = 4.0,
    this.failSessionOnSpoofing = false,
  });
}
