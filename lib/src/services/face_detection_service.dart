import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';

import '../config/app_config.dart';

/// Service for face detection and gesture recognition
class FaceDetectionService {
  /// ML Kit face detector
  late FaceDetector _faceDetector;

  /// Whether currently processing an image
  bool _isProcessingImage = false;

  /// Frame skip counter for throttling
  int _frameSkipCounter = 0;

  /// Error recovery counter
  int _errorCount = 0;

  /// Last measured eye open probability
  double? _lastEyeOpenProbability;

  /// Last measured smile probability
  double? _lastSmileProbability;

  /// Whether face is properly centered
  bool _isFaceCentered = false;

  /// Last measured head angle X (for nodding)
  double? _lastHeadEulerAngleX;

  /// History of head angle readings
  final List<double> _headAngleReadings = [];

  /// Configuration for liveness detection
  final LivenessConfig _config;

  /// Constructor with optional configuration
  FaceDetectionService({
    LivenessConfig? config,
  }) : _config = config ?? const LivenessConfig() {
    _initializeDetector();
  }

  /// Initialize the face detector with current configuration
  void _initializeDetector() {
    debugPrint("!!! >> _initializeDetector called");
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: _config.minFaceSize,
      ),
    );
  }

  CameraDescription? _currentCamera;

  /// Update configuration
  void updateConfig(LivenessConfig config) {
    if (_config.minFaceSize != config.minFaceSize) {
      // Dispose and reinitialize with new settings
      debugPrint("!!! >> updateConfig called");
      _faceDetector.close();
      _initializeDetector();
    }
  }

  void forceFaceCentered(bool centered) {
    _isFaceCentered = centered;
  }

  /// Check if face is centered in the oval guide
  bool checkFaceCenteringOLD(Face face, Size screenSize) {
    final screenCenterX = screenSize.width / 2;
    final screenCenterY = screenSize.height / 2 - screenSize.height * 0.05;

    final faceBox = face.boundingBox;

    // Apply the same coordinate correction here
    double faceCenterX;
    if (Platform.isAndroid &&
        _currentCamera?.lensDirection == CameraLensDirection.front) {
      faceCenterX = screenSize.width - (faceBox.left + faceBox.width / 2);
    } else {
      faceCenterX = faceBox.left + faceBox.width / 2;
    }

    final faceCenterY = faceBox.top + faceBox.height / 2;
    final bool isAndroid = Platform.isAndroid;
    final double faceMarginMultiplier =
        isAndroid ? 1.2 : 1.0; // More margin on Android

    final maxHorizontalOffset = screenSize.width * 0.15 * faceMarginMultiplier;
    final maxVerticalOffset = screenSize.height * 0.1;

    final ovalHeight = screenSize.height * 0.55;
    final ovalWidth = ovalHeight * 0.75;

    var minFaceWidthRatio = Platform.isAndroid ? 0.2 : 0.3;
    const maxFaceWidthRatio = 0.95;

    final faceWidthRatio = faceBox.width / ovalWidth;

    final isHorizontallyCentered = Platform.isAndroid
        ? true
        : (faceCenterX - screenCenterX).abs() < maxHorizontalOffset;
    final isVerticallyCentered =
        (faceCenterY - screenCenterY).abs() < maxVerticalOffset;

    final isRightSize = faceWidthRatio >= minFaceWidthRatio &&
        faceWidthRatio <= maxFaceWidthRatio;

    debugPrint(
        'Face centering: H=$isHorizontallyCentered, V=$isVerticallyCentered, Size=$isRightSize');
    debugPrint('Face width ratio: $faceWidthRatio');

    _isFaceCentered =
        isHorizontallyCentered && isVerticallyCentered && isRightSize;
    debugPrint(
        'Face centered check: H=$isHorizontallyCentered, V=$isVerticallyCentered, Size=$isRightSize, Final=$_isFaceCentered');

    return _isFaceCentered;
  }

  /// Check if face is centered in the oval guide
  bool checkFaceCentering(Face face, Size screenSize) {

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
    // if (_currentCamera?.lensDirection == CameraLensDirection.front) {
    //   faceCenterX = screenSizeAux.width - (faceBox.left + faceBox.width / 2);
    // }
    final faceCenterY = faceBox.top + faceBox.height / 2;

    // Platform-specific tolerances
    final bool isAndroid = Platform.isAndroid;
    final double horizontalToleranceMultiplier = isAndroid ? 1.2 : 1.0;
    final double verticalToleranceMultiplier = isAndroid ? 1.1 : 1.0;

    // Tolerance based on oval size (percentage of oval dimensions)
    final maxHorizontalOffset = ovalWidth * 0.20 * horizontalToleranceMultiplier;
    final maxVerticalOffset = ovalHeight * 0.15 * verticalToleranceMultiplier;

    // Platform-specific size ratios
    final minFaceWidthRatio = isAndroid ? 0.25 : 0.3;
    final maxFaceWidthRatio = 0.85;
    final minFaceHeightRatio = isAndroid ? 0.25 : 0.3;
    final maxFaceHeightRatio = 0.85;

    // Calculate size ratios
    final faceWidthRatio = faceBox.width / ovalWidth;
    final faceHeightRatio = faceBox.height / ovalHeight;

    // Check if face is within oval boundaries
    final ovalLeft = ovalCenterX - ovalWidth / 2;
    final ovalRight = ovalCenterX + ovalWidth / 2;
    final ovalTop = ovalCenterY - ovalHeight / 2;
    final ovalBottom = ovalCenterY + ovalHeight / 2;

    final isInsideOvalHorizontally = faceCenterX >= ovalLeft && faceCenterX <= ovalRight;
    final isInsideOvalVertically = faceCenterY >= ovalTop && faceCenterY <= ovalBottom;

    // CORREÇÃO: Verificação de centralização relativa ao centro do oval
    final horizontalDistanceFromCenter = (faceCenterX - ovalCenterX).abs();
    final verticalDistanceFromCenter = (faceCenterY - ovalCenterY).abs();

    final isHorizontallyCentered = horizontalDistanceFromCenter <= maxHorizontalOffset;
    final isVerticallyCentered = verticalDistanceFromCenter <= maxVerticalOffset;

    // Check size requirements
    final isRightWidth = faceWidthRatio >= minFaceWidthRatio && faceWidthRatio <= maxFaceWidthRatio;
    final isRightHeight = faceHeightRatio >= minFaceHeightRatio && faceHeightRatio <= maxFaceHeightRatio;
    final isRightSize = isRightWidth && isRightHeight;

    // Check face proportion
    final double faceAspectRatio = faceBox.width / faceBox.height;
    final double expectedAspectRatio = 0.75;
    final double aspectTolerance = 0.3; // Increased tolerance for more flexibility
    final hasGoodProportion = (faceAspectRatio - expectedAspectRatio).abs() <= aspectTolerance;

    // Debug information
    debugPrint('=== FACE CENTERING DEBUG ===');
    debugPrint('Oval: Center(${ovalCenterX.toStringAsFixed(1)}, ${ovalCenterY.toStringAsFixed(1)}), '
        'Size(${ovalWidth.toStringAsFixed(1)}x${ovalHeight.toStringAsFixed(1)})');
    debugPrint('Face: Center(${faceCenterX.toStringAsFixed(1)}, ${faceCenterY.toStringAsFixed(1)}), '
        'Size(${faceBox.width.toStringAsFixed(1)}x${faceBox.height.toStringAsFixed(1)})');
    debugPrint('Distance from center: H=${horizontalDistanceFromCenter.toStringAsFixed(1)}, '
        'V=${verticalDistanceFromCenter.toStringAsFixed(1)}');
    debugPrint('Max allowed distance: H=${maxHorizontalOffset.toStringAsFixed(1)}, '
        'V=${maxVerticalOffset.toStringAsFixed(1)}');
    debugPrint('Inside oval: H=$isInsideOvalHorizontally, V=$isInsideOvalVertically');
    debugPrint('Centered: H=$isHorizontallyCentered, V=$isVerticallyCentered');
    debugPrint('Size ratios: W=$faceWidthRatio, H=$faceHeightRatio');
    debugPrint('Right size: W=$isRightWidth, H=$isRightHeight');

    // Final validation
    _isFaceCentered = isInsideOvalHorizontally &&
        isInsideOvalVertically &&
        isHorizontallyCentered &&
        isVerticallyCentered &&
        isRightSize;

    debugPrint('Final result: $_isFaceCentered');
    debugPrint('===========================');

    return _isFaceCentered;
  }

  /// Process camera image to detect faces with improved error handling
  Future<List<Face>> processImage(CameraImage image, CameraDescription camera) async {
    _currentCamera = camera;

    // Skip processing if already processing or implement frame throttling
    if (_isProcessingImage) return [];

    // Frame throttling - process every Nth frame
    _frameSkipCounter++;
    if (_frameSkipCounter % _config.frameSkipInterval != 0) {
      return [];
    }

    _isProcessingImage = true;
    
    try {
      // Validate image data before processing
      if (image.planes.isEmpty || image.planes[0].bytes.isEmpty) {
        debugPrint('Invalid image data received');
        return [];
      }

      // Create InputImage with proper error handling
      final inputImage = _createInputImageRobust(image, camera);
      if (inputImage == null) {
        debugPrint('Failed to create InputImage');
        return [];
      }

      // Process the image
      final faces = await _faceDetector.processImage(inputImage);
      
      // Reset error count on successful processing
      _errorCount = 0;
      
      return faces;
    } catch (e) {
      _errorCount++;
      debugPrint('Error processing image (attempt $_errorCount): $e');
      
      // If too many consecutive errors, reset the detector
      if (_errorCount >= _config.maxConsecutiveErrors) {
        debugPrint('Too many consecutive errors, reinitializing detector');
        await _reinitializeDetector();
        _errorCount = 0;
      }
      
      return [];
    } finally {
      _isProcessingImage = false;
    }
  }

  /// Create InputImage with maximum robustness
  InputImage? _createInputImageRobust(CameraImage image, CameraDescription camera) {
    // Try multiple approaches in order of preference
    
    // Approach 1: Standard method with format detection
    try {
      return _createInputImageStandard(image, camera);
    } catch (e) {
      debugPrint('Standard InputImage creation failed: $e');
    }

    // Approach 2: Force nv21 (Android) / bgra8888 (iOS) format (most common)
    try {
      return _createInputImageForced(image, camera);
    } catch (e) {
      debugPrint('Forced nv21 (Android) / bgra8888 (iOS) InputImage creation failed: $e');
    }

    // Approach 3: Minimal metadata approach
    try {
      return _createInputImageMinimal(image, camera);
    } catch (e) {
      debugPrint('Minimal InputImage creation failed: $e');
    }

    return null;
  }

  /// Standard InputImage creation with format detection
  InputImage? _createInputImageStandard(CameraImage image, CameraDescription camera) {

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _getInputImageRotation(camera),
        format: _getSafeInputImageFormat(image.format),
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  /// Forced nv21 format for Android and bgra8888 for iOS InputImage creation
  InputImage? _createInputImageForced(CameraImage image, CameraDescription camera) {

    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);

    // WARNING: According to google_ml_kit_flutter, It only supports nv21 format for Android and bgra8888 for iOS
    debugPrint("_createInputImageForced called. Format [${inputImageFormat!.name}], It will be forced to ${Platform.isAndroid ? InputImageFormat.nv21.name : InputImageFormat.bgra8888.name}");

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: _getInputImageRotation(camera),
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Minimal InputImage creation with fixed values
  InputImage? _createInputImageMinimal(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg, // Fixed rotation
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888, // Fixed format
        bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : image.width,
      ),
    );
  }

  /// Get safe InputImageFormat (only use formats that definitely exist)
  InputImageFormat _getSafeInputImageFormat(ImageFormat format) {
    // Only use formats we know exist in all versions
    switch (format.group) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.jpeg:
      case ImageFormatGroup.unknown:
      default:
        // For any unsupported or unknown format, default to nv21 for android and bgra8888 for iOS
        if(Platform.isAndroid) {
          debugPrint('Using nv21 (Android) fallback for format: ${format.group}');
          return InputImageFormat.nv21;
        } else {
          debugPrint('Using bgra8888 (iOS) fallback for format: ${format.group}');
          return InputImageFormat.bgra8888;
        }
    }
  }

  /// Get InputImageRotation based on camera sensor orientation
  InputImageRotation _getInputImageRotation(CameraDescription camera) {
    try {
      final sensorOrientation = camera.sensorOrientation;
      switch (sensorOrientation) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          debugPrint('Unknown sensor orientation: $sensorOrientation, using 0 degrees');
          return InputImageRotation.rotation0deg;
      }
    } catch (e) {
      debugPrint('Error getting rotation: $e');
      return InputImageRotation.rotation0deg;
    }
  }

  /// Reinitialize the face detector
  Future<void> _reinitializeDetector() async {
    try {
      debugPrint("!!! >> _reinitializeDetector called");
      await _faceDetector.close();
      await Future.delayed(const Duration(milliseconds: 100));
      _initializeDetector();
      debugPrint('Face detector reinitialized successfully');
    } catch (e) {
      debugPrint('Error reinitializing detector: $e');
    }
  }

  Offset transformFacePosition(Offset facePosition, Size imageSize) {
    if (_currentCamera == null) return facePosition;

    final bool isFrontCamera = _currentCamera!.lensDirection == CameraLensDirection.front;
    final int rotation = _currentCamera!.sensorOrientation;

    double x = facePosition.dx;
    double y = facePosition.dy;

    // Apply transformations based on camera type and orientation
    if (Platform.isAndroid) {
      if (isFrontCamera) {
        // Front camera on Android might need horizontal flipping
        x = imageSize.width - x;

        // Adjust based on rotation
        if (rotation == 90 || rotation == 270) {
          // Swap coordinates for 90/270 degree rotations
          final temp = x;
          x = y;
          y = temp;
        }
      }
    }

    return Offset(x, y);
  }

  /// Detect if a challenge has been completed
  bool detectChallengeCompletion(Face face, ChallengeType challengeType) {
    switch (challengeType) {
      case ChallengeType.blink:
        return _detectBlink(face);
      case ChallengeType.turnLeft:
        return _detectLeftTurn(face);
      case ChallengeType.turnRight:
        return _detectRightTurn(face);
      case ChallengeType.smile:
        return _detectSmile(face);
      case ChallengeType.nod:
        return _detectNod(face);
    }
  }

  /// Detect left head turn
  bool _detectLeftTurn(Face face) {
    if (face.headEulerAngleY != null) {
      _storeHeadAngle(face.headEulerAngleY!);
      return face.headEulerAngleY! > _config.headTurnThreshold;
    }
    return false;
  }

  /// Detect right head turn
  bool _detectLeftTurn(Face face) {
    if (face.headEulerAngleY != null) {
      _storeHeadAngle(face.headEulerAngleY!);
      return face.headEulerAngleY! < -_config.headTurnThreshold;
    }
    return false;
  }

  /// Detect eye blink
  bool _detectBlink(Face face) {
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      final double avgEyeOpenProbability =
          (face.leftEyeOpenProbability! + face.rightEyeOpenProbability!) / 2;

      if (_lastEyeOpenProbability != null) {
        if (_lastEyeOpenProbability! > _config.eyeBlinkThresholdOpen &&
            avgEyeOpenProbability < _config.eyeBlinkThresholdClosed) {
          _lastEyeOpenProbability = avgEyeOpenProbability;
          return true;
        }
      }

      _lastEyeOpenProbability = avgEyeOpenProbability;
    }
    return false;
  }

  /// Detect smile
  bool _detectSmile(Face face) {
    if (face.smilingProbability != null) {
      final smileProbability = face.smilingProbability!;

      if (_lastSmileProbability != null) {
        if (_lastSmileProbability! < _config.smileThresholdNeutral &&
            smileProbability > _config.smileThresholdSmiling) {
          _lastSmileProbability = smileProbability;
          return true;
        }
      }

      _lastSmileProbability = smileProbability;
    }
    return false;
  }

  /// Detect head nod
  bool _detectNod(Face face) {
    if (face.headEulerAngleX != null) {
      final headAngleX = face.headEulerAngleX!;
      debugPrint('Nod angle: $headAngleX');

      if (_lastHeadEulerAngleX != null) {
        if ((_lastHeadEulerAngleX! < -10 && headAngleX > 10) ||
            (_lastHeadEulerAngleX! > 10 && headAngleX < -10)) {
          _lastHeadEulerAngleX = headAngleX;
          return true;
        }
      }

      _lastHeadEulerAngleX = headAngleX;
    }
    return false;
  }

  /// Store head angle reading
  void _storeHeadAngle(double angle) {
    _headAngleReadings.add(angle);
    if (_headAngleReadings.length > _config.maxHeadAngleReadings) {
      _headAngleReadings.removeAt(0);
    }
  }

  /// Get head angle readings
  List<double> get headAngleReadings => _headAngleReadings;

  /// Whether face is properly centered
  bool get isFaceCentered => _isFaceCentered;

  /// Reset all tracking data
  void resetTracking() {
    _lastEyeOpenProbability = null;
    _lastSmileProbability = null;
    _lastHeadEulerAngleX = null;
    _headAngleReadings.clear();
    _isFaceCentered = false;
    _errorCount = 0;
    _frameSkipCounter = 0;
  }

  /// Clean up resources
  void dispose() {
    debugPrint("!!! >> dispose called");
    _faceDetector.close();
  }
}