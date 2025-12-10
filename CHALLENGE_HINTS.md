# Challenge Hints Feature

The Challenge Hints feature allows you to display animated GIFs or Lottie files during liveness challenges to guide users on what action they need to perform.

## Features

- Display hint animations for each challenge type
- Customizable positioning (top center, bottom center, corners)
- Per-challenge configuration
- Support for both GIF and Lottie files
- Optional custom animations from users
- Built-in default animations for common challenges

## Quick Start

### Enable Default Hints

To use the built-in hint animations with default settings:

```dart
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

LivenessDetectionScreen(
  cameras: cameras,
  config: LivenessConfig(
    defaultChallengeHintConfig: ChallengeHintConfig(
      enabled: true,
      position: ChallengeHintPosition.topCenter,
      size: 100.0,
      displayDuration: Duration(seconds: 2),
    ),
  ),
);
```

### Configure Hints Per Challenge

To configure different hints for specific challenge types:

```dart
LivenessConfig(
  challengeHints: {
    ChallengeType.blink: ChallengeHintConfig(
      enabled: true,
      position: ChallengeHintPosition.topCenter,
      size: 120.0,
    ),
    ChallengeType.smile: ChallengeHintConfig(
      enabled: true,
      position: ChallengeHintPosition.bottomCenter,
      size: 100.0,
    ),
    ChallengeType.turnLeft: ChallengeHintConfig(
      enabled: true,
      position: ChallengeHintPosition.topRight,
    ),
  },
  defaultChallengeHintConfig: ChallengeHintConfig(
    enabled: false, // Disable hints for challenges not in the map
  ),
)
```

## Custom Animations

### Using Custom GIF Files

To use your own GIF files:

```dart
ChallengeHintConfig(
  enabled: true,
  assetPath: 'assets/my_custom_animations/blink_hint.gif',
  position: ChallengeHintPosition.topCenter,
  size: 100.0,
)
```

Make sure to add your custom assets to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/my_custom_animations/
```

### Using Lottie Animations (Optional)

If your project has the `lottie` package, you can use Lottie animations:

First, add lottie to your `pubspec.yaml`:

```yaml
dependencies:
  lottie: ^3.0.0  # or latest version
```

Then configure the hint:

```dart
ChallengeHintConfig(
  enabled: true,
  assetPath: 'assets/animations/blink_hint.json',
  isLottie: true,
  position: ChallengeHintPosition.topCenter,
  size: 100.0,
)
```

Note: The Lottie package is optional. If it's not available in your project, the hint will gracefully fall back to displaying a placeholder or the GIF version.

## Configuration Options

### ChallengeHintConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Whether to show the hint |
| `assetPath` | `String?` | `null` | Custom path to GIF/Lottie file. If null, uses default built-in animation |
| `position` | `ChallengeHintPosition` | `ChallengeHintPosition.topCenter` | Where to display the hint on screen |
| `size` | `double` | `100.0` | Size of the hint widget |
| `displayDuration` | `Duration` | `Duration(seconds: 2)` | How long to display the hint |
| `animateEntrance` | `bool` | `true` | Whether to animate the hint entrance |
| `isLottie` | `bool` | `false` | Whether the asset is a Lottie file |

### ChallengeHintPosition Options

- `ChallengeHintPosition.topCenter` - Top center of the screen
- `ChallengeHintPosition.bottomCenter` - Bottom center of the screen
- `ChallengeHintPosition.topLeft` - Top left corner
- `ChallengeHintPosition.topRight` - Top right corner
- `ChallengeHintPosition.bottomLeft` - Bottom left corner
- `ChallengeHintPosition.bottomRight` - Bottom right corner

## Built-in Default Animations

The package includes default GIF animations for the following challenge types:

- `ChallengeType.blink` - Eye blinking animation
- `ChallengeType.smile` - Smiling animation
- `ChallengeType.nod` - Head nodding animation
- `ChallengeType.turnLeft` - Head rotating left animation
- `ChallengeType.turnRight` - Head rotating right animation

## Examples

### Example 1: Simple Configuration

Enable hints for all challenges with default settings:

```dart
LivenessDetectionScreen(
  cameras: cameras,
  config: LivenessConfig(
    defaultChallengeHintConfig: ChallengeHintConfig(),
  ),
);
```

### Example 2: Custom Position and Size

```dart
LivenessDetectionScreen(
  cameras: cameras,
  config: LivenessConfig(
    defaultChallengeHintConfig: ChallengeHintConfig(
      position: ChallengeHintPosition.bottomCenter,
      size: 150.0,
      displayDuration: Duration(seconds: 3),
    ),
  ),
);
```

### Example 3: Mixed Configuration

Use default hints for most challenges, but customize specific ones:

```dart
LivenessDetectionScreen(
  cameras: cameras,
  config: LivenessConfig(
    defaultChallengeHintConfig: ChallengeHintConfig(
      enabled: true,
      position: ChallengeHintPosition.topCenter,
    ),
    challengeHints: {
      ChallengeType.blink: ChallengeHintConfig(
        enabled: true,
        assetPath: 'assets/custom/blink.gif',
        position: ChallengeHintPosition.bottomCenter,
        size: 120.0,
      ),
      ChallengeType.smile: ChallengeHintConfig(
        enabled: false, // Disable hint for smile challenge
      ),
    },
  ),
);
```

### Example 4: Disable All Hints

```dart
LivenessDetectionScreen(
  cameras: cameras,
  config: LivenessConfig(
    defaultChallengeHintConfig: ChallengeHintConfig.disabled(),
  ),
);
```

## Tips

1. Keep hint animations simple and clear
2. Test different positions to find what works best for your UI
3. Consider the hint size relative to your target device screen size
4. Use shorter display durations (1-2 seconds) for quick hints
5. Provide custom animations that match your app's design language

## Troubleshooting

### Hints Not Showing

1. Check that `enabled` is set to `true`
2. Verify that you're in the `performingChallenges` state
3. Ensure the challenge type has a hint configuration
4. Check that the asset path is correct (if using custom assets)

### Custom Assets Not Loading

1. Verify the asset path in `pubspec.yaml`
2. Run `flutter pub get` after adding assets
3. Check that the file path matches exactly (case-sensitive)
4. Ensure the file format is supported (GIF or Lottie JSON)

### Lottie Not Working

1. Confirm the `lottie` package is added to `pubspec.yaml`
2. Run `flutter pub get`
3. Check that `isLottie` is set to `true`
4. Verify the JSON file is a valid Lottie animation

## API Reference

For full API documentation, see the main README or run:

```bash
dart doc .
```