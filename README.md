# Face Liveness Detection

A highly customizable Flutter package for face liveness detection with multiple challenge types. This package helps you verify that a real person is present in front of the camera, not a photo, video, or mask.

## Features

- 💯 Multiple liveness challenge types (blinking, smiling, head turns, nodding, zoom, center the face, tilt up, tilt down)
- 🔄 Random challenge sequence generation for enhanced security
- 🎯 Face centering guidance with visual feedback
- 🔍 Anti-spoofing measures (screen glare detection, motion correlation)
- 🎨 Fully customizable UI with theming support
- 🌈 Animated progress indicators, status displays, and overlays
- 📱 Simple integration with Flutter apps
- 📸 Optional image capture capability


## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_liveliness_detection: ^0.2.1
```

Then run:

```
flutter pub get
```

Make sure to add camera permissions to your app:

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face liveness verification</string>
```

### Android

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

## Quick Start

Here's how to quickly integrate face liveness detection into your app:

```dart
import 'package:camera/camera.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/developer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get available cameras
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Liveness Detection')),
        body: LivenessDetectionScreen(
          cameras: cameras,
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness verification completed: $isSuccessful');
            log('Session ID: $sessionId');
            if (metadata != null) {
              log('Anti-spoofing check results: ${metadata['antiSpoofingDetection']}');
            }
          },
        ),
      ),
    );
  }
}
```

## Customization

### Configuration

Customize the detection settings using `LivenessConfig`:

```dart
LivenessConfig config = LivenessConfig(
  // Challenge configuration
  challengeTypes: [ChallengeType.blink, ChallengeType.smile, ChallengeType.turnRight],
  numberOfRandomChallenges: 3,
  alwaysIncludeBlink: true,

  // Custom instructions
  challengeInstructions: {
    ChallengeType.blink: 'Please blink your eyes now',
    ChallengeType.smile: 'Show us your best smile',
  },

  // Detection thresholds
  eyeBlinkThresholdOpen: 0.7,
  eyeBlinkThresholdClosed: 0.3,
  smileThresholdNeutral: 0.3,
  smileThresholdSmiling: 0.7,
  headTurnThreshold: 20.0,

  // UI configuration
  ovalHeightRatio: 0.9,
  ovalWidthRatio: 0.9,
  strokeWidth: 4.0,

  // Session settings
  maxSessionDuration: Duration(minutes: 2),
);
```

#### Plugin messages customization (Portuguese example)

```dart
LivenessDetectionScreen(
  config: LivenessConfig(
    // ... other settings
    messages: const LivenessMessages(
      // Face Centering Messages
      moveFartherAway: 'Afaste-se um pouco',
      moveCloser: 'Aproxime-se',
      moveLeft: 'Mova para a esquerda',
      moveRight: 'Mova para a direita',
      moveUp: 'Mova para cima',
      moveDown: 'Mova para baixo',
      perfectHoldStill: 'Perfeito! Fique parado',
      noFaceDetected: 'Nenhum rosto detectado',

      // Process Status Messages
      initializing: 'Inicializando...',
      initialInstruction: 'Posicione seu rosto no oval',
      poorLighting: 'Por favor, vá para uma área mais iluminada',
      processingVerification: 'Processando verificação...',
      verificationComplete: 'Verificação concluída!',
      errorInitializingCamera: 'Erro ao iniciar a câmera. Por favor, reinicie.',
      spoofingDetected: 'Possível fraude detectada',
    ),
  ),
  onLivenessCompleted: (sessionId, isSuccessful, data) {
    // ...
  },
)

```

### Theming

Customize the appearance using `LivenessTheme`:

```dart
LivenessTheme theme = LivenessTheme(
  // Colors
  primaryColor: Colors.blue,
  successColor: Colors.green,
  errorColor: Colors.red,
  warningColor: Colors.orange,
  ovalGuideColor: Colors.purple,

  // Text styles
  instructionTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  guidanceTextStyle: TextStyle(
    color: Colors.blue,
    fontSize: 16,
  ),

  // Progress indicator
  progressIndicatorColor: Colors.blue,
  progressIndicatorHeight: 12,

  // Animation
  useOvalPulseAnimation: true,
);
```

