library;

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smart_liveliness_detection/src/controllers/liveness_controller.dart';
import 'package:smart_liveliness_detection/src/models/face_quality_result.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';

// Configuration
export 'src/config/app_config.dart';
export 'src/config/screen_flash_config.dart';
// Models
export 'src/models/face_quality_result.dart';
export 'src/models/screen_flash_result.dart';
export 'src/config/messages_config.dart';
export 'src/config/theme_config.dart';
export 'src/config/challenge_hint_config.dart';
export 'src/config/voice_guidance_config.dart';
// Controllers
export 'src/controllers/liveness_controller.dart';
// Models (continued)
export 'src/models/challenge.dart';
export 'src/models/liveness_session.dart';
// Utilities
export 'src/utils/constants.dart';
export 'src/utils/enums.dart';
export 'src/utils/math_utils.dart';

// Theme
export 'src/theme/futuristic_theme.dart';

// Painters
export 'src/painters/background_glow_painter.dart';
export 'src/painters/chronos_painter.dart';
export 'src/painters/cosmos_painter.dart';
export 'src/painters/floating_painter.dart';
export 'src/painters/hologram_painter.dart';
export 'src/painters/kinetic_painter.dart';
export 'src/painters/liquid_metal_painter.dart';
export 'src/painters/monolith_painter.dart';
export 'src/painters/obsidian_painter.dart';
export 'src/painters/prism_painter.dart';
export 'src/painters/quantum_painter.dart';
export 'src/painters/singularity_painter.dart';
export 'src/painters/sumi_painter.dart';
export 'src/painters/synapse_painter.dart';

// Main widgets
export 'src/widgets/liveliness_detection_screen.dart';
export 'src/painters/liveness_ui_style.dart';
export 'src/widgets/futuristic_liveness_bar.dart';
export 'src/widgets/futuristic_oval_overlay.dart';
export 'src/widgets/liveness_style_picker.dart';

// Callback types
typedef LivenessCompletedCallback = void Function(String sessionId, bool isSuccessful, Map<String, dynamic>? metadata);
typedef ChallengeCompletedCallback = void Function(ChallengeType challengeType);
typedef FinalImageCapturedCallback = void Function(String sessionId, XFile imageFile, Map<String, dynamic> metadata);

typedef FaceDetectedCallback = void Function(ChallengeType challengeType, bool firstChallengePassed, CameraImage image, List<Face> faces, CameraDescription camera);
typedef FaceNotDetectedCallback = void Function(ChallengeType challengeType, LivenessController controller);
typedef FaceQualityCallback = void Function(FaceQualityResult result);
