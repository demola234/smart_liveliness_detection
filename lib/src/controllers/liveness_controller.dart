import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';
import 'package:smart_liveliness_detection/src/services/camera_service.dart';
import 'package:smart_liveliness_detection/src/services/capture_service.dart';
import 'package:smart_liveliness_detection/src/services/face_detection_service.dart';
import 'package:smart_liveliness_detection/src/services/motion_service.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';
import 'package:smart_liveliness_detection/src/controllers/zoom_challenge_controller.dart';


/// Controller for liveness detection session
class LivenessController extends ChangeNotifier {
  /// Camera service
  final CameraService _cameraService;

  /// Face detection service
  final FaceDetectionService _faceDetectionService;

  /// Motion service
  final MotionService _motionService;

  /// Single capture service
  CaptureService? _singleCaptureService;

  /// Available cameras
  final List<CameraDescription> _cameras;

  /// Configuration
  LivenessConfig _config;

  /// Theme
  LivenessTheme _theme;

  /// Liveness session
  LivenessSession _session;

  /// Message for face centering guidance
  String _faceCenteringMessage = '';

  /// Whether a face is currently detected
  bool _isFaceDetected = false;

  /// Whether currently processing an image
  bool _isProcessing = false;

  /// Current status message
  String _statusMessage = 'Initializing...';

  /// Callback for when a challenge is completed
  final ChallengeCompletedCallback? _onChallengeCompleted;

  /// Callback for when liveness verification is completed
  final LivenessCompletedCallback? _onLivenessCompleted;

  /// Callback for when face is detected
  final FaceDetectedCallback? _onFaceDetected;

  /// Callback for when face is NOT detected (It will trigger the first face non-detection event after any face detection)
  final FaceNotDetectedCallback? _onFaceNotDetected;

  /// Callback for when final image is captured
  final Function(String sessionId, XFile imageFile, Map<String, dynamic> metadata)? _onFinalImageCaptured;

  /// Whether verification was successful (after completion)
  bool _isVerificationSuccessful = false;

  late final ZoomChallengeController _zoomChallengeController;

  /// Whether to capture image at end of verification
  final bool _captureFinalImage;

  /// Constructor
  LivenessController({
    required List<CameraDescription> cameras,
    required TickerProvider vsync,
    LivenessConfig? config,
    LivenessTheme? theme,
    CameraService? cameraService,
    FaceDetectionService? faceDetectionService,
    MotionService? motionService,
    List<ChallengeType>? challengeTypes,
    ChallengeCompletedCallback? onChallengeCompleted,
    LivenessCompletedCallback? onLivenessCompleted,
    FaceDetectedCallback? onFaceDetected,
    FaceNotDetectedCallback? onFaceNotDetected,
    Function(String sessionId, XFile imageFile, Map<String, dynamic> metadata)? onFinalImageCaptured,
    bool captureFinalImage = true,
  })  : _cameras = cameras,
        _config = config ?? const LivenessConfig(),
        _theme = theme ?? const LivenessTheme(),
        _cameraService = cameraService ?? CameraService(config: config),
        _faceDetectionService =faceDetectionService ?? FaceDetectionService(config: config),
        _motionService = motionService ?? MotionService(config: config),
        _onChallengeCompleted = onChallengeCompleted,
        _onLivenessCompleted = onLivenessCompleted,
        _onFaceDetected = onFaceDetected,
        _onFaceNotDetected = onFaceNotDetected,
        _onFinalImageCaptured = onFinalImageCaptured,
        _captureFinalImage = captureFinalImage,
        _session = LivenessSession(
          challenges: LivenessSession.generateRandomChallenges(config ?? const LivenessConfig()),
        ) {
    _zoomChallengeController = ZoomChallengeController(vsync: vsync);
    _initialize();
  }