Or use a theme based on Material Design:

```dart
LivenessTheme theme = LivenessTheme.fromMaterialColor(
  Colors.teal,
  brightness: Brightness.dark,
);
```

### Callbacks

Get notified about challenges and session completion:

```dart
LivenessDetectionScreen(
  cameras: cameras,
  config: config,
  theme: theme,
  onChallengeCompleted: (challengeType) {
    log('Challenge completed: $challengeType');
  },
  onLivenessCompleted: (sessionId, isSuccessful, metadata) {
    log('Liveness verification completed:');
    log('Session ID: $sessionId');
    log('Overall Success: $isSuccessful');

    if (metadata != null && metadata.containsKey('antiSpoofingDetection')) {
      final antiSpoofingResult = metadata['antiSpoofingDetection'];
      final didPassMotionCheck = !antiSpoofingResult['motionCorrelationCheckFailed'];
      final didPassGlareCheck = !antiSpoofingResult['screenGlareDetected'];
      final didPassContourCheck = !antiSpoofingResult['lackOfFacialContoursDetected'];

      log('Motion Check Passed: $didPassMotionCheck');
      log('Glare Check Passed: $didPassGlareCheck');
      log('Contour Check Passed: $didPassContourCheck');
    }

    // You can now send this session ID and the detailed results to your backend
    // for verification or proceed with your app flow.
  },
);
```

### Custom UI Elements

Customize the UI with your own components:

```dart
LivenessDetectionScreen(
  cameras: cameras,
  showAppBar: false, // Hide default app bar
  customAppBar: AppBar(
    title: const Text('My Custom Verification'),
    backgroundColor: Colors.transparent,
  ),
  customSuccessOverlay: MyCustomSuccessWidget(),
);
```

### Image Capture

Enable capturing the user's image after successful verification:

```dart
LivenessDetectionScreen(
  cameras: cameras,
  captureFinalImage: true, // Enable final image capture
  onFinalImageCaptured: (sessionId, imageFile, metadata) {
    // imageFile is an XFile that contains the captured image
    log('Image saved to: ${imageFile.path}');

    // The metadata map contains the detailed anti-spoofing results
    final antiSpoofingResult = metadata['antiSpoofingDetection'];
    log('Anti-spoofing results from capture: $antiSpoofingResult');

    // You can now:
    // 1. Display the image
    // 2. Upload it to your server along with the metadata
    // 3. Store it locally
  },
);
```

## Advanced Usage

### Embedding in Custom UI

You can incorporate the liveness detection into a larger flow:

```dart
class VerificationFlow extends StatefulWidget {
  @override
  _VerificationFlowState createState() => _VerificationFlowState();
}

class _VerificationFlowState extends State<VerificationFlow> {
  int _currentStep = 0;
  String? _sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentStep,
        children: [
          // Step 1: Instructions
          InstructionScreen(
            onContinue: () => setState(() => _currentStep = 1),
          ),

          // Step 2: Liveness Detection
          LivenessDetectionScreen(
            cameras: cameras,
            onLivenessCompleted: (sessionId, isSuccessful, result) {
              if (isSuccessful) {
                setState(() {
                  _sessionId = sessionId;
                  _currentStep = 2;
                });
              }
            },
          ),

          // Step 3: Verification Complete
          VerificationCompleteScreen(
            sessionId: _sessionId,
            onContinue: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
```

## Available Challenge Types

- `ChallengeType.blink` - Verify that the user can blink
- `ChallengeType.turnLeft` - Verify that the user can turn their head left
- `ChallengeType.turnRight` - Verify that the user can turn their head right
- `ChallengeType.tiltUp` - Verify that the user can tilt their head up
- `ChallengeType.tiltDown` - Verify that the user can tilt their head down
- `ChallengeType.smile` - Verify that the user can smile
- `ChallengeType.nod` - Verify that the user can nod their head
- `ChallengeType.Zoom` - The user needs to move their face closer to the camera, filling the oval.
- `ChallengeType.normal` - Checks whether the user's face is centered. Ideal for taking a photo of the user.

## Advanced Anti-Spoofing Measures

