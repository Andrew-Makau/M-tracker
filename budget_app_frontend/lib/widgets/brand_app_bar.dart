import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// BrandAppBar
/// A thin wrapper around AppBar that applies the app's brand gradient
/// and consistent sizing/styles across the app. Accepts the same
/// commonly-used properties: `title`, `leading`, `actions`, `bottom`.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const BrandAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useGradient = backgroundColor == null || backgroundColor == Colors.transparent;

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Colors.transparent,
      shadowColor: elevation > 0 ? Colors.black12 : null,
      // gradient background using Brand colors — only when backgroundColor is transparent
      flexibleSpace: useGradient ? Container(
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
        ),
      ) : null,
      // use the app theme's appBar text/icon styles, or default to black for white backgrounds
      iconTheme: backgroundColor == Colors.white 
          ? const IconThemeData(color: Colors.black)
          : theme.appBarTheme.iconTheme ?? const IconThemeData(),
      titleTextStyle: theme.appBarTheme.titleTextStyle,
      actionsIconTheme: backgroundColor == Colors.white
          ? const IconThemeData(color: Colors.black)
          : theme.appBarTheme.actionsIconTheme,
      bottom: bottom,
    );
  }
}
