import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() {
  // LivenessThemeConfig mock
  const LivenessTheme themeConfig = LivenessTheme();
  group('LivenessTheme - copyWith', () {
    test('copyWith creates a new instance with updated values', () {
      // Arrange & Act
      final updatedConfig = themeConfig.copyWith(
        backgroundColor: const Color(0xFF000000),
        overlayColor: const Color(0x80000000),
        instructionTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        statusTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        guidanceTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        progressIndicatorColor: Colors.green,
        progressIndicatorBackgroundColor: Colors.grey,
      );

      // Assert
      expect(updatedConfig, isNot(same(themeConfig)));
      expect(updatedConfig.backgroundColor, equals(const Color(0xFF000000)));
      expect(updatedConfig.overlayColor, equals(const Color(0x80000000)));
      expect(
          updatedConfig.instructionTextStyle,
          equals(const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )));
      expect(
          updatedConfig.statusTextStyle,
          equals(const TextStyle(
            color: Colors.black,
            fontSize: 16,
          )));
      expect(
          updatedConfig.guidanceTextStyle,
          equals(const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          )));
    });

    test('copyWith retains existing values when parameters are null', () {
      // Arrange & Act
      final updatedConfig = themeConfig.copyWith();

      // Assert
      expect(updatedConfig, isNot(same(themeConfig)));
      expect(
          updatedConfig.backgroundColor, equals(themeConfig.backgroundColor));
      expect(updatedConfig.overlayColor, equals(themeConfig.overlayColor));
      expect(updatedConfig.instructionTextStyle,
          equals(themeConfig.instructionTextStyle));
    });
  });
}
