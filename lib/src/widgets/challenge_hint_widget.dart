import 'package:flutter/material.dart';
import 'package:smart_liveliness_detection/src/config/challenge_hint_config.dart';
import 'package:smart_liveliness_detection/src/utils/enums.dart';

class ChallengeHintWidget extends StatefulWidget {
  final ChallengeType challengeType;

  final ChallengeHintConfig config;

  final String? customAssetPath;

  final bool? customIsLottie;

  const ChallengeHintWidget({
    super.key,
    required this.challengeType,
    required this.config,
    this.customAssetPath,
    this.customIsLottie,
  });

  @override
  State<ChallengeHintWidget> createState() => _ChallengeHintWidgetState();
}

class _ChallengeHintWidgetState extends State<ChallengeHintWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _slide;
  late Animation<double> _flipX;
  bool _isLottieAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkLottieAvailability();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );

    _scale = switch (widget.config.hintAnimation) {
      ChallengeHintAnimation.scaleIn => TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.12), weight: 55),
          TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 45),
        ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      ChallengeHintAnimation.bounceIn => TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.28), weight: 38),
          TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.88), weight: 24),
          TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.06), weight: 22),
          TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 16),
        ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear)),
      _ => Tween<double>(begin: 1.0, end: 1.0).animate(_controller),
    };

    _slide = switch (widget.config.hintAnimation) {
      ChallengeHintAnimation.slideUp => Tween<double>(begin: 48.0, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
      _ => Tween<double>(begin: 0.0, end: 0.0).animate(_controller),
    };

    _flipX = switch (widget.config.hintAnimation) {
      ChallengeHintAnimation.flipIn => TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 65),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 35),
        ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      _ => Tween<double>(begin: 1.0, end: 1.0).animate(_controller),
    };

    if (widget.config.animateEntrance) {
      _controller.forward();
      Future.delayed(widget.config.displayDuration, () {
        if (mounted) _controller.reverse();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  void _checkLottieAvailability() {
    try {
      final isLottie = widget.customIsLottie ?? widget.config.isLottie;
      if (isLottie) {
        setState(() => _isLottieAvailable = true);
      }
    } catch (_) {
      setState(() => _isLottieAvailable = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _getAssetPath() {
    if (widget.customAssetPath != null) return widget.customAssetPath;
    return ChallengeHintConfig.defaultAssetPaths[widget.challengeType];
  }

  // ── Styled containers ──────────────────────────────────────────────────────

  Widget _buildStyledContainer(Widget inner) {
    final size = widget.config.size;
    final accent = widget.config.accentColor ?? const Color(0xFF00D4FF);

    return switch (widget.config.hintStyle) {
      ChallengeHintStyle.plain => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: inner),
        ),

      ChallengeHintStyle.glass => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: inner),
        ),

      ChallengeHintStyle.futuristic => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.75), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: inner),
        ),

      ChallengeHintStyle.minimal => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.85), width: 2.0),
          ),
          padding: const EdgeInsets.all(6),
          child: ClipOval(child: inner),
        ),

      ChallengeHintStyle.neon => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.65),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
                blurRadius: 44,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: inner),
        ),
    };
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildHintContent() {
    final assetPath = _getAssetPath();
    if (assetPath == null) return const SizedBox.shrink();

    final isLottie = widget.customIsLottie ?? widget.config.isLottie;

    final inner = (isLottie && _isLottieAvailable)
        ? const Center(child: Icon(Icons.animation, color: Colors.grey))
        : Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.help_outline, color: Colors.grey)),
          );

    return _buildStyledContainer(inner);
  }

  // ── Animation wrapper ─────────────────────────────────────────────────────

  Widget _applyAnimation(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        Widget result = child;

        switch (widget.config.hintAnimation) {
          case ChallengeHintAnimation.scaleIn:
          case ChallengeHintAnimation.bounceIn:
            result = Transform.scale(scale: _scale.value, child: result);
          case ChallengeHintAnimation.slideUp:
            result = Transform.translate(
              offset: Offset(0, _slide.value),
              child: result,
            );
          case ChallengeHintAnimation.flipIn:
            result = Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(_flipX.value, 1.0, 1.0),
              child: result,
            );
        }

        return Opacity(opacity: _opacity.value.clamp(0.0, 1.0), child: result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.enabled) return const SizedBox.shrink();

    final content = _buildHintContent();

    if (widget.config.animateEntrance) {
      return _applyAnimation(content);
    }

    return content;
  }
}

extension ChallengeHintPositioning on ChallengeHintPosition {
  Positioned positionWidget(Widget child, MediaQueryData mediaQuery, {bool showAppBar = true}) {
    final topPadding = (showAppBar ? kToolbarHeight : 0) + mediaQuery.padding.top + 80;
    final bottomPadding = mediaQuery.padding.bottom + 120;

    switch (this) {
      case ChallengeHintPosition.topCenter:
        return Positioned(top: topPadding, left: 0, right: 0, child: Center(child: child));
      case ChallengeHintPosition.bottomCenter:
        return Positioned(bottom: bottomPadding, left: 0, right: 0, child: Center(child: child));
      case ChallengeHintPosition.topLeft:
        return Positioned(top: topPadding, left: 20, child: child);
      case ChallengeHintPosition.topRight:
        return Positioned(top: topPadding, right: 20, child: child);
      case ChallengeHintPosition.bottomLeft:
        return Positioned(bottom: bottomPadding, left: 20, child: child);
      case ChallengeHintPosition.bottomRight:
        return Positioned(bottom: bottomPadding, right: 20, child: child);
    }
  }
}
