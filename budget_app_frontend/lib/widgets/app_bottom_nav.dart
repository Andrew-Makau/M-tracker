import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28), // slightly larger radius to prevent overlap
        clipBehavior: Clip.hardEdge,
        child: Container(
          // Outer container to apply shadow and rounded clip
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: CurvedNavigationBar(
            height: 64,
            // Transparent to avoid edge artifacts against vibrant background
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.primary, // grey bar
            buttonBackgroundColor: Theme.of(context).colorScheme.secondary, // orange active bubble
            animationCurve: Curves.easeOutCubic,
            animationDuration: const Duration(milliseconds: 240),
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: currentIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
              ),
              Icon(
                Icons.history,
                size: 30,
                color: currentIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
              ),
              Icon(
                Icons.pie_chart,
                size: 30,
                color: currentIndex == 2
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
              ),
              Icon(
                Icons.bar_chart,
                size: 30,
                color: currentIndex == 3
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
              ),
            ],
            index: currentIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              onTap(index);
            },
          ),
        ),
      ),
    );
  }
}
