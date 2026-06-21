import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// 🎨 Formal Animated Background untuk Sekolah
///
/// Features:
/// - Animated gradient background (formal colors)
/// - Floating bubble particles
/// - Light & Dark mode support
/// - Smooth continuous animations
/// - Customizable colors & bubble count
///
/// Usage:
/// ```dart
/// AnimatedBackground(
///   isDarkMode: false,
///   child: YourContent(),
/// )
/// ```
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final int bubbleCount;
  final Duration animationDuration;
  final bool isDarkMode;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.gradientColors,
    this.bubbleCount = 15,
    this.animationDuration = const Duration(seconds: 10),
    this.isDarkMode = false,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;

  // Bubble animations
  final List<AnimationController> _bubbleControllers = [];
  final List<Animation<double>> _bubbleAnimations = [];

  @override
  void initState() {
    super.initState();
    _initGradientAnimation();
    _initBubbleAnimations();
  }

  void _initGradientAnimation() {
    _gradientController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  void _initBubbleAnimations() {
    final random = math.Random();
    for (int i = 0; i < widget.bubbleCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 2000 + random.nextInt(3000)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _bubbleControllers.add(controller);
      _bubbleAnimations.add(animation);

      // Stagger animations
      Future.delayed(Duration(milliseconds: random.nextInt(2000)), () {
        if (mounted) {
          controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        _buildAnimatedBackground(),

        // Floating bubbles
        ..._buildFloatingBubbles(),

        // Child content
        widget.child,
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    // Use formal colors or custom colors
    final colors = widget.gradientColors ??
        (widget.isDarkMode
            ? [
                AppColors.darkBackground,
                AppColors.darkSurface,
                AppColors.darkBackground,
              ]
            : [
                AppColors.formalNavy,
                AppColors.formalNavyLight,
                AppColors.formalNavy,
              ]);

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _gradientController.value == 0
                  ? null
                  : GradientRotation(_gradientController.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingBubbles() {
    final random = math.Random();
    final size = MediaQuery.of(context).size;
    final bubbles = <Widget>[];

    // Bubble color based on theme
    final bubbleColor = widget.isDarkMode
        ? AppColors.darkAccent.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.3);
    final shadowColor = widget.isDarkMode
        ? AppColors.darkAccent.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.1);

    for (int i = 0; i < widget.bubbleCount; i++) {
      final bubbleSize = 20.0 + random.nextDouble() * 40;
      final top = random.nextDouble() * size.height;
      final left = random.nextDouble() * size.width;

      bubbles.add(
        Positioned(
          top: top,
          left: left,
          child: AnimatedBuilder(
            animation: _bubbleAnimations[i],
            builder: (context, child) {
              return Opacity(
                opacity: 0.1 + _bubbleAnimations[i].value * 0.2,
                child: Transform.translate(
                  offset: Offset(0, -_bubbleAnimations[i].value * 50),
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bubbleColor,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return bubbles;
  }
}
