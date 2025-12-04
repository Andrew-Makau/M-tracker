import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pressable.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Pressable(
            onTapDown: widget.isEnabled && !widget.isLoading
                ? (_) {
                    setState(() {
                      _isPressed = true;
                    });
                    _animationController.forward();
                    HapticFeedback.mediumImpact();
                  }
                : null,
            onTapUp: widget.isEnabled && !widget.isLoading
                ? (_) {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                    widget.onPressed();
                  }
                : null,
            onTapCancel: widget.isEnabled && !widget.isLoading
                ? () {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                  }
                : null,
            onTap: widget.isEnabled && !widget.isLoading ? () {} : null,
            child: Container(
              width: double.infinity,
              height: 7.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isEnabled
                        ? [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withAlpha(204),
                          ]
                        : [
                            Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(77),
                            Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(51),
                          ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isEnabled && !_isPressed
                    ? [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  if (widget.isEnabled && !widget.isLoading)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(
                                  -1.0 + _shimmerAnimation.value, 0.0),
                              end:
                                  Alignment(1.0 + _shimmerAnimation.value, 0.0),
                                colors: [
                                Colors.transparent,
                                Theme.of(context).colorScheme.onPrimary.withAlpha(26),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 6.w,
                            height: 6.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isEnabled
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Text(
                            widget.text,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                                color: widget.isEnabled
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(153),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
