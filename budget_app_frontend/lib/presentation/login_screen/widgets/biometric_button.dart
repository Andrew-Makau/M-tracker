import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const BiometricButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isEnabled
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed();
                }
              : null,
          onTapDown: (_) {
            if (widget.isEnabled) {
              _animationController.stop();
            }
          },
          onTapUp: (_) {
            if (widget.isEnabled) {
              _animationController.repeat(reverse: true);
            }
          },
          onTapCancel: () {
            if (widget.isEnabled) {
              _animationController.repeat(reverse: true);
            }
          },
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isEnabled
                      ? [
                          AppTheme.lightTheme.colorScheme.primary,
                          AppTheme.lightTheme.colorScheme.secondary,
                        ]
                      : [
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.2),
                        ],
                ),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 5 * _pulseAnimation.value,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'fingerprint',
                  color: widget.isEnabled
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                  size: 8.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
