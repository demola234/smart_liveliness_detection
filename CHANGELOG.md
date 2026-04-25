# Changelog
## Version 0.3.6 - April 25, 2026
* Minor bug fixes and stability improvements

## Version 0.3.5 - April 19, 2026

### New Features

#### 3D Depth Detection (iOS TrueDepth / ARKit)
* Added `DepthDetectionConfig` — opt-in configuration with `depthThreshold` (metres), `requireTrueDepth`, `failSessionOnSpoofing`, and `minFramesRequired`
* Added `DepthDetectionResult` model with `depthStdDev`, `depthVariance`, `confidence`, `vertexCount`, and `isTrueDepthAvailable`
* Added `DepthDetectionService` — Dart platform-channel wrapper; no-ops gracefully on Android and unsupported iOS devices
* Added iOS native plugin (`DepthDetectionPlugin.swift`) using `ARFaceTrackingConfiguration` — measures Z-axis standard deviation across the ARKit face mesh (~1 220 vertices) to distinguish real 3-D faces from flat photos and screen replays
* Added `SmartLivelinessDetectionPlugin.swift` root registrar and `ios/smart_liveliness_detection.podspec`
* Depth session runs in parallel with challenges — no extra liveness phase
* Result added to `antiSpoofingDetection` metadata as `depthSpoofDetected: bool`
* `LivenessController.lastDepthResult` getter exposes the most recent result
* Package converted to Flutter plugin (`flutter.plugin` section in `pubspec.yaml`)

#### Biometric Template Generation
* Added `TemplateConfig` — selects `BiometricAlgorithm` (currently `geometricRatios`) and optional XOR obfuscation key
* Added `BiometricTemplate` model with `encodedVector` (base64), `rawVector`, `algorithm`, `sessionId`, `createdAt`, `featureCount`
* Added `BiometricTemplateService` — extracts ~27 normalised geometric features from ML Kit face landmarks (positions + inter-landmark ratios), serialises to `Float32List` → bytes → base64 with optional XOR obfuscation
* Added `BiometricMatcher` utility — `compare()` returns cosine similarity 0.0–1.0; `isMatch()` applies a threshold
* New `LivenessConfig` fields:
  * `generateBiometricTemplate` (default `false`) — opt-in flag
  * `templateConfig` — algorithm and obfuscation settings
  * `referenceTemplate` — previously enrolled template to match against
  * `biometricMatchThreshold` (default `0.80`) — cosine similarity pass threshold
* New `onBiometricTemplateGenerated` callback on `LivenessDetectionScreen` and `LivenessController`
* When `referenceTemplate` is set, `biometricMatchScore` and `biometricMatchPassed` are injected into `onLivenessCompleted` metadata
* Template generation is privacy-first: no raw pixel data stored, one-way conversion

### Dependency Updates
* `camera` → `^0.12.0+1`
* `camera_android` → `^0.10.10+16`
* `google_mlkit_face_detection` → `^0.13.2`
* `sensors_plus` → `^7.0.0`
* `flutter_tts` → `^4.2.5`
* `uuid` → `^4.5.3`
* `cupertino_icons` → `^1.0.9`
* `flutter_lints` → `^6.0.0`
* `mockito` → `^5.6.4`
* `build_runner` → `^2.13.1`
* Removed `dartdoc` dev dependency (conflicts with `mockito ≥5.6.4` analyzer constraint; pub.dev generates docs server-side)

### Other
* Fixed stale example code that had leaked into `lib/main.dart` and removed it
* Example app: added "3D Depth Detection", "Biometric Template — Enroll", and "Biometric Template — Verify" demo screens
* Added dartdoc comments to all `Assets` constants for pub.dev documentation scoring
* Moved example entry point to `example/lib/main.dart` (pub.dev canonical location)

---

## Version 0.3.4 - April 19, 2026

### New Features

