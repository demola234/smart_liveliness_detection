# Changelog
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

  