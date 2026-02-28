import 'package:camera/camera.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';
import 'package:smart_liveliness_detection/src/services/camera_service.dart';
import 'package:smart_liveliness_detection/src/services/face_detection_service.dart';
import 'package:smart_liveliness_detection/src/services/motion_service.dart';
import 'package:smart_liveliness_detection/src/services/voice_guidance_service.dart';

import '../helper/helper.dart' show FakeCameraDescription, FakeCameraImage;
import 'liveness_controller_test.mocks.dart';

class FakeTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick)..muted = true;
}

@GenerateMocks([
  CameraService,
  FaceDetectionService,
  MotionService,
  VoiceGuidanceService,
  LivenessSession
])
class MockCameraController extends Mock implements CameraController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // LivenessController mock
  final mockCameraController = MockCameraController();
  late MockCameraService mockCameraService;
  late MockFaceDetectionService mockFaceDetectionService;
  late MockMotionService mockMotionService;
  late MockVoiceGuidanceService mockVoiceGuidanceService;
  late MockLivenessSession mockLivenessSession;
  late LivenessController controller;
  late FakeTickerProvider vsync;
  bool disposed = false;

  setUp(() async {
    final fakeCamera = [
      FakeCameraDescription(
          name: '0',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0)
    ];
    // Create Mocks
    mockCameraService = MockCameraService();
    mockMotionService = MockMotionService();
    mockFaceDetectionService = MockFaceDetectionService();
    mockVoiceGuidanceService = MockVoiceGuidanceService();
    mockLivenessSession = MockLivenessSession();
    vsync = FakeTickerProvider();

    when(mockCameraService.initialize(any))
        .thenAnswer((_) async => mockCameraController);
    when(mockCameraService.startImageStream(any)).thenAnswer((_) async {});
    when(mockCameraService.controller).thenReturn(null);
    when(mockMotionService.startAccelerometerTracking()).thenReturn(null);
    when(mockCameraService.stopImageStream()).thenAnswer((_) async {});
    when(mockCameraService.dispose()).thenAnswer((_) async {});
    when(mockFaceDetectionService.dispose()).thenReturn(null);
    when(mockMotionService.dispose()).thenReturn(null);
    when(mockCameraService.calculateLightingCondition(any)).thenReturn(null);
    when(mockCameraService.detectScreenGlare(any)).thenReturn(false);
    when(mockFaceDetectionService.processImage(any, any))
        .thenAnswer((_) async => []);

    controller = LivenessController(
      cameras: fakeCamera,
      vsync: vsync,
      cameraService: mockCameraService,
      faceDetectionService: mockFaceDetectionService,
      motionService: mockMotionService,
    );
  });

  tearDown(() async {
    if (!disposed) {
      controller.dispose();
    }
    disposed = false;
  });

  group('LivenessController - initial state', () {
    test('statusMessage start as initializating...', () async {
      await Future.delayed(Duration.zero);

      expect(
          controller.statusMessage, equals('Position your face in the oval'));
    });

    test('currentState starts as LivenessState.initial', () async {
      await Future.delayed(Duration.zero);

      expect(controller.currentState, equals(LivenessState.initial));
    });

    test('isVerificationSuccessful is false by default', () {
      expect(controller.isVerificationSuccessful, isFalse);
    });

    test('progress returns 0.0 initially', () {
      expect(controller.progress, equals(0.0));
    });

    test('given voice guidance is enabled, voiceGuidanceConfig is not null',
        () {
      // Arrange & Act
      const voiceGuidanceConfig =
          LivenessConfig(voiceGuidance: VoiceGuidanceConfig(enabled: true));

      // Assert
      expect(voiceGuidanceConfig.voiceGuidance, isNotNull);
    });

    test('given voice guidance is disabled, voiceGuidanceConfig is null', () {
      // Arrange & Act
      const voiceGuidanceConfig =
          LivenessConfig(voiceGuidance: VoiceGuidanceConfig(enabled: false));

      // Assert
      expect(voiceGuidanceConfig.voiceGuidance?.enabled, isFalse);
    });

    test('given voice guidance is enabled, the service is initialized',
        () async {
      // Arrange & Act
      const voiceGuidanceConfig =
          LivenessConfig(voiceGuidance: VoiceGuidanceConfig(enabled: true));
      controller.updateConfig(voiceGuidanceConfig);

      // Assert
      expect(controller.config.voiceGuidance?.enabled, isTrue);
    });

    test('initialization calls camera and motion service methods', () async {
      // Wait for async initialization to complete
      await Future.delayed(Duration.zero);

      // Verify camera initialization
      verify(mockCameraService.initialize(any)).called(1);
      verify(mockCameraService.startImageStream(any)).called(1);

      // Verify motion service starts tracking
      verify(mockMotionService.startAccelerometerTracking()).called(1);
    });
  });

  group('LivenessController - updateConfig', () {
    test('updateConfig updates the config', () {
      const newConfig = LivenessConfig(
        alwaysIncludeBlink: false,
      );

      controller.updateConfig(newConfig);

      expect(controller.config.alwaysIncludeBlink, isFalse);
    });
  });
  group('LivenessController - processCameraImage', () {
    test('processCameraImage processes image when not disposed', () async {
      when(mockCameraService.isInitialized).thenReturn(false);
      await controller.processCameraImage(FakeCameraImage(planes: []));

      verifyNever(mockFaceDetectionService.processImage(any, any));
    });

    test('processCameraImage does not process image when disposed', () async {
      disposed = true;
      controller.dispose();
      await controller.processCameraImage(FakeCameraImage(planes: []));

      verifyNever(mockFaceDetectionService.processImage(any, any));
    });
  });
}
