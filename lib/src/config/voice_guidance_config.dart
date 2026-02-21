/// Configuration for the voice guidance / text-to-speech feature.
///
/// Pass an instance to [LivenessConfig.voiceGuidance] to enable spoken
/// instructions during liveness verification.
///
/// ```dart
/// LivenessConfig(
///   voiceGuidance: VoiceGuidanceConfig(
///     enabled: true,
///     language: 'en-US',
///   ),
/// )
/// ```
class VoiceGuidanceConfig {
  /// Master switch. When `false` no TTS is initialised and no speech occurs.
  final bool enabled;

  /// BCP-47 language / locale code passed to the device TTS engine.
  ///
  /// Examples: `'en-US'`, `'en-GB'`, `'fr-FR'`, `'pt-BR'`, `'es-ES'`.
  /// Falls back to the device default when the requested locale is unavailable.
  final String language;

  /// Playback volume, clamped 0.0–1.0. Defaults to `1.0` (full volume).
  final double volume;

  /// Speech rate passed to `flutter_tts`, clamped 0.0–1.0.
  /// `0.5` is the normal pace on most engines. Lower values are slower.
  final double speechRate;

  /// Pitch multiplier passed to `flutter_tts`, clamped 0.5–2.0.
  /// `1.0` is the default pitch. Values above 1.0 are higher-pitched.
  final double pitch;

  /// Whether to speak face-centering guidance messages such as
  /// "Move closer", "Move right", etc. These fire at ~30 fps so they are
  /// automatically debounced by [repeatInterval].
  final bool speakPositioningFeedback;

  /// Whether to speak each challenge instruction when the challenge starts
  /// (e.g. "Please blink your eyes", "Please turn left").
  final bool speakChallengeInstructions;

  /// Whether to speak the final result message ("Liveness verification
  /// complete!" or "Potential spoofing detected.").
  final bool speakCompletion;

  /// Minimum duration before the SAME message is spoken again.
  ///
  /// Prevents the TTS engine from being flooded by repeated centering
  /// messages while the user is adjusting their position. Defaults to 3 s.
  final Duration repeatInterval;

  const VoiceGuidanceConfig({
    this.enabled = true,
    this.language = 'en-US',
    this.volume = 1.0,
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.speakPositioningFeedback = true,
    this.speakChallengeInstructions = true,
    this.speakCompletion = true,
    this.repeatInterval = const Duration(seconds: 3),
  });

  /// Returns a copy of this config with the given fields replaced.
  VoiceGuidanceConfig copyWith({
    bool? enabled,
    String? language,
    double? volume,
    double? speechRate,
    double? pitch,
    bool? speakPositioningFeedback,
    bool? speakChallengeInstructions,
    bool? speakCompletion,
    Duration? repeatInterval,
  }) {
    return VoiceGuidanceConfig(
      enabled: enabled ?? this.enabled,
      language: language ?? this.language,
      volume: volume ?? this.volume,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      speakPositioningFeedback:
          speakPositioningFeedback ?? this.speakPositioningFeedback,
      speakChallengeInstructions:
          speakChallengeInstructions ?? this.speakChallengeInstructions,
      speakCompletion: speakCompletion ?? this.speakCompletion,
      repeatInterval: repeatInterval ?? this.repeatInterval,
    );
  }

  /// Minimal preset: only challenge instructions and completion are spoken;
  /// continuous positioning feedback is disabled.
  factory VoiceGuidanceConfig.minimal() => const VoiceGuidanceConfig(
        speakPositioningFeedback: false,
      );

  /// Preset tuned for accessibility: slower speech, all feedback enabled.
  factory VoiceGuidanceConfig.accessibility() => const VoiceGuidanceConfig(
        speechRate: 0.4,
        repeatInterval: Duration(seconds: 2),
      );
}
