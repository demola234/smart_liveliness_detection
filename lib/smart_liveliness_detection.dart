library smart_liveliness_detection;

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_liveliness_detection/src/controllers/liveness_controller.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';

// Configuration
export 'src/config/app_config.dart';
export 'src/config/messages_config.dart';
export 'src/config/theme_config.dart';
export 'src/config/challenge_hint_config.dart';
// Controllers
export 'src/controllers/liveness_controller.dart';
// Models
export 'src/models/challenge.dart';
export 'src/models/liveness_session.dart';
// Utilities
export 'src/utils/constants.dart';
export 'src/utils/enums.dart';
// Export public APIs

// Main widgets
export 'src/widgets/liveliness_detection_screen.dart';

// Callback types
typedef LivenessCompletedCallback = void Function(String sessionId, bool isSuccessful, Map<String, dynamic>? metadata);
typedef ChallengeCompletedCallback = void Function(ChallengeType challengeType);
typedef FinalImageCapturedCallback = void Function(String sessionId, XFile imageFile, Map<String, dynamic> metadata);

typedef FaceDetectedCallback = void Function(ChallengeType challengeType, CameraImage image, List<Face> faces, CameraDescription camera);
typedef FaceNotDetectedCallback = void Function(ChallengeType challengeType, LivenessController controller);