  /// Initialize the controller and services
  Future<void> _initialize() async {
    try {
      _statusMessage = 'Initializing camera...';
      notifyListeners();

      _currentZoomFactor = 0.0;
      _zoomChallengeController.reset();

      // Initialize camera service
      await _cameraService.initialize(_cameras);

      // Start motion tracking
      _motionService.startAccelerometerTracking();

      // Start image stream with error handling
      await _cameraService.startImageStream(_processCameraImage);

      // Initialize single capture service if enabled
      if (_captureFinalImage && _cameraService.controller != null) {
        _singleCaptureService = CaptureService(
          cameraController: _cameraService.controller,
        );
      }

      _statusMessage = 'Ready - Position your face in the oval';
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing liveness controller: $e');
      _statusMessage = 'Error initializing camera. Please restart the app.';
      notifyListeners();
    }
  }

  /// Process images from the camera stream
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || !_cameraService.isInitialized) return;

    _isProcessing = true;

    try {
      // Check session expiry
      if (_session.isExpired(_config.maxSessionDuration)) {
        _session = _session.reset(_config);
        _faceDetectionService.resetTracking();
        _motionService.resetTracking();
        notifyListeners();
        return;
      }

      // Calculate lighting with error handling
      try {
        _cameraService.calculateLightingCondition(image);
      } catch (e) {
        debugPrint('Error calculating lighting: $e');
      }

      // Detect screen glare with error handling
      bool hasScreenGlare = false;
      try {
        hasScreenGlare = _cameraService.detectScreenGlare(image);
        if (hasScreenGlare) {
          debugPrint(
              'Detected potential screen glare, possible spoofing attempt');
        }
      } catch (e) {
        debugPrint('Error detecting screen glare: $e');
      }

      // Get the front camera
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      // Process faces with error handling
      List<Face>? faces = [];
      try {
        faces = await _faceDetectionService.processImage(image, camera);
      } catch (e) {
        debugPrint('Error in face detection: $e');
        // Continue with empty face list
      }

      if(faces != null) {
        if (faces.isNotEmpty) {
          final face = faces.first;
          _isFaceDetected = true;

          //region ## 1. Calculate the screen size from the camera image
          // (exactly like you do in _updateFaceCenteringGuidance)
          final screenSize = Size(
            image.width.toDouble(),
            image.height.toDouble(),
          );

          Size screenSizeAux = Size(screenSize.width > screenSize.height ? screenSize.height : screenSize.width, screenSize.width > screenSize.height ? screenSize.width : screenSize.height);
          //endregion

          //region ## 2. Calculate the rectangle of the oval
          final ovalCenterY = screenSizeAux.height / 2 - screenSizeAux.height * 0.05;
          final ovalHeight = screenSizeAux.height * 0.55;
          final ovalWidth = ovalHeight * 0.75;
          final ovalRect = Rect.fromCenter(
            center: Offset(screenSizeAux.width / 2, ovalCenterY),
            width: ovalWidth,
            height: ovalHeight,
          );
          //endregion

          bool isCentered = false;

          try {
            isCentered = _faceDetectionService.checkFaceCentering(face, screenSize);
            _updateFaceCenteringGuidance(face, screenSize);
          } catch (e) {
            debugPrint('Error checking face centering: $e');
            _faceCenteringMessage = 'Error checking face position';
          }

          //region ## 3. Pass the calculated ovalRect to the processing method
          if (_session.state == LivenessState.centeringFace && isCentered) {
            _processLivenessDetection(face, ovalRect);
          } else if (_session.state != LivenessState.centeringFace) {
            _processLivenessDetection(face, ovalRect);
          }
          //endregion

          // Notify via callback
          _onFaceDetected?.call(_session.currentChallenge!.type, image, faces, camera);
        } else {
          // WARNING: It will be called only after onFaceDetected is called! It will trigger the first face non-detection event after any face detection
          if(_isFaceDetected) {
            // Notify via callback
            _onFaceNotDetected?.call(_session.currentChallenge!.type, this);
          }

          _isFaceDetected = false;
          _faceCenteringMessage = 'No face detected';
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error in _processCameraImage: $e');
      _statusMessage = 'Processing error occurred';
      notifyListeners();
    } finally {
      _isProcessing = false;
    }
  }

  /// Update face centering guidance message
  void _updateFaceCenteringGuidance(Face face, Size screenSize) {

    // Adjust screenSize because the camera may have rotated the image
    Size screenSizeAux = Size(screenSize.width > screenSize.height ? screenSize.height : screenSize.width, screenSize.width > screenSize.height ? screenSize.width : screenSize.height);

    // Oval center (adjusted 5% upwards from screen center)
    final ovalCenterX = screenSizeAux.width / 2;
    final ovalCenterY = screenSizeAux.height / 2 - screenSizeAux.height * 0.05;

    // Oval dimensions
    final ovalHeight = screenSizeAux.height * 0.55;
    final ovalWidth = ovalHeight * 0.75;

    final faceBox = face.boundingBox;

    // Apply coordinate correction for front camera
    double faceCenterX = faceBox.left + faceBox.width / 2;
    // WARNING: This is really needed?
    // This is where the problem is - we need to flip the X coordinate on Android with front camera
    // if (_currentCamera?.lensDirection == CameraLensDirection.front) {
    //   // Flip the X coordinate for Android front camera
    //   faceCenterX = screenSizeAux.width - (faceBox.left + faceBox.width / 2);
    // }
    final faceCenterY = faceBox.top + faceBox.height / 2;

    // Debug prints to verify coordinates
    debugPrint('Face center: ($faceCenterX, $faceCenterY)');
    debugPrint('Screen center: ($ovalCenterX, $ovalCenterY)');

    // Platform-specific tolerances
    final bool isAndroid = Platform.isAndroid;
    final double horizontalToleranceMultiplier = isAndroid ? 1.2 : 1.0;
    final double verticalToleranceMultiplier = isAndroid ? 1.1 : 1.0;

    // Tolerance based on oval size (percentage of oval dimensions)
    // final maxHorizontalOffset = ovalWidth * 0.20 * horizontalToleranceMultiplier;
    // final maxVerticalOffset = ovalHeight * 0.15 * verticalToleranceMultiplier;

    // Platform-specific size ratios
    // final minFaceWidthRatio = isAndroid ? 0.25 : 0.3;
    // final maxFaceWidthRatio = 0.85;
    // final minFaceHeightRatio = isAndroid ? 0.25 : 0.3;
    // final maxFaceHeightRatio = 0.85;

    // Calculate size ratios
    final faceWidthRatio = faceBox.width / ovalWidth;
    final faceHeightRatio = faceBox.height / ovalHeight;

    // Check if face is within oval boundaries
    // final ovalLeft = ovalCenterX - ovalWidth / 2;
    // final ovalRight = ovalCenterX + ovalWidth / 2;
    // final ovalTop = ovalCenterY - ovalHeight / 2;
    // final ovalBottom = ovalCenterY + ovalHeight / 2;

    // final isInsideOvalHorizontally = faceCenterX >= ovalLeft && faceCenterX <= ovalRight;
    // final isInsideOvalVertically = faceCenterY >= ovalTop && faceCenterY <= ovalBottom;

    // final horizontalDistanceFromCenter = (faceCenterX - ovalCenterX).abs();
    // final verticalDistanceFromCenter = (faceCenterY - ovalCenterY).abs();

    // final isHorizontallyCentered = horizontalDistanceFromCenter <= maxHorizontalOffset;
    // final isVerticallyCentered = verticalDistanceFromCenter <= maxVerticalOffset;

    final isHorizontallyOff = (faceCenterX - ovalCenterX).abs() > screenSize.width * 0.1;
    final isVerticallyOff = (faceCenterY - ovalCenterY).abs() > screenSize.height * 0.1;

    final isTooBig = faceWidthRatio > 1.5;
    final isTooSmall = faceWidthRatio < 0.5;

    // Direction logic using the corrected coordinates
    if (isTooBig) {
      _faceCenteringMessage = 'Move farther away';
    } else if (isTooSmall) {
      _faceCenteringMessage = 'Move closer';
    } else if (isHorizontallyOff) {
      if (faceCenterX > ovalCenterX) {
        _faceCenteringMessage = 'Move right';
      } else {
        _faceCenteringMessage = 'Move left';
      }
    } else if (isVerticallyOff) {
      if (faceCenterY < ovalCenterY) {
        _faceCenteringMessage = 'Move down';
      } else {
        _faceCenteringMessage = 'Move up';
      }
    } else {
      _faceCenteringMessage = 'Perfect! Hold still';
    }

    if (!isTooBig && !isTooSmall && !isHorizontallyOff && !isVerticallyOff) {
      _faceCenteringMessage = 'Perfect! Hold still';
      // Force the face detection service to consider the face centered
      _faceDetectionService.forceFaceCentered(true);
    }
  }

  /// Process liveness detection for the current state
  void _processLivenessDetection(Face face, Rect ovalRect) {
    if (!_cameraService.isLightingGood) {
      _statusMessage = 'Please move to a better lit area';
      return;
    }

    switch (_session.state) {
      case LivenessState.initial:
        _session.state = LivenessState.centeringFace;
        _statusMessage = 'Position your face within the oval';
        break;

      case LivenessState.centeringFace:
        if (_faceDetectionService.isFaceCentered) {
          _session.state = LivenessState.performingChallenges;
          _updateStatusMessage();
          notifyListeners();

          // Schedule the ACTUAL start of the challenge animation for the next event cycle.
          // This gives the UI time to render the initial state of the challenge.
          Future.delayed(Duration.zero, () {
            if (_session.currentChallenge?.type == ChallengeType.zoom &&
                _zoomChallengeController.state == ZoomChallengeState.initial) {
              _zoomChallengeController.startChallenge();
            }
          });

          // WARNING: Do not continue to the 'performingChallenges' case in this same cycle.
          // Challenge validation will begin on the next camera frame.
          return;
        } else {
          _statusMessage = _faceCenteringMessage;
        }
        break;

      case LivenessState.performingChallenges:
        if (_session.currentChallengeIndex >= _session.challenges.length) {
          _completeSession();
          break;
        }

        final currentChallenge = _session.currentChallenge!;

        if (currentChallenge.type == ChallengeType.zoom && _zoomChallengeController.state == ZoomChallengeState.initial) {
          _zoomChallengeController.startChallenge();
        }

        bool challengePassed = _faceDetectionService.detectChallengeCompletion(
          face,
          currentChallenge.type,
          // Parameters relevant only to the zoom challenge
          ovalRect: ovalRect,
          zoomFactor: _zoomChallengeController.zoomFactor,
        );

        // If the challenge is zoom, add a check to ensure the animation has finished.
        if (currentChallenge.type == ChallengeType.zoom) {
          // The zoom animation is "complete" when the zoomFactor is 1.0.
          // We use a small tolerance to avoid precision issues with doubles.
          challengePassed = challengePassed && (_zoomChallengeController.zoomFactor > 0.99);
        }

        if (challengePassed) {
          currentChallenge.isCompleted = true;

          // If the challenge that ended was a zoom, reset the animation controller.
          if (currentChallenge.type == ChallengeType.zoom) {
            _currentZoomFactor = _zoomChallengeController.zoomFactor;
            _zoomChallengeController.reset();
          }

          _session.currentChallengeIndex++;

          // Notify via callback
          _onChallengeCompleted?.call(currentChallenge.type);

          _updateStatusMessage();

          notifyListeners();

          //region ## Check next challenge -> Zoom challenge
          // After passing a challenge, check if the NEXT one is zoom, to start it.
          final nextChallenge = _session.currentChallenge;
          if (nextChallenge?.type == ChallengeType.zoom &&
              _zoomChallengeController.state == ZoomChallengeState.initial) {

            // A small delay so that the user notices the transition of challenges.
            Future.delayed(const Duration(milliseconds: 500), () {
              // Check again as the state may have changed.
              if (_zoomChallengeController.state == ZoomChallengeState.initial) {
                _zoomChallengeController.startChallenge();
              }
            });
          }
          //endregion
        }
        break;

      case LivenessState.completed:
        break;
    }
  }

  /// Complete the liveness session
  void _completeSession() async {
    _session.state = LivenessState.completed;

    bool motionValid = _motionService
        .verifyMotionCorrelation(_faceDetectionService.headAngleReadings);

    _isVerificationSuccessful = motionValid;

    if (!motionValid) {
      debugPrint('Potential spoofing detected: Face moved but device didn\'t');
    }

    _statusMessage = 'Liveness verification complete!';

    // Capture final image if enabled and verification was successful
    if (_captureFinalImage &&
        _isVerificationSuccessful &&
        _singleCaptureService != null) {
      try {
        final XFile? finalImage = await _singleCaptureService!.captureImage();

        if (finalImage != null && _onFinalImageCaptured != null) {
          // Create metadata for the captured image
          final Map<String, dynamic> metadata = {
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'verificationResult': _isVerificationSuccessful,
            'challenges': _session.challenges.map((c) => c.type.toString()).toList(),
            'sessionDuration': DateTime.now().difference(_session.startTime).inMilliseconds,
            'lightingValue': _cameraService.lightingValue,
          };

          // Call the callback with the image and metadata
          _onFinalImageCaptured!(_session.sessionId, finalImage, metadata);
        }
      } catch (e) {
        debugPrint('Error capturing final image: $e');
      }
    }

    // Notify via callback
    _onLivenessCompleted?.call(_session.sessionId, _isVerificationSuccessful, {});
  }

  /// Update the current status message
  void _updateStatusMessage() {
    if (_session.currentChallenge != null) {
      _statusMessage = _session.currentChallenge!.instruction;
    } else {
      _statusMessage = 'Processing verification...';
    }
  }

  /// Reset the session
  void resetSession() {
    _session = _session.reset(_config);
    _faceDetectionService.resetTracking();
    _motionService.resetTracking();
    _statusMessage = 'Initializing...';
    _isVerificationSuccessful = false;
    notifyListeners();
  }

  /// Update configuration
  void updateConfig(LivenessConfig config) {
    _config = config;
    _cameraService.updateConfig(config);
    _faceDetectionService.updateConfig(config);
    _motionService.updateConfig(config);
    notifyListeners();
  }

  /// Update theme
  void updateTheme(LivenessTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  /// Whether camera is initialized
  bool get isInitialized => _cameraService.isInitialized;

  /// Whether a face is currently detected
  bool get isFaceDetected => _isFaceDetected;

  /// Whether lighting conditions are good
  bool get isLightingGood => _cameraService.isLightingGood;

  /// Current status message
  String get statusMessage => _statusMessage;

  /// Current state of liveness detection
  LivenessState get currentState => _session.state;

  /// Progress as percentage (0.0-1.0)
  double get progress => _session.getProgressPercentage();

  /// Session ID
  String get sessionId => _session.sessionId;

  /// Camera controller
  CameraController? get cameraController => _cameraService.controller;

  /// Face centering message
  String get faceCenteringMessage => _faceCenteringMessage;

  /// Current liveness session
  LivenessSession get session => _session;

  /// Current configuration
  LivenessConfig get config => _config;

  /// Current theme
  LivenessTheme get theme => _theme;

  /// Whether verification was successful
  bool get isVerificationSuccessful => _isVerificationSuccessful;

  /// Current lighting value (0.0-1.0)
  double get lightingValue => _cameraService.lightingValue;

  double _currentZoomFactor = 0.0;

  /// Factor for oval zoom animation (0.0 to 1.0)
  double get zoomFactor {
    final currentChallenge = _session.currentChallenge;
    // IF the current challenge is zoom and is in progress,
    // use the real-time animation value.
    if (currentChallenge?.type == ChallengeType.zoom &&
        _zoomChallengeController.state == ZoomChallengeState.inProgress) {
      return _zoomChallengeController.zoomFactor;
    }
    // ELSE, return the last value we saved.
    return _currentZoomFactor;
  }

  ZoomChallengeState get zoomState => _zoomChallengeController.state;

  /// Capture current image as a file
  Future<XFile?> captureImage() async {
    if (_singleCaptureService != null) {
      return _singleCaptureService!.captureImage();
    } else if (_cameraService.isInitialized &&
        _cameraService.controller != null) {
      try {
        final XFile file = await _cameraService.controller!.takePicture();
        return file;
      } catch (e) {
        debugPrint('Error capturing image: $e');
        return null;
      }
    }
    return null;
  }

  /// Clean up resources
  @override
  void dispose() async {
    _isProcessing = false;

    try {
      await _cameraService.stopImageStream();
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }

    try {
      _singleCaptureService?.dispose();
      _cameraService.dispose();
      _faceDetectionService.dispose();
      _motionService.dispose();
    } catch (e) {
      debugPrint('Error during disposal: $e');
    }

    super.dispose();
  }
}
