import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedGradientBackground extends StatelessWidget {
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        MirrorAnimationBuilder<Color?>(
          tween: ColorTween(
            begin:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            end: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.2),
          ),
          duration: const Duration(seconds: 4),
          builder: (context, value, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    value ??
                        AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                    AppTheme.lightTheme.colorScheme.surface,
                    AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
        // Floating geometric shapes
        _buildFloatingShapes(),
        // Main content
        child,
      ],
    );
  }

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        // Top right circle
        Positioned(
          top: -50,
          right: -50,
          child: MirrorAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 20.0),
            duration: const Duration(seconds: 6),
            builder: (context, value, _) {
              return Transform.translate(
                offset: Offset(value, value * 0.5),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom left circle
        Positioned(
          bottom: -30,
          left: -30,
          child: MirrorAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: -15.0),
            duration: const Duration(seconds: 5),
            builder: (context, value, _) {
              return Transform.translate(
                offset: Offset(value, value * 0.8),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.tertiary
                        .withValues(alpha: 0.1),
                  ),
                ),
              );
            },
          ),
        ),
        // Middle floating rectangle
        Positioned(
          top: 200,
          left: -20,
          child: MirrorAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 10.0),
            duration: const Duration(seconds: 7),
            builder: (context, value, _) {
              return Transform.rotate(
                angle: value * 0.1,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