#### Face Quality Scoring
* Added `FaceQualityResult` model with an overall score (0–100) and per-metric breakdown: `brightness`, `sharpness`, `headPose`, `faceSize`, `eyeOpenness`
* Added `FaceQualityService` — lightweight pixel-sampling analysis that runs on every 10th face-detected frame to avoid jank
* New `onFaceQualityCheck` callback on `LivenessDetectionScreen` — fires with each quality result so apps can surface feedback to the user
* New `LivenessConfig` fields:
  * `enableFaceQualityScoring` (default `false`) — opt-in flag
  * `minFaceQualityScore` (default `60.0`) — score threshold used when blocking is enabled
  * `blockChallengesOnLowQuality` (default `false`) — when `true`, session stays in centering phase until quality score meets the threshold
* New `LivenessMessages.lowFaceQuality` — customisable message shown when score is too low
* `LivenessController.lastQualityResult` getter exposes the most recent `FaceQualityResult`

#### Screen Flash Anti-Spoofing
* Added `ScreenFlashConfig` — configurable RGB flash test that runs between face centering and the first challenge
* Added `ScreenFlashResult` model with `passed`, `colorDeltas` (per-color luminance response vs baseline), `baselineLuminance`, and `confidence`
* Added `ScreenFlashService` — internal state machine: baseline → flashRed → flashGreen → flashBlue → done
* Full-screen colored overlay rendered automatically during the test via `LivenessController.activeFlashColor` getter
* Camera exposure is locked (`ExposureMode.locked`) for the duration of the flash test to prevent AEC from cancelling the signal, then restored automatically
* Configurable warmup frames per color (`warmupFramesPerColor`, default `2`) — skips early frames while screen and camera settle
* New `LivenessConfig.screenFlash: ScreenFlashConfig?` — null by default (opt-in)
* New `LivenessState.screenFlashTest` — inserted between `centeringFace` and `performingChallenges`
* Flash result included in `antiSpoofingDetection` metadata as `screenFlashSpoofDetected: bool`
* New `LivenessMessages` fields: `screenFlashInstruction`, `screenFlashSpoofingDetected`
* `failSessionOnSpoofing` flag controls whether a failed flash test ends the session or just sets the metadata flag

## Version 0.3.2 - February 21, 2026
* Patch: Version bump and minor stability improvements

## Version 0.3.1 - February 21, 2026
### Bug Fixes
* Fixed a critical bug in `VoiceGuidanceService` where TTS would attempt to speak even when not initialized, causing crashes on some devices. Added a guard clause to prevent any TTS operations if the service is not properly initialized.
* Resolved head turning challenges not resetting the session correctly when the face was not detected, ensuring a more consistent user experience.
* Improved error handling in the camera service to prevent crashes when the camera feed is interrupted or unavailable.

## Version 0.3.0 - February 21, 2026

### New Features

#### Voice Guidance & Accessibility
* Added `VoiceGuidanceConfig` — fully configurable TTS settings (language, volume, speech rate, pitch, repeat interval)
* Added `VoiceGuidanceService` — debounced TTS wrapper built on `flutter_tts` that prevents audio flooding from ~30 fps camera callbacks
* Voice guidance speaks: initial instruction, face centering feedback, each challenge instruction, and completion/failure result
* Fine-grained control flags: `speakPositioningFeedback`, `speakChallengeInstructions`, `speakCompletion`
* Two convenience presets: `VoiceGuidanceConfig.minimal()` (no centering speech) and `VoiceGuidanceConfig.accessibility()` (slower rate, shorter repeat interval)
* Exported `VoiceGuidanceConfig` from the top-level package barrel
* Zero overhead when disabled — `VoiceGuidanceService` is only instantiated when `voiceGuidance?.enabled == true`

#### Futuristic UI Painter Styles
* Added 13 new animated canvas overlay painter styles selectable via `LivenessStyle` enum:
  * `quantum` — pulsing energy rings with particle scatter effect
  * `liquidMetal` — flowing chrome shimmer with metallic sheen
  * `cosmos` — deep-space star field with nebula gradient
  * `hologram` — cyan holographic scan lines and grid
  * `singularity` — gravitational lens distortion vortex
  * `synapse` — neural network node-and-edge animation
  * `kinetic` — motion-blur speed lines and momentum trails
  * `prism` — rainbow light refraction prismatic effect
  * `obsidian` — volcanic glass dark sheen with ember glow
  * `monolith` — stark geometric brutalist framing
  * `chronos` — clockwork gears and time-dial overlay
  * `floating` — soft levitating bubble particles
  * `sumi` — Japanese ink-wash calligraphic brushwork

