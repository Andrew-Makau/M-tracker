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

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? Colors.transparent,
      // gradient background using Brand colors — uses theme-level gradient if available
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
        ),
      ),
      // use the app theme's appBar text/icon styles where possible
      iconTheme: theme.appBarTheme.iconTheme ?? const IconThemeData(),
      titleTextStyle: theme.appBarTheme.titleTextStyle,
      actionsIconTheme: theme.appBarTheme.actionsIconTheme,
      bottom: bottom,
    );
  }
}