This package implements several advanced, configurable anti-spoofing measures to provide a robust defense against common presentation attacks. While some checks act as non-blocking flags, the motion correlation check determines the final success of the verification.

Upon completion, the `onLivenessCompleted` and `onFinalImageCaptured` callbacks return a detailed metadata map with the results.

### Anti-Spoofing Result Map

Both callbacks provide a `metadata` map which may contain an `antiSpoofingDetection` key. This key holds a nested map with the following boolean flags:

- `motionCorrelationCheckFailed`: The only blocking check by default. If `true`, the overall `isSuccessful` result of the liveness check will be `false`. This occurs if the head moves significantly but the device does not.
- `screenGlareDetected`: A non-blocking flag. `true` if potential screen glare was detected on the user's face.
- `lackOfFacialContoursDetected`: A non-blocking flag. `true` if the system failed to detect a sufficient number of facial contours, which could indicate a mask.

### 1. Screen Glare Detection

This check analyzes the camera feed for bright, reflective spots. It acts as a non-blocking flag in the final result.

**Configuration:**

- `enableScreenGlareDetection`: Set to `false` to disable this check. (Default: `true`)
- `glareBrightnessFactor`: Multiplier for the average brightness to set the dynamic glare threshold. (Default: `3.0`)
- `minBrightPercentage` / `maxBrightPercentage`: The minimum and maximum percentage of bright pixels required to trigger the glare detection. (Defaults: `0.05` and `0.30`)

### 2. Motion Correlation Check

This is a powerful defense that determines the final success of the verification. To prevent false positives from minor tremors, it uses the standard deviation of head angles to detect significant movement. It ensures head and device movements are correlated.

**Configuration:**

- `enableMotionCorrelationCheck`: Set to `false` to disable this check. (Default: `true`)
- `significantHeadMovementStdDev`: The standard deviation threshold for head movement to be considered significant. A higher value is more tolerant. (Default: `5.0`)
- `minDeviceMovementThreshold`: The minimum amount of device motion required to pass the check if significant head motion is detected. (Default: `0.5`)

### 3. Face Contour Analysis (Mask Detection)

This check verifies the integrity of facial contours and acts as a non-blocking flag in the final result.

**Configuration:**

- `enableContourAnalysisOnCentering`: When `true`, performs the contour check during the initial face centering step. (Default: `true`)
- `contourChallengeTypes`: A list of `ChallengeType` where the contour check should also be performed (e.g., `ChallengeType.blink` or `ChallengeType.smile`).
- `minRequiredSecondaryContours`: The minimum number of secondary contours required for the check to pass. This makes the detection tolerant to minor imperfections. (Default: `2`)

### 4. Continuous Identity Verification (Sandwich Strategy)

To prevent "swap attacks" (where a real user starts the session but then swaps to a photo/video), it is highly recommended to perform a face check at the beginning and at the end of the session.

This strategy "sandwiches" the liveness challenges between two `ChallengeType.normal` checks. The package can automatically insert these checks for random challenge sequences.

**Configuration:**

- `sandwichNormalChallenge`: When `true`, automatically adds a `ChallengeType.normal` at the start and end of the randomly generated challenge list. (Default: `false` for backward compatibility)

**Manual Configuration Note:**
If you are providing a custom list of `challengeTypes` instead of using random generation, it is strongly recommended that you manually add `ChallengeType.normal` as the first and last items in your list.

**Example:**

```dart
LivenessConfig(
  // ... other settings
  enableContourAnalysisOnCentering: true,
  contourChallengeTypes: [
    ChallengeType.blink,
    ChallengeType.smile,
  ],
  minRequiredSecondaryContours: 2, // Requires 2 out of 5 secondary contours to be present
  // Automatically add normal check at start and end
  sandwichNormalChallenge: true, 
)
```

## Demo 
![Example](https://github.com/demola234/smart_liveliness_detection/blob/main/screenshots/smart_liveliness_detector.gif?raw=true)

## Demo Video
Check out our [demo video](https://vimeo.com/1078400278?share=copy) to see the package in action!

## Contributing

Contributions are welcome! Feel free to submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
