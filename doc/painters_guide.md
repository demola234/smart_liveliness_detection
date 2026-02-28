# Futuristic Painters — UI Customisation Guide

The `smart_liveliness_detection` package ships **14 `CustomPainter` classes** that let you build richly animated faces for the liveness-detection UI without touching the core detection logic.

---

## Table of Contents

1. [Painter overview](#1-painter-overview)
2. [FuturisticTheme — colour system](#2-futuristictheme--colour-system)
3. [Painter parameter reference](#3-painter-parameter-reference)
4. [Using a painter as a progress bar](#4-using-a-painter-as-a-progress-bar)
5. [Using a painter as a full-width background](#5-using-a-painter-as-a-full-width-background)
6. [Connecting painters to the liveness controller](#6-connecting-painters-to-the-liveness-controller)
7. [Per-painter effect toggles & custom colours](#7-per-painter-effect-toggles--custom-colours)
8. [Painter gallery & design intent](#8-painter-gallery--design-intent)
9. [Complete integration example](#9-complete-integration-example)

---

## 1. Painter overview

| Class | Visual character | Best used as |
|---|---|---|
| `QuantumPainter` | Magnetic shape deformation + neon border | Progress bar |
| `LiquidMetalPainter` | "Pizza cheese" edge morphing + chrome shine | Progress bar |
| `CosmosPainter` | Parallax starfield + nebula | Background / progress bar |
| `HologramPainter` | Scanlines + iridescent shimmer | Progress bar |
| `SingularityPainter` | Warped spacetime grid + black hole | Background |
| `SynapsePainter` | Neural nodes + data filaments | Progress bar |
| `KineticPainter` | Tile shingle physics | Progress bar |
| `PrismPainter` | Chromatic dispersion rays | Progress bar |
| `ObsidianPainter` | Matte black + violet glow pod | Progress bar |
| `MonolithPainter` | Razor slit on matte black | Progress bar |
| `ChronosPainter` | Mechanical gears + tick marks | Progress bar |
| `FloatingPainter` | Frosted glass levitation | Progress bar |
| `SumiPainter` | Japanese ink-wash on paper | Progress bar |
| `BackgroundGlowPainter` | Pulsing radial glow cloud | Overlay / background |

---

## 2. FuturisticTheme — colour system

Every painter takes a `FuturisticTheme` that defines four colours / gradients.

```dart
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

// Use a built-in preset:
const theme = FuturisticTheme.quantum;

// Or build a custom theme:
const theme = FuturisticTheme(
  accentColor: Color(0xFF00FF88),    // glow, indicator, active element
  baseColor: Color(0xFF0D1117),      // bar fill
  backgroundColor: Color(0xFF060A0F), // deep background
  glowGradient: LinearGradient(      // secondary glow layers (≥ 2 colors)
    colors: [Color(0xFF00FF88), Color(0xFF7B26F7)],
  ),
);
```

### Built-in presets

| Preset constant | Palette description |
|---|---|
| `FuturisticTheme.quantum` | Electric cyan + deep violet |
| `FuturisticTheme.cosmos` | Deep-space blue + nebula purple |
| `FuturisticTheme.hologram` | Iridescent cyan + magenta |
| `FuturisticTheme.singularity` | Gravitational gold on void black |
| `FuturisticTheme.synapse` | Bio-electric green + ocean blue |
| `FuturisticTheme.kinetic` | Electric orange + gold |
| `FuturisticTheme.liquidMetal` | Chrome silver + cyan shimmer |
| `FuturisticTheme.prism` | Crystal white + violet |
| `FuturisticTheme.sumi` | Ink black + crimson seal (light bg) |
| `FuturisticTheme.monolith` | Razor white on matte black |
| `FuturisticTheme.obsidian` | Violet glow on obsidian |
| `FuturisticTheme.chronos` | Amber mechanical on charcoal |
| `FuturisticTheme.floating` | Soft blue on frosted dark |

---

## 3. Painter parameter reference

Most painters share the same core signature:

| Parameter | Type | Description |
|---|---|---|
| `animationValue` | `double` | Continuous index of the *active* item (0 → count-1). Drive this with an `AnimationController`. |
| `count` | `int` | Total number of items (challenges) in the bar. |
| `idleTime` | `double` | Elapsed seconds; used for looping idle effects (gear rotation, star drift, etc.). |
| `theme` | `FuturisticTheme` | Colour configuration. |
| `pressValue` | `double` | 0 → 1 impact animation played when a challenge completes. |
| `customColors` | `Map<String, Color>` | Override individual named colours (see §7). |
| `effectToggles` | `Map<String, bool>` | Enable / disable individual visual layers (see §7). |

`QuantumPainter` and `LiquidMetalPainter` use `progress` / `totalItems` instead of `animationValue` / `count` — same semantics, different names.

`BackgroundGlowPainter` uses `activeX`, `totalItems`, `pulse`, `rotation`.

`ObsidianPainter` adds `glowStrength` (default `1.0`).

---

## 4. Using a painter as a progress bar

Wrap any painter in a `CustomPaint` inside an `AnimatedBuilder`:

```dart
class LivenessChallengeBar extends StatefulWidget {
  final int challengeCount;
  final int currentChallenge;

  const LivenessChallengeBar({
    super.key,
    required this.challengeCount,
    required this.currentChallenge,
  });

  @override
  State<LivenessChallengeBar> createState() => _LivenessChallengeBarState();
}

class _LivenessChallengeBarState extends State<LivenessChallengeBar>
    with TickerProviderStateMixin {
  late final AnimationController _move;   // slides between challenge slots
  late final AnimationController _idle;   // drives looping idle effects
  late final AnimationController _press;  // one-shot impact burst

  @override
  void initState() {
    super.initState();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _idle = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void didUpdateWidget(LivenessChallengeBar old) {
    super.didUpdateWidget(old);
    if (widget.currentChallenge != old.currentChallenge) {
      // Slide to new slot and fire impact burst
      _move.animateTo(
        widget.currentChallenge.toDouble(),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _press
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _idle.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _idle, _press]),
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 60),
          painter: QuantumPainter(           // ← swap any painter here
            progress: _move.value,
            totalItems: widget.challengeCount,
            idleTime: _idle.value * 60,
            theme: FuturisticTheme.quantum,
            pressValue: CurvedAnimation(
              parent: _press,
              curve: Curves.easeOut,
            ).value,
          ),
        );
      },
    );
  }
}
```

### Swapping painters at runtime

Since every painter takes the same parameters you can swap them with a simple variable:

```dart
CustomPainter _buildPainter(String style, double progress, double idle, double press) {
  final theme = FuturisticTheme.quantum;
  return switch (style) {
    'cosmos'      => CosmosPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.cosmos, pressValue: press),
    'hologram'    => HologramPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.hologram, pressValue: press),
    'synapse'     => SynapsePainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.synapse, pressValue: press),
    'kinetic'     => KineticPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.kinetic, pressValue: press),
    'sumi'        => SumiPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.sumi, pressValue: press),
    'monolith'    => MonolithPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.monolith, pressValue: press),
    'chronos'     => ChronosPainter(animationValue: progress, count: 4, idleTime: idle, theme: FuturisticTheme.chronos, pressValue: press),
    'liquidMetal' => LiquidMetalPainter(progress: progress, totalItems: 4, squash: press, theme: FuturisticTheme.liquidMetal),
    _             => QuantumPainter(progress: progress, totalItems: 4, idleTime: idle, theme: theme, pressValue: press),
  };
}
```

---

## 5. Using a painter as a full-width background

`SingularityPainter`, `CosmosPainter`, and `BackgroundGlowPainter` work well as full-screen or camera-overlay backgrounds.

```dart
Stack(
  fit: StackFit.expand,
  children: [
    // Camera preview sits below
    CameraPreview(cameraController),

    // Background effect overlaid at the bottom
    Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _idle,
        builder: (_, __) => CustomPaint(
          size: const Size(double.infinity, 120),
          painter: SingularityPainter(
            animationValue: _move.value,
            count: widget.challengeCount,
            idleTime: _idle.value * 60,
            theme: FuturisticTheme.singularity,
            effectToggles: const {'showGrid': true, 'showHole': true, 'showAura': true},
          ),
        ),
      ),
    ),

    // Oval guide + instruction widgets on top …
  ],
)
```

### BackgroundGlowPainter — ambient glow that tracks the active item

```dart
CustomPaint(
  painter: BackgroundGlowPainter(
    activeX: _move.value * itemWidth + itemWidth / 2,
    totalItems: widget.challengeCount,
    theme: FuturisticTheme.quantum,
    pulse: _idle.value,           // 0 → 1, repeating
    rotation: _idle.value * 2 * math.pi,
  ),
)
```

---

## 6. Connecting painters to the liveness controller

Listen to `LivenessController` to drive painter animation values:

```dart
class _MyLivenessScreenState extends State<MyLivenessScreen>
    with TickerProviderStateMixin {
  late final LivenessController _liveness;
  late final AnimationController _move;
  late final AnimationController _idle;
  late final AnimationController _press;

  int _completedChallenges = 0;

  @override
  void initState() {
    super.initState();
    _liveness = LivenessController(config: widget.config);
    _move  = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _idle  = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  // Call this from your onChallengeCompleted callback:
  void _onChallengeCompleted(ChallengeType type) {
    setState(() => _completedChallenges++);

    // Slide bar forward
    _move.animateTo(
      _completedChallenges.toDouble(),
      curve: Curves.easeInOutCubic,
    );

    // Fire impact burst
    _press..reset()..forward();
  }

  @override
  Widget build(BuildContext context) {
    final totalChallenges = widget.config.challenges.length;

    return LivelinessDetectionScreen(
      config: widget.config,
      onChallengeCompleted: _onChallengeCompleted,
      progressBarBuilder: (context) => AnimatedBuilder(
        animation: Listenable.merge([_move, _idle, _press]),
        builder: (_, __) => SizedBox(
          height: 64,
          child: CustomPaint(
            painter: KineticPainter(
              animationValue: _move.value,
              count: totalChallenges,
              idleTime: _idle.value * 60,
              theme: FuturisticTheme.kinetic,
              pressValue: CurvedAnimation(parent: _press, curve: Curves.easeOut).value,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Per-painter effect toggles & custom colours

Fine-tune any painter without subclassing by passing `effectToggles` and `customColors` maps.

### QuantumPainter / LiquidMetalPainter

```dart
QuantumPainter(
  // ...
  effectToggles: const {
    'showAura':    true,   // radial aura glow
    'showGhosts':  false,  // energy echo trails
    'showNucleus': true,   // active nucleus highlight
    'showScanLine': true,  // vertical scan sweep
  },
  customColors: {
    'auraColor':            const Color(0xFFFF6B35),
    'ghostColor':           const Color(0xFFFF6B35),
    'nucleusColor':         const Color(0xFFFF6B35),
    'nucleusAccentColor':   const Color(0xFFFF0000),
    'accentColor':          const Color(0xFFFF6B35),
    'secondaryAccentColor': const Color(0xFFFF0000),
    'scanLineColor':        Colors.white,
    'baseColor':            const Color(0xFF1A0A00),
    'baseAccentColor':      const Color(0xFF0D0500),
  },
)
```

### CosmosPainter

```dart
CosmosPainter(
  // ...
  effectToggles: const {
    'showStars':         true,
    'showNebula':        true,
    'showShootingStars': false,
    'showCore':          true,
    'showImpact':        true,
  },
  customColors: {
    'backgroundColor':   const Color(0xFF000510),
    'starColor':         Colors.lightBlue,
    'nebulaColor':       const Color(0xFF5B8CFF),
    'nebulaAccentColor': const Color(0xFF7B26F7),
    'coreColor':         Colors.white,
  },
)
```

### SingularityPainter

```dart
SingularityPainter(
  // ...
  effectToggles: const {
    'showGrid':   true,
    'showHole':   true,
    'showAura':   true,
    'showImpact': true,
  },
  customColors: {
    'gridColor':      Colors.cyan,
    'diskColor':      const Color(0xFFFFC400),
    'diskAccentColor': Colors.purpleAccent,
    'holeColor':      Colors.black,
    'photonRingColor': Colors.white,
    'auraColor':      const Color(0xFFFFC400),
    'impactColor':    Colors.white,
  },
)
```

### SumiPainter (light background)

```dart
SumiPainter(
  // ...
  effectToggles: const {
    'showPaperTexture': true,
    'showInkSplatter':  true,
    'showSeal':         true,
    'showImpact':       true,
  },
  customColors: {
    'paperColor': const Color(0xFFFAF0E6),  // linen
    'inkColor':   const Color(0xFF0D0D0D),
    'sealColor':  const Color(0xFFCC2200),
    'impactColor': Colors.black,
  },
)
```

### ObsidianPainter

```dart
ObsidianPainter(
  // ...
  glowStrength: 1.5,   // amplify the subsurface glow
  effectToggles: const {
    'showGrid':      true,
    'showGlow':      true,
    'showIndicator': true,
    'showImpact':    true,
  },
  customColors: {
    'baseColor':       const Color(0xFF050505),
    'baseAccentColor': const Color(0xFF0F0F0F),
    'gridColor':       Colors.white,
    'glowColor':       const Color(0xFF9B59B6),
    'accentColor':     const Color(0xFF9B59B6),
    'podShadowColor':  Colors.black,
    'podBorderColor':  Colors.white,
    'impactColor':     const Color(0xFF9B59B6),
  },
)
```

---

## 8. Painter gallery & design intent

### QuantumPainter
Physics-inspired. The bar *stretches* and *skews* as it moves between items, simulating inertia. A rotating neon border acts as an active scanner. Best for: high-tech / sci-fi branding.

### LiquidMetalPainter
The bar edges deform organically as it moves — top/bottom bulge, stretch, and pinch like molten chrome. Supports drag offset for pointer tracking. Best for: premium / luxury identity.

### CosmosPainter
Two-layer parallax starfield with volumetric nebula cloud centred on the active item. Shooting stars appear occasionally. Best for: space / exploration themed apps.

### HologramPainter
Horizontal scanlines + iridescent shimmer that shifts colour across the bar. Glitch rectangles fire on impact. Best for: AR / mixed-reality UX.

### SingularityPainter
Draws a warped spacetime grid that bends toward the active position. Includes an accretion disk and photon ring. Best for: dramatic, physics-heavy branding.

### SynapsePainter
Neural nodes sit at each challenge position; energy bridges glow between adjacent active nodes. On impact the bar outline deforms organically. Best for: biometric / health / AI branding.

### KineticPainter
A grid of square tiles physically tilt and jump when the active indicator passes over them. The effect propagates outward from the pointer. Best for: dynamic / sports / energy branding.

### PrismPainter
Crystal-clear bar with chromatic dispersion — separate red / green / blue frames offset on impact. Refraction rays emanate from the active centre. Best for: photography / creative / luxury.

### ObsidianPainter
Austere black with a single coloured subsurface glow pod. Micro-grid texture adds depth without busyness. Best for: security / enterprise / stealth branding.

### MonolithPainter
A razor-thin lit slit on near-black. Minimal, architectural, dramatic. Best for: high-end, minimalist apps.

### ChronosPainter
Brushed-metal base with tick marks and a ticking mechanical gear behind the active indicator. Best for: watch / precision / engineering branding.

### FloatingPainter
The entire bar floats on a sine wave; a translucent shadow beneath moves inversely, amplifying the levitation feel. A frosted-glass border completes the iOS-inspired look. Best for: clean consumer apps.

### SumiPainter
Ink bleeds on Japanese rice paper. An organic ink-bleed shape pulses at the active position. A small red rectangular seal appears in the top-right corner. Best for: cultural / artisanal / wellness branding.

### BackgroundGlowPainter
A large radial glow cloud that pulses and orbits around the active position. Intended as a secondary decorative layer *behind* another painter or behind the camera preview.

---

## 9. Complete integration example

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smart_liveliness_detection/smart_liveliness_detection.dart';

/// Drop-in replacement for the default liveness progress bar.
/// Pick any painter name from the painter gallery above.
class FuturisticProgressBar extends StatefulWidget {
  final int totalChallenges;
  final int currentChallenge;
  final String painterStyle;    // e.g. 'quantum', 'cosmos', 'kinetic' …
  final FuturisticTheme? theme; // override theme; null = auto-pick

  const FuturisticProgressBar({
    super.key,
    required this.totalChallenges,
    required this.currentChallenge,
    this.painterStyle = 'quantum',
    this.theme,
  });

  @override
  State<FuturisticProgressBar> createState() => _FuturisticProgressBarState();
}

class _FuturisticProgressBarState extends State<FuturisticProgressBar>
    with TickerProviderStateMixin {
  late final AnimationController _move;
  late final AnimationController _idle;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _move  = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _idle  = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void didUpdateWidget(FuturisticProgressBar old) {
    super.didUpdateWidget(old);
    if (widget.currentChallenge != old.currentChallenge) {
      _move.animateTo(
        widget.currentChallenge.toDouble(),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
      _press..reset()..forward();
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _idle.dispose();
    _press.dispose();
    super.dispose();
  }

  FuturisticTheme _resolveTheme() {
    if (widget.theme != null) return widget.theme!;
    return switch (widget.painterStyle) {
      'cosmos'      => FuturisticTheme.cosmos,
      'hologram'    => FuturisticTheme.hologram,
      'singularity' => FuturisticTheme.singularity,
      'synapse'     => FuturisticTheme.synapse,
      'kinetic'     => FuturisticTheme.kinetic,
      'liquidMetal' => FuturisticTheme.liquidMetal,
      'prism'       => FuturisticTheme.prism,
      'obsidian'    => FuturisticTheme.obsidian,
      'monolith'    => FuturisticTheme.monolith,
      'chronos'     => FuturisticTheme.chronos,
      'floating'    => FuturisticTheme.floating,
      'sumi'        => FuturisticTheme.sumi,
      _             => FuturisticTheme.quantum,
    };
  }

  CustomPainter _buildPainter(double move, double idle, double press) {
    final n     = widget.totalChallenges;
    final theme = _resolveTheme();

    return switch (widget.painterStyle) {
      'cosmos'      => CosmosPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'hologram'    => HologramPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'singularity' => SingularityPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'synapse'     => SynapsePainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'kinetic'     => KineticPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'liquidMetal' => LiquidMetalPainter(progress: move, totalItems: n, squash: press, theme: theme),
      'prism'       => PrismPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'obsidian'    => ObsidianPainter(animationValue: move, count: n, theme: theme, pressValue: press),
      'monolith'    => MonolithPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'chronos'     => ChronosPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'floating'    => FloatingPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      'sumi'        => SumiPainter(animationValue: move, count: n, idleTime: idle, theme: theme, pressValue: press),
      _             => QuantumPainter(progress: move, totalItems: n, idleTime: idle, theme: theme, pressValue: press),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _idle, _press]),
      builder: (_, __) {
        final press = CurvedAnimation(parent: _press, curve: Curves.easeOut).value;
        return SizedBox(
          height: 64,
          child: CustomPaint(
            size: Size.infinite,
            painter: _buildPainter(_move.value, _idle.value * 60, press),
          ),
        );
      },
    );
  }
}
```

### Usage in your app

```dart
LivelinessDetectionScreen(
  config: myConfig,
  onChallengeCompleted: (type) { /* ... */ },
  // Override the built-in progress bar:
  progressBarBuilder: (context) => FuturisticProgressBar(
    totalChallenges: myConfig.challenges.length,
    currentChallenge: _completedCount,
    painterStyle: 'kinetic',           // change to any painter name
    theme: FuturisticTheme.kinetic.copyWith(
      accentColor: Colors.deepOrange,  // brand override
    ),
  ),
);
```
