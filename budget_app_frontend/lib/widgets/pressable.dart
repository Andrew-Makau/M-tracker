import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Pressable
/// Wraps [InkWell] (or [GestureDetector]) to provide consistent
/// ripple, padding, and haptic feedback across the app.
class Pressable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (onTap != null) onTap!();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    if (onLongPress != null) onLongPress!();
  }

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: br,
        splashColor: splashColor ?? Theme.of(context).colorScheme.secondary.withAlpha(31),
        highlightColor: highlightColor ?? Colors.transparent,
        onTap: onTap == null ? null : _handleTap,
        onLongPress: onLongPress == null ? null : _handleLongPress,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppTheme.spacingSmall),
          child: child,
        ),
      ),
    );
  }
}
