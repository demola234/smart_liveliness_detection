import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';
import 'package:smart_liveliness_detection/src/widgets/instruction_overlay.dart';
import 'package:smart_liveliness_detection/src/widgets/liveness_progress_bar.dart';
import 'package:smart_liveliness_detection/src/widgets/oval_progress.dart';
import 'package:smart_liveliness_detection/src/widgets/status_indicator.dart';
import 'package:smart_liveliness_detection/src/widgets/success_overlay.dart';
import 'package:smart_liveliness_detection/src/widgets/challenge_hint_widget.dart';

/// Callback type for when a challenge is completed
typedef ChallengeCompletedCallback = void Function(ChallengeType challengeType);

/// Callback type for when liveness verification is completed
typedef LivenessCompletedCallback = void Function(String sessionId, bool isSuccessful, Map<String, dynamic> data);

/// Callback type for when final image is captured with metadata
typedef FinalImageCapturedCallback = void Function(String sessionId, XFile imageFile, Map<String, dynamic> metadata);

/// Callback type for when face is detected
typedef FaceDetectedCallback = void Function(ChallengeType challengeType, bool firstChallengePassed, CameraImage image, List<Face> faces, CameraDescription camera);

/// Callback type for when face is NOT detected (It will trigger the first face non-detection event after any face detection)
typedef FaceNotDetectedCallback = void Function(ChallengeType challengeType, LivenessController controller);

/// Callback type for face quality scoring results
typedef FaceQualityCallback = void Function(FaceQualityResult result);

/// Main widget for liveness detection
class LivenessDetectionScreen extends StatefulWidget {
  /// Available cameras
  final List<CameraDescription> cameras;

  /// Configuration
  final LivenessConfig? config;

  /// Theme
  final LivenessTheme? theme;

  /// Callback for when a challenge is completed
  final ChallengeCompletedCallback? onChallengeCompleted;

  /// Callback for when liveness verification is completed
  final LivenessCompletedCallback? onLivenessCompleted;

  /// Callback for when face is detected
  final FaceDetectedCallback? onFaceDetected;

  /// Callback for when face is NOT detected
  final FaceNotDetectedCallback? onFaceNotDetected;

  /// Callback fired each time a face quality score is computed.
  final FaceQualityCallback? onFaceQualityCheck;

  /// Whether to show app bar
  final bool showAppBar;

  /// Custom app bar
  final PreferredSizeWidget? customAppBar;

  /// Custom success overlay
  final Widget? customSuccessOverlay;

  /// Whether to show status indicators
  final bool showStatusIndicators;

  /// Whether to show the capture image button
  final bool showCaptureImageButton;

  /// Callback when manual image is captured
  final Function(String sessionId, XFile imageFile)? onManualImageCaptured;

  /// Text for the capture button
  final String? captureButtonText;

  /// Whether to use color progress for oval
  final bool useColorProgress;

  /// Whether to capture a single image at the end of verification
  final bool captureFinalImage;

  /// Callback for when final image is captured with metadata
  final FinalImageCapturedCallback? onFinalImageCaptured;

  /// Optional futuristic painter style for the progress bar.
  ///
  /// When set, the bottom progress area is replaced by an animated
  /// [FuturisticLivenessBar] using the chosen [LivenessUiStyle].
  /// When `null` the default progress indicator is used.
  final LivenessUiStyle? painterStyle;

  /// When `true` a floating button lets the user switch [painterStyle] at
  /// runtime via [LivenessStylePicker]. Has no effect when [painterStyle]
  /// is `null`.
  final bool allowStyleChange;

  /// Height of the futuristic bar in logical pixels (default 64).
  final double futuristicBarHeight;

  /// Constructor
  const LivenessDetectionScreen({
    super.key,
    required this.cameras,
    this.config,
    this.theme,
    this.onChallengeCompleted,
    this.onLivenessCompleted,
    this.showAppBar = true,
    this.customAppBar,
    this.customSuccessOverlay,
    this.showStatusIndicators = true,
    this.showCaptureImageButton = false,
    this.onManualImageCaptured,
    this.captureButtonText,
    this.useColorProgress = true,
    this.captureFinalImage = false,
    this.onFinalImageCaptured,
    this.onFaceDetected,
    this.onFaceNotDetected,
    this.onFaceQualityCheck,
    this.painterStyle,
    this.allowStyleChange = false,
    this.futuristicBarHeight = 64,
  });

