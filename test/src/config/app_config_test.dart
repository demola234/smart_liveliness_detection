import 'package:flutter_test/flutter_test.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() {
  // LivenessConfig mock
  const LivenessConfig livenessConfig = LivenessConfig();

  group('LivenessConfig - copyWith', () {
    test('copyWith creates a new instance with updated values', () {
      // Arrange & Act
      final updatedConfig = livenessConfig.copyWith(
        minFaceSize: 0.5,
        alwaysIncludeBlink: true,
        cameraRestartDelay: const Duration(seconds: 2),
      );

      // Assert
      expect(updatedConfig, isNot(same(livenessConfig)));
      expect(updatedConfig.minFaceSize, equals(0.5));
      expect(updatedConfig.alwaysIncludeBlink, isTrue);
      expect(
          updatedConfig.cameraRestartDelay, equals(const Duration(seconds: 2)));
    });

    test('copyWith retains existing values when parameters are null', () {
      // Arrange & Act
      final updatedConfig = livenessConfig.copyWith();

      // Assert
      expect(updatedConfig, isNot(same(livenessConfig)));
      expect(updatedConfig.minFaceSize, equals(livenessConfig.minFaceSize));
      expect(updatedConfig.alwaysIncludeBlink,
          equals(livenessConfig.alwaysIncludeBlink));
      expect(updatedConfig.cameraRestartDelay,
          equals(livenessConfig.cameraRestartDelay));
    });

    test('LivenessConfig performance values are correct', () {
      // Arrange & Act
      final performanceLivenessConfig = LivenessConfig.performance();

      // Assert
      expect(performanceLivenessConfig.frameSkipInterval, 1);
      expect(performanceLivenessConfig.maxConsecutiveErrors, 8);
      expect(performanceLivenessConfig.enableAggressiveErrorRecovery, false);
      expect(performanceLivenessConfig.enablePerformanceMonitoring, true);
      expect(performanceLivenessConfig.maxFrameDropRate, 0.5);
    });

    test('LivenessConfig debug values are correct', () {
      // Arrange & Act
      final performanceLivenessConfig = LivenessConfig.debug();

      // Assert
      expect(performanceLivenessConfig.frameSkipInterval, 4);
      expect(performanceLivenessConfig.maxConsecutiveErrors, 2);
      expect(performanceLivenessConfig.enableAggressiveErrorRecovery, true);
      expect(performanceLivenessConfig.enablePerformanceMonitoring, true);
      expect(performanceLivenessConfig.maxFrameDropRate, 0.9);
    });
  });
}
