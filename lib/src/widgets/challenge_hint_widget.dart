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
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isLottieAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkLottieAvailability();

    if (widget.config.animateEntrance) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.5, end: 1.1),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.1, end: 1.0),
          weight: 50.0,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );

      _controller.forward();

      Future.delayed(widget.config.displayDuration, () {
        if (mounted) {
          _controller.reverse();
        }
      });
    }
  }

  void _checkLottieAvailability() {
    try {
      final isLottie = widget.customIsLottie ?? widget.config.isLottie;
      if (isLottie) {
        setState(() {
          _isLottieAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLottieAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    if (widget.config.animateEntrance) {
      _controller.dispose();
    }
    super.dispose();
  }

  String? _getAssetPath() {
    if (widget.customAssetPath != null) {
      return widget.customAssetPath;
    }

    return ChallengeHintConfig.defaultAssetPaths[widget.challengeType];
  }

  Widget _buildHintContent() {
    final assetPath = _getAssetPath();

    if (assetPath == null) {
      return const SizedBox.shrink();
    }

    final isLottie = widget.customIsLottie ?? widget.config.isLottie;

    if (isLottie && _isLottieAvailable) {
      return _buildLottieAnimation(assetPath);
    } else {
      return _buildGifImage(assetPath);
    }
  }

  Widget _buildGifImage(String assetPath) {
    return Container(
      width: widget.config.size,
      height: widget.config.size,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: widget.config.size,
          height: widget.config.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.help_outline,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLottieAnimation(String assetPath) {
    try {
      return Container(
        width: widget.config.size,
        height: widget.config.size,
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
        child: const Center(
          child: Icon(
            Icons.animation,
            color: Colors.grey,
          ),
        ),
      );
    } catch (e) {
      return _buildGifImage(assetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.enabled) {
      return const SizedBox.shrink();
    }

    final content = _buildHintContent();

    if (widget.config.animateEntrance) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: content,
            ),
          );
        },
      );
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
        return Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          child: Center(child: child),
        );
      case ChallengeHintPosition.bottomCenter:
        return Positioned(
          bottom: bottomPadding,
          left: 0,
          right: 0,
          child: Center(child: child),
        );
      case ChallengeHintPosition.topLeft:
        return Positioned(
          top: topPadding,
          left: 20,
          child: child,
        );
      case ChallengeHintPosition.topRight:
        return Positioned(
          top: topPadding,
          right: 20,
          child: child,
        );
      case ChallengeHintPosition.bottomLeft:
        return Positioned(
          bottom: bottomPadding,
          left: 20,
          child: child,
        );
      case ChallengeHintPosition.bottomRight:
        return Positioned(
          bottom: bottomPadding,
          right: 20,
          child: child,
        );
    }
  }
}