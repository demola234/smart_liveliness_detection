import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_liveliness_detection/src/config/app_config.dart';
import 'package:smart_liveliness_detection/src/services/camera_service.dart';

import '../helper/helper.dart';

void main() {
  // Initialize Flutter test bindings for platform channel tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraService - Initialization', () {
    late CameraService cameraService;
    late MockCameraController mockController;
    late List<CameraDescription> mockCameras;
    late CameraDescription frontCamera;
    late CameraDescription backCamera;

    setUp(() {
      mockController = MockCameraController();
      cameraService = CameraService();

      frontCamera = FakeCameraDescription(
        name: 'Front Camera',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 90,
      );

      backCamera = FakeCameraDescription(
        name: 'Back Camera',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      mockCameras = [backCamera, frontCamera];
    });

    tearDown(() async {
      await cameraService.dispose();
    });

    test('should initialize with default configuration', () {
      // Arrange & Act - Create a CameraService with default config
      final service = CameraService();

      // Assert - Verify the service has correct initial state
      expect(service.isInitialized, false);
      expect(service.controller, isNull);
      expect(service.isLightingGood, true);
      expect(service.lightingValue, 0.0);
    });

    // TODO: Write test for custom configuration
    test('should initialize with custom configuration', () {
      // ARRANGE: Create a LivenessConfig with custom values
      const livenessConfig = LivenessConfig(
        minLightingThreshold: 0.3,
        cameraZoomLevel: 0.8,
      );
      // ACT: Create CameraService with the custom config
      final service = CameraService(config: livenessConfig);
      // ASSERT: Verify the service is created (state checks)
      expect(service.isInitialized, false);
      expect(service.controller, isNull);
      expect(service.isLightingGood, true);
      expect(service.lightingValue, 0.0);
    });

    // TODO: Write test for camera selection
    test('should prefer front camera when available', () {
      // HINT: Check that mockCameras[1] is the front camera
      // Verify its lensDirection is CameraLensDirection.front
      final selectedCamera = mockCameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => mockCameras.first,
      );
      expect(selectedCamera.lensDirection, CameraLensDirection.front);
      expect(selectedCamera.name, 'Front Camera');
    });

    // TODO: Write test for error handling
    test('should handle empty camera list', () {
      // HINT: Use expect(() => ..., throwsA(...))
      // Empty list should throw StateError
      expect(
        () {
          final cameras = <CameraDescription>[];
          cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );
        },
        throwsA(isA<StateError>()),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 📖 TESTING PATTERN: Testing State Management
  // ═══════════════════════════════════════════════════════════════

  group('CameraService - State Management', () {
    late CameraService cameraService;

    setUp(() {
      cameraService = CameraService();
    });

    tearDown(() async {
      await cameraService.dispose();
    });

    test('should start as not initialized', () {
      // Your code here
      expect(cameraService.isInitialized, false);
    });

    // TODO: Test that controller starts as null
    test('should have null controller initially', () {
      // HINT: Check cameraService.controller
      expect(cameraService.controller, isNull);
    });

    // TODO: Test default lighting values
    test('should have default lighting values', () {
      // HINT: Check isLightingGood and lightingValue
      expect(cameraService.isLightingGood, true);
      expect(cameraService.lightingValue, 0.0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 📖 TESTING PATTERN: Helper Functions for Test Data
  // ═══════════════════════════════════════════════════════════════

  group('CameraService - Lighting Detection', () {
    late CameraService cameraService;

    setUp(() {
      cameraService = CameraService(
        config: const LivenessConfig(minLightingThreshold: 0.3),
      );
    });

    tearDown(() async {
      await cameraService.dispose();
    });

    // ✅ HELPER FUNCTION: Create test camera images
    // BEST PRACTICE: Extract complex test data creation into helper functions
    FakeCameraImage createTestImage({
      required int brightness,
      int width = 640,
      int height = 480,
    }) {
      // Create Y plane (brightness) with uniform values
      final bytes = Uint8List(width * height);
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = brightness;
      }

      final plane = FakePlane(bytes, bytesPerRow: width);
      return FakeCameraImage(planes: [plane], width: width, height: height);
    }

    // ✅ EXAMPLE: Testing with test doubles
    test('should detect good lighting conditions', () {
      // ARRANGE: Create bright image (200/255 ≈ 0.78)
      final brightImage = createTestImage(brightness: 200);

      // ACT: Calculate lighting with fake camera image
      cameraService.calculateLightingCondition(brightImage);

      // ASSERT: Lighting should be good
      expect(cameraService.isLightingGood, true);
      expect(cameraService.lightingValue, greaterThan(0.3));
    });

    // TODO: Test poor lighting detection
    test('should detect poor lighting conditions', () {
      // HINT: Create dark image with brightness around 50
      final darkImage = createTestImage(brightness: 50);
      // ACT: Calculate lighting with fake camera image
      cameraService.calculateLightingCondition(darkImage);
      // ASSERT: Lighting should be poor
      expect(cameraService.lightingValue, lessThan(0.3));
      expect(cameraService.isLightingGood, false);
    });

    // TODO: Test edge case - empty image planes
    test('should handle empty image planes gracefully', () {
      // HINT: Create FakeCameraImage with empty planes list
      final emptyImage = FakeCameraImage(planes: []);
      // ACT: Calculate lighting with empty image
      cameraService.calculateLightingCondition(emptyImage);
      // Should not crash, verify safe default values
      expect(cameraService.lightingValue, 0.0);
      expect(cameraService.isLightingGood, true);
    });

    // TODO: Test edge case - corrupted data
    test('should handle corrupted image data', () {
      final corruptedPlane = FakePlane(Uint8List(0));
      final corruptedImage = FakeCameraImage(planes: [corruptedPlane]);
      // ACT: Calculate lighting with corrupted image
      cameraService.calculateLightingCondition(corruptedImage);
      // Should not crash, verify safe default values (0.0 when invalid)
      expect(cameraService.lightingValue, 0.0);
      expect(cameraService.isLightingGood, true);
    });

    // TODO: Test different brightness levels
    // Try brightness values: 0, 128, 255
  });

  // ═══════════════════════════════════════════════════════════════
  // 📖 TESTING PATTERN: Testing Complex Logic
  // ═══════════════════════════════════════════════════════════════

  group('CameraService - Glare Detection', () {
    late CameraService cameraService;

    setUp(() {
      cameraService = CameraService(
        config: const LivenessConfig(
          glareBrightnessFactor: 1.3,
          minBrightPercentage: 0.15,
          maxBrightPercentage: 0.45,
        ),
      );
    });

    tearDown(() async {
      await cameraService.dispose();
    });

    // Helper to create images with varying brightness
    FakeCameraImage createTestImage({
      required List<int> brightnessValues,
    }) {
      final bytes = Uint8List.fromList(brightnessValues);
      final plane = FakePlane(bytes);
      return FakeCameraImage(planes: [plane]);
    }

    // TODO: Test glare detection with screen-like pattern
    test('should detect screen glare', () {
      // HINT: Create image with mixed brightness
      final glareImage = createTestImage(
        brightnessValues: List<int>.generate(
          640 * 480,
          (index) => (index % 10 < 7) ? 100 : 250,
        ),
      );

      // ACT: Detect glare
      final hasGlare = cameraService.detectScreenGlare(glareImage);
      // Example: 70% normal (100), 30% bright (250)
      expect(hasGlare, isTrue);

      // Use createTestImage with appropriate brightnessValues
      // Remember to cast to dynamic: createTestImage(...) as dynamic
      
    });

    // TODO: Test normal conditions (no glare)
    test('should not detect glare in normal conditions', () {
      // HINT: Create image with uniform brightness around 120
    });

    // TODO: Test edge cases
    test('should handle empty image in glare detection', () {
      // Create empty FakeCameraImage
    });

    // TODO: Test extreme brightness patterns
  });

  // ═══════════════════════════════════════════════════════════════
  // 📖 YOUR PRACTICE AREA: Add More Test Groups
  // ═══════════════════════════════════════════════════════════════

  // TODO: Add test group for configuration updates
  group('CameraService - Configuration', () {
    // Test updateConfig() method
    // Verify configuration changes
  });

  // TODO: Add test group for cleanup/disposal
  group('CameraService - Cleanup', () {
    // Test dispose() works correctly
    // Test multiple dispose() calls don't crash
  });

  // TODO: Add test group for image stream operations
  group('CameraService - Image Stream', () {
    // Test startImageStream()
    // Test stopImageStream()
    // Test error handling in streams
  });
}

// ═══════════════════════════════════════════════════════════════
// 📚 QUICK REFERENCE: Common Test Matchers
// ═══════════════════════════════════════════════════════════════
// expect(value, equals(expected))       - Exact equality
// expect(value, isNull)                 - Value is null
// expect(value, isNotNull)              - Value is not null
// expect(value, isTrue)                 - Boolean is true
// expect(value, isFalse)                - Boolean is false
// expect(value, greaterThan(x))         - Numeric comparison
// expect(value, lessThan(x))            - Numeric comparison
// expect(value, isA<Type>())            - Type checking
// expect(() => code, throwsException)   - Exception testing
// expect(list, contains(item))          - List contains
// expect(list, hasLength(n))            - List length

// ═══════════════════════════════════════════════════════════════
// 📚 QUICK REFERENCE: Mockito Patterns
// ═══════════════════════════════════════════════════════════════
// Stubbing (setting up mock behavior):
//   when(mock.method()).thenReturn(value)
//   when(mock.method()).thenThrow(exception)
//   when(mock.method()).thenAnswer((_) async => value)
//
// Verification (checking if methods were called):
//   verify(mock.method()).called(1)
//   verifyNever(mock.method())
//   verifyInOrder([mock.method1(), mock.method2()])
//
// Difference between Mocks and Fakes:
//   - Mock: Simulates behavior, allows verification (e.g., MockCameraController)
//   - Fake: Working implementation for testing (e.g., FakeCameraImage)

// ═══════════════════════════════════════════════════════════════
// 🎯 TESTING CHECKLIST FOR YOU TO COMPLETE
// ═══════════════════════════════════════════════════════════════
// [ ] Test initialization with default config
// [ ] Test initialization with custom config
// [ ] Test camera selection logic
// [ ] Test error handling (empty camera list)
// [ ] Test state management (isInitialized, controller, etc.)
// [ ] Test good lighting detection
// [ ] Test poor lighting detection
// [ ] Test lighting with edge cases (empty/corrupted data)
// [ ] Test glare detection (positive case)
// [ ] Test glare detection (negative case)
// [ ] Test configuration updates
// [ ] Test disposal/cleanup
// [ ] Test multiple disposal calls
// [ ] Test image stream operations
// [ ] Aim for >80% code coverage

// ═══════════════════════════════════════════════════════════════
// 🚀 NEXT STEPS
// ═══════════════════════════════════════════════════════════════
// 1. Start filling in the TODO tests one by one
// 2. Run tests: flutter test test/src/services/camera_service_test.dart
// 3. Check coverage: flutter test --coverage
// 4. Iterate: Write test → Run → Debug → Repeat
//
// 💡 PRO TIPS:
// - Start with the simplest tests first (state management)
// - Use the example tests as templates
// - Read error messages carefully - they often tell you exactly what's wrong
// - Run tests frequently to catch issues early
// - Use debugPrint() in your tests when you need to debug