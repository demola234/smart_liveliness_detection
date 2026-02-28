import 'package:flutter_test/flutter_test.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() {
  // VoiceGuidanceConfig mock
  const VoiceGuidanceConfig voiceGuidanceConfig = VoiceGuidanceConfig();
  group('VoiceGuidanceConfig - copyWith', () {
    test('copyWith creates a new instance with updated values', () {
      // Arrange & Act
      final updatedConfig = voiceGuidanceConfig.copyWith(
          enabled: false,
          language: 'es',
          volume: 0.8,
          pitch: 1.2,
          speakPositioningFeedback: true);

      // Assert
      expect(updatedConfig, isNot(same(voiceGuidanceConfig)));
      expect(updatedConfig.enabled, equals(false));
      expect(updatedConfig.language, equals('es'));
      expect(updatedConfig.volume, equals(0.8));
      expect(updatedConfig.pitch, equals(1.2));
      expect(updatedConfig.speakChallengeInstructions, equals(true));
    });

    test('copyWith retains existing values when parameters are null', () {
      // Arrange & Act
      final updatedConfig = voiceGuidanceConfig.copyWith();

      // Assert
      expect(updatedConfig.enabled, equals(voiceGuidanceConfig.enabled));
      expect(updatedConfig.language, equals(voiceGuidanceConfig.language));
      expect(updatedConfig.volume, equals(voiceGuidanceConfig.volume));
      expect(updatedConfig.pitch, equals(voiceGuidanceConfig.pitch));
      expect(updatedConfig.speakChallengeInstructions,
          equals(voiceGuidanceConfig.speakChallengeInstructions));
    });
  });

  group('VoiceGuidanceConfig - factory constructors', () {
    test('minimal factory constructor sets correct values', () {
      // Arrange & Act
      final minimalConfig = VoiceGuidanceConfig.minimal();

      // Assert
      expect(minimalConfig.speakPositioningFeedback, equals(false));
      expect(minimalConfig.speakChallengeInstructions, equals(true));
      expect(minimalConfig.speakCompletion, equals(true));
    });

    test('accessibility factory constructor sets correct values', () {
      // Arrange & Act
      final accessibilityConfig = VoiceGuidanceConfig.accessibility();

      // Assert
      expect(accessibilityConfig.speechRate, equals(0.4));
      expect(accessibilityConfig.repeatInterval,
          equals(const Duration(seconds: 2)));
    });
  });
}
