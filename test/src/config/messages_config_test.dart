import 'package:flutter_test/flutter_test.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() {
  group('MessagesConfig - ', () {
    test('Default constructor sets correct default values', () {
      // Arrange & Act
      const defaultConfig = LivenessMessages();

      // Assert
      expect(defaultConfig.moveFartherAway, equals('Move farther away'));
      expect(defaultConfig.moveCloser, equals('Move closer'));
      expect(defaultConfig.moveRight, equals('Move right'));
      expect(defaultConfig.moveLeft, equals('Move left'));
      expect(defaultConfig.moveUp, equals('Move up'));
      expect(defaultConfig.moveDown, equals('Move down'));
      expect(defaultConfig.perfectHoldStill, equals('Perfect! Hold still'));
      expect(defaultConfig.noFaceDetected, equals('No face detected'));
      expect(defaultConfig.errorCheckingFacePosition,
          equals('Error checking face position'));
      expect(defaultConfig.initializing, equals('Initializing...'));
      expect(
          defaultConfig.initializingCamera, equals('Initializing camera...'));
      expect(defaultConfig.errorInitializingCamera,
          equals('Error initializing camera. Please restart the app.'));
      expect(defaultConfig.initialInstruction,
          equals('Position your face in the oval'));
      expect(defaultConfig.poorLighting, equals('Please move to a better lit area'));
      expect(defaultConfig.processingVerification,
          equals('Processing verification...'));
      expect(defaultConfig.verificationComplete,
          equals('Liveness verification complete!'));
      expect(defaultConfig.spoofingDetected,
          equals('Potential spoofing detected.'));
      expect(
          defaultConfig.errorProcessing, equals('Processing error occurred'));
    });
  });
}
