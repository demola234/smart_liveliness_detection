import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Optional: Set immersive mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  // Get available cameras
  final cameras = await availableCameras();

  runApp(FaceLivenessExampleApp(cameras: cameras));
}

class FaceLivenessExampleApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const FaceLivenessExampleApp({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Liveness Detection Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Liveness Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a liveness detection example:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            _buildExampleButton(
              context,
              'Default Style',
              'Use the package with default settings',
              () => _navigateToLivenessScreen(
                context,
                const LivenessConfig(),
                const LivenessTheme(),
              ),
            ),
            _buildExampleButton(
              context,
              'Custom Theme',
              'Custom colors and styling',
              () => _navigateToLivenessScreen(
                context,
                const LivenessConfig(),
                const LivenessTheme(
                  primaryColor: Colors.purple,
                  ovalGuideColor: Colors.purpleAccent,
                  successColor: Colors.green,
                  errorColor: Colors.redAccent,
                  overlayOpacity: 0.6,
                  progressIndicatorColor: Colors.purpleAccent,
                  instructionTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  useOvalPulseAnimation: true,
                ),
              ),
            ),
            _buildExampleButton(
              context,
              'Custom Challenges',
              'Specific challenge sequence with custom messages',
              () {
                const customConfig = LivenessConfig(
                  initialZoomFactor: 0.1,
                  challengeTypes: [
                    ChallengeType.blink,
                    ChallengeType.zoom,
                    ChallengeType.turnRight,
                    ChallengeType.turnLeft,
                    ChallengeType.tiltUp,
                    ChallengeType.tiltDown,
                    ChallengeType.smile,
                    ChallengeType.normal,
                    //ChallengeType.nod,
                  ],
                  challengeInstructions: {
                    ChallengeType.blink: 'Blink your eyes slowly',
                    ChallengeType.zoom: 'Bring your face closer slowly',
                    ChallengeType.turnRight: 'Turn your head to the right',
                    ChallengeType.turnLeft: 'Turn your head to the left',
                    ChallengeType.tiltUp: 'Tilt up your head',
                    ChallengeType.tiltDown: 'Tilt down your head',
                    ChallengeType.smile: 'Show me your best smile',
                    ChallengeType.normal: 'Center Your Face',
                    //ChallengeType.nod: 'Nod your head up and down',
                  },
                );
                _navigateToLivenessScreen(
                    context, customConfig, const LivenessTheme(
                    successColor: Colors.green,
                    errorColor: Colors.redAccent,
                    guidanceTextStyle: TextStyle(
                      //color: Color(0xFF2E38B7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                ));
              },
            ),
            _buildExampleButton(
              context,
              'Custom Challenges and Status Messages',
              'Specific challenge sequence with custom messages',
                  () {
                const customConfig = LivenessConfig(
                  initialZoomFactor: 0.1,
                  challengeTypes: [
                    ChallengeType.blink,
                    ChallengeType.zoom,
                    ChallengeType.turnRight,
                    ChallengeType.turnLeft,
                    ChallengeType.tiltUp,
                    ChallengeType.tiltDown,
                    ChallengeType.smile,
                    ChallengeType.normal,
                    //ChallengeType.nod,
                  ],
                  challengeInstructions: {
                    ChallengeType.blink: 'Pisque os olhos lentamente',
                    ChallengeType.zoom: 'Aproxime o rosto lentamente',
                    ChallengeType.turnRight: 'Vire a cabeça para o lado direito',
                    ChallengeType.turnLeft: 'Vire a cabeça para o lado esquerdo',
                    ChallengeType.tiltUp: 'Incline a cabeça para cima',
                    ChallengeType.tiltDown: 'Incline a cabeça para baixo',
                    ChallengeType.smile: 'Mostre seu melhor sorriso',
                    ChallengeType.normal: 'Centralize seu rosto',
                    //ChallengeType.nod: 'Acene com a cabeça',
                  },
                  messages: LivenessMessages(
                    moveFartherAway: 'Afaste-se um pouco',
                    moveCloser: 'Aproxime-se um pouco',
                    moveLeft: 'Mova para a esquerda',
                    moveRight: 'Mova para a direita',
                    moveUp: 'Mova para cima',
                    moveDown: 'Mova para baixo',
                    perfectHoldStill: 'Perfeito! Fique parado',
                    noFaceDetected: 'Nenhum rosto detectado',
                    errorCheckingFacePosition: 'Ocorreu um erro no processamento',

                    initializing: 'Inicializando...',
                    initializingCamera: 'Inicializando a camera...',
                    errorInitializingCamera: 'Erro ao inicializar a câmera. Reinicie o aplicativo.',
                    initialInstruction: 'Posicione seu rosto no oval',
                    poorLighting: 'Mova-se para uma área mais iluminada',
                    processingVerification: 'Processando verificação...',
                    verificationComplete: 'Verificação de vivacidade concluída!',
                    spoofingDetected: "Possível falsificação detectada.",
                    errorProcessing: 'Ocorreu um erro de processamento',
                  ),
                );
                _navigateToLivenessScreen(
                    context, customConfig, const LivenessTheme(
                  successColor: Colors.green,
                  errorColor: Colors.redAccent,
                  guidanceTextStyle: TextStyle(
                    //color: Color(0xFF2E38B7),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  //overlayColor: Colors.white,
                  // overlayOpacity: 0.85,
                  // primaryColor: Colors.white,
                  // ovalGuideColor: Colors.white, //.withValues(alpha: 0.87),
                  // appBarBackgroundColor: Colors.white,
                  // appBarTextColor: Colors.black87
                ));
              },
            ),
            _buildExampleButton(
              context,
              'Material Design',
              'Theme based on Material Design',
              () {
                final materialTheme = LivenessTheme.fromMaterialColor(
                  Colors.teal,
                  brightness: Brightness.dark,
                );
                _navigateToLivenessScreen(
                    context, const LivenessConfig(), materialTheme);
              },
            ),
            _buildExampleButton(
              context,
              'Capture User Image',
              'Take a photo after successful verification',
              () => _navigateToLivenessWithImageCapture(context),
            ),
            _buildExampleButton(
              context,
              'Custom Configuration',
              'Modified thresholds and settings',
              () {
                const customConfig = LivenessConfig(
                  maxSessionDuration: Duration(minutes: 3),
                  eyeBlinkThresholdOpen: 0.8,
                  eyeBlinkThresholdClosed: 0.2,
                  smileThresholdSmiling: 0.8,
                  headTurnThreshold: 15.0,
                  ovalHeightRatio: 0.7,
                  ovalWidthRatio: 0.8,
                  strokeWidth: 5.0,
                  numberOfRandomChallenges: 2,
                );
                _navigateToLivenessScreen(
                    context, customConfig, const LivenessTheme());
              },
            ),
            _buildExampleButton(
              context,
              'Challenge Hints (Default)',
              'Display built-in GIF hints for challenges',
              () => _navigateToLivenessWithDefaultHints(context),
            ),
            _buildExampleButton(
              context,
              'Challenge Hints (Custom Position)',
              'Customize hint position and size per challenge',
              () => _navigateToLivenessWithCustomHints(context),
            ),
            _buildExampleButton(
              context,
              'Futuristic UI — Fixed Style',
              'Animated progress bar with a preset painter (Quantum)',
              () => _navigateToLivenessWithFuturisticStyle(context),
            ),
            _buildExampleButton(
              context,
              'Futuristic UI — Style Picker',
              'Switch between 13 animated painters at runtime',
              () => _navigateToLivenessWithStylePicker(context),
            ),
            _buildExampleButton(
              context,
              'Futuristic + Neon Hints',
              'Kinetic fluid-arc theme with neon-glowing hint cards and elastic bounce animation. Palette button switches themes.',
              () => _navigateToFuturisticNeonHints(context),
            ),
            _buildExampleButton(
              context,
              'Hint Styles Showcase',
              'Each challenge shows a different hint style (plain → glass → futuristic → minimal → neon) with matching animations.',
              () => _navigateToHintStylesShowcase(context),
            ),
            _buildExampleButton(
              context,
              'Voice Guidance',
              'Spoken instructions and positioning feedback via device TTS',
              () => _navigateToLivenessWithVoiceGuidance(context),
            ),
            _buildExampleButton(
              context,
              'Face Quality Scoring',
              'Real-time quality score with issues and recommendations',
              () => _navigateToLivenessWithQualityScoring(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String title,
    String description,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLivenessScreen(
    BuildContext context,
    LivenessConfig config,
    LivenessTheme theme,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: config,
          theme: theme,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness verification completed:');
            log('Session ID: $sessionId');
            log('Success: $isSuccessful');
            log('Metadata: $metadata');
          },
          onFaceDetected: (ChallengeType challengeType, bool firstChallengePassed, CameraImage image, List<Face> faces, CameraDescription camera) {
            log('onFaceDetected - current Challenge: ${challengeType.name}');
          },
          onFaceNotDetected: (ChallengeType challengeType, LivenessController controller) {
            log('onFaceNotDetected - current Challenge: ${challengeType.name}');

            // Reset session if face is not detected and the head is not turned
            if(![ChallengeType.tiltDown, ChallengeType.tiltUp, ChallengeType.turnRight, ChallengeType.turnLeft, ChallengeType.nod].contains(challengeType)) {
              controller.resetSession();
            }
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithImageCapture(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            alwaysIncludeBlink: true,
            challengeTypes: [
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.blink,
            ],
          ),
          theme: LivenessTheme.fromMaterialColor(
            Colors.blue,
            brightness: Brightness.dark,
          ),
          // Enable single final image capture
          captureFinalImage: true,
          // Show a button for manual capture as well
          showCaptureImageButton: true,
          showStatusIndicators: false,
          showAppBar: false,
          captureButtonText: 'Take Photo',
          // Process the final verification image
          onFinalImageCaptured: (sessionId, imageFile, metadata) {
            log('Final image captured:');
            log('Session ID: $sessionId');
            log('Image path: ${imageFile.path}');
            log('Metadata: $metadata');

            // Show a dialog with the captured image
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Verification Complete'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Session ID: $sessionId'),
                      const SizedBox(height: 8),
                      Text('Image saved to: ${imageFile.path}'),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imageFile.path),
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            log('Error loading image: $error');
                            return const Text('Could not load image preview');
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Challenge count: ${(metadata['challenges'] as List).length}'),
                      Text('Duration: ${metadata['sessionDuration']} ms'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          // Handle manual capture separately
          onManualImageCaptured: (sessionId, imageFile) {
            log('Manual image captured:');
            log('Session ID: $sessionId');
            log('Image path: ${imageFile.path}');

            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Manual Image Captured'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Session ID: $sessionId'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imageFile.path),
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            log('Error loading image: $error');
                            return const Text('Could not load image preview');
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness verification completed:');
            log('Session ID: $sessionId');
            log('Success: $isSuccessful');
            log('Metadata: $metadata');
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithDefaultHints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.smile,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.nod,
            ],
            // Enable default hints for all challenges
            defaultChallengeHintConfig: ChallengeHintConfig(
              enabled: true,
              position: ChallengeHintPosition.topCenter,
              size: 100.0,
              displayDuration: Duration(seconds: 2),
            ),
          ),
          theme: const LivenessTheme(
            primaryColor: Colors.blue,
            successColor: Colors.green,
          ),
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness verification completed:');
            log('Session ID: $sessionId');
            log('Success: $isSuccessful');
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithFuturisticStyle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.smile,
            ],
          ),
          theme: const LivenessTheme(),
          // Fixed futuristic painter — no style-picker button shown
          painterStyle: LivenessUiStyle.quantum,
          futuristicBarHeight: 72,
          showAppBar: false,
          showStatusIndicators: true,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted && isSuccessful) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Verified!'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithStylePicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.smile,
            ],
          ),
          theme: const LivenessTheme(),
          // Start with cosmos; palette button lets the user switch styles
          painterStyle: LivenessUiStyle.cosmos,
          allowStyleChange: true,
          futuristicBarHeight: 72,
          showAppBar: false,
          showStatusIndicators: true,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted && isSuccessful) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Verified!'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToFuturisticNeonHints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.smile,
              ChallengeType.nod,
            ],
            // Neon hint cards that match the kinetic accent colour
            defaultChallengeHintConfig: ChallengeHintConfig(
              enabled: true,
              position: ChallengeHintPosition.topCenter,
              size: 110.0,
              displayDuration: Duration(seconds: 3),
              hintStyle: ChallengeHintStyle.neon,
              hintAnimation: ChallengeHintAnimation.bounceIn,
              accentColor: Color(0xFFFF6B35), // kinetic orange
            ),
          ),
          theme: const LivenessTheme(),
          // Kinetic style — shows the fluid-arc conduit + rippled oval border
          painterStyle: LivenessUiStyle.kinetic,
          // Palette button (bottom-right) lets the user swipe through themes
          allowStyleChange: true,
          showAppBar: false,
          showStatusIndicators: true,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted && isSuccessful) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Verified!'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToHintStylesShowcase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.smile,
              ChallengeType.nod,
            ],
            // Each challenge gets a distinct hint style + animation
            challengeHints: {
              ChallengeType.blink: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 110.0,
                hintStyle: ChallengeHintStyle.plain,
                hintAnimation: ChallengeHintAnimation.scaleIn,
              ),
              ChallengeType.turnLeft: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 110.0,
                hintStyle: ChallengeHintStyle.glass,
                hintAnimation: ChallengeHintAnimation.slideUp,
              ),
              ChallengeType.turnRight: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 110.0,
                hintStyle: ChallengeHintStyle.futuristic,
                hintAnimation: ChallengeHintAnimation.flipIn,
                accentColor: Color(0xFF00D4FF), // quantum cyan
              ),
              ChallengeType.smile: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 110.0,
                hintStyle: ChallengeHintStyle.minimal,
                hintAnimation: ChallengeHintAnimation.bounceIn,
                accentColor: Color(0xFF00FF88), // synapse green
              ),
              ChallengeType.nod: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 110.0,
                hintStyle: ChallengeHintStyle.neon,
                hintAnimation: ChallengeHintAnimation.bounceIn,
                accentColor: Color(0xFF5B8CFF), // cosmos blue
              ),
            },
          ),
          theme: const LivenessTheme(),
          // Start with cosmos; palette button lets user swipe through all themes
          painterStyle: LivenessUiStyle.cosmos,
          allowStyleChange: true,
          showAppBar: false,
          showStatusIndicators: true,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted && isSuccessful) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Verified!'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithVoiceGuidance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.smile,
            ],
            challengeInstructions: {
              ChallengeType.blink: 'Please blink your eyes',
              ChallengeType.turnLeft: 'Please turn your head to the left',
              ChallengeType.smile: 'Please smile',
            },
            voiceGuidance: VoiceGuidanceConfig(
              enabled: true,
              language: 'en-US',
              speechRate: 0.5,
              speakPositioningFeedback: true,
              speakChallengeInstructions: true,
              speakCompletion: true,
              repeatInterval: Duration(seconds: 3),
            ),
          ),
          theme: const LivenessTheme(),
          showAppBar: true,
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(isSuccessful ? 'Verified!' : 'Failed'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithQualityScoring(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.turnLeft,
              ChallengeType.smile,
            ],
            enableFaceQualityScoring: true,
            minFaceQualityScore: 60.0,
            blockChallengesOnLowQuality: false,
          ),
          theme: const LivenessTheme(),
          showAppBar: true,
          onFaceQualityCheck: (result) {
            log('Quality score: ${result.score.toStringAsFixed(1)}');
            log('Issues: ${result.issues}');
            log('Recommendations: ${result.recommendations}');
            log('Metrics: ${result.metrics.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
          },
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness completed — success: $isSuccessful');
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(isSuccessful ? 'Verified!' : 'Failed'),
                  content: Text('Session: $sessionId'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _navigateToLivenessWithCustomHints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivenessDetectionScreen(
          cameras: cameras,
          config: const LivenessConfig(
            challengeTypes: [
              ChallengeType.blink,
              ChallengeType.smile,
              ChallengeType.turnLeft,
              ChallengeType.turnRight,
              ChallengeType.nod,
            ],
            // Custom hints per challenge type
            challengeHints: {
              ChallengeType.blink: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topCenter,
                size: 120.0,
                displayDuration: Duration(seconds: 3),
              ),
              ChallengeType.smile: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.bottomCenter,
                size: 100.0,
                displayDuration: Duration(seconds: 2),
              ),
              ChallengeType.turnLeft: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topRight,
                size: 80.0,
              ),
              ChallengeType.turnRight: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.topLeft,
                size: 80.0,
              ),
              ChallengeType.nod: ChallengeHintConfig(
                enabled: true,
                position: ChallengeHintPosition.bottomCenter,
                size: 110.0,
              ),
            },
            // Fallback for challenges not in the map
            defaultChallengeHintConfig: ChallengeHintConfig(
              enabled: false,
            ),
          ),
          theme: LivenessTheme.fromMaterialColor(
            Colors.purple,
            brightness: Brightness.dark,
          ),
          onChallengeCompleted: (challengeType) {
            log('Challenge completed: ${challengeType.name}');
          },
          onLivenessCompleted: (sessionId, isSuccessful, metadata) {
            log('Liveness verification completed:');
            log('Session ID: $sessionId');
            log('Success: $isSuccessful');

            // Show success dialog
            if (context.mounted && isSuccessful) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Success!'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text('Liveness verification passed!'),
                      const SizedBox(height: 8),
                      Text('Session ID: $sessionId'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
