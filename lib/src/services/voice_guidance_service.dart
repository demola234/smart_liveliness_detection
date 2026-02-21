import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smart_liveliness_detection/src/config/voice_guidance_config.dart';

/// Internal service that wraps [FlutterTts] and applies debouncing so that
/// the same message is not repeated more often than [VoiceGuidanceConfig.repeatInterval].
///
/// This service is created and owned by [LivenessController]; consumers do not
/// interact with it directly — they configure voice behaviour via
/// [VoiceGuidanceConfig] in [LivenessConfig].
class VoiceGuidanceService {
  final VoiceGuidanceConfig config;

  final FlutterTts _tts = FlutterTts();

  String _lastMessage = '';
  DateTime _lastSpokenAt = DateTime(0);
  bool _initialized = false;

  VoiceGuidanceService({required this.config});

  /// Initialise the TTS engine with the values from [config].
  /// Must be called before [speak].
  Future<void> initialize() async {
    try {
      // Apply settings — failures here are non-fatal; we still attempt to speak.
      await _tts.setLanguage(config.language);
      await _tts.setVolume(config.volume.clamp(0.0, 1.0));
      await _tts.setSpeechRate(config.speechRate.clamp(0.0, 1.0));
      await _tts.setPitch(config.pitch.clamp(0.5, 2.0));
      // Prevent speech from blocking the caller on Android.
      await _tts.awaitSpeakCompletion(false);
    } catch (e) {
      debugPrint('VoiceGuidanceService: TTS init warning — $e');
    }
    // Mark ready regardless: individual speak() calls handle their own errors.
    _initialized = true;
  }

  /// Speaks [text] unless it is the same message spoken within
  /// [VoiceGuidanceConfig.repeatInterval].
  ///
  /// A different [text] always interrupts and replaces whatever is currently
  /// being spoken.
  Future<void> speak(String text) async {
    if (!_initialized || text.trim().isEmpty) return;

    final now = DateTime.now();
    final sameMessage = text == _lastMessage;
    final tooSoon = now.difference(_lastSpokenAt) < config.repeatInterval;

    if (sameMessage && tooSoon) return;

    // Track state before the async gap so debounce still works even if speak()
    // is slow.
    _lastMessage = text;
    _lastSpokenAt = now;

    try {
      // Do NOT call stop() before speak() — on Android this can cancel the
      // incoming utterance before the engine has a chance to queue it.
      await _tts.speak(text);
    } catch (e) {
      debugPrint('VoiceGuidanceService: speak error — $e');
    }
  }

  /// Immediately stops any ongoing speech.
  Future<void> stop() async {
    if (!_initialized) return;
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('VoiceGuidanceService: stop error — $e');
    }
  }

  /// Stops speech and releases TTS resources.
  Future<void> dispose() async {
    await stop();
  }
}
