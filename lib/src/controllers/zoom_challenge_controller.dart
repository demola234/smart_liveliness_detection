// In a new file, e.g., lib/src/controllers/zoom_challenge_controller.dart
import 'package:flutter/material.dart';

// Enum to represent the challenge states
enum ZoomChallengeState {
  initial,      // Challenge hasn't started yet
  inProgress,   // User is approaching
  completed,    // User has successfully approached
  failed,       // Time has run out or the face has been lost
}

class ZoomChallengeController extends ChangeNotifier {
  final AnimationController _animationController;
  final double _initialValue;

  ZoomChallengeState _state = ZoomChallengeState.initial;
  ZoomChallengeState get state => _state;

  double get zoomFactor => _animationController.value;

  ZoomChallengeController({required TickerProvider vsync,
    required double initialValue,
  }) : _animationController = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 500), // Duration of the animation
    value: initialValue,
  ), _initialValue = initialValue {
    _animationController.addListener(notifyListeners); // Notify the UI to rebuild
  }

  void startChallenge() {
    if (_state == ZoomChallengeState.initial) {
      _state = ZoomChallengeState.inProgress;
      _animationController.forward();
    }
  }

  // This method will be called by the FaceDetectionService
  void onFaceValidationResult(bool isFaceCorrectlyPositioned) {
    if (_state != ZoomChallengeState.inProgress) return;

    // If the animation has finished and the face is correctly positioned, the challenge is complete!
    if (_animationController.isCompleted && isFaceCorrectlyPositioned) {
      _state = ZoomChallengeState.completed;
      debugPrint("✅ Zoom Challenge Completed!");
      notifyListeners();
    }
  }


  // If time runs out and the challenge was not completed
  void checkTimeout() {
    if (_animationController.isCompleted && _state != ZoomChallengeState.completed) {
      _state = ZoomChallengeState.failed;
      notifyListeners();
    }
  }

  /// Resets the challenge to its initial state.
  void reset() {
    _state = ZoomChallengeState.initial;
    //_animationController.reset();
    _animationController.value = _initialValue;
    debugPrint("🔄️ Zoom Challenge Controller has been reset.");
    notifyListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}