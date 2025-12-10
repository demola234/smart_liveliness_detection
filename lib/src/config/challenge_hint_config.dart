import 'package:smart_liveliness_detection/src/utils/enums.dart';

class ChallengeHintConfig {
  final bool enabled;

  final String? assetPath;

  final ChallengeHintPosition position;

  final double size;

  final Duration displayDuration;

  final bool animateEntrance;

  final bool isLottie;

  const ChallengeHintConfig({
    this.enabled = true,
    this.assetPath,
    this.position = ChallengeHintPosition.topCenter,
    this.size = 100.0,
    this.displayDuration = const Duration(seconds: 2),
    this.animateEntrance = true,
    this.isLottie = false,
  });

  ChallengeHintConfig copyWith({
    bool? enabled,
    String? assetPath,
    ChallengeHintPosition? position,
    double? size,
    Duration? displayDuration,
    bool? animateEntrance,
    bool? isLottie,
  }) {
    return ChallengeHintConfig(
      enabled: enabled ?? this.enabled,
      assetPath: assetPath ?? this.assetPath,
      position: position ?? this.position,
      size: size ?? this.size,
      displayDuration: displayDuration ?? this.displayDuration,
      animateEntrance: animateEntrance ?? this.animateEntrance,
      isLottie: isLottie ?? this.isLottie,
    );
  }

  factory ChallengeHintConfig.disabled() {
    return const ChallengeHintConfig(enabled: false);
  }

  static Map<ChallengeType, String> get defaultAssetPaths => {
        ChallengeType.blink: 'assets/gif/blink.gif',
        ChallengeType.smile: 'assets/gif/smile.gif',
        ChallengeType.nod: 'assets/gif/nod.gif',
        ChallengeType.turnLeft: 'assets/gif/rotate_left.gif',
        ChallengeType.turnRight: 'assets/gif/rotate_right.gif',
      };
}