/// A class to hold customizable messages for the liveness detection UI.
class LivenessMessages {
  //region ## Face centering messages
  /// Message displayed when the user's face is too far from the camera.
  final String moveFartherAway;

  /// Message displayed when the user's face is too close to the camera.
  final String moveCloser;

  /// Message displayed when the user needs to move their face to the right.
  final String moveRight;

  /// Message displayed when the user needs to move their face to the left.
  final String moveLeft;

  /// Message displayed when the user needs to move their face up.
  final String moveUp;

  /// Message displayed when the user needs to move their face down.
  final String moveDown;

  /// Message displayed when the user's face is perfectly positioned.
  final String perfectHoldStill;

  /// Message displayed when no face is detected.
  final String noFaceDetected;

  /// Message displayed when there is an error checking face position.
  final String errorCheckingFacePosition;
  //endregion

  //region ## Status messages
  /// Message displayed when the session is initializing.
  final String initializing;

  /// Message displayed when the camera is initializing.
  final String initializingCamera;

  /// Error message if camera initialization fails.
  final String errorInitializingCamera;

  /// Initial instruction for positioning the face.
  final String initialInstruction;

  /// Message for when lighting is poor.
  final String poorLighting;

  /// Message displayed during final processing.
  final String processingVerification;

  /// Message displayed when verification is complete.
  final String verificationComplete;

  /// Message for a possible spoofing attempt.
  final String spoofingDetected;

  ///Message displayed when there is a processing error.
  final String errorProcessing;
  //endregion

  /// Constructs a [LivenessMessages] object.
  const LivenessMessages({
    this.moveFartherAway = 'Move farther away',
    this.moveCloser = 'Move closer',
    this.moveRight = 'Move right',
    this.moveLeft = 'Move left',
    this.moveUp = 'Move up',
    this.moveDown = 'Move down',
    this.perfectHoldStill = 'Perfect! Hold still',
    this.noFaceDetected = 'No face detected',
    this.errorCheckingFacePosition = 'Error checking face position',

    // -------------------------------------------------------------------------

    this.initializing = 'Initializing...',
    this.initializingCamera = 'Initializing camera...',
    this.errorInitializingCamera = 'Error initializing camera. Please restart the app.',
    this.initialInstruction = 'Position your face in the oval',
    this.poorLighting = 'Please move to a better lit area',
    this.processingVerification = 'Processing verification...',
    this.verificationComplete = 'Liveness verification complete!',
    this.spoofingDetected = "Potential spoofing detected.",
    this.errorProcessing = 'Processing error occurred',
  });
}