  @override
  State<LivenessDetectionScreen> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late LivenessController _controller;
  XFile? _finalImage;

  late double _zoomFactor;

  void _resetZoomFactor() {
    setState(() {
      _zoomFactor = widget.config?.initialZoomFactor ?? 1.0;
    });
  }

  void _syncZoomFactor() {
    final z = _controller.zoomFactor;
    if (z != _zoomFactor) {
      setState(() {
        _zoomFactor = z;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _resetZoomFactor();

    _controller = LivenessController(
      cameras: widget.cameras,
      vsync: this,
      config: widget.config,
      theme: widget.theme,
      onChallengeCompleted: widget.onChallengeCompleted,
      // Make sure this is using the same type
      onLivenessCompleted: widget.onLivenessCompleted != null ? (sessionId, isSuccessful, data) {
        widget.onLivenessCompleted!(sessionId, isSuccessful, data!);
      } : null,
      onFinalImageCaptured: _handleFinalImageCaptured,
      captureFinalImage: widget.captureFinalImage,
      onFaceDetected: widget.onFaceDetected,
      onFaceNotDetected: widget.onFaceNotDetected,
      onFaceQualityCheck: widget.onFaceQualityCheck,
      onReset: _resetZoomFactor,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  void _handleFinalImageCaptured(String sessionId, XFile imageFile, Map<String, dynamic> metadata) {
    setState(() {
      _finalImage = imageFile;
    });

    if (widget.onFinalImageCaptured != null) {
      widget.onFinalImageCaptured!(sessionId, imageFile, metadata);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _controller = LivenessController(
        cameras: widget.cameras,
        vsync: this,
        config: widget.config,
        theme: widget.theme,
        onChallengeCompleted: widget.onChallengeCompleted,
        // Make sure this is using the same type
        onLivenessCompleted: widget.onLivenessCompleted != null
            ? (sessionId, isSuccessful, data) {
                widget.onLivenessCompleted!(sessionId, isSuccessful, data!);
              }
            : null,
        onFinalImageCaptured: _handleFinalImageCaptured,
        captureFinalImage: widget.captureFinalImage,
        onFaceQualityCheck: widget.onFaceQualityCheck,
        onReset: _resetZoomFactor,
      );
      _controller.addListener(_syncZoomFactor);
      setState(() {
        _finalImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Builder(builder: (context) {
        // If we have a final image and custom success overlay isn't provided,
        // use our own success overlay with the captured image
        Widget? successOverlay = widget.customSuccessOverlay;
        if (successOverlay == null &&
            _finalImage != null &&
            widget.captureFinalImage) {
          successOverlay = _buildSuccessWithImage(context);
        }

        final flashColor =
            context.watch<LivenessController>().activeFlashColor;

        return Stack(
          children: [
            LivenessDetectionView(
              initializingMessage: widget.config?.messages.initializingCamera,
              showAppBar: widget.showAppBar,
              customAppBar: widget.customAppBar,
              customSuccessOverlay: successOverlay,
              showStatusIndicators: widget.showStatusIndicators,
              showCaptureImageButton: widget.showCaptureImageButton,
              onImageCaptured: _handleManualCapture,
              captureButtonText: widget.captureButtonText,
              useColorProgress: widget.useColorProgress,
              painterStyle: widget.painterStyle,
              allowStyleChange: widget.allowStyleChange,
              futuristicBarHeight: widget.futuristicBarHeight,
            ),
            if (flashColor != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(color: flashColor.withValues(alpha: 0.85)),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _handleManualCapture(String sessionId) async {
    final imageFile = await _controller.captureImage();
    if (imageFile != null && widget.onManualImageCaptured != null) {
      widget.onManualImageCaptured!(sessionId, imageFile);
    }
  }

  Widget _buildSuccessWithImage(BuildContext context) {
    final controller = Provider.of<LivenessController>(context);
    final theme = controller.theme;

    if (_finalImage == null) return const SizedBox.shrink();

    return Stack(
      children: [
        SuccessOverlay(
          sessionId: controller.sessionId,
          onReset: controller.resetSession,
          theme: theme,
          isSuccessful: controller.isVerificationSuccessful,
          showCaptureImageButton: widget.showCaptureImageButton,
          captureButtonText: widget.captureButtonText,
          onCaptureImage:
              widget.showCaptureImageButton ? _handleManualCapture : null,
        ),
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                "Verification Image Captured",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.successColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.file(
                    File(_finalImage!.path),
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// View component of the liveness detection screen
class LivenessDetectionView extends StatefulWidget {
  /// Whether to show app bar
  final bool showAppBar;

  /// Custom app bar
  final PreferredSizeWidget? customAppBar;

  /// Custom success overlay
  final Widget? customSuccessOverlay;

  /// Whether to show status indicators
  final bool showStatusIndicators;

  /// Whether to show the capture image button
  final bool showCaptureImageButton;

  /// Callback when image is captured
  final Function(String sessionId)? onImageCaptured;

  /// Text for the capture button
  final String? captureButtonText;

  /// Whether to use color progress for oval
  final bool useColorProgress;

  final String? initializingMessage;

  /// Optional futuristic painter style. When set, the default progress bar is
  /// replaced by an animated [FuturisticLivenessBar].
  final LivenessUiStyle? painterStyle;

  /// When `true`, a floating palette button lets the user switch styles at
  /// runtime via [LivenessStylePicker]. Has no effect when [painterStyle] is `null`.
  final bool allowStyleChange;

  /// Height of the futuristic bar in logical pixels (default 64).
  final double futuristicBarHeight;

  /// Constructor
  const LivenessDetectionView({
    super.key,
    this.showAppBar = true,
    this.customAppBar,
    this.customSuccessOverlay,
    this.showStatusIndicators = true,
    this.showCaptureImageButton = false,
    this.onImageCaptured,
    this.captureButtonText,
    this.useColorProgress = true,
    this.initializingMessage = 'Initializing camera...',
    this.painterStyle,
    this.allowStyleChange = false,
    this.futuristicBarHeight = 64,
  });

  @override
  State<LivenessDetectionView> createState() => _LivenessDetectionViewState();
}

class _LivenessDetectionViewState extends State<LivenessDetectionView> {
  LivenessUiStyle? _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.painterStyle;
  }

  Future<void> _pickStyle(BuildContext context) async {
    final chosen = await LivenessStylePicker.show(
      context,
      _currentStyle ?? LivenessUiStyle.quantum,
    );
    if (chosen != null && mounted) {
      setState(() => _currentStyle = chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LivenessController>(context);
    final mediaQuery = MediaQuery.of(context);
    final theme = controller.theme;

    // Show loading screen until initialized
    if (!controller.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator.adaptive(
                backgroundColor: theme.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                widget.initializingMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.statusTextStyle.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build app bar if enabled
    final appBar = widget.showAppBar
        ? widget.customAppBar ??
            AppBar(
              title: const Text('Face Liveness Detection'),
              backgroundColor: theme.appBarBackgroundColor,
              foregroundColor: theme.appBarTextColor,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.resetSession,
                ),
              ],
            )
        : null;

    // When a futuristic style is active, tint the whole screen with its
    // background colour so the themed UI spans the entire display.
    final scaffoldBg = _currentStyle != null
        ? _currentStyle!.theme.backgroundColor
        : theme.backgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview
                _buildCameraPreview(controller),

                // Oval overlay — futuristic HUD when a style is active,
                // standard colour-progress overlay otherwise.
                if (_currentStyle != null)
                  FuturisticOvalOverlay(
                    isFaceDetected: controller.isFaceDetected,
                    config: controller.config,
                    theme: controller.theme,
                    progress: widget.useColorProgress ? controller.progress : 0.0,
                    style: _currentStyle!,
                    zoomFactor: controller.zoomFactor,
                  )
                else
                  OvalColorProgressOverlay(
                    zoomFactor: controller.zoomFactor,
                    isFaceDetected: controller.isFaceDetected,
                    config: controller.config,
                    theme: controller.theme,
                    progress: widget.useColorProgress ? controller.progress : 0.0,
                    startColor: theme.primaryColor,
                    endColor: theme.successColor,
                  ),

                // Status indicators
                if (widget.showStatusIndicators) ...[
                  Positioned(
                    top: widget.showAppBar ? 130 : 40,
                    right: 20,
                    child: StatusIndicator.faceDetection(
                      isActive: controller.isFaceDetected,
                      theme: theme,
                    ),
                  ),
                  Positioned(
                    top: widget.showAppBar ? 130 : 40,
                    left: 20,
                    child: StatusIndicator.lighting(
                      isActive: controller.isLightingGood,
                      theme: theme,
                    ),
                  ),
                ],

                // Status message
                Positioned(
                  top: (widget.showAppBar ? kToolbarHeight : 0) +
                      mediaQuery.padding.top +
                      20,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: AnimatedStatusMessage(
                      message: controller.statusMessage,
                      theme: theme,
                    ),
                  ),
                ),

                // Face centering message
                if (controller.currentState == LivenessState.centeringFace)
                  Positioned(
                    bottom: 100 + mediaQuery.padding.bottom,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Text(
                        controller.faceCenteringMessage,
                        style: theme.guidanceTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Challenge hint widget
                if (controller.currentState == LivenessState.performingChallenges &&
                    controller.session.currentChallenge != null)
                  _buildChallengeHint(
                    controller,
                    mediaQuery,
                    widget.showAppBar,
                  ),

                // ── Progress bar (default / legacy) ───────────────────────
                if (_currentStyle == null && !widget.useColorProgress)
                  Positioned(
                    bottom: 40 + mediaQuery.padding.bottom,
                    left: 20,
                    right: 20,
                    child: LivenessProgressBar(
                      progress: controller.progress,
                    ),
                  ),


                // ── Style-picker floating button ──────────────────────────
                if (_currentStyle != null && widget.allowStyleChange)
                  Positioned(
                    bottom: 20 + mediaQuery.padding.bottom,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => _pickStyle(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _currentStyle!.theme.accentColor
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentStyle!.theme.accentColor,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: _currentStyle!.theme.accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                // Success overlay
                if (controller.currentState == LivenessState.completed)
                  widget.customSuccessOverlay ??
                      SuccessOverlay(
                        sessionId: controller.sessionId,
                        onReset: controller.resetSession,
                        theme: theme,
                        isSuccessful: controller.isVerificationSuccessful,
                        showCaptureImageButton: widget.showCaptureImageButton,
                        captureButtonText: widget.captureButtonText,
                        onCaptureImage: widget.showCaptureImageButton
                            ? (sessionId) async {
                                widget.onImageCaptured?.call(sessionId);
                              }
                            : null,
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(LivenessController controller) {
    if (controller.isInitialized && controller.cameraController != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.cameraController!.value.previewSize!.height,
          height: controller.cameraController!.value.previewSize!.width,
          child: CameraPreview(controller.cameraController!),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
  }

  Widget _buildChallengeHint(
    LivenessController controller,
    MediaQueryData mediaQuery,
    bool showAppBar,
  ) {
    final config = controller.config;
    final currentChallenge = controller.session.currentChallenge!;

    final hintConfig = config.challengeHints?[currentChallenge.type] ??
        config.defaultChallengeHintConfig;

    if (hintConfig == null || !hintConfig.enabled) {
      return const SizedBox.shrink();
    }

    final hintWidget = ChallengeHintWidget(
      challengeType: currentChallenge.type,
      config: hintConfig,
      key: ValueKey('hint_${currentChallenge.type}'),
    );

    return hintConfig.position.positionWidget(
      hintWidget,
      mediaQuery,
      showAppBar: showAppBar,
    );
  }
}
