import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() {
  const assetPath = 'assets/hint.json';
  const newAssetPath = 'assets/new_hint.json';
  group('ChallengeHintConfig - ', () {
    test('copyWith creates a new instance with updated values', () {
      // Arrange
      const originalConfig = ChallengeHintConfig(
        enabled: true,
        assetPath: assetPath,
        position: ChallengeHintPosition.bottomCenter,
        size: 120.0,
        displayDuration: Duration(seconds: 3),
        animateEntrance: false,
        isLottie: true,
        hintStyle: ChallengeHintStyle.futuristic,
        hintAnimation: ChallengeHintAnimation.bounceIn,
        accentColor: Colors.cyanAccent,
      );

      // Act
      final updatedConfig = originalConfig.copyWith(
        enabled: false,
        assetPath: newAssetPath,
        position: ChallengeHintPosition.topLeft,
        size: 150.0,
        displayDuration: const Duration(seconds: 5),
        animateEntrance: true,
        isLottie: false,
        hintStyle: ChallengeHintStyle.neon,
        hintAnimation: ChallengeHintAnimation.scaleIn,
        accentColor: Colors.cyanAccent,
      );

      // Assert
      expect(updatedConfig, isNot(same(originalConfig)));
      expect(updatedConfig.enabled, equals(false));
      expect(updatedConfig.assetPath, equals(newAssetPath));
      expect(updatedConfig.position, equals(ChallengeHintPosition.topLeft));
      expect(updatedConfig.size, equals(150.0));
      expect(updatedConfig.displayDuration, equals(const Duration(seconds: 5)));
      expect(updatedConfig.animateEntrance, equals(true));
      expect(updatedConfig.isLottie, equals(false));
      expect(updatedConfig.hintStyle, equals(ChallengeHintStyle.neon));
      expect(
          updatedConfig.hintAnimation, equals(ChallengeHintAnimation.scaleIn));
      expect(updatedConfig.accentColor, equals(Colors.cyanAccent));
    });
  });

  group('ChallengeHintConfig - Default Values', () {
    test('Default constructor sets correct default values', () {
      // Arrange & Act
      const defaultConfig = ChallengeHintConfig();

      // Assert
      expect(defaultConfig.enabled, equals(true));
      expect(defaultConfig.assetPath, isNull);
      expect(defaultConfig.position, equals(ChallengeHintPosition.topCenter));
      expect(defaultConfig.size, equals(100.0));
      expect(defaultConfig.displayDuration, equals(const Duration(seconds: 2)));
      expect(defaultConfig.animateEntrance, equals(true));
      expect(defaultConfig.isLottie, equals(false));
      expect(defaultConfig.hintStyle, equals(ChallengeHintStyle.plain));
      expect(
          defaultConfig.hintAnimation, equals(ChallengeHintAnimation.scaleIn));
      expect(defaultConfig.accentColor, isNull);
    });
  });

  group('ChallengeHintConfig - Immutability', () {
    test('copyWith does not modify original instance', () {
      // Arrange
      const originalConfig = ChallengeHintConfig(
        enabled: true,
        assetPath: assetPath,
        position: ChallengeHintPosition.bottomCenter,
        size: 120.0,
        displayDuration: Duration(seconds: 3),
        animateEntrance: false,
        isLottie: true,
        hintStyle: ChallengeHintStyle.futuristic,
        hintAnimation: ChallengeHintAnimation.bounceIn,
        accentColor: Colors.cyanAccent,
      );

      // Act
      final updatedConfig = originalConfig.copyWith(
        enabled: false,
        assetPath: newAssetPath,
      );

      // Assert
      expect(originalConfig.enabled, equals(true));
      expect(originalConfig.assetPath, equals(assetPath));
      expect(updatedConfig.enabled, equals(false));
      expect(updatedConfig.assetPath, equals(newAssetPath));
    });
  });
}