#### Futuristic Oval Overlay (`FuturisticOvalOverlay`)
* Style-matched animated oval face frame with per-style border color, glow, and corner HUD brackets
* Rotating progress ring that fills as liveness challenges are completed
* Animated scan-line sweep across the face region

#### Liveness Style Picker (`LivenessStylePicker`)
* New bottom-sheet widget for switching painter styles at runtime
* Live animated mini-previews of all 13 styles rendered inside the picker

#### Challenge Hint Widget Enhancements
* Added `ChallengeHintStyle` enum with 5 visual styles: `plain`, `glass`, `futuristic`, `minimal`, `neon`
* Added `ChallengeHintAnimation` enum with 4 entrance animations: `scaleIn`, `slideUp`, `bounceIn`, `flipIn`
* Hint widget now respects both style and animation on every challenge transition

### Dependencies
* Added `flutter_tts: ^4.2.0`

### Platform Setup
* **Android**: Added `android.intent.action.TTS_SERVICE` `<queries>` intent to `AndroidManifest.xml` for Android 11+ package visibility
* **iOS**: Configured `AVAudioSession` with `.playback` category and `.mixWithOthers` option in `AppDelegate.swift` so TTS audio is heard even when the ring/silent switch is off

---

## Version 0.2.3 - November 26, 2025
* Bug fixing and improvements:
* - Minor bug fixes
## Version 0.2.2- November 25, 2025
* Improvement and new features:
* - Challenge hint animations: Display GIF/Lottie animations to guide users through challenges
* - Customizable hint positions: Choose from multiple positions (top center, bottom center, corners)
* - Per-challenge hint configuration: Configure hints individually for each challenge type
* - Optional custom animations: Users can provide their own GIF or Lottie files
* - Flexible hint display: Enable/disable hints globally or per challenge
* - Default hint animations: Built-in GIFs for blink, smile, nod, and head rotation challenges

## Version 0.2.1- November 24, 2025
* Bug fixing, improvements and new features:

- This version has several improvements in anti-spoofing techniques:

- Anti-Spoofing Result Map
- Screen Glare Detection
- Motion Correlation Check
- Face Contour Analysis (Mask Detection)
- Details:
- Bug fixing: Ignoring wrong error message (errorProcessing) after session.isComplete. 
- Bug fixing: Fixing glare detection method and adding option to enable/disable it. 
- Improving verifyMotionCorrelation method. Now checking both X and Y axes. 
- Adding params to enable/disable motion correlation detection. 
- Adding mask detection feature by detection face contours (The user can choose to enable/disable this feature, as well as the number of contours detected. The user can also choose which types of challenges will be checked). 
- Anti-spoofing settings: Screen reflection detection and missing facial contour detection no longer block liveness detection. 
- Anti-spoofing detection is configured in the metadata under antiSpoofingDetection flags (Anti-Spoofing Result Map), without preventing successful results.

## Version 0.2.0 - October 25, 2025
* Added support for new liveness challenges: "Raise Eyebrows" and "Open Mouth"
* Improved face detection accuracy with updated ML models
* Enhanced UI customization options for better theming
* Fixed minor bugs and improved overall performance

## 0.1.3 - April 25, 2025
* Google ML Kit upgraded to version 0.11.0
* Bug fixes and improvements

## 0.1.1 - April 24, 2025
* Bug fixes and improvements

## 0.1.0 - April 24, 2025
* Bug fixes and improvements
* Android fix initialization fix


## 0.0.1-beta.5 - April 23, 2025
* Bug fixes and improvements
* Android fix initialization fix


## 0.0.1 - Initial Release (April 15, 2025)

* Initial release of the Face Liveness Detection package
* Features included:
  * Multiple liveness challenge types (blinking, smiling, head turns, nodding)
  * Random challenge sequence generation
  * Face centering guidance with visual feedback
  * Anti-spoofing measures
  * Customizable UI with theming support
  * Animated progress indicators and overlays
  * Optional image capture capability

  